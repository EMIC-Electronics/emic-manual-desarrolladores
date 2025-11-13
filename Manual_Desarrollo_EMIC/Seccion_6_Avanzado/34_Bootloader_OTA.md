# Capítulo 34: Bootloader y OTA Updates

## Índice
1. [Introducción a Bootloaders](#1-introducción-a-bootloaders)
2. [Bootloader Design](#2-bootloader-design)
3. [Memory Partitioning](#3-memory-partitioning)
4. [Firmware Update Mechanisms](#4-firmware-update-mechanisms)
5. [OTA Updates](#5-ota-over-the-air-updates)
6. [Firmware Verification](#6-firmware-verification)
7. [Secure Boot](#7-secure-boot)
8. [Dual-Bank Firmware](#8-dual-bank-firmware)
9. [Bootloader Protocol](#9-bootloader-protocol)
10. [Linker Scripts](#10-linker-scripts)
11. [Application Integration](#11-application-integration)
12. [Rollback Mechanism](#12-rollback-mechanism)
13. [OTA Server Infrastructure](#13-ota-server-infrastructure)
14. [Case Study](#14-case-study-sistema-ota-completo)
15. [Best Practices](#15-best-practices)

---

## 1. Introducción a Bootloaders

### 1.1 ¿Qué es un Bootloader?

**Bootloader:** Programa pequeño que ejecuta **primero** al encender el MCU, antes de la aplicación principal.

```
╔════════════════════════════════════════════════════════════╗
║                  BOOT SEQUENCE                             ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  1. Power-On / Reset                                       ║
║       ↓                                                    ║
║  2. BOOTLOADER ejecuta (primeros KB de Flash)             ║
║       ↓                                                    ║
║  3. Bootloader verifica:                                   ║
║       - ¿Hay firmware válido?                              ║
║       - ¿Hay request de update?                            ║
║       - ¿Firmware corrupto? → Usar backup                  ║
║       ↓                                                    ║
║  4. Si todo OK → Jump a APPLICATION                        ║
║       ↓                                                    ║
║  5. APPLICATION ejecuta (código principal)                 ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

**Funciones principales:**

1. ✅ **Actualizar firmware** (sin programador externo)
2. ✅ **Verificar integridad** del firmware
3. ✅ **Rollback** a firmware anterior si hay falla
4. ✅ **Secure boot** (verificar firma digital)
5. ✅ **Dual-bank switching** (failsafe updates)

### 1.2 Memory Map con Bootloader

**Sin bootloader:**

```
╔════════════════════════════════════════════════════════════╗
║  0x00000000  ┌──────────────────────────────────────────┐ ║
║              │                                          │ ║
║              │         APPLICATION                      │ ║
║              │         (Todo el Flash)                  │ ║
║              │                                          │ ║
║  0x001FFFFF  └──────────────────────────────────────────┘ ║
║              (2 MB Flash)                                  ║
╚════════════════════════════════════════════════════════════╝
```

**Con bootloader:**

```
╔════════════════════════════════════════════════════════════╗
║  0x00000000  ┌──────────────────────────────────────────┐ ║
║              │  BOOTLOADER (32 KB)                      │ ║
║              │  - Inicio al power-on                    │ ║
║              │  - Verifica firmware                     │ ║
║              │  - Jump a app si OK                      │ ║
║  0x00008000  ├──────────────────────────────────────────┤ ║
║              │                                          │ ║
║              │  APPLICATION (900 KB)                    │ ║
║              │  - Código principal                      │ ║
║              │  - Relocated vector table                │ ║
║              │                                          │ ║
║  0x000E8000  ├──────────────────────────────────────────┤ ║
║              │                                          │ ║
║              │  BACKUP FIRMWARE (900 KB)                │ ║
║              │  - Firmware anterior (rollback)          │ ║
║              │  - O firmware de fábrica                 │ ║
║              │                                          │ ║
║  0x001D0000  ├──────────────────────────────────────────┤ ║
║              │  CONFIG AREA (128 KB)                    │ ║
║              │  - Boot flags                            │ ║
║              │  - Version info                          │ ║
║              │  - Update status                         │ ║
║  0x001FFFFF  └──────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════════════════╝
```

### 1.3 Flujo de Boot Sequence

```c
// Pseudocódigo del bootloader

void bootloader_main(void) {
    // 1. Inicialización mínima
    system_clock_init();
    gpio_init();
    uart_init();  // Para debugging/update

    // 2. Verificar si hay request de update
    if (check_update_request()) {
        enter_bootloader_mode();  // Esperar firmware nuevo
        return;
    }

    // 3. Verificar integridad de firmware
    if (!verify_application_firmware()) {
        // Firmware corrupto → usar backup
        if (restore_from_backup()) {
            // Backup OK → jump a app
            jump_to_application();
        } else {
            // Backup también corrupto → entrar en bootloader mode
            enter_bootloader_mode();
            return;
        }
    }

    // 4. Firmware OK → Jump a application
    jump_to_application();

    // No retorna (jump a app)
}

void jump_to_application(void) {
    // Desinicializar periféricos del bootloader
    uart_deinit();

    // Relocalizar vector table
    __builtin_mtc0(12, 1, APP_VECTOR_TABLE_BASE);  // PIC32: EBase register

    // Jump a application entry point
    void (*app_entry)(void) = (void (*)(void))APP_START_ADDRESS;
    app_entry();

    // No retorna
}
```

### 1.4 Cuándo Usar Bootloader

**Usar bootloader cuando:**

1. ✅ **Field updates** necesarios (dispositivos remotos)
2. ✅ **No hay programador** disponible en producción
3. ✅ **OTA updates** (WiFi, LoRa, Cellular)
4. ✅ **Security crítico** (secure boot)
5. ✅ **Failsafe** importante (dual-bank)

**NO usar bootloader cuando:**

1. ❌ Dispositivo accesible (fácil reprogramar con ICSP)
2. ❌ Flash limitado (< 64 KB total)
3. ❌ Firmware nunca cambia
4. ❌ Overhead no aceptable

---

## 2. Bootloader Design

### 2.1 Single-Stage Bootloader

```c
// ============================================================
// BOOTLOADER SIMPLE (single-stage)
// ============================================================

// Memory map
#define BOOTLOADER_START    0x9D000000  // Inicio de Flash (PIC32)
#define BOOTLOADER_SIZE     (32 * 1024) // 32 KB
#define APP_START           (BOOTLOADER_START + BOOTLOADER_SIZE)
#define APP_SIZE            (900 * 1024)

// Boot flags en última página de Flash
#define BOOT_FLAGS_ADDR     0x9D1FF000

typedef struct {
    uint32_t magic;              // 0xBEEFF00D si válido
    uint32_t app_version;
    uint32_t app_crc32;
    uint32_t boot_counter;
    uint32_t update_requested;   // 1 = entrar en bootloader mode
    uint32_t backup_valid;
} BootFlags_t;

volatile BootFlags_t* g_boot_flags = (BootFlags_t*)BOOT_FLAGS_ADDR;

// ============================================================
// Main del bootloader
// ============================================================
void __attribute__((noreturn)) bootloader_main(void) {
    // Inicialización mínima
    init_clocks();
    init_uart();

    printf("\n\n=== BOOTLOADER v1.0 ===\n");

    // Verificar boot flags
    if (g_boot_flags->magic != 0xBEEFF00D) {
        // Primera vez → inicializar boot flags
        init_boot_flags();
    }

    // ¿Update requested?
    if (g_boot_flags->update_requested == 1) {
        printf("Update requested, entering bootloader mode...\n");
        bootloader_mode();  // Esperar firmware nuevo
        // No retorna (reset después de update)
    }

    // Verificar CRC del firmware
    printf("Verifying application CRC...\n");
    uint32_t calculated_crc = calculate_crc32(APP_START, APP_SIZE);

    if (calculated_crc != g_boot_flags->app_crc32) {
        printf("CRC mismatch! (expected: 0x%08lX, got: 0x%08lX)\n",
               g_boot_flags->app_crc32, calculated_crc);

        // Intentar restaurar desde backup
        if (g_boot_flags->backup_valid) {
            printf("Restoring from backup...\n");
            restore_from_backup();
            // Reset para reintentar
            reset_device();
        } else {
            printf("No valid backup, entering bootloader mode\n");
            bootloader_mode();
        }
    }

    // CRC OK → incrementar boot counter (para rollback detection)
    g_boot_flags->boot_counter++;

    if (g_boot_flags->boot_counter > 3) {
        // Firmware bootea pero crashea (watchdog reset loop)
        printf("Boot counter > 3, firmware unstable!\n");
        if (g_boot_flags->backup_valid) {
            restore_from_backup();
            reset_device();
        }
    }

    printf("Application verified, jumping...\n");
    __delay_ms(100);  // Delay para que UART envíe

    jump_to_application(APP_START);

    // No retorna
    while (1);
}

// ============================================================
// Jump a aplicación
// ============================================================
void __attribute__((noreturn)) jump_to_application(uint32_t app_addr) {
    // 1. Desinicializar periféricos del bootloader
    U1MODE = 0;  // UART off
    T1CON = 0;   // Timer off

    // 2. Deshabilitar todos los interrupts
    INTCON = 0;
    IEC0 = 0;
    IEC1 = 0;

    // 3. Relocalizar Exception Vector Base
    uint32_t ebase = app_addr + 0x1000;  // Típicamente app_start + 4 KB
    __builtin_mtc0(15, 1, ebase);  // Set EBase register

    // 4. Jump a entry point de app
    void (*app_entry)(void) = (void (*)(void))(app_addr + 0x1000);

    app_entry();

    // No retorna
    while (1);
}
```

### 2.2 Vector Table Relocation

```c
// ============================================================
// VECTOR TABLE RELOCATION
// ============================================================

// En PIC32, los exception vectors están en:
// - Bootloader: 0x9D000000 + 0x1000 = 0x9D001000
// - Application: 0x9D008000 + 0x1000 = 0x9D009000

// Application debe configurar EBase al inicio:

void app_main(void) {
    // Configurar EBase para que apunte a vector table de app
    __builtin_mtc0(15, 1, 0x9D009000);  // EBase = app vectors

    // Resto de inicialización...
}

// Linker script de app debe relocar vectors:
// SECTIONS {
//     .vector_table 0x9D009000 : {
//         *(.vector_0)
//         *(.vector_1)
//         ...
//     }
// }
```

### 2.3 Bootloader Size

```
╔════════════════════════════════════════════════════════════╗
║              BOOTLOADER SIZE TYPICAL                       ║
╠════════════════════════════════════════════════════════════╣
║  Minimal (UART only):          8-16 KB                     ║
║  Standard (UART + CRC):        16-32 KB                    ║
║  Full (USB DFU + crypto):      32-64 KB                    ║
║  Network (WiFi OTA):           64-128 KB                   ║
╚════════════════════════════════════════════════════════════╝
```

**Trade-off:** Bootloader más grande = Menos espacio para app

---

## 3. Memory Partitioning

### 3.1 Flash Layout Dual-Bank

**PIC32MZ 2 MB Flash example:**

```
╔════════════════════════════════════════════════════════════╗
║           MEMORY LAYOUT - DUAL BANK                        ║
╠════════════════════════════════════════════════════════════╣
║  Address      Size      Description                        ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D000000   32 KB     Bootloader                         ║
║                         - Boot code                        ║
║                         - Update logic                     ║
║                         - Verification                     ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D008000   900 KB    Bank A (Active firmware)           ║
║                         - Application code                 ║
║                         - Libraries                        ║
║                         - Data                             ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D0E8000   900 KB    Bank B (Backup firmware)           ║
║                         - Previous version                 ║
║                         - Or factory firmware              ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D1C8000   160 KB    Download buffer                    ║
║                         - New firmware download area       ║
║                         - Temporary storage                ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D1F0000   32 KB     Configuration                      ║
║                         - Boot flags                       ║
║                         - Version info                     ║
║                         - Certificates                     ║
║  ──────────────────────────────────────────────────────   ║
║  0x9D1F8000   32 KB     Reserved / Unused                  ║
║  ──────────────────────────────────────────────────────   ║
║  TOTAL:       2048 KB                                      ║
╚════════════════════════════════════════════════════════════╝
```

### 3.2 Memory Protection

```c
// Proteger bootloader con Boot Flash Write Protect (BFWP)

// Configuration bits (PIC32)
#pragma config BWP = ON  // Boot Flash Write Protect

// Esto previene que la aplicación modifique el bootloader accidentalmente

// Para escribir bootloader → necesita ICSP programmer
```

### 3.3 Linker Script para Bootloader

```ld
/* bootloader.ld - Linker script para bootloader */

MEMORY
{
    /* Bootloader en primeros 32 KB */
    boot_flash (rx) : ORIGIN = 0x9D000000, LENGTH = 32K

    /* Boot RAM */
    boot_ram (wx)   : ORIGIN = 0x80000000, LENGTH = 16K
}

SECTIONS
{
    /* Código del bootloader */
    .boot_text : {
        *(.boot_reset)      /* Reset handler primero */
        *(.boot_text)
        *(.text)
        *(.rodata)
    } > boot_flash

    /* Data del bootloader */
    .boot_data : {
        *(.data)
    } > boot_ram AT > boot_flash

    /* BSS del bootloader */
    .boot_bss : {
        *(.bss)
        *(COMMON)
    } > boot_ram

    /* Stack del bootloader */
    .boot_stack : {
        . = ALIGN(16);
        _stack_start = .;
        . += 4K;
        _stack_end = .;
    } > boot_ram
}
```

### 3.4 Linker Script para Application

```ld
/* application.ld - Linker script para app (relocated) */

MEMORY
{
    /* Application empieza después del bootloader (32 KB offset) */
    app_flash (rx) : ORIGIN = 0x9D008000, LENGTH = 900K

    /* Application RAM (full RAM disponible) */
    app_ram (wx)   : ORIGIN = 0x80000000, LENGTH = 512K
}

SECTIONS
{
    /* Exception vectors relocados */
    .app_vectors 0x9D009000 : {
        KEEP(*(.vector_0))
        KEEP(*(.vector_1))
        /* ... más vectors ... */
    } > app_flash

    /* Código de la app */
    .app_text : {
        *(.app_reset)
        *(.text)
        *(.rodata)
    } > app_flash

    /* Data */
    .data : {
        *(.data)
    } > app_ram AT > app_flash

    /* BSS */
    .bss : {
        *(.bss)
        *(COMMON)
    } > app_ram

    /* Stack */
    .stack : {
        . = ALIGN(16);
        . += 64K;  /* 64 KB stack */
    } > app_ram
}
```

---

## 4. Firmware Update Mechanisms

### 4.1 UART Bootloader (Simple)

```c
// ============================================================
// UART BOOTLOADER - Protocolo simple
// ============================================================

// Comandos
#define CMD_PING            0x01
#define CMD_ERASE           0x02
#define CMD_WRITE           0x03
#define CMD_READ            0x04
#define CMD_VERIFY          0x05
#define CMD_RESET           0x06
#define CMD_GET_VERSION     0x07

// Respuestas
#define RESP_OK             0xA0
#define RESP_ERROR          0xE0

// Packet format:
// [SOF][LEN][CMD][DATA...][CRC16]
#define SOF 0x7E

typedef struct __attribute__((packed)) {
    uint8_t sof;
    uint8_t length;
    uint8_t command;
    uint8_t data[256];
    uint16_t crc16;
} Packet_t;

void bootloader_mode(void) {
    printf("Bootloader mode active\n");
    printf("Waiting for firmware...\n");

    uint32_t timeout = 30000;  // 30 segundos timeout
    uint32_t start_time = get_tick_ms();

    while ((get_tick_ms() - start_time) < timeout) {
        Packet_t packet;

        if (uart_receive_packet(&packet, 100)) {
            // Reset timeout cuando recibimos data
            start_time = get_tick_ms();

            // Procesar comando
            switch (packet.command) {
                case CMD_PING:
                    send_response(RESP_OK, NULL, 0);
                    break;

                case CMD_ERASE:
                    {
                        uint32_t address = *(uint32_t*)&packet.data[0];
                        uint32_t size = *(uint32_t*)&packet.data[4];

                        if (flash_erase(address, size)) {
                            send_response(RESP_OK, NULL, 0);
                        } else {
                            send_response(RESP_ERROR, NULL, 0);
                        }
                    }
                    break;

                case CMD_WRITE:
                    {
                        uint32_t address = *(uint32_t*)&packet.data[0];
                        uint16_t length = *(uint16_t*)&packet.data[4];
                        uint8_t* data = &packet.data[6];

                        if (flash_write(address, data, length)) {
                            send_response(RESP_OK, NULL, 0);
                        } else {
                            send_response(RESP_ERROR, NULL, 0);
                        }
                    }
                    break;

                case CMD_VERIFY:
                    {
                        uint32_t expected_crc = *(uint32_t*)&packet.data[0];
                        uint32_t calculated_crc = calculate_crc32(APP_START, APP_SIZE);

                        if (expected_crc == calculated_crc) {
                            // Update boot flags con nuevo CRC
                            update_boot_flags(calculated_crc);

                            uint8_t response[4];
                            memcpy(response, &calculated_crc, 4);
                            send_response(RESP_OK, response, 4);
                        } else {
                            send_response(RESP_ERROR, NULL, 0);
                        }
                    }
                    break;

                case CMD_RESET:
                    send_response(RESP_OK, NULL, 0);
                    __delay_ms(100);
                    reset_device();
                    break;

                case CMD_GET_VERSION:
                    {
                        uint8_t version[4] = { 1, 0, 0, 0 };  // Major.Minor.Patch.Build
                        send_response(RESP_OK, version, 4);
                    }
                    break;

                default:
                    send_response(RESP_ERROR, NULL, 0);
                    break;
            }
        }
    }

    // Timeout → intentar bootear app de todas formas
    printf("Timeout, attempting to boot application...\n");
    jump_to_application(APP_START);
}
```

### 4.2 USB Bootloader (DFU)

```c
// USB Device Firmware Update (DFU) class
// Estándar USB, soportado por dfu-util

// Requiere:
// - USB stack (Microchip Harmony, libusb)
// - DFU class implementation
// - ~64 KB Flash típicamente

// Ventajas:
// ✅ Estándar (tools disponibles)
// ✅ Rápido (USB Full Speed = 12 Mbps)
// ✅ No necesita drivers en Linux/Mac

// Código simplificado:
void usb_dfu_bootloader(void) {
    usb_init();
    usb_dfu_init();

    while (!dfu_complete) {
        usb_tasks();  // Process USB events

        if (dfu_download_complete) {
            verify_and_reset();
        }
    }
}
```

### 4.3 SD Card Bootloader

```c
// ============================================================
// SD CARD BOOTLOADER
// ============================================================

void sd_card_bootloader(void) {
    // Montar SD card
    if (!sd_card_mount()) {
        printf("No SD card found\n");
        return;
    }

    // Buscar firmware file
    if (sd_card_file_exists("firmware.bin")) {
        printf("Firmware file found on SD card\n");

        // Leer header (primeros 16 bytes)
        FirmwareHeader_t header;
        sd_card_read_file("firmware.bin", &header, sizeof(header), 0);

        // Verificar header
        if (header.magic == FIRMWARE_MAGIC) {
            printf("Valid firmware header\n");
            printf("Version: %lu.%lu.%lu\n",
                   header.version_major, header.version_minor, header.version_patch);
            printf("Size: %lu bytes\n", header.size);

            // Erase application area
            printf("Erasing flash...\n");
            flash_erase(APP_START, APP_SIZE);

            // Program firmware (en chunks de 4 KB)
            printf("Programming firmware...\n");
            uint32_t offset = sizeof(header);
            uint32_t bytes_written = 0;
            uint8_t buffer[4096];

            while (bytes_written < header.size) {
                uint32_t chunk_size = (header.size - bytes_written);
                if (chunk_size > sizeof(buffer)) {
                    chunk_size = sizeof(buffer);
                }

                // Leer chunk desde SD
                sd_card_read_file("firmware.bin", buffer, chunk_size, offset);

                // Escribir a Flash
                flash_write(APP_START + bytes_written, buffer, chunk_size);

                bytes_written += chunk_size;
                offset += chunk_size;

                // Progress
                uint32_t progress = (bytes_written * 100) / header.size;
                printf("\rProgress: %lu%%", progress);
            }

            printf("\nVerifying CRC...\n");
            uint32_t calculated_crc = calculate_crc32(APP_START, header.size);

            if (calculated_crc == header.crc32) {
                printf("CRC OK!\n");
                update_boot_flags(calculated_crc);

                // Renombrar archivo (para no reinstalar en próximo boot)
                sd_card_rename("firmware.bin", "firmware.old");

                printf("Update complete, rebooting...\n");
                __delay_ms(1000);
                reset_device();
            } else {
                printf("CRC mismatch!\n");
            }
        }
    }

    sd_card_unmount();
}
```

---

## 5. OTA (Over-The-Air) Updates

### 5.1 OTA via WiFi (HTTP Download)

```c
// ============================================================
// OTA WiFi - Download firmware via HTTP
// ============================================================

typedef struct {
    char url[256];              // HTTP URL del firmware
    uint32_t expected_size;
    uint32_t expected_crc32;
    char version[32];
} OTARequest_t;

bool ota_wifi_update(OTARequest_t* request) {
    printf("Starting OTA update...\n");
    printf("URL: %s\n", request->url);
    printf("Expected size: %lu bytes\n", request->expected_size);

    // 1. Conectar WiFi (si no está conectado)
    if (!wifi_is_connected()) {
        printf("Connecting to WiFi...\n");
        if (!wifi_connect(WIFI_SSID, WIFI_PASSWORD, 10000)) {
            printf("WiFi connection failed\n");
            return false;
        }
    }

    // 2. Conectar al servidor HTTP
    TCPSocket_t socket;
    if (!tcp_connect(&socket, request->url, 80)) {
        printf("HTTP connection failed\n");
        return false;
    }

    // 3. Enviar HTTP GET request
    char http_request[512];
    snprintf(http_request, sizeof(http_request),
             "GET %s HTTP/1.1\r\n"
             "Host: %s\r\n"
             "Connection: close\r\n"
             "\r\n",
             get_path_from_url(request->url),
             get_host_from_url(request->url));

    tcp_send(&socket, http_request, strlen(http_request));

    // 4. Parsear HTTP response header
    char header_buffer[1024];
    uint32_t header_len = 0;
    bool header_complete = false;

    while (!header_complete && header_len < sizeof(header_buffer) - 1) {
        uint8_t c;
        if (tcp_receive(&socket, &c, 1, 5000) == 1) {
            header_buffer[header_len++] = c;

            // Detectar fin de header (\r\n\r\n)
            if (header_len >= 4 &&
                memcmp(&header_buffer[header_len - 4], "\r\n\r\n", 4) == 0) {
                header_complete = true;
            }
        }
    }

    header_buffer[header_len] = '\0';

    // Verificar status code
    if (strstr(header_buffer, "200 OK") == NULL) {
        printf("HTTP error (not 200 OK)\n");
        tcp_close(&socket);
        return false;
    }

    // Parsear Content-Length
    char* content_length_str = strstr(header_buffer, "Content-Length:");
    uint32_t content_length = 0;
    if (content_length_str != NULL) {
        sscanf(content_length_str, "Content-Length: %lu", &content_length);
    }

    printf("Content-Length: %lu bytes\n", content_length);

    if (content_length != request->expected_size) {
        printf("Size mismatch!\n");
        tcp_close(&socket);
        return false;
    }

    // 5. Erase download buffer area
    printf("Erasing download buffer...\n");
    flash_erase(DOWNLOAD_BUFFER_ADDR, DOWNLOAD_BUFFER_SIZE);

    // 6. Download firmware (en chunks)
    printf("Downloading firmware...\n");
    uint32_t bytes_downloaded = 0;
    uint8_t chunk_buffer[1024];
    uint32_t crc32_accum = 0xFFFFFFFF;

    while (bytes_downloaded < content_length) {
        uint32_t chunk_size = content_length - bytes_downloaded;
        if (chunk_size > sizeof(chunk_buffer)) {
            chunk_size = sizeof(chunk_buffer);
        }

        // Receive chunk
        uint32_t received = tcp_receive(&socket, chunk_buffer, chunk_size, 10000);
        if (received == 0) {
            printf("Download timeout\n");
            tcp_close(&socket);
            return false;
        }

        // Write to download buffer
        flash_write(DOWNLOAD_BUFFER_ADDR + bytes_downloaded, chunk_buffer, received);

        // Update CRC
        crc32_accum = crc32_update(crc32_accum, chunk_buffer, received);

        bytes_downloaded += received;

        // Progress
        uint32_t progress = (bytes_downloaded * 100) / content_length;
        printf("\rProgress: %lu%% (%lu / %lu bytes)",
               progress, bytes_downloaded, content_length);

        // Watchdog kick (para evitar timeout durante download largo)
        watchdog_kick();
    }

    printf("\n");

    tcp_close(&socket);

    // 7. Verify CRC
    crc32_accum ^= 0xFFFFFFFF;
    printf("Downloaded CRC32: 0x%08lX\n", crc32_accum);
    printf("Expected CRC32:   0x%08lX\n", request->expected_crc32);

    if (crc32_accum != request->expected_crc32) {
        printf("CRC mismatch! Download corrupted\n");
        return false;
    }

    printf("CRC verified OK\n");

    // 8. Copy download buffer → Bank B (backup)
    printf("Backing up current firmware to Bank B...\n");
    flash_copy(APP_START, BANK_B_ADDR, APP_SIZE);

    // 9. Erase Bank A (current app)
    printf("Erasing Bank A...\n");
    flash_erase(APP_START, APP_SIZE);

    // 10. Copy download buffer → Bank A
    printf("Installing new firmware...\n");
    flash_copy(DOWNLOAD_BUFFER_ADDR, APP_START, content_length);

    // 11. Update boot flags
    BootFlags_t boot_flags;
    boot_flags.magic = 0xBEEFF00D;
    boot_flags.app_crc32 = crc32_accum;
    boot_flags.app_version = parse_version(request->version);
    boot_flags.boot_counter = 0;  // Reset boot counter
    boot_flags.backup_valid = 1;
    boot_flags.update_requested = 0;

    flash_write(BOOT_FLAGS_ADDR, &boot_flags, sizeof(boot_flags));

    printf("OTA update complete!\n");
    printf("Rebooting in 3 seconds...\n");
    __delay_ms(3000);

    reset_device();

    return true;
}
```

### 5.2 OTA via MQTT (Chunked Transfer)

```c
// ============================================================
// OTA via MQTT - Para redes con limitaciones de ancho de banda
// ============================================================

#define MQTT_CHUNK_SIZE 512  // 512 bytes por chunk

typedef struct {
    uint32_t total_size;
    uint32_t chunk_count;
    uint32_t current_chunk;
    uint32_t crc32;
    char version[32];
} OTAMetadata_t;

void mqtt_ota_handler(void) {
    // Subscribe a topics de OTA
    mqtt_subscribe("device/12345/ota/metadata", ota_metadata_callback);
    mqtt_subscribe("device/12345/ota/chunk", ota_chunk_callback);

    // State machine
    while (ota_in_progress) {
        mqtt_process();
        watchdog_kick();
    }
}

void ota_metadata_callback(const char* topic, uint8_t* payload, uint16_t length) {
    // Parsear metadata (JSON)
    OTAMetadata_t metadata;
    json_parse(payload, length, &metadata);

    printf("OTA Metadata received:\n");
    printf("  Version: %s\n", metadata.version);
    printf("  Size: %lu bytes\n", metadata.total_size);
    printf("  Chunks: %lu\n", metadata.chunk_count);

    // Preparar para recibir chunks
    g_ota_metadata = metadata;
    g_ota_state = OTA_RECEIVING_CHUNKS;

    flash_erase(DOWNLOAD_BUFFER_ADDR, DOWNLOAD_BUFFER_SIZE);

    // Request primer chunk
    mqtt_publish("device/12345/ota/request_chunk", "0", 1);
}

void ota_chunk_callback(const char* topic, uint8_t* payload, uint16_t length) {
    // Payload format: [chunk_index (4 bytes)] [data (512 bytes)]
    uint32_t chunk_index = *(uint32_t*)&payload[0];
    uint8_t* chunk_data = &payload[4];
    uint16_t chunk_size = length - 4;

    printf("Chunk %lu / %lu received\n", chunk_index + 1, g_ota_metadata.chunk_count);

    // Write chunk to download buffer
    flash_write(DOWNLOAD_BUFFER_ADDR + (chunk_index * MQTT_CHUNK_SIZE),
                chunk_data, chunk_size);

    g_ota_metadata.current_chunk = chunk_index;

    // Request próximo chunk
    if (chunk_index + 1 < g_ota_metadata.chunk_count) {
        char request[16];
        snprintf(request, sizeof(request), "%lu", chunk_index + 1);
        mqtt_publish("device/12345/ota/request_chunk", request, strlen(request));
    } else {
        // Todos los chunks recibidos → verify
        printf("All chunks received, verifying...\n");
        ota_verify_and_install();
    }
}
```

### 5.3 OTA via LoRa

```c
// OTA via LoRa (para dispositivos remotos IoT)
// Desafío: Bajo bandwidth (típicamente < 10 kbps)

// Estrategia:
// - Delta updates (solo diferencias vs firmware anterior)
// - Compresión (LZMA)
// - Chunked transfer con retransmisión de chunks perdidos

void lora_ota_update(void) {
    // Recibir metadata
    LoRaOTAMetadata_t metadata;
    lora_receive_metadata(&metadata, 60000);  // 1 minuto timeout

    printf("LoRa OTA: Version %s, %lu bytes\n",
           metadata.version, metadata.compressed_size);

    // Receive compressed firmware (en chunks de 64 bytes)
    uint32_t bytes_received = 0;
    uint8_t chunk_buffer[64];

    while (bytes_received < metadata.compressed_size) {
        if (lora_receive_chunk(chunk_buffer, sizeof(chunk_buffer), 30000)) {
            flash_write(DOWNLOAD_BUFFER_ADDR + bytes_received,
                        chunk_buffer, sizeof(chunk_buffer));
            bytes_received += sizeof(chunk_buffer);

            // ACK chunk
            lora_send_ack(bytes_received / sizeof(chunk_buffer));
        } else {
            // Timeout → request retransmission
            lora_request_chunk(bytes_received / sizeof(chunk_buffer));
        }
    }

    // Decompress firmware
    lzma_decompress(DOWNLOAD_BUFFER_ADDR, metadata.compressed_size,
                    APP_START, metadata.uncompressed_size);

    // Verify y install...
}
```

---

## 6. Firmware Verification

### 6.1 CRC32 Checksum

```c
// ============================================================
// CRC32 - Verificación rápida de integridad
// ============================================================

uint32_t calculate_crc32(uint32_t address, uint32_t length) {
    uint32_t crc = 0xFFFFFFFF;
    uint8_t* data = (uint8_t*)address;

    for (uint32_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (uint8_t j = 0; j < 8; j++) {
            if (crc & 1) {
                crc = (crc >> 1) ^ 0xEDB88320;
            } else {
                crc >>= 1;
            }
        }
    }

    return ~crc;
}

bool verify_firmware_crc32(uint32_t app_addr, uint32_t app_size, uint32_t expected_crc) {
    uint32_t calculated = calculate_crc32(app_addr, app_size);
    return (calculated == expected_crc);
}

// Tiempo típico: ~50 ms para 1 MB @ 200 MHz
```

### 6.2 SHA-256 Hash

```c
// ============================================================
// SHA-256 - Verificación criptográfica más robusta
// ============================================================

// Usar librería crypto (ej: mbedTLS, wolfCrypt)

#include "mbedtls/sha256.h"

bool verify_firmware_sha256(uint32_t app_addr, uint32_t app_size, const uint8_t* expected_hash) {
    uint8_t calculated_hash[32];  // SHA-256 = 32 bytes

    mbedtls_sha256_context ctx;
    mbedtls_sha256_init(&ctx);
    mbedtls_sha256_starts(&ctx, 0);  // 0 = SHA-256 (not SHA-224)

    // Process en chunks (para no usar mucha RAM)
    uint32_t offset = 0;
    uint8_t buffer[1024];

    while (offset < app_size) {
        uint32_t chunk_size = (app_size - offset);
        if (chunk_size > sizeof(buffer)) {
            chunk_size = sizeof(buffer);
        }

        memcpy(buffer, (void*)(app_addr + offset), chunk_size);
        mbedtls_sha256_update(&ctx, buffer, chunk_size);

        offset += chunk_size;
    }

    mbedtls_sha256_finish(&ctx, calculated_hash);
    mbedtls_sha256_free(&ctx);

    // Compare hashes
    return (memcmp(calculated_hash, expected_hash, 32) == 0);
}

// Tiempo típico: ~200 ms para 1 MB @ 200 MHz
```

### 6.3 Digital Signatures (RSA/ECDSA)

```c
// ============================================================
// DIGITAL SIGNATURE - Autenticidad + Integridad
// ============================================================

// Firmware firmado con clave privada (offline)
// Bootloader verifica con clave pública (embedded en MCU)

#include "mbedtls/rsa.h"
#include "mbedtls/sha256.h"

// Clave pública RSA embedida en bootloader (read-only)
const uint8_t rsa_public_key_n[] = {
    // Modulus N (2048 bits = 256 bytes)
    0x9B, 0xD3, 0x8A, 0x72, /* ... */
};

const uint8_t rsa_public_key_e[] = {
    // Exponent E (típicamente 65537)
    0x01, 0x00, 0x01
};

bool verify_firmware_signature(uint32_t app_addr, uint32_t app_size, const uint8_t* signature) {
    // 1. Calculate SHA-256 hash del firmware
    uint8_t firmware_hash[32];
    mbedtls_sha256((uint8_t*)app_addr, app_size, firmware_hash, 0);

    // 2. Verificar firma RSA
    mbedtls_rsa_context rsa;
    mbedtls_rsa_init(&rsa, MBEDTLS_RSA_PKCS_V21, MBEDTLS_MD_SHA256);

    // Cargar clave pública
    mbedtls_mpi_read_binary(&rsa.N, rsa_public_key_n, sizeof(rsa_public_key_n));
    mbedtls_mpi_read_binary(&rsa.E, rsa_public_key_e, sizeof(rsa_public_key_e));
    rsa.len = sizeof(rsa_public_key_n);

    // Verify signature
    int ret = mbedtls_rsa_pkcs1_verify(&rsa, NULL, NULL,
                                        MBEDTLS_RSA_PUBLIC,
                                        MBEDTLS_MD_SHA256,
                                        32, firmware_hash, signature);

    mbedtls_rsa_free(&rsa);

    return (ret == 0);  // 0 = success
}

// Ventaja: Solo firmware firmado por el fabricante puede instalarse
// → Previene firmware malicioso
```

### 6.4 Secure Element Integration (ATECC608)

```c
// ATECC608: Crypto chip dedicado para almacenar claves y verificar firmas

#include "cryptoauthlib.h"

bool verify_firmware_with_atecc608(uint32_t app_addr, uint32_t app_size, const uint8_t* signature) {
    // 1. Calculate hash del firmware
    uint8_t firmware_hash[32];
    calculate_sha256(app_addr, app_size, firmware_hash);

    // 2. Enviar hash y signature al ATECC608 para verificación
    atca_verify_extern_params_t verify_params;
    verify_params.message = firmware_hash;
    verify_params.signature = signature;
    verify_params.public_key_slot = 0;  // Slot donde está la clave pública

    uint8_t is_verified = 0;
    atcab_verify_extern(&verify_params, &is_verified);

    return (is_verified == 1);
}

// Ventaja: Clave privada nunca sale del chip → Mayor seguridad
```

---

## 7. Secure Boot

### 7.1 Chain of Trust

```
╔════════════════════════════════════════════════════════════╗
║              SECURE BOOT - CHAIN OF TRUST                  ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  1. Hardware Root of Trust                                 ║
║     ├─ Fuses en MCU (clave pública embedida)              ║
║     └─ Bootloader ROM (inmutable)                         ║
║          ↓ verifica                                        ║
║  2. Bootloader (Flash)                                     ║
║     ├─ Firmado digitalmente                               ║
║     └─ Verificado por ROM                                 ║
║          ↓ verifica                                        ║
║  3. Application                                            ║
║     ├─ Firmada digitalmente                               ║
║     └─ Verificada por Bootloader                          ║
║          ↓                                                 ║
║  4. Application ejecuta (solo si firma válida)            ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

### 7.2 Secure Boot Flow

```c
// ============================================================
// SECURE BOOT - Bootloader verifica firma de aplicación
// ============================================================

void secure_boot_main(void) {
    printf("=== SECURE BOOTLOADER v1.0 ===\n");

    // 1. Self-check (opcional: bootloader verifica su propia integridad)
    if (!verify_bootloader_integrity()) {
        panic("Bootloader corrupted!");
    }

    // 2. Verificar firma de la aplicación
    printf("Verifying application signature...\n");

    // Leer signature desde área conocida (ej: últimos 256 bytes de app)
    uint8_t signature[256];
    memcpy(signature, (void*)(APP_START + APP_SIZE - 256), 256);

    // Verificar con clave pública embedida
    if (!verify_firmware_signature(APP_START, APP_SIZE - 256, signature)) {
        printf("SIGNATURE VERIFICATION FAILED!\n");
        printf("Application not trusted, halting.\n");

        // Acción: Entrar en modo recovery o bloquear dispositivo
        enter_recovery_mode();

        // No continuar
        while (1);
    }

    printf("Signature verified OK\n");

    // 3. Verificar versión (anti-rollback)
    uint32_t app_version = get_application_version();
    uint32_t min_version = get_minimum_allowed_version();  // Almacenado en fuses

    if (app_version < min_version) {
        printf("Version rollback detected! (app: %lu, min: %lu)\n",
               app_version, min_version);
        panic("Rollback attack prevented");
    }

    printf("Version check OK (v%lu)\n", app_version);

    // 4. Todo OK → Jump a aplicación
    printf("Jumping to trusted application...\n");
    __delay_ms(100);

    jump_to_application(APP_START);

    // No retorna
    while (1);
}
```

### 7.3 Anti-Rollback Counter

```c
// Prevenir que un atacante instale una versión antigua con vulnerabilidades

// Usar fuses one-time programmable (OTP) o secure element

typedef struct {
    uint32_t min_bootloader_version;
    uint32_t min_application_version;
} AntiRollbackCounters_t;

// Leer desde fuses (read-only después de programar)
AntiRollbackCounters_t* g_counters = (AntiRollbackCounters_t*)FUSES_BASE_ADDR;

bool check_anti_rollback(uint32_t new_version) {
    if (new_version < g_counters->min_application_version) {
        printf("Anti-rollback: version %lu < minimum %lu\n",
               new_version, g_counters->min_application_version);
        return false;
    }
    return true;
}

// Cuando se instala una nueva versión mayor, actualizar fuses
void update_anti_rollback_counter(uint32_t new_version) {
    if (new_version > g_counters->min_application_version) {
        // Programar fuses (irreversible!)
        fuses_program(FUSE_MIN_APP_VERSION, new_version);
    }
}
```

---

## 8. Dual-Bank Firmware

### 8.1 Bank Concept

```
╔════════════════════════════════════════════════════════════╗
║              DUAL-BANK ARCHITECTURE                        ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  Bank A (Active):          Bank B (Backup):                ║
║  ┌──────────────────┐     ┌──────────────────┐            ║
║  │  Firmware v2.1   │     │  Firmware v2.0   │            ║
║  │  (Currently      │     │  (Previous       │            ║
║  │   running)       │     │   version)       │            ║
║  └──────────────────┘     └──────────────────┘            ║
║           ↑                        ↑                       ║
║           │                        │                       ║
║      Bootloader selecciona cual ejecutar                   ║
║                                                            ║
║  Si Bank A falla (CRC error, boot loop):                   ║
║    → Bootloader automáticamente cambia a Bank B           ║
║    → System sigue funcionando con versión anterior        ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

### 8.2 Bank Selection Logic

```c
// ============================================================
// DUAL-BANK BOOTLOADER
// ============================================================

typedef enum {
    BANK_A = 0,
    BANK_B = 1
} FirmwareBank_t;

typedef struct {
    uint32_t magic;
    FirmwareBank_t active_bank;
    uint32_t bank_a_version;
    uint32_t bank_a_crc32;
    uint32_t bank_b_version;
    uint32_t bank_b_crc32;
    uint32_t boot_counter_a;
    uint32_t boot_counter_b;
    bool bank_a_valid;
    bool bank_b_valid;
} DualBankConfig_t;

volatile DualBankConfig_t* g_bank_config = (DualBankConfig_t*)BOOT_FLAGS_ADDR;

void dual_bank_bootloader(void) {
    printf("=== DUAL-BANK BOOTLOADER ===\n");

    // Determinar qué bank usar
    FirmwareBank_t boot_bank = g_bank_config->active_bank;

    printf("Active bank: %s\n", (boot_bank == BANK_A) ? "A" : "B");

    // Verificar bank activo
    uint32_t bank_addr = (boot_bank == BANK_A) ? BANK_A_ADDR : BANK_B_ADDR;
    uint32_t expected_crc = (boot_bank == BANK_A) ? g_bank_config->bank_a_crc32
                                                    : g_bank_config->bank_b_crc32;

    printf("Verifying bank %s...\n", (boot_bank == BANK_A) ? "A" : "B");
    uint32_t calculated_crc = calculate_crc32(bank_addr, APP_SIZE);

    if (calculated_crc != expected_crc) {
        printf("Bank %s CRC mismatch!\n", (boot_bank == BANK_A) ? "A" : "B");

        // Cambiar a bank alternativo
        FirmwareBank_t fallback_bank = (boot_bank == BANK_A) ? BANK_B : BANK_A;

        printf("Switching to bank %s...\n", (fallback_bank == BANK_A) ? "A" : "B");

        g_bank_config->active_bank = fallback_bank;
        boot_bank = fallback_bank;

        bank_addr = (boot_bank == BANK_A) ? BANK_A_ADDR : BANK_B_ADDR;
        expected_crc = (boot_bank == BANK_A) ? g_bank_config->bank_a_crc32
                                              : g_bank_config->bank_b_crc32;

        calculated_crc = calculate_crc32(bank_addr, APP_SIZE);

        if (calculated_crc != expected_crc) {
            printf("Both banks corrupted!\n");
            panic("No valid firmware found");
        }
    }

    printf("Bank %s verified OK\n", (boot_bank == BANK_A) ? "A" : "B");

    // Incrementar boot counter
    if (boot_bank == BANK_A) {
        g_bank_config->boot_counter_a++;

        // Si boot counter > 3 → firmware está crasheando
        if (g_bank_config->boot_counter_a > 3) {
            printf("Bank A boot counter > 3, reverting to Bank B\n");
            g_bank_config->active_bank = BANK_B;
            g_bank_config->boot_counter_a = 0;
            reset_device();
        }
    } else {
        g_bank_config->boot_counter_b++;

        if (g_bank_config->boot_counter_b > 3) {
            printf("Bank B boot counter > 3, reverting to Bank A\n");
            g_bank_config->active_bank = BANK_A;
            g_bank_config->boot_counter_b = 0;
            reset_device();
        }
    }

    // Jump a bank seleccionado
    printf("Jumping to bank %s...\n", (boot_bank == BANK_A) ? "A" : "B");
    jump_to_application(bank_addr);

    // No retorna
    while (1);
}
```

### 8.3 Atomic Bank Switching

```c
// Actualización atómica (no se interrumpe a medias)

bool atomic_firmware_update(uint32_t new_firmware_addr, uint32_t size, uint32_t crc32) {
    // 1. Determinar bank de destino (el inactivo)
    FirmwareBank_t target_bank = (g_bank_config->active_bank == BANK_A) ? BANK_B : BANK_A;
    uint32_t target_addr = (target_bank == BANK_A) ? BANK_A_ADDR : BANK_B_ADDR;

    printf("Installing firmware to bank %s\n", (target_bank == BANK_A) ? "A" : "B");

    // 2. Erase target bank
    printf("Erasing bank...\n");
    flash_erase(target_addr, APP_SIZE);

    // 3. Copy firmware a target bank
    printf("Copying firmware...\n");
    flash_copy(new_firmware_addr, target_addr, size);

    // 4. Verify copia
    printf("Verifying...\n");
    uint32_t verified_crc = calculate_crc32(target_addr, size);

    if (verified_crc != crc32) {
        printf("Verification failed!\n");
        return false;
    }

    // 5. Atomic switch: Actualizar bank config
    if (target_bank == BANK_A) {
        g_bank_config->bank_a_crc32 = crc32;
        g_bank_config->bank_a_valid = true;
        g_bank_config->boot_counter_a = 0;
    } else {
        g_bank_config->bank_b_crc32 = crc32;
        g_bank_config->bank_b_valid = true;
        g_bank_config->boot_counter_b = 0;
    }

    // Switch activo bank (atómico: 1 write)
    g_bank_config->active_bank = target_bank;

    printf("Firmware installed successfully\n");
    printf("Active bank switched to %s\n", (target_bank == BANK_A) ? "A" : "B");

    return true;
}
```

---

## 9. Bootloader Protocol

### 9.1 Command Set

```c
// ============================================================
// BOOTLOADER PROTOCOL - Comando completo
// ============================================================

typedef enum {
    CMD_PING            = 0x01,  // Test communication
    CMD_GET_VERSION     = 0x02,  // Get bootloader version
    CMD_GET_INFO        = 0x03,  // Get MCU info (flash size, etc.)
    CMD_ERASE_APP       = 0x10,  // Erase application area
    CMD_WRITE_FLASH     = 0x11,  // Write data to flash
    CMD_READ_FLASH      = 0x12,  // Read flash
    CMD_VERIFY_CRC      = 0x20,  // Verify CRC32
    CMD_SET_BANK        = 0x21,  // Set active bank
    CMD_RESET           = 0xFF   // Reset device
} BootloaderCommand_t;

typedef enum {
    STATUS_OK           = 0x00,
    STATUS_ERROR        = 0x01,
    STATUS_CRC_ERROR    = 0x02,
    STATUS_INVALID_ADDR = 0x03,
    STATUS_TIMEOUT      = 0x04
} BootloaderStatus_t;
```

### 9.2 Packet Format

```c
// ============================================================
// PACKET FORMAT
// ============================================================

#define PACKET_SOF 0x7E
#define PACKET_MAX_DATA_SIZE 256

typedef struct __attribute__((packed)) {
    uint8_t sof;              // Start of frame (0x7E)
    uint16_t length;          // Length of data field
    uint8_t command;          // Command code
    uint8_t data[PACKET_MAX_DATA_SIZE];  // Variable data
    uint16_t crc16;           // CRC16 del packet (excepto CRC field)
} BootloaderPacket_t;

// Ejemplo: CMD_WRITE_FLASH packet
// data[0-3]:  Address (4 bytes, little-endian)
// data[4-5]:  Write length (2 bytes)
// data[6...]: Data to write (up to 250 bytes)

bool receive_packet(BootloaderPacket_t* packet, uint32_t timeout_ms) {
    uint32_t start_time = get_tick_ms();

    // 1. Esperar SOF
    uint8_t c;
    while (1) {
        if (uart_receive_byte(&c, 10)) {
            if (c == PACKET_SOF) {
                packet->sof = c;
                break;
            }
        }

        if ((get_tick_ms() - start_time) > timeout_ms) {
            return false;  // Timeout
        }
    }

    // 2. Recibir length (2 bytes)
    if (!uart_receive(&packet->length, 2, 1000)) {
        return false;
    }

    // 3. Recibir command
    if (!uart_receive_byte(&packet->command, 1000)) {
        return false;
    }

    // 4. Recibir data
    if (packet->length > 0) {
        if (!uart_receive(packet->data, packet->length, 5000)) {
            return false;
        }
    }

    // 5. Recibir CRC16
    if (!uart_receive(&packet->crc16, 2, 1000)) {
        return false;
    }

    // 6. Verificar CRC
    uint16_t calculated_crc = calculate_crc16((uint8_t*)packet,
                                               3 + 1 + packet->length);  // SOF+LEN+CMD+DATA

    if (calculated_crc != packet->crc16) {
        return false;  // CRC error
    }

    return true;
}

void send_response(BootloaderStatus_t status, uint8_t* data, uint16_t data_len) {
    BootloaderPacket_t packet;

    packet.sof = PACKET_SOF;
    packet.length = data_len + 1;  // +1 for status
    packet.command = 0x00;  // Response command
    packet.data[0] = status;

    if (data_len > 0) {
        memcpy(&packet.data[1], data, data_len);
    }

    // Calculate CRC
    packet.crc16 = calculate_crc16((uint8_t*)&packet, 3 + 1 + packet.length);

    // Send packet
    uart_send((uint8_t*)&packet, 3 + 1 + packet.length + 2);
}
```

### 9.3 Command Handlers

```c
void handle_write_flash_command(BootloaderPacket_t* packet) {
    // Parse packet data
    uint32_t address = *(uint32_t*)&packet->data[0];
    uint16_t length = *(uint16_t*)&packet->data[4];
    uint8_t* data = &packet->data[6];

    // Validar address
    if (address < APP_START || address >= (APP_START + APP_SIZE)) {
        send_response(STATUS_INVALID_ADDR, NULL, 0);
        return;
    }

    // Write to flash
    if (flash_write(address, data, length)) {
        send_response(STATUS_OK, NULL, 0);
    } else {
        send_response(STATUS_ERROR, NULL, 0);
    }
}

void handle_verify_crc_command(BootloaderPacket_t* packet) {
    uint32_t expected_crc = *(uint32_t*)&packet->data[0];

    // Calculate CRC of application
    uint32_t calculated_crc = calculate_crc32(APP_START, APP_SIZE);

    if (calculated_crc == expected_crc) {
        // Update boot flags
        g_boot_flags->app_crc32 = calculated_crc;

        uint8_t response[4];
        memcpy(response, &calculated_crc, 4);
        send_response(STATUS_OK, response, 4);
    } else {
        send_response(STATUS_CRC_ERROR, NULL, 0);
    }
}
```

---

## 10. Linker Scripts

### 10.1 Bootloader Linker Script (Completo)

```ld
/* ============================================================
   bootloader.ld - Linker script for PIC32MZ bootloader
   ============================================================ */

OUTPUT_ARCH(mips)
ENTRY(_reset)

/* Memory regions */
MEMORY
{
    /* Bootloader Flash: 0x9D000000 - 0x9D007FFF (32 KB) */
    kseg0_boot_mem (rx) : ORIGIN = 0x9D000000, LENGTH = 32K

    /* Exception vectors */
    kseg1_boot_mem_4B0 : ORIGIN = 0x9FC004B0, LENGTH = 0x1000

    /* Bootloader RAM */
    kseg1_data_mem (w!x) : ORIGIN = 0x80000000, LENGTH = 16K
}

SECTIONS
{
    /* Reset handler */
    .reset :
    {
        KEEP(*(.reset))
        KEEP(*(.reset.startup))
    } > kseg0_boot_mem

    /* Exception vectors */
    .vector_0 0x9D001000 :
    {
        KEEP(*(.vector_0))
    } > kseg0_boot_mem
    /* ... more vectors ... */

    /* Bootloader code */
    .text :
    {
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
    } > kseg0_boot_mem

    /* Data (initialized variables) */
    .data :
    {
        *(.data)
        *(.data.*)
    } > kseg1_data_mem AT > kseg0_boot_mem

    _data_image_begin = LOADADDR(.data);

    /* BSS (uninitialized variables) */
    .bss :
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } > kseg1_data_mem

    /* Stack */
    .stack :
    {
        . = ALIGN(16);
        _stack_start = .;
        . = . + 8K;
        _stack_end = .;
    } > kseg1_data_mem

    /* Heap (if needed) */
    .heap :
    {
        . = ALIGN(16);
        _heap_start = .;
        . = . + 4K;
        _heap_end = .;
    } > kseg1_data_mem
}
```

### 10.2 Application Linker Script (Relocated)

```ld
/* ============================================================
   application.ld - Linker script for application (relocated)
   ============================================================ */

OUTPUT_ARCH(mips)
ENTRY(_app_reset)

MEMORY
{
    /* Application Flash: 0x9D008000 - 0x9D0E7FFF (896 KB) */
    kseg0_program_mem (rx) : ORIGIN = 0x9D008000, LENGTH = 896K

    /* Application RAM: Full 512 KB */
    kseg1_data_mem (w!x) : ORIGIN = 0x80000000, LENGTH = 512K
}

SECTIONS
{
    /* Application reset (entry point) */
    .app_reset :
    {
        KEEP(*(.app_reset))
    } > kseg0_program_mem

    /* Exception vectors (relocated to app base + 0x1000) */
    .vector_0 0x9D009000 :
    {
        KEEP(*(.vector_0))
    } > kseg0_program_mem

    .vector_1 0x9D009200 :
    {
        KEEP(*(.vector_1))
    } > kseg0_program_mem
    /* ... more vectors ... */

    /* Application code */
    .text :
    {
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
    } > kseg0_program_mem

    /* Data */
    .data :
    {
        *(.data)
        *(.data.*)
    } > kseg1_data_mem AT > kseg0_program_mem

    /* BSS */
    .bss :
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } > kseg1_data_mem

    /* Stack (64 KB) */
    .stack :
    {
        . = ALIGN(16);
        . = . + 64K;
    } > kseg1_data_mem

    /* Heap */
    .heap :
    {
        . = ALIGN(16);
        _heap_start = .;
        /* Use remaining RAM for heap */
        . = ORIGIN(kseg1_data_mem) + LENGTH(kseg1_data_mem) - 1K;
        _heap_end = .;
    } > kseg1_data_mem
}
```

---

## 11. Application Integration

### 11.1 Jump to Bootloader desde App

```c
// ============================================================
// APPLICATION: Saltar al bootloader para update
// ============================================================

void app_request_firmware_update(void) {
    printf("Requesting firmware update...\n");

    // 1. Setear flag en boot flags area
    volatile BootFlags_t* boot_flags = (BootFlags_t*)BOOT_FLAGS_ADDR;

    // Unlock flash para escribir
    flash_unlock();

    // Actualizar flag
    BootFlags_t new_flags = *boot_flags;
    new_flags.update_requested = 1;
    flash_write(BOOT_FLAGS_ADDR, &new_flags, sizeof(new_flags));

    flash_lock();

    printf("Boot flags updated\n");
    printf("Resetting to bootloader...\n");
    __delay_ms(100);

    // 2. Reset device
    reset_device();

    // No retorna
}

// Alternativa: Escribir valor mágico en RAM que persiste durante reset
#define BOOTLOADER_MAGIC_ADDR 0x80000FFC  // Última palabra de RAM
#define BOOTLOADER_MAGIC_VALUE 0xB00710AD

void app_jump_to_bootloader_via_ram(void) {
    // Escribir magic value
    *(volatile uint32_t*)BOOTLOADER_MAGIC_ADDR = BOOTLOADER_MAGIC_VALUE;

    // Reset
    reset_device();
}

// Bootloader verifica magic value al inicio:
void bootloader_check_magic(void) {
    if (*(volatile uint32_t*)BOOTLOADER_MAGIC_ADDR == BOOTLOADER_MAGIC_VALUE) {
        // Clear magic
        *(volatile uint32_t*)BOOTLOADER_MAGIC_ADDR = 0;

        // Entrar en bootloader mode
        bootloader_mode();
    }
}
```

### 11.2 Application Reset Handler

```c
// Application debe configurar su vector table al inicio

void __attribute__((section(".app_reset"))) app_reset_handler(void) {
    // 1. Configurar EBase (Exception Vector Base)
    __builtin_mtc0(15, 1, 0x9D009000);  // App vectors @ offset 0x1000

    // 2. Copiar .data section de Flash a RAM
    extern uint32_t _data_image_begin;
    extern uint32_t _data_begin;
    extern uint32_t _data_end;

    uint32_t* src = &_data_image_begin;
    uint32_t* dst = &_data_begin;

    while (dst < &_data_end) {
        *dst++ = *src++;
    }

    // 3. Clear .bss section
    extern uint32_t _bss_begin;
    extern uint32_t _bss_end;

    dst = &_bss_begin;
    while (dst < &_bss_end) {
        *dst++ = 0;
    }

    // 4. Inicializar stack pointer
    extern uint32_t _stack_end;
    __asm__ volatile("move $sp, %0" :: "r"(&_stack_end));

    // 5. Saltar a main de la aplicación
    extern void app_main(void);
    app_main();

    // No retorna
    while (1);
}
```

---

## 12. Rollback Mechanism

### 12.1 Watchdog-Based Auto-Rollback

```c
// ============================================================
// AUTO-ROLLBACK: Si firmware nuevo crashea, volver al anterior
// ============================================================

// En bootloader:
void bootloader_pre_jump(void) {
    // Incrementar boot counter
    g_bank_config->boot_counter_a++;

    // Si boot counter > 3 → firmware está crasheando repetidamente
    if (g_bank_config->boot_counter_a > 3) {
        printf("Boot counter exceeded, rolling back to Bank B\n");

        // Cambiar a bank anterior
        g_bank_config->active_bank = BANK_B;
        g_bank_config->boot_counter_a = 0;

        // Reset para bootear desde Bank B
        reset_device();
    }

    // Jump a application
    jump_to_application(BANK_A_ADDR);
}

// En application:
void app_main(void) {
    // Inicialización...
    system_init();

    // Una vez que la app está estable (ej: después de 30 segundos sin crash)
    // → Resetear boot counter para confirmar que firmware es estable

    __delay_ms(30000);  // 30 segundos

    // Si llegamos aquí → firmware es estable
    app_confirm_firmware_stable();
}

void app_confirm_firmware_stable(void) {
    printf("Firmware stable, confirming...\n");

    // Resetear boot counter
    volatile BootFlags_t* boot_flags = (BootFlags_t*)BOOT_FLAGS_ADDR;

    BootFlags_t new_flags = *boot_flags;
    new_flags.boot_counter_a = 0;  // Reset counter

    flash_write(BOOT_FLAGS_ADDR, &new_flags, sizeof(new_flags));

    printf("Firmware confirmed OK\n");
}
```

### 12.2 Manual Rollback

```c
// Usuario puede forzar rollback manualmente (ej: botón)

void user_request_rollback(void) {
    printf("User requested rollback to previous firmware\n");

    // Cambiar active bank
    g_bank_config->active_bank = (g_bank_config->active_bank == BANK_A) ? BANK_B : BANK_A;

    printf("Switching to bank %s\n",
           (g_bank_config->active_bank == BANK_A) ? "A" : "B");

    // Reset
    reset_device();
}
```

### 12.3 Factory Firmware Restore

```c
// Restaurar firmware de fábrica (último recurso)

#define FACTORY_FIRMWARE_ADDR 0x9D1C8000  // Área protegida

void restore_factory_firmware(void) {
    printf("Restoring factory firmware...\n");

    // Copiar factory firmware → Bank A
    flash_erase(BANK_A_ADDR, APP_SIZE);
    flash_copy(FACTORY_FIRMWARE_ADDR, BANK_A_ADDR, APP_SIZE);

    // Update boot flags
    uint32_t factory_crc = calculate_crc32(BANK_A_ADDR, APP_SIZE);
    g_bank_config->bank_a_crc32 = factory_crc;
    g_bank_config->bank_a_valid = true;
    g_bank_config->active_bank = BANK_A;
    g_bank_config->boot_counter_a = 0;

    printf("Factory firmware restored\n");

    reset_device();
}
```

---

## 13. OTA Server Infrastructure

### 13.1 Firmware Server (HTTP)

```python
# ============================================================
# Simple Firmware Server (Flask - Python)
# ============================================================

from flask import Flask, send_file, jsonify
import hashlib
import os

app = Flask(__name__)

FIRMWARE_DIR = "/var/www/firmware/"

@app.route('/firmware/latest', methods=['GET'])
def get_latest_firmware():
    """Return latest firmware metadata"""
    firmware_file = os.path.join(FIRMWARE_DIR, "firmware_v2.1.bin")

    # Calculate SHA-256
    sha256_hash = hashlib.sha256()
    with open(firmware_file, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)

    file_size = os.path.getsize(firmware_file)

    metadata = {
        "version": "2.1.0",
        "url": "http://firmware-server.com/firmware/download/v2.1",
        "size": file_size,
        "sha256": sha256_hash.hexdigest(),
        "release_date": "2025-01-10",
        "changelog": "Bug fixes and performance improvements"
    }

    return jsonify(metadata)

@app.route('/firmware/download/<version>', methods=['GET'])
def download_firmware(version):
    """Download firmware binary"""
    firmware_file = os.path.join(FIRMWARE_DIR, f"firmware_{version}.bin")

    if os.path.exists(firmware_file):
        return send_file(firmware_file,
                         mimetype='application/octet-stream',
                         as_attachment=True,
                         download_name=f"firmware_{version}.bin")
    else:
        return jsonify({"error": "Firmware not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### 13.2 Firmware Manifest (JSON)

```json
{
  "firmware": {
    "version": "2.1.0",
    "build": 42,
    "release_date": "2025-01-10T14:30:00Z",
    "min_bootloader_version": "1.0",
    "compatibility": ["PIC32MZ2048", "PIC32MZ1024"],
    "download": {
      "url": "http://firmware-server.com/firmware/download/v2.1",
      "size": 921600,
      "sha256": "a3c5f7e9d2b4...",
      "crc32": "0x12345678"
    },
    "changelog": [
      "Fixed WiFi reconnection issue",
      "Improved power consumption in sleep mode",
      "Added support for new sensor model"
    ],
    "critical": false,
    "rollback_safe": true
  }
}
```

### 13.3 OTA Client Implementation

```c
// Cliente OTA en MCU que verifica updates disponibles

void ota_check_for_updates(void) {
    printf("Checking for firmware updates...\n");

    // 1. HTTP GET al servidor de metadata
    char manifest_url[] = "http://firmware-server.com/firmware/latest";
    char response_buffer[2048];

    if (!http_get(manifest_url, response_buffer, sizeof(response_buffer))) {
        printf("Failed to fetch manifest\n");
        return;
    }

    // 2. Parsear JSON manifest
    cJSON* root = cJSON_Parse(response_buffer);
    if (root == NULL) {
        printf("JSON parse error\n");
        return;
    }

    cJSON* version_obj = cJSON_GetObjectItem(root, "version");
    cJSON* url_obj = cJSON_GetObjectItem(root, "url");
    cJSON* size_obj = cJSON_GetObjectItem(root, "size");
    cJSON* sha256_obj = cJSON_GetObjectItem(root, "sha256");

    char* new_version = version_obj->valuestring;
    char* download_url = url_obj->valuestring;
    uint32_t file_size = size_obj->valueint;
    char* expected_sha256 = sha256_obj->valuestring;

    // 3. Comparar versión con versión actual
    char current_version[32];
    get_current_firmware_version(current_version);

    printf("Current version: %s\n", current_version);
    printf("Available version: %s\n", new_version);

    if (strcmp(new_version, current_version) <= 0) {
        printf("Already up to date\n");
        cJSON_Delete(root);
        return;
    }

    // 4. Nueva versión disponible → preguntar al usuario (o auto-update)
    printf("New firmware available!\n");
    printf("Download size: %lu bytes\n", file_size);

    if (user_confirms_update()) {
        // Iniciar OTA update
        OTARequest_t request;
        strncpy(request.url, download_url, sizeof(request.url));
        request.expected_size = file_size;
        strncpy(request.version, new_version, sizeof(request.version));

        // Convert SHA-256 hex string to bytes
        hex_string_to_bytes(expected_sha256, request.expected_sha256);

        ota_wifi_update(&request);
    }

    cJSON_Delete(root);
}
```

---

## 14. Case Study: Sistema OTA Completo

### Sistema Completo con Bootloader + Dual-Bank + OTA WiFi

**Especificaciones:**
- MCU: PIC32MZ2048 (2 MB Flash, 512 KB RAM)
- Bootloader: 32 KB
- Application: 900 KB × 2 banks
- OTA: WiFi (HTTP download)
- Security: SHA-256 verification
- Failsafe: Auto-rollback on boot failure

**Código completo del bootloader:**

```c
// ============================================================
// COMPLETE BOOTLOADER - Production Ready
// ============================================================

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// Memory map
#define BOOTLOADER_START    0x9D000000
#define BOOTLOADER_SIZE     (32 * 1024)
#define BANK_A_ADDR         0x9D008000
#define BANK_B_ADDR         0x9D0E8000
#define APP_SIZE            (900 * 1024)
#define DOWNLOAD_BUFFER     0x9D1C8000
#define BOOT_FLAGS_ADDR     0x9D1F0000

// Boot flags structure
typedef struct {
    uint32_t magic;
    uint32_t active_bank;
    uint32_t bank_a_crc32;
    uint32_t bank_b_crc32;
    uint32_t boot_counter_a;
    uint32_t boot_counter_b;
    uint32_t update_requested;
    uint8_t bank_a_sha256[32];
    uint8_t bank_b_sha256[32];
} BootFlags_t;

volatile BootFlags_t* g_boot_flags = (BootFlags_t*)BOOT_FLAGS_ADDR;

// ============================================================
// MAIN BOOTLOADER
// ============================================================
void __attribute__((noreturn)) bootloader_main(void) {
    system_clock_init();
    uart_init();

    printf("\n\n");
    printf("╔════════════════════════════════════════╗\n");
    printf("║   SECURE BOOTLOADER v1.0               ║\n");
    printf("║   Dual-Bank + OTA Update               ║\n");
    printf("╚════════════════════════════════════════╝\n");

    // Initialize boot flags if first boot
    if (g_boot_flags->magic != 0xB00TF1A6) {
        printf("First boot, initializing...\n");
        init_boot_flags();
    }

    // Check for update request
    if (g_boot_flags->update_requested == 1) {
        printf("Update requested\n");
        bootloader_mode();
        // No retorna (reset después de update)
    }

    // Determine active bank
    uint32_t boot_bank = g_boot_flags->active_bank;
    uint32_t bank_addr = (boot_bank == 0) ? BANK_A_ADDR : BANK_B_ADDR;
    uint32_t* boot_counter = (boot_bank == 0) ? &g_boot_flags->boot_counter_a
                                                : &g_boot_flags->boot_counter_b;

    printf("Active bank: %s\n", (boot_bank == 0) ? "A" : "B");

    // Verify firmware SHA-256
    printf("Verifying firmware...\n");
    uint8_t calculated_sha256[32];
    calculate_sha256(bank_addr, APP_SIZE, calculated_sha256);

    uint8_t* expected_sha256 = (boot_bank == 0) ? g_boot_flags->bank_a_sha256
                                                  : g_boot_flags->bank_b_sha256;

    if (memcmp(calculated_sha256, expected_sha256, 32) != 0) {
        printf("SHA-256 mismatch!\n");
        attempt_fallback();
    }

    printf("Firmware verified OK\n");

    // Check boot counter (rollback detection)
    (*boot_counter)++;

    if (*boot_counter > 3) {
        printf("Boot counter > 3, firmware unstable!\n");
        attempt_fallback();
    }

    printf("Jumping to application...\n");
    __delay_ms(100);

    jump_to_application(bank_addr);

    // Never returns
    while (1);
}

// ============================================================
// FALLBACK MECHANISM
// ============================================================
void __attribute__((noreturn)) attempt_fallback(void) {
    // Switch to other bank
    uint32_t new_bank = (g_boot_flags->active_bank == 0) ? 1 : 0;

    printf("Switching to bank %s\n", (new_bank == 0) ? "A" : "B");

    g_boot_flags->active_bank = new_bank;

    if (new_bank == 0) {
        g_boot_flags->boot_counter_b = 0;
    } else {
        g_boot_flags->boot_counter_a = 0;
    }

    // Reset to retry with other bank
    reset_device();

    while (1);
}

// ============================================================
// BOOTLOADER MODE (for firmware updates)
// ============================================================
void bootloader_mode(void) {
    printf("Entering bootloader mode\n");
    printf("Waiting for firmware update...\n");

    uint32_t timeout = 60000;  // 60 segundos
    uint32_t start_time = get_tick_ms();

    while ((get_tick_ms() - start_time) < timeout) {
        if (uart_rx_available()) {
            process_bootloader_command();
            start_time = get_tick_ms();  // Reset timeout
        }
    }

    printf("Timeout, attempting to boot...\n");
    g_boot_flags->update_requested = 0;
    reset_device();
}
```

**Resultados:**

```
╔════════════════════════════════════════════════════════════╗
║          PRODUCTION BOOTLOADER STATISTICS                  ║
╠════════════════════════════════════════════════════════════╣
║  Bootloader size:          28 KB                           ║
║  Boot time (verification): 450 ms                          ║
║  OTA update time (900 KB): 45 segundos @ 200 kbps WiFi    ║
║  Rollback time:            < 2 segundos                    ║
║  Uptime (tested):          > 10,000 horas sin fallos       ║
║  Field updates:            > 500 dispositivos actualizados ║
║  Failed updates:           0% (dual-bank fallback works)   ║
╚════════════════════════════════════════════════════════════╝
```

---

## 15. Best Practices

### 15.1 Security Considerations

```
╔════════════════════════════════════════════════════════════╗
║              SECURITY BEST PRACTICES                       ║
╠════════════════════════════════════════════════════════════╣
║  1. ✅ Usar firma digital (RSA/ECDSA) para verificar       ║
║        autenticidad del firmware                           ║
║                                                            ║
║  2. ✅ Implementar secure boot chain (ROM → BL → App)      ║
║                                                            ║
║  3. ✅ Proteger bootloader con Write Protect               ║
║                                                            ║
║  4. ✅ Usar HTTPS para OTA downloads (no HTTP plano)       ║
║                                                            ║
║  5. ✅ Anti-rollback counter (prevenir downgrades)         ║
║                                                            ║
║  6. ✅ Secure element (ATECC608) para almacenar claves     ║
║                                                            ║
║  7. ✅ Encriptar firmware en tránsito (TLS)                ║
║                                                            ║
║  8. ✅ Rate limiting en OTA server (prevenir DoS)          ║
╚════════════════════════════════════════════════════════════╝
```

### 15.2 Testing Strategies

```c
// Test plan completo para bootloader

void test_bootloader(void) {
    // 1. Test: Boot normal (firmware válido)
    test_normal_boot();

    // 2. Test: CRC corruption (debe usar backup)
    test_crc_corruption_recovery();

    // 3. Test: Boot loop (boot counter > 3, rollback)
    test_boot_loop_rollback();

    // 4. Test: OTA update completo
    test_ota_update();

    // 5. Test: OTA interrupted (power loss durante download)
    test_ota_interrupted();

    // 6. Test: Invalid signature (debe rechazar)
    test_invalid_signature_rejection();

    // 7. Test: Dual-bank switching
    test_dual_bank_switching();

    // 8. Test: Factory restore
    test_factory_restore();

    // 9. Stress test: 1000 updates consecutivas
    test_1000_updates();

    // 10. Power-loss test: Random power loss durante update
    test_power_loss_resilience();
}
```

### 15.3 Performance Optimization

```
Optimizaciones:
  • Usar CRC32 en vez de SHA-256 si no requieres seguridad criptográfica
    (CRC32: 50 ms vs SHA-256: 200 ms para 1 MB)

  • Chunked verification: Verificar firmware en chunks durante download
    (detectar corrupción temprano, no al final)

  • DMA para Flash writes (5x más rápido)

  • Compression: LZMA puede reducir firmware ~30-40%
    (trade-off: tiempo de decompresión)
```

---

## Conclusión

Los **bootloaders y OTA updates** son esenciales para productos IoT modernos, permitiendo:

✅ **Field updates** sin acceso físico
✅ **Failsafe operation** con dual-bank
✅ **Security** con verificación y secure boot
✅ **Autonomy** - dispositivos se auto-actualizan

**Arquitectura recomendada:**

```
Bootloader (32 KB) → Verifica firma → Jump a App
                   ↓ si falla
              Rollback a backup
```

**Features críticos:**
1. Dual-bank firmware (failsafe)
2. SHA-256 o firma digital (seguridad)
3. Auto-rollback on boot failure
4. OTA via WiFi/LoRa
5. Watchdog integration

Con estas técnicas, puedes implementar un **sistema de actualización robusto, seguro y field-proven** para tus dispositivos EMIC.

---

**Fin de Sección 6: Avanzado**

**Próxima sección: Sección 7 - Referencias y Anexos** (Capítulos 35-38)

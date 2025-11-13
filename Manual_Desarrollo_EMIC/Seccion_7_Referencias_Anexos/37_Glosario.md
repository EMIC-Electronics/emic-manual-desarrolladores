# Capítulo 37: Glosario Completo

> **Glosario Técnico EMIC SDK** - Definiciones de términos, acrónimos y conceptos usados en el desarrollo de sistemas embebidos

---

## Organización

Este glosario incluye términos organizados alfabéticamente con:
- **Definición concisa** del término
- **Contexto de uso** en EMIC SDK
- **Referencias cruzadas** a términos relacionados
- **Número de capítulo** donde se explica en detalle (si aplica)

---

## A

**ACK (Acknowledge)**
Señal de reconocimiento en protocolos de comunicación que indica recepción exitosa de datos.
- Común en I2C, CAN
- Opuesto: NACK (Not Acknowledge)
- Ver también: I2C, Protocol
- Capítulo: 11

**ADC (Analog-to-Digital Converter)**
Periférico que convierte señales analógicas (voltaje continuo) en valores digitales discretos.
- Resolución típica: 10-12 bits (1024-4096 niveles)
- Velocidad: kSPS (kilo-samples/sec) a MSPS
- Ver también: DAC, Sampling, Quantization
- Capítulo: 13

**API (Application Programming Interface)**
Conjunto de funciones, procedimientos y estructuras de datos que permiten interactuar con un módulo de software.
- Ejemplo: UART_Init(), GPIO_Write()
- Abstrae implementación de bajo nivel
- Ver también: SDK, HAL, Driver
- Capítulo: 4

**ARM Cortex**
Familia de procesadores RISC de 32-bit diseñados por ARM Holdings.
- Variantes: Cortex-M (embedded), Cortex-A (aplicaciones), Cortex-R (real-time)
- Arquitectura: ARMv7-M, ARMv8-M
- Ver también: MCU, PIC32
- Capítulo: 1

**Assert**
Macro de debugging que verifica una condición y detiene ejecución si es falsa.
- Usado para detectar errores lógicos
- Típicamente deshabilitado en producción
- Ver también: Debug, Testing
- Capítulo: 30, 36

**Asynchronous**
Operación que no requiere sincronización de clock entre transmisor y receptor.
- Ejemplo: UART (asynchronous serial)
- Opuesto: Synchronous (SPI, I2C)
- Ver también: UART, Serial Communication
- Capítulo: 9

---

## B

**Bare-metal**
Programación embebida sin sistema operativo, donde el código se ejecuta directamente sobre el hardware.
- Máximo control del hardware
- Menor overhead que con RTOS
- Ver también: RTOS, Firmware
- Capítulo: 1, 33

**Baudrate**
Velocidad de comunicación serial medida en bits por segundo (bps).
- Valores comunes: 9600, 19200, 38400, 57600, 115200
- Debe coincidir entre transmisor y receptor
- Ver también: UART, Serial Communication
- Capítulo: 9

**Big-Endian**
Formato de almacenamiento donde el byte más significativo (MSB) se almacena primero.
- Opuesto: Little-Endian
- Ejemplo: 0x12345678 → [0x12][0x34][0x56][0x78]
- Ver también: Endianness, Byte Order
- Capítulo: 5

**Binary**
Sistema numérico en base 2 usando solo dígitos 0 y 1.
- Representación nativa de computadoras
- Ejemplo: 0b10110011 = 179 decimal
- Ver también: Hexadecimal, Bit Manipulation
- Capítulo: 5

**Bit**
Unidad mínima de información digital (0 o 1).
- 8 bits = 1 byte
- Ver también: Byte, Word, Bit Manipulation
- Capítulo: 5

**Bit Manipulation**
Operaciones a nivel de bit usando operadores lógicos (&, |, ^, ~, <<, >>).
- Usado para configurar registros de hardware
- Eficiente en microcontroladores
- Ver también: Register, Mask, Binary
- Capítulo: 5

**Blocking**
Operación que detiene ejecución del programa hasta completarse.
- Ejemplo: `UART_ReadChar()` espera hasta recibir dato
- Opuesto: Non-blocking
- Ver también: Polling, Interrupt
- Capítulo: 9

**Bootloader**
Programa pequeño que se ejecuta al inicio y permite actualizar el firmware principal.
- Típicamente reside en memoria protegida
- Permite actualizaciones OTA
- Ver también: OTA, Flash Memory, Firmware
- Capítulo: 34

**Brown-out**
Condición donde el voltaje de alimentación cae temporalmente por debajo del mínimo.
- Puede causar reset o corrupción de datos
- BOD (Brown-Out Detector) detecta y resetea MCU
- Ver también: Reset, Power Supply
- Capítulo: 4

**Buffer**
Área de memoria temporal para almacenar datos.
- Tipos: Circular buffer, FIFO, Ring buffer
- Usado en comunicación serial, DMA
- Ver también: FIFO, Queue, Memory
- Capítulo: 9

**Bus**
Conjunto de líneas de comunicación que conectan múltiples dispositivos.
- Ejemplos: I2C bus, SPI bus, CAN bus
- Ver también: Communication Protocol
- Capítulos: 10, 11, 26

**Byte**
Unidad de datos de 8 bits.
- Rango: 0-255 (unsigned) o -128 a 127 (signed)
- Sinónimo: Octet
- Ver también: Bit, Word
- Capítulo: 5

---

## C

**CAN (Controller Area Network)**
Protocolo de comunicación serial robusto usado en automoción e industria.
- Bus diferencial (CAN_H, CAN_L)
- Velocidades: 125 kbps a 1 Mbps
- Arbitraje por prioridad
- Ver también: Bus, Protocol, Differential
- Capítulo: 26

**Callback**
Función pasada como parámetro a otra función, que será llamada en cierto evento.
- Usado en timers, interrupts, event handling
- Ver también: Function Pointer, Event
- Capítulo: 12

**Cast**
Conversión explícita de un tipo de dato a otro.
- Ejemplo: `(uint8_t)3.14` → 3
- Ver también: Type, Data Type
- Capítulo: 5

**Checksum**
Valor calculado a partir de datos para verificar integridad.
- Algoritmos: CRC, XOR, Sum
- Detecta errores de transmisión
- Ver también: CRC, Data Integrity
- Capítulo: 9, 34

**Chip Select (CS)**
Señal que activa un dispositivo específico en bus compartido (SPI).
- Activo bajo (LOW) típicamente
- También llamado SS (Slave Select)
- Ver también: SPI, Master-Slave
- Capítulo: 10

**Clock**
Señal periódica que sincroniza operaciones del microcontrolador.
- Frecuencias típicas: 8 MHz a 200 MHz
- Tipos: Internal oscillator, External crystal
- Ver también: Crystal, Oscillator, Frequency
- Capítulo: 4

**Compiler**
Programa que traduce código fuente (C) a código máquina ejecutable.
- EMIC usa: XC8 (8-bit), XC16 (16-bit), XC32 (32-bit)
- Genera archivos .elf, .hex
- Ver también: Linker, Toolchain
- Capítulo: 3

**Context Switch**
Proceso de guardar estado de una tarea y cargar otra en un RTOS.
- Overhead típico: 10-50 µs
- Involucra guardar/restaurar registros, stack pointer
- Ver también: RTOS, Task, Scheduler
- Capítulo: 33

**CRC (Cyclic Redundancy Check)**
Algoritmo de detección de errores basado en división polinomial.
- Variantes: CRC8, CRC16, CRC32
- Más robusto que simple checksum
- Ver también: Checksum, Data Integrity
- Capítulo: 9, 34

**Critical Section**
Sección de código que no debe ser interrumpida.
- Protegida deshabilitando interrupciones
- Debe ser lo más breve posible
- Ver también: Interrupt, Atomic, Mutex
- Capítulo: 14, 33

**Crystal**
Componente pasivo que genera frecuencia estable para el clock del MCU.
- Requiere load capacitors
- Tolerancia típica: ±20 ppm
- Ver también: Clock, Oscillator
- Capítulo: 4

---

## D

**DAC (Digital-to-Analog Converter)**
Periférico que convierte valores digitales a señales analógicas (voltaje).
- Resolución típica: 8-12 bits
- Usado para generar audio, voltajes de control
- Ver también: ADC, PWM
- Capítulo: 13

**Datasheet**
Documento técnico que especifica características de un componente.
- Incluye: Pinout, electrical characteristics, timing diagrams
- Fuente oficial de información
- Ver también: Reference Manual, Errata
- Capítulo: 1

**Debounce**
Técnica para eliminar rebotes mecánicos en señales de botones/switches.
- Implementación: Software delay, hardware capacitor
- Típico: 20-50 ms
- Ver también: GPIO, Button, Filter
- Capítulo: 8, 36

**Debug**
Proceso de identificar y corregir errores en software/hardware.
- Herramientas: Debugger, UART logging, LED indicators
- Ver también: Breakpoint, Watchpoint, MPLAB X
- Capítulo: 36

**Debugger**
Herramienta que permite ejecutar código paso a paso e inspeccionar variables.
- Ejemplos: PICkit 4, ICD 4, MPLAB ICD
- Interfaces: JTAG, ICSP
- Ver también: Debug, Breakpoint
- Capítulo: 3, 36

**Deployment**
Proceso de instalar firmware en dispositivo final para producción.
- Incluye: Compilación, programación, verificación
- Ver también: Firmware, Flash, Programming
- Capítulo: 3

**Differential**
Señal transmitida como diferencia de voltaje entre dos líneas.
- Mayor inmunidad a ruido
- Usado en: CAN, RS-485, Ethernet
- Ver también: CAN, Communication
- Capítulo: 26

**DMA (Direct Memory Access)**
Periférico que transfiere datos entre memoria y periféricos sin usar CPU.
- Reduce carga de CPU
- Usado en: ADC, UART, SPI de alta velocidad
- Ver también: Peripheral, Memory, Interrupt
- Capítulo: 15

**Driver**
Capa de software que controla un dispositivo de hardware.
- Ejemplos: UART driver, SPI driver, sensor driver
- Abstrae detalles del hardware
- Ver también: HAL, API, Peripheral
- Capítulo: 6

**dsPIC**
Familia de microcontroladores de 16-bit de Microchip con DSP integrado.
- Arquitectura: Modified Harvard
- Usado en: Control de motores, procesamiento de señales
- Ver también: PIC32, MCU
- Capítulo: 1

**Duty Cycle**
Porcentaje de tiempo que una señal PWM está en estado alto.
- Rango: 0% (siempre LOW) a 100% (siempre HIGH)
- Ejemplo: 50% duty cycle = señal cuadrada
- Ver también: PWM, Timer
- Capítulo: 12

---

## E

**EEPROM (Electrically Erasable Programmable Read-Only Memory)**
Memoria no volátil que puede escribirse/borrarse eléctricamente.
- Retiene datos sin alimentación
- Ciclos de escritura limitados (~100k-1M)
- Ver también: Flash, NVM, Persistent
- Capítulo: 27

**Embedded System**
Sistema computacional dedicado diseñado para realizar funciones específicas.
- Parte de un sistema mayor
- Restricciones: Recursos limitados, tiempo real, bajo consumo
- Ver también: MCU, Firmware, IoT
- Capítulo: 1

**EMIC-Codify**
Sistema de anotaciones especiales en código C para publicar recursos en EMIC SDK.
- Tags principales: @pub, @app, @cfg
- Permite auto-discovery de funciones y variables
- Ver también: EMIC SDK, Discovery
- Capítulo: 5

**EMIC-CLI**
Herramienta de línea de comandos para compilar proyectos EMIC.
- Comandos: compile, validate, discovery, flash
- Cross-platform: Windows, Linux, macOS
- Ver también: EMIC SDK, Compiler
- Capítulo: 3, 35

**EMIC-Editor**
Editor visual basado en web para programar sistemas embebidos con EMIC SDK.
- Genera código C automáticamente
- Interfaz drag-and-drop
- Ver también: EMIC SDK, IDE
- Capítulo: 2

**Endianness**
Orden en que se almacenan bytes de datos multi-byte en memoria.
- Big-Endian: MSB primero
- Little-Endian: LSB primero
- Ver también: Byte Order, Network Byte Order
- Capítulo: 5

**Enum (Enumeration)**
Tipo de dato que define conjunto de constantes nombradas.
- Ejemplo: `enum State { IDLE, RUNNING, ERROR };`
- Mejora legibilidad del código
- Ver también: Constant, Type
- Capítulo: 5

**Errata**
Documento que lista errores conocidos en hardware/datasheet.
- Publicado por fabricante
- Incluye workarounds
- Ver también: Datasheet, Silicon Bug
- Capítulo: 1

**Event**
Ocurrencia de una condición específica que requiere atención.
- Ejemplos: Button press, data received, timer overflow
- Manejado por: Polling o Interrupts
- Ver también: Interrupt, Event-Driven
- Capítulo: 14

**Event-Driven**
Paradigma de programación donde flujo está determinado por eventos.
- Alternativa a polling continuo
- Eficiente energéticamente
- Ver también: Interrupt, Callback, RTOS
- Capítulo: 14, 33

**Exception**
Evento que altera flujo normal de ejecución.
- Ejemplos: Divide by zero, invalid memory access
- MCU responde con exception handler
- Ver también: Interrupt, Trap
- Capítulo: 14

---

## F

**FIFO (First-In-First-Out)**
Estructura de datos tipo cola donde primer elemento insertado es primero en salir.
- Usado en buffers de comunicación
- Ver también: Queue, Buffer, Circular Buffer
- Capítulo: 9

**Firmware**
Software que controla directamente el hardware en sistema embebido.
- Reside en memoria no volátil (Flash)
- Ver también: Embedded System, Flash Memory
- Capítulo: 1

**Flash Memory**
Memoria no volátil de estado sólido donde se almacena el firmware.
- Típico: 32 KB a 2 MB en MCUs
- Permite reescritura (update firmware)
- Ver también: EEPROM, NVM, Bootloader
- Capítulo: 4, 34

**Floating Point**
Representación de números con punto decimal (fracción).
- Tipos: `float` (32-bit), `double` (64-bit)
- Costoso en MCUs sin FPU
- Ver también: Fixed Point, FPU
- Capítulo: 5

**FPU (Floating-Point Unit)**
Unidad de hardware dedicada para operaciones de punto flotante.
- Presente en algunos ARM Cortex-M4, PIC32MZ
- Acelera cálculos matemáticos
- Ver también: Floating Point, ALU
- Capítulo: 1

**FreeRTOS**
Sistema operativo de tiempo real open-source popular en sistemas embebidos.
- Características: Tasks, queues, semaphores, timers
- Kernel pequeño (~10 KB)
- Ver también: RTOS, Task, Scheduler
- Capítulo: 33

**Frequency**
Número de ciclos de una señal periódica por unidad de tiempo.
- Unidad: Hz (Hertz) = ciclos/segundo
- Relacionado: Período = 1 / Frecuencia
- Ver también: Clock, PWM, Timer
- Capítulo: 4, 12

**Function Pointer**
Variable que almacena dirección de memoria de una función.
- Permite callbacks y dispatch tables
- Ejemplo: `void (*callback)(void);`
- Ver también: Callback, Pointer
- Capítulo: 5

---

## G

**GCC (GNU Compiler Collection)**
Conjunto de compiladores open-source.
- Base de XC32 compiler (para PIC32)
- Ver también: Compiler, Toolchain
- Capítulo: 3

**GPIO (General Purpose Input/Output)**
Pin configurable como entrada o salida digital.
- Estados: HIGH (3.3V) o LOW (0V)
- Usado para: LEDs, botones, control de periféricos
- Ver también: Pin, Digital I/O
- Capítulo: 8

**Ground (GND)**
Referencia de voltaje 0V en circuito.
- Debe ser común entre todos los dispositivos
- Ver también: VDD, Power Supply
- Capítulo: 4

---

## H

**HAL (Hardware Abstraction Layer)**
Capa de software que abstrae detalles específicos del hardware.
- Permite portabilidad entre diferentes MCUs
- Ver también: Driver, API, Abstraction
- Capítulo: 4, 6

**Handshake**
Protocolo de sincronización entre dos dispositivos antes de transmitir datos.
- Ejemplos: RTS/CTS en UART, ACK en I2C
- Ver también: Flow Control, Protocol
- Capítulo: 9

**Heap**
Área de memoria para allocación dinámica en runtime.
- Funciones: `malloc()`, `free()`
- Puede fragmentarse
- Ver también: Stack, Memory, Dynamic Allocation
- Capítulo: 5, 36

**Hexadecimal**
Sistema numérico en base 16 (dígitos 0-9, A-F).
- Notación: 0x o 0h
- Ejemplo: 0xFF = 255 decimal
- Ver también: Binary, Decimal
- Capítulo: 5

**HTTP (Hypertext Transfer Protocol)**
Protocolo de aplicación para transmisión de datos en web.
- Métodos: GET, POST, PUT, DELETE
- Puerto por defecto: 80 (HTTP), 443 (HTTPS)
- Ver también: TCP/IP, Web Server
- Capítulo: 23

---

## I

**I2C (Inter-Integrated Circuit)**
Protocolo de comunicación serial synchronous con 2 líneas (SDA, SCL).
- Multi-master, multi-slave
- Velocidades: 100 kHz (Standard), 400 kHz (Fast), 1 MHz (Fast+)
- Ver también: Bus, Serial, Pull-up
- Capítulo: 11

**ICSP (In-Circuit Serial Programming)**
Método de programación de MCU mientras está en circuito.
- Usa pines: MCLR, PGC, PGD
- Ver también: Programming, PICkit
- Capítulo: 3

**IDE (Integrated Development Environment)**
Software que combina editor, compilador y debugger.
- Ejemplo: MPLAB X IDE
- Ver también: Editor, Compiler, Debugger
- Capítulo: 2, 3

**Idle**
Estado de baja actividad donde CPU espera eventos.
- Reduce consumo de energía
- Ver también: Sleep, Power Management
- Capítulo: 33

**Initialization**
Configuración inicial de hardware y variables al arrancar sistema.
- Típicamente en función `main()` o `init()`
- Ver también: Startup, Configuration
- Capítulo: 4

**Inline Function**
Función cuyo código se inserta directamente en punto de llamada.
- Evita overhead de llamada a función
- Palabra clave: `inline`
- Ver también: Macro, Optimization
- Capítulo: 5

**Interrupt**
Evento que suspende temporalmente ejecución principal para atender evento urgente.
- Ejemplos: Timer overflow, data received, button press
- Ver también: ISR, Vector Table, Priority
- Capítulo: 14

**IoT (Internet of Things)**
Red de dispositivos físicos conectados a Internet.
- Componentes: Sensores, actuadores, conectividad
- Ver también: WiFi, MQTT, Cloud
- Capítulo: 1, 20-26

**ISR (Interrupt Service Routine)**
Función especial que se ejecuta cuando ocurre una interrupción.
- También llamado: Interrupt Handler
- Debe ser rápida y no bloqueante
- Ver también: Interrupt, Vector Table
- Capítulo: 14

---

## J

**JTAG (Joint Test Action Group)**
Interfaz estándar para debugging y programación de MCUs.
- Pines: TCK, TMS, TDI, TDO, TRST
- Permite boundary scan
- Ver también: Debug, ICSP
- Capítulo: 3

**Jitter**
Variación en timing de eventos periódicos.
- Indeseable en sistemas de tiempo real
- Causas: Interrupts, context switching
- Ver también: Real-Time, Timing
- Capítulo: 36

---

## K

**Kernel**
Núcleo de un sistema operativo que maneja recursos y scheduling.
- En RTOS: Maneja tasks, IPC, timing
- Ver también: RTOS, Scheduler, FreeRTOS
- Capítulo: 33

---

## L

**Latency**
Tiempo de retardo entre evento y respuesta.
- Interrupt latency: Tiempo hasta que ISR comienza
- Ver también: Real-Time, Response Time
- Capítulo: 14, 36

**Library**
Conjunto de funciones pre-compiladas reutilizables.
- Formato: .a (archive) o .lib
- Ejemplo: Math library (-lm)
- Ver también: Linker, API
- Capítulo: 3

**Linker**
Programa que combina archivos objeto (.o) en ejecutable final.
- Resuelve referencias entre módulos
- Usa linker script para memory layout
- Ver también: Compiler, Linker Script
- Capítulo: 3

**Linker Script**
Archivo que define memory layout y secciones del programa.
- Extensión: .ld
- Define: Flash addresses, RAM allocation
- Ver también: Memory Map, Linker
- Capítulo: 3, 34

**Little-Endian**
Formato de almacenamiento donde byte menos significativo (LSB) se almacena primero.
- Usado por: x86, ARM Cortex-M
- Ejemplo: 0x12345678 → [0x78][0x56][0x34][0x12]
- Ver también: Endianness, Byte Order
- Capítulo: 5

**LoRa (Long Range)**
Tecnología de comunicación wireless de largo alcance y bajo consumo.
- Rango: 2-15 km
- Velocidad: 0.3-50 kbps
- Ver también: LoRaWAN, LPWAN, IoT
- Capítulo: 22

**LoRaWAN**
Protocolo de red basado en LoRa para redes IoT.
- Arquitectura: End-nodes, Gateways, Network Server
- Ver también: LoRa, MQTT
- Capítulo: 22

---

## M

**Macro**
Sustitución de texto realizada por preprocessor.
- Definido con `#define`
- Ejemplo: `#define LED_PIN 10`
- Ver también: Preprocessor, Constant
- Capítulo: 5

**Master-Slave**
Arquitectura donde un dispositivo (master) controla comunicación con otros (slaves).
- Usado en: SPI, I2C
- Master genera clock
- Ver también: SPI, I2C, Bus
- Capítulo: 10, 11

**MCU (Microcontroller Unit)**
Computadora completa en un solo chip con CPU, memoria y periféricos.
- Ejemplos: PIC32MZ, dsPIC33, ARM Cortex-M
- Ver también: Embedded System, Processor
- Capítulo: 1

**Memory Leak**
Error de programación donde memoria allocada no se libera.
- Causa agotamiento gradual de heap
- Ver también: Heap, malloc, free
- Capítulo: 36

**Memory Map**
Distribución de diferentes regiones de memoria en espacio de direcciones.
- Secciones: Flash, RAM, Peripherals
- Ver también: Linker Script, Address Space
- Capítulo: 4

**MIPS**
Arquitectura de procesador RISC.
- Usado en PIC32 (MIPS32 M4K core)
- Ver también: PIC32, RISC
- Capítulo: 1

**Modbus**
Protocolo de comunicación industrial para SCADA y PLC.
- Variantes: Modbus RTU (serial), Modbus TCP (Ethernet)
- Ver también: Industrial Protocol, RS-485
- Capítulo: 25

**MPLAB X**
IDE oficial de Microchip para desarrollo en PIC/dsPIC.
- Basado en NetBeans
- Incluye: Editor, compiler, debugger
- Ver también: IDE, XC Compilers
- Capítulo: 2, 3

**MQTT (Message Queuing Telemetry Transport)**
Protocolo de mensajería ligero para IoT basado en publish/subscribe.
- Puerto por defecto: 1883 (MQTT), 8883 (MQTTS)
- Ver también: Broker, Topic, QoS, IoT
- Capítulo: 23

**Multitasking**
Capacidad de ejecutar múltiples tareas aparentemente simultáneas.
- Implementado por RTOS scheduler
- Ver también: RTOS, Task, Context Switch
- Capítulo: 33

**Mutex (Mutual Exclusion)**
Mecanismo de sincronización para proteger recursos compartidos.
- Solo una tarea puede adquirir mutex a la vez
- Ver también: Semaphore, Critical Section, RTOS
- Capítulo: 33

---

## N

**NACK (Not Acknowledge)**
Señal de no-reconocimiento en protocolos indicando fallo en recepción.
- Opuesto de ACK
- Usado en: I2C
- Ver también: ACK, I2C, Protocol
- Capítulo: 11

**Non-blocking**
Operación que retorna inmediatamente sin esperar completion.
- Ejemplo: `UART_TxReady()` verifica si puede enviar sin bloquear
- Opuesto: Blocking
- Ver también: Interrupt, Asynchronous
- Capítulo: 9

**NVM (Non-Volatile Memory)**
Memoria que retiene datos sin alimentación.
- Tipos: Flash, EEPROM, FRAM
- Ver también: Flash, EEPROM, Persistent
- Capítulo: 27

---

## O

**Oscillator**
Circuito que genera señal periódica para clock del MCU.
- Tipos: Crystal, RC, Internal
- Ver también: Clock, Crystal, Frequency
- Capítulo: 4

**OTA (Over-The-Air)**
Actualización de firmware remotamente via wireless.
- Métodos: WiFi, LoRa, Cellular
- Ver también: Bootloader, Firmware Update
- Capítulo: 34

**Overflow**
Condición donde resultado de operación excede rango representable.
- Ejemplo: uint8_t (255 + 1) → 0 (overflow)
- Ver también: Underflow, Wraparound
- Capítulo: 5

---

## P

**Parity**
Bit adicional para detección de errores en comunicación serial.
- Tipos: Even, Odd, None
- Ver también: UART, Error Detection
- Capítulo: 9

**PCB (Printed Circuit Board)**
Placa con pistas conductoras que conectan componentes electrónicos.
- Capas: 1, 2, 4, 6+
- Ver también: Schematic, Hardware
- Capítulo: 7

**Peripheral**
Módulo de hardware integrado en MCU para función específica.
- Ejemplos: UART, SPI, Timer, ADC
- Ver también: MCU, Register, Driver
- Capítulo: 4

**Persistent**
Datos que se mantienen después de reset o pérdida de alimentación.
- Almacenados en: Flash, EEPROM, NVM
- Ver también: NVM, Volatile
- Capítulo: 27

**PIC32**
Familia de microcontroladores de 32-bit de Microchip basados en MIPS.
- Variantes: PIC32MX, PIC32MZ
- Frecuencias: 40-252 MHz
- Ver también: MCU, MIPS, Microchip
- Capítulo: 1

**PICkit**
Programador/debugger económico de Microchip.
- Versiones: PICkit 3, PICkit 4
- Interfaz: ICSP
- Ver también: Programming, Debugger
- Capítulo: 3

**Pin**
Terminal físico del MCU que puede configurarse para diferentes funciones.
- Funciones: GPIO, UART TX/RX, SPI, I2C, ADC, etc
- Ver también: GPIO, Peripheral, Multiplexing
- Capítulo: 8

**Pointer**
Variable que almacena dirección de memoria.
- Ejemplo: `uint8_t* ptr = &variable;`
- Operadores: `&` (address-of), `*` (dereference)
- Ver también: Address, Reference
- Capítulo: 5

**Polling**
Técnica donde CPU verifica repetidamente estado de periférico.
- Alternativa: Interrupts
- Menos eficiente energéticamente
- Ver también: Busy-Wait, Interrupt
- Capítulo: 9

**Power Supply**
Circuito que proporciona voltaje estable al sistema.
- Típico: 3.3V o 5V para MCU
- Ver también: VDD, GND, Regulator
- Capítulo: 4

**Preprocessor**
Primera fase de compilación que procesa directivas (#define, #include, etc).
- Realiza sustitución de texto
- Ver también: Macro, #include, #define
- Capítulo: 5

**Priority**
Nivel de importancia asignado a interrupt o task.
- Mayor prioridad → Se ejecuta primero
- Ver también: Interrupt, RTOS, Scheduler
- Capítulo: 14, 33

**Protocol**
Conjunto de reglas para comunicación entre dispositivos.
- Ejemplos: UART, SPI, I2C, CAN, MQTT, HTTP
- Define: Formato de datos, timing, handshaking
- Ver también: Communication
- Capítulos: 9-11, 23-26

**Pull-up / Pull-down**
Resistencia que fija nivel lógico de pin cuando está floating.
- Pull-up: Conecta a VDD (pin = HIGH por defecto)
- Pull-down: Conecta a GND (pin = LOW por defecto)
- Ver también: GPIO, Floating, I2C
- Capítulo: 8, 11

**PWM (Pulse Width Modulation)**
Técnica para simular señal analógica variando duty cycle de señal digital.
- Usado para: Control de LEDs, motores, DAC
- Ver también: Duty Cycle, Timer
- Capítulo: 12

---

## Q

**Quantization**
Proceso de discretizar señal analógica continua en valores digitales finitos.
- Resolución determina precisión
- Ocurre en ADC
- Ver también: ADC, Resolution, Sampling
- Capítulo: 13

**Queue**
Estructura de datos FIFO para comunicación entre tasks en RTOS.
- Operaciones: Send, Receive, Peek
- Ver también: FIFO, RTOS, IPC
- Capítulo: 33

**QoS (Quality of Service)**
Nivel de garantía de entrega en protocolos de mensajería.
- MQTT QoS: 0 (at most once), 1 (at least once), 2 (exactly once)
- Ver también: MQTT, Reliability
- Capítulo: 23

---

## R

**RAM (Random Access Memory)**
Memoria volátil de acceso rápido para datos y stack.
- Típico en MCU: 8 KB - 512 KB
- Pierde datos sin alimentación
- Ver también: Volatile, SRAM, Memory
- Capítulo: 4

**Real-Time**
Sistema donde corrección depende no solo del resultado sino del tiempo en que se produce.
- Hard real-time: Deadline absoluto
- Soft real-time: Deadline preferible
- Ver también: RTOS, Deadline, Latency
- Capítulo: 33

**Register**
Pequeña área de almacenamiento de alta velocidad en CPU o periférico.
- Tipos: Control, Status, Data
- Acceso: Memory-mapped
- Ver también: Peripheral, Bit Manipulation
- Capítulo: 4, 5

**Reset**
Condición que reinicia el MCU a estado inicial.
- Tipos: Power-on, Brown-out, Watchdog, Software
- Ver también: Startup, Watchdog, Brown-out
- Capítulo: 4

**Resolution**
Número de niveles discretos en conversión analógico-digital.
- Ejemplo: ADC 10-bit = 1024 niveles (0-1023)
- Mayor resolución = Mayor precisión
- Ver también: ADC, Quantization
- Capítulo: 13

**RISC (Reduced Instruction Set Computer)**
Arquitectura de CPU con conjunto simple de instrucciones.
- Características: Instrucciones de tamaño fijo, pocos modos de direccionamiento
- Ejemplos: ARM, MIPS
- Ver también: ARM, MIPS, Architecture
- Capítulo: 1

**RTOS (Real-Time Operating System)**
Sistema operativo diseñado para aplicaciones de tiempo real.
- Características: Determinismo, scheduling predictible
- Ejemplo: FreeRTOS
- Ver también: FreeRTOS, Task, Scheduler
- Capítulo: 33

---

## S

**Sampling**
Proceso de medir señal analógica a intervalos regulares.
- Sampling rate: Frecuencia de muestreo (Hz o SPS)
- Nyquist theorem: Sample rate ≥ 2× señal máxima
- Ver también: ADC, Quantization
- Capítulo: 13

**Scheduler**
Componente de RTOS que decide qué task ejecutar.
- Algoritmos: Preemptive, Cooperative, Round-robin
- Ver también: RTOS, Task, Priority
- Capítulo: 33

**SDK (Software Development Kit)**
Conjunto de herramientas, bibliotecas y documentación para desarrollar software.
- EMIC SDK: Repositorio de módulos y APIs reutilizables
- Ver también: API, Library, Toolchain
- Capítulo: 1

**Semaphore**
Mecanismo de sincronización para coordinar tasks.
- Tipos: Binary (0/1), Counting (0-N)
- Ver también: Mutex, RTOS, Synchronization
- Capítulo: 33

**Serial Communication**
Transmisión de datos bit por bit secuencialmente.
- Tipos: UART (asynchronous), SPI, I2C (synchronous)
- Ver también: UART, SPI, I2C
- Capítulos: 9-11

**Sleep Mode**
Estado de bajo consumo donde CPU se detiene temporalmente.
- Variantes: Idle, Doze, Sleep, Deep Sleep
- Despertar: Por interrupt
- Ver también: Power Management, Interrupt
- Capítulo: 4

**SPI (Serial Peripheral Interface)**
Protocolo de comunicación serial synchronous full-duplex con 4 líneas.
- Líneas: SCK (clock), MOSI, MISO, CS
- Master-slave architecture
- Velocidades: Hasta decenas de MHz
- Ver también: Master-Slave, Full-Duplex
- Capítulo: 10

**Stack**
Área de memoria para almacenar variables locales, parámetros y direcciones de retorno.
- Crece hacia abajo en direcciones de memoria
- Stack overflow si se excede tamaño
- Ver también: Heap, Stack Overflow, Memory
- Capítulo: 5, 36

**Stack Overflow**
Error donde stack excede tamaño asignado.
- Síntomas: Reset, corrupción de variables
- Causas: Recursión profunda, arrays grandes locales
- Ver también: Stack, Memory, Debugging
- Capítulo: 36

**State Machine**
Modelo de sistema que transita entre estados definidos según eventos.
- Componentes: Estados, transiciones, eventos
- Patrón común en sistemas embebidos
- Ver también: Event, FSM
- Capítulo: 5

**Static**
Palabra clave C con múltiples significados según contexto:
- Variable local static: Persiste entre llamadas
- Variable global static: Scope limitado a archivo
- Función static: No exportada (internal linkage)
- Ver también: Scope, Linkage
- Capítulo: 5

**Struct (Structure)**
Tipo de dato compuesto que agrupa variables relacionadas.
- Ejemplo: `struct Point { int x; int y; };`
- Ver también: Type, Data Structure
- Capítulo: 5

**Synchronous**
Comunicación donde transmisor y receptor comparten clock común.
- Ejemplos: SPI, I2C
- Opuesto: Asynchronous (UART)
- Ver también: SPI, I2C, Clock
- Capítulos: 10, 11

---

## T

**Task**
Unidad de ejecución independiente en RTOS, similar a thread.
- Tiene: Priority, stack, state
- Estados: Running, Ready, Blocked, Suspended
- Ver también: RTOS, Scheduler, Context Switch
- Capítulo: 33

**TCP/IP (Transmission Control Protocol / Internet Protocol)**
Suite de protocolos para comunicación en redes.
- TCP: Confiable, orientado a conexión
- IP: Routing de paquetes
- Ver también: Ethernet, HTTP, MQTT
- Capítulo: 20

**Timer**
Periférico que cuenta pulsos de clock para medir tiempo.
- Usado para: Delays, PWM, event scheduling
- Tipos: 16-bit, 32-bit
- Ver también: PWM, Interrupt, Clock
- Capítulo: 12

**Toolchain**
Conjunto de herramientas para desarrollo (compiler, linker, assembler, debugger).
- EMIC: XC8/XC16/XC32 + MPLAB X
- Ver también: Compiler, Linker, IDE
- Capítulo: 3

**UART (Universal Asynchronous Receiver-Transmitter)**
Periférico para comunicación serial asynchronous.
- Líneas: TX (transmit), RX (receive)
- Parámetros: Baudrate, data bits, parity, stop bits
- Ver también: Serial Communication, Asynchronous
- Capítulo: 9

**Typedef**
Palabra clave C para crear alias de tipos.
- Ejemplo: `typedef uint8_t byte;`
- Mejora legibilidad
- Ver también: Type, Struct, Enum
- Capítulo: 5

---

## U

**UART** (ver definición en T)

**Underflow**
Condición donde resultado de operación es menor que mínimo representable.
- Ejemplo: uint8_t (0 - 1) → 255 (underflow)
- Ver también: Overflow, Wraparound
- Capítulo: 5

**USB (Universal Serial Bus)**
Interfaz serial para conectar periféricos.
- Velocidades: USB 1.1 (12 Mbps), USB 2.0 (480 Mbps)
- Modos: Host, Device, OTG
- Ver también: Communication, Peripheral
- Capítulo: 16

---

## V

**Variable**
Ubicación nombrada en memoria para almacenar datos.
- Tipos: Local, Global, Static, Volatile
- Ver también: Type, Scope, Memory
- Capítulo: 5

**VDD**
Voltaje de alimentación positivo (power supply).
- Típico: 3.3V o 5V en MCUs
- Ver también: GND, Power Supply
- Capítulo: 4

**Vector Table**
Tabla en memoria que contiene direcciones de ISRs.
- Cada interrupt tiene entrada en vector table
- En PIC32: Ubicada en 0x9D000000 + offset
- Ver también: Interrupt, ISR, Reset Vector
- Capítulo: 14, 34

**Volatile**
Palabra clave C que indica variable puede cambiar externamente.
- Usado para: Registros de hardware, variables modificadas en ISR
- Previene optimizaciones del compilador
- Ver también: Register, Interrupt, Compiler
- Capítulo: 5, 14

---

## W

**Watchdog Timer (WDT)**
Timer de hardware que resetea MCU si no se "alimenta" periódicamente.
- Detecta software colgado
- Debe deshabilitarse durante debugging
- Ver también: Reset, Timeout, Safety
- Capítulo: 4, 36

**WiFi**
Tecnología de comunicación wireless basada en IEEE 802.11.
- Bandas: 2.4 GHz, 5 GHz
- Protocolos: WPA2, WPA3
- Ver también: IoT, TCP/IP, HTTP, MQTT
- Capítulo: 20

**Word**
Unidad de datos nativa del procesador.
- 8-bit MCU: 1 byte
- 16-bit MCU: 2 bytes
- 32-bit MCU: 4 bytes
- Ver también: Byte, Data Type
- Capítulo: 5

**Wraparound**
Comportamiento donde valor que excede máximo vuelve a mínimo (o viceversa).
- Ejemplo: uint8_t (255 + 1) = 0
- Ver también: Overflow, Underflow, Modular Arithmetic
- Capítulo: 5

---

## X

**XC8 / XC16 / XC32**
Familia de compiladores C de Microchip para PICs.
- XC8: PIC de 8-bit
- XC16: PIC/dsPIC de 16-bit
- XC32: PIC32 de 32-bit (basado en GCC)
- Ver también: Compiler, Toolchain, MPLAB X
- Capítulo: 3

---

## 📚 Referencias

Para información detallada de términos, consultar:
- Capítulos específicos indicados en cada definición
- Datasheets de Microchip (www.microchip.com)
- EMIC SDK Documentation (docs.emic.io)

---

**Progreso del Manual:**
- Capítulo: 37/38 (97.37%)
- Sección 7: 3/4 (75%)

**Próximo capítulo:** Cap. 38 - Recursos y Comunidad (ÚLTIMO CAPÍTULO!)

---

*Glosario Completo EMIC SDK - v1.0*
*EMIC SDK Development Manual - Section 7*

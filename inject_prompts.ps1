$ErrorActionPreference = 'Stop'
try {
    $planPath = 'PLAN_MAESTRO_MANUAL_DESARROLLO_EMIC.md'
    $restoredPath = 'restored_prompts_s1_s2.md'
    
    $planContent = Get-Content -Path $planPath -Raw -Encoding UTF8
    $restoredContent = Get-Content -Path $restoredPath -Raw -Encoding UTF8
    
    # Use ASCII match for robustness
    $marker = "EMIC-CODIFY"
    $index = $planContent.IndexOf($marker)
    
    if ($index -ge 0) {
        # Find the ### line before this marker
         # We'll just look for the PREVIOUS "###" before this marker to get the start of the line or section
         # But simpler: just locate the line with "SECCI?N 3" (ignoring charset) by regex
         
         $lines = Get-Content -Path $planPath -Encoding UTF8
         $insertLineIndex = -1
         for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "EMIC-CODIFY" -and $lines[$i] -match "###") {
                $insertLineIndex = $i
                break
            }
         }
         
         if ($insertLineIndex -ge 0) {
             # Insert before this line
             $preLines = $lines[0..($insertLineIndex - 1)]
             $postLines = $lines[$insertLineIndex..($lines.Count - 1)]
             
             $finalContent = ($preLines -join "`r`n") + "`r`n" + $restoredContent + "`r`n" + ($postLines -join "`r`n")
             Set-Content -Path $planPath -Value $finalContent -Encoding UTF8
             Write-Host "Successfully injected prompts."
         } else {
             Write-Error "Could not find line match."
         }

    } else {
        Write-Error "Could not find marker text."
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

@echo off
title SIAC - Servidor Dashboard JNE 2026
color 0A
echo.
echo  ============================================
echo   SIAC - Sistema Integral de Actas JNE 2026
echo  ============================================
echo.
echo  [*] Iniciando servidor en http://localhost:8080
echo  [*] Mantener esta ventana abierta.
echo  [*] Para cerrar: presione Ctrl+C
echo  ============================================
echo.

REM Abrir Chrome automaticamente despues de 2 segundos
start "" /b cmd /c "timeout /t 2 /nobreak >nul && start chrome http://localhost:8080/SIAC_Dashboard_JNE_2026.html"

REM Servidor PowerShell con autenticacion ANONIMA (sin usuario/contraseña)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$folder = Split-Path -Parent '%~f0';" ^
  "$listener = New-Object System.Net.HttpListener;" ^
  "$listener.Prefixes.Add('http://localhost:8080/');" ^
  "$listener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::Anonymous;" ^
  "try {" ^
    "$listener.Start();" ^
    "Write-Host '[OK] Servidor activo en http://localhost:8080' -ForegroundColor Green;" ^
    "Write-Host '[..] Esperando... (Ctrl+C para detener)' -ForegroundColor Yellow;" ^
  "} catch {" ^
    "Write-Host '[ERROR] Puerto 8080 ocupado. Cierre otras instancias y reintente.' -ForegroundColor Red;" ^
    "pause; exit 1;" ^
  "};" ^
  "while ($listener.IsListening) {" ^
    "try {" ^
      "$ctx = $listener.GetContext();" ^
      "$req = $ctx.Request;" ^
      "$res = $ctx.Response;" ^
      "$path = $req.Url.LocalPath.TrimStart('/');" ^
      "if ($path -eq '' -or $path -eq '/') { $path = 'SIAC_Dashboard_JNE_2026.html' };" ^
      "$file = Join-Path $folder $path;" ^
      "if (Test-Path $file -PathType Leaf) {" ^
        "$bytes = [System.IO.File]::ReadAllBytes($file);" ^
        "$ext = [System.IO.Path]::GetExtension($file).ToLower();" ^
        "$mime = if($ext -eq '.html'){'text/html; charset=utf-8'} elseif($ext -eq '.js'){'application/javascript'} elseif($ext -eq '.css'){'text/css'} else {'application/octet-stream'};" ^
        "$res.ContentType = $mime;" ^
        "$res.ContentLength64 = $bytes.Length;" ^
        "$res.Headers.Add('Access-Control-Allow-Origin','*');" ^
        "$res.Headers.Add('Cache-Control','no-cache');" ^
        "$res.OutputStream.Write($bytes, 0, $bytes.Length);" ^
        "Write-Host ('[OK] ' + $path) -ForegroundColor Cyan;" ^
      "} else {" ^
        "$res.StatusCode = 404;" ^
        "Write-Host ('[404] ' + $path) -ForegroundColor Red;" ^
      "};" ^
      "$res.Close();" ^
    "} catch { }" ^
  "};"

echo.
echo  Servidor detenido.
pause

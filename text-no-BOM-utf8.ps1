#!/usr/bin/env pwsh

$ruta = "archivo_perfecto.txt"
$contenido = "Línea 1`nLínea 2" # El `n es LF en PowerShell

# Creamos el encoding UTF-8 sin BOM (la firma)
$utf8SinBOM = New-Object System.Text.UTF8Encoding($false)

# Escribimos el archivo
[System.IO.File]::WriteAllText($ruta, $contenido, $utf8SinBOM)

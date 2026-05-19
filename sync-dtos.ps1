$ErrorActionPreference = "Stop"

$JSON_FILE = "dtos.json"

if (-not (Test-Path $JSON_FILE)) {
    Write-Error "ERROR: '$JSON_FILE' not found."
    exit 1
}

$dtos = (Get-Content $JSON_FILE -Raw | ConvertFrom-Json).dtos

foreach ($entry in $dtos) {
    $name            = $entry.name
    $gatewayPath     = $entry.gatewayPath
    $microservicePath = $entry.microservicePath

    Write-Host "[$name] Syncing '$microservicePath' -> '$gatewayPath'"

    if (-not (Test-Path $microservicePath -PathType Container)) {
        Write-Host "[$name] ERROR: Microservice path '$microservicePath' does not exist. Skipping."
        continue
    }

    if (-not (Test-Path $gatewayPath)) {
        New-Item -ItemType Directory -Path $gatewayPath -Force | Out-Null
    }

    Remove-Item -Path "$gatewayPath\*" -Recurse -Force

    Copy-Item -Path "$microservicePath\*" -Destination $gatewayPath -Recurse -Force

    Write-Host "[$name] Done."
}
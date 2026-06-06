Get-ChildItem -Path "." -Directory | Where-Object { $_.Name -like "ENTropy-Backend-MS*" } | ForEach-Object {
    Write-Host "`nProcessing: $( $_.FullName )" -ForegroundColor Cyan
    Set-Location $_.FullName

    Remove-Item -Path "src/database/migrations/*.ts" -Force -ErrorAction SilentlyContinue
    npm run update:common
    npm run migration:generate
    npm run migration:run

    Set-Location ..
}
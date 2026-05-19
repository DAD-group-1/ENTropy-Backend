<#
.SYNOPSIS
    Syncs *.interface.ts and *.dto.ts files from ENTropy microservices to the Gateway.

.DESCRIPTION
    Scans all directories matching 'ENTropy-Backend-MS-*/src', collects every
    *.interface.ts and *.dto.ts file, then finds matching filenames inside
    'ENTropy-Backend-Gateway'. For each match it compares the content that
    comes AFTER the last import statement. If the MS version differs from the
    Gateway version, the Gateway file is updated with the MS post-import block.

.PARAMETER RootPath
    Base directory that contains both the microservice folders and the Gateway
    folder. Defaults to the current working directory.

.PARAMETER GatewayName
    Name of the Gateway folder. Defaults to 'ENTropy-Backend-Gateway'.

.PARAMETER WhatIf
    Simulate the run without writing any files.

.EXAMPLE
    .\Sync-MSToGateway.ps1
    .\Sync-MSToGateway.ps1 -RootPath "C:\Projects" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [string] $RootPath    = (Get-Location).Path,
    [string] $GatewayName = 'ENTropy-Backend-Gateway'
)

# ─── Helpers ────────────────────────────────────────────────────────────────

function Get-PostImportContent {
    <#
    .SYNOPSIS
        Returns a hashtable with:
          - ImportBlock  : everything up to and including the last import line
          - BodyBlock    : everything after the last import line
          - LastImportIndex : 0-based line index of the last import (-1 if none)
    #>
    param ([string[]] $Lines)

    $lastImportIdx = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        # Match any line that starts an import statement (handles multi-line
        # imports too by catching the opening line)
        if ($Lines[$i] -match '^\s*import\s') {
            $lastImportIdx = $i
        }
    }

    if ($lastImportIdx -eq -1) {
        # No import at all — treat the whole file as "body"
        return @{
            ImportBlock      = @()
            BodyBlock        = $Lines
            LastImportIndex  = -1
        }
    }

    return @{
        ImportBlock     = $Lines[0..$lastImportIdx]
        BodyBlock       = if ($lastImportIdx + 1 -lt $Lines.Count) {
            $Lines[($lastImportIdx + 1)..($Lines.Count - 1)]
        } else { @() }
        LastImportIndex = $lastImportIdx
    }
}

function Compare-BodyBlocks {
    param ([string[]] $A, [string[]] $B)
    $normA = ($A | ForEach-Object { $_.TrimEnd() }) -join "`n"
    $normB = ($B | ForEach-Object { $_.TrimEnd() }) -join "`n"
    return $normA -eq $normB
}

# ─── Main ───────────────────────────────────────────────────────────────────

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ENTropy MS → Gateway sync" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Root    : $RootPath"
Write-Host "  Gateway : $GatewayName"
Write-Host ""

# 1. Locate all matching MS source directories
$msSrcDirs = Get-ChildItem -Path $RootPath -Directory -Filter 'ENTropy-Backend-MS-*' |
        ForEach-Object {
            $srcPath = Join-Path $_.FullName 'src'
            if (Test-Path $srcPath) { $srcPath }
        }

if (-not $msSrcDirs) {
    Write-Warning "No 'ENTropy-Backend-MS-*/src' directories found under '$RootPath'."
    exit 0
}

Write-Host "Microservice /src directories found:" -ForegroundColor Yellow
$msSrcDirs | ForEach-Object { Write-Host "  $_" }
Write-Host ""

# 2. Collect all *.interface.ts and *.dto.ts files from every MS src
$msFiles = $msSrcDirs | ForEach-Object {
    Get-ChildItem -Path $_ -Recurse -Include '*.interface.ts', '*.dto.ts' -File
}

if (-not $msFiles) {
    Write-Warning "No *.interface.ts or *.dto.ts files found in the microservice directories."
    exit 0
}

Write-Host "MS source files collected : $($msFiles.Count)" -ForegroundColor Yellow
Write-Host ""

# 3. Locate the Gateway root
$gatewayRoot = Join-Path $RootPath $GatewayName
if (-not (Test-Path $gatewayRoot)) {
    Write-Error "Gateway directory not found: '$gatewayRoot'"
    exit 1
}

# 4. Build a name-to-path lookup for every file inside the Gateway
Write-Host "Indexing Gateway files..." -ForegroundColor Yellow
$gatewayIndex = @{}   # key = filename (lowercase), value = list of full paths

Get-ChildItem -Path $gatewayRoot -Recurse -File | ForEach-Object {
    $key = $_.Name.ToLower()
    if (-not $gatewayIndex.ContainsKey($key)) {
        $gatewayIndex[$key] = [System.Collections.Generic.List[string]]::new()
    }
    $gatewayIndex[$key].Add($_.FullName)
}

Write-Host "Gateway files indexed     : $($gatewayIndex.Count) unique names"
Write-Host ""

# 5. Process each MS file
$stats = @{ Checked = 0; Synced = 0; Skipped = 0; NoMatch = 0 }

foreach ($msFile in $msFiles) {
    $key = $msFile.Name.ToLower()

    if (-not $gatewayIndex.ContainsKey($key)) {
        Write-Verbose "NO MATCH  : $($msFile.FullName)"
        $stats.NoMatch++
        continue
    }

    $gatewayMatches = $gatewayIndex[$key]

    # Read MS file
    $msLines   = Get-Content -Path $msFile.FullName -Encoding UTF8
    $msParsed  = Get-PostImportContent -Lines $msLines

    foreach ($gwPath in $gatewayMatches) {
        $stats.Checked++

        Write-Host "Checking  : $($msFile.Name)" -ForegroundColor Gray
        Write-Host "  MS      : $($msFile.FullName)"
        Write-Host "  Gateway : $gwPath"

        $gwLines  = Get-Content -Path $gwPath -Encoding UTF8
        $gwParsed = Get-PostImportContent -Lines $gwLines

        # Compare body blocks (content after last import)
        if (Compare-BodyBlocks -A $msParsed.BodyBlock -B $gwParsed.BodyBlock) {
            Write-Host "  Status  : " -NoNewline
            Write-Host "UP-TO-DATE" -ForegroundColor Green
            $stats.Skipped++
            continue
        }

        # Bodies differ - show a summary of what changes
        Write-Host "  Status  : " -NoNewline
        Write-Host "OUTDATED  (body differs after last import)" -ForegroundColor Yellow

        if ($msParsed.BodyBlock.Count -eq 0) {
            Write-Host "  Warning : MS file has no content after imports - skipping." -ForegroundColor DarkYellow
            $stats.Skipped++
            continue
        }

        # Build the new file content:
        #   Gateway import block  +  MS body block
        $newContent = @()

        if ($gwParsed.ImportBlock.Count -gt 0) {
            $newContent += $gwParsed.ImportBlock
        }

        $newContent += $msParsed.BodyBlock

        $newText = $newContent -join "`n"

        if ($PSCmdlet.ShouldProcess($gwPath, "Overwrite body after last import with MS version")) {
            Set-Content -Path $gwPath -Value $newText -Encoding UTF8 -NoNewline
            Write-Host "  Action  : " -NoNewline
            Write-Host "UPDATED" -ForegroundColor Cyan
            $stats.Synced++
        } else {
            Write-Host "  Action  : " -NoNewline
            Write-Host "WOULD UPDATE (WhatIf)" -ForegroundColor DarkCyan
            $stats.Synced++
        }
    }
}

# 6. Summary
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Files checked      : $($stats.Checked)"
Write-Host "  Files synced       : $($stats.Synced)" -ForegroundColor Cyan
Write-Host "  Already up-to-date : $($stats.Skipped)" -ForegroundColor Green
Write-Host "  No Gateway match   : $($stats.NoMatch)" -ForegroundColor DarkGray
Write-Host ""

param(
    [string]$InputFile = "schema.json"
)

# ─── Helpers ────────────────────────────────────────────────────────────────

function To-PascalCase($str)
{
    (($str -split '_') | ForEach-Object {
        $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower()
    }) -join ''
}

function To-SingularPascalCase($tableName)
{
    $singular = $tableName -replace 'ies$', 'y' -replace 's$', ''
    To-PascalCase $singular
}

function To-KebabSingular($tableName)
{
    $singular = $tableName -replace 'ies$', 'y' -replace 's$', ''
    ($singular -split '_' | ForEach-Object { $_.ToLower() }) -join '-'
}

function To-KebabPlural($tableName)
{
    ((($tableName -replace 's$', '') + 's') -split '_' | ForEach-Object { $_.ToLower() }) -join '-'
}

# Map SQL types to TypeScript types
function To-TsType($sqlType)
{
    switch ( $sqlType.ToUpper())
    {
        'INTEGER'  {
            return 'number'
        }
        'INT'      {
            return 'number'
        }
        'BIGINT'   {
            return 'number'
        }
        'FLOAT'    {
            return 'number'
        }
        'DOUBLE'   {
            return 'number'
        }
        'DECIMAL'  {
            return 'number'
        }
        'YEAR'     {
            return 'number'
        }
        'VARCHAR'  {
            return 'string'
        }
        'TEXT'     {
            return 'string'
        }
        'CHAR'     {
            return 'string'
        }
        'DATE'     {
            return 'Date'
        }
        'DATETIME' {
            return 'Date'
        }
        'TIMESTAMP'{
            return 'Date'
        }
        'BOOLEAN'  {
            return 'boolean'
        }
        'BOOL'     {
            return 'boolean'
        }
        'ENUM'     {
            return 'enum'
        }  # handled separately
        default    {
            return 'any'
        }
    }
}

# ─── Load JSON ───────────────────────────────────────────────────────────────

$json = Get-Content $InputFile -Raw | ConvertFrom-Json

foreach ($table in $json.tables)
{
    $tableName = $table.name
    $fields = $table.fields
    $className = To-SingularPascalCase $tableName
    $kebabSingular = To-KebabSingular $tableName
    $kebabPlural = To-KebabPlural $tableName

    $baseDir = "ENTropy-Backend-Common/src/core/services/aaa-generated/$kebabPlural"
    $entityDir = "$baseDir/entities"
    $interfaceDir = "$baseDir/interfaces"
    $dtoDir = "$baseDir/interfaces/dto"

    New-Item -ItemType Directory -Force -Path $entityDir   | Out-Null
    New-Item -ItemType Directory -Force -Path $interfaceDir | Out-Null
    New-Item -ItemType Directory -Force -Path $dtoDir      | Out-Null

    # Detect enums
    $enumFields = $fields | Where-Object { $_.type -eq 'ENUM' }

    # ── 1. ENTITY ────────────────────────────────────────────────────────────

    $entityPath = "$entityDir/$kebabSingular.entity.ts"

    if (Test-Path $entityPath)
    {
        Write-Host "Skipped (already exists): $entityPath"
    }
    else
    {
        $sb = [System.Text.StringBuilder]::new()

        # Imports
        [void]$sb.AppendLine("import { Entity, Column, PrimaryColumn, PrimaryGeneratedColumn } from 'typeorm';")

        # Enum imports if any
        foreach ($ef in $enumFields)
        {
            $enumName = "$className$( To-PascalCase $ef.name )"
            [void]$sb.AppendLine("import { $enumName } from '../interfaces/$kebabSingular.interface';")
        }

        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("@Entity()")
        [void]$sb.AppendLine("export class Internal$className {")

        foreach ($field in $fields)
        {
            $tsType = To-TsType $field.type

            if ($field.type -eq 'ENUM')
            {
                $enumName = "$className$( To-PascalCase $field.name )"
                $tsType = $enumName
            }

            if ($field.primary -and $field.increment)
            {
                [void]$sb.AppendLine("  @PrimaryGeneratedColumn()")
            }
            elseif ($field.primary)
            {
                [void]$sb.AppendLine("  @PrimaryColumn()")
            }
            else
            {
                [void]$sb.AppendLine("  @Column()")
            }

            [void]$sb.AppendLine("  $( $field.name ): $tsType;")
        }

        [void]$sb.AppendLine("}")

        Set-Content -Path $entityPath -Value $sb.ToString()
        Write-Host "Created entity:     $entityPath"
    }

    # ── 2. INTERFACE ─────────────────────────────────────────────────────────

    $interfacePath = "$interfaceDir/$kebabSingular.interface.ts"

    if (Test-Path $interfacePath)
    {
        Write-Host "Skipped (already exists): $interfacePath"
    }
    else
    {
        $sb = [System.Text.StringBuilder]::new()

        # Enums
        foreach ($ef in $enumFields)
        {
            $enumName = "$className$( To-PascalCase $ef.name )"
            [void]$sb.AppendLine("export enum $enumName {")
            foreach ($val in $ef.values)
            {
                $key = $val.ToUpper()
                [void]$sb.AppendLine("  $key = '$val',")
            }
            [void]$sb.AppendLine("}")
            [void]$sb.AppendLine("")
        }

        # Interface
        [void]$sb.AppendLine("export interface $className {")

        foreach ($field in $fields)
        {
            $tsType = To-TsType $field.type
            if ($field.type -eq 'ENUM')
            {
                $enumName = "$className$( To-PascalCase $field.name )"
                $tsType = $enumName
            }
            [void]$sb.AppendLine("  $( $field.name ): $tsType;")
        }

        [void]$sb.AppendLine("}")

        Set-Content -Path $interfacePath -Value $sb.ToString()
        Write-Host "Created interface:  $interfacePath"
    }

    # ── 3. DTO ───────────────────────────────────────────────────────────────

    $dtoPath = "$dtoDir/$kebabSingular.dto.ts"

    if (Test-Path $dtoPath)
    {
        Write-Host "Skipped (already exists): $dtoPath"
    }
    else
    {
        $sb = [System.Text.StringBuilder]::new()

        [void]$sb.AppendLine("import { ApiProperty } from '@nestjs/swagger';")
        [void]$sb.AppendLine("import { PartialType } from '@nestjs/mapped-types';")

        foreach ($ef in $enumFields)
        {
            $enumName = "$className$( To-PascalCase $ef.name )"
            [void]$sb.AppendLine("import { $enumName } from '../interfaces/$kebabSingular.interface';")
        }

        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("export class Create${className}Dto {")

        foreach ($field in $fields)
        {
            $tsType = To-TsType $field.type
            if ($field.type -eq 'ENUM')
            {
                $enumName = "$className$( To-PascalCase $field.name )"
                $tsType = $enumName
            }
            [void]$sb.AppendLine("  @ApiProperty()")
            [void]$sb.AppendLine("  $( $field.name ): $tsType;")
            [void]$sb.AppendLine("")
        }

        [void]$sb.AppendLine("}")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("export class Update${className}Dto extends PartialType(Create${className}Dto) {}")

        Set-Content -Path $dtoPath -Value $sb.ToString()
        Write-Host "Created dto:        $dtoPath"
    }

    Write-Host ""
}
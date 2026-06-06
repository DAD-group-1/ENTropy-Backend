function Clear-Terminal
{
    $ESC = [char]27
    $hideCursor = "${ESC}[?25l"
    Write-Host -NoNewline $hideCursor
    [Console]::SetCursorPosition(0, 0)
    [Console]::Clear()
}

function Close-Terminal
{
    $ESC = [char]27
    $showCursor = "${ESC}[?25h"
    Write-Host -NoNewline $showCursor
}

function Display-List
{
    Clear-Terminal
    Write-Host "Select in which project you want to create the nest component:`n"

    $listOptions | ForEach-Object -Begin { $index = 0 } -Process {
        $prefix = if ($index -eq $selectedOption.Value)
        {
            [char]0x276F
        }
        else
        {
            " "
        }
        $checkbox = if ($index -eq $selectedOption.Value)
        {
            [char]0x25C9
        }
        else
        {
            [char]0x25CB
        }
        Write-Host "$prefix $checkbox $_"
        $index++
    }
}

function Show-Menu
{
    param([string[]]$Options)

    $selectedOption = [ref]0

    Display-List

    while ($true)
    {
        $keyInfo = [System.Console]::ReadKey($true)

        switch ($keyInfo.Key)
        {
            "DownArrow" {
                $selectedOption.Value = (($selectedOption.Value + 1) % $Options.Length)
                Display-List
            }
            "UpArrow" {
                $selectedOption.Value = (($selectedOption.Value - 1 + $Options.Length) % $Options.Length)
                Display-List
            }
            "Enter" {
                Close-Terminal
                return $Options[$selectedOption.Value]
            }
        }

        Start-Sleep -Milliseconds 50
    }
}

# --- Usage ---

$listOptions = Get-ChildItem -Directory | Where-Object { $_.Name -like "ENTropy*" } | Select-Object -ExpandProperty Name
$selected = Show-Menu -Options $listOptions

# Do whatever you want with $selected here
Write-Host "`nYou selected: $selected"

cd $selected

$folder_path = Read-Host "Enter the folder path (e.g. core/users)"
$name = Read-Host "Enter the module name (e.g. user)"

nest g module $folder_path/$name --flat
nest g controller $folder_path/$name --flat
nest g service $folder_path/$name --flat


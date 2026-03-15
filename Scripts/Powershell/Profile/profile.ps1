#!/usr/bin/env pwsh

## Map PSDrives to other registry hives
if (!(Test-Path HKCR:)) {
    $null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    $null = New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
}

## Create $PSStyle if running on a version older than 7.2
## - Add other ANSI color definitions as needed

if ($PSVersionTable.PSVersion.ToString() -lt '7.2.0') {
    # define escape char since "`e" may not be supported
    $esc = [char]0x1b
    $PSStyle = [pscustomobject]@{
        Foreground = @{
            Magenta = "${esc}[35m"
            BrightYellow = "${esc}[93m"
        }
        Background = @{
            BrightBlack = "${esc}[100m"
        }
    }
}

## Set PSReadLine options and keybindings
$PSROptions = @{
    ContinuationPrompt = '  '
    Colors             = @{
        Operator         = $PSStyle.Foreground.Magenta
        Parameter        = $PSStyle.Foreground.Magenta
        Selection        = $PSStyle.Background.BrightBlack
        InLinePrediction = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack
    }
}
Set-PSReadLineOption @PSROptions
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine

## Add argument completer for the dotnet CLI tool
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

Function search-duckduckgo {
	$query = 'https://ddg.gg/?q='
	$args | % { $query = $query + "$_+" }
	$url = $query.Substring(0, $query.Length - 1)
	start "$url"
}
Set-Alias ddg search-duckduckgo

## Quick navigation

function .. { Set-Location .. }
function ... { Set-Location ..\\.. }
function Edit-Profile {
	if ($IsWindows) {
		#edit $PROFILE
		micro $PROFILE
	} else {
		nano $PROFILE
	}
}
function Go-Dev {
	if ($IsWindows) {
		Set-Location "D:\Repos"
	} else {
		Set-Location "$HOME/"
	}
}
Set-Alias godev Go-Dev

## Common Tools

Set-Alias -Name cls -Value Clear-Host

function Flat-Me {
    <#
    .SYNOPSIS
        Converts a file to UTF-8 (No BOM) with LF line endings.
        Compatible with PS 5.1 and PS 7.
    #>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Path
    )

    process {
        # Resolve path to handle relative links
        $fullPath = (Resolve-Path $Path).Path
        
        # Use .NET to read all text safely across versions
        $content = [System.IO.File]::ReadAllText($fullPath)
        
        # Replace Windows CRLF (`r`n) with Unix LF (`n)
        $flattenedContent = $content -replace "`r`n", "`n"

        if ($PSVersionTable.PSVersion.Major -ge 7) {
            # In PS 7, 'utf8' is No-BOM by default
            Set-Content -Path $fullPath -Value $flattenedContent -Encoding utf8 -NoNewline
        } else {
            # In PS 5.1, we must use .NET to suppress the BOM
            # The 'false' argument in the constructor specifies 'No BOM'
            $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($fullPath, $flattenedContent, $Utf8NoBom)
        }

        Write-Host "Flattened (Universal): $fullPath" -ForegroundColor Cyan
    }
}

Set-Alias -Name flatme -Value Flat-Me

function Clip-It {
    <#
    .SYNOPSIS
        Sends a string or pipeline object to the clipboard as plain text.
        Works in PS 5.1 and PS 7 (Windows/Linux/macOS).
    #>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string]$InputObject
    )

    process {
        try {
            # Set-Clipboard is built into PS 5.1 and PS 7.
            # We cast to [string] to ensure no rich-text formatting is carried over.
            Set-Clipboard -Value ([string]$InputObject)
            Write-Host "Sent to clipboard." -ForegroundColor Gray
        }
        catch {
            Write-Error "Failed to set clipboard. Ensure your environment supports clipboard operations."
        }
    }
}

Set-Alias -Name clipit -Value Clip-It

function touch {
	<#
	.SYNOPSIS
		Mimics the Linux 'touch' command.
	.DESCRIPTION
		If the file exists, updates its last access/write time.
		If the file does not exist, creates an empty file.
	#>
	param(
		[Parameter(Mandatory=$True)]
		[string]$Path
	)

	if (Test-Path $Path) {
		# Update timestamp if file exists
		(Get-Item $Path).LastWriteTime = Get-Date		
	} else {
		# Create empty file if it doesn't exist
		New-Item -Path $Path -ItemType File | Out-Null
	}
}

## Environment

# Calculate admin status once at startup to keep the prompt snappy
$global:IsElevated = if ($IsWindows) {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($currentIdentity)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} else {
    $env:USER -eq 'root'
}

function prompt {
    # Cross-platform Username & Hostname
    $user = if ($IsWindows) { $env:USERNAME } else { $env:USER }
    $computer = if ($IsWindows) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    
    $userColor = if ($global:IsElevated) { "Red" } else { "Green" }
    $path = $ExecutionContext.SessionState.Path.CurrentLocation

    Write-Host "[$computer] " -NoNewline -ForegroundColor Cyan
    Write-Host "$user " -NoNewline -ForegroundColor $userColor
    Write-Host "in " -NoNewline
    Write-Host "$path" -ForegroundColor Yellow
    
    return "> "
}

function Go-Administrator {
    <#
    .SYNOPSIS
        Starts a new elevated PowerShell 7 session.
    #>
    # Capture the current directory so the new window opens in the same spot
    $currentDir = Get-Location
    
    # Start-Process with 'RunAs' triggers the UAC prompt
    # -NoExit ensures the new window stays open
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "Set-Location '$currentDir'" -Verb RunAs
}

Set-Alias -Name goadmin -Value Go-Administrator
##Aliasses

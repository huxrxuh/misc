# Powershell Profiles

Powershell reserves the variable `$PROFILE` to indicate the current host.

To check if a profile exists use:

```Powershell
Test-Path -Path $profile
```

Create the profile if it doesn't exists:

```Powershell
if (!(Test-Path -Path $PROFILE)) { New-Item -Type File -Path $PROFILE -Force }
```

The `-Force` parameter ensures that the necessary directories are created if they are missing.

Open the profile for editing:

```Powershell
start notepad++ $PROFILE
```

# Define Functions

Add a function to start a duckduckgo search:

```Powershell
Function search-duckduckgo {
	$query = 'https://www.ddg.gg/?q='
	$args | % { $query = $query + "$_+" }
	$url = $query.Substring(0, $query.Length -1)
	start "$url"
}

Set-Alias ddg search-duckduckgo
```

Restart the session for changes to apply.

# Check if current session has admin privileges

```Powershell
net session >$null 2>&1; if ($LASTEXITCODE -eq 0) { "Admin session" } else { "Not an admin session" }
```

It relies in the system error codes when a non-admin command is attempted.

Pure Powershell:

```Powershell
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

# Start admin session

```Powershell
Start-Process pwsh -Verb RunAs -Args "-NoExit -Command cd '$PWD'"
```

Using alias `Args` for `ArgumentList`, and `pwsh` for Powershell 7.



# Start SSH Passwordless

In windows you need to add your key:

```Powershell
Start-Service ssh-agent

# Add the key
ssh-add "$HOME\.ssh\id_ed25519"
```

If the service is not started:

```Powershell
# Set the service to automatic

Set-Service -Name ssh-agent -StartupType Automatic

# Now start the service
Start-Service -Name ssh-agent

# Verify the service is running
Get-Service ssh-agent
```

## Handle multiple keys

Git needs to know which one to use:

```Powershell Title = "config"
notepad "$HOME\.ssh\config"
```

Add this configuration

```text
Host github.com
	HostName github.com
	User git
	IdentityFile C:\Users\Username\.ssh\id_ed25519
```

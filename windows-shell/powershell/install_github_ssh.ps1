#!/usr/bin/env pwsh

# Script to set up SSH keys for GitHub on Windows
param(
    [string]$email = "",
    [string]$keyName = "id_ed25519",
    [switch]$noPrompt = $false
)

# Ask for email if not provided
if ([string]::IsNullOrEmpty($email)) {
    $email = Read-Host "Enter your GitHub email address"
}

# Check if Git is installed
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Git is not installed. Please install Git before continuing." -ForegroundColor Red
    exit 1
}

# Create .ssh directory if it doesn't exist
$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
    Write-Host "Created .ssh directory at $sshDir" -ForegroundColor Green
}

# Check if key already exists
$keyPath = "$sshDir\$keyName"
if (Test-Path $keyPath) {
    if (!$noPrompt) {
        $confirmation = Read-Host "An SSH key already exists at $keyPath. Do you want to overwrite it? (y/n)"
        if ($confirmation -ne 'y') {
            Write-Host "Operation cancelled. Using existing key." -ForegroundColor Yellow
            $useExisting = $true
        }
    } else {
        Write-Host "Using existing SSH key at $keyPath" -ForegroundColor Yellow
        $useExisting = $true
    }
}

# Generate new SSH key if needed
if (!$useExisting) {
    Write-Host "Generating new SSH key..." -ForegroundColor Blue
    ssh-keygen -t ed25519 -C $email -f $keyPath -N '""'
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to generate SSH key." -ForegroundColor Red
        exit 1
    }
    Write-Host "SSH key generated successfully!" -ForegroundColor Green
}

# Start SSH agent if not running
$sshAgentRunning = Get-Process ssh-agent -ErrorAction SilentlyContinue
if (!$sshAgentRunning) {
    Write-Host "Starting SSH agent..." -ForegroundColor Blue
    
    # Try to start the SSH agent using the direct command method first
    $sshAgentOutput = & cmd /c "ssh-agent -s" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        # Parse and set environment variables from ssh-agent output
        $sshAgentOutput | ForEach-Object {
            if ($_ -match '([A-Z_]+)=([^;]+);') {
                [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
                Write-Host "Set $($matches[1]) to $($matches[2])" -ForegroundColor Green
            }
        }
        
        Write-Host "SSH agent started successfully using command method" -ForegroundColor Green
    } else {
        # If command method fails, try the service method as fallback
        try {
            Start-Service ssh-agent -ErrorAction Stop
            Write-Host "SSH agent service started successfully" -ForegroundColor Green
        } catch {
            Write-Host "Warning: Could not start SSH agent service: $_" -ForegroundColor Yellow
            Write-Host "You may need to enable and start the SSH agent service manually." -ForegroundColor Yellow
            
            # Give instructions for enabling SSH agent service
            Write-Host "`nTo enable the SSH agent service, run these commands as administrator:" -ForegroundColor Cyan
            Write-Host "Get-Service ssh-agent | Set-Service -StartupType Automatic" -ForegroundColor White
            Write-Host "Start-Service ssh-agent" -ForegroundColor White
            
            # Continue anyway - ssh-add might still work if the agent is running otherwise
        }
    }
}

# Add key to SSH agent
Write-Host "Adding key to SSH agent..." -ForegroundColor Blue
ssh-add $keyPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to add key to SSH agent. SSH agent might not be running correctly." -ForegroundColor Red
    Write-Host "You may need to manually add the key later with: ssh-add $keyPath" -ForegroundColor Yellow
    # Don't exit, continue with the rest of the script
}

# Copy public key to clipboard
$publicKey = Get-Content "$keyPath.pub"
Set-Clipboard -Value $publicKey
Write-Host "Your public SSH key has been copied to clipboard!" -ForegroundColor Green

# Instructions for adding key to GitHub
Write-Host "`nFollow these steps to add your SSH key to GitHub:" -ForegroundColor Cyan
Write-Host "1. Log in to GitHub" -ForegroundColor White
Write-Host "2. Click on your profile picture in the top right, then click 'Settings'" -ForegroundColor White
Write-Host "3. In the left sidebar, click 'SSH and GPG keys'" -ForegroundColor White
Write-Host "4. Click 'New SSH key'" -ForegroundColor White
Write-Host "5. Give your key a title (e.g., 'Work Laptop')" -ForegroundColor White
Write-Host "6. The key is already in your clipboard, just paste it in the 'Key' field" -ForegroundColor White
Write-Host "7. Click 'Add SSH key'" -ForegroundColor White

Write-Host "`nTest your connection by running:" -ForegroundColor Yellow
Write-Host "ssh -T git@github.com" -ForegroundColor White

Write-Host "`nSSH key setup completed successfully!" -ForegroundColor Green 
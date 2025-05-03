# Install JDK PowerShell Script
# This script downloads and installs OpenJDK with support for multiple versions

param (
    [string]$Version = "17.0.8",
    [string]$InstallPath = "C:\Program Files\Java",
    [switch]$SetDefault,
    [switch]$ShowVersions,
    [switch]$ListInstalled,
    [string]$Vendor = "Eclipse Temurin",
    [switch]$Help,
    [switch]$List
)

# Available JDK vendors
$JDKVendors = @("Eclipse Temurin", "Amazon Corretto")

# Available JDK versions and their download URLs
$JDKVersions = @{
    # Eclipse Temurin versions
    "Eclipse Temurin" = @{
        "8.0.392" = @{
            VersionTag = "8u392-b08"
            URL = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u392b08.msi"
            FolderName = "jdk8u392-b08"
        }
        "11.0.21" = @{
            VersionTag = "11.0.21+9"
            URL = "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.21_9.msi"
            FolderName = "jdk-11.0.21+9"
        }
        "17.0.8" = @{
            VersionTag = "17.0.8+7"
            URL = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.8_7.msi"
            FolderName = "jdk-17.0.8+7"
        }
        "17.0.9" = @{
            VersionTag = "17.0.9+9"
            URL = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_windows_hotspot_17.0.9_9.msi"
            FolderName = "jdk-17.0.9+9"
        }
        "21.0.1" = @{
            VersionTag = "21.0.1+12"
            URL = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1%2B12/OpenJDK21U-jdk_x64_windows_hotspot_21.0.1_12.msi"
            FolderName = "jdk-21.0.1+12"
        }
    }
    
    # Amazon Corretto versions
    "Amazon Corretto" = @{
        "8.392.08.1" = @{
            VersionTag = "8.392.08.1"
            URL = "https://corretto.aws/downloads/resources/8.392.08.1/amazon-corretto-8.392.08.1-windows-x64-jdk.msi"
            FolderName = "jdk1.8.0_392"
        }
        "11.0.21.9.1" = @{
            VersionTag = "11.0.21.9.1"
            URL = "https://corretto.aws/downloads/resources/11.0.21.9.1/amazon-corretto-11.0.21.9.1-windows-x64-jdk.msi"
            FolderName = "jdk11.0.21_9"
        }
        "17.0.9.8.1" = @{
            VersionTag = "17.0.9.8.1"
            URL = "https://corretto.aws/downloads/resources/17.0.9.8.1/amazon-corretto-17.0.9.8.1-windows-x64-jdk.msi"
            FolderName = "jdk17.0.9_8"
        }
        "21.0.1.12.1" = @{
            VersionTag = "21.0.1.12.1"
            URL = "https://corretto.aws/downloads/resources/21.0.1.12.1/amazon-corretto-21.0.1.12.1-windows-x64-jdk.msi"
            FolderName = "jdk21.0.1_12"
        }
    }
}

# Function to display help information
function Show-Help {
    Write-Host "JDK Installation Script Help" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host "Description:" -ForegroundColor Yellow
    Write-Host "  This script downloads and installs OpenJDK with support for multiple versions and vendors."
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -Version <version>      : Specify the JDK version to install (default: 17.0.8)"
    Write-Host "  -InstallPath <path>     : Specify the installation directory (default: C:\Program Files\Java)"
    Write-Host "  -SetDefault            : Set the installed JDK as the default Java environment"
    Write-Host "  -ShowVersions          : Display all available JDK versions"
    Write-Host "  -ListInstalled         : List all installed JDK versions"
    Write-Host "  -Vendor <vendor>        : Specify the JDK vendor (default: Eclipse Temurin)"
    Write-Host "  -Help                  : Display this help information"
    Write-Host "  -List                  : Show available vendors and versions"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\install_jdk.ps1 -Version 11.0.21 -Vendor 'Eclipse Temurin'"
    Write-Host "  .\install_jdk.ps1 -Version 17.0.9.8.1 -Vendor 'Amazon Corretto'"
    Write-Host "  .\install_jdk.ps1 -Version 8.392.08.1 -Vendor 'Amazon Corretto' -SetDefault:`$false"
    Write-Host "  .\install_jdk.ps1 -ShowVersions"
    Write-Host "  .\install_jdk.ps1 -ListInstalled"
    Write-Host "  .\install_jdk.ps1 -InstallPath 'D:\Java' -Version 21.0.1 -Vendor 'Eclipse Temurin'"
    Write-Host "  .\install_jdk.ps1 -Help"
    Write-Host "  .\install_jdk.ps1 -List"
}

# Function to display available versions
function Show-AvailableVersions {
    Write-Host "Available JDK Vendors and Versions:" -ForegroundColor Cyan
    foreach ($vendorName in $JDKVendors) {
        Write-Host "`n${vendorName}:" -ForegroundColor Green
        foreach ($key in $JDKVersions[$vendorName].Keys | Sort-Object) {
            $versionTag = $JDKVersions[$vendorName][$key].VersionTag
            Write-Host "  - $key ($versionTag)"
        }
    }
}

# Function to list installed JDK versions
function Get-InstalledJDKs {
    $installedJDKs = @()
    
    # Check common Java installation directories
    $javaFolders = @(
        "C:\Program Files\Java",
        "C:\Program Files (x86)\Java",
        "C:\Program Files\Amazon Corretto",
        $InstallPath
    ) | Select-Object -Unique
    
    foreach ($folder in $javaFolders) {
        if (Test-Path $folder) {
            Get-ChildItem $folder -Directory | ForEach-Object {
                $jdkPath = $_.FullName
                $javaExe = Join-Path $jdkPath "bin\java.exe"
                
                if (Test-Path $javaExe) {
                    $version = & $javaExe -version 2>&1
                    $versionString = $version | Out-String
                    
                    # Detect vendor
                    $vendorName = "Unknown"
                    if ($versionString -match "Corretto") {
                        $vendorName = "Amazon Corretto"
                    }
                    elseif ($versionString -match "Temurin") {
                        $vendorName = "Eclipse Temurin"
                    }
                    
                    $isDefault = $false
                    $javaHomePath = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", [System.EnvironmentVariableTarget]::Machine)
                    if ($javaHomePath -eq $jdkPath) {
                        $isDefault = $true
                    }
                    
                    $installedJDKs += [PSCustomObject]@{
                        Path = $jdkPath
                        Version = $versionString.Trim()
                        Vendor = $vendorName
                        IsDefault = $isDefault
                    }
                }
            }
        }
    }
    
    return $installedJDKs
}

# Function to display installed JDK versions
function Show-InstalledJDKs {
    $installedJDKs = Get-InstalledJDKs
    
    if ($installedJDKs.Count -eq 0) {
        Write-Host "No JDK installations found." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Installed JDK Versions:" -ForegroundColor Cyan
    foreach ($jdk in $installedJDKs) {
        $defaultMark = if ($jdk.IsDefault) { " [DEFAULT]" } else { "" }
        Write-Host "  - $($jdk.Path)$defaultMark" -ForegroundColor Green
        Write-Host "    Vendor: $($jdk.Vendor)"
        Write-Host "    $($jdk.Version)"
    }
}

# Function to check if a specific JDK version is already installed
function Test-JDKInstalled {
    param (
        [string]$Version,
        [string]$InstallPath,
        [string]$Vendor
    )
    
    $installedJDKs = Get-InstalledJDKs
    
    # Check if version is supported for this vendor
    if (-not $JDKVersions[$Vendor] -or -not $JDKVersions[$Vendor][$Version]) {
        return $false
    }
    
    $versionInfo = $JDKVersions[$Vendor][$Version]
    $specificPath = Join-Path $InstallPath $versionInfo.FolderName
    
    foreach ($jdk in $installedJDKs) {
        if ($jdk.Path -eq $specificPath) {
            Write-Host "$Vendor JDK $Version is already installed at: $specificPath" -ForegroundColor Yellow
            return $true
        }
    }
    
    return $false
}

# Function to download and install JDK
function Install-JDK {
    param (
        [string]$Version,
        [string]$InstallPath,
        [switch]$SetDefault,
        [string]$Vendor
    )
    
    # Check if vendor is supported
    if (-not $JDKVendors -contains $Vendor) {
        Write-Host "Error: JDK vendor $Vendor is not supported by this script." -ForegroundColor Red
        Write-Host "Supported vendors are: $($JDKVendors -join ', ')" -ForegroundColor Yellow
        return $false
    }
    
    # Check if version is supported for this vendor
    if (-not $JDKVersions[$Vendor] -or -not $JDKVersions[$Vendor][$Version]) {
        Write-Host "Error: JDK version $Version for vendor $Vendor is not supported by this script." -ForegroundColor Red
        Write-Host "Use the -ShowVersions parameter to see available versions." -ForegroundColor Yellow
        return $false
    }
    
    $versionInfo = $JDKVersions[$Vendor][$Version]
    $vendorFolderName = if ($Vendor -eq "Amazon Corretto") { "Amazon Corretto" } else { "Java" }
    $InstallPath = "$InstallPath\$vendorFolderName"
    
    $specificInstallPath = Join-Path $InstallPath $versionInfo.FolderName
    
    # Create install directory if it doesn't exist
    if (!(Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # Check if this version is already installed
    if (Test-JDKInstalled -Version $Version -InstallPath $InstallPath -Vendor $Vendor) {
        $response = Read-Host "This JDK version appears to be already installed. Do you want to reinstall? (y/n)"
        if ($response -ne "y") {
            # If not reinstalling but setting as default
            if ($SetDefault) {
                Set-JavaHome -Path $specificInstallPath
            }
            return $true
        }
    }
    
    # Create temp directory for download
    $tempDir = Join-Path $env:TEMP "jdk-install"
    if (!(Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }
    
    # Download JDK
    $filename = "$Vendor-$Version.msi"
    $downloadUrl = $versionInfo.URL
    $outFile = Join-Path $tempDir $filename
    
    Write-Host "Downloading $Vendor JDK $Version from $downloadUrl..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outFile
    }
    catch {
        Write-Host "Error downloading JDK: $_" -ForegroundColor Red
        return $false
    }
    
    # Install JDK
    Write-Host "Installing $Vendor JDK $Version to $specificInstallPath..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $outFile, "INSTALLDIR=`"$specificInstallPath`"", "/quiet", "/norestart" -Wait
        Write-Host "$Vendor JDK $Version installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error installing JDK: $_" -ForegroundColor Red
        return $false
    }
    
    # Set JAVA_HOME environment variable if requested
    if ($SetDefault) {
        Set-JavaHome -Path $specificInstallPath
    }
    
    # Clean up
    Remove-Item -Path $outFile -Force
    return $true
}

# Function to set JAVA_HOME and update PATH
function Set-JavaHome {
    param (
        [string]$Path
    )
    
    # Set JAVA_HOME environment variable
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $Path, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Set JAVA_HOME to: $Path" -ForegroundColor Green
    
    # Add Java to PATH if not already there
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $binPath = Join-Path $Path "bin"
    if ($currentPath -notlike "*$binPath*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Added Java to system PATH" -ForegroundColor Green
    }
}

# Main script
Write-Host "JDK Installation Script" -ForegroundColor Cyan


# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    exit
}

# If no parameters are provided, show help
if ($MyInvocation.BoundParameters.Count -eq 0 -and $args.Count -eq 0) {
    Show-Help
    # Ask user if they want to install with default values
    $installDefault = Read-Host "Would you like to install JDK with default values? (Y/N)"
    if ($installDefault -eq "N" -or $installDefault -eq "n") {
        exit
    }
}

# Show help if requested
if ($Help) {
    Show-Help
    exit
}

# Show available versions if requested
if ($ShowVersions -or $List) {
    Show-AvailableVersions
    exit
}

# List installed JDKs if requested
if ($ListInstalled) {
    Show-InstalledJDKs
    exit
}

# Install JDK
$versionInfo = $JDKVersions[$Vendor][$Version]
Write-Host "Installing JDK $Vendor $Version from $($versionInfo.URL) to $InstallPath..." -ForegroundColor Cyan
$success = Install-JDK -Version $Version -InstallPath $InstallPath -SetDefault:$SetDefault -Vendor $Vendor

if ($success) {
    Write-Host "Verifying installation..." -ForegroundColor Cyan
    if ($SetDefault) {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        try {
            $javaVersion = java -version 2>&1
            Write-Host "Java version information:" -ForegroundColor Green
            Write-Host $javaVersion
        } catch {
            Write-Host "Could not verify java installation. You may need to restart your terminal." -ForegroundColor Yellow
        }
        Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
    }
    Write-Host "Installation completed successfully!" -ForegroundColor Green
}
else {
    Write-Host "Installation failed." -ForegroundColor Red
}

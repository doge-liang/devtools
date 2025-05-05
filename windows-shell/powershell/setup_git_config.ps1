# Get proxy settings from environment variables or prompt user
param(
    [Parameter(Mandatory=$false)]
    [string]$httpProxy = $env:http_proxy,
    
    [Parameter(Mandatory=$false)] 
    [string]$httpsProxy = $env:https_proxy
)

if (-not $httpProxy) {
    $httpProxy = Read-Host "Enter HTTP proxy (e.g. http://proxy.example.com:8080)"
}

if (-not $httpsProxy) {
    $httpsProxy = Read-Host "Enter HTTPS proxy (e.g. http://proxy.example.com:8080)"
}

# Configure git to use proxy
Write-Host "Setting git proxy configuration..."

# Set http proxy
git config --global http.proxy $httpProxy
if ($LASTEXITCODE -eq 0) {
    Write-Host "HTTP proxy configured successfully"
} else {
    Write-Host "Failed to configure HTTP proxy" -ForegroundColor Red
}

# Set https proxy
git config --global https.proxy $httpsProxy
if ($LASTEXITCODE -eq 0) {
    Write-Host "HTTPS proxy configured successfully"
} else {
    Write-Host "Failed to configure HTTPS proxy" -ForegroundColor Red
}

git config --global user.name "doge-liang"
git config --global user.email "liangsycmail@gmail.com"

Write-Host "`nCurrent git proxy settings:"
git config --global --get http.proxy
git config --global --get https.proxy

Write-Host "`nTo remove proxy settings later, use:"
Write-Host "git config --global --unset http.proxy"
Write-Host "git config --global --unset https.proxy"
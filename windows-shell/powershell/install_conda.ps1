# 设置控制台输出编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
# 尝试设置代码页（可能需要管理员权限）
try { chcp 65001 | Out-Null } catch { Write-Host "无法设置代码页，可能需要管理员权限" }

# 下载最新Miniconda3 Windows安装包
$miniconda_url = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
$installer = "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"

Write-Host "正在下载Miniconda安装包..."
Invoke-WebRequest -Uri $miniconda_url -OutFile $installer

# 安装路径（可自定义）
$install_path = "$env:USERPROFILE\Miniconda3"

Write-Host "正在静默安装Miniconda..."
Start-Process -Wait -FilePath $installer -ArgumentList "/InstallationType=JustMe", "/AddToPath=1", "/RegisterPython=1", "/S", "/D=$install_path"

# 初始化conda
$conda_bat = "$install_path\Scripts\conda.exe"
if (Test-Path $conda_bat) {
    Write-Host "正在初始化conda..."
    & "$conda_bat" init powershell
    Write-Host "Conda安装并初始化完成，请重启PowerShell窗口。"
} else {
    Write-Host "Conda安装失败，请检查安装日志。"
}

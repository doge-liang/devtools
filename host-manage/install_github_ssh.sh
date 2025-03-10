#!/bin/bash

# 配置GitHub SSH并设置ssh-config
# 支持多仓库多密钥管理

# 输入参数处理
read -p "📦 请输入GitHub仓库地址（支持SSH/HTTPS格式）: " REPO_URL
read -p "🔑 输入密钥名称（默认：github_ed25519）: " KEY_NAME
KEY_NAME=${KEY_NAME:-github_ed25519}
KEY_PATH="$HOME/.ssh/${KEY_NAME}"

# 转换URL为SSH格式
if [[ $REPO_URL == https://github.com/* ]]; then
    REPO_URL="git@github.com:${REPO_URL#https://github.com/}"
    REPO_URL="${REPO_URL%.git}.git"
elif [[ $REPO_URL == git@github.com:* ]]; then
    REPO_URL="${REPO_URL}"
else
    echo "❌ 不支持的仓库地址格式"
    exit 1
fi

# 提取主机名
HOSTNAME=$(echo "$REPO_URL" | awk -F@ '{print $2}' | awk -F: '{print $1}')
echo "🔍 检测到主机名：$HOSTNAME"

# 生成密钥
if [ ! -f "${KEY_PATH}" ]; then
    echo "🔑 生成新的ED25519密钥..."
    ssh-keygen -t ed25519 -f "${KEY_PATH}" -C "${KEY_NAME}-$(date +%Y%m%d)" -N ""
    chmod 600 "${KEY_PATH}"
else
    echo "⚠️ 使用现有密钥：${KEY_PATH}"
fi

# 显示公钥
echo -e "\n📋 公钥内容："
cat "${KEY_PATH}.pub"

# 自动复制到剪贴板
if command -v pbcopy >/dev/null; then
    cat "${KEY_PATH}.pub" | pbcopy
    echo "✅ 已复制到剪贴板（macOS）"
elif command -v xclip >/dev/null; then
    cat "${KEY_PATH}.pub" | xclip -selection clipboard
    echo "✅ 已复制到剪贴板（Linux）"
fi

# 打开浏览器添加密钥
xdg-open "https://github.com/settings/keys" &> /dev/null || open "https://github.com/settings/keys" &> /dev/null

read -p "⏳ 请确保已添加公钥到GitHub，按回车继续..."

# 配置SSH config
CONFIG_FILE="$HOME/.ssh/config"
mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

if ! grep -q "Host $HOSTNAME" "$CONFIG_FILE"; then
    echo -e "\n# GitHub自动配置 - $(date)" >> "$CONFIG_FILE"
    echo "Host $HOSTNAME" >> "$CONFIG_FILE"
    echo "    HostName $HOSTNAME" >> "$CONFIG_FILE"
    echo "    User git" >> "$CONFIG_FILE"
    echo "    IdentityFile ${KEY_PATH}" >> "$CONFIG_FILE"
    echo "    IdentitiesOnly yes" >> "$CONFIG_FILE"
    echo "    LogLevel ERROR" >> "$CONFIG_FILE"
    echo "✅ 已更新SSH配置文件：$CONFIG_FILE"
else
    echo "⚠️ 主机配置已存在，跳过写入"
fi

# 测试连接
echo -e "\n🔗 测试SSH连接..."
ssh -T -i "${KEY_PATH}" "git@${HOSTNAME}" 2>&1 | grep -v "failed"

echo -e "\n🚀 现在可以使用以下命令克隆仓库："
echo "git clone ${REPO_URL}"
echo -e "\n💡 后续操作建议："
echo "1. 其他仓库使用相同主机时无需重复配置"
echo "2. 不同账号需要创建不同密钥并配置对应Host"


#!/bin/bash

# 配置Git用户信息
echo -e "\n👤 配置Git用户信息..."
if ! read -t 30 -p "请输入GitHub用户名: " GIT_NAME; then
    echo -e "\n❌ 输入超时"
    exit 1
fi
if ! read -t 30 -p "请输入GitHub邮箱: " GIT_EMAIL; then
    echo -e "\n❌ 输入超时" 
    exit 1
fi
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "✅ 已配置Git用户名: $GIT_NAME"
echo "✅ 已配置Git邮箱: $GIT_EMAIL"
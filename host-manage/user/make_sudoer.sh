#!/bin/bash

# 获取当前用户
current_user=$(whoami)

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 显示使用方法
usage() {
    echo "使用方法: $0 -u <用户名>"
    echo "选项:"
    echo "  -u    用户名"
    exit 1
}

# 解析命令行参数
while getopts "u:" opt; do
    case $opt in
        u) username="$OPTARG";;
        ?) usage;;
    esac
done

# 检查必需参数
if [ -z "$username" ]; then
    echo "错误: 用户名是必需的"
    usage
fi

# 检查用户是否存在
if ! id "$username" &>/dev/null; then
    echo "错误: 用户 '$username' 不存在"
    exit 1
fi

# 将用户添加到sudo组
usermod -aG sudo "$username"

# 检查是否添加成功
if groups "$username" | grep -q "\bsudo\b"; then
    echo "用户 '$username' 已成功添加到sudo组"
else
    echo "错误: 将用户添加到sudo组失败"
    exit 1
fi 
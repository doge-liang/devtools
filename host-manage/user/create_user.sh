#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 显示使用方法
usage() {
    echo "使用方法: $0 -u <用户名> -p <密码> [-g <用户组>]"
    echo "选项:"
    echo "  -u    用户名"
    echo "  -p    密码"
    echo "  -g    用户组 (可选)"
    exit 1
}

# 解析命令行参数
while getopts "u:p:g:" opt; do
    case $opt in
        u) username="$OPTARG";;
        p) password="$OPTARG";;
        g) group="$OPTARG";;
        ?) usage;;
    esac
done

# 检查必需参数
if [ -z "$username" ] || [ -z "$password" ]; then
    echo "错误: 用户名和密码是必需的"
    usage
fi

# 检查用户是否已存在
if id "$username" &>/dev/null; then
    echo "错误: 用户 '$username' 已存在"
    exit 1
fi

# 创建用户
if [ -n "$group" ]; then
    # 如果指定了用户组，先检查组是否存在
    if ! getent group "$group" &>/dev/null; then
        echo "创建用户组 '$group'"
        groupadd "$group"
    fi
    useradd -m -g "$group" "$username"
else
    useradd -m "$username"
fi

# 设置密码
echo "$username:$password" | chpasswd

# 检查用户是否创建成功
if id "$username" &>/dev/null; then
    echo "用户 '$username' 创建成功"
    if [ -n "$group" ]; then
        echo "用户组: $group"
    fi
else
    echo "错误: 用户创建失败"
    exit 1
fi



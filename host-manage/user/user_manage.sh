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
    echo "使用方法: $0 -a <操作> -u <用户名> -p <密码> [-g <用户组>]"
    echo "选项:"
    echo "  -a    操作类型 (create, make_sudoer)"
    echo "  -u    用户名"
    echo "  -p    密码"
    echo "  -g    用户组 (可选)"
    exit 1
}

# 解析命令行参数
while getopts "a:u:p:g:" opt; do
    case $opt in
        a) action="$OPTARG";;
        u) username="$OPTARG";;
        p) password="$OPTARG";;
        g) group="$OPTARG";;
        ?) usage;;
    esac
done

# 检查必需参数
if [ -z "$action" ] || [ -z "$username" ] || [ -z "$password" ]; then
    echo "错误: 操作类型、用户名和密码是必需的"
    usage
fi

# 根据操作类型执行相应的脚本
case "$action" in
    "create")
        # 构建create_user.sh的参数
        create_args="-u $username -p $password"
        if [ -n "$group" ]; then
            create_args="$create_args -g $group"
        fi
        
        # 执行create_user.sh脚本
        $(dirname "$0")/create_user.sh $create_args
        ;;
    "make_sudoer")
        # 执行make_sudoer.sh脚本
        $(dirname "$0")/make_sudoer.sh -u "$username"
        ;;
    *)
        echo "错误: 不支持的操作类型 '$action'"
        usage
        ;;
esac

#!/bin/bash

# 创建 /etc/xbps.d 目录（如果不存在）
mkdir -p /etc/xbps.d

# 复制默认的 repository 配置文件
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/

# 替换默认的 Void Linux 仓库 URL 为清华大学的镜像
sed -i 's|https://repo-default.voidlinux.org|https://mirrors.tuna.tsinghua.edu.cn/voidlinux|g' /etc/xbps.d/*-repository-*.conf
echo "Repository URLs have been updated to Tsinghua University mirrors."



#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 修改版本为编译日期，数字类型。
date_version=$(date +"%Y%m%d%H")
echo $date_version > version

# 为iStoreOS固件版本加上编译作者
author="cc"
sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V ${date_version} by ${author}'/g" package/base-files/files/etc/openwrt_release
sed -i "s/OPENWRT_RELEASE.*/OPENWRT_RELEASE=\"%D %V ${date_version} by ${author}\"/g" package/base-files/files/usr/lib/os-release

# 拉取我的软件包仓库
#echo 'src-git xmpackages https://github.com/xiaomeng9597/openwrt-packages2.git;main' >> feeds.conf.default

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

echo 'src-git openclash https://github.com/vernesong/OpenClash' >>feeds.conf.default
echo 'src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome' >>feeds.conf.default
# echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns' >>feeds.conf.default

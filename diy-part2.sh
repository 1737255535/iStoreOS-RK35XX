#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 接收设备名称参数（从 workflow 传入）
BOARD_NAME="${1:-panther_x2}"

# enable rk3568 model adc keys
cp -f $GITHUB_WORKSPACE/configfiles/adc-keys.txt adc-keys.txt
! grep -q 'adc-keys {' package/boot/uboot-rk35xx/src/arch/arm/dts/rk3568-easepi.dts && sed -i '/\"rockchip,rk3568\";/r adc-keys.txt' package/boot/uboot-rk35xx/src/arch/arm/dts/rk3568-easepi.dts

# update ubus git HEAD
cp -f $GITHUB_WORKSPACE/configfiles/ubus_Makefile package/system/ubus/Makefile

# 近期istoreos网站文件服务器不稳定，临时增加一个自定义下载网址
sed -i "s/push @mirrors, 'https:\/\/mirror2.openwrt.org\/sources';/&\\npush @mirrors, 'https:\/\/github.com\/xiaomeng9597\/files\/releases\/download\/iStoreosFile';/g" scripts/download.pl


# 修改内核配置文件
sed -i "/.*CONFIG_ROCKCHIP_RGA2.*/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/# CONFIG_ROCKCHIP_RGA2 is not set/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_DEBUGGER=y/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_DEBUG_FS=y/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_PROC_FS=y/d" target/linux/rockchip/rk35xx/config-5.10

# 修改openwrt登陆地址,把下面的 192.168.10.1 修改成你想要的就可以了
#sed -i 's/192.168.100.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名字，把 iStore OS 修改你喜欢的就行（不能纯数字或者使用中文）
# sed -i 's/OpenWrt/iStore OS/g' package/base-files/files/bin/config_generate

# ttyd 自动登录
# sed -i "s?/bin/login?/usr/libexec/login.sh?g" ${GITHUB_WORKSPACE}/openwrt/package/feeds/packages/ttyd/files/ttyd.config

# 添加自定义软件包
echo '
CONFIG_PACKAGE_luci-app-mosdns=y
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-openclash=y
' >> .config



# 修改uhttpd配置文件，启用nginx
# sed -i "/.*uhttpd.*/d" .config
# sed -i '/.*\/etc\/init.d.*/d' package/network/services/uhttpd/Makefile
# sed -i '/.*.\/files\/uhttpd.init.*/d' package/network/services/uhttpd/Makefile
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config
cp -a $GITHUB_WORKSPACE/configfiles/etc/* package/base-files/files/etc/
# ls package/base-files/files/etc/



# 轮询检查ubus服务是否崩溃，崩溃就重启ubus服务，只针对rk3566机型，如黑豹X2和荐片TV盒子。
cp -f $GITHUB_WORKSPACE/configfiles/httpubus package/base-files/files/etc/init.d/httpubus
cp -f $GITHUB_WORKSPACE/configfiles/ubus-examine.sh package/base-files/files/bin/ubus-examine.sh
chmod 755 package/base-files/files/etc/init.d/httpubus
chmod 755 package/base-files/files/bin/ubus-examine.sh



# 集成黑豹X2和荐片TV盒子WiFi驱动，默认不启用WiFi
cp -a $GITHUB_WORKSPACE/configfiles/packages/* package/firmware/
cp -f $GITHUB_WORKSPACE/configfiles/opwifi package/base-files/files/etc/init.d/opwifi
chmod 755 package/base-files/files/etc/init.d/opwifi
# sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh



# 集成CPU性能跑分脚本
cp -f $GITHUB_WORKSPACE/configfiles/coremark/coremark-arm64 package/base-files/files/bin/coremark-arm64
cp -f $GITHUB_WORKSPACE/configfiles/coremark/coremark-arm64.sh package/base-files/files/bin/coremark.sh
chmod 755 package/base-files/files/bin/coremark-arm64
chmod 755 package/base-files/files/bin/coremark.sh


# iStoreOS-settings
git clone --depth=1 -b main https://github.com/xiaomeng9597/istoreos-settings package/default-settings


# 定时限速插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus


# 复制dts设备树文件到指定目录下
cp -a $GITHUB_WORKSPACE/configfiles/dts/rk356x/* target/linux/rockchip/dts/rk3568/

# ============================================
# 根据传入的设备名称动态选择编译设备
# ============================================
echo ">>> 编译设备: ${BOARD_NAME}"

# 清除所有 rockchip 设备的选择
sed -i '/CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_/d' .config

# 根据设备名称设置对应的 CONFIG 选项
case "${BOARD_NAME}" in
    panther_x2)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_panther_x2=y' >> .config
        ;;
    jp_tvbox)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_jp_tvbox=y' >> .config
        ;;
    fastrhino_r6xs)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_fastrhino_r6xs=y' >> .config
        ;;
    fastrhino_r66s)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_fastrhino_r66s=y' >> .config
        ;;
    fastrhino_r68s)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_fastrhino_r68s=y' >> .config
        ;;
    firefly_station-p2)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_firefly_station-p2=y' >> .config
        ;;
    friendlyarm_nanopi-r5s)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_friendlyarm_nanopi-r5s=y' >> .config
        ;;
    friendlyarm_nanopi-r6s)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_friendlyarm_nanopi-r6s=y' >> .config
        ;;
    hinlink_h88k)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_hinlink_h88k=y' >> .config
        ;;
    hinlink_opc-h6xk)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_hinlink_opc-h6xk=y' >> .config
        ;;
    dg_nas-lite)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_dg_nas-lite=y' >> .config
        ;;
    ezpro_mrkaio-m68s)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_ezpro_mrkaio-m68s=y' >> .config
        ;;
    ezpro_mrkaio-m68s-plus)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_ezpro_mrkaio-m68s-plus=y' >> .config
        ;;
    dg_tn3568)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_dg_tn3568=y' >> .config
        ;;
    yijiahe_jm10)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_yijiahe_jm10=y' >> .config
        ;;
    xunlong_orangepi-5-plus)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_xunlong_orangepi-5-plus=y' >> .config
        ;;
    lyt_t68m)
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_lyt_t68m=y' >> .config
        ;;
    *)
        echo "未知设备: ${BOARD_NAME}，使用默认 panther_x2"
        echo 'CONFIG_TARGET_DEVICE_rockchip_rk35xx_DEVICE_panther_x2=y' >> .config
        ;;
esac

# 禁止多设备编译（避免产生多个固件）
echo '# CONFIG_TARGET_MULTI_PROFILE is not set' >> .config

# 重新生成默认配置
make defconfig

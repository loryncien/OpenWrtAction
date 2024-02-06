#!/bin/sh
#===============================================
# File name: init-settings.sh
# Description: This script will be executed during the first boot
# the existing UCI defaults scripts in /rom/etc/uci-defaults
# Author: SuLingGG
# Blog: https://mlapp.cn
#===============================================

[ -f '/bin/bash' ] && sed -i "s#/bin/ash#/bin/bash#g" /etc/passwd
# [ -f '/usr/bin/zsh' ] && sed -i "s#/bin/ash#/usr/bin/zsh#g" /etc/passwd

uci -q batch << EOF
# Set default theme to luci-theme-argon
set luci.main.lang=zh_cn
set luci.main.mediaurlbase='/luci-static/argon'

# Check file system during boot
set fstab.@global[0].check_fs=1

# Enable dhcp force
#set dhcp.lan.force='1'

# Disable IPv6 DHCP, ULA
delete dhcp.lan.ra
delete dhcp.lan.ra_management
delete dhcp.lan.dhcpv6
delete dhcp.lan.ndp

# Disable IPV6 ula prefix
delete network.globals.ula_prefix
delete network.wan6

# Enable rebind protection. Filtered DNS service responses from blocked domains are 0.0.0.0 which causes dnsmasq to fill the system log with possible DNS-rebind attack detected messages.
set dhcp.@dnsmasq[0].rebind_protection='1'

# Disable Turboacc for control
set turboacc.config.sfe_flow='0'
set turboacc.config.sw_flow='0'
set turboacc.config.hw_flow='0'

set nlbwmon.@nlbwmon[0].refresh_interval=2s

commit
EOF

sed -i 's/services/nas/g' /usr/lib/lua/luci/view/linkease_status.htm
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/linkease.lua

# samba
TMP_ALL="$(df -h | grep "/tmp" | awk '{print $2}' | awk 'NR==1')"
[ -e /etc/config/samba4 ] && { uci -q batch <<-EOF
 set samba4.@samba[0].homes='0'
 set samba4.@samba[0].macos='0'
 set samba4.@samba[0].disable_netbios='0'
 delete samba4.@sambashare[0]
 add samba4 sambashare
 set samba4.@sambashare[-1].name='upload<$TMP_ALL'
 set samba4.@sambashare[-1].path='/tmp/upload'
 set samba4.@sambashare[-1].browseable='yes'
 set samba4.@sambashare[-1].read_only='no'
 set samba4.@sambashare[-1].guest_ok='yes'
 set samba4.@sambashare[-1].create_mask='0666'
 set samba4.@sambashare[-1].dir_mask='0777'
 commit
EOF
}

# Disable opkg signature check
sed -i 's/^option check_signature/# &/g' /etc/opkg.conf
# Delete the line containing the keyword in distfeeds.conf
sed -i '/passwall\|helloworld\|OpenClash/d' /etc/opkg/distfeeds.conf
sed -i '/kenzo\|small/d' /etc/opkg/distfeeds.conf

# 启动本地内核
[ -d '/www/snapshots' ] && sed -i 's|core.*|core file:///www/snapshots/targets/x86/64/packages|' /etc/opkg/distfeeds.conf

# sirpdboy luci-app-netdata-cn 不能启动
[ -f '/etc/init.d/netdata' ] && chmod +x /etc/init.d/netdata

# delete footer.htm distversion
sed -i '/ver.distversion/d' /usr/lib/lua/luci/view/themes/argon/footer.htm

rm -rf /tmp/luci-modulecache/
rm -f /tmp/luci-indexcache

exit 0

#!/bin/bash

echo "========================="
echo "开始 common 配置……"

## 添加 package
pushd package
#echo "Add Passwall SSRP"
#git clone --depth=1 https://github.com/fw876/helloworld.git
#git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall-packages.git passwall_packages
#git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall.git luci-app-passwall

svn export -q https://github.com/vernesong/OpenClash/trunk/luci-app-openclash

echo "Add luci-app-unblockneteasemusic core"
if [ -d "../feeds/luci/applications/luci-app-unblockneteasemusic" ]; then
  pushd ../feeds/luci/applications/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic
  # uclient-fetch Use IPv4 only
  sed -i 's/uclient-fetch/uclient-fetch -4/g' update.sh
  # unblockneteasemusic core
  mkdir -p core
  curl 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' -o commits.json
  echo "$(grep sha commits.json | sed -n "1,1p" | cut -c 13-52)" > core_local_ver
  curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/app.js -o core/app.js
  curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/bridge.js -o core/bridge.js
  curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt -o core/ca.crt
  curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.crt -o core/server.crt
  curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.key -o core/server.key
  popd
fi

echo "Add luci-app-adguardhome"
find .. -maxdepth 4 -iname "luci-app-adguardhome" -type d | xargs rm -rf
svn export -q https://github.com/kenzok8/small-package/trunk/adguardhome
svn export -q https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-adguardhome

echo "Add luci-app-mosdns"
# drop mosdns and v2ray-geodata packages that come with the source
find .. -maxdepth 4 -iname "*mosdns" -type d | xargs rm -rf
find ../ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ../ | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata.git v2ray-geodata

echo "Add luci-app-smartdns"
find .. -maxdepth 4 -iname "*smartdns" -type d | xargs rm -rf
svn export -q https://github.com/kenzok8/small-package/trunk/smartdns
svn export -q https://github.com/kenzok8/small-package/trunk/luci-app-smartdns

echo "Add luci-app-netdata"
#find .. -maxdepth 4 -iname "*netdata" -type d | xargs rm -rf
rm -rf ../feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata
ln -s luci-app-netdata/po/zh-cn luci-app-netdata/po/zh_Hans

echo "Add luci-app-ddns-go"
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go.git

echo "Add luci-app-alist"
find .. -maxdepth 4 -iname "*alist" -type d | xargs rm -rf
rm -rf ../feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 20.x ../feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/luci-app-alist.git

echo "Add luci-app-ddnsto linkease istorex"
find .. -maxdepth 4 -iname "*ddnsto" -type d | xargs rm -rf
git clone --depth=1 -b master https://github.com/linkease/nas-packages.git
git clone --depth=1 -b main https://github.com/linkease/nas-packages-luci.git

echo "Add luci-app-eqos"
rm -rf ../feeds/luci/applications/luci-app-eqos
svn export -q https://github.com/kenzok8/jell/trunk/luci-app-eqos

echo "Add luci-app-eqosplus"
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus
sed -i '/"Control"/d' luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/10/99/g' luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/\"control\"/\"network\"/g' `grep "control" -rl ./luci-app-eqosplus`

echo "Add OpenAppFilter"
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git

echo "Add luci-app-parentcontrol"
git clone --depth=1 https://github.com/sirpdboy/luci-app-parentcontrol.git

#echo "Add luci-app-serverchan"
#find .. -maxdepth 4 -iname "*serverchan" -type d | xargs rm -rf
#find .. -maxdepth 4 -iname "*pushbot" -type d | xargs rm -rf
#git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git
#git clone --depth=1 https://github.com/zzsj0928/luci-app-pushbot.git

echo "Add luci-app-autotimeset"
find . -maxdepth 4 -iname "*autotimeset" -type d | xargs rm -rf
git clone --depth=1 https://github.com/sirpdboy/luci-app-autotimeset.git

echo "Add aliyundrive-webdav"
rm -rf ../feeds/luci/applications/luci-app-aliyundrive-webdav
rm -rf ../feeds/packages/multimedia/aliyundrive-webdav
svn export -q https://github.com/messense/aliyundrive-webdav/trunk/openwrt aliyundrive

echo "Add luci-app-bandwidthd"
git clone https://github.com/AlexZhuo/luci-app-bandwidthd.git

# Add Theme
echo "Add Themeluci-theme-design theme"
rm -rf ../feeds/luci/themes/luci-theme-design
git clone --depth=1 -b $(echo $SOURCE_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 https://github.com/gngpp/luci-app-design-config.git

echo "Add Themejerrykuku Argon theme"
rm -rf ../feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b $(echo $SOURCE_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
git clone --depth=1 -b $(echo $SOURCE_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git
popd

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

# 修改插件名字
# sed -i 's/"解除网易云音乐播放限制"/"网易云音乐解锁"/g' `grep "解除网易云音乐播放限制" -rl ./`

# Modify default IP
#sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# Rename hostname to OpenWrt
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate

# Change default shell to zsh
#sed -i 's#/bin/ash#/usr/bin/zsh#g' package/base-files/files/etc/passwd

# 显示增加编译时间
sed -i "s/%C/(By @Cheng build $(TZ=UTC-8 date "+%Y-%m-%d"))/g" package/base-files/files/etc/openwrt_release

# 修改欢迎banner
cp -f $GITHUB_WORKSPACE/data/banner package/base-files/files/etc/banner

# samba解除root限制
sed -i 's/invalid users = root/#&/g' feeds/packages/net/samba4/files/smb.conf.template

echo "完成 common 配置完成……"
echo "========================="
echo

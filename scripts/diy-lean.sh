#!/bin/bash

echo "========================="
echo "开始 diy-lean.sh 配置……"

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

echo "Add 科学上网插件"
git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/passwall_packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

echo "Add luci-app-adguardhome"
find ./ -maxdepth 4 -iname "luci-app-adguardhome" -type d | xargs rm -rf
git_sparse_clone main https://github.com/kenzok8/small-package adguardhome
git_sparse_clone main https://github.com/sirpdboy/sirpdboy-package luci-app-adguardhome

echo "Add luci-app-mosdns"
# drop mosdns and v2ray-geodata packages that come with the source
find ./ -maxdepth 4 -iname "*mosdns" -type d | xargs rm -rf
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata.git package/v2ray-geodata

echo "Add luci-app-smartdns"
find .. -maxdepth 4 -iname "*smartdns" -type d | xargs rm -rf
git_sparse_clone main https://github.com/kenzok8/small-package smartdns
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-smartdns

echo "Add luci-app-netdata"
# find ./ -maxdepth 4 -iname "*netdata" -type d | xargs rm -rf
rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
ln -s package/luci-app-netdata/po/zh-cn package/luci-app-netdata/po/zh_Hans

echo "Add luci-app-ddns-go"
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go.git package/luci-app-ddns-go

echo "Add luci-app-alist"
find ./ -maxdepth 4 -iname "*alist" -type d | xargs rm -rf
git clone --depth=1 https://github.com/sbwml/luci-app-alist.git package/luci-app-alist

echo "Add luci-app-eqosplus"
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
sed -i '/"Control"/d' luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/10/99/g' luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/\"control\"/\"network\"/g' `grep "control" -rl ./luci-app-eqosplus`

echo "Add OpenAppFilter"
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/openappfilter

echo "Add luci-app-autotimeset"
find ./ -maxdepth 4 -iname "*autotimeset" -type d | xargs rm -rf
git clone --depth=1 https://github.com/sirpdboy/luci-app-autotimeset.git package/luci-app-autotimeset

echo "Add aliyundrive-webdav"
find ./ -maxdepth 4 -iname "*aliyundrive-webdav" -type d | xargs rm -rf
git_sparse_clone main https://github.com/messense/aliyundrive-webdav openwrt

echo "Add luci-app-bandwidthd"
git clone --depth=1 https://github.com/AlexZhuo/luci-app-bandwidthd.git package/luci-app-bandwidthd

# Add Theme
echo "Add Themeluci-theme-design theme"
rm -rf ./feeds/luci/themes/luci-theme-design
git clone --depth=1 -b main https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 https://github.com/gngpp/luci-app-design-config.git

echo "Add Themejerrykuku Argon theme"
rm -rf ./feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git

echo "Add luci-app-unblockneteasemusic core"
# luci-app-unblockneteasemusic
find ./ -maxdepth 4 -iname "luci-app-unblockneteasemusic" -type d | xargs rm -rf
git clone --depth=1 -b master https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
# uclient-fetch Use IPv4 only
sed -i 's/uclient-fetch/uclient-fetch -4/g' package/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic/update.sh
# rename
sed -i 's/"解除网易云音乐播放限制"/"解锁网易云灰色音乐"/g' `grep "解除网易云音乐播放限制" -rl package/luci-app-unblockneteasemusic`
# unblockneteasemusic core
NAME=$"package/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic" && mkdir -p $NAME/core
curl 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' -o commits.json
echo "$(grep sha commits.json | sed -n "1,1p" | cut -c 13-52)">"$NAME/core_local_ver"
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/app.js -o $NAME/core/app.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/bridge.js -o $NAME/core/bridge.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt -o $NAME/core/ca.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.crt -o $NAME/core/server.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.key -o $NAME/core/server.key

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

# 添加 poweroff 按钮
curl -fsSL https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/poweroff.htm > feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm
curl -fsSL https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/system.lua > feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

# luci-app-wrtbwmon 5s to 2s
sed -i 's#interval: 5#interval: 2#g' $(find feeds/luci/applications -name 'wrtbwmon.js')
sed -i 's# selected="selected"##' $(find feeds/luci/applications -name 'wrtbwmon.htm')
sed -i 's#"2"#& selected="selected"#' $(find feeds/luci/applications -name 'wrtbwmon.htm')

# Modify default IP
#sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Change default shell to zsh
#sed -i 's#/bin/ash#/usr/bin/zsh#g' package/base-files/files/etc/passwd

# 显示增加编译时间
sed -i "s/%C/(By @Cheng build $(TZ=UTC-8 date "+%Y-%m-%d"))/g" package/base-files/files/etc/openwrt_release

# 修改欢迎banner
cp -f $GITHUB_WORKSPACE/data/banner package/base-files/files/etc/banner

# samba解除root限制
sed -i 's/invalid users = root/#&/g' feeds/packages/net/samba4/files/smb.conf.template

pushd package/lean/default-settings/files
# 设置密码为空
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' zzz-default-settings
# 版本号里显示编译时间
sed -ri "s#(R[0-9].*[0-9])#\1 (By @Cheng build $(TZ=UTC-8 date "+%Y-%m-%d")) #g" zzz-default-settings
popd

./scripts/feeds update -a
./scripts/feeds install -a

echo "完成 diy-lean.sh 配置完成……"
echo "========================="
echo

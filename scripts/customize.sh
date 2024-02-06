#!/bin/bash

function merge_package(){
	# Third-party function
	# From https://github.com/coolsnowwolf/lede/issues/11757#issuecomment-1892195201

  # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径
  # 同一个仓库下载多个文件夹直接在后面跟文件名或路径,空格分开
	# eg: merge_package master https://github.com/WYC-2020/openwrt-packages package/openwrt-packages luci-app-eqos luci-app-openclash luci-app-ddnsto ddnsto 
	# eg: merge_package master https://github.com/lisaac/luci-app-dockerman package/lean applications/luci-app-dockerman
	
	if [[ $# -lt 3 ]]
	then
		ECHO "Syntax error: [$#] [$*]"
		return 0
	fi
	
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="${WORK}"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
	cd - > /dev/null
}

echo "Add luci-app-netdata"
# find ./ -maxdepth 4 -iname "*netdata" -type d | xargs rm -rf
rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
ln -s package/luci-app-netdata/po/zh-cn package/luci-app-netdata/po/zh_Hans

echo "Add luci-app-eqosplus"
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
sed -i '/"Control"/d' package/luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/10/99/g' package/luci-app-eqosplus/luasrc/controller/eqosplus.lua
sed -i 's/\"control\"/\"network\"/g' `grep "control" -rl package/luci-app-eqosplus`

echo "Add luci-theme-argon"
find ./ -maxdepth 4 -iname "luci-theme-argon" -type d | xargs rm -rf
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

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

# 修改makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

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

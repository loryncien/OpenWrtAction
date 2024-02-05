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
sed -i 's/\"control\"/\"network\"/g' `grep "control" -rl ./luci-app-eqosplus`

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

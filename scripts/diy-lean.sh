#!/bin/bash

echo "========================="
echo "开始 diy-lean.sh 18.06 配置"

pushd package
# luci-app-unblockneteasemusic
find .. -maxdepth 4 -iname "luci-app-unblockneteasemusic" -type d | xargs rm -rf
git clone --depth=1 -b master https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
# uclient-fetch Use IPv4 only
sed -i 's/uclient-fetch/uclient-fetch -4/g' luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic/update.sh
# rename
sed -i 's/"解除网易云音乐播放限制"/"解锁网易云灰色音乐"/g' `grep "解除网易云音乐播放限制" -rl ./`
# unblockneteasemusic core
NAME=$"luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic" && mkdir -p $NAME/core
curl 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' -o commits.json
echo "$(grep sha commits.json | sed -n "1,1p" | cut -c 13-52)">"$NAME/core_local_ver"
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/app.js -o $NAME/core/app.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/bridge.js -o $NAME/core/bridge.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt -o $NAME/core/ca.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.crt -o $NAME/core/server.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.key -o $NAME/core/server.key
popd

# 添加 poweroff 按钮
curl -fsSL https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm
curl -fsSL https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

# luci-app-wrtbwmon 5s to 2s
sed -i 's#interval: 5#interval: 2#g' $(find feeds/luci/applications -name 'wrtbwmon.js')
sed -i 's# selected="selected"##' $(find feeds/luci/applications -name 'wrtbwmon.htm')
sed -i 's#"2"#& selected="selected"#' $(find feeds/luci/applications -name 'wrtbwmon.htm')

# Modify localtime in Homepage
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/x86/index.htm
# Shows increased compile time
#sed -i "s/<%=pcdata(ver.distversion)%>/& (By @Cheng build $(TZ=UTC-8 date "+%Y-%m-%d"))/g" package/lean/autocore/files/x86/index.htm
# Modify hostname in Homepage
sed -i 's/${g}'"'"' - '"'"'//g' package/lean/autocore/files/x86/autocore

pushd package/lean/default-settings/files
# 设置密码为空
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' zzz-default-settings
# 版本号里显示一个自己的名字
export date_version=$(TZ=UTC-8 date +'%Y-%m-%d')
sed -ri "s#(R[0-9].*[0-9])#\1 (By @Cheng build ${date_version}) #g" zzz-default-settings
popd

echo "完成 diy-lean.sh 18.06 配置"
echo "========================="
echo

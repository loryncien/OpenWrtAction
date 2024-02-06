#!/bin/bash

echo "========================="
echo "开始 终端 配置……"

mkdir -p files/root
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
# git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh

## Install extra plugins
# git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions

## Get .zshrc dotfile
# cp $GITHUB_WORKSPACE/data/zsh/.zshrc .

git clone --depth 1 https://github.com/skywind3000/z.lua.git ./.config/z.lua
cat >> .bashrc <<EOP 
# z.lua
alias zc='z -c'      # 严格匹配当前路径的子路径
alias zz='z -i'      # 使用交互式选择模式
alias zf='z -I'      # 使用 fzf 对多个结果进行选择
alias zb='z -b'      # 快速回到父目录
alias zbi='z -b -i'  # 快速回到父目录交互式选择模式
alias zh='z -i -t .' # 历史路径

# When you are using j xxx it will first try cd xxx and then z xxx if cd failed.
function j() {
    if [[ "\$argv[1]" == "-"* ]]; then
        z "\$@"
    else
        cd "\$@" 2> /dev/null || z "\$@"
    fi
}

eval "\$(lua /root/.config/z.lua/z.lua --init bash once enhanced)"

EOP

## Install vim-plug
curl -fLo ./.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# cp $GITHUB_WORKSPACE/data/bashrc .bashrc

popd

echo "完成 终端 配置……"
echo "========================="
echo

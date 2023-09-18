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

git clone --depth 1 https://github.com/skywind3000/z.lua.git ./.config/z.lua
curl "https://raw.githubusercontent.com/loryncien/fz.sh/master/fz.sh" -o ./.config/fz.sh

## Install vim-plug
curl -fLo ./.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

## Get .zshrc dotfile
# cp $GITHUB_WORKSPACE/data/zsh/.zshrc .
cp $GITHUB_WORKSPACE/data/.bashrc .

## Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ./.config/fzf
.config/fzf/install --bin
cp $GITHUB_WORKSPACE/data/.fzf.bash .
echo '# Note: opkg update && opkg install findutils findutils-find --force-reinstall' >> .bashrc
echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> .bashrc

popd

echo "完成 终端 配置……"
echo "========================="
echo

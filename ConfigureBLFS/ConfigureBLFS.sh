#! /bin/bash

source UtilInstallPackagesBLFS.sh

CreateNewUser()
{
	local NewUser="$1";

	useradd -m -G root -s /bin/zsh "$NewUser"
	passwd "$NewUser" << EOF
S
S
S
EOF
	cat > /home/$NewUser/.zshrc << EOF
# zsh-new-user-install
## History Configuration
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

## Common shell options
# unsetopt autocd
unsetopt autocd
# unsetopt extendedglob
unsetopt extendedglob
# setopt nomatch
setopt nomatch
# setopt beep
unsetopt nobeep
# unsetopt notify
unsetopt notify

# compinstall
zstyle :compinstall filename '/home/ohengelm/.zshrc'

autoload -Uz compinit
compinit

EOF
}


InstallZsh;
CreateNewUser ohengelm
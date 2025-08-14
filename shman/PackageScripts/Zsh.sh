#!/bin/bash

if [ ! -z "${PackageZsh[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									  Zsh									   #
# ===============ft_linux==============||==============©Othello=============== #

# https://www.linuxfromscratch.org/blfs/view/stable/postlfs/zsh.html
declare -A PackageZsh;
PackageZsh[Source]="https://www.zsh.org/pub/zsh-5.9.tar.xz";
PackageZsh[MD5]="182e37ca3fe3fa6a44f69ad462c5c30e";
PackageZsh[Name]="zsh";
PackageZsh[Version]="5.9";
PackageZsh[Package]="${PackageZsh[Name]}-${PackageZsh[Version]}";
PackageZsh[Extension]=".tar.xz";

PackageZsh[Programs]="zsh zsh-5.9";
PackageZsh[Libraries]="";
PackageZsh[Python]="";

InstallZsh()
{
	# Check Installation
	CheckZsh && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	# Install Package
	_BuildZsh;
	_ConfigureZsh;
	return $?
}

CheckZsh()
{
	CheckInstallation	"${PackageZsh[Programs]}"\
						"${PackageZsh[Libraries]}"\
						"${PackageZsh[Python]}" 1> /dev/null;
	return $?;
}

CheckZshVerbose()
{
	CheckInstallationVerbose	"${PackageZsh[Programs]}"\
								"${PackageZsh[Libraries]}"\
								"${PackageZsh[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildZsh()
{

	EchoInfo	"Package ${PackageZsh[Name]}"

	DownloadPackage	"${PackageZsh[Source]}"	"${SHMAN_PDIR}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageZsh[Package]}"	"${PackageZsh[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageZsh[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageZsh[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageZsh[Name]}> Adapt the documentation build system for texinfo-7.0 or later"
	sed 	-e 's/set_from_init_file/texinfo_&/' \
			-i Doc/Makefile.in

	EchoInfo	"${PackageZsh[Name]}> Fix some programs shipped in the building system for detecting system features"
	sed -e 's/^main/int &/' \
		-e 's/exit(/return(/' \
		-i aczsh.m4 configure.ac
	sed -e 's/test = /&(char**)/' \
		-i configure.ac
	autoconf

	EchoInfo	"${PackageZsh[Name]}> Adjust documentation reference to /etc/zsh"
	sed -e 's|/etc/z|/etc/zsh/z|g' \
		-i Doc/*.*

	EchoInfo	"${PackageZsh[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc/zsh \
				--enable-etcdir=/etc/zsh \
				--enable-cap \
				--enable-gdbm \
				1> /dev/null || { EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZsh[Name]}> make"
	make  1> /dev/null || { EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZsh[Name]}> makeinfo *"
	makeinfo  Doc/zsh.texi --html      -o Doc/html && \
	makeinfo  Doc/zsh.texi --plaintext -o zsh.txt  && \
	makeinfo  Doc/zsh.texi --html --no-split --no-headers -o zsh.html || \
	{ EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	# texi2pdf  Doc/zsh.texi -o Doc/zsh.pdf

	EchoInfo	"${PackageZsh[Name]}> make check"
	make check 1> /dev/null || { EchoTest KO ${PackageZsh[Name]} && EchoInfo "V14system.ztst might fail due to timing issues, but is harmless" && PressAnyKeyToContinue; };

	EchoInfo	"${PackageZsh[Name]}> make install"
	make install && \
	make infodir=/usr/share/info install.info && \
	make htmldir=/usr/share/doc/zsh-5.9/html install.html && \
	install -v -m644 zsh.{html,txt} Etc/FAQ /usr/share/doc/zsh-5.9 \
	1> /dev/null || { EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	# install -v -m644 Doc/zsh.pdf /usr/share/doc/zsh-5.9
}

_ConfigureZsh()
{
	EchoInfo	"${PackageZsh[Name]}> Add /etc/zsh/zshrc file for default users"
	mkdir -p /etc/zsh
	cat	> /etc/zsh/zshrc << EOF
# Colors
export TERM=xterm-256color

# Default prompt
case "\$(tput colors)" in
	8)
		PS1="%(?..%F{#ff0000}%? )%(#.%F{#ff4040}%n.%F{#ff9f40}%n)%F{#aaaaaa}|%1~ %# ";;
	*)
		PS1="%(?..%F{#ff0000}%? )%(#.%F{#ff4040}%n.%F{#ff9f40}%n)%F{#c7c1bb}|%1~ %# ";;
esac

# Bindkeys for Keyboard input
bindkey -e

# Copied from Codam bindkey -L
bindkey "^@" set-mark-command
bindkey "^A" beginning-of-line
bindkey "^B" backward-char
bindkey "^D" delete-char-or-list
bindkey "^E" end-of-line
bindkey "^F" forward-char
bindkey "^G" send-break
bindkey "^H" backward-delete-char
bindkey "^I" expand-or-complete
bindkey "^J" accept-line
bindkey "^K" kill-line
bindkey "^L" clear-screen
bindkey "^M" accept-line
bindkey "^N" down-line-or-history
bindkey "^O" accept-line-and-down-history
bindkey "^P" up-line-or-history
bindkey "^Q" push-line
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
bindkey "^T" transpose-chars
bindkey "^U" kill-whole-line
bindkey "^V" quoted-insert
bindkey "^W" backward-kill-word
bindkey "^X^B" vi-match-bracket
bindkey "^X^F" vi-find-next-char
bindkey "^X^J" vi-join
bindkey "^X^K" kill-buffer
bindkey "^X^N" infer-next-history
bindkey "^X^O" overwrite-mode
bindkey "^X^R" _read_comp
bindkey "^X^U" undo
bindkey "^X^V" vi-cmd-mode
bindkey "^X^X" exchange-point-and-mark
bindkey "^X*" expand-word
bindkey "^X=" what-cursor-position
bindkey "^X?" _complete_debug
bindkey "^XC" _correct_filename
bindkey "^XG" list-expand
bindkey "^Xa" _expand_alias
bindkey "^Xc" _correct_word
bindkey "^Xd" _list_expansions
bindkey "^Xe" _expand_word
bindkey "^Xg" list-expand
bindkey "^Xh" _complete_help
bindkey "^Xm" _most_recent_file
bindkey "^Xn" _next_tags
bindkey "^Xr" history-incremental-search-backward
bindkey "^Xs" history-incremental-search-forward
bindkey "^Xt" _complete_tag
bindkey "^Xu" undo
bindkey "^X~" _bash_list-choices
bindkey "^Y" yank
bindkey "^[^D" list-choices
bindkey "^[^G" send-break
bindkey "^[^H" backward-kill-word
bindkey "^[^I" self-insert-unmeta
bindkey "^[^J" self-insert-unmeta
bindkey "^[^L" clear-screen
bindkey "^[^M" self-insert-unmeta
bindkey "^[^_" copy-prev-word
bindkey "^[ " expand-history
bindkey "^[!" expand-history
bindkey "^[\"" quote-region
bindkey "^[\$" spell-word
bindkey "^['" quote-line
bindkey "^[," _history-complete-newer
bindkey "^[-" neg-argument
bindkey "^[." insert-last-word
bindkey "^[/" _history-complete-older
bindkey "^[0" digit-argument
bindkey "^[1" digit-argument
bindkey "^[2" digit-argument
bindkey "^[3" digit-argument
bindkey "^[4" digit-argument
bindkey "^[5" digit-argument
bindkey "^[6" digit-argument
bindkey "^[7" digit-argument
bindkey "^[8" digit-argument
bindkey "^[9" digit-argument
bindkey "^[<" beginning-of-buffer-or-history
bindkey "^[>" end-of-buffer-or-history
bindkey "^[?" which-command
bindkey "^[A" accept-and-hold
bindkey "^[B" backward-word
bindkey "^[C" capitalize-word
bindkey "^[D" kill-word
bindkey "^[F" forward-word
bindkey "^[G" get-line
bindkey "^[H" run-help
bindkey "^[L" down-case-word
bindkey "^[N" history-search-forward
bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history
bindkey "^[OC" forward-char
bindkey "^[OD" backward-char
bindkey "^[OF" end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[P" history-search-backward
bindkey "^[Q" push-line
bindkey "^[S" spell-word
bindkey "^[T" transpose-words
bindkey "^[U" up-case-word
bindkey "^[W" copy-region-as-kill
bindkey "^[[200~" bracketed-paste
bindkey "^[[2~" overwrite-mode
bindkey "^[[3~" delete-char
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[C" forward-char
bindkey "^[[D" backward-char
bindkey "^[_" insert-last-word
bindkey "^[a" accept-and-hold
bindkey "^[b" backward-word
bindkey "^[c" capitalize-word
bindkey "^[d" kill-word
bindkey "^[f" forward-word
bindkey "^[g" get-line
bindkey "^[h" run-help
bindkey "^[l" down-case-word
bindkey "^[n" history-search-forward
bindkey "^[p" history-search-backward
bindkey "^[q" push-line
bindkey "^[s" spell-word
bindkey "^[t" transpose-words
bindkey "^[u" up-case-word
bindkey "^[w" copy-region-as-kill
bindkey "^[x" execute-named-cmd
bindkey "^[y" yank-pop
bindkey "^[z" execute-last-named-cmd
bindkey "^[|" vi-goto-column
bindkey "^[~" _bash_complete-word
bindkey "^[^?" backward-kill-word
bindkey "^_" undo
bindkey -R " "-"~" self-insert
bindkey "^?" backward-delete-char
bindkey -R "\M-^@"-"\M-^?" self-insert

# Manually added
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[F" end-of-line
bindkey "^[[H" beginning-of-line

# colors
# Enable colored output for ls
export LS_COLORS='di=34;1:ex=32;1:ln=36:or=31:mi=31:fi=0:*Makefile=38;2;255;128;0:*.tar=38;5;40'
alias ls='ls --color=auto'

# Enable colors output for env
alias env='
env | grep -E "^(SHELL|SHLVL|TERM|LANG)" 	| GREP_COLORS="mt=1;32" grep --color=always -E "^[^=]+=|:"
env | grep -E "^(USER|LOGNAME|MAIL|HOME)" 	| GREP_COLORS="mt=1;33" grep --color=always -E "^[^=]+=|:"
env | grep -E "^(PWD|OLDPWD)" 				| GREP_COLORS="mt=1;31" grep --color=always -E "^[^=]+=|:"
env | grep -E "^(PATH)" 					| GREP_COLORS="mt=1;31" grep --color=always -E "^[^=]+=|:"
env | grep -E "^(SSH)" 						| GREP_COLORS="mt=1;35" grep --color=always -E "^[^=]+=|:"
env | grep -Ev "^(SHELL|SHLVL|TERM|LANG|USER|LOGNAME|MAIL|HOME|PWD|OLDPWD|PATH|SSH)" | GREP_COLORS="mt=1;32" grep --color=always -E "^[^=]+=|:"'


ps -o comm= -p \$$ | tr -d '\n'
echo -n "(\$-) "
id
EOF
}
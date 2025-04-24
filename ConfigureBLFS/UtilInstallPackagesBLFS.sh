#! /bin/bash

source Utils.sh

PDIR="/usr/src/";

DownloadPackage()
{
	if [ ! -z "${1}" ] && [ ! -z "${2}" ]; then
		if [ -f "${2}${3}" ]; then
			if [ ! -z "${4}" ] && [ "$(md5sum "${2}${3}" | awk '{print $1}')" = "$4" ]; then
				return ;
			else
				EchoError	"Issue with MD5sum $4";
			fi
		fi
		EchoInfo	"Downloading ${3}"
		wget -P "${2}" "${1}";
	fi
}

ReExtractPackage()
{
	local SRC="${1}${2}${3}";
	local DST="${1}";
	local RSLT="${1}${2}";

	# EchoInfo	"$SRC";
	# EchoInfo	"$DST";
	# EchoInfo	"$RSLT";
	# EchoInfo	"validate input"; PressAnyKeyToContinue;
	if [ ! -f "$SRC" ] || [ ! -d "$DST" ]; then
		EchoError	"ReExtractPackage SRC[$SRC] DST[$DST]";
		# return false;
		return 1;
	fi
	
	# EchoInfo	"remove old"; PressAnyKeyToContinue;
	if [ -d "$RSLT" ]; then
		# echo "removing old"; PressAnyKeyToContinue;
		rm -rf "$RSLT";
	fi
	
	# EchoInfo	"extract new"; PressAnyKeyToContinue
	tar -xf "$SRC" -C "$DST" || { echo "Failed to extract $?" >&2 && PressAnyKeyToContinue; };
	# PressAnyKeyToContinue;

}

# =====================================||===================================== #
#									Temp									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A Packagetemp;
Packagetemp[Source]="";
Packagetemp[MD5]="";
Packagetemp[Name]="Temp";
Packagetemp[Version]="";
Packagetemp[Package]="${Packagetemp[Name]}-${Packagetemp[Version]}";
Packagetemp[Extension]=".tar.xz";

InstallTemp()
{
	EchoInfo	"Package ${Packagetemp[Name]}"

	DownloadPackage	"${Packagetemp[Source]}"	"${PDIR}"	"${Packagetemp[Package]}${Packagetemp[Extension]}"	"${Packagetemp[MD5]}";
	ReExtractPackage	"${PDIR}"	"${Packagetemp[Package]}"	"${Packagetemp[Extension]}";

	if ! cd "${PDIR}${Packagetemp[Package]}"; then
		EchoError	"cd ${PDIR}${Packagetemp[Package]}";
		return 1;
	fi

	EchoInfo	"${Packagetemp[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${Packagetemp[Name]}> make"
	make  1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${Packagetemp[Name]}> make check"
	make check 1> /dev/null || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${Packagetemp[Name]}> make install"
	make install 1> /dev/null && Packagetemp[Status]=$? || { Packagetemp[Status]=$?; EchoTest KO ${Packagetemp[Name]} && PressAnyKeyToContinue; return 1; };

	# if ! mkdir -p build; then
	# 	Packagetemp[Status]=1; 
	# 	EchoError	"Failed to make ${PDIR}${Packagetemp[Name]}/build";
	# 	return ;
	# fi
	# cd "${PDIR}${Packagetemp[Package]}/build";
}

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

InstallZsh()
{
	EchoInfo	"Package ${PackageZsh[Name]}"

	DownloadPackage	"${PackageZsh[Source]}"	"${PDIR}";
	ReExtractPackage	"${PDIR}"	"${PackageZsh[Package]}"	"${PackageZsh[Extension]}";

	if ! cd "${PDIR}${PackageZsh[Package]}"; then
		EchoError	"cd ${PDIR}${PackageZsh[Package]}";
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
				1> /dev/null || { PackageZsh[Status]=$?; EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZsh[Name]}> make"
	make  1> /dev/null || { PackageZsh[Status]=$?; EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageZsh[Name]}> makeinfo *"
	makeinfo  Doc/zsh.texi --html      -o Doc/html && \
	makeinfo  Doc/zsh.texi --plaintext -o zsh.txt  && \
	makeinfo  Doc/zsh.texi --html --no-split --no-headers -o zsh.html || \
	{ PackageZsh[Status]=$?; EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	# texi2pdf  Doc/zsh.texi -o Doc/zsh.pdf

	EchoInfo	"${PackageZsh[Name]}> make check"
	make check 1> /dev/null || { PackageZsh[Status]=$?; EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageZsh[Name]}> make install"
	make install && \
	make infodir=/usr/share/info install.info && \
	make htmldir=/usr/share/doc/zsh-5.9/html install.html && \
	install -v -m644 zsh.{html,txt} Etc/FAQ /usr/share/doc/zsh-5.9 \
	1> /dev/null && PackageZsh[Status]=$? || { PackageZsh[Status]=$?; EchoTest KO ${PackageZsh[Name]} && PressAnyKeyToContinue; return 1; };

	# install -v -m644 Doc/zsh.pdf /usr/share/doc/zsh-5.9

	EchoInfo	"${PackageZsh[Name]}> Add /etc/zsh/zshrc file for default users"
	cat	> /etc/zsh/zshrc << EOF
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

ps -o comm= -p \$$ | tr -d '\n'
echo -n "(\$-) "
id
EOF
}


# =====================================||===================================== #
#									Lynx									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLynx;
PackageLynx[Source]="https://invisible-mirror.net/archives/lynx/tarballs/lynx2.9.2.tar.bz2";
PackageLynx[MD5]="3ce01505e82626ca4d7291d7e649c4c9";
PackageLynx[Name]="lynx";
PackageLynx[Version]="2.9.2";
PackageLynx[Package]="${PackageLynx[Name]}${PackageLynx[Version]}";
PackageLynx[Extension]=".tar.bz2";

InstallLynx()
{
	EchoInfo	"Package ${PackageLynx[Name]}"

	DownloadPackage	"${PackageLynx[Source]}"	"${PDIR}"	"${PackageLynx[Package]}${PackageLynx[Extension]}"	"${PackageLynx[MD5]}";
	ReExtractPackage	"${PDIR}"	"${PackageLynx[Package]}"	"${PackageLynx[Extension]}";

	if ! cd "${PDIR}${PackageLynx[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLynx[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLynx[Name]}> Configure"
	./configure --prefix=/usr \
				--sysconfdir=/etc/lynx \
				--with-zlib \
				--with-bzlib \
				--with-ssl \
				--with-screen=ncursesw \
				--enable-locale-charset \
				--datadir=/usr/share/doc/lynx-2.9.2 \
				1> /dev/null || { PackageLynx[Status]=$?; EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLynx[Name]}> make"
	make  1> /dev/null || { PackageLynx[Status]=$?; EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLynx[Name]}> make install-full"
	make install-full 1> /dev/null && PackageLynx[Status]=$? || { PackageLynx[Status]=$?; EchoTest KO ${PackageLynx[Name]} && PressAnyKeyToContinue; return 1; };
	
	chgrp -v -R root /usr/share/doc/lynx-2.9.2/lynx_doc
}

# =====================================||===================================== #
#									Which									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageWhich;
PackageWhich[Source]="https://ftp.gnu.org/gnu/which/which-2.23.tar.gz";
PackageWhich[MD5]="1963b85914132d78373f02a84cdb3c86";
PackageWhich[Name]="which";
PackageWhich[Version]="2.23";
PackageWhich[Package]="${PackageWhich[Name]}-${PackageWhich[Version]}";
PackageWhich[Extension]=".tar.gz";

InstallWhich()
{
	EchoInfo	"Package ${PackageWhich[Name]}"

	DownloadPackage	"${PackageWhich[Source]}"	"${PDIR}"	"${PackageWhich[Package]}${PackageWhich[Extension]}"	"${PackageWhich[MD5]}";
	ReExtractPackage	"${PDIR}"	"${PackageWhich[Package]}"	"${PackageWhich[Extension]}";

	if ! cd "${PDIR}${PackageWhich[Package]}"; then
		EchoError	"cd ${PDIR}${PackageWhich[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageWhich[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageWhich[Status]=$?; EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWhich[Name]}> make"
	make  1> /dev/null || { PackageWhich[Status]=$?; EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageWhich[Name]}> make install"
	make install 1> /dev/null && PackageWhich[Status]=$? || { PackageWhich[Status]=$?; EchoTest KO ${PackageWhich[Name]} && PressAnyKeyToContinue; return 1; };
}

# =====================================||===================================== #
#									Libtasn1									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibtasn1;
PackageLibtasn1[Source]="https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.20.0.tar.gz";
PackageLibtasn1[MD5]="930f71d788cf37505a0327c1b84741be";
PackageLibtasn1[Name]="libtasn1";
PackageLibtasn1[Version]="4.20.0";
PackageLibtasn1[Package]="${PackageLibtasn1[Name]}-${PackageLibtasn1[Version]}";
PackageLibtasn1[Extension]=".tar.gz";

InstallLibtasn1()
{
	EchoInfo	"Package ${PackageLibtasn1[Name]}"

	DownloadPackage	"${PackageLibtasn1[Source]}"	"${PDIR}"	"${PackageLibtasn1[Package]}${PackageLibtasn1[Extension]}"	"${PackageLibtasn1[MD5]}";
	ReExtractPackage	"${PDIR}"	"${PackageLibtasn1[Package]}"	"${PackageLibtasn1[Extension]}";

	if ! cd "${PDIR}${PackageLibtasn1[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibtasn1[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibtasn1[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				1> /dev/null || { PackageLibtasn1[Status]=$?; EchoTest KO ${PackageLibtasn1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibtasn1[Name]}> make"
	make  1> /dev/null || { PackageLibtasn1[Status]=$?; EchoTest KO ${PackageLibtasn1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibtasn1[Name]}> make check"
	make check 1> /dev/null || { PackageLibtasn1[Status]=$?; EchoTest KO ${PackageLibtasn1[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLibtasn1[Name]}> make install"
	make install 1> /dev/null && PackageLibtasn1[Status]=$? || { PackageLibtasn1[Status]=$?; EchoTest KO ${PackageLibtasn1[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibtasn1[Name]}> install API documentation"
	make -C doc/reference install-data-local

	# if ! mkdir -p build; then
	# 	PackageLibtasn1[Status]=1; 
	# 	EchoError	"Failed to make ${PDIR}${PackageLibtasn1[Name]}/build";
	# 	return ;
	# fi
	# cd "${PDIR}${PackageLibtasn1[Package]}/build";
}

# =====================================||===================================== #
#									LibgpgError									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLibgpgError;
PackageLibgpgError[Source]="https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2";
PackageLibgpgError[MD5]="74b73ea044685ce9fd6043a8cc885eac";
PackageLibgpgError[Name]="libgpg-error";
PackageLibgpgError[Version]="1.51";
PackageLibgpgError[Package]="${PackageLibgpgError[Name]}-${PackageLibgpgError[Version]}";
PackageLibgpgError[Extension]=".tar.bz2";

InstallLibgpgError()
{
	EchoInfo	"Package ${PackageLibgpgError[Name]}"

	DownloadPackage	"${PackageLibgpgError[Source]}"	"${PDIR}"	"${PackageLibgpgError[Package]}${PackageLibgpgError[Extension]}"	"${PackageLibgpgError[MD5]}";
	ReExtractPackage	"${PDIR}"	"${PackageLibgpgError[Package]}"	"${PackageLibgpgError[Extension]}";

	if ! cd "${PDIR}${PackageLibgpgError[Package]}"; then
		EchoError	"cd ${PDIR}${PackageLibgpgError[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLibgpgError[Name]}> Configure"
	./configure --prefix=/usr 1> /dev/null || { PackageLibgpgError[Status]=$?; EchoTest KO ${PackageLibgpgError[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibgpgError[Name]}> make"
	make  1> /dev/null || { PackageLibgpgError[Status]=$?; EchoTest KO ${PackageLibgpgError[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLibgpgError[Name]}> make install"
	make install 1> /dev/null && PackageLibgpgError[Status]=$? || { PackageLibgpgError[Status]=$?; EchoTest KO ${PackageLibgpgError[Name]} && PressAnyKeyToContinue; return 1; };

	install -v -m644 -D README /usr/share/doc/libgpg-error-1.51/README

}

# InstallLynx;
# InstallWhich;

# Gnome
		InstallLibtasn1;
	# p11-kit
		InstallLibgpgError;
	# libgcrypt
		# docutils-0.21.2
				# ICU-76.1
			# libxml2
		# libxslt-1.1.42
		# pcre2-10.45
	# GLib-2.82.5
# Gcr-3.41.2

# Pacman
	# Curl
		# libpsl
			# libidn2
				# libunistring


# Gnome
	# Gcr
		# GLib
		# libgcrypt
			# libgpg-error
		# p11-kit

	# gnome-shell
		# evolution-data-server
		# Gcr
		# Gjs-1.82.1
		# gnome-desktop-44.1
		# ibus-1.5.31
		# Mutter-47.5
		# Polkit-126
		# and startup-notification-0.12
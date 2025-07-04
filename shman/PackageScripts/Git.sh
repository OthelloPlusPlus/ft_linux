#!/bin/bash

if [ ! -z "${PackageGit[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									  Git									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGit;
PackageGit[Source]="https://www.kernel.org/pub/software/scm/git/git-2.48.1.tar.xz";
PackageGit[MD5]="99656f1481e70701198257ada703a480";
PackageGit[Name]="git";
PackageGit[Version]="2.48.1";
PackageGit[Package]="${PackageGit[Name]}-${PackageGit[Version]}";
PackageGit[Extension]=".tar.xz";

PackageGit[Programs]="git git-receive-pack git-upload-archive git-upload-pack git-cvsserver git-shell gitk scalar";
PackageGit[Libraries]="";
PackageGit[Python]="";

InstallGit()
{
	# Check Installation
	CheckGit && return $?;

	# Check Dependencies
	Dependencies=()
	for Dependency in "${Dependencies[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || return $?
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
	done

	Optional=(Asciidoc Xmlto)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh";
		fi
	done
	
	# Install Package
	_BuildGit;
	return $?
}

CheckGit()
{
	CheckInstallation 	"${PackageGit[Programs]}"\
						"${PackageGit[Libraries]}"\
						"${PackageGit[Python]}" 1> /dev/null;
	return $?;
}

CheckGitVerbose()
{
	CheckInstallationVerbose	"${PackageGit[Programs]}"\
								"${PackageGit[Libraries]}"\
								"${PackageGit[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_BuildGit()
{
	EchoInfo	"Package ${PackageGit[Name]}"

	DownloadPackage	"${PackageGit[Source]}"	"${SHMAN_PDIR}"	"${PackageGit[Package]}${PackageGit[Extension]}"	"${PackageGit[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGit[Package]}"	"${PackageGit[Extension]}";

	if ! cd "${SHMAN_PDIR}${PackageGit[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGit[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageGit[Name]}> Configure"
	./configure --prefix=/usr \
				--with-gitconfig=/etc/gitconfig \
				--with-python=python3 \
				1> /dev/null || { EchoTest KO ${PackageGit[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGit[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageGit[Name]} && PressAnyKeyToContinue; return 1; };

	# If you have installed asciidoc-10.2.1 you can create the html version of the man pages and other docs:
	CheckAsciidoc 2>/dev/null && \
	{
		EchoInfo "${PackageGit[Name]}> make html"
		make html

		# If you have installed asciidoc-10.2.1 and xmlto-0.0.29 you can create the man pages:
		CheckXmlto 2>/dev/null && \
		{
			EchoInfo "${PackageGit[Name]}> make man"
			make man
		}
	}

	EchoInfo	"${PackageGit[Name]}> make test"
	GIT_UNZIP=nonexist make test -k |& tee test.log
	grep '^not ok' test.log | grep -v TODO
	
	EchoInfo	"${PackageGit[Name]}> make install"
	make perllibdir=/usr/lib/perl5/5.40/site_perl install 1> /dev/null || { EchoTest KO ${PackageGit[Name]} && PressAnyKeyToContinue; return 1; };
}

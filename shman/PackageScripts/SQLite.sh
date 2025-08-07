#!/bin/bash

if [ ! -z "${PackageSQLite[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 SQLite									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageSQLite;
PackageSQLite[Source]="https://sqlite.org/2025/sqlite-autoconf-3490100.tar.gz";
PackageSQLite[MD5]="8d77d0779bcd9993eaef33431e2e0c30";
PackageSQLite[Name]="sqlite-autoconf";
PackageSQLite[Version]="3490100";
PackageSQLite[Package]="${PackageSQLite[Name]}-${PackageSQLite[Version]}";
PackageSQLite[Extension]=".tar.gz";

PackageSQLite[Programs]="sqlite3";
PackageSQLite[Libraries]="libsqlite3.so";
PackageSQLite[Python]="";

InstallSQLite()
{
	# Check Installation
	CheckSQLite && return $?;

	# Check Dependencies
	Required=()
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(LibArchive)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"Package ${PackageSQLite[Name]}"
	_ExtractPackageSQLite || return $?;
	_BuildSQLite;
	return $?
}

CheckSQLite()
{
	CheckInstallation 	"${PackageSQLite[Programs]}"\
						"${PackageSQLite[Libraries]}"\
						"${PackageSQLite[Python]}" 1> /dev/null;
	return $?;
}

CheckSQLiteVerbose()
{
	CheckInstallationVerbose	"${PackageSQLite[Programs]}"\
								"${PackageSQLite[Libraries]}"\
								"${PackageSQLite[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageSQLite()
{
	DownloadPackage	"${PackageSQLite[Source]}"	"${SHMAN_PDIR}"	"${PackageSQLite[Package]}${PackageSQLite[Extension]}"	"${PackageSQLite[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageSQLite[Package]}"	"${PackageSQLite[Extension]}" || return $?;
	wget -P "${SHMAN_PDIR}" "https://sqlite.org/2025/sqlite-doc-3490100.zip";

	return $?;
}

_BuildSQLite()
{
	if ! cd "${SHMAN_PDIR}${PackageSQLite[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageSQLite[Package]}";
		return 1;
	fi

	unzip -q ../sqlite-doc-3490100.zip

	EchoInfo	"${PackageSQLite[Name]}> Configure"
	./configure --prefix=/usr \
				--disable-static \
				--enable-fts{4,5} \
				CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
						-D SQLITE_ENABLE_UNLOCK_NOTIFY=1 \
						-D SQLITE_ENABLE_DBSTAT_VTAB=1 \
						-D SQLITE_SECURE_DELETE=1" \
				1> /dev/null || { EchoTest KO ${PackageSQLite[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSQLite[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageSQLite[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSQLite[Name]}> make install"
	make install 1> /dev/null || { EchoTest KO ${PackageSQLite[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageSQLite[Name]}> Install documentation"
	install -v -m755 -d /usr/share/doc/sqlite-3.49.1 &&	cp -v -R sqlite-doc-3490100/* /usr/share/doc/sqlite-3.49.1
}

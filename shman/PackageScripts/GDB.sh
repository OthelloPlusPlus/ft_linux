#!/bin/bash

if [ ! -z "${PackageGDB[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									GDB								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageGDB;
# Manual
PackageGDB[Source]="https://ftp.gnu.org/gnu/gdb/gdb-16.2.tar.xz";
PackageGDB[MD5]="05e4a7e3b177432771aa7277af9bccee";
# Automated unless edgecase
PackageGDB[Name]="";
PackageGDB[Version]="";
PackageGDB[Extension]="";
if [[ -n "${PackageGDB[Source]}" ]]; then
	filename="${PackageGDB[Source]##*/}"
	if [[ $filename =~ ^([a-zA-Z0-9._+-]+)-([0-9]+\.[0-9]+(\.[0-9]+)?)(\..+)$ ]]; then
		[[ -z "${PackageGDB[Name]}" ]] && PackageGDB[Name]="${BASH_REMATCH[1]}"
		[[ -z "${PackageGDB[Version]}" ]] && PackageGDB[Version]="${BASH_REMATCH[2]}"
		[[ -z "${PackageGDB[Extension]}" ]] && PackageGDB[Extension]="${BASH_REMATCH[4]}"
	fi
fi
PackageGDB[Package]="${PackageGDB[Name]}-${PackageGDB[Version]}";

PackageGDB[Programs]="gcore gdb gdbserver gdb-add-index gstack";
PackageGDB[Libraries]="libinproctrace.so";
PackageGDB[Python]="";

InstallGDB()
{
	# Check Installation
	CheckGDB && return $?;

	# Check Dependencies
	EchoInfo	"${PackageGDB[Name]}> Checking dependencies..."
	Required=()
	for Dependency in "${Required[@]}"; do
		# EchoInfo	"${PackageGDB[Name]}> Checking required ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		# EchoInfo	"${PackageGDB[Name]}> Checking recommended ${Dependency}..."
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen GCC Guile Rustc Valgrind)
	for Dependency in "${Optional[@]}"; do
		# EchoInfo	"${PackageGDB[Name]}> Checking optional ${Dependency}..."
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageGDB[Name]}> Building package..."
	_ExtractPackageGDB || return $?;
	_BuildGDB;
	return $?
}

CheckGDB()
{
	return 1;
	CheckInstallation 	"${PackageGDB[Programs]}"\
						"${PackageGDB[Libraries]}"\
						"${PackageGDB[Python]}" 1> /dev/null;
	return $?;
}

CheckGDBVerbose()
{
	return 1;
	CheckInstallationVerbose	"${PackageGDB[Programs]}"\
								"${PackageGDB[Libraries]}"\
								"${PackageGDB[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageGDB()
{
	DownloadPackage	"${PackageGDB[Source]}"	"${SHMAN_PDIR}"	"${PackageGDB[Package]}${PackageGDB[Extension]}"	"${PackageGDB[MD5]}" || return $?;
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageGDB[Package]}"	"${PackageGDB[Extension]}" || return $?;

	for URL in \
		# ""
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done

	return $?;
}

_BuildGDB()
{
	if ! cd "${SHMAN_PDIR}${PackageGDB[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageGDB[Package]}";
		return 1;
	fi

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageGDB[Package]}/build \
					|| { EchoError "${PackageGDB[Name]}> Failed to enter ${SHMAN_PDIR}${PackageGDB[Package]}/build"; return 1; }

	EchoInfo	"${PackageGDB[Name]}> Configure"
	../configure --prefix=/usr \
				--with-system-readline \
				--with-python=/usr/bin/python3 \
				1> /dev/null || { EchoTest KO ${PackageGDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDB[Name]}> make"
	make 1> /dev/null || { EchoTest KO ${PackageGDB[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageGDB[Name]}> make check"
	# make check 1> /dev/null || { EchoTest KO ${PackageGDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDB[Name]}> make -C gdb install"
	make -C gdb install 1> /dev/null || { EchoTest KO ${PackageGDB[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageGDB[Name]}> make -C gdbserver install"
	make -C gdbserver install 1> /dev/null || { EchoTest KO ${PackageGDB[Name]} && PressAnyKeyToContinue; return 1; };
}

# ls /usr/lib64/libglib-2.0.so.0.8200.5 

# tail -n 30 /var/log/gdm/*log 2>/dev/null
# dmesg | tail -n 30

# echo '#include <iostream>
# #include <string>

# int main() {
#     std::string message = "C++ std::string works!";
#     std::cout << message << std::endl;

#     std::string empty;
#     if (empty.empty()) {
#         std::cout << "Empty string is correctly recognized as empty." << std::endl;
#     }

#     const char* null_ptr = nullptr;
#     try {
#         std::string bad(null_ptr); // This should throw
#     } catch (const std::logic_error& e) {
#         std::cout << "Caught expected logic_error: " << e.what() << std::endl;
#     } catch (...) {
#         std::cout << "Caught some unexpected error." << std::endl;
#     }
#     return 0;
# }' > Temp.cpp 

# g++ Temp.cpp -o Temp.out && ./Temp.out || echo "Error: $?"

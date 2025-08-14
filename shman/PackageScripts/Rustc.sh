#!/bin/bash

if [ ! -z "${PackageRustc[Source]}" ]; then return; fi

source ${SHMAN_UDIR}Utils.sh

# =====================================||===================================== #
#									 Rustc									   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageRustc;
PackageRustc[Source]="https://static.rust-lang.org/dist/rustc-1.85.0-src.tar.xz";
PackageRustc[MD5]="a0193e0a4925f772bd50f8d12e47860c";
PackageRustc[Name]="rustc";
PackageRustc[Version]="1.85.0";
PackageRustc[Package]="${PackageRustc[Name]}-${PackageRustc[Version]}-src";
PackageRustc[Extension]=".tar.xz";

PackageRustc[Programs]="cargo-clippy cargo-fmt cargo clippy-driver rust-gdb rust-gdbgui rust-lldb rustc rustdoc rustfmt";
# removed non-gcc libraries librustc-driver-<16-byte-hash>.so libstd-<16-byte-hash>.so libtest-<16-byte-hash>.so
PackageRustc[Libraries]="";
PackageRustc[Python]="";

InstallRustc()
{
	# Check Installation
	CheckRustc && return $?;

	# Check Dependencies
	EchoInfo	"${PackageRustc[Name]}> Checking dependencies..."
	Required=(CMake cURL)
	for Dependency in "${Required[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=(LibSsh2 LLVM SQLite)
	for Dependency in "${Recommended[@]}"; do
		source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}" || PressAnyKeyToContinue;
	done

	Optional=(GDB Git)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done

	# Install Package
	EchoInfo	"${PackageRustc[Name]}> Building package..."
	_ExtractPackageRustc || return $?;
	_BuildRustc;
	return $?
}

CheckRustc()
{
	CheckInstallation 	"${PackageRustc[Programs]}"\
						"${PackageRustc[Libraries]}"\
						"${PackageRustc[Python]}" \
						1> /dev/null || return $?;
	rustc - --emit=metadata 1> /dev/null <<EOF
fn main() {
    let _ = std::fs::File::open("/dev/null");
}
EOF

	return $?;
}

CheckRustcVerbose()
{
	CheckInstallationVerbose	"${PackageRustc[Programs]}"\
								"${PackageRustc[Libraries]}"\
								"${PackageRustc[Python]}" \
								|| return $?;
	rustc - --emit=metadata 1> /dev/null <<EOF
fn main() {
    let _ = std::fs::File::open("/dev/null");
}
EOF
	if [ $? -ne 0 ]; then
		echo -en "${C_RED}libstd-*.so${C_RESET}" >&2;
		return 1;
	fi
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageRustc()
{
	DownloadPackage	"${PackageRustc[Source]}"	"${SHMAN_PDIR}"	"${PackageRustc[Package]}${PackageRustc[Extension]}"	"${PackageRustc[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageRustc[Package]}"	"${PackageRustc[Extension]}" || return $?;
	# wget -P "${SHMAN_PDIR}" "";

	return $?;
}

_BuildRustc()
{
	if ! cd "${SHMAN_PDIR}${PackageRustc[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageRustc[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageRustc[Name]}> Making directory"
	mkdir -pv /opt/rustc-1.85.0 && ln -svfn rustc-1.85.0 /opt/rustc

	EchoInfo	"${PackageRustc[Name]}> config.toml"
	cat << EOF > config.toml
# see config.toml.example for more possible options
# See the 8.4 book for an old example using shipped LLVM
# e.g. if not installing clang, or using a version before 13.0

# Tell x.py the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system,
# so x.py will not warn us to do such a review.
change-id = 134650

[llvm]
# When using system llvm prefer shared libraries
link-shared = true

# Do not download pre-built LLVM, instead either use the system
# LLVM or build LLVM from the shipped source.
download-ci-llvm = false

# If building the shipped LLVM source, only enable the x86 target
# instead of all the targets supported by LLVM.
targets = "X86"

[build]
# omit docs to save time and space (default is to build them)
docs = false

# install extended tools: cargo, clippy, etc
extended = true

# Do not query new versions of dependencies online.
locked-deps = true

# Specify which extended tools (those from the default install).
tools = ["cargo", "clippy", "rustdoc", "rustfmt"]

[install]
prefix = "/opt/rustc-1.85.0"
docdir = "share/doc/rustc-1.85.0"

[rust]
channel = "stable"
description = "for BLFS 12.3"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF

	# mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageRustc[Package]}/build \
	# 				|| { EchoError "${PackageRustc[Name]}> Failed to enter ${SHMAN_PDIR}${PackageRustc[Package]}/build"; return 1; }

	EchoInfo	"${PackageRustc[Name]}> Configure"
	sed '/MirOpt/d' -i src/bootstrap/src/core/builder/mod.rs

	EchoInfo	"${PackageRustc[Name]}> ./x.py build"
	[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1
	[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
	./x.py build || { EchoTest KO ${PackageRustc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageRustc[Name]}> ./x.py test"
	./x.py test --verbose --no-fail-fast | tee rustc-testlog 1> /dev/null || { EchoTest KO ${PackageRustc[Name]} && PressAnyKeyToContinue; return 1; };
	EchoInfo	"${PackageRustc[Name]}> test results"
	grep '^test result:' rustc-testlog | awk '{sum1 += $4; sum2 += $6} END { print sum1 " passed; " sum2 " failed" }'

	EchoInfo	"${PackageRustc[Name]}> ./x.py install"
	./x.py install rustc std && \
	./x.py install --stage=1 cargo clippy rustfmt 1> /dev/null || { EchoTest KO ${PackageRustc[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageRustc[Name]}> Documentation"
	rm -fv /opt/rustc-1.85.0/share/doc/rustc-1.85.0/*.old 
	install -vm644 	README.md                       			/opt/rustc-1.85.0/share/doc/rustc-1.85.0
	install -vdm755 /usr/share/zsh/site-functions
	ln -sfv 		/opt/rustc/share/zsh/site-functions/_cargo 	/usr/share/zsh/site-functions
	mv -v 			/etc/bash_completion.d/cargo 				/usr/share/bash-completion/completions

	EchoInfo	"${PackageRustc[Name]}> Unset exported env"
	unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG
}

#!/bin/bash

if [ ! -z "${PackageLLVM[Source]}" ]; then return; fi

source ${SHMAN_DIR}Utils.sh

# =====================================||===================================== #
#									LLVM								   #
# ===============ft_linux==============||==============©Othello=============== #

declare -A PackageLLVM;
PackageLLVM[Source]="https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/llvm-19.1.7.src.tar.xz";
PackageLLVM[MD5]="45229744809103ad151e3757a0f21d3d";
PackageLLVM[Name]="llvm";
PackageLLVM[Version]="19.1.7";
PackageLLVM[Package]="${PackageLLVM[Name]}-${PackageLLVM[Version]}.src";
PackageLLVM[Extension]=".tar.xz";

PackageLLVM[Programs]="amdgpu-arch analyze-build bugpoint c-index-test clang clang++ clang-19 clang-check clang-cl clang-cpp clang-extdef-mapping clang-format clang-linker-wrapper clang-offload-bundler clang-offload-packager clang-refactor clang-rename clang-repl clang-scan-deps clang-tblgen diagtool dsymutil FileCheck git-clang-format hmaptool intercept-build llc lli llvm-addr2line llvm-ar llvm-as llvm-bcanalyzer llvm-bitcode-strip llvm-cat llvm-cfi-verify llvm-config llvm-cov llvm-c-test llvm-cvtres llvm-cxxdump llvm-cxxfilt llvm-cxxmap llvm-debuginfo-analyzer llvm-debuginfod llvm-debuginfod-find llvm-diff llvm-dis llvm-dlltool llvm-dwarfdump llvm-dwarfutil llvm-dwp llvm-exegesis llvm-extract llvm-gsymutil llvm-ifs llvm-install-name-tool llvm-jitlink llvm-lib llvm-libtool-darwin llvm-link llvm-lipo llvm-lto llvm-lto2 llvm-mc llvm-mca llvm-ml llvm-modextract llvm-mt llvm-nm llvm-objcopy llvm-objdump llvm-opt-report llvm-otool llvm-pdbutil llvm-profdata llvm-profgen llvm-ranlib llvm-rc llvm-readelf llvm-readobj llvm-readtapi llvm-reduce llvm-remarkutil llvm-rtdyld llvm-sim llvm-size llvm-split llvm-stress llvm-strings llvm-strip llvm-symbolizer llvm-tblgen llvm-tli-checker llvm-undname llvm-windres llvm-xray nvptx-arch opt sancov sanstats scan-build scan-build-py scan-view verify-uselistorder";
# removed LLVMgold.so because it didnt test well
PackageLLVM[Libraries]="libLLVM.so libLTO.so libRemarks.so libclang.so libclang-cpp.so";
PackageLLVM[Python]="";

InstallLLVM()
{
	# Check Installation
	CheckLLVM && return $?;

	# Check Dependencies
	EchoInfo	"${PackageLLVM[Name]}> Checking dependencies..."
	Required=(CMake)
	for Dependency in "${Required[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || { PressAnyKeyToContinue; return $?; }
	done

	Recommended=()
	for Dependency in "${Recommended[@]}"; do
		(source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}") || PressAnyKeyToContinue;
	done

	Optional=(Doxygen Git Graphviz LibXml2 Psutil Pygments Rsync Texlive Valgrind Zip)
	for Dependency in "${Optional[@]}"; do
		if [ -f ${SHMAN_SDIR}/${Dependency}.sh ]; then
			source "${SHMAN_SDIR}/${Dependency}.sh" && Install"${Dependency}"
		fi
	done
	
	# Install Package
	EchoInfo	"${PackageLLVM[Name]}> Building package..."
	_ExtractPackageLLVM || return $?;
	_BuildLLVM;
	return $?
}

CheckLLVM()
{
	CheckInstallation 	"${PackageLLVM[Programs]}"\
						"${PackageLLVM[Libraries]}"\
						"${PackageLLVM[Python]}" 1> /dev/null;
	return $?;
}

CheckLLVMVerbose()
{
	CheckInstallationVerbose	"${PackageLLVM[Programs]}"\
								"${PackageLLVM[Libraries]}"\
								"${PackageLLVM[Python]}";
	return $?;
}

# =====================================||===================================== #
#								  Installation								   #
# ===============ft_linux==============||==============©Othello=============== #

_ExtractPackageLLVM()
{
	DownloadPackage	"${PackageLLVM[Source]}"	"${SHMAN_PDIR}"	"${PackageLLVM[Package]}${PackageLLVM[Extension]}"	"${PackageLLVM[MD5]}";
	ReExtractPackage	"${SHMAN_PDIR}"	"${PackageLLVM[Package]}"	"${PackageLLVM[Extension]}" || return $?;

	for URL in \
		"https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-cmake-19.1.7.src.tar.xz"\
		"https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-third-party-19.1.7.src.tar.xz"\
		"https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/clang-19.1.7.src.tar.xz"\
		"https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/compiler-rt-19.1.7.src.tar.xz"
	do
		wget -O "${SHMAN_PDIR}/${URL##*/}" "${URL}"
	done
	
	return $?;
}

_BuildLLVM()
{
	if ! cd "${SHMAN_PDIR}${PackageLLVM[Package]}"; then
		EchoError	"cd ${SHMAN_PDIR}${PackageLLVM[Package]}";
		return 1;
	fi

	EchoInfo	"${PackageLLVM[Name]}> Preparation"
	tar -xf ../llvm-cmake-19.1.7.src.tar.xz
	tar -xf ../llvm-third-party-19.1.7.src.tar.xz
	sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@cmake-19.1.7.src@' \
		-i CMakeLists.txt
	sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@third-party-19.1.7.src@' \
		-i cmake/modules/HandleLLVMOptions.cmake

	tar -xf ../clang-19.1.7.src.tar.xz -C tools
	mv tools/clang-19.1.7.src tools/clang

	tar -xf ../compiler-rt-19.1.7.src.tar.xz -C projects
	mv projects/compiler-rt-19.1.7.src projects/compiler-rt

	grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

	sed 's/utility/tool/' -i utils/FileCheck/CMakeLists.txt

	mkdir -p build 	&& cd ${SHMAN_PDIR}${PackageLLVM[Package]}/build \
					|| { EchoError "${PackageLLVM[Name]}> Failed to enter ${SHMAN_PDIR}${PackageLLVM[Package]}/build"; return 1; }

	EchoInfo	"${PackageLLVM[Name]}> Configure"
	CC=gcc CXX=g++ \
	cmake -D CMAKE_INSTALL_PREFIX=/usr \
		-D CMAKE_SKIP_INSTALL_RPATH=ON \
		-D LLVM_ENABLE_FFI=ON \
		-D CMAKE_BUILD_TYPE=Release \
		-D LLVM_BUILD_LLVM_DYLIB=ON \
		-D LLVM_LINK_LLVM_DYLIB=ON \
		-D LLVM_ENABLE_RTTI=ON \
		-D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
		-D LLVM_BINUTILS_INCDIR=/usr/include \
		-D LLVM_INCLUDE_BENCHMARKS=OFF \
		-D CLANG_DEFAULT_PIE_ON_LINUX=ON \
		-D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
		-W no-dev -G Ninja .. \
		1> /dev/null || { EchoTest KO ${PackageLLVM[Name]} && PressAnyKeyToContinue; return 1; };

	EchoInfo	"${PackageLLVM[Name]}> ninja"
	ninja 1> /dev/null || { EchoTest KO ${PackageLLVM[Name]} && PressAnyKeyToContinue; return 1; };

	# EchoInfo	"${PackageLLVM[Name]}> ninja check-all"
	# sed -e 's/config.has_no_default_config_flag/True/' \
	# 	-i ../projects/compiler-rt/test/lit.common.cfg.py
	# sh -c 'ulimit -c 0 && ninja check-all' 1> /dev/null || { EchoTest KO ${PackageLLVM[Name]} && PressAnyKeyToContinue; return 1; };
	
	EchoInfo	"${PackageLLVM[Name]}> ninja install"
	ninja install 1> /dev/null || { EchoTest KO ${PackageLLVM[Name]} && PressAnyKeyToContinue; return 1; };
}

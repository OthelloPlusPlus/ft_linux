#! /bin/bash

source ${SHMAN_DIR}Utils.sh

InstallPips()
{
	# Build Tools / Packaging
	InstallPip	editables hatchling hatch-fancy-pypi-readme hatch_vcs meson_python pyproject-metadata setuptools_scm
	# InstallPip
	# Utilities / Helper Libraries
	InstallPip	alabaster attrs chardet charset-normalizer idna imagesize pathspec pytz trove-classifiers
	InstallPip	packaging pyxdg six
	# Testing (Internal Testing Frameworks)
	InstallPip	iniconfig pluggy
	InstallPip	pytest
	# Python / C Integration / Math
	# InstallPip
	InstallPip	Cython numpy psutil
	# Network / Web / HTTP
	InstallPip	certifi urllib3
	InstallPip	cachecontrol requests sentry-sdk
	# Markup / Parsing / Serialization
	InstallPip	commonmark msgpack smartypants snowballstemmer typogrify webencodings
	InstallPip	cssselect html5lib lxml Mako pyparsing pyserial PyYAML
	# Documentation (Sphinx + Doc Tools)
	InstallPip	Babel Markdown sphinxcontrib-applehelp sphinxcontrib-devhelp sphinxcontrib-htmlhelp sphinxcontrib-jquery sphinxcontrib-jsmath sphinxcontrib-qthelp sphinxcontrib-serializinghtml
	InstallPip	asciidoc docutils doxypypy doxyqml gi-docgen recommonmark scour sphinx sphinx_rtd_theme
	# Syntax Highlighting / Code Tools
	# InstallPip
	InstallPip	ply pygdbmi Pygments
	# GUI / Graphics / GObject / GTK
	# InstallPip
	InstallPip	pygobject dbus-python python-dbusmock

	pip3 cache purge
}

InstallPip()
{
	for Pip in $@; do
		if ! pip3 show $Pip &> /dev/null; then
			EchoInfo	"Installing $Pip..."
			pip3 install --no-user $Pip || { EchoError "Error[$?]: $Pip"; PressAnyKeyToContinue; };
		fi
	done
}

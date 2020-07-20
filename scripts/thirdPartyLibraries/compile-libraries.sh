#!/usr/bin/env bash

root_dir=$PWD

# ASDF NEEDS DEFINED ENV VARIABLES:
# $ANDROID_NDK_ROOT
# $ANDROID_NDK_HOST
# $ANDROID_NDK_COMPILER
# $ANDROID_LIBRARIES
# $ANDROID_NDK_PLATFORM is not used in this script, but it is used in some of the library rules scripts
#   eg. library-rules/libjpeg-turbo.sh
#       library-rules/openssl.sh
#   It is in the form of "android-16" or "android-21"

# sets a few environment variables
set_toolchain () {
	local bin_dir="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"

	for bin in $(find $bin_dir -maxdepth 1 -name "$ANDROID_NDK_HOST-*"); do
		local bin_name=$(basename $bin)
		bin_name=${bin_name#$ANDROID_NDK_HOST-}
		local var_name=${bin_name^^}
		var_name=${var_name//+/X}
		var_name=$(echo -n $var_name |sed "s/[^A-Z0-9_]/_/g")
		export $var_name=$bin
	done

	export CC=$bin_dir/$ANDROID_NDK_COMPILER-clang
	export CXX=$bin_dir/$ANDROID_NDK_COMPILER-clang++

	export ACLOCAL_PATH=$ANDROID_LIBRARIES/share/aclocal
	export PKG_CONFIG_LIBDIR=$ANDROID_LIBRARIES/lib
	export PKG_CONFIG_PATH=$ANDROID_LIBRARIES/lib/pkgconfig
}

# get_dependencies() method is used in library_rules scripts!
get_dependencies () {
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $@
}

do_fetch () {
	if [ -d $library*/ ]; then
		rm -r $library*/
	fi
	DEBIAN_FRONTEND=noninteractive apt-get source -y $library
	cd $library*/
}

do_configure () {
	./configure --prefix=$ANDROID_LIBRARIES --host=$ANDROID_NDK_HOST --disable-shared $@
}

do_make () {
	make -j$num_cpus $@ && \
	make install $@
}

num_cpus=$(nproc || grep -c ^processor /proc/cpuinfo || echo 1)
build_library () {
	host=$ANDROID_NDK_HOST
	prefix=$ANDROID_LIBRARIES
	set -xe
	local rules_file="$root_dir/library-rules/$library.sh"
	if [ -f "$rules_file" ]; then
		. "$rules_file"
	else
		do_fetch
		do_configure
		do_make
	fi

	return 0
}

warning () {
	echo $@ >&2
}

fatal_error () {
	if [ "$library" != "" ]; then
		warning "$library build failed!"
	else
		warning "Build failed!"
	fi
	warning "You may now connect to the container with docker exec to inspect"
	warning "the environment, then hit Ctrl+C here to end the build."
	tail -f /dev/null
	exit 1
}

set -eE
trap fatal_error ERR

libraries=$@

set_toolchain
echo $PATH
for library in $libraries; do
	echo "Building $library"
	build_library $library
	cd "$root_dir"
done

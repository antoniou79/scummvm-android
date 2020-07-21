#!/bin/sh
# VANILLA_PATH should be set after a call to the plain setenv_android.sh
if [ "$VANILLA_PATH" == "" ]; then
	echo "Error: Variable VANILLA_PATH is not set"
elif [ "$ANDROID_USR_OPT_PATH" == "" ]; then
	echo "Error: Variable ANDROID_USR_OPT_PATH is not set"
elif [ "$ANDROID_TOOLCHAIN" == "" ]; then
	echo "Error: Variable ANDROID_TOOLCHAIN is not set"
else
	export ANDROID_3RD_LIBS_PATH=${ANDROID_USR_OPT_PATH}/libraries/i686
	export PATH=${ANDROID_TOOLCHAIN}/bin:${ANDROID_3RD_LIBS_PATH}/bin:${VANILLA_PATH}
	export CXXFLAGS="-I${ANDROID_3RD_LIBS_PATH}/include"
	export LDFLAGS="-L${ANDROID_3RD_LIBS_PATH}/lib"
	export PKG_CONFIG_LIBDIR=${ANDROID_3RD_LIBS_PATH}/lib/pkgconfig
		
	echo "To build for Android x86..."
	echo "From ScummVM source folder you may run *one* of the following configure commands or your own custom configure:"
	echo "   make clean; ./configure --enable-all-engines --enable-verbose-build --host=android-x86 --enable-debug"
	echo "   make clean; ./configure --disable-all-unstable-engines --enable-verbose-build --host=android-x86 --enable-debug"
	echo "   make clean; ./configure --disable-all-engines --enable-engine=<engine B> --enable-engine=<engine A> --host=android-x86 --enable-debug"
	echo "   make clean; ./configure --enable-verbose-build --host=android-x86 --enable-release --disable-debug"
	echo "And finally run:"
	echo "   make -j$(nproc)"
fi

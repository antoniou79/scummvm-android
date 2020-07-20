#!/bin/sh
# VANILLA_PATH should be set after a call to the plain setenv_android.sh
if [ "$VANILLA_PATH" == "" ]; then
	echo "Error: Variable VANILLA_PATH is not set! Please run script setenv-android.sh first!"
else
	export ANDROID_TARGET_NDK_TOOLCHPREFIX=aarch64-linux-android
	export ANDROID_TARGET_NDK_LIBS_SUBPATH=aarch64
	
	export PATH=${ANDROID_TOOLCHAIN}/bin:${ANDROID_NDK_ROOT}/toolchains/${ANDROID_TARGET_NDK_TOOLCHPREFIX}-4.9/prebuilt/linux-x86_64/bin:$ANDROID_USR_OPT_PATH/libraries/${ANDROID_TARGET_NDK_LIBS_SUBPATH}/bin:$VANILLA_PATH
	export CPPFLAGS=
	export CXX="ccache aarch64-linux-android21-clang++"
	export CXXFLAGS="-isystem -i${ANDROID_TOOLCHAIN}/include -I${ANDROID_USR_OPT_PATH}/libraries/${ANDROID_TARGET_NDK_LIBS_SUBPATH}/include"
	export LDFLAGS="-L${ANDROID_USR_OPT_PATH}/libraries/${ANDROID_TARGET_NDK_LIBS_SUBPATH}/lib -L${ANDROID_TOOLCHAIN}/lib"
	
	export PKG_CONFIG_LIBDIR=${ANDROID_USR_OPT_PATH}/libraries/${ANDROID_TARGET_NDK_LIBS_SUBPATH}/lib/pkgconfig:${ANDROID_NDK_ROOT}/prebuilt/linux-x86_64/lib/pkgconfig

	echo "To build for Android ARMv8-A (arm64-v8a)..."
	echo "From ScummVM source folder you may run *one* of the following configure commands or your own custom configure:"
	echo "   make clean; ./configure --enable-all-engines --enable-verbose-build --host=android-arm64-v8a --enable-debug"
	echo "   make clean; ./configure --disable-all-unstable-engines --enable-verbose-build --host=android-arm64-v8a --enable-debug"
	echo "   make clean; ./configure --disable-all-engines --enable-engine=<engine B> --enable-engine=<engine A> --host=android-arm64-v8a --enable-debug"
	echo "   make clean; ./configure --enable-verbose-build --host=android-arm64-v8a --enable-release --disable-debug"
	echo "And finally run:"
	echo "   make -j$(nproc)"
fi

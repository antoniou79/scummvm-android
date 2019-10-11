#!/bin/sh

# VANILLA_PATH should be set after a call to the plain setenv_android.sh
export ANDROID_STANDALONE_TOOLCH=$ANDROID_NDK_HOME/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
export ANDROID_STANDALONE_TRIBLE=aarch64-linux-android
export PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH
export NDK_LOG=1
export NDK_PLATFORMS_ROOT=$ANDROID_NDK_HOME/platforms
export NDK_TOOLCHAINS_ROOT=$ANDROID_NDK_HOME/toolchains
export ADDR2LINE=$ANDROID_STANDALONE_TRIBLE-addr2line
export AR=$ANDROID_STANDALONE_TRIBLE-ar
export AS=$ANDROID_STANDALONE_TRIBLE-as
# clang++ is a wrapper script which sets up the Android API version correctly
#export CPPFLAGS=
export CXX="ccache $ANDROID_STANDALONE_TRIBLE-clang++"
export CXXFILT=$ANDROID_STANDALONE_TRIBLE-c++filt
export CXXFLAGS="-isystem $ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/include"
export LDFLAGS="-L$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/lib"
export CC=$ANDROID_STANDALONE_TRIBLE-clang
export CPP=$ANDROID_STANDALONE_TRIBLE-cpp
export DWP=$ANDROID_STANDALONE_TRIBLE-dwp
export ELFEDIT=$ANDROID_STANDALONE_TRIBLE-elfedit
export GXX=$ANDROID_STANDALONE_TRIBLE-g++
export GCC=$ANDROID_STANDALONE_TRIBLE-gcc
export GCOV=$ANDROID_STANDALONE_TRIBLE-gcov
export GCOV_TOOL=$ANDROID_STANDALONE_TRIBLE-gcov-tool
export GPROF=$ANDROID_STANDALONE_TRIBLE-gprof
export LD=$ANDROID_STANDALONE_TRIBLE-ld
export NM=$ANDROID_STANDALONE_TRIBLE-nm
export OBJCOPY=$ANDROID_STANDALONE_TRIBLE-objcopy
export OBJDUMP=$ANDROID_STANDALONE_TRIBLE-objdump
export RANLIB=$ANDROID_STANDALONE_TRIBLE-ranlib
export READELF=$ANDROID_STANDALONE_TRIBLE-readelf
export SIZE=$ANDROID_STANDALONE_TRIBLE-size
export STRINGS=$ANDROID_STANDALONE_TRIBLE-strings
export STRIP=$ANDROID_STANDALONE_TRIBLE-strip
export CCACHE_COMPRESS=1
export PKG_CONFIG_LIBDIR=$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/lib/pkgconfig

# for ScummVM
export ANDROID_NDK=$ANDROID_NDK_HOME/build
export ANDROID_SDK=$ANDROID_SDK_ROOT

echo "To build for Android ARMv8-A (arm64-v8a)..."
echo "From ScummVM source folder you may run *one* of the following configure commands or your own custom configure:"
echo "   make clean; ./configure --enable-all-engines --enable-verbose-build --host=android-arm64-v8a --enable-debug"
echo "   make clean; ./configure --disable-all-unstable-engines --enable-verbose-build --host=android-arm64-v8a --enable-debug"
echo "   make clean; ./configure --disable-all-engines --enable-engine=<engine B> --enable-engine=<engine A> --host=android-arm64-v8a --enable-debug"
echo "   make clean; ./configure --enable-verbose-build --host=android-arm64-v8a --enable-release --disable-debug"
echo "And finally run:"
echo "   make -j$(nproc)"

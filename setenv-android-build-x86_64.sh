#!/bin/sh

# VANILLA_PATH should be set after a call to the plain setenv_android.sh
export ANDROID_STANDALONE_TOOLCH=$ANDROID_NDK_HOME/toolchains/x86_64-4.9/prebuilt/linux-x86_64
export ANDROID_STANDALONE_TRIBLE=x86_64-linux-android
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

echo "From ScummVM source folder run:"
echo "make clean; ./configure --enable-all-engines --disable-engine=testbed --enable-verbose-build --host=android-x86_64 --enable-debug --disable-mt32emu"
echo "make -j$(nproc) && mv ScummVM-debug.apk SScummVM-debug-android-x86_64.apk"

SDL2_VERSION=2.0.10
#do_fetch
#
#export ANDROID_STANDALONE_TOOLCH=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
#export ANDROID_STANDALONE_TRIBLE=arm-linux-androideabi
#export PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

export NDK_MODULE_PATH=${ANDROID_NDK_HOME}/sources/android/cpufeatures

if [ ! -d SDL2-${SDL2_VERSION} ]
then
    if [ ! -f SDL2-${SDL2_VERSION}.tar.gz ]
    then
        wget https://libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz || exit 128
    fi
    tar xzf SDL2-${SDL2_VERSION}.tar.gz || exit 128
fi

cd SDL2-${SDL2_VERSION} || exit 128

patch -p1 < ../SDL2Configure.patch

mkdir -p ./src/extras/android/
cp ${ANDROID_NDK_HOME}/sources/android/cpufeatures/cpu-features.h ./include/
cp ${ANDROID_NDK_HOME}/sources/android/cpufeatures/cpu-features.c ./src/extras/android/

#CPPFLAGS="-I${ANDROID_NDK_HOME}/sources/android/cpufeatures -I${ANDROID_NDK_HOME}/sources/third_party/esd/include/" ./configure --prefix=$prefix --host=$host --disable-shared
# esd and gl2 cause linking issues - other subsystems could too. We only need libsdl2 for sdl2-net so they can safely be disabled
# TODO: do we need the events subsystem?
# TODO: can we remove more subsystems?
# TODO Test: if we can also disable the cpuinfo subsystem to avoid the shenanigans with copy pasting and cpu-features files and building them as part of the sdl static library
./configure --prefix=$prefix --host=$host --disable-shared --disable-audio --disable-video-wayland --disable-video-opengl

do_make

get_dependencies automake debhelper libtool

if [ ! -d tremor ]
then
    git clone -n https://gitlab.xiph.org/xiph/tremor.git && cd tremor || exit 128
    git checkout 7c30a66346199f3f09017a09567c6c8a3a0eedc8 || exit 128
else
    cd tremor || exit 128
fi

#OPTIONS=""
#if [ $host == "arm-linux-androideabi" ]; then
#	OPTIONS="--enable-low-accuracy"
#fi

#patch is needed for arm64 (aarch64 to be treated as Little Endian arm arch)
if [ $host == "aarch64-linux-android" ]; then
	patch -p1 < ../configure-tremor.patch
fi

autoreconf -fi

#do_configure $OPTIONS
do_configure
make
make install-data-am
make install-exec-am

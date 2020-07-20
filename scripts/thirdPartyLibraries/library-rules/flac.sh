#do_fetch
#do_configure
#do_make -C src/libFLAC
#do_make -C include

LIBFLAC_VERSION=1.3.3

if [ ! -d flac-${LIBFLAC_VERSION} ]
then
    if [ ! -f flac-${LIBFLAC_VERSION}.tar.gz ]
    then
        wget https://ftp.osuosl.org/pub/xiph/releases/flac/flac-${LIBFLAC_VERSION}.tar.xz || exit 128
    fi
    tar xf flac-${LIBFLAC_VERSION}.tar.xz || exit 128
fi

cd flac-${LIBFLAC_VERSION} || exit 128

## NDK r14b API 9 lacks defines for MIN and MAX so we add them explicitly to flac library
## - otherwise linkage errors occur at ScummVM compile time
#patch -p1 < ../macros-flac-1.3.3.patch

autoreconf -fi
do_configure --disable-doxygen-docs --disable-xmms-plugin --disable-cpplibs --disable-ogg
make -j$num_cpus -C src/libFLAC
make -C src/libFLAC install
# No need to build includes?
make -C include install

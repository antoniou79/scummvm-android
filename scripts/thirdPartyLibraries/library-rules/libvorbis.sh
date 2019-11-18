#do_fetch
get_dependencies automake debhelper libtool
LIBVORBIS_VERSION=1.3.6

if [ ! -d libvorbis-${LIBVORBIS_VERSION} ]
then
    if [ ! -f libvorbis-${LIBVORBIS_VERSION}.tar.gz ]
    then
        wget https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz || exit 128
    fi
    tar xzf libvorbis-${LIBVORBIS_VERSION}.tar.gz || exit 128
fi

cd libvorbis-${LIBVORBIS_VERSION} || exit 128

if [ $host == "i686-linux-android" ]
then
	patch -p1 < ../patch-x86-vorbis-clang.patch
fi

# Avoid compiling and installing doc
sed -ie 's/^\(SUBDIRS.*\) doc/\1/' Makefile.am

autoreconf -fi -I m4

do_configure
do_make -C lib
do_make -C include
make install-pkgconfigDATA
make install-m4dataDATA

#do_fetch

LIBOGG_VERSION=1.3.4

if [ ! -d libogg-${LIBOGG_VERSION} ]
then
    if [ ! -f libogg-${LIBOGG_VERSION}.tar.gz ]
    then
        wget https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz || exit 128
    fi
    tar xzf libogg-${LIBOGG_VERSION}.tar.gz || exit 128
fi

cd libogg-${LIBOGG_VERSION} || exit 128

do_configure
do_make -C src
do_make -C include
make install-m4dataDATA \
	install-pkgconfigDATA

#do_fetch

LIBCURL_VERSION=7.66.0

if [ ! -d curl-${LIBCURL_VERSION} ]
then
    if [ ! -f curl-${LIBCURL_VERSION}.tar.gz ]
    then
        wget https://curl.haxx.se/download/curl-${LIBCURL_VERSION}.tar.gz || exit 128
    fi
    tar xzf curl-${LIBCURL_VERSION}.tar.gz || exit 128
fi

cd curl-${LIBCURL_VERSION} || exit 128

#do_configure --with-ssl=$prefix
do_configure --without-ssl
do_make -C lib
do_make -C include
make install-pkgconfigDATA
make install-binSCRIPTS

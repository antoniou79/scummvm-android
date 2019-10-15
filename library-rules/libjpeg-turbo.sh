JPEGTURBO_VERSION=1.5.3

if [ ! -d libjpeg-turbo-${JPEGTURBO_VERSION} ]
then
    if [ ! -f libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz ]
    then
        wget https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz || exit 128
    fi
    tar xzf libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz || exit 128
fi

cd libjpeg-turbo-${JPEGTURBO_VERSION} || exit 128

if [ $host == "i686-linux-android" ]
then
#   https://github.com/libjpeg-turbo/libjpeg-turbo/issues/155
	do_configure --without-turbojpeg --with-pic
else
	do_configure --without-turbojpeg
fi

do_make -C simd
make  \
	install-libLTLIBRARIES \
	install-pkgconfigDATA \
	install-includeHEADERS \
	install-nodist_includeHEADERS

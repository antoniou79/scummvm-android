#do_fetch

LIBICONV_VERSION=1.16

if [ ! -d libiconv-${LIBICONV_VERSION} ]
then
    if [ ! -f libiconv-${LIBICONV_VERSION}.tar.gz ]
    then
        wget http://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz || exit 128
    fi
    tar xzf libiconv-${LIBICONV_VERSION}.tar.gz || exit 128
fi

cd libiconv-${LIBICONV_VERSION} || exit 128

do_configure
do_make

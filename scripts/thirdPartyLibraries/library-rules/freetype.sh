get_dependencies gcc libc6-dev automake debhelper libtool
#do_fetch
#tar xf freetype-2*.tar.bz2
#cd freetype*/

LIBFREETYPE_VERSION=2.10.1

if [ ! -d freetype-${LIBFREETYPE_VERSION} ]
then
    if [ ! -f freetype-${LIBFREETYPE_VERSION}.tar.gz ]
    then
        wget https://download.savannah.gnu.org/releases/freetype/freetype-${LIBFREETYPE_VERSION}.tar.gz || exit 128
    fi
    tar xzf freetype-${LIBFREETYPE_VERSION}.tar.gz || exit 128
fi

cd freetype-${LIBFREETYPE_VERSION} || exit 128

patch -p1 < ../configure-freetype.patch

do_configure --build="x86_64-linux-gnu"
do_make

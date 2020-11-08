get_dependencies gcc libc6-dev automake debhelper libtool
#do_fetch
#tar xf freetype-2*.tar.bz2
#cd freetype*/

# updated version to 2.10.4
# patch now includes setting (uncommenting) in include/freetype/config/ftoption.h the following:
# - FT_CONFIG_OPTION_SUBPIXEL_RENDERING
# - FT_CONFIG_OPTION_SYSTEM_ZLIB
# - FT_CONFIG_OPTION_USE_PNG

# based on https://www.freetype.org/freetype2/docs/reference/ft2-lcd_rendering.html#:~:text=FreeType%20provides%20two%20alternative%20subpixel%20rendering%20technologies.&text=ClearType%2Dstyle%20LCD%20rendering%20exploits,by%20a%20factor%20of%203.
LIBFREETYPE_VERSION=2.10.4

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

do_configure --build="x86_64-linux-gnu" --with-zlib=yes --with-png=yes
# run make but not in parallel mode (no -j argument)
# because for this library that tends to create issues during compilation and later on at detection
make
make install

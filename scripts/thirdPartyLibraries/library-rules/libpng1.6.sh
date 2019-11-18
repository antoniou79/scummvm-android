#do_fetch

LIBPNG_VERSION=1.6.37

if [ ! -d libpng-${LIBPNG_VERSION} ]
then
    if [ ! -f libpng-${LIBPNG_VERSION}.tar.gz ]
    then
        wget -O libpng-${LIBPNG_VERSION}.tar.gz https://github.com/glennrp/libpng/archive/v${LIBPNG_VERSION}.tar.gz || exit 128
    fi
    tar xzf libpng-${LIBPNG_VERSION}.tar.gz || exit 128
fi

cd libpng-${LIBPNG_VERSION} || exit 128

do_configure
make -j$num_cpus && \
make \
	install-libLTLIBRARIES \
	install-binSCRIPTS \
	install-pkgconfigDATA \
	install-pkgincludeHEADERS \
	install-nodist_pkgincludeHEADERS \
	install-header-links \
	install-library-links \
	install-libpng-pc && \
# install-libpng-config is needed by android toolchain for freetype2 compile
# freetype won't use the pkg-config entry for libpng, since it will report libz.pc to be missing
make install-libpng-config

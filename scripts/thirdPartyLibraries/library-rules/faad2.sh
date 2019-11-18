get_dependencies automake libtool
#do_fetch


LIBFAAD2_VERSION_UNDERSCORED=2_8_8

if [ ! -d faad2-${LIBFAAD2_VERSION_UNDERSCORED} ]
then
    if [ ! -f faad2-${LIBFAAD2_VERSION_UNDERSCORED}.tar.gz ]
    then
        wget -O faad2-${LIBFAAD2_VERSION_UNDERSCORED}.tar.gz https://github.com/knik0/faad2/archive/${LIBFAAD2_VERSION_UNDERSCORED}.tar.gz || exit 128
    fi
    tar xzf faad2-${LIBFAAD2_VERSION_UNDERSCORED}.tar.gz || exit 128
fi

cd faad2-${LIBFAAD2_VERSION_UNDERSCORED} || exit 128

# Avoid compiling and installing libfaad2_drm
sed -ie 's/^\(lib_LTLIBRARIES.*\) libfaad_drm.la/\1/' libfaad/Makefile.am

autoreconf -fi

do_configure
do_make -C libfaad

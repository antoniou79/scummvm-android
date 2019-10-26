get_dependencies automake libtool
#do_fetch

LIBFAAD2_VERSION_MAJ=2.8.0
LIBFAAD2_VERSION_SPECIFIC=2.8.8

if [ ! -d faad2-${LIBFAAD2_VERSION_SPECIFIC} ]
then
    if [ ! -f faad2-${LIBFAAD2_VERSION_SPECIFIC}.tar.gz ]
    then
        wget https://download.sourceforge.net/faac/faad2-src/faad2-${LIBFAAD2_VERSION_MAJ}/faad2-${LIBFAAD2_VERSION_SPECIFIC}.tar.gz || exit 128
    fi
    tar xzf faad2-${LIBFAAD2_VERSION_SPECIFIC}.tar.gz || exit 128
fi

cd faad2-${LIBFAAD2_VERSION_SPECIFIC} || exit 128

# Avoid compiling and installing libfaad2_drm
sed -ie 's/^\(lib_LTLIBRARIES.*\) libfaad_drm.la/\1/' libfaad/Makefile.am

autoreconf -fi

do_configure
do_make -C libfaad

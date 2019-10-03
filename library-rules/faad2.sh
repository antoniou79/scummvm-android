get_dependencies automake libtool
do_fetch
#autoreconf -i
# Avoid compiling and installing libfaad2_drm
sed -ie 's/^\(lib_LTLIBRARIES.*\) libfaad_drm.la/\1/' libfaad/Makefile.am

autoreconf -fi

do_configure
do_make -C libfaad

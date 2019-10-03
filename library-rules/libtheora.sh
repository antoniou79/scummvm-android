do_fetch

# libtheora has an outdated autotools config which does not know of androideabi,
# so replace it with a new one
dh_update_autotools_config

# Avoid compiling and installing doc
sed -ie 's/^\(SUBDIRS.*\) doc/\1/' Makefile.am

autoreconf -fi -I m4
#  --disable-doc is not a valid configure option for theora (v 1.1.1+dfsg1)
do_configure --disable-examples --disable-spec --disable-doc
do_make -C lib
do_make -C include
make install-pkgconfigDATA


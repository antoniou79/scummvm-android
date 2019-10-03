get_dependencies automake debhelper libtool
do_fetch

# has an outdated autotools config which does not know of androideabi,
# so replace it with a new one
dh_update_autotools_config

do_configure
make -j$num_cpus -C liba52 && \
make -C liba52 install && \
# No ned to build includes
make -C include install

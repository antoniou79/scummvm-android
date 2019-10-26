get_dependencies automake libtool
#do_fetch

if [ ! -d mpeg2dec ]
then
    git clone https://salsa.debian.org/multimedia-team/mpeg2dec.git || exit 128
fi

cd mpeg2dec || exit 128

patch -p1 < ../patch-mpeg2dec-confac.patch

## mpeg2dec has an outdated autotools config which does not know of androideabi,
## so replace it with a new one
rm -rf .auto
dh_update_autotools_config
autoreconf -i

# mpeg2dec includes non-PIC ARM assembly which is forbidden in Android 23+, so
# disable it from being used
sed -i 's/arm\*)/xxarmxx)/' configure

chmod +x configure

do_configure
make -j$num_cpus -C libmpeg2
make -C libmpeg2 install
# No need to build includes?
make -C include install

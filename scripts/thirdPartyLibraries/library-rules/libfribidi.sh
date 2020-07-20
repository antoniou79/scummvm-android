FRIBIDI_VERSION=1.0.10

if [ ! -d fribidi-${FRIBIDI_VERSION} ]
then
    if [ ! -f fribidi-${FRIBIDI_VERSION}.tar.xz ]
    then
        wget https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.xz || exit 128
    fi
    tar xf fribidi-${FRIBIDI_VERSION}.tar.xz || exit 128
fi

cd fribidi-${FRIBIDI_VERSION} || exit 128

do_configure
do_make

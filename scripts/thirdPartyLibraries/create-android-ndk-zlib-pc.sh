#!/usr/bin/env bash

# We need a pc (pkgconfig file) for the zlib mainly that is integrated in the NDK
# and some of our third party libraries check for the existence of this pc file as a requirement 
# to detect it (or other packages that depend on zlib)
# eg. freetype, needs zlib, and also libpng (which depends on zlib)
# script based on: https://cgit.freedesktop.org/mesa/mesa/tree/.gitlab-ci/create-android-ndk-pc.sh
ndkminapi="$1"

sysroot=$ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot

pcdir=${ANDROID_LIBRARIES}/lib/pkgconfig
mkdir -p $pcdir

# Determine zlib version (the same way original zlib configure does)
ZLIB_VERSION=$(sed -n -e '/VERSION "/s/.*"\(.*\)".*/\1/p' < ${sysroot}/usr/include/zlib.h)
if [ -z "${ZLIB_VERSION}" ]; then
	error "Can't find Android zlib version"
fi

cat >$pcdir/zlib.pc <<EOF
prefix=$sysroot
exec_prefix=$sysroot
libdir=$sysroot/usr/lib/${ANDROID_NDK_HOST}/$ndkminapi
sharedlibdir=$sysroot/usr/lib/${ANDROID_NDK_HOST}
includedir=$sysroot/usr/include

Name: zlib
Description: zlib compression library
Version: ${ZLIB_VERSION}

Requires:
Libs: -L$sysroot/usr/lib/${ANDROID_NDK_HOST}/$ndkminapi -lz
Cflags: -I$sysroot/usr/include -I${ANDROID_LIBRARIES}/include
EOF


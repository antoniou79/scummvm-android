#do_fetch

LIBCURL_VERSION=7.71.1

if [ $host == "arm-linux-androideabi" ]
	then
	#CURL_TARGET="android-arm"
	#OPTIONS="--target=armv5te-linux-androideabi"
	#LDFLAGSADDED=""
	#LIBSADDED="-ldl -latomic"
	# For arm-v7a:
	OPTIONS="--target=armv7a-linux-androideabi"
	LDFLAGSADDED="-Wl,--fix-cortex-a8"
	LIBSADDED="-ldl -latomic"
elif [ $host == "aarch64-linux-android" ]
	then
	CURL_TARGET="android-arm64"
    OPTIONS=""
	LDFLAGSADDED=""
	LIBSADDED="-ldl"
elif [ $host == "i686-linux-android" ]
	then
	CURL_TARGET="android-x86"
    OPTIONS=""
	LDFLAGSADDED=""
	LIBSADDED="-ldl -latomic"
elif [ $host == "x86_64-linux-android" ]
	then
	CURL_TARGET="android-x86_64"
    OPTIONS=""
	LDFLAGSADDED=""
	LIBSADDED="-ldl"
else
	echo "Invalid host architecture was set!" && exit 128
fi


if [ ! -d curl-${LIBCURL_VERSION} ]
then
    if [ ! -f curl-${LIBCURL_VERSION}.tar.gz ]
    then
        wget https://curl.haxx.se/download/curl-${LIBCURL_VERSION}.tar.gz || exit 128
    fi
    tar xzf curl-${LIBCURL_VERSION}.tar.gz || exit 128
fi

cd curl-${LIBCURL_VERSION} || exit 128

LIBS="${LIBS} ${LIBSADDED}" LDFLAGS="${LDFLAGS} ${LDFLAGSADDED}" ./configure --prefix=$prefix --host=$host --disable-shared --enable-static ${OPTIONS} --with-ssl=$prefix --libdir=$prefix/lib --includedir=$prefix/include
do_make -C lib
do_make -C include
make install-pkgconfigDATA install-binSCRIPTS

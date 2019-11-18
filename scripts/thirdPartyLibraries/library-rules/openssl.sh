
OPENSSL_VERSION=1_1_1d

# needs env vars:
# ANDROID_NDK_HOME to be set to root of NDK folder
# PLATFORM_MIN_API_VERSION
# PLATFORM_MIN_API_x64_VERSION

# https://github.com/openssl/openssl/blob/master/NOTES.ANDROID
# based on $host variable, decide on the value of the SSL_TARGET var and other options
# use -fno-integrated-as when using clang
if [ $host == "arm-linux-androideabi" ]
	then
	SSL_TARGET="android-arm"
	OPTIONS="--target=armv5te-linux-androideabi -fno-integrated-as -mthumb -fPIC -latomic -D__ANDROID_API__=${PLATFORM_MIN_API_VERSION} no-threads" 
	# TODO for arm-v7a it would be: (TODO ERRORS!!!!)
	#OPTIONS="--target=armv7a-linux-androideabi -fno-integrated-as -Wl,--fix-cortex-a8 -fPIC -latomic -D__ANDROID_API__=${PLATFORM_MIN_API_VERSION} no-threads"
elif [ $host == "aarch64-linux-android" ]
	then
	SSL_TARGET="android-arm64"
	OPTIONS="-fPIC -fno-integrated-as -D__ANDROID_API__=${PLATFORM_MIN_API_x64_VERSION}"
elif [ $host == "i686-linux-android" ]
	then
	SSL_TARGET="android-x86"
	# TODO do we need -fPIC?
	OPTIONS="-fno-integrated-as -latomic -D__ANDROID_API__=${PLATFORM_MIN_API_VERSION} no-threads"
elif [ $host == "x86_64-linux-android" ]
	then
	SSL_TARGET="android-x86_64"
	OPTIONS="-fno-integrated-as -fPIC -D__ANDROID_API__=${PLATFORM_MIN_API_x64_VERSION}"
else
	echo "Invalid host architecture was set!" && exit 128
fi


if [ ! -d openssl-OpenSSL_${OPENSSL_VERSION} ]
then
    if [ ! -f OpenSSL_${OPENSSL_VERSION}.tar.gz ]
    then
        wget https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VERSION}.tar.gz || exit 128
    fi
    tar xzf OpenSSL_${OPENSSL_VERSION}.tar.gz || exit 128
fi

cd openssl-OpenSSL_${OPENSSL_VERSION} || exit 128

##### build-function #####
build_the_thing() {
	# TODO proper options as in scummvm configure for armeabi v5te vs armv7
	# Don't use -static! (according to instructions it may cause unexpected behavior. Use no-shared (and maybe also no-threads).
	CC=clang ./Configure $SSL_TARGET $OPTIONS no-shared --prefix=$prefix
	make depend || exit 128 
	make || exit 128 
	make install_sw || exit 128
	make install_ssldirs || exit 128
#	make install DESTDIR=$DESTDIR || exit 128
#	make -j$num_cpus build_libs || exit 128
#	make install_dev || exit 128
}
build_the_thing
echo "Success"

OPENSSL_VERSION=1_1_1g

# needs env vars:
# ANDROID_NDK_ROOT to be set to root of NDK folder
# ANDROID_NDK_PLATFORM has to be set to "android-16" or "android-21" or other version

ANDROID_NDK_PLATFORM_LEVEL=${ANDROID_NDK_PLATFORM#android-}
#export PATH=$PATH:$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin

export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT

# REFERENCE NOTES:
# https://github.com/openssl/openssl/blob/OpenSSL_1_1_1g/NOTES.ANDROID
if [ $host == "arm-linux-androideabi" ]; then
	OPTIONS="android-arm --target=armv7a-linux-androideabi$ANDROID_NDK_PLATFORM_LEVEL"
elif [ $host == "aarch64-linux-android" ]; then
	OPTIONS="android-arm64 --target=aarch64-linux-android$ANDROID_NDK_PLATFORM_LEVEL"
elif [ $host == "i686-linux-android" ]; then
	OPTIONS="android-x86 --target=i686-linux-android$ANDROID_NDK_PLATFORM_LEVEL"
elif [ $host == "x86_64-linux-android" ]; then
	OPTIONS="android-x86_64 --target=x86_64-linux-androideabi$ANDROID_NDK_PLATFORM_LEVEL"
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
	# ANDROID_NDK_HOME was renamed to ANDROID_NDK_ROOT in yet unreleaded openssl version
	# https://github.com/openssl/openssl/blob/master/NOTES.ANDROID
	# 1.1.1g still needs ANDROID_NDK_ΗΟΜΕ
	ANDROID_NDK_HOME=$ANDROID_NDK_ROOT ./Configure $OPTIONS -fPIC -latomic -D__ANDROID_API__=$ANDROID_NDK_PLATFORM_LEVEL no-shared no-threads --prefix=$prefix
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

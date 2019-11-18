get_dependencies cmake
JPEGTURBO_VERSION=2.0.3

if [ ! -d libjpeg-turbo-${JPEGTURBO_VERSION} ]
then
    if [ ! -f libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz ]
    then
#       wget https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz || exit 128
       wget -O libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEGTURBO_VERSION}.tar.gz || exit 128
    fi
    tar xzf libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz || exit 128
fi

cd libjpeg-turbo-${JPEGTURBO_VERSION} || exit 128

## https://github.com/libjpeg-turbo/libjpeg-turbo/blob/master/BUILDING.md
##TOOLCHAIN={"gcc" or "clang"-- "gcc" must be used with NDK r16b and earlier, and "clang" must be used with NDK r17c and later}
# TODO: Does the ANDROID_ABI=armeabi-v7a work for the android v5te case too? Do we need a separate cross-compilation for that?
if [ $host == "arm-linux-androideabi" ]
	then
	cmake -G"Unix Makefiles" \
		-DCMAKE_INSTALL_PREFIX=$prefix \
		-DANDROID_ABI=armeabi \
		-DANDROID_ARM_MODE=arm \
		-DANDROID_PLATFORM=android-${PLATFORM_MIN_API_VERSION} \
		-DANDROID_TOOLCHAIN=gcc \
		-DCMAKE_ASM_FLAGS="--target=arm-linux-androideabi${PLATFORM_MIN_API_VERSION}" \
		-DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
		-DCMAKE_POSITION_INDEPENDENT_CODE=OFF \
		-DENABLE_SHARED=OFF -DWITH_TURBOJPEG=OFF \
		.
elif [ $host == "aarch64-linux-android" ]
	then
	cmake -G"Unix Makefiles" \
		-DCMAKE_INSTALL_PREFIX=$prefix \
		-DANDROID_ABI=arm64-v8a \
		-DANDROID_ARM_MODE=arm \
		-DANDROID_PLATFORM=android-${PLATFORM_MIN_API_x64_VERSION} \
		-DANDROID_TOOLCHAIN=gcc \
		-DCMAKE_ASM_FLAGS="--target=aarch64-linux-android${PLATFORM_MIN_API_x64_VERSION}" \
		-DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
		-DCMAKE_POSITION_INDEPENDENT_CODE=OFF \
		-DENABLE_SHARED=OFF -DWITH_TURBOJPEG=OFF \
		.
elif [ $host == "i686-linux-android" ]
	then
	cmake -G"Unix Makefiles" \
		-DCMAKE_INSTALL_PREFIX=$prefix \
		-DANDROID_ABI=x86 \
		-DANDROID_PLATFORM=android-${PLATFORM_MIN_API_VERSION} \
		-DANDROID_TOOLCHAIN=gcc \
		-DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-DENABLE_SHARED=OFF -DWITH_TURBOJPEG=OFF \
		.
elif [ $host == "x86_64-linux-android" ]
	then
	cmake -G"Unix Makefiles" \
		-DCMAKE_INSTALL_PREFIX=$prefix \
		-DANDROID_ABI=x86_64 \
		-DANDROID_PLATFORM=android-${PLATFORM_MIN_API_x64_VERSION} \
		-DANDROID_TOOLCHAIN=gcc \
		-DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-DENABLE_SHARED=OFF -DWITH_TURBOJPEG=OFF \
		.
else
	echo "invalid host architecture set!" && exit 128
fi

do_make

#if [ $host == "i686-linux-android" ]
#then
##   https://github.com/libjpeg-turbo/libjpeg-turbo/issues/155
#	do_configure --without-turbojpeg --with-pic
#else
#	do_configure --without-turbojpeg
#fi
#
#do_make -C simd
#make  \
#	install-libLTLIBRARIES \
#	install-pkgconfigDATA \
#	install-includeHEADERS \
#	install-nodist_includeHEADERS

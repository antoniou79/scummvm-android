# Debian "Stretch" 9.0 was initially released on June 17th, 2017 - Using: openjdk-8-jre-headless
#ARG DEFAULT_OS_IMAGE=debian:9.2
# Debian "Buster" 10.1 is stable since September 7th, 2019
#                      openjdk-8 is no longer supported in Debian 10+ as of yet
#                      openjdk-11 is the supported package, but it is not compatible with sdk-manager!
#                      We can install openjdk-8 by adding the Debian Unstable distribution (sid)
ARG DEFAULT_OS_IMAGE=debian:10.1
FROM ${DEFAULT_OS_IMAGE} AS compiler
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
#
# [FIRST STAGE]
# BUILDING THE TOOLCHAINS AND THIRD PARTY LIBs
#
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
USER root

# use SID repository to get openjdk-8
RUN echo "deb http://ftp.us.debian.org/debian sid main" >> /etc/apt/sources.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	       ccache \
	       dumb-init \
	       git \
	       gzip \
	       make \
	       python \
	       python-openssl \
	       rsync \
	       xz-utils \
	       zip \
	       ca-certificates \
	       openjdk-8-jre-headless \
	       unzip \
	       wget && \
	rm -rf /var/lib/apt/lists/*
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# SETTING UP THE NDK
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# As of yet (Nov 2019) - ScummVM is build with NDK r14b, to keep support for API level 9 devices (armeabi)
#
WORKDIR /tmp/compile
ENV ANDROID_USR_OPT_PATH=/opt/toolchains/android
ENV PLATFORM_MIN_API_VERSION=9
ENV PLATFORM_MIN_API_x64_VERSION=21
#ENV PLATFORM_MIN_API_x64_VERSION=23
ENV NDK_VERSION=r14b
RUN mkdir -p ${ANDROID_USR_OPT_PATH}/ && \
	wget --progress=bar:force:noscroll -O ndk.zip \
	     https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip && \
	unzip ndk.zip && \
	rm ndk.zip
#
# Set up standalone toolchains for android: ARM, ARM64, x86 (i686) and x86_64
# NDK r14b (and NDK versions older than NDK 19) needs to explicitly create standalone toolchains
# and we need that because we're cross compiliing a set of third party libraries for our toolchains
RUN cd android-ndk-*/ && \
	# standalone toolchain for "arm" (armeabi arm-v7a)
	# By default, an ARM Clang standalone toolchain will target the armeabi-v7a ABI. 
	# This can be overridden by passing the appropriate -march or -target option.
	python ./build/tools/make_standalone_toolchain.py \
	       --arch arm \
	       --api ${PLATFORM_MIN_API_VERSION} \
	       --install-dir ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION} \
	       --force && \
	# standalone toolchain for "arm64" (aarch64)
	python ./build/tools/make_standalone_toolchain.py \
	       --arch arm64 \
	       --api ${PLATFORM_MIN_API_x64_VERSION} \
	       --install-dir ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION} \
	       --force && \
	# standalone toolchain for "x86" (i686)
	python ./build/tools/make_standalone_toolchain.py \
	       --arch x86 \
	       --api ${PLATFORM_MIN_API_VERSION} \
	       --install-dir ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION} \
	       --force && \
	# standalone toolchain for "x86_64"
	python ./build/tools/make_standalone_toolchain.py \
	       --arch x86_64 \
	       --api ${PLATFORM_MIN_API_x64_VERSION} \
	       --install-dir ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION} \
	       --force && \
	# creating extra folders inside each toolchain and symbolic links from ndk's structure (from toolchains and platforms)
	# TODO: create separate folders for 3rd party libs for debug and release cross-compiled versions?
	# for arm
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-linux-androideabi/include && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-linux-androideabi/lib/pkgconfig && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-v7a-linux-androideabi/include && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-v7a-linux-androideabi/lib/pkgconfig && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/arm-linux-androideabi-4.9/prebuilt && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION} \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64 && \
	#
	# for arm64
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/aarch64-linux-android/include && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/aarch64-linux-android/lib/pkgconfig && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/aarch64-linux-android-4.9/prebuilt && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION} \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64  && \
	#
	# for x86
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/i686-linux-android/include && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/i686-linux-android/lib/pkgconfig && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86-4.9/prebuilt && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION} \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86-4.9/prebuilt/linux-x86_64 && \
	#
	# for x86_64
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/x86_64-linux-android/include && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/x86_64-linux-android/lib/pkgconfig && \
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86_64-4.9/prebuilt && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION} \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86_64-4.9/prebuilt/linux-x86_64 && \
	#
	# platform android-${PLATFORM_MIN_API_VERSION} symbolic links (to arm and x86)
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION} && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION}/arch-arm  && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION}/arch-x86 && \
	#
	# platform android-${PLATFORM_MIN_API_x64_VERSION} symbolic links (to arm64 and x86_64)
	mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION} && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION}/arch-arm64 && \
	ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot \
	      ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION}/arch-x86_64 && \
	#
	# Move folders "build" and "sources" as they are, from the original NDK folder
	mv build   ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/build   && \
	mv sources ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/sources && \
	mv ndk-build ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/ndk-build && \
	mv source.properties ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/source.properties && \
	# copy the uchar.h and complex.h file which are missing from API-9 platforms. We borrow them from the x64 platforms (should be ok). Needed for openssl building.
	cp ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot/usr/include/uchar.h \
		${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot/usr/include && \
	cp ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot/usr/include/uchar.h \
		${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot/usr/include && \
	cp ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot/usr/include/complex.h \
		${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot/usr/include && \
	cp ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot/usr/include/complex.h \
		${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot/usr/include && \
	rm -rf /tmp/compile
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# SETTING UP THE SDK
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
#
# We use build-tools r25.2.5 (from Jan 2017)
#
# ORIGINAL-TODO: We are forced to use this older version of the SDK tools because ScummVM
# uses the obsolete ndk-build process instead of the newer CMake+Gradle process.
ARG SDK_VERSION=r25.2.5
WORKDIR /tmp/compile
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg
RUN wget --progress=bar:force:noscroll -O sdk.zip \
	     https://dl.google.com/android/repository/tools_${SDK_VERSION}-linux.zip && \
	unzip sdk.zip -d ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86 && \
	rm sdk.zip && \
# we could probably prune tools files even more aggressively for space, if
# needed
	rm -rf \
	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/apps \
	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/lib/monitor-x86 \
	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/lib/monitor-x86_64 \
#	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/lib64 \
#	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/proguard \
	      ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/qemu \
	&& \
	find ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86 -type f -executable -exec chmod o+x {} + && \
#
#
# Run sdkmanager and install "build-tools;25.0.3"
#                        and "platform-tools"  (this is 29.0.4)
#                        and "platforms;android-28" (version 6)
#
# The sdkmanager --list will read something like:
# Installed packages:
#  Path                 | Version | Description                    | Location             
#  -------              | ------- | -------                        | -------              
#  build-tools;25.0.3   | 25.0.3  | Android SDK Build-Tools 25.0.3 | build-tools/25.0.3/  
#  platform-tools       | 29.0.4  | Android SDK Platform-Tools     | platform-tools/      
#  platforms;android-28 | 6       | Android SDK Platform 28        | platforms/android-28/
#  tools                | 25.2.5  | Android SDK Tools 25.2.5       | tools/    
#
	yes | ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/bin/sdkmanager \
	        "build-tools;25.0.3" \
	        platform-tools \
	        "platforms;android-28"
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# CROSS COMPILING THIRD PARTY LIBRARIES
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# dpkg-dev is required to retrieve sources from apt
RUN sed 's/^deb \(.*\)/deb-src \1/' /etc/apt/sources.list \
	     > /etc/apt/sources.list.d/debsrc.list && \
	apt-get update && \
	    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	    debhelper \
	    dpkg-dev \
	    libncurses5 \
	    pkg-config

ENV VANILLA_PATH=$PATH
ENV ANDROID_NDK_HOME=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}
#
# Note: Valid host tuples for us (which are used as is in the prefix too) would be:
#            arm-linux-androideabi     (arm)
#            arm-v7a-linux-androideabi (arm-v7a) [TODO - new, separate completely from armeabi]
#            i686-linux-android        (x86)
#            aarch64-linux-android     (arm64)
#            x86_64-linux-android      (x86_64)
# ----
# Using:
# [*] zlib : Android NDK comes with a suitable zlib already
# [*] libiconv-1.16                                            -- http://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz
# [*] libpng-1.6.37                                            -- https://github.com/glennrp/libpng/archive/v1.6.37.tar.gz
# [*] freetype-2.10.1                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
# [*] libjpeg-turbo-2.0.3                                      -- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.3.tar.gz
# [*] faad2-2.8.8                                              -- https://github.com/knik0/faad2/archive/2_8_8.tar.gz
# [*] libmad_0.15.1b                                           -- Debian 10.1 Distribution package (0.15.1b ? is latest (but old))
# [*] libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
# [*] libtheora_1.1.1                                          -- Debian 10.1 Distribution package (1.1.1+dfsg.1-15 ?)
# [*] libvorbis-1.3.6                                          -- https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
# [*] flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
# [*] mpeg2dec_0.5.1-7                                         -- https://salsa.debian.org/multimedia-team/mpeg2dec.git (0.5.1 is latest (but old))
# [*] openssl 1.1.1d                                           -- https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
# [*] curl 7.66.0                                              -- https://curl.haxx.se/download/curl-7.66.0.tar.gz
# [*] fluidsynth-lite-38353444676a1788ef78eb7f835fba4fa061f3f2 -- https://github.com/Doom64/fluidsynth-lite/archive/38353444676a1788ef78eb7f835fba4fa061f3f2.tar.gz (Apr 6, 2019)
# [*] a52dec-0.7.4                                             -- Debian 10.1 distribution package (0.7.4-19 ?)
# /scripts/thirdPartyLibraries
# ----
WORKDIR /tmp/compile
COPY ./scripts/thirdPartyLibraries/compile-libraries.sh \
     ./scripts/thirdPartyLibraries/compile-libraries-android-arm.sh \
     ./scripts/thirdPartyLibraries/compile-libraries-android-arm64.sh \
     ./scripts/thirdPartyLibraries/compile-libraries-android-x86.sh \
     ./scripts/thirdPartyLibraries/compile-libraries-android-x86_64.sh \
     ./scripts/thirdPartyLibraries/cleanup-all-libraries-src-android.sh \
     ./scripts/thirdPartyLibraries/patches/configure-freetype.patch \
     ./scripts/thirdPartyLibraries/patches/patch-x86-vorbis-clang.patch \
     ./scripts/thirdPartyLibraries/patches/macros-flac-1.3.3.patch \
     ./scripts/thirdPartyLibraries/patches/patch-mpeg2dec-confac.patch \
     ./

# --------------------------------------------------------------------------------------------------------
# Cross-compile for arm (eabi)
# [TODO] set specific options for every lib, update all scripts!
# [TODO] Cross-compile for arm-v7a and armeabi specifically and separately!
#        ??? -march=arm
# Target toolchain paths should be before the native path, otherwise some libraries
# will pickup wrong paths for config files (typically of dependency libraries and tools)
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=arm-linux-androideabi
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh
COPY ./scripts/thirdPartyLibraries/library-rules/libiconv.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libiconv

COPY ./scripts/thirdPartyLibraries/library-rules/libpng1.6.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libpng1.6

COPY ./scripts/thirdPartyLibraries/library-rules/freetype.sh library-rules/
RUN  ./compile-libraries-android-arm.sh freetype

COPY ./scripts/thirdPartyLibraries/library-rules/libjpeg-turbo.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libjpeg-turbo

COPY ./scripts/thirdPartyLibraries/library-rules/faad2.sh library-rules/
RUN  ./compile-libraries-android-arm.sh faad2

COPY ./scripts/thirdPartyLibraries/library-rules/libmad.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libmad

COPY ./scripts/thirdPartyLibraries/library-rules/libogg.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libogg

COPY ./scripts/thirdPartyLibraries/library-rules/libtheora.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libtheora

COPY ./scripts/thirdPartyLibraries/library-rules/libvorbis.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libvorbis

COPY ./scripts/thirdPartyLibraries/library-rules/flac.sh library-rules/
RUN  ./compile-libraries-android-arm.sh flac

COPY ./scripts/thirdPartyLibraries/library-rules/mpeg2dec.sh library-rules/
RUN  ./compile-libraries-android-arm.sh mpeg2dec

COPY ./scripts/thirdPartyLibraries/library-rules/openssl.sh library-rules/
RUN  ./compile-libraries-android-arm.sh openssl

COPY ./scripts/thirdPartyLibraries/library-rules/curl.sh library-rules/
RUN  ./compile-libraries-android-arm.sh curl

COPY ./scripts/thirdPartyLibraries/library-rules/fluidsynth-lite.sh library-rules/
RUN  ./compile-libraries-android-arm.sh fluidsynth-lite

COPY ./scripts/thirdPartyLibraries/library-rules/a52dec.sh library-rules/
RUN  ./compile-libraries-android-arm.sh a52dec

# --------------------------------------------------------------------------------------------------------
# Cross-compile for arm-v7a (uses same standalone toolchain as armeabi-v5te but different linking options)
# [!!!!] TODO: recheck/set specific options for every lib, create and/or update all scripts!]
# [!!!!] TODO: for linker: make sure to provide the following two flags to the linker: -march=armv7-a -Wl,--fix-cortex-a8 !!!
#ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
#ENV ANDROID_STANDALONE_TRIBLE=arm-linux-androideabi
#ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH
#
#RUN  ./cleanup-all-libraries-src-android.sh
#
#RUN  ./compile-libraries-android-arm-v7a.sh libiconv
#RUN  ./compile-libraries-android-arm-v7a.sh libpng1.6
#RUN  ./compile-libraries-android-arm-v7a.sh freetype
#RUN  ./compile-libraries-android-arm-v7a.sh libjpeg-turbo
#RUN  ./compile-libraries-android-arm-v7a.sh faad2
#RUN  ./compile-libraries-android-arm-v7a.sh libmad
#RUN  ./compile-libraries-android-arm-v7a.sh libogg
#RUN  ./compile-libraries-android-arm-v7a.sh libtheora
#RUN  ./compile-libraries-android-arm-v7a.sh libvorbis
#RUN  ./compile-libraries-android-arm-v7a.sh flac
#RUN  ./compile-libraries-android-arm-v7a.sh mpeg2dec
#RUN  ./compile-libraries-android-arm-v7a.sh openssl
#RUN  ./compile-libraries-android-arm-v7a.sh curl
#RUN  ./compile-libraries-android-arm-v7a.sh fluidsynth-lite
#RUN  ./compile-libraries-android-arm-v7a.sh a52dec
# --------------------------------------------------------------------------------------------------------
# Cross-compile for arm64
#
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=aarch64-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries-android-arm64.sh libiconv
RUN  ./compile-libraries-android-arm64.sh libpng1.6
RUN  ./compile-libraries-android-arm64.sh freetype
RUN  ./compile-libraries-android-arm64.sh libjpeg-turbo
RUN  ./compile-libraries-android-arm64.sh faad2
RUN  ./compile-libraries-android-arm64.sh libmad
RUN  ./compile-libraries-android-arm64.sh libogg
RUN  ./compile-libraries-android-arm64.sh libtheora
RUN  ./compile-libraries-android-arm64.sh libvorbis
RUN  ./compile-libraries-android-arm64.sh flac
RUN  ./compile-libraries-android-arm64.sh mpeg2dec
RUN  ./compile-libraries-android-arm64.sh openssl
RUN  ./compile-libraries-android-arm64.sh curl
RUN  ./compile-libraries-android-arm64.sh fluidsynth-lite
RUN  ./compile-libraries-android-arm64.sh a52dec

# --------------------------------------------------------------------------------------------------------
# Cross-compile for x86
#
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=i686-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries-android-x86.sh libiconv
RUN  ./compile-libraries-android-x86.sh libpng1.6
RUN  ./compile-libraries-android-x86.sh freetype
RUN  ./compile-libraries-android-x86.sh libjpeg-turbo
RUN  ./compile-libraries-android-x86.sh faad2
RUN  ./compile-libraries-android-x86.sh libmad
RUN  ./compile-libraries-android-x86.sh libogg
RUN  ./compile-libraries-android-x86.sh libtheora
RUN  ./compile-libraries-android-x86.sh libvorbis
RUN  ./compile-libraries-android-x86.sh flac
RUN  ./compile-libraries-android-x86.sh mpeg2dec
RUN  ./compile-libraries-android-x86.sh openssl
RUN  ./compile-libraries-android-x86.sh curl
RUN  ./compile-libraries-android-x86.sh fluidsynth-lite
RUN  ./compile-libraries-android-x86.sh a52dec

# --------------------------------------------------------------------------------------------------------
# Cross-compile for x86_64
#
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86_64-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=x86_64-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries-android-x86_64.sh libiconv
RUN  ./compile-libraries-android-x86_64.sh libpng1.6
RUN  ./compile-libraries-android-x86_64.sh freetype
RUN  ./compile-libraries-android-x86_64.sh libjpeg-turbo
RUN  ./compile-libraries-android-x86_64.sh faad2
RUN  ./compile-libraries-android-x86_64.sh libmad
RUN  ./compile-libraries-android-x86_64.sh libogg
RUN  ./compile-libraries-android-x86_64.sh libtheora
RUN  ./compile-libraries-android-x86_64.sh libvorbis
RUN  ./compile-libraries-android-x86_64.sh flac
RUN  ./compile-libraries-android-x86_64.sh mpeg2dec
RUN  ./compile-libraries-android-x86_64.sh openssl
RUN  ./compile-libraries-android-x86_64.sh curl
RUN  ./compile-libraries-android-x86_64.sh fluidsynth-lite
RUN  ./compile-libraries-android-x86_64.sh a52dec

#
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
#
# [SECOND STAGE]
# SETTING UP THE SCUMMVM APK BUILDING IMAGE
#
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
FROM ${DEFAULT_OS_IMAGE}
USER root

ENV ANDROID_USR_OPT_PATH=/opt/toolchains/android
ENV NDK_VERSION=r14b

COPY --from=compiler ${ANDROID_USR_OPT_PATH} ${ANDROID_USR_OPT_PATH}

# Add user scummvm with /bin/bash shell and home dir /home/scummvm
RUN useradd -ms /bin/bash -d /home/scummvm -u 2899 -U scummvm
#
# Create folders and chown to scummvm:scummvm
#   - /home/scummvm
#   - /data/ccache
#   - /data/sharedrepo
RUN mkdir -p /home/scummvm /data/ccache /data/sharedrepo && \
     chown scummvm:scummvm /home/scummvm /data/ccache /data/sharedrepo
#
# Get useful packages
RUN echo "deb http://ftp.us.debian.org/debian sid main" >> /etc/apt/sources.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	       ccache \
	       dumb-init \
	       git \
	       gzip \
	       make \
	       python \
	       python-openssl \
	       rsync \
	       xz-utils \
	       zip \
	       ca-certificates \
	       openjdk-8-jre-headless \
	       unzip \
	       wget \
	       pkg-config \
# The compiler needs libncurses5; the SDK build tools need file and Java,
# the ScummVM build needs ant
	       ant \
	       file \
	       libncurses5 \
	       openjdk-8-jdk-headless && \
	rm -rf /var/lib/apt/lists/*

# Android's signing key needs to be persisted or else it will be regenerated
# users will not be able to reinstall new builds on top of old builds
RUN mkdir -p /home/scummvm/.android && \
	chown scummvm:scummvm /home/scummvm/.android

# Copy aux scripts 
# TODO create an automated script instead (?)
# TODO create an automated script for building a multi-eabi apk (?)
#
COPY ./scripts/scummVM/setenv-android.sh                   ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-armeabi.sh     ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-armeabi-v7a.sh ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-arm64-v8a.sh   ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-x86.sh         ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-x86_64.sh      ${ANDROID_USR_OPT_PATH}/

USER scummvm
WORKDIR /home/scummvm


ARG DEFAULT_OS_IMAGE=debian:9.2
FROM ${DEFAULT_OS_IMAGE} AS compiler
#
# Building the toolchains stage
USER root

RUN apt-get update && \
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
#
# SETTING UP THE NDK
#
# As of yet (Sep 2019) - ScummVM is build with NDK r14b, to keep support for API level 9 devices (armeabi)
#
WORKDIR /tmp/compile
ENV ANDROID_USR_OPT_PATH=/opt/toolchains/android
ENV PLATFORM_MIN_API_VERSION=9
ENV PLATFORM_MIN_API_x64_VERSION=21
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
    # standalone toolchain for "arm" (armeabi)
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
    #
    # for arm
    mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-linux-androideabi/include && \
    mkdir -p ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/arm-linux-androideabi/lib/pkgconfig && \
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
    # platform android-9 symbolic links (to arm and x86)
    mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION} && \
    ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot \
          ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION}/arch-arm  && \
    ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_VERSION}/sysroot \
          ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_VERSION}/arch-x86 && \
    #
    # platform android-21 symbolic links (to arm64 and x86_64)
    mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION} && \
    ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-arm64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot \
          ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION}/arch-arm64 && \
    ln -s ${ANDROID_USR_OPT_PATH}/standalone-toolchain-x86_64-ndk-${NDK_VERSION}-api-${PLATFORM_MIN_API_x64_VERSION}/sysroot \
          ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-${PLATFORM_MIN_API_x64_VERSION}/arch-x86_64 && \
    #
    # Move of platform android-23/arch-* as is from original NDK folder
    # platform android-23 is needed separately because the code is compiled for API 14, but
    # the packaging is done for API 23, apparently for some vague manifest-related
    # reason in commit a32c53f936f8b3fbf90d016d3c07de62c96798b1
    mkdir -p ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-23/ && \
    mv platforms/android-23/arch-arm    ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-23/arch-arm    && \
    mv platforms/android-23/arch-arm64  ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-23/arch-arm64  && \
    mv platforms/android-23/arch-x86    ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-23/arch-x86    && \
    mv platforms/android-23/arch-x86_64 ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/platforms/android-23/arch-x86_64 && \
    #
    # Move of folders "build" and "sources" as is from original NDK folder
    mv build   ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/build   && \
    mv sources ${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/sources && \
    rm -rf /tmp/compile
#
# SETTING UP THE SDK
#
#
# We use build-tools r25.2.5 (from Jan 2017)
#
# ORIGINAL-TODO: We are forced to use this older version of the SDK tools because ScummVM
# uses the obsolete ndk-build process instead of the newer CMake+Gradle process.
ARG SDK_VERSION=r25.2.5
WORKDIR /tmp/compile
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
#         ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/lib64 \
#         ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/proguard \
          ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/qemu \
   && \
   find ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86 -type f -executable -exec chmod o+x {} + && \
#
# android-23 is needed because the code is compiled for API 14, but the
# packaging is done for API 23, apparently for some vague manifest-related
# reason in commit a32c53f936f8b3fbf90d016d3c07de62c96798b1
#
# Run sdkmanager and install "build-tools;25.0.3"
#                        and "platform-tools"  (this is 29.0.4)
#                        and "platforms;android-23" (version 3)
#
# The sdkmanager --list will read something like:
# Installed packages:
#  Path                 | Version | Description                    | Location             
#  -------              | ------- | -------                        | -------              
#  build-tools;25.0.3   | 25.0.3  | Android SDK Build-Tools 25.0.3 | build-tools/25.0.3/  
#  platform-tools       | 29.0.4  | Android SDK Platform-Tools     | platform-tools/      
#  platforms;android-23 | 3       | Android SDK Platform 23        | platforms/android-23/
#  tools                | 25.2.5  | Android SDK Tools 25.2.5       | tools/    
#
   yes | ${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86/tools/bin/sdkmanager \
            "build-tools;25.0.3" \
            platform-tools \
            "platforms;android-23"
#
# CROSS COMPILING THIRD PARTY LIBRARIES
# 
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
#
# Note: Valid host tuples for us (which are used as is in the prefix too) would be:
#            arm-linux-androideabi (arm)
#            i686-linux-android    (x86)
#            aarch64-linux-android (arm64)
#            x86_64-linux-android  (x86_64)
# ----
# Using:
# [*] zlib : Android NDK comes with a suitable zlib already
# [*] libpng-1.6.37                                            -- https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
# [*] freetype-2.10.1                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
# [*] libjpeg-turbo-1.5.3                                      -- https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.5.3.tar.gz
# [*] faad2-2.8.0~cvs20150510                                  -- Distribution package
# [*] libmad_0.15.1b                                           -- 0.15.1b is latest (but old)
# [*] libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
# [*] libtheora_1.1.1                                          -- Distribution package
# [*] libvorbis-1.3.6                                          -- from https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
# [*] flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
# [*] mpeg2dec_0.5.1-7                                         -- 0.5.1 is latest (but old)
# [*] curl_7.66.0                                              -- https://curl.haxx.se/download/curl-7.66.0.tar.gz
# [*] fluidsynth-lite-38353444676a1788ef78eb7f835fba4fa061f3f2 -- (Apr 6, 2019)
# [*] a52dec-0.7.4                                             -- 0.7.4 is latest (but old)
# 
# ----
WORKDIR /tmp/compile
COPY ./compile-libraries.sh \
     ./compile-libraries-android-arm.sh \
     ./compile-libraries-android-arm64.sh \
     ./compile-libraries-android-x86.sh \
     ./compile-libraries-android-x86_64.sh \
     ./configure-freetype.patch \
     ./patch-x86-vorbis-clang.patch \
     ./macros-flac-1.3.3.patch \
     ./cleanup-all-libraries-src-android.sh \
     ./

# Cross-compile for arm (eabi)
# Target toolchain paths should be before the native path, otherwise some libraries
# will pickup wrong paths for config files (typically of dependency libraries and tools)
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=arm-linux-androideabi
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh
COPY ./library-rules/libpng1.6.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libpng1.6

COPY ./library-rules/freetype.sh library-rules/
RUN  ./compile-libraries-android-arm.sh freetype

COPY ./library-rules/libjpeg-turbo.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libjpeg-turbo

COPY ./library-rules/faad2.sh library-rules/
RUN  ./compile-libraries-android-arm.sh faad2

COPY ./library-rules/libmad.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libmad

COPY ./library-rules/libogg.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libogg

COPY ./library-rules/libtheora.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libtheora

COPY ./library-rules/libvorbis.sh library-rules/
RUN  ./compile-libraries-android-arm.sh libvorbis

COPY ./library-rules/flac.sh library-rules/
RUN  ./compile-libraries-android-arm.sh flac

COPY ./library-rules/mpeg2dec.sh library-rules/
RUN  ./compile-libraries-android-arm.sh mpeg2dec

COPY ./library-rules/curl.sh library-rules/
RUN  ./compile-libraries-android-arm.sh curl

COPY ./library-rules/fluidsynth-lite.sh library-rules/
RUN  ./compile-libraries-android-arm.sh fluidsynth-lite

COPY ./library-rules/a52dec.sh library-rules/
RUN  ./compile-libraries-android-arm.sh a52dec

# ----
# Cross-compile for arm64
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=aarch64-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh
COPY ./library-rules/libpng1.6.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libpng1.6

COPY ./library-rules/freetype.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh freetype

COPY ./library-rules/libjpeg-turbo.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libjpeg-turbo

COPY ./library-rules/faad2.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh faad2

COPY ./library-rules/libmad.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libmad

COPY ./library-rules/libogg.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libogg

COPY ./library-rules/libtheora.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libtheora

COPY ./library-rules/libvorbis.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh libvorbis

COPY ./library-rules/flac.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh flac

COPY ./library-rules/mpeg2dec.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh mpeg2dec

COPY ./library-rules/curl.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh curl

COPY ./library-rules/fluidsynth-lite.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh fluidsynth-lite

COPY ./library-rules/a52dec.sh library-rules/
RUN  ./compile-libraries-android-arm64.sh a52dec

# ----
# Cross-compile for x86
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=i686-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh
COPY ./library-rules/libpng1.6.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libpng1.6

COPY ./library-rules/freetype.sh library-rules/
RUN  ./compile-libraries-android-x86.sh freetype

COPY ./library-rules/libjpeg-turbo.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libjpeg-turbo

COPY ./library-rules/faad2.sh library-rules/
RUN  ./compile-libraries-android-x86.sh faad2

COPY ./library-rules/libmad.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libmad

COPY ./library-rules/libogg.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libogg

COPY ./library-rules/libtheora.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libtheora

COPY ./library-rules/libvorbis.sh library-rules/
RUN  ./compile-libraries-android-x86.sh libvorbis

COPY ./library-rules/flac.sh library-rules/
RUN  ./compile-libraries-android-x86.sh flac

COPY ./library-rules/mpeg2dec.sh library-rules/
RUN  ./compile-libraries-android-x86.sh mpeg2dec

COPY ./library-rules/curl.sh library-rules/
RUN  ./compile-libraries-android-x86.sh curl

COPY ./library-rules/fluidsynth-lite.sh library-rules/
RUN  ./compile-libraries-android-x86.sh fluidsynth-lite

COPY ./library-rules/a52dec.sh library-rules/
RUN  ./compile-libraries-android-x86.sh a52dec

# ----
# Cross-compile for x86_64
ENV ANDROID_STANDALONE_TOOLCH=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/toolchains/x86_64-4.9/prebuilt/linux-x86_64
ENV ANDROID_STANDALONE_TRIBLE=x86_64-linux-android
ENV PATH=$ANDROID_STANDALONE_TOOLCH/bin:$ANDROID_STANDALONE_TOOLCH/$ANDROID_STANDALONE_TRIBLE/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh
COPY ./library-rules/libpng1.6.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libpng1.6

COPY ./library-rules/freetype.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh freetype

COPY ./library-rules/libjpeg-turbo.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libjpeg-turbo

COPY ./library-rules/faad2.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh faad2

COPY ./library-rules/libmad.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libmad

COPY ./library-rules/libogg.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libogg

COPY ./library-rules/libtheora.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libtheora

COPY ./library-rules/libvorbis.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh libvorbis

COPY ./library-rules/flac.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh flac

COPY ./library-rules/mpeg2dec.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh mpeg2dec

COPY ./library-rules/curl.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh curl

COPY ./library-rules/fluidsynth-lite.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh fluidsynth-lite

COPY ./library-rules/a52dec.sh library-rules/
RUN  ./compile-libraries-android-x86_64.sh a52dec

#
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
#
# SETTING UP THE SCUMMVM APT BUILDING IMAGE
#
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
RUN apt-get update && \
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
#
COPY ./setenv-android.sh                  ${ANDROID_USR_OPT_PATH}/
COPY ./setenv-android-build-arm.sh        ${ANDROID_USR_OPT_PATH}/
COPY ./setenv-android-build-arm64-v8a.sh  ${ANDROID_USR_OPT_PATH}/
COPY ./setenv-android-build-x86.sh        ${ANDROID_USR_OPT_PATH}/
COPY ./setenv-android-build-x86_64.sh     ${ANDROID_USR_OPT_PATH}/

# ScummVM configure-specific
ENV ANDROID_NDK=${ANDROID_USR_OPT_PATH}/android-ndk-${NDK_VERSION}/build \
	ANDROID_SDK=${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86

USER scummvm
WORKDIR /home/scummvm


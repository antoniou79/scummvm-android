# Debian "Buster" 10.4 is stable since May 9th, 2020
#                      openjdk-11 is the supported package
ARG DEFAULT_OS_IMAGE=debian:10.4
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
	       openjdk-11-jre-headless \
	       unzip \
	       wget && \
	rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# SETTING UP THE ANDROID SDK & NDK
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# OLD: (Nov 2019) - ScummVM is build with NDK r14b, to keep support for API level 9 devices (arm-v5 armeabi)
# NEW: With newer NDK 21.x we should set min API to 16
ARG PLATFORM_MIN_API_VERSION=16
ARG PLATFORM_MIN_API_x64_VERSION=21
#ARG NDK_VERSION=21.0.6113669
ARG  NDK_VERSION=21.3.6528147
#ARG SDK_CMD_TOOLS_VERSION=6200805
ARG ANDROID_SDK_CMD_TOOLS_VERSION=6609375
ARG ANDROID_SDK_BTOOLS_VERSION=29.0.3

ENV ANDROID_USR_OPT_PATH=/opt/toolchains/android
ENV ANDROID_SDK_ROOT=${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86

WORKDIR ${ANDROID_SDK_ROOT}

RUN wget --progress=bar:force:noscroll \
		-O commandlinetools.zip \
		https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_CMD_TOOLS_VERSION}_latest.zip
RUN unzip commandlinetools.zip && \
	rm commandlinetools.zip && \
#
# Run sdkmanager and install "build-tools;29.0.3"
#                        and "platform-tools"  (this is 30.0.3)
#                        and "platforms;android-29" (version 4)
#
# The sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --list will read something like:
# Installed packages:
#  Path                 | Version      | Description                     | Location             
#  -------              | -------      | -------                         | -------              
#  build-tools;29.0.3   | 29.0.3       | Android SDK Build-Tools 29.0.3  | build-tools/29.0.3/  
#  ndk;21.3.6528147     | 21.3.6528147 | NDK (Side by side) 21.3.6528147 | ndk/21.3.6528147/    
#  patcher;v4           | 1            | SDK Patch Applier v4            | patcher/v4/          
#  platform-tools       | 30.0.3       | Android SDK Platform-Tools      | platform-tools/      
#  platforms;android-29 | 4            | Android SDK Platform 29         | platforms/android-29/
#  tools                | 2.1.0        | Android SDK Tools 2.1           | tools/
#  
	yes | ${ANDROID_SDK_ROOT}/tools/bin/sdkmanager \
		--sdk_root=${ANDROID_SDK_ROOT} \
		"build-tools;${ANDROID_SDK_BTOOLS_VERSION}" \
		"platform-tools" \
		"platforms;android-29" \
		"ndk;${NDK_VERSION}"

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${NDK_VERSION}

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

#      
# Note: We are building for:
#            arm-v7a-linux-androideabi (arm-v7a)
#            i686-linux-android        (x86)
#            aarch64-linux-android     (arm64)
#            x86_64-linux-android      (x86_64)
# ----
# Using:
# [*] zlib : Android NDK comes with a suitable zlib already
# [*] libiconv-1.16                                            -- http://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz
# [*] libpng-1.6.37                                            -- https://github.com/glennrp/libpng/archive/v1.6.37.tar.gz
# [*] freetype-2.10.2                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.gz
# [*] libjpeg-turbo-2.0.5                                      -- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.5.tar.gz
# [*] faad2-2.9.2                                              -- https://github.com/knik0/faad2/archive/2_9_2.tar.gz
# [*] libmad_0.15.1b                                           -- Debian 10.1 Distribution package (0.15.1b ? is latest (but old))
# [*] libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
# [*] libtheora_1.1.1                                          -- Debian 10.1 Distribution package (1.1.1+dfsg.1-15 ?)
# [*] libvorbis-1.3.6                                          -- https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
# [*] flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
# [*] mpeg2dec_0.5.1-7                                         -- https://salsa.debian.org/multimedia-team/mpeg2dec.git (0.5.1 is latest (but old))
# [*] openssl 1.1.1g                                           -- https://github.com/openssl/openssl/archive/OpenSSL_1_1_1g.tar.gz
# [*] curl 7.71.1                                              -- https://curl.haxx.se/download/curl-7.71.1.tar.gz
# [*] fluidsynth-lite-c539a8d9270ba5a3f7d6e460606483fc2ab1eb61 -- https://github.com/Doom64/fluidsynth-lite/archive/c539a8d9270ba5a3f7d6e460606483fc2ab1eb61.tar.gz (Jan 26, 2020)
# [*] a52dec-0.7.4                                             -- Debian 10.1 distribution package (0.7.4-19 ?)
# [*] libsdl2-net-2.0.1                                        -- https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
# [*] libfribidi-1.0.10                                        -- https://github.com/fribidi/fribidi/releases/download/v1.0.10/fribidi-1.0.10.tar.xz
# ----
WORKDIR /tmp/compile
COPY ./scripts/thirdPartyLibraries/compile-libraries.sh \
     ./scripts/thirdPartyLibraries/cleanup-all-libraries-src-android.sh \
     ./scripts/thirdPartyLibraries/patches/configure-freetype.patch \
     ./scripts/thirdPartyLibraries/patches/patch-x86-vorbis-clang.patch \
     ./scripts/thirdPartyLibraries/patches/patch-mpeg2dec-confac.patch \
     ./scripts/thirdPartyLibraries/patches/forSDL2NetFiles.patch \
     ./

COPY ./scripts/thirdPartyLibraries/library-rules/libiconv.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libpng1.6.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/freetype.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libjpeg-turbo.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/faad2.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libmad.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libogg.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libtheora.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libvorbis.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/flac.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/mpeg2dec.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/openssl.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/curl.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/fluidsynth-lite.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/a52dec.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libsdl2-net.sh library-rules/
COPY ./scripts/thirdPartyLibraries/library-rules/libfribidi.sh library-rules/

# --------------------------------------------------------------------------------------------------------
# Cross-compile for arm-v7a
# [!!!!] TODO: recheck/set specific options for every lib, create and/or update all scripts!]
# [!!!!] TODO: for linker: make sure to provide the following two flags to the linker: -march=armv7-a -Wl,--fix-cortex-a8 !!!
# 
ENV ANDROID_NDK_HOST=arm-linux-androideabi
ENV ANDROID_NDK_COMPILER=armv7a-linux-androideabi${PLATFORM_MIN_API_VERSION}
ENV ANDROID_NDK_PLATFORM=android-${PLATFORM_MIN_API_VERSION}
ENV ANDROID_LIBRARIES=${ANDROID_USR_OPT_PATH}/libraries/armv7a
ENV ANDROID_TARGET_NDK_TOOLCHPREFIX=arm-linux-androideabi
ENV PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/$ANDROID_TARGET_NDK_TOOLCHPREFIX-4.9/prebuilt/linux-x86_64/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries.sh libiconv
RUN  ./compile-libraries.sh libpng1.6
RUN  ./compile-libraries.sh freetype
RUN  ./compile-libraries.sh libjpeg-turbo
RUN  ./compile-libraries.sh faad2
RUN  ./compile-libraries.sh libmad
RUN  ./compile-libraries.sh libogg
RUN  ./compile-libraries.sh libtheora
RUN  ./compile-libraries.sh libvorbis
RUN  ./compile-libraries.sh flac
RUN  ./compile-libraries.sh mpeg2dec
RUN  ./compile-libraries.sh openssl
RUN  ./compile-libraries.sh curl
RUN  ./compile-libraries.sh fluidsynth-lite
RUN  ./compile-libraries.sh a52dec
RUN  ./compile-libraries.sh libsdl2-net
RUN  ./compile-libraries.sh libfribidi

# --------------------------------------------------------------------------------------------------------
# Cross-compile for arm64
#
ENV ANDROID_NDK_HOST=aarch64-linux-android
ENV ANDROID_NDK_COMPILER=aarch64-linux-android${PLATFORM_MIN_API_x64_VERSION}
ENV ANDROID_NDK_PLATFORM=android-${PLATFORM_MIN_API_x64_VERSION}
ENV ANDROID_LIBRARIES=${ANDROID_USR_OPT_PATH}/libraries/aarch64
ENV ANDROID_TARGET_NDK_TOOLCHPREFIX=aarch64-linux-android
ENV PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/$ANDROID_TARGET_NDK_TOOLCHPREFIX-4.9/prebuilt/linux-x86_64/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries.sh libiconv
RUN  ./compile-libraries.sh libpng1.6
RUN  ./compile-libraries.sh freetype
RUN  ./compile-libraries.sh libjpeg-turbo
RUN  ./compile-libraries.sh faad2
RUN  ./compile-libraries.sh libmad
RUN  ./compile-libraries.sh libogg
RUN  ./compile-libraries.sh libtheora
RUN  ./compile-libraries.sh libvorbis
RUN  ./compile-libraries.sh flac
RUN  ./compile-libraries.sh mpeg2dec
RUN  ./compile-libraries.sh openssl
RUN  ./compile-libraries.sh curl
RUN  ./compile-libraries.sh fluidsynth-lite
RUN  ./compile-libraries.sh a52dec
RUN  ./compile-libraries.sh libsdl2-net
RUN  ./compile-libraries.sh libfribidi

# --------------------------------------------------------------------------------------------------------
# Cross-compile for x86
#
ENV ANDROID_NDK_HOST=i686-linux-android
ENV ANDROID_NDK_COMPILER=i686-linux-android${PLATFORM_MIN_API_VERSION}
ENV ANDROID_NDK_PLATFORM=android-${PLATFORM_MIN_API_VERSION}
ENV ANDROID_LIBRARIES=${ANDROID_USR_OPT_PATH}/libraries/i686
ENV ANDROID_TARGET_NDK_TOOLCHPREFIX=x86
ENV PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/$ANDROID_TARGET_NDK_TOOLCHPREFIX-4.9/prebuilt/linux-x86_64/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries.sh libiconv
RUN  ./compile-libraries.sh libpng1.6
RUN  ./compile-libraries.sh freetype
RUN  ./compile-libraries.sh libjpeg-turbo
RUN  ./compile-libraries.sh faad2
RUN  ./compile-libraries.sh libmad
RUN  ./compile-libraries.sh libogg
RUN  ./compile-libraries.sh libtheora
RUN  ./compile-libraries.sh libvorbis
RUN  ./compile-libraries.sh flac
RUN  ./compile-libraries.sh mpeg2dec
RUN  ./compile-libraries.sh openssl
RUN  ./compile-libraries.sh curl
RUN  ./compile-libraries.sh fluidsynth-lite
RUN  ./compile-libraries.sh a52dec
RUN  ./compile-libraries.sh libsdl2-net
RUN  ./compile-libraries.sh libfribidi

# --------------------------------------------------------------------------------------------------------
# Cross-compile for x86_64
#
ENV ANDROID_NDK_HOST=x86_64-linux-android
ENV ANDROID_NDK_COMPILER=x86_64-linux-android${PLATFORM_MIN_API_x64_VERSION}
ENV ANDROID_NDK_PLATFORM=android-${PLATFORM_MIN_API_x64_VERSION}
ENV ANDROID_LIBRARIES=${ANDROID_USR_OPT_PATH}/libraries/x86_64
ENV ANDROID_TARGET_NDK_TOOLCHPREFIX=x86_64
ENV PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/$ANDROID_TARGET_NDK_TOOLCHPREFIX-4.9/prebuilt/linux-x86_64/bin:$VANILLA_PATH

RUN  ./cleanup-all-libraries-src-android.sh

RUN  ./compile-libraries.sh libiconv
RUN  ./compile-libraries.sh libpng1.6
RUN  ./compile-libraries.sh freetype
RUN  ./compile-libraries.sh libjpeg-turbo
RUN  ./compile-libraries.sh faad2
RUN  ./compile-libraries.sh libmad
RUN  ./compile-libraries.sh libogg
RUN  ./compile-libraries.sh libtheora
RUN  ./compile-libraries.sh libvorbis
RUN  ./compile-libraries.sh flac
RUN  ./compile-libraries.sh mpeg2dec
RUN  ./compile-libraries.sh openssl
RUN  ./compile-libraries.sh curl
RUN  ./compile-libraries.sh fluidsynth-lite
RUN  ./compile-libraries.sh a52dec
RUN  ./compile-libraries.sh libsdl2-net
RUN  ./compile-libraries.sh libfribidi

RUN  ./cleanup-all-libraries-src-android.sh
ENV PATH=$VANILLA_PATH
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

#ARG PLATFORM_MIN_API_VERSION=16
#ARG PLATFORM_MIN_API_x64_VERSION=21
#ARG NDK_VERSION=21.0.6113669
ARG  NDK_VERSION=21.3.6528147
#ARG SDK_CMD_TOOLS_VERSION=6200805
#ARG ANDROID_SDK_CMD_TOOLS_VERSION=6609375
ARG ANDROID_SDK_BTOOLS_VERSION=29.0.3

ENV ANDROID_SDK_ROOT=${ANDROID_USR_OPT_PATH}/android-sdk-linux_x86
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${NDK_VERSION}
ENV ANDROID_TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
ENV ANDROID_SDK_TOOLS=$ANDROID_SDK_ROOT/tools
ENV ANDROID_SDK_BTOOLS=$ANDROID_HOME/build-tools/${ANDROID_SDK_BTOOLS_VERSION}
ENV PATH=$ANDROID_SDK_TOOLS:$ANDROID_SDK_BTOOLS:$PATH
ENV VANILLA_PATH=$PATH
ENV NDK_LOG=1
ENV LC_ALL=C
ENV CCACHE_COMPRESS=1

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
	       openjdk-11-jre-headless \
	       unzip \
	       wget \
	       pkg-config \
	       libncurses5 \
	       openjdk-11-jdk-headless && \
	rm -rf /var/lib/apt/lists/*

# Android's signing key needs to be persisted or else it will be regenerated
# users will not be able to reinstall new builds on top of old builds
RUN mkdir -p /home/scummvm/.android && \
	chown scummvm:scummvm /home/scummvm/.android

# Copy aux scripts
#
COPY ./scripts/scummVM/setenv-android-build-armeabi-v7a.sh ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-arm64-v8a.sh   ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-x86.sh         ${ANDROID_USR_OPT_PATH}/
COPY ./scripts/scummVM/setenv-android-build-x86_64.sh      ${ANDROID_USR_OPT_PATH}/

USER scummvm
WORKDIR /home/scummvm


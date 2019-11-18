#!/bin/sh
# This script is meant to be run once!
if [ "$VANILLA_PATH" != "" ]; then
	echo "Variable VANILLA_PATH is already set. This script is meant to be run once per session!"
else
	export NDK_VERSION=r14b
	export PLATFORM_MIN_API_VERSION=9
	export PLATFORM_MIN_API_x64_VERSION=21
	export ANDROID_USR_OPT=/opt/toolchains/android
	export ANDROID_USR_OPT_PATH=$ANDROID_USR_OPT
	export ANDROID_HOME=$ANDROID_USR_OPT/android-sdk-linux_x86
	export ANDROID_NDK_HOME=$ANDROID_USR_OPT/android-ndk-$NDK_VERSION
	export ANDROID_SDK_ROOT=$ANDROID_HOME
	export ANDROID_SDK_TOOLS=$ANDROID_HOME/tools
	export ANDROID_SDK_BTOOLS=$ANDROID_HOME/build-tools/25.0.3
	# ScummVM uses these two env vars for NDK and SDK paths:
	export ANDROID_NDK=$ANDROID_NDK_HOME
	export ANDROID_SDK=$ANDROID_SDK_ROOT
	export NDK_LOG=1
	export NDK_PLATFORMS_ROOT=$ANDROID_NDK_HOME/platforms
	export NDK_TOOLCHAINS_ROOT=$ANDROID_NDK_HOME/toolchains
	export CCACHE_COMPRESS=1
	export PATH=$ANDROID_SDK_TOOLS:$ANDROID_SDK_BTOOLS:$PATH
	export VANILLA_PATH=$PATH
fi

#!/bin/sh
# This script is meant to be run once!
export ANDROID_USR_OPT=/opt/toolchains/android
export ANDROID_HOME=$ANDROID_USR_OPT/android-sdk-linux_x86
export ANDROID_NDK_HOME=$ANDROID_USR_OPT/android-ndk-r14b
export ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_SDK_TOOLS=$ANDROID_HOME/tools
export ANDROID_SDK_BTOOLS=$ANDROID_HOME/build-tools/25.0.3
export PATH=$ANDROID_SDK_TOOLS:$ANDROID_SDK_BTOOLS:$ANDROID_STUDIO_INSTALLATION:$PATH
export VANILLA_PATH=$PATH


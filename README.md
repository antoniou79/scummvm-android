# scummvm-android
Docker Image configuration and auxiliary files for NDK r21d toolchain for building the Android port for ScummVM

Based on the work of Colin Snover (csnover), Cameron Cawley (ccawley2011), Le Philousophe (lephilousophe) and Peter Kohaut (peterkohaut).

Base docker image is now: 
```
Debian 10.4
```

JDK version used: 
```
openjdk 11.0.7 2020-04-14
OpenJDK Runtime Environment (build 11.0.7+10-post-Debian-3deb10u1)
OpenJDK 64-Bit Server VM (build 11.0.7+10-post-Debian-3deb10u1, mixed mode, sharing)
```

Cross-compiled libraries are:
-  zlib : Android NDK comes with a suitable zlib already
-  libiconv-1.16                                            -- http://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz
-  libpng-1.6.37                                            -- https://github.com/glennrp/libpng/archive/v1.6.37.tar.gz
-  freetype-2.10.2                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.gz
-  libjpeg-turbo-2.0.5                                      -- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.5.tar.gz
-  faad2-2.9.2                                              -- https://github.com/knik0/faad2/archive/2_9_2.tar.gz
-  libmad_0.15.1b                                           -- Debian 10.1 Distribution package (0.15.1b ? is latest (but old))
-  libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
-  libtheora_1.1.1                                          -- Debian 10.1 Distribution package (1.1.1+dfsg.1-15 ?)
-  libvorbis-1.3.6                                          -- https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
-  flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
-  mpeg2dec_0.5.1-7                                         -- https://salsa.debian.org/multimedia-team/mpeg2dec.git (0.5.1 is latest (but old))
-  openssl 1.1.1g                                           -- https://github.com/openssl/openssl/archive/OpenSSL_1_1_1g.tar.gz
-  curl 7.71.1                                              -- https://curl.haxx.se/download/curl-7.71.1.tar.gz
-  fluidsynth-lite-c539a8d9270ba5a3f7d6e460606483fc2ab1eb61 -- https://github.com/Doom64/fluidsynth-lite/archive/c539a8d9270ba5a3f7d6e460606483fc2ab1eb61.tar.gz (Jan 26, 2020)
-  a52dec-0.7.4                                             -- Debian 10.1 distribution package (0.7.4-19 ?)
-  libsdl2-net-2.0.1                                        -- https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
-  libfribidi-1.0.10                                        -- https://github.com/fribidi/fribidi/releases/download/v1.0.10/fribidi-1.0.10.tar.xz

Basic instructions:
- Install docker ("Docker Engine - Community" should work fine). Tested with version 19.03.12, (build 48a66213fe) using containerd.io version 1.2.13 on Linux Ubuntu x64 20.04 LTS.
- Install docker-compose on your system. Tested with version 1.25.0.

- Build the image with:
```
docker build -t "scummvm/scummvm-android:latest" -f "./Dockerfile" .
```

- Edit "docker-compose.override.yml" and replace the placeholder paths with your native system's paths, properly.

- Run the container with:
```
docker-compose run --rm android
```

- From within the container, navigate to /data/sharedrepo, where the scummvm repo should be mounted.
```
cd /data/sharedrepo
```
- Then run the following sequence of commands, using the appropriate "setenv-android-build-xxxxx.sh" script and setting the proper target architecture as the "--host" argument depending on the architecture you are targeting (supported target architecture values are: android-arm-v7a, android-arm64-v8a, android-x86 and android-x86_64). Example:
```
source $ANDROID_USR_OPT_PATH/setenv-android-build-arm64-v8a.sh
make clean; ./configure --enable-engine=testbed --host=android-arm64-v8a --enable-verbose-build --enable-debug
make -j$(nproc)
```

- The output APK will be created as ScummVM-debug.apk in the current folder. Make sure to move or copy this file elsewhere before running "make clean" and starting to build for another architecture.

TODO:
- Test with text to speech support for Android (Google text to speech: https://play.google.com/store/apps/details?id=com.google.android.tts&hl=en_US)

Thanks to:
- ccawley2011, csnover, lephilousophe, peterkohaut

Reference links:
- Scummvm repository: https://github.com/scummvm/scummvm
- https://github.com/csnover/scummvm-buildbot
- https://github.com/lephilousophe/dockerized-bb
- https://github.com/ccawley2011/dockerized-bb/tree/android

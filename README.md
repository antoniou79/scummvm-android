# scummvm-android
Docker Image configuration and auxiliary files for NDK r14b toolchains for building the Android port for ScummVM

Based on the work of Colin Snover (csnover), Cameron Cawley (ccawley2011) and Le Philousophe (lephilousophe).

Cross-compiled libraries are:
- libiconv-1.16                                            -- http://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz
- libpng-1.6.37                                            -- https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
- freetype-2.10.1                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
- libjpeg-turbo-1.5.3                                      -- https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.5.3.tar.gz
- faad2-2.8.0~cvs20150510                                  -- Debian 9.2 distribution package
- libmad_0.15.1b                                           -- 0.15.1b is latest (but old)
- libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
- libtheora_1.1.1                                          -- Debian 9.2 distribution package
- libvorbis-1.3.6                                          -- from https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
- flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
- mpeg2dec_0.5.1-7                                         -- 0.5.1 is latest (but old)
- curl_7.66.0                                              -- https://curl.haxx.se/download/curl-7.66.0.tar.gz
- fluidsynth-lite-38353444676a1788ef78eb7f835fba4fa061f3f2 -- (Apr 6, 2019)
- a52dec-0.7.4

Basic instructions:
- Install docker (community edition shold work fine) (tested with version 19.03.2, build 6a30dfc on Linux Ubuntu x64 16.04.6 LTS)
- Install docker-compose on your system (tested with version 1.24.1, build 4667896b)

- Build the image with:
```
docker build -t "scummvm/scummvm-android:latest" -f "./Dockerfile" .
```

- Edit "docker-compose.override.yml" and replace the placeholder paths with your native system's paths, properly.

- Run the container with:
```
docker-compose run --rm android
```

- From within the container, navigate to /data/sharedrepo, where the scummvm repo should be mounted. Then run the "setenv-android.sh" script. This script has to be run only once per container session.
```
cd /data/sharedrepo
source $ANDROID_USR_OPT_PATH/setenv-android.sh
```
- Then run the following sequence of commands, using the appropriate "setenv-android-build-xxxxx.sh" script and setting the proper target architecture as the "--host" argument depending on the architecture you are targetting (supported target architecture values are: android-arm, android-arm-v7a, android-arm64-v8a, android-x86 and android-x86_64). Example:
```
source $ANDROID_USR_OPT_PATH/setenv-android-build-arm64-v8a.sh
make clean; ./configure --enable-engine=testbed --host=android-arm64-v8a --enable-verbose-build --enable-debug
make -j$(nproc)
```

- The output APK will be created as ScummVM-debug.apk in the current folder. Make sure to move or copy it elsewhere before running make clean and starting to build for another architecture.

Todo: 
- Test adding support for more third party libraries
- Test possible transition to building with gradle without losing minimum API support

Reference links:
- Scummvm repository: https://github.com/scummvm/scummvm
- https://github.com/csnover/scummvm-buildbot
- https://github.com/lephilousophe/dockerized-bb
- https://github.com/ccawley2011/dockerized-bb/tree/android

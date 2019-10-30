# scummvm-android
Docker Image configuration and auxiliary files for NDK r14b toolchains for building the Android port for ScummVM

Based on the work of Colin Snover (csnover), Cameron Cawley (ccawley2011) and Le Philousophe (lephilousophe).

Base docker image is now: 
```
Debian 10.1
```

JDK used is from Debian Unstable (sid): 
```
openjdk version "1.8.0_232"
OpenJDK Runtime Environment (build 1.8.0_232-8u232-b09-1-b09)
```

Cross-compiled libraries are:
- libiconv-1.16                                            -- http://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz
- libpng-1.6.37                                            -- https://github.com/glennrp/libpng/archive/v1.6.37.tar.gz
- freetype-2.10.1                                          -- https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
- libjpeg-turbo-2.0.3                                      -- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.3.tar.gz
- faad2-2.8.8                                              -- https://github.com/knik0/faad2/archive/2\_8\_8.tar.gz
- libmad_0.15.1b                                           -- Debian 10.1 distribution package (0.15.1b) is latest (but old)
- libogg_1.3.4                                             -- https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
- libtheora_1.1.1                                          -- Debian 10.1 distribution package (1.1.1+dfsg.1-15 ?)
- libvorbis-1.3.6                                          -- https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.6.tar.gz
- flac_1.3.3                                               -- https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.3.tar.xz
- mpeg2dec_0.5.1-7                                         -- https://salsa.debian.org/multimedia-team/mpeg2dec.git (0.5.1 is latest (but old))
- openssl 1.1.1d                                           -- https://github.com/openssl/openssl/archive/OpenSSL\_1\_1\_1d.tar.gz
- curl_7.66.0                                              -- https://curl.haxx.se/download/curl-7.66.0.tar.gz
- fluidsynth-lite-38353444676a1788ef78eb7f835fba4fa061f3f2 -- https://github.com/Doom64/fluidsynth-lite/archive/38353444676a1788ef78eb7f835fba4fa061f3f2.tar.gz (Apr 6, 2019)
- a52dec-0.7.4                                             -- Debian 10.1 distribution package (0.7.4-19 ?)

Basic instructions:
- Install docker ("Docker Engine - Community" should work fine). Tested with version 19.03.4 (build 9013bf583a) using containerd.io version 1.2.10-3 on Linux Ubuntu x64 16.04.6 LTS.
- Install docker-compose on your system. Tested with version 1.24.1 (build 4667896b).

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

- The output APK will be created as ScummVM-debug.apk in the current folder. Make sure to move or copy this file elsewhere before running "make clean" and starting to build for another architecture.

TODO:
- Test adding support for more third party libraries (eg. OpenSSL, also: more updated libraries, faad2 (2.9.0), text to speech support)
- Cleaner cross-compiling for arm-v7a
- Consider moving all cross-compiled 3rd party libraries in separate folders outside the standalone NDK toolchains
- Organize the files better in a folder structure
- Test possible transition to building with gradle without losing minimum API support
- Create another Dockerfile and script assets for the setup to build the old Android SDL port (uses SDL 1.2)
- Create another Dockerfile and script assets for the setup to build the non-SDL port with the most recent version of NDK (this will probably result to the loss of supported older devices)
- Experiment with possible SDL2 integration (?)

Reference links:
- Scummvm repository: https://github.com/scummvm/scummvm
- https://github.com/csnover/scummvm-buildbot
- https://github.com/lephilousophe/dockerized-bb
- https://github.com/ccawley2011/dockerized-bb/tree/android

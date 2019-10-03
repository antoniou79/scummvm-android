# scummvm-android
Docker Image configuration and auxiliary files for NDK r14b toolchains for building the ScummVM port for Android

Based on the work of Colin Snover (csnover), Cameron Cawley (ccawley2011) and Le Philousophe (lephilousophe).

Cross-compiled libraries are:
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

Todo: 
- Properly fill in documentation here for users
- Add separate building script for arm-v7a apks
- Test adding support for more third party libraries 
- Test possible transition to building with gradle without losing minimum API support

Reference links:
- Scummvm repository: https://github.com/scummvm/scummvm
- https://github.com/csnover/scummvm-buildbot
- https://github.com/lephilousophe/dockerized-bb
- https://github.com/ccawley2011/dockerized-bb/tree/android

SDL2NET_VERSION=2.0.1
#do_fetch

if [ ! -d SDL2_net-${SDL2NET_VERSION} ]
then
    if [ ! -f SDL2_net-${SDL2NET_VERSION}.tar.gz ]
    then
        wget https://www.libsdl.org/projects/SDL_net/release/SDL2_net-${SDL2NET_VERSION}.tar.gz || exit 128
    fi
    tar xzf SDL2_net-${SDL2NET_VERSION}.tar.gz || exit 128
fi

cd SDL2_net-${SDL2NET_VERSION} || exit 128

patch -p1 < ../forSDL2NetFiles.patch

do_configure --with-sdl-prefix=$prefix
# showinterfaces.c indirectly includes SDL_main.h which #defines main to
# SDL_main when __ANDROID__ is defined, so it won't compile in the usual manner,
# so just stub it out
echo 'int main(){return 0;}' > showinterfaces.c
do_make

get_dependencies cmake

wget -O - --progress=bar:force:noscroll \
	https://github.com/Doom64/fluidsynth-lite/archive/38353444676a1788ef78eb7f835fba4fa061f3f2.tar.gz | tar -xzf -

cd fluidsynth-lite*/
cmake -DCMAKE_INSTALL_PREFIX=$prefix \
	-DBUILD_SHARED_LIBS=no .
do_make
cp -a src/libfluidsynth.a $prefix/lib

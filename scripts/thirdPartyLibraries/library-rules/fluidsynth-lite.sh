get_dependencies cmake

wget -O - --progress=bar:force:noscroll \
	https://github.com/Doom64/fluidsynth-lite/archive/c539a8d9270ba5a3f7d6e460606483fc2ab1eb61.tar.gz | tar -xzf -

cd fluidsynth-lite*/
cmake -DCMAKE_INSTALL_PREFIX=$prefix \
	-DBUILD_SHARED_LIBS=no .
do_make
cp -a src/libfluidsynth.a $prefix/lib

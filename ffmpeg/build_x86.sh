#!/bin/bash

if [ "$NDK" = "" ]; then
	echo NDK variable not set, assuming ${HOME}/android-ndk
	export NDK=${HOME}/android-ndk
fi

SYSROOT=$NDK/platforms/android-9/arch-x86
# Expand the prebuilt/* path into the correct one
TOOLCHAIN=`echo $NDK/toolchains/x86-4.4.3/prebuilt/*-x86`
export PATH=$TOOLCHAIN/bin:$PATH

for version in x86; do

	DEST=build/
	FLAGS="--target-os=linux --cross-prefix=i686-linux-android- --arch=x86"
	FLAGS="$FLAGS --sysroot=$SYSROOT"
	FLAGS="$FLAGS --disable-shared --enable-static --disable-symver --disable-asm"
    FLAGS="$FLAGS --disable-doc"
    FLAGS="$FLAGS --disable-bsfs"
    FLAGS="$FLAGS --disable-indevs --disable-outdevs"
    FLAGS="$FLAGS --disable-programs"
    FLAGS="$FLAGS --disable-filter=showspectrum --disable-filter=dctdnoiz --disable-filter=atempo"
    FLAGS="$FLAGS --enable-swscale"

	case "$version" in
		x86)
			EXTRA_CFLAGS=""
			EXTRA_LDFLAGS=""
			ABI="x86"
			;;
	esac
	DEST="$DEST/$ABI"
	FLAGS="$FLAGS --prefix=$DEST"

	mkdir -p $DEST
	echo $FLAGS --extra-cflags="$EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" > $DEST/info.txt
	./configure $FLAGS --extra-cflags="$EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" | tee $DEST/configuration.txt
	[ $PIPESTATUS == 0 ] || exit 1
	make clean
	make -j4 || exit 1
	make install || exit 1

done


#!/bin/bash

if [ "$NDK" = "" ]; then
	echo NDK variable not set, assuming ${HOME}/android-ndk
	export NDK=${HOME}/android-ndk
fi

SYSROOT=$NDK/platforms/android-8/arch-arm
# Expand the prebuilt/* path into the correct one
TOOLCHAIN=`echo $NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/*-x86`
export PATH=$TOOLCHAIN/bin:$PATH

# ARMv5
# ARMv7
# ARMv7+VFPv3-d16 (Tegra2)
# ARMv7+Neon (Cortex-A8)

#for version in armv5te armv7a v7neon v7vfpv3; do
for version in armv5te armv7a; do

	DEST=build/
	FLAGS="--target-os=linux --cross-prefix=arm-linux-androideabi- --arch=arm"
	FLAGS="$FLAGS --sysroot=$SYSROOT"
	FLAGS="$FLAGS --disable-shared --enable-static --disable-symver"
    FLAGS="$FLAGS --disable-doc"
    FLAGS="$FLAGS --disable-bsfs"
    FLAGS="$FLAGS --disable-indevs --disable-outdevs"
    FLAGS="$FLAGS --disable-programs"
    FLAGS="$FLAGS --disable-filter=showspectrum --disable-filter=dctdnoiz --disable-filter=atempo"
    FLAGS="$FLAGS --enable-swscale --enable-pic"

	case "$version" in
        v7vfpv3)
            EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
            EXTRA_LDFLAGS="-Wl"
            ABI="armeabi-v7a"
            ;;
		v7neon)
			EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
			EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
			# Runtime choosing neon vs non-neon requires
			ABI="armeabi-v7a"
			;;
		armv7a)
			EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -fPIC -DANDROID"
			EXTRA_LDFLAGS=""
			ABI="armeabi-v7a"
			;;
		armv5te)
			EXTRA_CFLAGS=""
			EXTRA_LDFLAGS=""
			ABI="armeabi"
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


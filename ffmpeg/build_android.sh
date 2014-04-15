#!/bin/sh

#  build_universal.sh
#  
#
#  Created by A. Wischnewski on 01.03.13.
#

export NDK="/Library/Developer/android-ndk-r8d"

rm -rf build
mkdir -p build

source ./build_arm.sh
source ./build_x86.sh
#! /usr/bin/env bash
#
# Copyright (C) 2014 Miguel Botón <waninkoko@gmail.com>
# Copyright (C) 2014 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#--------------------
set -e

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
fi

#--------------------
# common defines
FF_ARCH=$1
if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'arm, armv7a, x86, ...'.\n"
    exit 1
fi


FF_BUILD_ROOT=`pwd`
FF_ANDROID_PLATFORM=android-21


FF_BUILD_NAME=
FF_SOURCE=
FF_CROSS_PREFIX=

FF_CFG_FLAGS=
FF_PLATFORM_CFG_FLAGS=

FF_EXTRA_CFLAGS=
FF_EXTRA_LDFLAGS=



#--------------------
echo ""
echo "--------------------"
echo "[*] make NDK standalone toolchain"
echo "--------------------"
. ./tools/do-detect-env.sh
FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG
FF_GCC_VER=$IJK_GCC_VER
FF_GCC_64_VER=$IJK_GCC_64_VER


#----- armv7a begin -----
if [ "$FF_ARCH" = "armv7a" ]; then
    FF_BUILD_NAME=fdk-aac-armv7a
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
	
    FF_CROSS_PREFIX=arm-linux-androideabi
	FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    # FF_PLATFORM_CFG_FLAGS="android-armv7"

    FF_CFG_FLAGS="$FF_CFG_FLAGS --host=arm-linux-android"

elif [ "$FF_ARCH" = "armv5" ]; then
    FF_BUILD_NAME=fdk-aac-armv5
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
	
    FF_CROSS_PREFIX=arm-linux-androideabi
	FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    # FF_PLATFORM_CFG_FLAGS="android"

    FF_CFG_FLAGS="$FF_CFG_FLAGS --host=arm-linux-android"

elif [ "$FF_ARCH" = "x86" ]; then
    FF_BUILD_NAME=fdk-aac-x86
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
	
    FF_CROSS_PREFIX=i686-linux-android
	FF_TOOLCHAIN_NAME=x86-${FF_GCC_VER}

    # FF_PLATFORM_CFG_FLAGS="android-x86"

    #FF_CFG_FLAGS="$FF_CFG_FLAGS no-asm"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --host=i686-linux-android"

elif [ "$FF_ARCH" = "x86_64" ]; then
    FF_ANDROID_PLATFORM=android-21

    FF_BUILD_NAME=fdk-aac-x86_64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=x86_64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    # FF_PLATFORM_CFG_FLAGS="linux-x86_64"

    FF_CFG_FLAGS="$FF_CFG_FLAGS --host=x86_64-linux-android"

elif [ "$FF_ARCH" = "arm64" ]; then
    FF_ANDROID_PLATFORM=android-21

    FF_BUILD_NAME=fdk-aac-arm64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=aarch64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    # FF_PLATFORM_CFG_FLAGS="linux-aarch64"

    FF_CFG_FLAGS="$FF_CFG_FLAGS --host=aarch64-linux-android"

else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi

FF_TOOLCHAIN_PATH=$FF_BUILD_ROOT/build/$FF_BUILD_NAME/toolchain

FF_SYSROOT=$FF_TOOLCHAIN_PATH/sysroot
FF_PREFIX=$FF_BUILD_ROOT/build/$FF_BUILD_NAME/output

mkdir -p $FF_PREFIX
# mkdir -p $FF_SYSROOT


#--------------------
echo ""
echo "--------------------"
echo "[*] make NDK standalone toolchain"
echo "--------------------"
. ./tools/do-detect-env.sh
FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG


FF_MAKE_TOOLCHAIN_FLAGS="$FF_MAKE_TOOLCHAIN_FLAGS --install-dir=$FF_TOOLCHAIN_PATH"
FF_TOOLCHAIN_TOUCH="$FF_TOOLCHAIN_PATH/touch"
if [ ! -f "$FF_TOOLCHAIN_TOUCH" ]; then
    $ANDROID_NDK/build/tools/make-standalone-toolchain.sh \
        $FF_MAKE_TOOLCHAIN_FLAGS \
        --platform=$FF_ANDROID_PLATFORM \
        --toolchain=$FF_TOOLCHAIN_NAME
    touch $FF_TOOLCHAIN_TOUCH;
fi


#--------------------
echo ""
echo "--------------------"
echo "[*] check fdk-aac env"
echo "--------------------"
export PATH=$FF_TOOLCHAIN_PATH/bin:$PATH

export COMMON_FF_CFG_FLAGS=

FF_CFG_FLAGS="$FF_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

#--------------------
# Standard options:
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$FF_PREFIX"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-static --disable-shared"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --with-sysroot=$FF_SYSROOT"
FF_CFG_FLAGS="$FF_CFG_FLAGS CPPFLAGS=-fPIC"
# FF_CFG_FLAGS="$FF_CFG_FLAGS $FF_PLATFORM_CFG_FLAGS"

#--------------------
echo ""
echo "--------------------"
echo "[*] configurate fdk-aac"
echo "--------------------"
cd $FF_SOURCE

./autogen.sh

NDK=~/Android/ndk/android-ndk-r20b # 这里需要替换成你本地的 NDK 路径，其他的不用修改
HOST_TAG=darwin-x86_64
NAX_TOOLCHAIN_PATH=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
API=21

if [ "$FF_ARCH" = "armv7a" ]; then
    AR=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ar
    AS=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-as
    LD=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ld
    RANLIB=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ranlib
    STRIP=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-strip
    CC=$NAX_TOOLCHAIN_PATH/bin/armv7a-linux-androideabi$API-clang
    CXX=$NAX_TOOLCHAIN_PATH/bin/armv7a-linux-androideabi$API-clang++

elif [ "$FF_ARCH" = "armv5" ]; then
    AR=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ar
    AS=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-as
    LD=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ld
    RANLIB=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-ranlib
    STRIP=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi-strip
    CC=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi$API-clang
    CXX=$NAX_TOOLCHAIN_PATH/bin/arm-linux-androideabi$API-clang++

elif [ "$FF_ARCH" = "x86" ]; then
    AR=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi-ar
    AS=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi-as
    LD=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi-ld
    RANLIB=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi-ranlib
    STRIP=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi-strip
    CC=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi$API-clang
    CXX=$NAX_TOOLCHAIN_PATH/bin/i686-linux-androideabi$API-clang++

elif [ "$FF_ARCH" = "x86_64" ]; then
    AR=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi-ar
    AS=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi-as
    LD=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi-ld
    RANLIB=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi-ranlib
    STRIP=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi-strip
    CC=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi$API-clang
    CXX=$NAX_TOOLCHAIN_PATH/bin/x86_64-linux-androideabi$API-clang++

elif [ "$FF_ARCH" = "arm64" ]; then
    AR=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi-ar
    AS=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi-as
    LD=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi-ld
    RANLIB=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi-ranlib
    STRIP=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi-strip
    CC=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi$API-clang
    CXX=$NAX_TOOLCHAIN_PATH/bin/aarch64-linux-androideabi$API-clang++

else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi

# echo "FF_TOOLCHAIN_PATH=${FF_TOOLCHAIN_PATH}"
# echo "AR= ${AR}"
# echo "AS= ${AS}"
# echo "LD= ${LD}"
# echo "RANLIB= ${RANLIB}"
# echo "STRIP= ${STRIP}"
# echo "CC= ${CC}"
# echo "CXX= ${CXX}"

#if [ -f "./Makefile" ]; then
#    echo 'reuse configure'
#else
    echo "./configure $FF_CFG_FLAGS"
    ./configure $FF_CFG_FLAGS CPPFLAGS="-fPIC"
# fi

#--------------------
echo ""
echo "--------------------"
echo "[*] compile fdk-aac"
echo "--------------------"
make $FF_MAKE_FLAGS
make install

#--------------------
echo ""
echo "--------------------"
echo "[*] link fdk-aac"
echo "--------------------"

#! /bin/bash

set -e

topDir=`cd $(dirname $0); pwd`
NODEJS_HEADERS_DIR=$topDir/node_modules/nodejs-mobile-react-native/android/libnode
NODEJS_MOBILE_GYP_BIN_FILE=$topDir/node_modules/nodejs-mobile-gyp/bin/node-gyp.js

# FIXME: Make standalone android toolchain instead of hard-coding it
# See: https://github.com/janeasystems/nodejs-mobile-react-native/blob/99f3400895d0b8626dbea37f8382f13e6aeb7ebb/android/build.gradle
STANDALONE_TOOLCHAIN=/Users/jim/whimsio/2018-06-rootcache/cabal-mobile/android/build/standalone-toolchains/arm-linux-androideabi

: <<'END'
        String ndk_bundle_path = android.ndkDirectory
        String standalone_toolchain = "${rootProject.buildDir}/standalone-toolchains/${temp_toolchain_name}"
        String npm_toolchain_add_to_path = "${rootProject.buildDir}/bin"
        String npm_toolchain_ar = "${standalone_toolchain}/bin/${temp_suffix}-ar"
        String npm_toolchain_cc = "${standalone_toolchain}/bin/${temp_suffix}-clang"
        String npm_toolchain_cxx = "${standalone_toolchain}/bin/${temp_suffix}-clang++"
        String npm_toolchain_link = "${standalone_toolchain}/bin/${temp_suffix}-clang++"

        String npm_gyp_defines = "target_arch=${temp_arch}"
        npm_gyp_defines += " v8_target_arch=${temp_v8_arch}"
        npm_gyp_defines += " android_target_arch=${temp_arch}"
        if (OperatingSystem.current().isMacOsX()) {
            npm_gyp_defines += " host_os=mac OS=android"
        } else if (OperatingSystem.current().isLinux()) {
            npm_gyp_defines += " host_os=linux OS=android"
        }

            environment ('npm_config_node_engine', 'v8' )
            environment ('npm_config_nodedir', "${project.projectDir}/libnode/" )
            environment ('npm_config_node_gyp', "${project.projectDir}/../../nodejs-mobile-gyp/bin/node-gyp.js" )
            environment ('npm_config_arch', temp_arch)
            environment ('npm_config_platform', 'android')
            environment ('npm_config_format', 'make-android')
            environment ('TOOLCHAIN',"${standalone_toolchain}")
            environment ('AR',"${npm_toolchain_ar}")
            environment ('CC',"${npm_toolchain_cc}")
            environment ('CXX',"${npm_toolchain_cxx}")
            environment ('LINK',"${npm_toolchain_link}")
            environment ('GYP_DEFINES',"${npm_gyp_defines}")
END

# FIXME: host_os for linux build host
export npm_config_node_engine="v8"
export npm_config_nodedir="$NODEJS_HEADERS_DIR"
export npm_config_node_gyp="$NODEJS_MOBILE_GYP_BIN_FILE"
export npm_config_arch="arm"
export npm_config_platform="android"
export npm_config_format="make-android"
export TOOLCHAIN="$STANDALONE_TOOLCHAIN"
export AR="$TOOLCHAIN/bin/arm-linux-androideabi-ar"
export CC="$TOOLCHAIN/bin/arm-linux-androideabi-clang"
export CXX="$TOOLCHAIN/bin/arm-linux-androideabi-clang++"
export LINK="$TOOLCHAIN/bin/arm-linux-androideabi-clang++"
export GYP_DEFINES="target_arch=arm v8_target_arch=arm android_target_arch=arm host_os=mac OS=android"
export PREBUILD_ARCH=arm
export PREBUILD_PLATFORM=android
export PREBUILD_NODE_GYP="$NODEJS_MOBILE_GYP_BIN_FILE"

if [ ! -d utp-native ]; then
  git clone git@github.com:mafintosh/utp-native.git
fi

pushd utp-native
rm -rf node_modules/prebuildify
UTP_NATIVE=1 npm install
npx prebuildify --strip --platform=android --arch=arm --target=node@8.0.0
popd

tar cf - -C utp-native prebuilds | tar xvf -

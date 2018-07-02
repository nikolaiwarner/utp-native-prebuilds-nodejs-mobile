#! /bin/bash

set -e

topDir=`cd $(dirname $0); pwd`
NODEJS_HEADERS_DIR=$topDir/node_modules/nodejs-mobile-react-native/ios/libnode
NODEJS_MOBILE_GYP_BIN_FILE=$topDir/node_modules/nodejs-mobile-gyp/bin/node-gyp.js

export GYP_DEFINES="OS=ios"
export npm_config_nodedir="$NODEJS_HEADERS_DIR"
export npm_config_node_gyp="$NODEJS_MOBILE_GYP_BIN_FILE"
export npm_config_platform="ios"
export npm_config_node_engine="chakracore"
export npm_config_arch="x64"
export PREBUILD_ARCH=x64
export PREBUILD_PLATFORM=ios
export PREBUILD_NODE_GYP="$NODEJS_MOBILE_GYP_BIN_FILE"

if [ ! -d utp-native ]; then
  git clone git@github.com:mafintosh/utp-native.git
fi

pushd utp-native
rm -rf node_modules/prebuildify
UTP_NATIVE=1 npm install
npx prebuildify --strip --platform=ios --arch=x64 --target=node@8.0.0
popd

tar cf - -C utp-native prebuilds | tar xvf -

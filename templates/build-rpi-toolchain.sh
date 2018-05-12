#!/bin/bash

function sync_additionals_into_sysroot() {

    RASPI_ADDRESS=${RASPI_ADDRESS:="{{raspi_address}}"}
    RASPI_USER=${RASPI_USER:="{{raspi_user}}"}
    SYSROOT_DIR="{{toolchains_dir}}/{{toolchain_prefix}}/{{toolchain_prefix}}/sysroot/"

    rsync -avzR $RASPI_USER@$RASPI_ADDRESS:/usr/include/boost \
                                          :/usr/include/spdlog \
                                          :/usr/include/mosquitto.h \
                                          :/usr/lib/arm-linux-gnueabihf/libssl* \
                                          :/usr/lib/arm-linux-gnueabihf/libcrypto* \
                                          :/usr/lib/arm-linux-gnueabihf/libcares* \
                                          :/usr/lib/arm-linux-gnueabihf/libboost_* \
                                          :/usr/lib/arm-linux-gnueabihf/libmosquitto.* \
                                          "$SYSROOT_DIR"

    # create symlinks so that the libraries can be used without multilib
    pushd "${SYSROOT_DIR}/usr/lib/" >/dev/null
    ls "arm-linux-gnueabihf/" | while read filename; do
        if [ ! -e "$filename" ]; then
            ln -s "arm-linux-gnueabihf/$filename" "$filename"
        fi
    done
    popd >/dev/null
}


cd "{{toolsdir}}"

if [ ! -e "crosstool-ng" ]; then
  git clone --depth 1 https://github.com/crosstool-ng/crosstool-ng
fi

cd "crosstool-ng"

if [ ! -e config/comp_libs.in ]; then
  ./bootstrap
fi

./configure --enable-local
make -j4

if [ ! -e .config ]; then
  cat "/usr/local/etc/{{toolchain_prefix}}.config" > .config
  ./ct-ng oldconfig
fi

mkdir -p "{{tarballs_dir}}"
./ct-ng build

sync_additionals_into_sysroot

pushd "{{toolchains_dir}}" >/dev/null
tar cfj "{{homedir}}/toolchain_{{toolchain_prefix}}.tbz2" "{{toolchain_prefix}}"
popd >/dev/null

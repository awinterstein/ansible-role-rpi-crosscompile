#!/bin/bash

function sync_additionals_into_sysroot() {

    RASPI_ADDRESS=${RASPI_ADDRESS:="{{raspi_address}}"}
    RASPI_USER=${RASPI_USER:="{{raspi_user}}"}
    SYSROOT_DIR="{{toolchains_dir}}/{{toolchain_prefix}}/{{toolchain_prefix}}/sysroot/"

    chmod u+w "$SYSROOT_DIR"
    mkdir -p "$SYSROOT_DIR/opt"

    rsync -avzR $RASPI_USER@$RASPI_ADDRESS:/usr/include/boost \
                                          :/usr/include/spdlog \
                                          :/usr/include/mosquitto.h \
                                          :/usr/lib/arm-linux-gnueabihf/libz.* \
                                          :/usr/lib/arm-linux-gnueabihf/libssl* \
                                          :/usr/lib/arm-linux-gnueabihf/libcrypto* \
                                          :/usr/lib/arm-linux-gnueabihf/libcares* \
                                          :/usr/lib/arm-linux-gnueabihf/libboost_* \
                                          :/usr/lib/arm-linux-gnueabihf/libmosquitto.* \
                                          :/usr/lib/arm-linux-gnueabihf/libdouble-conversion.* \
                                          :/usr/lib/arm-linux-gnueabihf/libpng16.* \
                                          :/usr/lib/arm-linux-gnueabihf/libharfbuzz.* \
                                          :/usr/lib/arm-linux-gnueabihf/libglib-2.0.* \
                                          :/usr/lib/arm-linux-gnueabihf/libfreetype.* \
                                          :/usr/lib/arm-linux-gnueabihf/libgraphite2.* \
                                          :/usr/lib/arm-linux-gnueabihf/libpcre.* \
                                          :/lib/arm-linux-gnueabihf/libz.* \
                                          :/lib/arm-linux-gnueabihf/libglib-2.0.* \
                                          :/lib/arm-linux-gnueabihf/libpcre.* \
                                          :/opt/vc/lib/* \
                                          "$SYSROOT_DIR"

    # write LD config file for the sysroot
    mkdir -p "$SYSROOT_DIR/etc/"
    chmod u+w "$SYSROOT_DIR/etc/"
    touch "$SYSROOT_DIR/etc/ld.so.conf"
cat << EOF > "$SYSROOT_DIR/etc/ld.so.conf"
/opt/vc/lib
/lib/arm-linux-gnueabihf
/usr/lib/arm-linux-gnueabihf
/usr/local/lib
EOF

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

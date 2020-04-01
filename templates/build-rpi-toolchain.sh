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
                                          :/usr/include/zlib.h \
                                          :/usr/include/zconf.h \
                                          :/usr/include/openssl \
                                          :/usr/include/arm-linux-gnueabihf/openssl \
                                          :/usr/lib/arm-linux-gnueabihf/libz.* \
                                          :/usr/lib/arm-linux-gnueabihf/libssl* \
                                          :/usr/lib/arm-linux-gnueabihf/libcrypto* \
                                          :/usr/lib/arm-linux-gnueabihf/libcares* \
                                          :/usr/lib/arm-linux-gnueabihf/libboost_* \
                                          :/usr/lib/arm-linux-gnueabihf/libgthread* \
                                          :/usr/lib/arm-linux-gnueabihf/libmosquitto.* \
                                          :/usr/lib/arm-linux-gnueabihf/libdouble-conversion.* \
                                          :/usr/lib/arm-linux-gnueabihf/libpng16.* \
                                          :/usr/lib/arm-linux-gnueabihf/libharfbuzz.* \
                                          :/usr/lib/arm-linux-gnueabihf/libglib-2.0.* \
                                          :/usr/lib/arm-linux-gnueabihf/libfreetype.* \
                                          :/usr/lib/arm-linux-gnueabihf/libgraphite2.* \
                                          :/usr/lib/arm-linux-gnueabihf/libidn2.* \
                                          :/usr/lib/arm-linux-gnueabihf/libpcre.* \
                                          :/usr/lib/arm-linux-gnueabihf/libunistring.* \
                                          :/lib/arm-linux-gnueabihf/libz.* \
                                          :/lib/arm-linux-gnueabihf/libpcre.* \
                                          :/opt/vc/include/* \
                                          :/opt/vc/lib/* \
                                          \
                                          :/usr/include/pqxx \
                                          :/usr/include/taglib \
                                          :/usr/include/mpd \
                                          :/usr/lib/arm-linux-gnueabihf/libpq* \
                                          :/usr/lib/arm-linux-gnueabihf/libtag* \
                                          :/usr/lib/arm-linux-gnueabihf/libmpdclient.* \
                                          :/usr/lib/arm-linux-gnueabihf/libldap_r* \
                                          :/usr/lib/arm-linux-gnueabihf/libgssapi_krb5* \
                                          :/usr/lib/arm-linux-gnueabihf/libicuuc* \
                                          :/usr/lib/arm-linux-gnueabihf/libicudata* \
                                          :/usr/lib/arm-linux-gnueabihf/libkrb5* \
                                          :/usr/lib/arm-linux-gnueabihf/libk5crypto* \
                                          :/usr/lib/arm-linux-gnueabihf/liblber* \
                                          :/usr/lib/arm-linux-gnueabihf/libsasl2* \
                                          :/usr/lib/arm-linux-gnueabihf/libgnutls* \
                                          :/usr/lib/arm-linux-gnueabihf/libgmp* \
                                          :/usr/lib/arm-linux-gnueabihf/libhogweed* \
                                          :/usr/lib/arm-linux-gnueabihf/libnettle* \
                                          :/usr/lib/arm-linux-gnueabihf/libtasn1* \
                                          :/usr/lib/arm-linux-gnueabihf/libp11* \
                                          :/usr/lib/arm-linux-gnueabihf/libffi* \
                                          :/usr/lib/arm-linux-gnueabihf/libcrypto.so.* \
                                          :/usr/lib/arm-linux-gnueabihf/libssl.so.* \
                                          :/lib/arm-linux-gnueabihf/libcom_err* \
                                          :/lib/arm-linux-gnueabihf/libkeyutils* \
                                          :/lib/arm-linux-gnueabihf/libidn* \
                                          :/lib/arm-linux-gnueabihf/libz.* \
                                          "$SYSROOT_DIR"

    # create symlinks for some libraries
    pushd "$SYSROOT_DIR/usr/lib"
    ln -sf arm-linux-gnueabihf/libmosquitto.so* .
    ln -sf arm-linux-gnueabihf/libtag.so* .
    ln -sf arm-linux-gnueabihf/libpq* .
    ln -sf arm-linux-gnueabihf/libmpdclient.so* .
    popd

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

if [ ! -e configure ]; then
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

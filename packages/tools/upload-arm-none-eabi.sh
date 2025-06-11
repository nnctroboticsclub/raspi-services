#!/bin/bash -e
. `dirname $0`/../.env

group=$1

if [ -z "$group" ]; then
  echo "Usage: $0 <group>"
  exit 1
fi

export PKG_NAME=arm-none-eabi
export PKG_VER=13.3
export VERSION=$(echo $PKG_VER | sed -e 's/rc/./g' -e 's/^v//g')
export DEB_FILE=$PKG_NAME-"$VERSION".deb

if [ ! -f $DEB_FILE ]; then
  echo "Creating Debian package: $DEB_FILE"

  installation_dir=$(pwd)/inst

  mkdir -p "$installation_dir"/DEBIAN
  cat <<EOF > "$installation_dir"/DEBIAN/control
Package: $PKG_NAME
Version: $VERSION
Section: tools
Priority: optional
Architecture: all
Maintainer: syoch64@gmail.com
Description: arm-none-eabi
EOF

  TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz
  if [ ! -f arm-none-eabi.tgz ]; then
    echo "Downloading arm-none-eabi..."
    wget $TOOLCHAIN_URL -O arm-none-eabi.tgz
  else
    echo "Using existing arm-none-eabi archive."
  fi
  tar -xf arm-none-eabi.tgz -C $installation_dir
  # rm -f arm-none-eabi.tgz

  mkdir $installation_dir/opt
  mv $installation_dir/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi $installation_dir/opt/arm-none-eabi

  mkdir -p "$installation_dir"/usr/bin
  for f in $installation_dir/opt/arm-none-eabi/bin/*; do
    ln -s "/opt/arm-none-eabi/bin/`basename $f`" "$installation_dir/usr/bin/`basename $f`"
  done

  dpkg-deb --build "$installation_dir" $DEB_FILE
  rm -rf "$installation_dir"
else
  echo "Debian package already exists: $DEB_FILE"
fi
if [ ! -f $DEB_FILE ]; then
  echo "Failed to create Debian package: $DEB_FILE"
  exit 1
fi

echo "Created Debian package: $DEB_FILE"
curl --progress-bar -X POST "$server/api/deb/upload?group=$group" -F "file=@$DEB_FILE"
rm -f $DEB_FILE
echo ""
echo "Uploaded $DEB_FILE to $server/api/deb/upload?group=$group"
#!/bin/bash -e
. `dirname $0`/../.env

group=$1

if [ -z "$group" ]; then
  echo "Usage: $0 <group>"
  exit 1
fi

export PKG_NAME=xpack-qemu-arm
export PKG_VER=8.2.2.1
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
Description: xpack-qemu-arm
EOF

  QEMU_URL="https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/download/v8.2.2-1/xpack-qemu-arm-8.2.2-1-linux-x64.tar.gz"
  if [ ! -f qemu-arm-xpack.tgz ]; then
    echo "Downloading xpack-qemu-arm..."
    wget $QEMU_URL -O qemu-arm-xpack.tgz
  else
    echo "Using existing xpack-qemu-arm archive."
  fi
  tar -xf qemu-arm-xpack.tgz -C $installation_dir
  rm -f qemu-arm-xpack.tgz

  mkdir $installation_dir/opt
  mv $installation_dir/xpack-qemu-arm-8.2.2-1 $installation_dir/opt/xpack-qemu-arm

  mkdir -p "$installation_dir"/usr/bin
  for f in $installation_dir/opt/xpack-qemu-arm/bin/*; do
    ln -s /opt/xpack-qemu-arm/bin/`basename $f` "$installation_dir"/usr/bin/`basename $f`
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
#!/bin/bash -e
. `dirname $0`/../.env

group=$1

if [ -z "$group" ]; then
  echo "Usage: $0 <group>"
  exit 1
fi

export PKG_NAME=cmake
export PKG_VER=4.0.2-1
export DEB_FILE=$PKG_NAME-"$PKG_VER".deb

if [ ! -f $DEB_FILE ]; then
  echo "Creating Debian package: $DEB_FILE"

  installation_dir=$(pwd)/inst

  mkdir -p "$installation_dir"/DEBIAN
  cat <<EOF > "$installation_dir"/DEBIAN/control
Package: $PKG_NAME
Version: $PKG_VER
Section: tools
Priority: optional
Architecture: all
Maintainer: syoch64@gmail.com
Description: CMake
EOF

  CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v4.0.2/cmake-4.0.2-linux-x86_64.tar.gz"
  if [ ! -f cmake.tgz ]; then
    echo "Downloading xpack-qemu-arm..."
    wget $CMAKE_URL -O cmake.tgz
  else
    echo "Using existing xpack-qemu-arm archive."
  fi
  tar -xf cmake.tgz -C $installation_dir
  rm -f cmake.tgz

  mkdir $installation_dir/opt
  mv $installation_dir/cmake-4.0.2-linux-x86_64 $installation_dir/opt/cmake

  mkdir -p "$installation_dir"/usr/bin
  for f in $installation_dir/opt/cmake/bin/*; do
    ln -s /opt/cmake/bin/`basename $f` "$installation_dir"/usr/bin/`basename $f`
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
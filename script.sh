#!/bin/bash

dir=$1

files=$(ls $dir)
thisdir=$(pwd)


for i in $files
do
  if [ $(echo $dir$i | cut -d. -f2) = 'cc' ]
  then
  filename=$(echo $i | cut -d. -f1)
  echo Incercam compilarea fisierului $i
  g++ $dir$i -o $dir$filename
  arm-linux-gnueabi-g++ $dir$i -o $dir${filename}_arm
  aarch64-linux-gnu-g++ $dir$i -o $dir${filename}_aarch64
  mkdir -p $filename/DEBIAN
  touch $filename/DEBIAN/control
  controlfile=$filename/DEBIAN/control
  echo 'Package: '$filename >>$controlfile
  echo 'Version: 1.0' >> $controlfile
  echo 'Section: custom' >>$controlfile
  echo 'Architecture: all' >>$controlfile
  echo 'Essential: no' >>$controlfile
  echo 'Installed-Size: 1024' >>$controlfile
  echo 'Maintainer: '$i >>$controlfile
  echo 'Description: made by Stanciu si Suhan' >>$controlfile

  mkdir -p $filename/usr/bin
  cp $dir$filename $filename/usr/bin
  cp $dir${filename}_arm $filename/usr/bin
  cp $dir${filename}_aarch64 $filename/usr/bin
  dpkg-deb --build $filename

  sudo cp $filename.deb /var/www/html/debian/

  rm -Rf $filename
  rm ${filename}.deb
  rm $dir$filename
  rm $dir${filename}_arm
  rm $dir${filename}_aarch64
  else
  echo $dir$i nu este fisier .cc
fi
done
cd /var/www/html/debian
dpkg-scanpackages . | gzip -c9 > Packages.gz

cd $thisdir

sudo apt-get update

#!/bin/sh
echo "deb http://ru.archive.ubuntu.com/ubuntu/ lucid main universe multiverse" >  /etc/apt/sources.list
echo "deb http://cpan2deb.x12.su/ubuntu/ lucid main " >> /etc/apt/sources.list
apt-get update


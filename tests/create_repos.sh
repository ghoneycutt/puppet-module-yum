#!/bin/bash -xe

cd /opt/repos
mkdir -p cowsay/6
mkdir -p cowsay/7

wget https://dl.fedoraproject.org/pub/epel/6/x86_64/Packages/c/cowsay-3.03-8.el6.noarch.rpm \
  -O cowsay/6/cowsay-3.03-8.el6.noarch.rpm
wget https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cowsay-3.04-4.el7.noarch.rpm \
  -O cowsay/7/cowsay-3.04-4.el7.noarch.rpm

for i in 6 7
do
  cd cowsay/${i}
  createrepo -v .
  cd -
done

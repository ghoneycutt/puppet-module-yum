#!/bin/bash -xe

rm -f /etc/yum.repos.d/epel.repo
yum clean all
rm -fr /var/cache/yum

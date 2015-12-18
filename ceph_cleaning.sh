#!/bin/bash
ceph-deploy purge $HOSTNAME
ceph-deploy purgedata $HOSTNAME
ceph-deploy forgetkeys
rm -fr $HOME/WorkSpace/ceph-deploy/*

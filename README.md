
WORKSPACE=/home/jamesliu/WorkSpace
CEPH_BUILD=$WORKSPACE/ceph
CEPH_INSTALL=$WORKSPACE/ceph-install
CEPH_DEPLOY=$WORKSPACE/ceph-deploy

export PYTHONPATH=$CEPH_INSTALL/lib/python2.7/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=$CEPH_INSTALL/lib:$LD_LIBRARY_PATH
export PATH=$CEPH_INSTALL/bin:$CEPH_INSTALL/sbin:$PATH
export CEPH_CONF=$CEPH_DEPLOY/ceph.conf


export GOPATH=/home/jamesliu/WorkSpace/GoWork
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

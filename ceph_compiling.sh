#!/bin/bash
#/***************************************************************************************
#           Scripts to compile Ceph and Install Ceph
#                James Liu
#
#***************************************************************************************/
# Make folder preparation
WORKSPACE=$HOME/WorkSpace
cd $WORKSPACE
#mkdir -p ceph-build
mkdir -p ceph-install
mkdir -p ceph-deploy
CEPH_BUILD=$WORKSPACE/ceph_lttng
CEPH_INSTALL=$WORKSPACE/ceph-install
CEPH_DEPLOY=$WORKSPACE/ceph-deploy

# Build & Install
#$HOME/ceph: this is your ceph source tree
cd $CEPH_BUILD
#../ceph/configure --with-lttng --prefix=$CEPH_INSTALL
make -j `getconf _NPROCESSORS_ONLN`
sudo make install

#3. add below to your $HOME/.bashrc
export PYTHONPATH=$CEPH_INSTALL/lib/python2.7/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=$CEPH_INSTALL/lib:$LD_LIBRARY_PATH
export PATH=$CEPH_INSTALL/bin:$CEPH_INSTALL/sbin:$PATH
export CEPH_CONF=$CEPH_DEPLOY/ceph.conf

#4.Create $HOME/ceph-deploy/ceph.conf
echo '[global]
fsid = a7f64266-0894-4f1e-a635-d0aeaca0e993
auth_cluster_required = none
auth_service_required = none
auth_client_required = none
osd_journal_size = 1024
osd objectstore = memstore
filestore_xattr_use_omap = true
debug_lockdep = 0/0
debug_context = 0/0
debug_crush = 0/0
debug_buffer = 0/0
debug_timer = 0/0
debug_filer = 0/0
debug_objecter = 0/0
debug_rados = 0/0
debug_rbd = 0/0
debug_journaler = 0/0
debug_objectcatcher = 0/0
debug_client = 0/0
debug_osd = 0/0
debug_optracker = 0/0
debug_objclass = 0/0
debug_filestore = 0/0
debug_journal = 0/0
debug_ms = 0/0
debug_monc = 0/0
debug_tp = 0/0
debug_auth = 0/0
debug_finisher = 0/0
debug_heartbeatmap = 0/0
debug_perfcounter = 0/0
debug_asok = 0/0
debug_throttle = 0/0
debug_mon = 0/0
debug_paxos = 0/0
debug_rgw = 0/0
osd_pool_default_size = 1
osd_op_threads=32
osd_enable_op_tracker=false
objecter_inflight_ops=102400
objecter_inflight_op_byte=1048576000
ms_dispatch_throttle_bytes=1048576000
mon_initial_members = localhost
mon_host = 127.0.0.1
mon data = '$CEPH_DEPLOY'/mon/mymondata
mon cluster log file = '$CEPH_DEPLOY'/mon/mon.log
osd data = '$CEPH_DEPLOY'/osd/myosddata
osd journal = '$CEPH_DEPLOY'/osd/myosdjournal
keyring='$CEPH_DEPLOY'/ceph.client.admin.keyring
run dir = '$CEPH_DEPLOY'/run' > $CEPH_DEPLOY/ceph.conf

sudo mkdir -p /etc/ceph/   
sudo cp $CEPH_DEPLOY/ceph.conf /etc/ceph/

#5. prepare keys
echo "--------------Prepare keys-----------"
cd $CEPH_DEPLOY
ceph-authtool --create-keyring ./ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring ./ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool ./ceph.mon.keyring --import-keyring ./ceph.client.admin.keyring
monmaptool --create --add localhost 127.0.0.1 --fsid a7f64266-0894-4f1e-a635-d0aeaca0e993 ./monmap

#6. setup & start mon
echo "--------------Setup&Start Mon-----------"
mkdir -p mon/mymondata
ceph-mon --mkfs -i localhost --monmap ./monmap --keyring ./ceph.mon.keyring
ceph-mon -i localhost

#7. setup & start osd
echo "--------------Setup&Start OSD-----------"
mkdir -p osd/myosddata
ceph osd create 487b9f85-0fee-48df-8976-e03218466ac6 0
ceph-osd -i 0 --mkfs --mkkey --osd-uuid 487b9f85-0fee-48df-8976-e03218466ac6
ceph auth add osd.0 osd 'allow *' mon 'allow profile osd' -i ./ceph.client.admin.keyring
ceph osd crush add-bucket localhost host
ceph osd crush move localhost root=default
ceph osd crush add osd.0 1.0 host=localhost
ceph-osd  -i 0

#8 Tune rbd size
echo "----------Tune RBD Size----------------"
ceph osd pool set rbd size 1
ceph osd pool set rbd min_size 1

#9. check the status
echo "----------Ceph Status Checking---------"
ceph -s

#10 Create images
echo "---------create image-----------------"
rbd create fio_test --size 512

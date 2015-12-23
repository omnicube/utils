Setting up BlKIN in Ceph requires installing babeltrace, blkin libraries and then setting up Ceph BLKIN branch.

Procedure to setup Babeltrace:

1. Download the babeltrace repository from here: https://github.com/efficios/babeltrace Git clone link: https://github.com/efficios/babeltrace.git
2. Make sure the master branch is checked out. Ensure all dependencies are installed (check webpage for dependencies).
3. Follow steps in the github page to install babeltrace. In step2, ./configure, add the flag to generate python bindings i.e. ./configure --enable-python-bindings. What we want to see here is that python2.7 bindings are generated so look for statements like found python2.7 or the path to python2.7-config and python2.7 binary in the configure step.
6. The rest of the steps from the webpage are to be followed.

Procedure in setting up BLKIN + LTTNG and Ceph with BLKIN:

1. First, download the blkin source code from here: https://github.com/marioskogias/blkin
2. Follow the install.md script (follow the part with cloned repository). The steps mentioned in that part are:
sudo apt-get install libboost-all-dev lttng-tools liblttng-ust-dev python3-babeltrace
autoreconf -fi
debuild -i -us -uc -b -j9
sudo dpkg -i ../*.deb
3. The first step may cause an issue on ubuntu14.04. Look into the error and if necessary, add the LTTNG PPA for python3-babeltrace
   - Install the latest lttng ppa https://launchpad.net/~lttng/+archive/ubuntu/ppa/ (Click on "Technical details of this PPA, choose the ubuntu version and add the 2 lines to /etc/apt/sources.list. Then run apt-get update). There might be an error about the adding of the ppa. In case the key is unverified an error is seen during apt-get update. Execute the following command to solve the issue:
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F4A7DFFC33739778
5. After installing BLKIN successfully, compile Ceph with BLKIN flags as mentioned in this document: https://github.com/agshew/ceph/blob/wip-blkin-v5/doc/dev/blkin.rst. Note that in the configure step, you have to mention --with-lttng instead of --without-lttng 
6. Now try creating a ceph cluster and check the presence of lttng tracepoints with the following commands:
   lttng create <session-name>
   lttng list -u --->lists all userspace tracepoints.
   If it is working so far, enable tracepoints with this statement:
   lttng enable-event --all -u ----> enable all userspace tracepoints
   lttng start ---> start tracing
   After experiment is done,
   lttng stop ---> stop tracing
   lttng view > <filename> ---> write traces to <filename>

Procedure To Install Zipkin (Only for viewing traces in Zipkin webpage):
1. Installing Zipkin. Zipkin might give an error "bad sbt jar!". The link to the scala sbt jar may be broken. In such a case, download the sbt launch jar manually using this command: wget http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch//0.12.3/sbt-launch.jar
2. Download and start the apache cassandra server with the default config:
	- download the version in the following link: http://livingforhadoop.blogspot.com/2015/06/steps-to-install-cassandra-on-ubuntu.html. Follow until step 4.
3. Next, start cassandra: bin/cassandra -f
4. Start the cli with the schema file in the zipkin-cassandra directory: bin/cassandra-cli --host localhost --port 9160 -f ~/src/wip-blkin-compile/zipkin/zipkin-1.1.0/zipkin-cassandra/src/schema/cassandra-schema.txt
Handy link: https://github.com/openzipkin/zipkin/blob/master/doc/ubuntu-quickstart.txt#L55https://github.com/openzipkin/zipkin/blob/master/doc/ubuntu-quickstart.txt#L55
5. Now start the zipkin services: bin/collector cassandra, bin/query cassandra and bin/web cassandra
6. Follow the part with "Show Ceph's Blkin Traces in Zipkin-Web"
7. If you see the PKIX error when you run Zipkin, follow this link: http://www.java-samples.com/showtutorial.php?tutorialid=210


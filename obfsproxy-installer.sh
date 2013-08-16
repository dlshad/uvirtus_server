#! /bin/sh

# This script is written for uVirtus Linux 2.0, this will build and configure the Obfsproxy server

# Installing needed packages
#Check if Obfsproxy is installed if not install it
pwdv=`pwd`
if ! which obfsproxy > /dev/null; then
	echo "Obfsproxy not found...... Installing "
	apt-get -y install autoconf pkg-config git libevent-dev libssl-dev screen
	git clone https://git.torproject.org/pluggable-transports/obfsproxy-legacy.git
	cd obfsproxy-legacy/
	./autogen.sh && ./configure && make
	make install
	cd $pwdv
	echo "obfsproxy --log-min-severity=info obfs2 --dest=127.0.0.1:443 server 0.0.0.0:80" >> /etc/rc.local
	obfsproxy --log-min-severity=info obfs2 --dest=127.0.0.1:443 server 0.0.0.0:80
else
	echo "The Obfsproxy is already installed"
fi

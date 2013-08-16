#! /bin/sh

# This script is written for uVirtus Linux 2.0 Server , this will build and configure the OpenVPN server

# Installing needed packages
#Check if OpenVPN is installed if not install it
#Write client crt , key + ready to use config file
# Please make sure toe change the interface name  - venet0:0 - at the line 63 to your internet network interface

pwdv=`pwd`

if ! which openvpn > /dev/null; then
        echo "OpenVPN not found...... Installing "
        apt-get -y install openvpn

        if [ "$?" = "0" ]; then

                # Continue to generate server certificates
                cp -r  /usr/share/doc/openvpn/examples/easy-rsa/2.0   /etc/openvpn/easy-rsa2
                cp ./vars /etc/openvpn/easy-rsa2/vars
                cd /etc/openvpn/easy-rsa2
                mkdir keys
                cp openssl-1.0.0.cnf openssl.cnf #this line could be deleted in case the cnf file is already exist
                source ./vars
                ./clean-all
                ./build-ca
                ./build-key-server server
                ./build-dh
                cd $pwdv
                cp /etc/openvpn/easy-rsa2/keys/ca.crt /etc/openvpn
                cp /etc/openvpn/easy-rsa2/keys/ca.key /etc/openvpn
                cp /etc/openvpn/easy-rsa2/keys/dh1024.pem /etc/openvpn
                cp /etc/openvpn/easy-rsa2/keys/server.crt /etc/openvpn
                cp /etc/openvpn/easy-rsa2/keys/server.key /etc/openvpn
                if [ "$?" = "0" ]; then
                        echo "OpenVPN service restarting...."
                        service openvpn restart
                                if [ "$?" = "0" ]; then
                                        echo "The OpenVPN service restarted....."
                                else
                                        echo "couldn't restart OpenVPN"
                                fi
                fi
                #Generating the Client certificate
                echo "Generating the Client certificate"
                cd /etc/openvpn/easy-rsa2
                source ./vars
                ./build-key client
                cd $pwdv
                #Configure the server
                adduser --system --no-create-home --disabled-login openvpn
                addgroup --system --no-create-home --disabled-login openvpn
                cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
                gunzip /etc/openvpn/server.conf.gz
                echo "push "redirect-gateway def1 bypass-dhcp"" >> /etc/openvpn/server.conf
                apt-get -y install curl
                service openvpn restart
                echo 1 > /proc/sys/net/ipv4/ip_forward
                iptables -A INPUT -i tun+ -j ACCEPT
                iptables -A FORWARD -i tun+ -j ACCEPT
                iptables -A INPUT -i tap+ -j ACCEPT
                iptables -A FORWARD -i tap+ -j ACCEPT
                iptables -t nat -A POSTROUTING -o venet0:0 -j MASQUERADE
                iptables-save

                #make client config file + bring the Crt , key to the same folder , ready to be copied to the client PC
           
                cd /etc/openvpn/
                mkdir clientconfig
                cp /etc/openvpn/ca.crt /etc/openvpn/clientconfig/
                cp /etc/openvpn/easy-rsa2/keys/client.crt /etc/openvpn/clientconfig/
                cp /etc/openvpn/easy-rsa2/keys/client.key /etc/openvpn/clientconfig/
                cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/clientconfig/
                cd /etc/openvpn/clientconfig/
                sed -i '/my-server/d' client.conf
                serverip=`ifconfig venet0:0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
                remote="remote "
                echo $remote$serverip >> /etc/openvpn/clientconfig/client.conf
                #Check if the openvpn tun0 interface appeared
                if ! `ifconfig|grep -q "tun0"` > /dev/null; then
                        echo "Couldn't find tun0interface"
                else
                        echo "tun0 interface is configured and the VPN is running"
                        exit 1
                fi

        else
                        echo "Can't install openvpn!" 1>&2
                        exit 1
        fi

else
        echo -e "OpenVPN is already installed"1>&2
        exit 1

fi

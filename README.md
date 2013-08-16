uvirtus_server
==============

Scripts for installing uvirtus Server 

How to run the openvpn-installer:
1- you need to have the openvpn-installer.sh file with the vars file in the same directory, for example /home/user directory
2- to run the script you need to run
. /files-dir/openvpn-installer.sh
note: it's dot space then the location of the file
3- some interaction is needed when creating the client certificates “the pass phrase and the company name”.

#cp openssl-1.0.0.cnf openssl.cnf  #this line could be deleted in case the cnf file is already exist

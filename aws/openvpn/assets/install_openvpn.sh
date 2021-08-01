wget http://swupdate.openvpn.org/as/openvpn-as-2.7.4-Ubuntu16.amd_64.deb
# we can not use latest, since v 2.7.5 comes with some dependencies that make the script fail
#wget https://openvpn.net/downloads/openvpn-as-latest-ubuntu16.amd_64.deb

sudo dpkg -i openvpn-as-2.7.4-Ubuntu16.amd_64.deb
#sudo dpkg -i openvpn-as-latest-ubuntu16.amd_64.deb

#OpenVPN does not support piped passwords.  Which is a shame - for now this must be done manually.

yes ${ospassword} | sudo passwd openvpn
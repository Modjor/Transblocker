# OpenVPN Connection Script for Synology
# Create your OpenVPN Connection from the Control Panel / Network interface of your Synology, then use this script to start the OpenVPN Connection
# Make sure to only have ONE SINGLE OpenVPN Client Connection configured - does not work with multiple connection

#retrieve openvpn connection name
CONNECTION_NAME=`cat /usr/syno/etc/synovpnclient/openvpn/ovpnclient.conf | grep conf_name | awk 'BEGIN {FS="="} {print $2}'`

#retrieve pptp connection id
CONNECTION_ID=`ls /usr/syno/etc/synovpnclient/openvpn/ | grep client | awk 'BEGIN {FS="_"} {print $2}' | awk 'BEGIN {FS="."} {print $1}'`


ls /usr/syno/etc/synovpnclient/openvpn/ | grep client | awk 'BEGIN {FS="_"} {print $2}' | awk 'BEGIN {FS="."} {print $1}'

if echo `ifconfig tun0` | grep -q "00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00"
then
        echo "VPN already up"
else
        echo conf_id=$CONNECTION_ID > /usr/syno/etc/synovpnclient/vpnc_connecting
        echo conf_name=$CONNECTION_NAME >> /usr/syno/etc/synovpnclient/vpnc_connecting
        echo proto=openvpn >> /usr/syno/etc/synovpnclient/vpnc_connecting
        /usr/syno/bin/synovpnc reconnect --protocol=openvpn --name=$CONNECTION_NAME
fi



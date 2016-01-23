# PPTP Connection Script for Synology
# Create your OpenVPN Connection from the Control Panel / Network interface of your Synology, then use this script to start the OpenVPN Connection
# Make sure to only have ONE SINGLE OpenVPN Client Connection configured - does not work with multiple connection



#!/bin/sh
VPNC_CONNECTING="/usr/syno/etc/synovpnclient/vpnc_connecting"

#retrieve pptp connection name - create variable connection
CONNECTION_NAME=`cat /usr/syno/etc/synovpnclient/pptp/pptpclient.conf | grep conf_name | awk 'BEGIN {FS="="} {print $2}'`

#retrieve pptp connection id
CONNECTION_ID=`ls /usr/syno/etc/synovpnclient/pptp/ | grep options | awk 'BEGIN {FS="_"} {print $2}' | awk 'BEGIN {FS="."} {print $1}'`


#create vpnc_connecting file
echo conf_id=$CONNECTION_ID > $VPNC_CONNECTING && echo conf_name=$CONNECTION_NAME >> $VPNC_CONNECTING && echo proto=pptp >> $VPNC_CONNECTING


/usr/bin/killall synovpnc 2>/dev/null

#check if pptp is running
if echo `ifconfig ppp0` | grep -q "Link encap:Point-to-Point Protocol"
then
echo "VPN already up"
else
/usr/syno/bin/synovpnc reconnect --protocol=pptp --name=$CONNECTION_NAME --retry=15 --interval=60 --keepfile && return 0;
fi
return 5

#!/bin/ash
# This script:
# - Checks if VPN is running, and reconnect if disconnected (vpnmaintainer.sh)
# - Checks the iptables rules for vpn and update them if needed
# - Checks if the IP has changed since the last execution, and update the transmission config file with the new IP (updatetransmi.sh)
# 
# 1: Error when connecting to VPN
# 5: Unable to load configuration file
#

echo "Transblocker"

# IMPORTANT!!! INSTALLATION PATH: SPECIFY PATH TO TRANSBLOCKER DIRECTORY (Ex: /volume1/scripts/transblocker)
installpath="/volume2/Scripts/transblocker"



#Settings defaults values
configfile="transblocker.conf"
iptables="/sbin/iptables"





# Loading configuration File
if  [ -f $installpath/$configfile ]
then echo "Loading configuration file" && . $installpath/$configfile
else echo "Unable to load "$installpath"/"$configfile	&& echo "verify your installpath variable in transblocker.sh" && exit 5;
fi

# Set the name of the VPN NIC and connection script depending of the VPN client configured in transblocker.conf (tun0/ovpnc.sh for OpenVPN and ppp0/pptp.sh for PPTP)
if [[ $vpntype = "openvpn" ]]
then echo "VPN Type set to OpenVPN, using tun0 as NIC & ovpnc.sh as connection script" && interface="tun0" &&  connectscript="ovpnc.sh"
else if [[ $vpntype="pptp" ]]
then echo "VPN Type set to PPTP, using ppp0 as NIC& pptp.sh as connection script" && interface="ppp0" &&  connectscript="pptp.sh"
else echo "vpntype value unknown. VPN Type not set properly. Please review your transblobker.conf settings" && exit 5;
fi
fi



# Testing if VPN is up - executing vpnmaintainer if not
if [ -z "$(ifconfig | grep "$interface")" ]
then echo "VPN is NOT running. Starting VPN Maintainer" && . $installpath/vpnmaintainer.sh;
else echo "VPN is already running. Continuing with IPTables check"

fi

echo "iptable check"
# Does Does IP Rules have been set? Calling iprule.sh if not
if [ -n "$($iptables -L -v | grep "$interface")" ]
then echo "VPN Rules for "$interface "are already set, no need to reapply";
else echo "Applying iptables for "$interface && . $installpath/iprules.sh

fi


# Starting Transmission check/config update script (updatesettings.sh)
. $installpath/updatesettings.sh




# [EOF]


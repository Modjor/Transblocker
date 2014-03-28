#!/bin/ash
# This script:
# - Checks if VPN is running, and reconnect if disconnected (vpntester.sh)
# - Checks the iptables rules for vpn and update them if needed
# - Checks if the IP has changed since the last execution, and update the transmission config file with the new IP (updatetransmi.sh)
# 
# 1: Error when connecting to VPN
# 5: Unable to load configuration file
#

echo "Transblocker"

# IMPORTANT!!! INSTALLATION PATH: SPECIFY PATH TO TRANSBLOCKER DIRECTORY (Ex: /volume1/scripts/transblocker)
installpath="/volume1/Scripts/transblocker"



#Settings defaults values
configfile="transblocker.conf"
iptables="/sbin/iptables"



# Loading configuration File
if  [ -f $installpath/$configfile ]
then echo "Loading configuration file" && . $installpath/$configfile
else echo "Unable to load "$installpath"/"$configfile	&& echo "verify your installpath variable in transblocker.sh" && exit 5;

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


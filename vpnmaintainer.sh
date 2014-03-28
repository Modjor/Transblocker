#!/bin/ash
# Exit Codes
# 0 VPN is up
# 
# 35 Unable to establish VPN.
# 36 Issue with the connection script
# 37 Connection script does not exist. Verify the connectscript name in transblocker.conf
# This script test the VPN connection, and if it's off tries to restart it using the vpn connection script defined in transblocker.conf

echo "Begin of vpnmaintainer.sh"

# Making sure connection scripts exist
if  [ -f $installpath/$connectscript ]
then echo "Connection Script detected. Continuing";
else echo "Unable to load "$installpath"/"$connectscript	&& echo "verify your connect script name in transblocker.sh" && exit 37;

fi


# Testing if VPN is up
if [ -n "$(ifconfig | grep "$interface")" ]
then echo "VPN is already UP" && return 0;
else # starting VPN using connection script
echo "Starting VPN using connection script:" && echo $installpath/$connectscript" "$vpnscriptarg && . $installpath/$connectscript $vpnscriptarg
fi


# Makes sure VPN is now running (3 attempts and then exit with error 35)
echo "Testing VPN, attempt 1"
if [ -n "$(ifconfig | grep "$interface")" ];
then echo "VPN is now running (wasn't before)" && return 0;
else echo "VPN han not started yet. Checking again in 5 seconds" && sleep 5;
fi

echo "Testing VPN, attempt 2"
if [ -n "$(ifconfig | grep "$interface")" ];
then echo "VPN is now running (wasn't before)" && return 0;
else echo "VPN has still not started yet. Checking again in 5 seconds"  && sleep 5;
fi

echo "Testing VPN, attempt 3"
if [ -n "$(ifconfig | grep "$interface")" ];
then echo "VPN is now running (wasn't before)"  && return 0;
else echo "Connection script seems having issue initiating the VPN connection." && echo "Check your connection script" && exit 35;
fi




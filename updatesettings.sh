# This script catch the IP Address of the vpn interface and update the bind-address-ipv4 value in transmission settings.json if IP has changed
# 
# Possible Exit codes:
# 45 : VPN IP Address has NOT been captured. Either not connected or interface name is incorrect (nic variable to set below)
# 0 : Transmission settings.conf is already up to date with the current VPN IP Address
# 46: VPN has not been captured, stopping transmission and exiting
# 48: unable to access to transmission confiugration file - verify path (settings.json)


# Settings for Stand Alone usage only
nic='tun0' # Specify here the VPN NIC interface name (usually ppp0 for PPTP and tun0 for OpenVPN)
settingsfile='/etc/settings.json' # path to transmission settings.json
ctrlscript="/var/packages/transmission/scripts/start-stop-status" # path to script that control Transmission Service

echo "Starting Transblocker update script"

# check if running in stand alone mode or sourced through transblocker script
if [ -z "$(echo $interface)" ]
then echo "Running in stand alone mode"
else echo "Running thought transblocker" && nic=$interface && settingsfile=$transsettingsfile && ctrlscript=$transctrlscript
fi

# Making sure Transmission configuration file exists
if  [ -f $settingsfile ]
then echo "Using Transmission settings file "$settingsfile
else echo $settingsfile " doesn't seems to exist. Exiting" && echo "Verify your transettings file path in transblocker.conf. Error 48." && return 48;
fi


# Making sure Transmission control script exists
if  [ -f $ctrlscript ]
then echo "Using following Transmission control script: "$ctrlscript
else echo $ctrlscript " doesn't seems to exist. Exiting" && echo "Verify path to Transmission ctrlscript. Error 49." && return 49;
fi




# Capturing VPN client IP Address
vpnipaddr=`/sbin/ifconfig $nic | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# Making sure IP Address has been captured - Exit if not
if [ -n "$(echo $vpnipaddr)" ]
then echo "VPN IP Address captured: " $vpnipaddr
elif [ -z "$(. $ctrlscript status | grep "is not running")" ]
	then echo "VPN IP Address has NOT been captured" && echo "Transmission is running" && $ctrlscript stop && echo "Exiting updatesettings.sh" && return 46;
	else echo "VPN IP Address has NOT been captured" && return 45;

fi



# Checking if IP Address has changed since last update of Transmission settings.json
if [ -n "$(cat $settingsfile | grep $vpnipaddr)" ]
then echo $settingsfile" is already up to date with the current ip address: " $vpnipaddr && return 0
else echo "IP Address has changed since last run. "$settingsfile " has to be updated"
fi

# If IP has changed, updating settings.json
if [ -z "$(. $ctrlscript status | grep "is not running")" ]
then echo "Transmission is currently running. Stopping service before updating binding settings" && $ctrlscript stop && echo "Transmission is now stopped." && sed -i "s/\"bind-address-ipv4\":.*\$/\"bind-address-ipv4\": \"$vpnipaddr\",/" $settingsfile
else echo "Transmission is NOT running." && sed -i "s/\"bind-address-ipv4\":.*\$/\"bind-address-ipv4\": \"$vpnipaddr\",/" $settingsfile
fi


# Making sure settings have been applied before restarting Transmission
if [ -n "$(cat $settingsfile | grep $vpnipaddr)" ]
then echo $settingsfile " has been successfully updated" && echo "(Re)starting Transmission" && $ctrlscript start && return 0;
else echo $settingsfile " has NOT been updated but should have been. Transmission will not be restarted"
fi

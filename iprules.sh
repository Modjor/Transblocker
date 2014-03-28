#!/bin/ash
#iptables configuration script for transblocker
# this script checks if VPPN is running and iptables rules running.
# If VPN is up but no rules are assigned, it will apply the rules

# Possible exit Codes
# 20: VPN is not connected. Rules NOT applied
# 21: Rules to the VPN interface have been already applied - not need to reapply.
# 0: Rules have been applied


unset $vpnic $iptablespath $iptablesset

#######################SET BELOW VALUES FOR STAND ALONE MODE###################

# In stand alone mode (Ex: call by the OpenVPN connection script), set the 2 values below:

vpnnic="tun0"  #your VPN interface. Usually tun0 for Openvpn, ppp0 for PPTP
iptablespath="/sbin/iptables" #Route to iptables binary


##############################################################################




# check if running in stand alone mode or sourced through transblocker script
if [ -z "$(echo $interface)" ]
then interface=$vpnnic && iptables=$iptablespath
fi


# Testing if VPN is up (exiting if not)
if [ -n "$(ifconfig | grep "$interface")" ]
then echo "VPN is connected, continuing";
else echo "VPN Not running, can't apply rules to iptables. Exiting" && exit 20;
fi



# Making sure iptables rules for VPN interface have NOT been defined already defined before applying them
if [ -n "$($iptables -L -v | grep "$interface")" ]
then echo "VPN Rules are already set, no need to reapply - Exiting" && exit 21;
else

##############################################################################################
# Place your iptables rules below - make sure to use the $iptables and $interface variables  #
##############################################################################################

    #Set incoming connections to ACCEPT on the VPN interface
    #$iptables -A INPUT -i $interface -p tcp --destination-port  22  -j ACCEPT # example to allow incoming ssh connections
	
	# Allow incoming conneciton on 51413 (Transmission Peer listening port)
	iptables -A INPUT -i $interface -p udp -m udp --dport 51412 -j ACCEPT 
	iptables -A INPUT -i $interface -p tcp -m tcp --dport 51412 -j ACCEPT 
	

	
########################NO MODIFICATION AFTER THAT LINE##########################
	# Allow incoming traffic for existing/related connections
	iptables -A INPUT -i $interface -m state --state ESTABLISHED,RELATED -j ACCEPT
	
    #if none of the rules were matched DROP  ALL incoming traffic on vpn interface                     #
    $iptables -A INPUT -i $interface -j DROP


	fi;

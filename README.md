transblocker
============

transblocker is a set of scripts for Synology DSM that maintains VPN client connection, associated iptables rules, and Transmissionbt binding to VPN interface


IMORTANT: transblocker is a very Alpha set of scripts - use it at our own risk
I’m running this smoothly on my own NAS, but it doesn’t mean it’s 100% safe

I’ve been using these scripts on late 4.x and early 5.x DSM

transblocker is a set of scripts that are mainly designed to run on Synology DSM, to achieve he following:
- Maintaining VPN client connection (reconnect when lost) – Only OpenVPN supported so far. But plan is also to add PPTP
- Enabling IPTables rules to block any incoming traffic on the Virtual interface
- Maintaining Transmissionbt binding with the Vitual interface IP, by automatically updating transmission settings.json with the new VPN IP when it changes

Transblocker.sh is the main script that you should schedule to run using a cron task.
Make sure to edit/create the following file before creating a cron:
-	Transblocker.conf 
-	Transblocker.sh: Set the installation path on line 14
-	Create your own VPN provider ovpn file – and add the path to the file containing your username and password (userpath.auth, as described in sample.ovpn)
Once you have edited the files accordingely to your own environment, run transblocker once  from command line to make sure it’s working fine. From the installation directory, type:
“sh transblocker.sh”

If everything goes fine you should expect:
-	VPN connection being connected if it wasn”t already
-	IPTables rules applied to your VPN interface if it wasn’t already
-	Stop the transmission service, update settings.json with the right binding ip and restart the transmission service


This script will block all incoming traffic on the virtual network interface, except for port 51412 (Transmissionqt peer listening port). You can edit the iprules.sh script to change/add the existing rules.
If you do so, use the variable $iptables to call iptables, and $interface call the VPN NIC:
###############
iptables -A INPUT -i $interface -p tcp -m tcp --dport 80 -j ACCEPT	
##############
 

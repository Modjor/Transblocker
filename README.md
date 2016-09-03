Transblocker
============

Purposes of Transblocker are:
- Maintain Transmission binding with VPN NIC (so your torrent traffic is ONLY going through your VPN connection)
- Keep VPN connection up and running (since the Synology auto reconnect is not extremely flexible/reliable)
- For DSM 5.x Only, enable Firewall for your VPN interface (feature available for DSM 5 and lower only - prior to DSM 6.x, the Synology VPN Client was widely opened)


Why would you use this script?
If you ar using some automatic provider/downloader tools associated with your transmission client, you probably want that all these few points are always properly set. 



transblocker is a set of scripts for Synology DSM that maintains VPN client connection, associated iptables rules, and Transmissionbt binding to VPN interface


IMORTANT: transblocker is a very Alpha set of scripts - use it at our own risk
I’m running this smoothly on my own NAS, but it doesn’t mean it’s 100% safe


I’ve been using these scripts on late 4.x and 5.x DSM

transblocker is a set of scripts that are mainly designed to run on Synology DSM, to achieve he following:
- Maintaining VPN client connection (reconnect when lost) – Only OpenVPN supported so far. But plan is also to add PPTP
- Enabling IPTables rules to block any incoming traffic on the Virtual interface
- Maintaining Transmissionbt binding with the Vitual interface IP, by automatically updating transmission settings.json with the new VPN IP when it changes

Transblocker.sh is the main script that you should schedule to run using a cron task.

How To install:

I) Create a new VPN client connection - PPTP or OpenVPN, using your Synology Control Panel => Network
 Note: You can only have one connection of each. If multiple PPTP or multiple OpenVPN client conenctio nare setup, the script will fail (however, you can have 1 OpenVPN connection and 1 PPTP connection)

II) Make sure to edit the following file before creating a cron:
-	Transblocker.conf: Make sure to specify the VPN Type your ar eusing (openvpn or pptp) 
-	Transblocker.sh: Set the installation path on line 14 (full path to the diretory where you copied the traslocker files)


Once you have edited the files accordingely to your own environment, run transblocker once  from command line to make sure it’s working fine. From the installation directory, type:
“sh transblocker.sh”

If everything goes fine you should expect:
-	VPN connection being connected if it wasn”t already
-	IPTables rules applied to your VPN interface if it wasn’t already
-	Stop the transmission service, update settings.json with the right binding ip and restart the transmission service

DSM 5.x and lower only:
This script will block all incoming traffic on the virtual network interface, except for port 51412 (Transmissionqt peer listening port). You can edit the iprules.sh script to change/add the existing rules.
If you do so, use the variable $iptables to call iptables, and $interface call the VPN NIC:

'''''''''''''''''''''

$iptables -A INPUT -i $interface -p tcp -m tcp --dport 80 -j ACCEPT	

'''''''''''''''''''''
 

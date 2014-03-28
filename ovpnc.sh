#!/bin/sh
#
# Startup script for openvpn client
# 
# Possible exit codes
# 5: Unable to load ovpn configuration file
# 7: Unable to access openvpn client binary
#

#############################################################################################
#            Configuration for stand alone execution
#
#Path to OpenvPN Client binary:
openvpnsa=/usr/sbin/openvpn
#
#Path to OpenVPN client config file directory (where .ovpn are stored):
ovpndirsa="/volume1/Scripts/transblocker" 
#
# Client config filename:
ovpnfilesa="SlickAmsterdam.ovpn"
#############################################################################################

echo "Begin of ovpnc.sh"

KERNEL_MODULES="x_tables.ko ip_tables.ko iptable_filter.ko nf_conntrack.ko nf_defrag_ipv4.ko nf_conntrack_ipv4.ko nf_nat.ko iptable_nat.ko ipt_REDIRECT.ko xt_multiport.ko xt_tcpudp.ko xt_state.ko ipt_MASQUERADE.ko tun.ko"
SERVICE="ovpnc"



# check if running in stand alone mode or sourced through transblocker script
if [ -z "$(echo $interface)" ]
then echo "Running in stand alone mode" && CONF_DIR=$ovpndirsa && OPENVPN_CONF=$ovpnfilesa
else echo "Running inside transblocker" && CONF_DIR=$ovpndir && OPENVPN_CONF=$ovpnfile && openvpnsa=$openvpn
fi

# Making sure .ovpn client file is available
if  [ -f $CONF_DIR/$OPENVPN_CONF ]
then echo "Using OpenVpn client configuration:" && echo $CONF_DIR/$OPENVPN_CONF
else echo $CONF_DIR"/"$OPENVPN_CONF" doesn't seems to exist. Exiting" && echo "Verify your ovpn path in transblocker.conf. Error 5." && exit 5;
fi

# Making sure OpenVpn Client binary is available
if  [ -f $openvpn ]
then echo "Using OpenVPN Client:" && echo $CONF_DIR"/"$OPENVPN_CONF
else echo $openvpn "binary doesn't seems to exist. Exiting" && echo "Verify your 'openvpn' variable in transblocker.conf. Error 5." && exit 7;
fi




reverse_modules() {
	local modules=$1
	local mod
	local ret=""

	for mod in $modules; do
	    ret="$mod $ret"
	done

	echo $ret
}

unload_module() {
	local modules=`reverse_modules "${KERNEL_MODULES}"`
	/usr/syno/bin/iptablestool --rmmod $SERVICE $modules
}

case "$1" in
  start)
	echo 1 > /proc/sys/net/ipv4/ip_forward

	# Make device if not present (not devfs)
	if [ ! -c /dev/net/tun ]; then
  		# Make /dev/net directory if needed
  		if [ ! -d /dev/net ]; then
        		mkdir -m 755 /dev/net
  		fi
  		mknod /dev/net/tun c 10 200
	fi

	/usr/syno/bin/iptablestool --insmod $SERVICE ${KERNEL_MODULES}

        echo "Starting openvpn client..."
	/usr/sbin/openvpn --daemon --cd ${CONF_DIR} --config ${OPENVPN_CONF} --writepid /var/run/ovpn_client.pid

        ;;
  stop)
        echo "Stopping openvpn client..."
        /bin/kill `cat /var/run/ovpn_client.pid` 2>/dev/null

	sleep 2	
	unload_module;
	;;
  unload)
	unload_module;
	;;
  *)
        echo "Usage of ovpnc.sh: $0 {start conf|stop}"
        return 1
esac
return

# [EOF]


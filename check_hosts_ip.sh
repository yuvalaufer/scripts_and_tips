#! /bin/bash


LOGFILE=/var/tmp/ip_check.log

if [ ! -f $LOGFILE ]; then 
	touch $LOGFILE
else 
	cp /dev/null $LOGFILE
fi


INPUTFILE=/etc/hosts

n_of_ips=`cat $INPUTFILE |grep -v 127.0.0.1 |grep "\." |wc -l`

function ping_ip () {
ip_addr=$1
s_name=$2
pingop=`ping $ip_addr -c 15`

if [ `echo $pingop |grep "15 received" |wc -l` != "0" ]; then
		echo "server name: $s_name with ip address: $ip_addr -------> is alive" >> $LOGFILE
elif 
	[ `echo $pingop |grep -v "15 received" |grep "100% packet loss" |wc -l` != "0" ]; then
			echo "server name: $s_name with ip adress: $ip_addr -------> not reachable!!!" >> $LOGFILE
elif [ `echo $pingop |grep -v "15 received" |grep -v "100% packet loss" |grep "packet loss" |wc -l` == "1" ]; then
			echo "server name: $s_name with ip address: $ip_addr -------> is alive , but there is a packet lose. please check your connection" >> $LOGFILE
fi
}

ip_list=($(cat $INPUTFILE |grep -v  127.0.0.1 |grep "\." |awk '{print $1}' |awk 'BEGIN { ORS = " " } { print }'))
server_list=($(cat $INPUTFILE |grep -v  127.0.0.1 |grep "\." |awk '{print $2}' |awk 'BEGIN { ORS = " " } { print }'))


for ((i=0; i<$n_of_ips; i++)); do
	echo "----------------------------"
	echo "checking server name:"
	echo "${server_list[$i]}"
	echo "with ip:"
	echo "${ip_list[$i]}"
	echo "----------------------------"
	ping_ip ${ip_list[$i]} ${server_list[$i]}
done

echo "end of script"
echo "please check script log: $LOGFILE"


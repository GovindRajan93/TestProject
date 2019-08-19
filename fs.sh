hostname=`ssh $VM "hostname"` 2> /dev/null
ip=`ssh $VM "hostname -I"` 2> /dev/null; echo "$(tput setaf 6)"; echo "$hostname:$ip"
uptime=`ssh $VM "uptime | cut -d ',' -f1,2 | cut -b 13-28"` 2> /dev/null; echo "uptime:$uptime"
load=`ssh $VM "uptime | cut -d ',' -f4 | cut -d ':' -f2 | cut -d '.' -f1"` 2> /dev/null
thresh=5
if [ $load -lt $thresh ]
then
echo "$(tput setaf 2)Load is OK"; echo "Current Load:" $load
else
echo "$(tput setaf 1)Load is HIGH"; echo "Current Load:" $load
fi

###Node Exporter Status##
nestatus=`ssh $VM "ps -ef | grep -i node_exporter | grep -v grep | wc -l"` 2> /dev/null
if [ $nestatus = 1 ]
then
echo "$(tput setaf 2)Node exporter is running" 2> /dev/null
else
echo "$(tput setaf 1)Node exporter is not running $(tput setaf 7)"
fi

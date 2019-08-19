hostname=`hostname`
ip=`hostname -I`; echo "$(tput setaf 6)"; echo "$hostname:$ip"
uptime=`uptime | cut -d ',' -f1,2 | cut -b 13-28`; echo "uptime:$uptime"
load=`uptime | cut -d ',' -f4 | cut -d ':' -f2 | cut -d '.' -f1`
thresh=5
if [ $load -lt $thresh ]
then
echo "Load is OK"; echo "Current Load:" $load
else
echo "Load is HIGH"; echo "Current Load:" $load
fi

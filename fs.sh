hostname=`hostname` 2> /dev/null
ip=`hostname -I` 2> /dev/null; echo "$(tput setaf 6)"; echo "$hostname:$ip"
uptime=`uptime | cut -d ',' -f1,2 | cut -b 13-28` 2> /dev/null; echo "uptime:$uptime"
load=`uptime | cut -d ',' -f4 | cut -d ':' -f2 | cut -d '.' -f1` 2> /dev/null
thresh=5
if [ $load -lt $thresh ]
then
echo "$(tput setaf 2)Load is OK"; echo "Current Load:" $load
else
echo "$(tput setaf 1)Load is HIGH"; echo "Current Load:" $load
fi

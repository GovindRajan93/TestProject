[ansibleuser@dotcom-prod-eun-bas-pci01 fs_check]$ cat fs.sh
for VM in `cat fslist`
do
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

climit=10
cpu_check()
{
#> /home/ansibleuser/fs_check/top.df
ssh $VM 'top -b -n 5' > /home/ansibleuser/fs_check/top.df 2> /dev/null
ar=$(cat top.df | grep -i ^Cpu | awk '{print $2}' | tr -d "," | sed 's/%us//g'| cut -d'.' -f1)
cpu_us=`echo "${ar[*]}" | sort -nr | head -n 1`; echo CPU Utilization:$cpu_us
#cpu_u=`sed -n 3p /home/ansibleuser/fs_check/top.df | awk '{print $2}' | tr -d ","`; echo CPU utilization: $cpu_u
#cpu_us=`sed -n 3p /home/ansibleuser/fs_check/top.df | awk '{print $2}' | tr -d "," | sed 's/%us//g' | cut -c1-2`; #echo CPU Utilization: $cpu_us
#cpu_sys=`sed -n 3p /home/ansibleuser/fs_check/top.df | awk '{print $3}'| tr -d "," `; echo CPU utilization by System process: $cpu_sys
if [ $cpu_us -gt $climit ]
then
echo "$(tput setaf 1) $(tput bold) Showing more cpu utilized process $(tput sgr 0) $(tput setaf 7)"
ssh $VM 'ps -eo pid,ppid,ni,pri,user,comm,command,time,%cpu,%mem --sort=-%cpu | head -n 8'
echo "$(tput setaf 1) $(tput bold) Showing more memory utilized process $(tput sgr 0) $(tput setaf 7)"
ssh $VM 'ps -eo pid,ppid,ni,pri,user,comm,command,time,%cpu,%mem --sort=-%mem | head -n 8'
fi
}
cpu_check $VM

mem_check()
{
ssh $VM 'free -mh' 2> /dev/null > /home/ansibleuser/fs_check/mem.df
memu=$(cat /home/ansibleuser/fs_check/mem.df | head -n 2 | tail -n 1 | awk '{print $3}' | tr -d 'G')
memf=$(cat /home/ansibleuser/fs_check/mem.df | head -n 2 | tail -n 1 | awk '{print $2}' | tr -d 'G')
m=$(echo "scale=2; "$memu / $memf" * 100;" | bc) ; echo Memory used: $m
}
mem_check $VM
#done 2> /dev/null

#File system checking
limit=70
fs_check()
{
echo "$(tput setaf 3)----------------------------------------------------------------------"
echo "$(tput setaf 7)"; echo "File System which utilised more than $limit%"
echo "$(tput setaf 3)----------------------------------------------------------------------"
echo "$(tput setaf 1)"
ssh $VM 'df -hP | grep -v ^F' 2> /dev/null > /home/ansibleuser/fs_check/tmp.df
cat /home/ansibleuser/fs_check/tmp.df | awk '{ print $5 $6}' | while read output;
do
utilization=$(echo $output | awk '{print $1}' | cut -d'%' -f1)
filesystem=$(echo $output | cut -d'%' -f2)
if [ $utilization -gt $limit ]
then
echo $utilization $filesystem
fi
done
echo "$(tput setaf 7)"
}
fs_check $VM
done 2> /dev/null

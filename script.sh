for i in `cat $1-hosts`
do
bash +x $i
done

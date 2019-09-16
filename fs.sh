date
hostname
hostname -I
for i in {1..10}
do
echo Hello World $i
done
echo "Script has completed `date +%D`"
echo "Number of users logged in:"
w -f

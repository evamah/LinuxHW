#!/bin/bash
x="This is x Variable of string"
echo "x test is: $x"
y=10
z=15
echo -e "$x\n$y\n$z"
sum=$((y + z))
echo "Sum of y and z is: $sum"

echo -n "Enter number: "
read num
if [ $num -gt 10 ]; then
    echo "The number is Greater than 10"
else
    echo "The number is Not greater than 10"
fi

dir=Der_$(whoami)
mkdir $dir
filepath=""
counter=0

while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    counter=$((counter + 1))
    filepath=${dir}/file_${counter}.txt
    #touch $filepath
    echo $counter >> $filepath
    cat $filepath
    #ls -l $dir
done



 


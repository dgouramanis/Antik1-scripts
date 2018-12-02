#!/bin/bash

axis_val=0
displacement_val=0.0000

echo "Enter X,Y or Z to select axis:"
read axis_val

echo "Enter displacement value:"
read displacement_val

if [ "$axis_val" = "x" ]; then
axis_val="X"
fi
if [ "$axis_val" = "y" ]; then
axis_val="Y"
fi
if [ "$axis_val" = "z" ]; then
axis_val="Z"
fi
if [ "$axis_val" = "a" ]; then
axis_val="A"
fi



echo -e "G70 G92 G90 \nG0 \c" > /home/debian/SCRIPTS/temporary-G.nc
echo -e "$axis_val\c" >> /home/debian/SCRIPTS/temporary-G.nc
echo -e "$displacement_val\c" >> /home/debian/SCRIPTS/temporary-G.nc
#echo -e " F15\c" >> /home/debian/SCRIPTS/temporary-G.nc


/usr/share/beagleg/machine-control -P -c /usr/share/beagleg/OPTOCAPE.config /home/debian/SCRIPTS/temporary-G.nc ;


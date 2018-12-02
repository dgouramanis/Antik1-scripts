#!/bin/bash

#allows only one instance of this script to run
if [ "$(pgrep -x $(basename $0))" != "$$" ]; then
 echo "Error: another instance of $(basename $0) is already running"
 exit 1
fi


echo "Select an option:"
echo "1) Run G code from USB"
echo "2) Peck drill cycle"
read selection

#SELECTION 1 RUNS G CODE FROM USB FLASH DRIVE
if [ "$selection" == 1 ]; then
echo "Searching USB drive..."
if [ -e /dev/sda1 ]
then
  umount /dev/sda1
  mount /dev/sda1 /beagleg_media
  echo ""  
else
  echo "/dev/sda1 not found."
  
  if [ ! -e /dev/sd* ]; then
    echo "no disks found."
    exit 1
  fi

  echo "Enter disk directory or type "e" to exit"
  ls /dev/sd*
  read disk_directory
  
  if [ "$disk_directory" == "e" ]; then
   echo "done."
   exit 1
  fi

  sleep 1
  umount $disk_directory
  mount $disk_directory /beagleg_media
fi

echo ""
echo ""

echo "Listing files..."
echo ""
ls /beagleg_media

echo ""
read -p "Choose a file: " -i "/beagleg_media/" -e g_file
sleep 1

echo ""
echo "Running file  $g_file"

echo ""
read -p "Enter a feedrate override: " -i "1.0" -e f_override
sleep 1

sleep 0.1

if [ "$g_file" == "/beagleg_media/" ]; then
 echo "Error: no file selected."
 exit 1
fi

/usr/share/beagleg/machine-control -P -f $f_override -c /usr/share/beagleg/OPTOCAPE.config $g_file ;

umount /beagleg_media

exit 1
fi
#END SELECTION 1


#SELECTION 2 CANNED PECK DRILL CYCLE
if [ "$selection" == 2 ]; then

echo "Enter number of pecks [1, 5, 10, 20]:"
read pecks

peck_file=99

if [ "$pecks" == "1" ]; then
peck_file="/home/debian/SCRIPTS/canned-cycle/peck1.nc"
fi
if [ "$pecks" == "5" ]; then
peck_file="/home/debian/SCRIPTS/canned-cycle/peck5.nc"
fi
if [ "$pecks" == "10" ]; then
peck_file="/home/debian/SCRIPTS/canned-cycle/peck10.nc"
fi
if [ "$pecks" == "20" ]; then
peck_file="/home/debian/SCRIPTS/canned-cycle/peck20.nc"
fi
if [ "$peck_file" = "99" ]; then
echo "Error: must select 5, 10 or 20"
exit 1
fi

depth=0
feed=0
spindle=0
echo "Hole depth:"
read depth
if [ -z "$depth" ]; then
echo "Error: depth = 0"
exit 1
fi

echo "Feed rate[2]:"
read feed
if [ -z "$feed" ]; then
feed=2
echo -e "\033[2A" #moves cursor up one
echo "$feed"
fi

echo "Spindle speed[200]:"
read spindle
if [ -z "$spindle" ]; then
spindle=200
echo -e "\033[2A" #moves cursor up one
echo "$spindle"
fi

echo -e "#1=$depth\n" > /home/debian/SCRIPTS/canned-cycle/temporary-peck.nc
echo -e "#2=$feed\n" >> /home/debian/SCRIPTS/canned-cycle/temporary-peck.nc
echo -e "#3=$spindle\n" >> /home/debian/SCRIPTS/canned-cycle/temporary-peck.nc
cat $peck_file >> /home/debian/SCRIPTS/canned-cycle/temporary-peck.nc

echo ""
echo "depth = $depth"
echo "feed = $feed"
echo "spindle = $spindle"
echo "Starting $pecks pecks..."

sleep 1

/usr/share/beagleg/machine-control -P -c /usr/share/beagleg/OPTOCAPE.config /home/debian/SCRIPTS/canned-cycle/temporary-peck.nc ;

echo ""
echo ""
echo "Final position offset Z +0.100"
echo ""
echo ""

exit 1
fi


#!/bin/bash
# System Info Report (Only using bash and shell tools 
# (iostat, free, bc, sed, uptime, date, grep) avoided awk for this tool (no reason)
# Author: Andrew Fitt
# Date: 5 August 2018



# Global Variables
# Read the memory utilisation stats into an array after splitting
IFS=' ' read -r -a memlist <<< `free | grep Mem`
# Read the current CPU average values into an array after splitting
IFS=' ' read -r -a cpulist <<< `iostat -c | grep "^\ *[0-9]"`

datetimenow="`date "+Date: %d/%m/%y%tTime: %H:%M:%S"` Host Name `uname -n`"


printf "%s\n" "-------------------------- System Report ----------------------------"
printf "%s %s %s %-20s %s %s %s\n" ${datetimenow}
echo ---------------------------------------------------------------------

# print out the up time of the system in human friendly format
echo Uptime: `uptime -p | sed s/^up\ //g` 

#print out a count of the number of users logged into the sytem
echo Current Users: `who -u | wc -l` 

# print out the percentage memory utilization
printf "Memory Utilisation: %s\n" `echo "scale=2; (${memlist[2]}/${memlist[1]})*100" | bc | sed s/\.[0-9]*$/%/`

printf "CPU Load: %3.2f\n" `echo "scale=2; (${cpulist[0]}+${cpulist[2]})" | bc`
echo ---------------------------- End Report -----------------------------


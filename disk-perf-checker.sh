#! /bin/bash

<<multi-line-comment
    Scope of the Code: Finds the disk performances with help of utility (dd). 
    Date of Creation: 15-May-2014
    Last Modified: 15-Jul-2014
    Written by: Sriram Ganesh (sriramganesh@yahoo.com)
multi-line-comment

# This Script is used to track performance of disk.

which dd > /dev/null || { echo "Unable to find dd. Exiting..."; exit 1;}
which getopt >/dev/null || { echo "Unable to find getopt. Exiting..."; exit 1;}


OPTS=$(getopt hp: "$@")

# Specify the Size of Blocks here.
BLOCK_SIZE=(512 1024 4096 8192 16384) 

# Specify the Size of Counts here
COUNT_SIZE=(2 4 20 50 100 200 300 500 1000)

# Function for finding Read Performance
# Input: Count and Block size
# Output: Read result
function readPerformance {	
	COUNT=$1
	BLOCK=$2
	FILE='disktest'
        READ_RESULT=$(dd if=/dev/zero of="$DIR/$FILE" count=$COUNT bs=$BLOCK 2>&1 | tail -1 | awk '{print $(NF-1)" "$NF}')
}


# Function for finding Write Performance
# Input: Count and Block size
# Output: Write result
function writePerformance {	
	COUNT=$1
	BLOCK=$2
	FILE='disktest'
    WRITE_RESULT=$(dd if="$DIR/$FILE" of=/dev/zero count=$COUNT bs=$BLOCK 2>&1 | tail -1 | awk '{print $(NF-1)" "$NF}')
}

# Function for usage
function usage {
	echo -e "This Script is used to track performance of disk.\nUSAGE: $0 -p PATH."
	exit 1
}

DIR=''
for EACH in $OPTS
do
	case $EACH in
	-h) usage
	    shift;;
	-p) shift;
	    DIR=$1
	    shift;;
	esac
done

[ ! -d "$DIR" ] && { echo "Unable to find directory. Exiting..."; exit 1;} 

# Calculating the Read & Write performance for given directory.
for EACH_BLOCK in "${BLOCK_SIZE[@]}"
do
	for EACH_COUNT in "${COUNT_SIZE[@]}"
	do
		readPerformance $EACH_COUNT $EACH_BLOCK
		writePerformance $EACH_COUNT $EACH_BLOCK
		echo "bs:$EACH_BLOCK, count:$EACH_COUNT"
		echo "READ-RESULT: $READ_RESULT"
		echo "WRITE-RESULT: $WRITE_RESULT"
		echo "  -------------   "
	done
done

#! /bin/bash 

<<multi-line-comment
    Scope of the Code: CPU and Memory benchmarking with help of utility (sysbench). 
    Date of Creation: 15-May-2014
    Last Modified: 15-Jul-2014
    Written by: Sriram Ganesh (sriramganesh@yahoo.com)
multi-line-comment


which sysbench 1>/dev/null || { echo "$0: Unable to find sysbench utility. Exiting..."; exit 1;}

function usage {
	echo -e "Script used for system benchmarking. Installation of sysbench is required.\nUsage: $0 cpu|threads|memory"
	exit 1;
}
	

# Function: Finding the performance for various thread counts. 
# Workflow:
# With the threads workload, each worker thread will be allocated a mutex (a sort of lock) and will, for each execution, loop a number of times (documented as the number of yields) in which it takes the lock, yields (meaning it asks the scheduler to stop itself from running and put it back and the end of the runqueue) and then, when it is scheduled again for execution, unlock. 
# By tuning the various parameters, one can simulate situations with high concurrent threading with the same lock, or high concurrent threading with several different locks, etc. 
# Input: NONE
# Output: Threads Benchmark Results
function perf_test_threads {
	echo -e "\nPerformance testing Results - THREADS:\n" 
	THD_CNT=64
        NO_REQS=10
        NO_LCKS=1
	for (( t=$THD_CNT; t<=1024; t=$t+$t ))
	do
		echo -e "\n\nThread count: $t"
		for (( r=$NO_REQS; r<=10000; r=$r*10 ))
		do	
			echo -e "\nNo of reqs: $r"
			for (( l=$NO_LCKS; l<=8; l=$l*2 ))
			do
				sysbench --test=threads --num-threads=$THD_CNT --max-requests=$TEMP_NO_REQS --thread-locks=$TEMP_NO_LCKS run
			done
		done
	done
}

# Function: CPU performance testing. 
# Workflow:
# When running with the cpu workload, sysbench will verify prime numbers by doing standard division of the number by all numbers between 2 and the square root of the number. If any number gives a remainder of 0, the next number is calculated. As you can imagine, this will put some stress on the CPU, but only on a very limited set of the CPUs features. 
# The benchmark can be configured with the number of simultaneous threads and the maximum number to verify if it is a prime. 
# Input: NONE
# Output: CPU Benchmark Results
function perf_test_cpu {
	THD_CNT=2
	PRIME_NO=100
	echo -e "\nPerformance testing Results - CPU:\n"
	for (( n=$PRIME_NO; n<=10000; n=$n*10 ))
	do
		sysbench --test=cpu --cpu-max-prime=$n --num-threads=$THD_CNT run
	done
}

# Function: Memory performance testing.
# Workflow:
# When using the memory test in sysbench, the benchmark application will allocate a memory buffer and then read or write from it, each time for the size of a pointer (so 32bit or 64bit), and each execution until the total buffer size has been read from or written to.
# Input: NONE
# Output: Memory Benchmark Results
function perf_test_memory {
	THD_CNT=1
	echo -e "\nPerformance testing Results - MEMORY:\n"
	for (( t=$THD_CNT; t<=8; t=$t+$t ))
        do
		sysbench --test=memory --num-threads=$t run
	done	
}

# Receives input.
OPTION="$1"

case "$OPTION" in
	cpu) perf_test_cpu
		;;
	threads) perf_test_threads
		;;
	memory) perf_test_memory
		;;
	*) usage
	   ;;
esac

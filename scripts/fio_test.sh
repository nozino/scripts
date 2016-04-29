#!/bin/bash

FILENAME="/dev/sdb"
DO_INIT="no"
FILESIZE=1G
READWRITE="randread"
IODEPTH=1

function parse_args() {
    [ $# -lt 1 ] && echo "$0: cmd <cdev0,cdev1,...,cdevN> <bdev0,bdev1,...,bdevN>" && exit 1

    FILENAME=$1
    [ ! -e $FILENAME ] && echo "no device $FILENAME" && exit 1
    shift

    while [[ $# -ge 1 ]]
    do
	key="$1"
	case $key in
	        -I|--init-disk)
		DO_INIT="yes"
		shift
		;;
	        *)
            # unknown option
		;;
	    esac
	shift # past argument or value
    done

    echo "FILENAME=$FILENAME"
}

function init_disk() {
    echo "INIT DISK, $FILENAME"
#    dd if=/dev/zero of=$FILENAME bs=1G
#    dd if=/dev/zero of=$FILENAME bs=1G
}

function init() {
    if [ $DO_INIT = "yes" ]
    then
	init_disk
    fi
}

function do_fio() {
    bs=$1

    [ -z $bs ] && echo "no block size" && exit 1

    for numjobs in 1 2 4 6 16 32
    do
	echo "numjobs=$numjobs"
	cmd="fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=$FILENAME --bs=$bs --iodepth=1 --size=$FILESIZE --readwrite=$READWRITE --numjobs=$numjobs"
	echo "cmd=$cmd"
	eval $cmd
    done
}

function do_test() {
    echo "************************************************"
    echo "DISK=$FILENAME"
    echo "************************************************"
    echo "================================================"
    echo "bs=512, size=16G, iodepth=1"
    echo "================================================"

    for bs in "512" "4k" "8k" "16k"
    do
	do_fio $bs
    done
}

parse_args $@

init
do_test

exit 0

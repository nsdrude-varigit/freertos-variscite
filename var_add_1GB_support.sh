#!/bin/bash

# -e  Exit immediately if a command exits with a non-zero status.
set -e

readonly SCRIPT_NAME=${0##*/}
readonly BSP_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage()
{
	echo
	echo "This script remap linker files (*.ld) and Vring regions to generate demos running on the"
	echo "VAR-SOM-MX8M-PLUS and DART-MX8M-PLUS whith 1GB DDR"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <dart_mx8mp|som_mx8mp> board folder"
	echo
	echo "Examples of use for DART-MX8M-Plus:"
	echo "  ./${SCRIPT_NAME} -b dart_mx8mp"
	echo
}

print_wiki_referencies ()
{
	echo 
	echo "To complete the 1GB support the follow extra changes are required:"
	echo " - U-Boot: change DDR M7 address and cma size in the enviroment"
	echo " - Kernel: change M7 device tree file"
	echo " - FS:     change variscite-rproc.conf file"
	echo " The detailed guide is provided in the wiki at link: xxxxxx"
	echo -n "Press (y) to continue or different key to exit: "
	read key_pressed
	if [ "$key_pressed" != "y" ]; then
		exit 1
	fi
}

check_params()
{
	if [ "$BSP_BASE_DIR" != "$PWD" ]; then
		echo "ERROR0: Script must be run from $BSP_BASE_DIR"
		usage
		exit 1
	fi

	if [ -z "$BOARD_DIR" ]; then
		echo "ERROR1: \"board folder is empty"
		usage
		exit 1
	fi

	if [[ ! -d boards/$BOARD_DIR ]] ; then
		echo "ERROR1: \"boards/$BOARD_DIR\" does not exist"
		usage
		exit 1
	fi
}

add_1GB_support()
{
	case $BOARD_DIR in

	dart_mx8mp|som_mx8mp)
		echo "Adjust *cm7_*.ld files"
		for i in $(find boards/$BOARD_DIR -name "*cm7_ddr_ram.ld"); do
			sed -i 's/m_interrupts          (RX)  : ORIGIN = 0x80000000, LENGTH = 0x00000400/m_interrupts          (RX)  : ORIGIN = 0x7E000000, LENGTH = 0x00000400/g' "$i"
			sed -i 's/m_text                (RX)  : ORIGIN = 0x80000400, LENGTH = 0x001FFC00/m_text                (RX)  : ORIGIN = 0x7E000400, LENGTH = 0x001FFC00/g' "$i"
			sed -i 's/m_data                (RW)  : ORIGIN = 0x80200000, LENGTH = 0x00200000/m_data                (RW)  : ORIGIN = 0x7E200000, LENGTH = 0x00200000/g' "$i"
			sed -i 's/m_data2               (RW)  : ORIGIN = 0x80400000, LENGTH = 0x00C00000/m_data2               (RW)  : ORIGIN = 0x7E400000, LENGTH = 0x00C00000/g' "$i"
		done

		for i in $(find boards/$BOARD_DIR -name "*cm7_ram.ld"); do
			sed -i 's/m_data2               (RW)  : ORIGIN = 0x80000000, LENGTH = 0x01000000/m_data2               (RW)  : ORIGIN = 0x7E000000, LENGTH = 0x01000000/g' "$i"
		done

		for i in $(find boards/$BOARD_DIR -name "*cm7_flash.ld"); do
			sed -i 's/m_data2               (RW)  : ORIGIN = 0x80000000, LENGTH = 0x01000000/m_data2               (RW)  : ORIGIN = 0x7E000000, LENGTH = 0x01000000/g' "$i"
		done
		;;
	esac
}

while getopts :b:c:d:e:t: OPTION;
do
	case $OPTION in
	b)
		readonly BOARD_DIR=$OPTARG
		;;
	*)
		usage
		exit 1
		;;
	esac
done

echo "Remember to investigate 0x80000000 in the board.c files !!!!!"
print_wiki_references
check_params
add_1GB_support

exit 0

#!/bin/bash

# -e  Exit immediately if a command exits with a non-zero status.
set -e

SCRIPT_NAME=${0##*/}
BSP_BASE_DIR=$PWD
PATH_TO_ARM_TOOLCHAIN="${BSP_BASE_DIR}/../gcc-arm-none-eabi-9-2020-q2-update"

usage()
{
	echo
	echo "This script generates a .vscode folder to add Visual Studio Code support to freertos-variscite examples"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <dart_mx8mq>				board folder (DART-MX8M)."
	echo " -d <GDBServer folder>"
	echo " -e <freertos example folder>		example folder where add .vscode>"
	echo " -t <tcm/ddr>				ram target"
	echo
	echo "hello_world example: ./var_add_vscode_support.sh -b dart_mx8mq -d /opt/SEGGER/JLink_Linux_V754c_x86_64 -e boards/dart_mx8mq/multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote -r hello_world.elf -t ddr"

}

check_params()
{
	if [[ ! -d boards/$BOARD_DIR ]] ; then
		echo "ERROR: \"boards/$BOARD_DIR\" does not exist"
		usage
		exit 1
	fi

	if [[ ! -d $GDBSERVER_DIR ]] ; then
		echo "ERROR: \"$GDBSERVER_DIR\" does not exist"
		echo "Download and Install J-Link Software: https://www.segger.com/downloads/jlink/"
		echo "e.g. sudo dpkg -i ~/Downloads/JLink_Linux_V754d_x86_64.deb"
		usage
		exit 1
	fi

	if [[ ! -d $PATH_TO_EXAMPLE_SRC ]] ; then
		echo "ERROR: \"$PATH_TO_EXAMPLE_SRC\" does not exist"
		usage
		exit 1
	fi

	if [[ $RAM_TARGET != "tcm" && $RAM_TARGET != "ddr" ]]; then
		echo "ERROR: \"$RAM_TARGET\" does not exist"
		usage
		exit 1
	fi

	if [[ ! -d $PATH_TO_ARM_TOOLCHAIN ]] ; then
		echo "ERROR: \"$PATH_TO_ARM_TOOLCHAIN\" does not exist"
		echo "Download the SDK:"
		echo "wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
		echo "tar xvf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
		usage
		exit 1
	fi
}

make_vscode()
{
	case $BOARD_DIR in
	dart_mx8mq)
		FREE_RTOS_DEVICE_DIR="MIMX8MQ6"
		SOC_INCLUDE_PATH="${BSP_BASE_DIR}/devices/${FREE_RTOS_DEVICE_DIR}"
		CM_DEVICE_ID="MIMX8MQ6_M4"
		PATH_TO_JLINKSCRIPT=iMX8M/NXP_iMX8M_Connect_CortexM4.JLinkScript
		SVD_FILE_NAME=MIMX8MQ6_cm4
		CORTEX_M_CPU=cortex-m4
		;;
	esac

	# Get EXECUTABLE_NAME
	readonly EXECUTABLE_NAME_ELF="$(cat ${PATH_TO_EXAMPLE_SRC}/armgcc/CMakeLists.txt | grep -oP '(?<=MCUX_SDK_PROJECT_NAME ).+?(?=\))')"
	readonly EXECUTABLE_NAME_BIN="$(cat ${PATH_TO_EXAMPLE_SRC}/armgcc/CMakeLists.txt | grep "{EXECUTABLE_OUTPUT_PATH}" | awk '{print $3}' | grep -oP '(?<=OUTPUT_PATH}/).+?(?=\))')"

	# build target
	if [[ $RAM_TARGET == "tcm" ]] ; then
		BUILD_TARGET="debug"
	else
		BUILD_TARGET="ddr_debug"
	fi

	# get executable output path
	#if [[ -f $PATH_TO_EXAMPLE_SRC/CMakeLists.txt ]] ; then
	#else
	#	echo "ERROR: CMakeLists.txt not found"
	#	exit 1
	#fi

	# cp vscode templates to example source folder
	if [[ -d $PATH_TO_EXAMPLE_SRC/.vscode ]] ; then
		rm -r $PATH_TO_EXAMPLE_SRC/.vscode
	fi
	mkdir $PATH_TO_EXAMPLE_SRC/.vscode
	cp -r var-vscode-template/* $PATH_TO_EXAMPLE_SRC/.vscode

	# cp svd file
	cp $SOC_INCLUDE_PATH/$SVD_FILE_NAME.xml $PATH_TO_EXAMPLE_SRC/.vscode/$SVD_FILE_NAME.svd

	# adjust settings.json
	sed -i "s|t_path_to_arm_gcc_dir|$PATH_TO_ARM_TOOLCHAIN|g" "$PATH_TO_EXAMPLE_SRC/.vscode/settings.json"
	sed -i "s|t_path_to_gdb_server_dir|$GDBSERVER_DIR|g" "$PATH_TO_EXAMPLE_SRC/.vscode/settings.json"
	sed -i "s|t_path_to_soc_include|$SOC_INCLUDE_PATH|g" "$PATH_TO_EXAMPLE_SRC/.vscode/settings.json"
	sed -i "s|t_build_target|$BUILD_TARGET|g" "$PATH_TO_EXAMPLE_SRC/.vscode/settings.json"

	# adjust launch.json
	sed -i "s|t_path_to_arm_toolchain|$PATH_TO_ARM_TOOLCHAIN/bin|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"
	sed -i "s|t_path_to_JLinkScript|$PATH_TO_JLINKSCRIPT|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"
	sed -i "s|t_path_tosvd_file|\${workspaceRoot}/.vscode/$SVD_FILE_NAME.svd|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"
	sed -i "s|t_path_to_executable|armgcc/\${config:VARISCITE.BUILD_TARGET}/$EXECUTABLE_NAME_ELF|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"
	sed -i "s|t_soc-cm|$CM_DEVICE_ID|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"
	sed -i "s|t_cortex-m-cpu|$CORTEX_M_CPU|g" "$PATH_TO_EXAMPLE_SRC/.vscode/launch.json"

	#raccomandations
	if [ $CORTEX_M_CPU == "cortex-m4" ] && [ $RAM_TARGET == "ddr" ]; then
		echo "NOTE! to debug applications mapped in DDR, is mandatory to disable cache (see SystemInit(void) function in....)"
	fi
}

while getopts :b:d:e:t:r: OPTION;
do
	case $OPTION in
	b)
		BOARD_DIR=$OPTARG
		;;
	d)
		GDBSERVER_DIR=$OPTARG
		;;
	e)
		PATH_TO_EXAMPLE_SRC=$OPTARG
		;;
	t)
		RAM_TARGET=$OPTARG
		;;
	*)
		usage
		exit 1
		;;
	esac
done

check_params
make_vscode

exit 0

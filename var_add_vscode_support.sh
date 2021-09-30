#!/bin/bash

# -e  Exit immediately if a command exits with a non-zero status.
set -e

SCRIPT_NAME=${0##*/}
BSP_BASE_DIR=$PWD
PATH_TO_ARM_TOOLCHAIN="${BSP_BASE_DIR}/../gcc-arm-none-eabi-9-2020-q2-update"

usage()
{
	echo
	echo "This script generates a .vscode folder to add Visual Studio Code support to freertos-variscite demos"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <dart_mx8mq>				board folder (DART-MX8M)."
	echo " -d <GDBServer folder>"
	echo " -e <options>"
	echo "    path/to/example/folder (armgcc folder parent, where will be generated .vscode folder)"
	echo "    all                    (to generate .vscode folder for all demos)"
	echo " -t <tcm/ddr>				ram target"
	echo
	echo "Examples of use:"
	echo "  generate vscode support to hello_world for DART-MX8M: ./${SCRIPT_NAME} -b dart_mx8mq -d /opt/SEGGER/JLink_Linux_V754c_x86_64 -e boards/dart_mx8mq/demo_apps/hello_world -t ddr"
	echo
}

check_params()
{
	if [[ ! -d boards/$BOARD_DIR ]] ; then
		echo "ERROR1: \"boards/$BOARD_DIR\" does not exist"
		usage
		exit 1
	fi

	if [[ ! -d $GDBSERVER_DIR ]] ; then
		echo "ERROR2: \"$GDBSERVER_DIR\" does not exist"
		echo "Download and Install J-Link Software: https://www.segger.com/downloads/jlink/"
		echo "e.g. sudo dpkg -i ~/Downloads/JLink_Linux_V754d_x86_64.deb"
		usage
		exit 1
	fi

	if [[ $PATH_TO_DEMO_SRC != "all" && ! -d $PATH_TO_DEMO_SRC ]] ; then
		echo "ERROR3: \"$PATH_TO_DEMO_SRC\" does not exist"
		usage
		exit 1
	fi

	if [[ $RAM_TARGET != "tcm" && $RAM_TARGET != "ddr" ]]; then
		echo "ERROR4: \"$RAM_TARGET\" does not exist"
		usage
		exit 1
	fi

	if [[ ! -d $PATH_TO_ARM_TOOLCHAIN ]] ; then
		echo "ERROR5: \"$PATH_TO_ARM_TOOLCHAIN\" does not exist"
		echo "Download the SDK:"
		echo "wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
		echo "tar xvf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
		usage
		exit 1
	fi
}

make_demo_vscode()
{
	DEMO_SRC=$1
	echo "generating .vscode for ${DEMO_SRC}"

	# Get EXECUTABLE_NAME
	EXECUTABLE_NAME_ELF="$(cat ${DEMO_SRC}/armgcc/CMakeLists.txt | grep -oP '(?<=MCUX_SDK_PROJECT_NAME ).+?(?=\))')"
	EXECUTABLE_NAME_BIN="$(cat ${DEMO_SRC}/armgcc/CMakeLists.txt | grep "{EXECUTABLE_OUTPUT_PATH}" | awk '{print $3}' | grep -oP '(?<=OUTPUT_PATH}/).+?(?=\))')"

	# build target
	if [[ $RAM_TARGET == "tcm" ]] ; then
		BUILD_TARGET="debug"
	else
		BUILD_TARGET="ddr_debug"
	fi

	# cp vscode templates to example source folder
	if [[ -d $DEMO_SRC/.vscode ]] ; then
		rm -r $DEMO_SRC/.vscode
	fi
	mkdir $DEMO_SRC/.vscode
	cp -r var-vscode-template/* $DEMO_SRC/.vscode

	# cp svd file
	cp $SOC_INCLUDE_PATH/$SVD_FILE_NAME.xml $DEMO_SRC/.vscode/$SVD_FILE_NAME.svd

	# adjust settings.json
	sed -i "s|t_path_to_arm_gcc_dir|$PATH_TO_ARM_TOOLCHAIN|g" "$DEMO_SRC/.vscode/settings.json"
	sed -i "s|t_path_to_gdb_server_dir|$GDBSERVER_DIR|g" "$DEMO_SRC/.vscode/settings.json"
	sed -i "s|t_path_to_soc_include|$SOC_INCLUDE_PATH|g" "$DEMO_SRC/.vscode/settings.json"
	sed -i "s|t_build_target|$BUILD_TARGET|g" "$DEMO_SRC/.vscode/settings.json"

	# adjust launch.json
	sed -i "s|t_path_to_arm_toolchain|$PATH_TO_ARM_TOOLCHAIN/bin|g" "$DEMO_SRC/.vscode/launch.json"
	sed -i "s|t_path_to_JLinkScript|$PATH_TO_JLINKSCRIPT|g" "$DEMO_SRC/.vscode/launch.json"
	sed -i "s|t_path_tosvd_file|\${workspaceRoot}/.vscode/$SVD_FILE_NAME.svd|g" "$DEMO_SRC/.vscode/launch.json"
	sed -i "s|t_path_to_executable|armgcc/\${config:VARISCITE.BUILD_TARGET}/$EXECUTABLE_NAME_ELF|g" "$DEMO_SRC/.vscode/launch.json"
	sed -i "s|t_soc-cm|$CM_DEVICE_ID|g" "$DEMO_SRC/.vscode/launch.json"
	sed -i "s|t_cortex-m-cpu|$CORTEX_M_CPU|g" "$DEMO_SRC/.vscode/launch.json"
}

make_vscode()
{
	case $BOARD_DIR in
	dart_mx8mq)
		readonly FREE_RTOS_DEVICE_DIR="MIMX8MQ6"
		readonly SOC_INCLUDE_PATH="${BSP_BASE_DIR}/devices/${FREE_RTOS_DEVICE_DIR}"
		readonly CM_DEVICE_ID="MIMX8MQ6_M4"
		readonly PATH_TO_JLINKSCRIPT=iMX8M/NXP_iMX8M_Connect_CortexM4.JLinkScript
		readonly SVD_FILE_NAME=MIMX8MQ6_cm4
		readonly CORTEX_M_CPU=cortex-m4
		;;
	esac

	if [[ $PATH_TO_DEMO_SRC == "all" ]] ; then
		for i in $(find $BSP_BASE_DIR/boards/$BOARD_DIR -name armgcc)
		do
			cd $i;
			cd ..
			path_to_demo_src=$PWD
			cd $BSP_BASE_DIR
			make_demo_vscode "$path_to_demo_src"
		done
	else
		make_demo_vscode "$PATH_TO_DEMO_SRC"
	fi

	#raccomandations
	if [ $CORTEX_M_CPU == "cortex-m4" ] && [ $RAM_TARGET == "ddr" ]; then
		echo "NOTE! to debug applications mapped in DDR, is mandatory to disable cache (see SystemInit(void) function in....)"
	fi
}

while getopts :b:d:e:t: OPTION;
do
	case $OPTION in
	b)
		readonly BOARD_DIR=$OPTARG
		;;
	d)
		readonly GDBSERVER_DIR=$OPTARG
		;;
	e)
		readonly PATH_TO_DEMO_SRC=$OPTARG
		;;
	t)
		readonly RAM_TARGET=$OPTARG
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

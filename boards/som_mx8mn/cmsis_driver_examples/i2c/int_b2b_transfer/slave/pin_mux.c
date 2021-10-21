/*
 * Copyright 2019-2021 NXP
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */


/***********************************************************************************************************************
 * This file was generated by the MCUXpresso Config Tools. Any manual edits made to this file
 * will be overwritten if the respective MCUXpresso Config Tools is used to update this file.
 **********************************************************************************************************************/

/*
 * TEXT BELOW IS USED AS SETTING FOR TOOLS *************************************
!!GlobalInfo
product: Pins v9.0
processor: MIMX8MN6xxxJZ
package_id: MIMX8MN6DVTJZ
mcu_data: ksdk2_0
processor_version: 9.0.0
 * BE CAREFUL MODIFYING THIS COMMENT - IT IS YAML SETTINGS FOR TOOLS ***********
 */

#include "fsl_common.h"
#include "fsl_iomuxc.h"
#include "pin_mux.h"

/* FUNCTION ************************************************************************************************************
 *
 * Function Name : BOARD_InitBootPins
 * Description   : Calls initialization functions.
 *
 * END ****************************************************************************************************************/
void BOARD_InitBootPins(void)
{
    BOARD_InitPins();
}

/*
 * TEXT BELOW IS USED AS SETTING FOR TOOLS *************************************
BOARD_InitPins:
- options: {callFromInitBoot: 'true', coreID: m7}
- pin_list:
  - {pin_num: E18, peripheral: UART3, signal: uart_rx, pin_signal: UART3_RXD, PE: Disabled, FSEL: FAST0, DSE: X6_0}
  - {pin_num: D18, peripheral: UART3, signal: uart_tx, pin_signal: UART3_TXD, PE: Disabled, FSEL: FAST0, DSE: X6_0}
 * BE CAREFUL MODIFYING THIS COMMENT - IT IS YAML SETTINGS FOR TOOLS ***********
 */

/* FUNCTION ************************************************************************************************************
 *
 * Function Name : BOARD_InitPins
 * Description   : Configures pin routing and optionally pin electrical features.
 *
 * END ****************************************************************************************************************/
void BOARD_InitPins(void) {                                /*!< Function assigned for the core: Cortex-M7F[m7] */
    IOMUXC_SetPinMux(IOMUXC_UART3_RXD_UART3_RX, 0U);
    IOMUXC_SetPinConfig(IOMUXC_UART3_RXD_UART3_RX, 
                        IOMUXC_SW_PAD_CTL_PAD_DSE(6U) |
                        IOMUXC_SW_PAD_CTL_PAD_FSEL(2U));
    IOMUXC_SetPinMux(IOMUXC_UART3_TXD_UART3_TX, 0U);
    IOMUXC_SetPinConfig(IOMUXC_UART3_TXD_UART3_TX, 
                        IOMUXC_SW_PAD_CTL_PAD_DSE(6U) |
                        IOMUXC_SW_PAD_CTL_PAD_FSEL(2U));
}


/*
 * TEXT BELOW IS USED AS SETTING FOR TOOLS *************************************
I2C4_DeinitPins:
- options: {callFromInitBoot: 'false', coreID: m7}
- pin_list:
  - {pin_num: D13, peripheral: GPIO5, signal: 'gpio_io, 20', pin_signal: I2C4_SCL}
  - {pin_num: E13, peripheral: GPIO5, signal: 'gpio_io, 21', pin_signal: I2C4_SDA}
 * BE CAREFUL MODIFYING THIS COMMENT - IT IS YAML SETTINGS FOR TOOLS ***********
 */

/* FUNCTION ************************************************************************************************************
 *
 * Function Name : I2C4_DeinitPins
 * Description   : Configures pin routing and optionally pin electrical features.
 *
 * END ****************************************************************************************************************/
void I2C4_DeinitPins(void) {                               /*!< Function assigned for the core: Cortex-M7F[m7] */
    IOMUXC_SetPinMux(IOMUXC_I2C4_SCL_GPIO5_IO20, 0U);
    IOMUXC_SetPinMux(IOMUXC_I2C4_SDA_GPIO5_IO21, 0U);
}


/*
 * TEXT BELOW IS USED AS SETTING FOR TOOLS *************************************
I2C4_InitPins:
- options: {callFromInitBoot: 'false', coreID: m7}
- pin_list:
  - {pin_num: D13, peripheral: I2C4, signal: i2c_scl, pin_signal: I2C4_SCL, PE: Disabled, SION: ENABLED, HYS: Enabled, FSEL: FAST0, DSE: X6_0}
  - {pin_num: E13, peripheral: I2C4, signal: i2c_sda, pin_signal: I2C4_SDA, PE: Disabled, SION: ENABLED, HYS: Enabled, FSEL: FAST0, DSE: X6_0}
 * BE CAREFUL MODIFYING THIS COMMENT - IT IS YAML SETTINGS FOR TOOLS ***********
 */

/* FUNCTION ************************************************************************************************************
 *
 * Function Name : I2C4_InitPins
 * Description   : Configures pin routing and optionally pin electrical features.
 *
 * END ****************************************************************************************************************/
void I2C4_InitPins(void) {                                 /*!< Function assigned for the core: Cortex-M7F[m7] */
    IOMUXC_SetPinMux(IOMUXC_I2C4_SCL_I2C4_SCL, 1U);
    IOMUXC_SetPinConfig(IOMUXC_I2C4_SCL_I2C4_SCL, 
                        IOMUXC_SW_PAD_CTL_PAD_DSE(6U) |
                        IOMUXC_SW_PAD_CTL_PAD_FSEL(2U) |
                        IOMUXC_SW_PAD_CTL_PAD_HYS_MASK);
    IOMUXC_SetPinMux(IOMUXC_I2C4_SDA_I2C4_SDA, 1U);
    IOMUXC_SetPinConfig(IOMUXC_I2C4_SDA_I2C4_SDA, 
                        IOMUXC_SW_PAD_CTL_PAD_DSE(6U) |
                        IOMUXC_SW_PAD_CTL_PAD_FSEL(2U) |
                        IOMUXC_SW_PAD_CTL_PAD_HYS_MASK);
}

/***********************************************************************************************************************
 * EOF
 **********************************************************************************************************************/

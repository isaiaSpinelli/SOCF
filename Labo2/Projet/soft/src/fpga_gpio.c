/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_gpio.c
 * Author               : Spinelli Isaia
 * Date                 : 21.02.2020
 *
 * Context              : SOCF tutorial lab
 *
 *****************************************************************************************
 * Brief: light HPS user LED up when HPS user button pressed, for DE1-SoC board
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 
 *
*****************************************************************************************/

typedef volatile unsigned int vuint;

#define FPGA_BASE_ADDR_IO 		0xFF200000

/* adresse des leds */
#define FPAG_LED        	*(vuint *)(HPS_GPIO1_BASE_ADDR + 0x0)
/* adresse des switches */
#define FPAG_SWITCH 		*(vuint *)(HPS_GPIO1_BASE_ADDR + 0x20)


int main(void){

    
    while(1){

		FPAG_LED = FPAG_SWITCH;
	}

}

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

#define HPS_GPIO1_BASE_ADDR 	0xFF709000
/* Ecriture sur les registres */
#define GPIO1_SWPORTA_DR        *(vuint *)(HPS_GPIO1_BASE_ADDR + 0x0)
/* direction par défaut = 0 (0=IN/1=OUT) */
#define GPIO1_SWPORTA_DRR 		*(vuint *)(HPS_GPIO1_BASE_ADDR + 0x4)
/* Lecture des GPIO */
#define GPIO1_EXT_PORTA			*(vuint *)(HPS_GPIO1_BASE_ADDR + 0x50)

#define HPS_GPIO1_KEY		25
#define HPS_GPIO1_LED		24

#define KEY					(1 << HPS_GPIO1_KEY)
#define LED					(1 << HPS_GPIO1_LED)

int main(void){
	/* Configure la led en sortie */
	GPIO1_SWPORTA_DRR |= LED ;
    
    while(1){
		/* Si le bouton est pressé */
		if(GPIO1_EXT_PORTA & KEY ){
			/* Allume la led */
			GPIO1_SWPORTA_DR &= ~LED; 
		} else {
			/* Eteind la led */
			GPIO1_SWPORTA_DR |= LED;
		}
		
	}

}

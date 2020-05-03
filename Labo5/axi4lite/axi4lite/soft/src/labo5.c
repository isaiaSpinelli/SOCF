/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : labo5.c
 * Author               : Spinelli Isaia
 * Date                 : 01.05.2020
 *
 * Context              : SOCF tutorial lab
 *
 *****************************************************************************************
 * Brief: Programme for labo 5 of SOCF, for DE1-SoC board
 *
 * Remarque : Tous les 3 interruptions de KEY0 et KEY1, change le masque de key 2 et 3
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.1	  01.05.20	  Isaia Spinelli : Modif pour la partie 1
 * 1.1	  03.05.20	  Isaia Spinelli : Ajout de la partie 2
*****************************************************************************************/

#define KEY0 0x01
#define KEY1 0x02
#define KEY2 0x04
#define KEY3 0x08

typedef volatile unsigned char vcint;
typedef volatile unsigned short vsint;
typedef volatile unsigned int vuint;


#define FPGA_BASE_ADDR_IO 		0xFF200000
#define AXI_LIGHT_BASE_ADDR 	FPGA_BASE_ADDR_IO


#define AXI_REG_CONST_CHAR		*(vcint *)(AXI_LIGHT_BASE_ADDR + 0x0)
#define AXI_REG_CONST_SHORT		*(vsint *)(AXI_LIGHT_BASE_ADDR + 0x0)
#define AXI_REG_CONST			*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x0)

#define AXI_REG_TEST			*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x4)

#define AXI_LEDS				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x100)

#define AXI_KEYS				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x200)
// Lecture de la source d'int. + acquitement
#define AXI_INT_SRC				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x204)
// 1 = interruption masquée
#define AXI_INT_MASK			*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x208)

#define AXI_SWITCHES			*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x300)

#define AXI_HEX0				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x400)
#define AXI_HEX1				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x410)
#define AXI_HEX2				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x420)
#define AXI_HEX3				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x430)
#define AXI_HEX4				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x440)
#define AXI_HEX5				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x450)

int irqKey2 = 0;
int irqKey3 = 0;

// Modif : lecuture du masque à 0 !!


void disable_A9_interrupts (void);
void set_A9_IRQ_stack (void);
void config_GIC (void);
void config_KEYs (void);
void enable_A9_interrupts (void);

int main(void){
	
	// tableau de converssion		  0 	1	  2		3	 4		5	 6	   7      8     9    a      b    c      d     e    f
	char tab_dec_to_hex_7seg[16] = {0x40, 0xF9, 0x24, 0x30, 0x19, 0x12, 0x02, 0xF8, 0x00, 0x10, 0x08, 0x03, 0x27, 0x21, 0x06, 0x0e };
	int led_tmp,Seg_tmp;
	
	
	/*---------- INTI ----------*/
	AXI_HEX5 = 0x40;
	AXI_HEX4 = 0xF9;
	AXI_HEX3 = 0x24;
	AXI_HEX2 = 0x30;
	AXI_HEX1 = 0x19;
	AXI_HEX0 = 0x02;

	AXI_LEDS = AXI_SWITCHES;

	unsigned int cst = AXI_REG_CONST;
	
	// Masque le bouton key3
	AXI_INT_MASK = KEY3;
	
	disable_A9_interrupts();   // disable interrupts in the A9 processor
	set_A9_IRQ_stack();        // initialize the stack pointer for IRQ mode
	config_GIC();              // configure the general interrupt controller
	config_KEYs();             // configure KEYs to generate interrupts
	enable_A9_interrupts();    // enable interrupts in the A9 processor

	
	
    
    while(1){
		/* Appuie sur KEY 0*/
		if ((AXI_KEYS & KEY0) == 0) {
			// l'états des switches est copiés sur les LEDs.
			AXI_LEDS = AXI_SWITCHES;
			// Les afficheurs HEX5 à HEX0 affichent en hexadécimal les bits 23 à 0 de la constante définie dans l’IP.
			AXI_HEX0 = tab_dec_to_hex_7seg[cst & 0xF];
			AXI_HEX1 = tab_dec_to_hex_7seg[(cst>>4)  & 0xF];
			AXI_HEX2 = tab_dec_to_hex_7seg[(cst>>8)  & 0xF];
			AXI_HEX3 = tab_dec_to_hex_7seg[(cst>>12) & 0xF];
			AXI_HEX4 = tab_dec_to_hex_7seg[(cst>>16) & 0xF];
			AXI_HEX5 = tab_dec_to_hex_7seg[(cst>>20) & 0xF];
			

		/* Appuie sur KEY 1 */
		} else if ((AXI_KEYS & KEY1) == 0) {
			//  l'états inverses des switches est copiés sur les LEDs.
			AXI_LEDS = ~AXI_SWITCHES;
			
			// Les afficheurs HEX5 à HEX0 affichent en hexadécimal l’inverse des bits 23 à 0 de la
			// constante définie dans l’IP.
			AXI_HEX0 = ~tab_dec_to_hex_7seg[cst & 0xF];
			AXI_HEX1 = ~tab_dec_to_hex_7seg[(cst>>4)  & 0xF];
			AXI_HEX2 = ~tab_dec_to_hex_7seg[(cst>>8)  & 0xF];
			AXI_HEX3 = ~tab_dec_to_hex_7seg[(cst>>12) & 0xF];
			AXI_HEX4 = ~tab_dec_to_hex_7seg[(cst>>16) & 0xF];
			AXI_HEX5 = ~tab_dec_to_hex_7seg[(cst>>20) & 0xF];

		// Si le bouton 2 est pressé (via une interruption)
		} else if (irqKey2) {
			irqKey2 = 0;

			/*  l’affichage des LEDs et des afficheurs 7 segments subit unerotation à droite */
			led_tmp = AXI_LEDS & 0x1;
			AXI_LEDS = ((AXI_LEDS & 0x3ff) >> 1) | (led_tmp << 9);
			
			Seg_tmp = AXI_HEX0;
			AXI_HEX0 = AXI_HEX1;
			AXI_HEX1 = AXI_HEX2;
			AXI_HEX2 = AXI_HEX3;
			AXI_HEX3 = AXI_HEX4;
			AXI_HEX4 = AXI_HEX5;
			AXI_HEX5 = Seg_tmp;
			
			
		// Si le bouton 3 est pressé (via une interruption)
		} else if (irqKey3) {
			irqKey3 = 0;

			/* l’affichage des LEDs et des afficheurs 7 segments subit une rotation à gauche */
			led_tmp = AXI_LEDS & 0x200;
			AXI_LEDS = (AXI_LEDS << 1) | (led_tmp >> 9);
			
			Seg_tmp = AXI_HEX5;
			AXI_HEX5 = AXI_HEX4;
			AXI_HEX4 = AXI_HEX3;
			AXI_HEX3 = AXI_HEX2;
			AXI_HEX2 = AXI_HEX1;
			AXI_HEX1 = AXI_HEX0;
			AXI_HEX0 = Seg_tmp;

		}
	}
}

/* Routine d'interruption */
/* Remarque : Tous les 3 interruptions de KEY0 et KEY1, change le masque de key 2 et 3 */
void pushbutton_ISR(void){
	static int cpt_int = 0;
	/* Lecture et acquitement des interruptions */
	int src_irq = AXI_INT_SRC;
	
	// Key2 pressé
	if (src_irq & KEY2) {
		irqKey2 = 1;
	} 
	
	// Key3 pressé
	if (src_irq & KEY3) {
		irqKey3 = 1;
	} 
	
	
	// Tous les 3 interruptions de KEY0 et KEY1, change le masque de key 2 et 3
	if (src_irq & KEY0 || src_irq & KEY1) {
		cpt_int++;
		
		if (cpt_int % 3 == 0)
			AXI_INT_MASK = AXI_INT_MASK ^ (KEY3 | KEY2);
	}
	
}

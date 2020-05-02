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
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.1	  01.05.20	  Isaia Spinelli
 *
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

#define AXI_SWITCHES			*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x300)

#define AXI_HEX0				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x400)
#define AXI_HEX1				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x410)
#define AXI_HEX2				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x420)
#define AXI_HEX3				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x430)
#define AXI_HEX4				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x440)
#define AXI_HEX5				*(vuint *)(AXI_LIGHT_BASE_ADDR + 0x450)

/* adresse des leds */
#define FPAG_LED        	*(vuint *)(FPGA_BASE_ADDR_IO + 0x0)
/* adresse des switches */
#define FPAG_SWITCH 		*(vuint *)(FPGA_BASE_ADDR_IO + 0x40)


/* adresse des keys */
#define FPAG_KEY        	*(vuint *)(FPGA_BASE_ADDR_IO + 0x50)
/* adresse des 7seg */
#define FPAG_7SEG_0			*(vuint *)(FPGA_BASE_ADDR_IO + 0x20)
#define FPAG_7SEG_1			*(vuint *)(FPGA_BASE_ADDR_IO + 0x10)
#define FPAG_7SEG_2			*(vuint *)(FPGA_BASE_ADDR_IO + 0x60)
#define FPAG_7SEG_3			*(vuint *)(FPGA_BASE_ADDR_IO + 0x70)
#define FPAG_7SEG_4			*(vuint *)(FPGA_BASE_ADDR_IO + 0x30)
#define FPAG_7SEG_5			*(vuint *)(FPGA_BASE_ADDR_IO + 0x80)


void disable_A9_interrupts (void);
void set_A9_IRQ_stack (void);
void config_GIC (void);
void config_KEYs (void);
void enable_A9_interrupts (void);

int main(void){
	
	//								  0 	1	  2		3	 4		5	 6	   7      8     9    a      b    c      d     e    f
	char tab_dec_to_hex_7seg[16] = {0x40, 0xF9, 0x24, 0x30, 0x19, 0x12, 0x02, 0xF8, 0x00, 0x10, 0x08, 0x03, 0x27, 0x21, 0x06, 0x0e };
	
	disable_A9_interrupts();   // disable interrupts in the A9 processor
	//set_A9_IRQ_stack();        // initialize the stack pointer for IRQ mode
	//config_GIC();              // configure the general interrupt controller
	//config_KEYs();             // configure KEYs to generate interrupts
	//enable_A9_interrupts();    // enable interrupts in the A9 processor

	AXI_HEX5 = 0x40;
	AXI_HEX4 = 0xF9;
	AXI_HEX3 = 0x24;
	AXI_HEX2 = 0x30;
	AXI_HEX1 = 0x19;
	AXI_HEX0 = 0x12;

	AXI_LEDS = AXI_SWITCHES;

	unsigned int cst = AXI_REG_CONST;

	unsigned int cst1 = AXI_REG_CONST_CHAR;

	unsigned int cst2 = AXI_REG_CONST_SHORT;

	unsigned int regTest = AXI_REG_TEST;

	AXI_REG_TEST = cst;

	regTest = AXI_REG_TEST;
	
    
    while(1){
		/* Appuie sur KEY 0*/
		//if ((FPAG_KEY & KEY0) == 0) {
			//FPAG_LED = FPAG_SWITCH;
			/* Les afficheurs HEX2 et HEX3 affichent 1 lorsque la LED8 et respectivement la LED9
				sont allumées, 0 sinon. */
			//FPAG_7SEG_2 = (FPAG_LED & 0x100) == 0x100 ? 0xF9 : 0x40 ;
			//FPAG_7SEG_3 = (FPAG_LED & 0x200) == 0x200 ? 0xF9 : 0x40 ;
			
			/* Les afficheurs HEX0 et HEX1 traduisent en hexadécimal les valeurs représentées
				par les LED3 à LED0 et LED7 à LED4 respectivement. */
			//FPAG_7SEG_0 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF)] ;
			//FPAG_7SEG_1 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF0) >> 4];

		/* Appuie sur KEY 1 */
		//} else if ((FPAG_KEY & KEY1) == 0) {
			//FPAG_LED = ~FPAG_SWITCH;
			
			/* Les afficheurs HEX2 et HEX3 affichent 1 lorsque la LED8 et respectivement la LED9
				sont allumées, 0 sinon. */
			//FPAG_7SEG_2 = (FPAG_LED & 0x100) == 0x100 ? 0xF9 : 0x40 ;
			//FPAG_7SEG_3 = (FPAG_LED & 0x200) == 0x200 ? 0xF9 : 0x40 ;
			
			/* Les afficheurs HEX0 et HEX1 traduisent en hexadécimal les valeurs représentées
				par les LED3 à LED0 et LED7 à LED4 respectivement. */
			//FPAG_7SEG_0 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF)] ;
			//FPAG_7SEG_1 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF0) >> 4];

		//} 
		
	}

}

void pushbutton_ISR(void){
	
	int Seg_tmp ;
	int led_tmp;
	int press;
	
	volatile int*KEY_ptr = (int*) &FPAG_KEY;
	
	press =*(KEY_ptr + 3);     // read the pushbutton interrupt register
	*(KEY_ptr + 3) = press;     // Clear the interrupt
	
	/* Appuie sur KEY 2 */
	if (press & 0x4) {
		/*  l’affichage des LEDs et des afficheurs 7 segments subit unerotation à droite */
		led_tmp = FPAG_LED & 0x1;
		FPAG_LED = (FPAG_LED >> 1) | (led_tmp << 9);
		
		Seg_tmp = FPAG_7SEG_0;
		FPAG_7SEG_0 = FPAG_7SEG_1;
		FPAG_7SEG_1 = FPAG_7SEG_2;
		FPAG_7SEG_2 = FPAG_7SEG_3;
		FPAG_7SEG_3 = FPAG_7SEG_4;
		FPAG_7SEG_4 = FPAG_7SEG_5;
		FPAG_7SEG_5 = Seg_tmp;
	
	/* Appuie sur KEY 3 */	
	} else if (press & 0x8)  {
		/* l’affichage des LEDs et des afficheurs 7 segmentssubit une rotation à gauche */
		led_tmp = FPAG_LED & 0x200;
		FPAG_LED = (FPAG_LED << 1) | (led_tmp >> 9);
		
		Seg_tmp = FPAG_7SEG_5;
		FPAG_7SEG_5 = FPAG_7SEG_4;
		FPAG_7SEG_4 = FPAG_7SEG_3;
		FPAG_7SEG_3 = FPAG_7SEG_2;
		FPAG_7SEG_2 = FPAG_7SEG_1;
		FPAG_7SEG_1 = FPAG_7SEG_0;
		FPAG_7SEG_0 = Seg_tmp;
	}
	
	return;
	
}

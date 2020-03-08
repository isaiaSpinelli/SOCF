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
 * 0.1	  06.03.20	  Isaia Spinelli
 *
*****************************************************************************************/

#define KEY0 0x01
#define KEY1 0x02
#define KEY2 0x04
#define KEY3 0x08

typedef volatile unsigned int vuint;

#define FPGA_BASE_ADDR_IO 		0xFF200000

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
	
	int key2Presses, key3Presses = 0;
	//								  0 	1	  2		3	 4		5	 6	   7      8     9    a      b    c      d     e    f
	char tab_dec_to_hex_7seg[16] = {0x40, 0xF9, 0x24, 0x30, 0x19, 0x12, 0x02, 0xF8, 0x00, 0x10, 0x08, 0x03, 0x27, 0x21, 0x06, 0x0e };
	
	disable_A9_interrupts ();   // disable interrupts in the A9 processor
	FPAG_7SEG_0 = 0x40 ;
	set_A9_IRQ_stack ();        // initialize the stack pointer for IRQ mode
	FPAG_7SEG_0 = 0xF9 ;
	config_GIC ();              // configure the general interrupt controller
	FPAG_7SEG_0 = 0x24 ;
	config_KEYs ();             // configure KEYs to generate interrupts
	FPAG_7SEG_0 = 0x0e ;
	enable_A9_interrupts ();    // enable interrupts in the A9 processor
	FPAG_7SEG_0 = 0x19 ;
	
    
    while(1){
		/* Appuie sur KEY 0*/
		if ((FPAG_KEY & KEY0) == 0) {
			FPAG_LED = FPAG_SWITCH;
			/* Les afficheurs HEX2 et HEX3 affichent 1 lorsque la LED8 et respectivement la LED9
				sont allumées, 0 sinon. */
			FPAG_7SEG_2 = (FPAG_LED & 0x100) == 0x100 ? 0xF9 : 0x40 ;
			FPAG_7SEG_3 = (FPAG_LED & 0x200) == 0x200 ? 0xF9 : 0x40 ;
			
			/* Les afficheurs HEX0 et HEX1 traduisent en hexadécimal les valeurs représentées
				par les LED3 à LED0 et LED7 à LED4 respectivement. */
			FPAG_7SEG_0 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF)] ;
			FPAG_7SEG_1 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF0) >> 4];

		} else if ((FPAG_KEY & KEY1) == 0) {
			FPAG_LED = ~FPAG_SWITCH;
			
			/* Les afficheurs HEX2 et HEX3 affichent 1 lorsque la LED8 et respectivement la LED9
				sont allumées, 0 sinon. */
			FPAG_7SEG_2 = (FPAG_LED & 0x100) == 0x100 ? 0xF9 : 0x40 ;
			FPAG_7SEG_3 = (FPAG_LED & 0x200) == 0x200 ? 0xF9 : 0x40 ;
			
			/* Les afficheurs HEX0 et HEX1 traduisent en hexadécimal les valeurs représentées
				par les LED3 à LED0 et LED7 à LED4 respectivement. */
			FPAG_7SEG_0 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF)] ;
			FPAG_7SEG_1 = tab_dec_to_hex_7seg[(FPAG_LED & 0xF0) >> 4];

			/* Appuie sur KEY 2 */
		} else if ((FPAG_KEY & KEY2) == 0) {
			
			if (key2Presses == 0) {
				key2Presses = 1;
			
				FPAG_LED = FPAG_LED >> 1;
		
				FPAG_7SEG_0 = FPAG_7SEG_1;
				FPAG_7SEG_1 = FPAG_7SEG_2;
				FPAG_7SEG_2 = FPAG_7SEG_3;
				FPAG_7SEG_3 = FPAG_7SEG_4;
				FPAG_7SEG_4 = FPAG_7SEG_5;
				FPAG_7SEG_5 = 0xFF;
				
			}
			
			
			
			/* Appuie sur KEY 3 */
		} else if ((FPAG_KEY & KEY3) == 0) {
			
			if (key3Presses == 0) {
				key3Presses = 1;
				
				FPAG_LED = FPAG_LED << 1;
				FPAG_7SEG_5 = FPAG_7SEG_4;
				FPAG_7SEG_4 = FPAG_7SEG_3;
				FPAG_7SEG_3 = FPAG_7SEG_2;
				FPAG_7SEG_2 = FPAG_7SEG_1;
				FPAG_7SEG_1 = FPAG_7SEG_0;
				FPAG_7SEG_0 = 0xFF;
			}
			
			
		} else {
			if (key2Presses == 1) {
				key2Presses = 0;
			}
			
			if (key3Presses == 1) {
				key3Presses = 0;
			}
		}
		
	}

}

void pushbutton_ISR(void){
	int press;
	
	volatile int*KEY_ptr = (int*) 0xFF200050;
	
	press =*(KEY_ptr + 3);     // read the pushbutton interrupt register
	*(KEY_ptr + 3) = press;     // Clear the interrupt
	
	//FPAG_7SEG_5 = 0x19;
	FPAG_7SEG_4 = 0x19;
	
	return;
	
}

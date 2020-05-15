/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : exceptions.h
 * Author               : Isaia Spinelli
 * Date                 : 06.05.2020
 *
 * Context              : SOCF class
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 1.1	  06.05.20	  Isaia Spinelli : Refactor
 *
*****************************************************************************************/

void disable_A9_interrupts (void);
void set_A9_IRQ_stack (void);
void config_GIC (void);
void config_KEYs (void);
void enable_A9_interrupts (void);
void config_interrupt (int, int);
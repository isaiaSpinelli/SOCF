Project for the Terasic DE1-Soc board

This project uses a custom component in Qsys, with an AXI4 lite slave interface and connected to the lightweight HPS-to-FPGA bus. An interrupt
can also be generated from the custom component by pressing on one of the pushbuttons KEY2 or KEY3 if interrupt mode is activated in the HPS.


How to run the project:
    - compile Quartus project (located in hard/eda/DE1_SoC.qpf), do not forget to generate Qsys project before
    - open Altera Monitor Program, open the corresponding project located in soft/proj
    - Load the board with the .sof file (when prompted by Altera Monitor Program), compile the source files and load the processor
    - Run


How the example works:
    - Press KEY0 to turn the LEDs on according to the switches positions. Simultaneously, HEX5 to HEX0 display the constant value defined in
      the custom component.
    - Press KEY1 to turn the LEDs on according to the opposite of switches positions. Simultaneously, HEX5 to HEX0 display the opposite of the
      constant value defined in the custom component.
    - Press KEY2 to generate an interrupt to the HPS. The CPU catches this interrupt and rotates the LEDs right. Simultaneously, it also
      rotates the 7 segments displays right (rotates the whole displays, not only one segment).
    - Press KEY3 to generate an interrupt to the HPS. The CPU catches this interrupt and rotates the LEDs left. Simultaneously, it also
      rotates the 7 segments displays left (rotates by one display, not only one segment).



folder structure:
    - doc: documentation
    - hard: files related to hardware, ie VHDL source and simulation files, Quartus and Qsys project
    - publi: publications
    - soft: files related to software, ie linux files and project, Altera Monitor Program source and project files
-----------------------------------------------------------------------------
-- Version initale: 
--  https://github.com/frobino/axi_custom_ip_tb/tree/master/led_controller_1.0/hdl
--
-- Author: Frobino
-- Date :  december 2014
--
--| Modifications |-----------------------------------------------------------
-- Ver   Auteur Date         Description
-- 1.0   EMI    16.03.2018   Adaptation noms signaux
--                           Adaptation generateur d'horloge (ajout sim_end_s)
--                           Ajout table de stimuli pour write et read
--
--
------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.axi4lite_slave;

entity axi4lite_slave_tb is
generic
(
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 8
);

end axi4lite_slave_tb;

architecture Behavioral of axi4lite_slave_tb is

    signal S_AXI_ACLK          : std_logic;
    signal S_AXI_ARESET        : std_logic;
    signal S_AXI_AWADDR        : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_AWVALID       : std_logic;
    signal S_AXI_WDATA         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_WLAST         : std_logic;
    signal S_AXI_WSTRB         : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    signal S_AXI_WVALID        : std_logic;
    signal S_AXI_BREADY        : std_logic;
    signal S_AXI_ARADDR        : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_ARVALID       : std_logic;
    signal S_AXI_RREADY        : std_logic;
    signal S_AXI_ARREADY       : std_logic;
    signal S_AXI_RDATA         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_RRESP         : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID        : std_logic;
    signal S_AXI_WREADY        : std_logic;
    signal S_AXI_BRESP         : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID        : std_logic;
    signal S_AXI_AWREADY       : std_logic;
    signal S_AXI_AWPROT        : std_logic_vector(2 downto 0);
    signal S_AXI_ARPROT        : std_logic_vector(2 downto 0);

    signal  tst_reg4_obs       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal  tst_reg5_obs       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal  tst_reg6_obs       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal  tst_reg7_obs       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);


    constant ClockPeriod : TIME := 5 ns;
    constant ClockPeriod2 : TIME := 10 ns;
    signal sim_end_s : boolean := false;
    shared variable ClockCount : integer range 0 to 50_000 := 10;
    signal sendIt : std_logic := '0';
    signal readIt : std_logic := '0';

  --Table pour les stimuli AXI_WRITE Channel  
    type Type_Stimuli_axi_write is
    record
        axi_awaddr_sti : natural;
        axi_wrdata_sti : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        axi_wstrb_sti  : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    end record;
    type Type_Tab_Stimuli_AXI_WRITE is array (natural range <>) of Type_Stimuli_axi_write;

    --Table pour les stimuli AXI_READ Channel  
    type Type_Stimuli_axi_read is
    record
        axi_araddr_sti : natural;
        axi_rdata_ref  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    end record;
    type Type_Tab_Stimuli_AXI_READ is array (natural range <>) of Type_Stimuli_axi_read;

    constant TAB_STI_AXI_WRITE : Type_Tab_Stimuli_AXI_WRITE :=
    --REM: table fixe pour 32 bits de data 
        (
            ( 4, x"00001023", "1111"),   --ecriture adresse 0x04
            ( 8, x"10004321", "1111"),   --ecriture adresse 0x08
            (12, x"2000a5a5", "1111"),   --ecriture adresse 0x0C 
            (16, x"3000ffff", "1111"),   --ecriture adresse 0x10 
            ( 4, x"AA240000", "1111")   --ecriture adresse 0x04
        );
    
    constant TAB_STI_AXI_READ : Type_Tab_Stimuli_AXI_READ :=
    --REM: table fixe pour 32 bits de data 
    --REM: valeur de reference rdata pas utilise!!!!!
        (
            (  0, x"00000000"  ),   --lecture adresse 0x00
            (  4, x"00000000"  ),   --lecture adresse 0x04
            (  8, x"00000000"  ),   --lecture adresse 0x08
            ( 12, x"00000000"  ),   --lecture adresse 0x0C
            ( 16, x"00000000"  )    --lecture adresse 0x10
        );

    
begin

    -- instance "axi_dummy_slv"
    axi_instance: entity work.axi4lite_slave
        generic map (
            AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH)
        port map (
            axi_clk_i       => S_AXI_ACLK,
            axi_reset_i     => S_AXI_ARESET,
            axi_awaddr_i    => S_AXI_AWADDR,
            axi_awprot_i    => S_AXI_AWPROT,
            axi_awvalid_i   => S_AXI_AWVALID,
            axi_awready_o   => S_AXI_AWREADY,
            axi_wdata_i     => S_AXI_WDATA,
            axi_wstrb_i     => S_AXI_WSTRB,
            axi_wvalid_i    => S_AXI_WVALID,
            axi_wready_o    => S_AXI_WREADY,
            axi_bresp_o     => S_AXI_BRESP,
            axi_bvalid_o    => S_AXI_BVALID,
            axi_bready_i    => S_AXI_BREADY,
            axi_araddr_i    => S_AXI_ARADDR,
            axi_arprot_i    => S_AXI_ARPROT,
            axi_arvalid_i   => S_AXI_ARVALID,
            axi_arready_o   => S_AXI_ARREADY,
            axi_rdata_o     => S_AXI_RDATA,
            axi_rresp_o     => S_AXI_RRESP,
            axi_rvalid_o    => S_AXI_RVALID,
            axi_rready_i    => S_AXI_RREADY,

            vect_input_A_i  => x"12345678",
            vect_input_B_i  => x"11223344",
            vect_input_C_i  => x"A5A5A5A5",
            vect_input_D_i  => x"87654321",

            output_reg_A_o  =>  tst_reg4_obs,
            output_reg_B_o  =>  tst_reg5_obs,
            output_reg_C_o  =>  tst_reg6_obs,
            output_reg_D_o  =>  tst_reg7_obs

        );

    -- Generate S_AXI_ACLK signal
    GENERATE_REFCLOCK : process
    begin
 
        while not sim_end_s loop
            S_AXI_ACLK <= '1',
                          '0' after ClockPeriod/2;
            ClockCount:= ClockCount+1;
            wait for ClockPeriod;
        end loop;
        wait;
    end process;

    ----------------------------------------------------------------------------------------------
    -- Simulate master write acces (3 channels)

    -- Process which simulates the master write address channel.
    -- This process is blocked on a "Send Flag" (sendIt).
    send_ad : PROCESS
    BEGIN
        S_AXI_AWVALID<='0';
        loop
           wait until sendIt = '1';
           wait until S_AXI_ACLK= '0';
               S_AXI_AWVALID<='1';
           wait until (S_AXI_AWREADY = '1');  --Client ready to read address
           wait until rising_edge(S_AXI_ACLK);
            --   assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
               S_AXI_AWVALID<='0';
        end loop;
    END PROCESS;

    -- Process which simulates the master write data channel.
    -- This process is blocked on a "Send Flag" (sendIt).
    send_d : PROCESS
    BEGIN
        S_AXI_WVALID<='0';
        loop
            wait until sendIt = '1';
            wait until S_AXI_ACLK= '0';
                S_AXI_WVALID<='1';
            wait until (S_AXI_WREADY = '1');  --Client ready to read data
            wait until rising_edge(S_AXI_ACLK);
            --    assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
                S_AXI_WVALID<='0';
        end loop;
    END PROCESS;

    -- Process which simulates the master write respond channel.
    -- This process is blocked on a "Send Flag" (sendIt).
    send_b : PROCESS
    BEGIN
        S_AXI_BREADY<='0';
        loop
            wait until sendIt = '1';
            wait until (S_AXI_AWREADY = '1');  --Client ready to read addres
            if S_AXI_WREADY = '0' then -- wait for S_AXI_WREADY = '1'
              wait until (S_AXI_WREADY = '1');  --Client ready to read data
            end if;
            S_AXI_BREADY<='1';
            wait until S_AXI_BVALID = '1';  -- Write result valid
                assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
                S_AXI_BREADY<='1';
            wait until S_AXI_BVALID = '0';  -- All finished
                S_AXI_BREADY<='0';
        end loop;
    END PROCESS;

    ----------------------------------------------------------------------------------------------
    -- Simulate a master read acces ( 2 channels)

    -- Process which simulates a master read address
    -- This process is blocked on a "Read Flag" (readIt).
    read_a : PROCESS
    BEGIN
        S_AXI_ARVALID<='0';
         loop
            wait until readIt = '1';
            wait until S_AXI_ACLK= '0';
                S_AXI_ARVALID<='1';
            wait until (S_AXI_ARREADY = '1');  --Client ready to read address
            wait until rising_edge(S_AXI_ACLK);
                S_AXI_ARVALID<='0';
        end loop;
    END PROCESS;

    -- Process which simulates a master read data
    -- This process is blocked on a "Read Flag" (readIt).
    read_d : PROCESS
    BEGIN
        S_AXI_RREADY<='0';
         loop
            wait until readIt = '1';
            wait until S_AXI_ACLK= '0';
                S_AXI_RREADY<='1';
            wait until (S_AXI_RVALID  = '1');  --Client provided data
            wait until rising_edge(S_AXI_ACLK);
                assert S_AXI_RRESP = "00" report "AXI data not written" severity failure;
                S_AXI_RREADY<='0';
        end loop;
    END PROCESS;


    --
    tb : PROCESS
    BEGIN
        S_AXI_ARESET<='1';
        sendIt<='0';
        wait for 2 * ClockPeriod;
        wait until falling_edge(S_AXI_ACLK);
        S_AXI_ARESET<='0';

        S_AXI_ARADDR<=(others => '-');  --etat adresse read durant stimuli write
     
        for I_Tab in TAB_STI_AXI_WRITE'range loop
            report ">>Test avec table d'ecriture sur bus AXI";

            S_AXI_AWADDR<=std_logic_vector(to_unsigned(TAB_STI_AXI_WRITE(I_Tab).axi_awaddr_sti,S_AXI_AWADDR'length)) ;
            S_AXI_WDATA<=TAB_STI_AXI_WRITE(I_Tab).axi_wrdata_sti;
            S_AXI_WSTRB<=TAB_STI_AXI_WRITE(I_Tab).axi_wstrb_sti;
            sendIt<='1';                --Start AXI Write to Slave
            wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
            wait until S_AXI_BVALID = '1';
            wait until S_AXI_BVALID = '0';  --AXI Write finished
            S_AXI_WSTRB<=b"0000";
            
            wait for ClockPeriod;
        end loop;
     
        for I_Tab in TAB_STI_AXI_READ'range loop
            report ">>Test avec table de lecture sur bus AXI";

            S_AXI_ARADDR<=std_logic_vector(to_unsigned(TAB_STI_AXI_READ(I_Tab).axi_araddr_sti,S_AXI_ARADDR'length)) ;
            readIt<='1';                --Start AXI Read from Slave
            wait for 1 ns; readIt<='0'; --Clear "Start Read" Flag
            wait until S_AXI_RVALID = '1';
            wait until S_AXI_RVALID = '0';
            
            wait for ClockPeriod;      
        end loop;
     
        S_AXI_ARADDR<=x"04";
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; readIt<='0'; --Clear "Start Read" Flag
        wait until S_AXI_RVALID = '1';
        wait until S_AXI_RVALID = '0';

        wait for 8 * ClockPeriod;
        sim_end_s <= true;
        wait; -- will wait forever
    END PROCESS tb;

end Behavioral;

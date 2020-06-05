-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Md5Core_tb.vhd
-- Description  : Sitmuli generator for Verilog MD5 IP
-- 
-- Auteur       : Sebastien Masle
-- Date         : 02.06.2020
-- Version      : 0.0
--
-- Utilise      : Labo SOCF, MD5
-- 
--| Modifications |------------------------------------------------------------
-- Version  Date         Auteur     Description
-- 0.0      See header   SMS        Initial version
--
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Md5Core_tb is
end Md5Core_tb;

architecture test_bench of Md5Core_tb is

    -- component declaration
    component Md5Core is
    port( 
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        en_i        : in  std_logic;
        valid_i     : in  std_logic;
        wb_i        : in  std_logic_vector (511 downto 0);
        init_val_i  : in  std_logic_vector (127 downto 0);
        valid_o     : out std_logic;
        footprint_o : out std_logic_vector (127 downto 0)
    );
    end component;
    
    ---------------
    -- Constants --
    ---------------
    
    constant ERROR_PULSE      : time := 4 ns;
    constant CLOCK_PERIOD     : time := 100 ns;
    
    type wb_t is array(natural range<>) of std_logic_vector(511 downto 0);
    
    constant TEST_WB : wb_t := (x"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080",
                                x"00000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008041",
                                x"00000000000000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080414141",
                                x"0000000000000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080646C726F57206F6C6C6548",
                                x"000000000000015800000000000000000000000080676F6420797A616C20656874207265766F2073706D756A20786F66206E776F7262206B6369757120656854");
    
    -------------
    -- signals --
    -------------
    signal sim_completed_s : boolean := false;
    
    -----------
    -- Ports --
    -----------
    signal clock_sti     : std_logic;
    signal reset_sti     : std_logic;
    signal enable_sti    : std_logic;
    signal valid_sti     : std_logic;
    signal wb_sti        : std_logic_vector(511 downto 0);
    signal valid_obs     : std_logic;
    signal footprint_obs : std_logic_vector(127 downto 0) := (others => '0');
    
    ----------------
    -- Procedures --
    ----------------
    -- simulator cycle
    procedure cycle(nb_cycle : integer := 1) is
    begin
        for i in 1 to nb_cycle loop
            wait until falling_edge(clock_sti);
            wait for 2 ns;
        end loop;
    end cycle;

begin
    
    ------------------------------
    -- Components instanciation --
    ------------------------------
    uut : Md5Core
        port map(clk_i       => clock_sti,
                 rst_i       => reset_sti,
                 en_i        => enable_sti,
                 valid_i     => valid_sti,
                 wb_i        => wb_sti,
                 init_val_i  => x"67452301EFCDAB8998BADCFE10325476",
                 valid_o     => valid_obs,
                 footprint_o => footprint_obs
        );
    
    ------------------------------
    -- Clock generation process --
    ------------------------------
    clk_gen : process
    begin
        while not sim_completed_s loop
            clock_sti <= '1';
            wait for CLOCK_PERIOD/2;
            clock_sti <= '0';
            wait for CLOCK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -------------------------
    -- Simulation sequence --
    -------------------------
    sim : process
        -- reset sequence
        procedure reset_seq is
        begin
            reset_sti  <= '1';
            enable_sti <= '0';
            valid_sti  <= '0';
            wb_sti     <= (others => '0');
            cycle(2);
            reset_sti  <= '0';
        end reset_seq;
        
    begin
        -- user notification
        report "Start of simulation";

        -- Reset system at the beginning
        reset_seq; -- reset procedure
        
        enable_sti <= '1';
        
        -- test several cases
        cycle(1);
        md5_test : for I in TEST_WB'range loop
            wb_sti <= TEST_WB(I);
            valid_sti <= '1';
            cycle(1);
            valid_sti <= '0';
            cycle(5);
            
            -- test enable
            if I < (TEST_WB'length / 2) then
                enable_sti <= '0';
                cycle(12);
                enable_sti <= '1';
            end if;
            
            -- wait few cycles
            cycle(5);
        end loop;
        
        cycle(100);
        
        report ">>End of simulation";
        
        sim_completed_s <= true;
        wait; 
    
    end process;

end test_bench;

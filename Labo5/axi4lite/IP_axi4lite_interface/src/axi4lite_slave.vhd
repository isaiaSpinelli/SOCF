-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : axi4lite_slave.vhd
-- Author       : E. Messerli    27.07.2017
-- Description  : slave interface AXI  (without burst)
-- used for     : SOCF lab
--| Modifications |-----------------------------------------------------------
-- Ver  Date       Auteur  Description
-- 1.0  26.03.2019  EMI    Adaptation du chablon pour les etudiants  
-- 1.1  03.04.2020  ISS    Complète le chablon pour le laboratoire 5
------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity axi4lite_slave is
    generic (
        -- Users to add parameters here

        -- User parameters ends

        -- Width of S_AXI data bus
        AXI_DATA_WIDTH  : integer   := 32;  -- 32 or 64 bits
        -- Width of S_AXI address bus
        AXI_ADDR_WIDTH  : integer   := 12
    );
    port (
        -- AXI4-Lite 
        axi_clk_i       : in  std_logic;
        axi_reset_i     : in  std_logic;
        
        -- Write Address Channel
        axi_awaddr_i    : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        axi_awprot_i    : in  std_logic_vector( 2 downto 0);    -- not used
        axi_awvalid_i   : in  std_logic;
        axi_awready_o   : out std_logic;

        -- Write Data Channel
        axi_wdata_i     : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        axi_wstrb_i     : in std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0); 
        axi_wvalid_i    : in  std_logic;
        axi_wready_o    : out std_logic;

        -- Write Response Channel
        axi_bresp_o     : out std_logic_vector(1 downto 0);
        axi_bvalid_o    : out std_logic;
        axi_bready_i    : in  std_logic;

        -- Read Address Channel
        axi_araddr_i    : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        axi_arprot_i    : in  std_logic_vector( 2 downto 0);    -- not used
        axi_arvalid_i   : in  std_logic;
        axi_arready_o   : out std_logic;

        -- Read Data Channel
        axi_rdata_o     : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        axi_rresp_o     : out std_logic_vector(1 downto 0);
        axi_rvalid_o    : out std_logic;
        axi_rready_i    : in  std_logic;

        -- User input-output
        switch_i        : in  std_logic_vector(31 downto 0) := (others => 'X');
        key_i           : in  std_logic_vector(31 downto 0)  := (others => 'X');
        
        leds_o          : out std_logic_vector(31 downto 0);
        
        hex0_o          : out std_logic_vector(31 downto 0);
        hex1_o          : out std_logic_vector(31 downto 0);
        hex2_o          : out std_logic_vector(31 downto 0);
        hex3_o          : out std_logic_vector(31 downto 0);
        hex4_o          : out std_logic_vector(31 downto 0);
        hex5_o          : out std_logic_vector(31 downto 0)
    );
end entity axi4lite_slave;

architecture rtl of axi4lite_slave is

    signal reset_s : std_logic;

    
    signal test_registre_address_valid : std_logic;
    
    
    -- local parameter for addressing 32 bit / 64 bits, cst: AXI_DATA_WIDTH
    -- ADDR_LSB is used for addressing word 32/64 bits registers/memories
    -- ADDR_LSB = 2 for 32 bits (n-1 downto 2)
    -- ADDR_LSB = 3 for 64 bits (n-1 downto 3)
    constant ADDR_LSB  : integer := (AXI_DATA_WIDTH/32)+ 1;
    
    --signal for the AXI slave
    --intern signal for output
    signal axi_awready_s       : std_logic;
    signal axi_arready_s       : std_logic;

    signal axi_wready_s       : std_logic;
    signal axi_rready_s       : std_logic;
    
    signal axi_rvalid_s       : std_logic;
    signal axi_rresp_s        : std_logic_vector(1 downto 0);
    signal axi_rdata_mem_s    : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    
    -- write enable 
    signal axi_data_wren_s       : std_logic;
    
     --intern signal for the axi interface
    signal axi_waddr_mem_s     : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    signal axi_araddr_mem_s    : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    
    signal axi_wdata_mem_s     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_wstrb_mem_s     : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0); 
    -- signal axi_araddr_mem_s    : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    
    signal axi_bresp_s     : std_logic_vector(1 downto 0);
    signal axi_bvalid_s    : std_logic;
    
    
    --------------- SIGNAUX ENTREES / SORTIES ---------------
    
    constant registre_cst_mem : std_logic_vector(AXI_DATA_WIDTH-1 downto 0):= x"deedbeef";
    signal registre_test_mem : std_logic_vector(AXI_DATA_WIDTH-1 downto 0):= (others => '0');
    
    -- signal for registre input (switch / key)
    signal registre_switch_mem : std_logic_vector(9 downto 0) := (others => 'X');
    signal registre_key_mem : std_logic_vector(3 downto 0) := (others => 'X');
    
    -- signal for registre leds 
    signal registre_led_mem : std_logic_vector(9 downto 0) := (others => 'X');
    
    -- signal for registre 7 seg
    signal registre_hex0_mem : std_logic_vector(6 downto 0) := (others => 'X');
    signal registre_hex1_mem : std_logic_vector(6 downto 0) := (others => 'X');
    signal registre_hex2_mem : std_logic_vector(6 downto 0) := (others => 'X');
    signal registre_hex3_mem : std_logic_vector(6 downto 0) := (others => 'X');
    signal registre_hex4_mem : std_logic_vector(6 downto 0) := (others => 'X');
    signal registre_hex5_mem : std_logic_vector(6 downto 0) := (others => 'X');
    
begin

    -- default values 
    reset_s  <= axi_reset_i;
    --axi_bresp_o <= "00";
    --axi_bresp_s <= "00";
    --axi_bvalid_o <= '0';
    --axi_rdata_o <= (others => 'X');
    --axi_rresp_o <= "00";
    --axi_rvalid_o <= '0';
    leds_o(9 downto 0) <= "0101010101";
    --leds_o(31 downto 10) <= (others => '0');
    
    hex0_o(6 downto 0) <= "1001111";
    hex0_o(31 downto 7) <= (others => '0');
    
    hex1_o(6 downto 0) <= "1001111";
    hex1_o(31 downto 7) <= (others => '0');
    
-----------------------------------------------------------
-- Write address channel

    process (reset_s, axi_clk_i)
    begin
        if reset_s = '1' then
            axi_awready_s <= '0';
            axi_waddr_mem_s <= (others => '0');
        elsif rising_edge(axi_clk_i) then
            if (axi_awready_s = '0' and axi_awvalid_i = '1')  then --and axi_wvalid_i = '1') then  modif EMI 10juil2018
                -- slave is ready to accept write address when
                -- there is a valid write address
                axi_awready_s <= '1';
                -- Write Address memorizing
                axi_waddr_mem_s <= axi_awaddr_i(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
            else
                axi_awready_s <= '0';
                axi_waddr_mem_s <= (others => '0');
            end if;
        end if;
    end process;
    axi_awready_o <= axi_awready_s;


-----------------------------------------------------------
-- Write data channel

    -- Implement axi_wready generation
    process (reset_s, axi_clk_i)
    begin
        
        
        if reset_s = '1' then
            --axi_waddr_done_s <= '0'; 
            axi_wready_s    <= '0';
            axi_wdata_mem_s <= (others => '0');
            axi_wstrb_mem_s <= (others => '0');
        elsif rising_edge(axi_clk_i) then
            if (axi_wready_s = '0' and axi_wvalid_i = '1')  then 
                -- slave is ready to accept write data when
                -- there is a valid write data
                axi_wready_s <= '1';
                -- Write Data memorizing
                axi_wdata_mem_s <= axi_wdata_i(AXI_DATA_WIDTH-1 downto 0);
                axi_wstrb_mem_s <= axi_wstrb_i((AXI_DATA_WIDTH/8)-1 downto 0); 
                -- Read axi_wstrb_i
            else
                axi_wready_s <= '0';
                axi_wdata_mem_s <= (others => '0');
                axi_wstrb_mem_s <= (others => '0');
            
            end if;
        end if;
    end process;
    
    axi_wready_o <= axi_wready_s;


    --condition to write data
    axi_data_wren_s <= '1' when axi_wready_s = '1' else 
                        '0';
    
    
    process (reset_s, axi_clk_i)
        --number address to access 32 or 64 bits data
        variable int_waddr_v : natural;
    begin
        if reset_s = '1' then
            
            --to be completed
            --axi_data_wren_s <= '0';
        
            test_registre_address_valid <= '0';
            
        elsif rising_edge(axi_clk_i) then

            if axi_data_wren_s = '1' then
                int_waddr_v   := to_integer(unsigned(axi_waddr_mem_s));
                --axi_bresp_o <= "00";
                case int_waddr_v is
                    -- offset 0 : constante 
                    when 0   => 
                    -- offset 4 : registre de test  
                    when 1   => test_registre_address_valid <= '1';
                    registre_test_mem <= axi_wdata_mem_s;

                    
                    --to be completed


                    when others => null;
                end case;
            end if;
        end if;
    end process;
                    

-----------------------------------------------------------
-- Write response channel

    process (reset_s, axi_clk_i)
    begin
        
        
        if reset_s = '1' then
            --axi_waddr_done_s <= '0'; 
            axi_bresp_s    <= "00";
            axi_bvalid_s   <= '0';
        elsif rising_edge(axi_clk_i) then
            if (axi_bvalid_s = '0' and axi_bready_i = '1')  then 
                -- slave is ready to accept write data when
                -- there is a valid write data
                axi_bvalid_s <= '1';
                -- Write response
                axi_bresp_s    <= "00";
            else
                axi_bvalid_s <= '0';
                axi_bresp_s    <= "--";
            
            
            end if;
        end if;
    end process;
    
    axi_bresp_o <= axi_bresp_s;
    axi_bvalid_o <= axi_bvalid_s;

    

-----------------------------------------------------------
-- Read address channel

    process (reset_s, axi_clk_i)
    begin
        if reset_s = '1' then
           axi_arready_s    <= '0';
           axi_araddr_mem_s <= (others => '1');
        elsif rising_edge(axi_clk_i) then
            if axi_arready_s = '0' and axi_arvalid_i = '1' then
                -- indicates that the slave has acceped the valid read address
                axi_arready_s    <= '1';
                -- Read Address memorizing
                axi_araddr_mem_s <= axi_araddr_i(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
            else
                axi_arready_s    <= '0';
                --axi_araddr_mem_s <= (others => '0');
            end if;
        end if;
    end process;
    axi_arready_o <= axi_arready_s;

-----------------------------------------------------------
-- Read data channel

    -- Implement axi_wready generation
    process (reset_s, axi_clk_i)
    --number address to access 32 or 64 bits data
        variable int_raddr_v : natural;
    begin
        
        
        if reset_s = '1' then
            --axi_waddr_done_s <= '0'; 
            axi_rvalid_s    <= '0';
            axi_rdata_mem_s <= (others => '0');
            axi_rresp_s    <= "00";

        elsif rising_edge(axi_clk_i) then
            if (axi_arready_s = '1' and axi_rvalid_s = '0')  then 
                -- slave is ready to accept write data when
                -- there is a valid write data
                axi_rvalid_s <= '1';
                -- read Data go
                
                int_raddr_v   := to_integer(unsigned(axi_araddr_mem_s));
                axi_rresp_s    <= "00";
                --axi_bresp_o <= "00";
                case int_raddr_v is
                    -- offset 0 : constante 
                    when 0   =>  
                        axi_rdata_mem_s <= registre_cst_mem;
                    -- offset 4 : registre de test  
                    when 1   =>
                        axi_rdata_mem_s <= registre_test_mem;

                    


                    when others => 
                        axi_rresp_s    <= "00";
                end case;
                

                -- Read axi_wstrb_i
            else
                axi_rvalid_s <= '0';
                --axi_rdata_mem_s <= (others => '0');
                axi_rresp_s    <= "--";
            
            end if;
        end if;
    end process;
    
    axi_rvalid_o <= axi_rvalid_s;
    
    
    axi_rdata_o <= axi_rdata_mem_s;
    
    axi_rresp_o <= axi_rresp_s;




end rtl;

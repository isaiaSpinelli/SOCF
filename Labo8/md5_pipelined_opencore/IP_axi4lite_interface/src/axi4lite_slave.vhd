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
-- 1.0  26.04.2019  EMI    Adaptation du chablon pour les etudiants  
-- 1.1  03.05.2020  ISS    Complète le chablon pour le laboratoire 5 Partie 2
-- 1.2  08.05.2020  ISS    Ajout de la fonctionnalité edge pour les irq
-- 1.2  05.06.2020  ISS    Ajout de la fonctionnalité pour le MD5 Core
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
        axi_rready_i    : in  std_logic

        -- User input-output
    );
end entity axi4lite_slave;

architecture rtl of axi4lite_slave is

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

    signal reset_s : std_logic;

    -- local parameter for addressing 32 bit / 64 bits, cst: AXI_DATA_WIDTH
    -- ADDR_LSB is used for addressing word 32/64 bits registers/memories
    -- ADDR_LSB = 2 for 32 bits (n-1 downto 2)
    -- ADDR_LSB = 3 for 64 bits (n-1 downto 3)
    constant ADDR_LSB  			: integer := (AXI_DATA_WIDTH/32)+ 1;
    
    --------------- SIGNAUX AXI 4 LIGHT -------------------
    
    --signal for the AXI slave
    --intern signal for output
    signal axi_awready_s       	: std_logic;
    signal axi_arready_s       	: std_logic;

    signal axi_wready_s       	: std_logic;
    signal axi_rready_s       	: std_logic;
    
    signal axi_rvalid_s       	: std_logic;
    signal axi_rresp_s        	: std_logic_vector(1 downto 0);
    signal axi_rdata_mem_s    	: std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    
    -- write enable 
    signal axi_data_wren_s      : std_logic;
    
     --intern signal for the axi interface
    signal axi_waddr_mem_s     	: std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    signal axi_araddr_mem_s    	: std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    
    signal axi_wdata_mem_s     	: std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_wstrb_mem_s     	: std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0); 
    -- signal axi_araddr_mem_s    : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    
    signal axi_bresp_s     		: std_logic_vector(1 downto 0);
    signal axi_bvalid_s    		: std_logic;
    
    
    --------------- SIGNAUX ENTREES / SORTIES ---------------
	
	--------------- SIGNAUX CONTROLES  ---------------
	signal busy_s    			: std_logic :='0';

	--------------- SIGNAUX MD5 ------------------------
	signal enable_s    			: std_logic :='0';
    signal valid_i_s     		: std_logic :='0';
	signal wb_s        			: std_logic_vector(511 downto 0);
	
	signal init_val_s 			: std_logic_vector(127 downto 0):= x"67452301EFCDAB8998BADCFE10325476";
	
	signal valid_o_s     		: std_logic;
    signal footprint_s 			: std_logic_vector(127 downto 0) := (others => '0');
	signal footprint_mem_s 		: std_logic_vector(127 downto 0) := (others => '0');
	
	
	    
begin

	------------------------------
    -- Components instanciation --
    ------------------------------
    uut : Md5Core
        port map(clk_i       => axi_clk_i,
                 rst_i       => axi_reset_i,
                 en_i        => enable_s,
                 valid_i     => valid_i_s,
                 wb_i        => wb_s,
                 init_val_i  => init_val_s,
                 valid_o     => valid_o_s,
                 footprint_o => footprint_s
        );
		
	 -- mise à jour des entrées
    reset_s  <= axi_reset_i;
	
	-- Constants mis à jour
    --registre_switch_mem <= switch_i(9 downto 0);
	

    
-----------------------------------------------------------
-- Write address channel

    process (reset_s, axi_clk_i)
    begin
		-- En cas de reset
        if reset_s = '1' then
			-- Valeur par défaut
            axi_awready_s <= '0';
            axi_waddr_mem_s <= (others => '0');
        elsif rising_edge(axi_clk_i) then
			-- Si une adresse d'écriture est valide
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
		-- En cas de reset
        if reset_s = '1' then
			-- Valeur par défaut
            axi_wready_s    <= '0';
            axi_wdata_mem_s <= (others => '0');
            axi_wstrb_mem_s <= (others => '0');
        elsif rising_edge(axi_clk_i) then
			-- Si les données d'écriture est valide
            if (axi_wready_s = '0' and axi_wvalid_i = '1')  then 
                -- slave is ready to accept write data when
                -- there is a valid write data
                axi_wready_s <= '1';
				
				-- Read axi_wstrb_i
                axi_wstrb_mem_s <= axi_wstrb_i((AXI_DATA_WIDTH/8)-1 downto 0);
				
				
				-- TEST AVEC LA FONCTIONNALITEE STROBE :
				
				-- Mémorisation des données à écrire en fonction du paramètre strobe
				-- axi_wdata_mem_s <= (others => '0');	
				
				-- if (axi_wstrb_i(0) = '1') then 
					-- axi_wdata_mem_s(7 downto 0) <= axi_wdata_i(7 downto 0);	
				-- end if;
				-- if (axi_wstrb_i(1) = '1') then 
					-- axi_wdata_mem_s(15 downto 8) <= axi_wdata_i(15 downto 8);	
				-- end if;
				-- if (axi_wstrb_i(2) = '1') then 
					-- axi_wdata_mem_s(23 downto 16) <= axi_wdata_i(23 downto 16);	
				-- end if;
				-- if (axi_wstrb_i(3) = '1') then 
					-- axi_wdata_mem_s(31 downto 24) <= axi_wdata_i(31 downto 24);	
				-- end if;
				
				-- Sans la fonctionnalité strobe 
				axi_wdata_mem_s <= axi_wdata_i;

            else
                axi_wready_s <= '0';
                axi_wdata_mem_s <= (others => '0');
                axi_wstrb_mem_s <= (others => '0');
            
            end if;
        end if;
    end process;
    
	-- Met à jour la sortie
    axi_wready_o <= axi_wready_s;


    -- condition to write data : si on est prêt à écrire
    axi_data_wren_s <= '1' when axi_wready_s = '1' else 
                        '0';
						
						
-----------------------------------------------------------
    -- ECRITURE 
    process (reset_s, axi_clk_i)
        --number address to access 32 or 64 bits data
        variable int_waddr_v : natural;
    begin
        if reset_s = '1' then
            -- Valeur par défaut : RESET 
			wb_s 		<= (others => '0');
			enable_s	<= '0';
			busy_s <= '0';
			valid_i_s <= '0';
            
        elsif rising_edge(axi_clk_i) then
			-- Si un footprint est arrivé, met à jour la valeur d'init
			if valid_o_s = '1' then
				footprint_mem_s <= footprint_s;
				init_val_s <= footprint_s;
				busy_s <= '0';
			end if;
			
			-- s'assure que le signal valid_i reste actif un seul coup de clock
			valid_i_s <= '0';
		
			-- Si une écriture est active
            if axi_data_wren_s = '1' then
				-- convertie l'adresse d'écriture en integer
                int_waddr_v   := to_integer(unsigned(axi_waddr_mem_s));
                case int_waddr_v is
                    -- offset 0 - 15 : wb_s (511 - 0) 
                    when 0 to 14   =>  wb_s ( ((int_waddr_v*32+31)) downto (int_waddr_v*32) ) <= axi_wdata_mem_s;
                   
				     when 15   =>  	wb_s ( 511 downto 480 ) <= axi_wdata_mem_s;
									valid_i_s <= '1';
									busy_s <= '1';
                        
                    -- offset 64 : Enable  
                    when 64   => 
						enable_s <= axi_wdata_mem_s(0);  
						busy_s <= '0';
						init_val_s  <= x"67452301EFCDAB8998BADCFE10325476";

                        
                        
                    when others => null;
                end case;
            end if;
        end if;
    end process;
                    

-----------------------------------------------------------
-- Write response channel

    process (reset_s, axi_clk_i)
    begin
        -- En cas de reset
        if reset_s = '1' then
            -- Valeur par défaut
            axi_bresp_s    <= "00";
            axi_bvalid_s   <= '0';
        elsif rising_edge(axi_clk_i) then
			-- Si le master est pret à lire la réponse
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
    -- Met à jours les sorties
    axi_bresp_o <= axi_bresp_s;
    axi_bvalid_o <= axi_bvalid_s;

    

-----------------------------------------------------------
-- Read address channel

    process (reset_s, axi_clk_i)
    begin
		-- en cas de reset
        if reset_s = '1' then
			-- valeur par défaut
           axi_arready_s    <= '0';
           axi_araddr_mem_s <= (others => '1');
        elsif rising_edge(axi_clk_i) then
			-- Si une adresse de lecture est valide
            if axi_arready_s = '0' and axi_arvalid_i = '1' then
                -- indicates that the slave has acceped the valid read address
                axi_arready_s    <= '1';
                -- Read Address memorizing
                axi_araddr_mem_s <= axi_araddr_i(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
            else
                axi_arready_s    <= '0';
            end if;
        end if;
    end process;
	-- Met à jour la sortie 
    axi_arready_o <= axi_arready_s;

-----------------------------------------------------------
-- Read data channel

    -- Implement axi_wready generation
    process (reset_s, axi_clk_i)
    --number address to access 32 or 64 bits data
        variable int_raddr_v : natural;
    begin
        
        -- En cas de reset
        if reset_s = '1' then
            -- valeur par défaut
            axi_rvalid_s    <= '0';
            axi_rdata_mem_s <= (others => '0');
            axi_rresp_s    <= "00";
			

        elsif rising_edge(axi_clk_i) then

		
			-- Si une lecture est faite
            if (axi_arready_s = '1' and axi_rvalid_s = '0')  then 
			
				-- Pré-charge une lecture à 0
				axi_rdata_mem_s <= (others => '0');
			
                -- slave is ready to accept write data when
                -- there is a valid write data
                axi_rvalid_s <= '1';
				
                -- read Data go
                int_raddr_v   := to_integer(unsigned(axi_araddr_mem_s));
                axi_rresp_s    <= "00";
		
				-- En fonction de l'adresse qu'on souhaite lire
                case int_raddr_v is
					-- lecture de la constante
					when 0   =>
                        axi_rdata_mem_s <= x"deadbeef";
					-- lecture du enable
                    when 64   =>
                        axi_rdata_mem_s(0) <= enable_s;
                     -- Lecture du busy
                    when 65   =>
                        axi_rdata_mem_s(0) <= busy_s;
						
						
					-- lecture du footprint
					when 128   =>
                        axi_rdata_mem_s <= footprint_mem_s(31 downto 0);
					when 129   =>
                         axi_rdata_mem_s <= footprint_mem_s(63 downto 32);
					when 130   =>
                         axi_rdata_mem_s <= footprint_mem_s(95 downto 64);
                    when 131   =>
                         axi_rdata_mem_s <= footprint_mem_s(127 downto 96);
                        
                   
                        
                        
                    when others => 
                        axi_rresp_s    <= "00";
                end case;
                
            else
                axi_rvalid_s <= '0';
                axi_rresp_s    <= "--";
            
            end if;
        end if;
    end process;
	

    -- Mise à jour de la validité de lecture
    axi_rvalid_o <= axi_rvalid_s;
    
    -- Mise à jour des données lues
    axi_rdata_o <= axi_rdata_mem_s;
    
    -- Mise à jour de la réponse de lecture
    axi_rresp_o <= axi_rresp_s;
    
    
    -- Mise à jour des sorties


end rtl;

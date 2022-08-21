library ieee;
use ieee.std_logic_1164.all;

entity PipeRegE is
	port(
		clk, flush, freeze : in std_logic;
		
		pc_e_din, ir_e_din, ao_e_din : in std_logic_vector(15 downto 0);
		bm_e_din : in std_logic_vector(7 downto 0);
		
		pc_e_dout, ir_e_dout, ao_e_dout : out std_logic_vector(15 downto 0);
		bm_e_dout : out std_logic_vector(7 downto 0);
		-- WB control signals in
		rf_a3_in_din : in std_logic_vector(1 downto 0);
		rf_d3_in_din, reg_write_din : in std_logic;
		
		-- WB control signals out
		rf_a3_in_dout : out std_logic_vector(1 downto 0);
		rf_d3_in_dout, reg_write_dout : out std_logic
	);
end PipeRegE;

architecture Behave of PipeRegE is
	
	signal pc_e : std_logic_vector(15 downto 0);
	signal ir_e : std_logic_vector(15 downto 0);
	signal bm_e : std_logic_vector(7 downto 0);
	signal ao_e : std_logic_vector(15 downto 0);
	
	
	-- WB control signals
	signal rf_a3_in : std_logic_vector(1 downto 0);
	signal rf_d3_in : std_logic;
	signal reg_write : std_logic;
	
begin

	process(clk, flush, freeze)
	begin
		
		if clk'event and clk = '1' then
			if flush = '1' then
				
				pc_e <= (others => '0');
				ir_e <= (others => '1');
				bm_e <= (others => '0');
				ao_e <= (others => '0');
				
				--WB
				rf_a3_in <= "00";
				rf_d3_in <= '0';
				reg_write <= '0';
				
			elsif freeze = '0' then
			
				pc_e <= pc_e_din;
				ir_e <= ir_e_din;
				bm_e <= bm_e_din;
				ao_e <= ao_e_din;
				
				
				-- WB
				rf_a3_in <= rf_a3_in_din;
				rf_d3_in <= rf_d3_in_din;
				reg_write <= reg_write_din;
			
			end if;
		end if;
			
		
	end process;
	
	pc_e_dout <= pc_e;
	ir_e_dout <= ir_e;
	bm_e_dout <= bm_e;
	ao_e_dout <= ao_e;
	
	-- WB
	rf_a3_in_dout <= rf_a3_in;
	rf_d3_in_dout <= rf_d3_in;
	reg_write_dout <= reg_write;

end Behave;
library ieee;
use ieee.std_logic_1164.all;

entity PipeRegA is
	port(
		clk : in std_logic;
		
		flush : in std_logic;
		freeze : in std_logic;
		
		pc_a_din : in std_logic_vector(15 downto 0);
		ir_a_din : in std_logic_vector(15 downto 0);
		ipc_a_din : in std_logic_vector(15 downto 0);
		
		pc_a_dout : out std_logic_vector(15 downto 0);
		ir_a_dout : out std_logic_vector(15 downto 0);
		ipc_a_dout : out std_logic_vector(15 downto 0)
	);
end PipeRegA;

architecture Behave of PipeRegA is
	
	signal pc_a : std_logic_vector(15 downto 0);
	signal ir_a : std_logic_vector(15 downto 0);
	signal ipc_a : std_logic_vector(15 downto 0);
	
begin

	process(clk, flush, freeze)
	begin
		
		if clk'event and clk = '1' then
			if flush = '1' then
				
				pc_a <= (others => '0');
				ir_a <= (others => '1');
				ipc_a <= (others => '0');
				
			elsif freeze = '0' then
			
				pc_a <= pc_a_din;
				ir_a <= ir_a_din;
				ipc_a <= ipc_a_din;
			
			end if;
		end if;
			
		
	end process;
	
	pc_a_dout <= pc_a;
	ir_a_dout <= ir_a;
	ipc_a_dout <= ipc_a;

end Behave;
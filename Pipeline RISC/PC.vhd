library ieee;
use ieee.std_logic_1164.all;

entity PC is
	port(
		clk : in std_logic;
		flush : in std_logic;
		freeze : in std_logic;
	
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end entity;

architecture Behave of PC is
	signal pc_data : std_logic_vector(15 downto 0);
begin

	process(clk) 
	begin
		if clk'event and (clk = '1') then
			
			if flush = '1' then 
				pc_data <= (others => '0');
			elsif freeze = '0' then
				pc_data <= data_in;
			end if;
			
		end if;
		
	end process;

	data_out <= pc_data;
    
end Behave;
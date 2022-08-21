library ieee;
use ieee.std_logic_1164.all;

entity Register3 is
	port(
		data_in : in std_logic_vector(2 downto 0);
		clk : in std_logic;
		reset : in std_logic;
		reg_write : in std_logic;
		data_out : out std_logic_vector(2 downto 0)
	);
end entity;

architecture Behave of Register3 is
	signal reg_data : std_logic_vector(2 downto 0);
begin

	process(clk, reset, reg_write) 
	begin
		if reset = '1' then
			reg_data <= (others => '0');
		elsif clk'event and (clk = '1') and (reg_write = '1') then
			reg_data <= data_in;
		end if;
	end process;

	data_out <= reg_data;
    
end Behave;
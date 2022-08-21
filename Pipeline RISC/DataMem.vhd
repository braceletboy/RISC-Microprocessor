library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity DataMem is 
	port(
		
		clk : in std_logic;
		reset : in std_logic;
		mem_write: in std_logic;
		
		addr : in std_logic_vector(15 downto 0); 
		data_in : in std_logic_vector(15 downto 0); 
		data_out: out std_logic_vector(15 downto 0)
		
		);
end entity;

architecture Behave of DataMem is
	
	type mem_array is array(127 downto 0) of std_logic_vector(15 downto 0);
	signal mem: mem_array;
	
begin

	process(reset, addr, data_in, mem_write, clk)
	begin
		
		if reset = '1' then
			mem <= (0 => "1000000000001111", 15 => "0000000000001111", 16 => "0000000000010000", 17 => "0000000010001111", 18 => "1110000000001111", 
						19 => "0000000000001111", 20 => "1100000000001111", 21 => "0010000000001111",
						others => (others => '0'));
		elsif mem_write = '0' then
			data_out <= mem(to_integer(unsigned(addr(6 downto 0))));
		elsif (clk'event and (clk = '1') and mem_write = '1') then
			mem(to_integer(unsigned(addr(6 downto 0)))) <= data_in;
		end if;
		
	end process;
	
end Behave;
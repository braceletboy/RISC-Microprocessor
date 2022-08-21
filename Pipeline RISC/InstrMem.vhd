library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity InstrMem is 
	port(
		addr : in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(15 downto 0)
		);
end entity;

architecture Behave of InstrMem is
	
	type mem_array is array(127 downto 0) of std_logic_vector(15 downto 0);
	signal mem: mem_array;
	
begin
	
	mem <= (
		0 => "0011011100001111",
		1 => "0100001000000000",
		2 => "0000001011001001",
		3 => "0000011011011000",
		4 => "0110001001111111",
		others => (others => '1')
	);
	
	data_out <= mem(to_integer(unsigned(addr(6 downto 0))));
	
end Behave;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity Memory is 
	port(addr, data_in: in std_logic_vector(15 downto 0); 
			data_out: out std_logic_vector(15 downto 0); 
			reset : in std_logic;
			CLK, memWrite: in std_logic
		);
end entity;

architecture memory_arch of Memory is
	type mem_array is array(127 downto 0) of std_logic_vector(15 downto 0);
	signal mem: mem_array;
begin
	process(reset, addr, data_in, memWrite,CLK)
	begin
		if reset = '1' then
			mem(0) <= "0001010000001111";
			mem(1) <= "0110000011110011";
			mem(15) <= "0000000000001111";
			mem(16) <= "1010101010101011";
			mem(17) <= "1010101010101110";
			mem(18) <= "1010101010111010";
			mem(19) <= "1010101011101010";
			mem(20) <= "1010101110101010";
			mem(21) <= "1010111010101010";
			mem(22) <= "1011101010101010";
			mem(14 downto 2) <= (others => (others => '0'));
			mem(127 downto 23) <= (others => (others => '0'));
		elsif memWrite = '0' then
			data_out <= mem(to_integer(unsigned(addr(6 downto 0))));
		elsif (CLK'event and (CLK = '1') and memWrite = '1') then
			mem(to_integer(unsigned(addr(6 downto 0)))) <= data_in;
		end if;
	end process;
end memory_arch;
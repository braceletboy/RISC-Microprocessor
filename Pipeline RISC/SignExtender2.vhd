library ieee;
use ieee.std_logic_1164.all;

entity SignExtender2 is
	port (
		data_in : in std_logic_vector(8 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end entity;

architecture Behave of SignExtender2 is
begin
	
	data_out(15) <= data_in(8);
	data_out(14) <= data_in(8);
	data_out(13) <= data_in(8);
	data_out(12) <= data_in(8);
	data_out(11) <= data_in(8);
	data_out(10) <= data_in(8);
	data_out(9) <= data_in(8);
	data_out(8 downto 0) <= data_in(8 downto 0);
	
end Behave;
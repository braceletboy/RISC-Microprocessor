library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
	port(
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end Adder;

architecture Behave of Adder is
	
	constant const_one : std_logic_vector(15 downto 0) := "0000000000000001";

begin
	
	data_out <= data_in + const_one;
	
end Behave;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library std;
use std.standard.all;

entity INC is
	port(input: in std_logic_vector(2 downto 0); output: out std_logic_vector(2 downto 0));
end entity;

architecture INC_arch of INC is 
begin
	output <= input + "001";
end INC_arch;
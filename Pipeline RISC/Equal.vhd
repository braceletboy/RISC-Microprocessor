library ieee;
use ieee.std_logic_1164.all;

entity Equal is
	port(
		eq_a : in std_logic_vector(15 downto 0);
		eq_b : in std_logic_vector(15 downto 0);
		eq : out std_logic
	);
end entity;

architecture Behave of Equal is
begin
	
	process(eq_a, eq_b)
	begin
		
		if eq_a = eq_b then
			eq <= '1';
		else
			eq <= '0';
		end if;
		
	end process;
	
end Behave;
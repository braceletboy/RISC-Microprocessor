library ieee;
use ieee.std_logic_1164.all;

entity Padder is
	port (
		data_in : in std_logic_vector(8 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end entity;

architecture Behave of Padder is
begin

	data_out(15 downto 7) <= data_in(8 downto 0);
	data_out(6 downto 0) <= "0000000";

end Behave;
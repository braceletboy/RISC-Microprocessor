library ieee;
use ieee.std_logic_1164.all;

entity Mux2 is
	generic(n : integer := 16);
	port(
		data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
		input_select : in std_logic := '0';
		data_out : out std_logic_vector(n-1 downto 0)
	);
end entity;

architecture Behave of Mux2 is
begin
	process(data_in0, data_in1, input_select)
	begin
		case input_select is
			when '0' => data_out <= data_in0;
			when '1' => data_out <= data_in1;
			when others => data_out <= (others => '0');
		end case;
	end process;
end Behave;
library ieee;
use ieee.std_logic_1164.all;

entity Mux4 is
	generic(n : integer := 16);
	port(
		data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in2 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in3 : in std_logic_vector(n-1 downto 0) := (others => '0');
		input_select : in std_logic_vector(1 downto 0) := (others => '0');
		data_out : out std_logic_vector(n-1 downto 0)
	);
end entity;

architecture Behave of Mux4 is
begin
	process(data_in0, data_in1, data_in2, data_in3, input_select)
	begin
		case input_select is
			when "00" => data_out <= data_in0;
			when "01" => data_out <= data_in1;
			when "10" => data_out <= data_in2;
			when "11" => data_out <= data_in3;
			when others => data_out <= (others => '0');
		end case;
	end process;
end Behave;
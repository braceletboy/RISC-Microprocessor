library ieee;
use ieee.std_logic_1164.all;

entity Mux8 is
	generic(n : integer := 16);
	port(
		data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in2 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in3 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in4 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in5 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in6 : in std_logic_vector(n-1 downto 0) := (others => '0');
		data_in7 : in std_logic_vector(n-1 downto 0) := (others => '0');
		input_select : in std_logic_vector(2 downto 0) := (others => '0');
		data_out : out std_logic_vector(n-1 downto 0)
	);
end entity;

architecture Behave of Mux8 is
begin
	process(data_in0, data_in1, data_in2, data_in3, data_in4, data_in5, data_in6, data_in7, input_select)
	begin
		case input_select is
			when "000" => data_out <= data_in0;
			when "001" => data_out <= data_in1;
			when "010" => data_out <= data_in2;
			when "011" => data_out <= data_in3;
			when "100" => data_out <= data_in4;
			when "101" => data_out <= data_in5;
			when "110" => data_out <= data_in6;
			when "111" => data_out <= data_in7;
			when others => data_out <= (others => '0');
		end case;
	end process;
end Behave;
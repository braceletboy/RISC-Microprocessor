library ieee;
use ieee.std_logic_1164.all;

entity BitRem is
	port(
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
end BitRem;

architecture Behave of BitRem is

begin
	
	process(data_in)
	begin
		
		if (data_in(0) = '1') then
			
			data_out(7 downto 1) <= data_in(7 downto 1);
			data_out(0 downto 0) <= "0";
			
		elsif (data_in(1) = '1') then
			
			data_out(7 downto 2) <= data_in(7 downto 2);
			data_out(1 downto 0) <= "00";
			
		elsif (data_in(2) = '1') then
			
			data_out(7 downto 3) <= data_in(7 downto 3);
			data_out(2 downto 0) <= "000";
			
		elsif (data_in(3) = '1') then
			
			data_out(7 downto 4) <= data_in(7 downto 4);
			data_out(3 downto 0) <= "0000";
			
		elsif (data_in(4) = '1') then
			
			data_out(7 downto 5) <= data_in(7 downto 5);
			data_out(4 downto 0) <= "00000";
			
		elsif (data_in(5) = '1') then
			
			data_out(7 downto 6) <= data_in(7 downto 6);
			data_out(5 downto 0) <= "000000";
			
		elsif (data_in(6) = '1') then
			
			data_out(7 downto 7) <= data_in(7 downto 7);
			data_out(6 downto 0) <= "0000000";
			
		else
			
			data_out <= "00000000";
			
		end if;
		
	end process;
	
end Behave;
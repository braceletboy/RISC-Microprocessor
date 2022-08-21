library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.standard.all;

entity priority_encoder is
	port(BM_d: in std_logic_vector(7 downto 0); priority_bits: out std_logic_vector(2 downto 0));
end entity;

architecture priority_encoder_arch of priority_encoder is 
begin
	process(BM_d)
	begin
		if BM_d(0) = '1' then
			priority_bits <= "000";
		elsif BM_d(1) = '1' then
			priority_bits <= "001";
		elsif BM_d(2) = '1' then
			priority_bits <= "010";
		elsif BM_d(3) = '1' then
			priority_bits <= "011";
		elsif BM_d(4) = '1' then
			priority_bits <= "100";
		elsif BM_d(5) = '1' then
			priority_bits <= "101";
		elsif BM_d(6) = '1' then
			priority_bits <= "110";
		elsif BM_d(7) = '1' then
			priority_bits <= "111";
		else
			priority_bits <= "000";
		end if;
	end process;
end priority_encoder_arch;

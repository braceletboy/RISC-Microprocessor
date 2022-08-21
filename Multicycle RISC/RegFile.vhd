library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity RegFile is
	port(
		a1,a2,a3: in std_logic_vector(2 downto 0);
		d3: in std_logic_vector(15 downto 0);
		d1,d2: out std_logic_vector(15 downto 0);
		reset: in std_logic;
		CLK, regWrite: in std_logic;
		r0, r1, r2, r3, r4, r5, r6, r7: out std_logic_vector(15 downto 0)
		);
end entity;

architecture reg_file_arch of RegFile is
	type reg_array is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal regFile: reg_array;
begin
	process(a3,d3,regWrite,CLK,reset)
	begin
		if reset = '1' then
			regFile(0) <= (others => '0');
			regFile(1) <= (others => '0');
			regFile(2) <= (others => '0');
			regFile(3) <= (others => '0');
			regFile(4) <= (others => '0');
			regFile(5) <= (others => '0');
			regFile(6) <= (others => '0');
			regFile(7) <= (others => '0');
		elsif (CLK'event and (CLK = '1') and (regWrite = '1')) then
			regFile(to_integer(unsigned(a3))) <= d3;
		end if;
	end process;
	d1 <= regFile(to_integer(unsigned(a1)));
	d2 <= regFile(to_integer(unsigned(a2)));
	r0 <= regFile(0);
	r1 <= regFile(1);
	r2 <= regFile(2);
	r3 <= regFile(3);
	r4 <= regFile(4);
	r5 <= regFile(5);
	r6 <= regFile(6);
	r7 <= regFile(7);
end reg_file_arch;
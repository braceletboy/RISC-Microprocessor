library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity RegFile is
	port(
		
		clk : in std_logic;
		reset : in std_logic;
		reg_write : in std_logic;
		r7_write : in std_logic;
		
		a1: in std_logic_vector(2 downto 0);
		a2: in std_logic_vector(2 downto 0);
		a3: in std_logic_vector(2 downto 0);
		
		d1: out std_logic_vector(15 downto 0);
		d2: out std_logic_vector(15 downto 0);
		d3: in std_logic_vector(15 downto 0);
		
		r7_data_in : in std_logic_vector(15 downto 0);
		r7_data_out : out std_logic_vector(15 downto 0);
		
		r0, r1, r2, r3, r4, r5, r6, r7: out std_logic_vector(15 downto 0)
		);
end entity;

architecture Behave of RegFile is
	
	type reg_array is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal regFile: reg_array;
	
begin

	process(clk, reset)
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
			
		elsif clk'event and (clk = '0') then
			
			if a3 = "111" then
				
				if reg_write = '1' then
					regFile(to_integer(unsigned(a3))) <= d3;
				elsif r7_write = '1' then
					regFile(7) <= r7_data_in;
				end if;
				
			else
				
				if reg_write = '1' then
					regFile(to_integer(unsigned(a3))) <= d3;
				end if;
				
				if r7_write = '1' then
					regFile(7) <= r7_data_in;
				end if;
				
			end if;
						
			
		end if;
	end process;
	
	d1 <= regFile(to_integer(unsigned(a1)));
	d2 <= regFile(to_integer(unsigned(a2)));
	
	r7_data_out <= regFile(7);
	
	r0 <= regFile(0);
	r1 <= regFile(1);
	r2 <= regFile(2);
	r3 <= regFile(3);
	r4 <= regFile(4);
	r5 <= regFile(5);
	r6 <= regFile(6);
	r7 <= regFile(7);
end Behave;
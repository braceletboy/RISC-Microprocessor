library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library std;
use std.standard.all;

entity ALU is
	port(
		data_a, data_b: in std_logic_vector(15 downto 0) := "0000000000000000";
		opSelect:in std_logic_vector(1 downto 0);
		output: out std_logic_vector(15 downto 0); 
		z,c,eq: out std_logic
	);
end entity;

architecture alu_arch of ALU is
	signal a, b, tmpOut: std_logic_vector(16 downto 0);
	signal carry, zero, equal: std_logic := '0';
begin
	a(16) <= '0';
	b(16) <= '0';
	a(15 downto 0) <= data_a;
	b(15 downto 0) <= data_b;
	process(a,b,opSelect)
	begin
	
		if (opSelect="00") then
			tmpOut <= a + b;
		elsif (opSelect="01") then
			tmpOut <= a nand b;
		elsif (opSelect = "10") then
			if (a = b) then
				equal <= '1';
			else
				equal <= '0';
			end if;
		else
			tmpOut <= a + b;
		end if;
	end process;
	
	process(tmpOut, opSelect)
	begin
		
		if(opSelect = "00") then
			carry <= tmpOut(16);
		end if;
		
	end process;
	
	process(tmpOut, opSelect)
	begin
		
		if(opSelect = "01") or (opSelect = "00") then
			if(tmpOut(15 downto 0) = "0000000000000000") then
				zero <= '1';
			else
				zero <= '0';
			end if;
		end if;
		
	end process;
	
	output <= tmpOut(15 downto 0);
	z <= zero;
	c <= carry;
	eq <= equal;
	
end alu_arch;
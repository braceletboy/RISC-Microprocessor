library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library std;
use std.standard.all;

entity ALU is
	port(
		alu_a, alu_b : in std_logic_vector(15 downto 0) := "0000000000000000";
		alu_op :in std_logic_vector(1 downto 0);
		alu_out : out std_logic_vector(15 downto 0); 
		zero, carry : out std_logic
	);
end entity;

architecture Behave of ALU is
	signal a, b, out_latch: std_logic_vector(16 downto 0);
begin
	a(16) <= '0';
	b(16) <= '0';
	a(15 downto 0) <= alu_a;
	b(15 downto 0) <= alu_b;
	
	process(a,b,alu_op)
	begin
	
		if (alu_op = "00") then
			out_latch <= a + b;
		elsif (alu_op = "01") then
			out_latch <= a nand b;
		else
			out_latch <= a + b;
		end if;
	end process;
	
	process(out_latch, alu_op)
	begin
		
		if(alu_op = "00") then
			carry <= out_latch(16);
		end if;
		
	end process;
	
	process(out_latch, alu_op)
	begin
		
		if (alu_op = "00" or alu_op = "01") then
			if (out_latch(15 downto 0) = "0000000000000000") then
				zero <= '1';
			else
				zero <= '0';
			end if;
		end if;
		
	end process;
	
	alu_out <= out_latch(15 downto 0);
	
end Behave;
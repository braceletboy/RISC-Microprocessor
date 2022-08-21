-- For ALU_forwarding, we generate the forwarding signals in the ID stage and propagate it to the EX stage
-- PC is assumed to be written into at the falling edge of the clock cycle

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity forwarding_unit is
	port(flag_LMSM: in std_logic; IR_a, IR_c, IR_d, state_array: in std_logic_vector(15 downto 0); pcf_in, alu_af_in, alu_bf_in: out std_logic_vector(1 downto 0));
end entity;

architecture forwarding_unit_arch of forwarding_unit is
begin
	process(flag_LMSM, IR_a, IR_c, IR_d, state_array)
		variable Sa,Sb: std_logic_vector(1 downto 0);
		variable c_rc: integer;
	begin
		Sa(0) := state_array(2*to_integer(unsigned(IR_a(11 downto 9))));
		Sa(1) := state_array(2*to_integer(unsigned(IR_a(11 downto 9)))+1);
		Sb(0) := state_array(2*to_integer(unsigned(IR_a(8 downto 6))));
		Sb(1) := state_array(2*to_integer(unsigned(IR_a(8 downto 6)))+1);

		c_rc := to_integer(unsigned(IR_c(5 downto 3)));
		
		-- Alu forwarding - for alu_a [ADD,NDU, ADC, NDC, ADZ, NDZ, ADI, SW]
		if  ((IR_a(15 downto 12) = "0001") or (IR_a(15 downto 12) = "0010") or 
				(IR_a(15 downto 12) = "0000") or (IR_a(15 downto 12) = "0101")) then
			if Sa = "10" then
				alu_af_in <= "01";
			elsif Sa = "01" then
				alu_af_in <= "10";
			else
				alu_af_in <= "00";
			end if;
		else
			alu_af_in <= "00";
		end if;
		
		-- Alu forwarding - for alu_b [ADD, NDU, ADC, NDC, ADZ, NDZ, LW, SW]
		if ((IR_a(15 downto 12) = "0000") or
				(IR_a(15 downto 12) = "0010") or (IR_a(15 downto 13) = "010")) then
			if Sb = "10" then
				alu_bf_in <= "01";
			elsif Sb = "01" then
				alu_bf_in <= "10";
			else
				alu_bf_in <= "00";
			end if;
		else
			alu_bf_in <= "00";
		end if;
		
		-- PC forwarding
		-- LM r7
		if ir_a(15 downto 13) = "011" then
			pcf_in <= "10";
		-- lhi/lw r7
		elsif ((IR_d(15 downto 12) = "0100")
				and (IR_d(11 downto 9) = "111")) then
			pcf_in <= "11";
		-- alu r7 [ADX, NDX]
		elsif ((((IR_c(15 downto 12) = "0000") or (IR_c(15 downto 12) = "0010")) and 
				c_rc = 7) or ((IR_c(15 downto 12) = "0001") and c_rc = 7) or ((IR_c(15 downto 12) = "0011") and c_rc = 7)) then
			pcf_in <= "01";
		else
			pcf_in <= "00";
		end if;
	end process;
end forwarding_unit_arch;
-- Takes in fsm_write signal
-- If fsm_write = '1', then load a value into new state based on the value present in IR_a

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.standard.all;

entity FSM is
	port(CLK, fsm_flush, fsm_write: in std_logic; IR_a: in std_logic_vector(15 downto 0); state: out std_logic_vector(1 downto 0));
end entity;

architecture fsm_arch of FSM is
	type fsm_state is (s0, s1, s2, s3); --s0 = 11, s1=01, s2=10, s3=00
	signal fsmstate: fsm_state := s3;
begin
	process(CLK)
		variable nfs : fsm_state;
	begin
		
		if fsmstate = s0 then
			nfs := s1;
		elsif fsmstate = s1 then
			nfs := s3;
		elsif fsmstate = s2 then
			nfs := s1;
		else
			nfs := s3;
		end if;
		
		if rising_edge(clk) then
			if fsm_flush = '1' then
				fsmstate <= s3;
			else
				if fsm_write = '1' then
					if IR_a(15 downto 12) = "0100" then
						fsmstate <= s0;
					elsif IR_a(15 downto 14) = "00" then
						fsmstate <= s2;
					end if;
				else
					fsmstate <= nfs;
				end if;
			end if;
		end if;
	end process;
	
	process(fsmstate)
	begin
		if fsmstate=s0 then
			state <= "11";
		elsif fsmstate=s1 then
			state <= "01";
		elsif fsmstate=s2 then
			state <= "10";
		else
			state <= "00";
		end if;
	end process;
end fsm_arch;


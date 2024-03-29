-- Status_file keeps the status of the instructions encountered
	-- Status signals include -> flag_c, flag_z, register FSMs
-- The FSMs operate at the edge of the CLK cycle

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity status_file is
	port(CLK: in std_logic; fsm_write: in std_logic_vector(7 downto 0); IR_a: in std_logic_vector(15 downto 0);
			BM_d: in std_logic_vector(7 downto 0); fsmc_write, fsmz_write: in std_logic; flush_status: in std_logic;
			flag_c, flag_z: out std_logic; fsm_state_array: out std_logic_vector(15 downto 0));
end entity;

architecture status_file_arch of status_file is
	component FSM is
		port(CLK, fsm_flush, fsm_write: in std_logic; IR_a: in std_logic_vector(15 downto 0); state: out std_logic_vector(1 downto 0));
	end component;
	
	type fsm_state is (s0, s1, s2, s3); --s0 = 11, s1=01, s2=10, s3=00
	signal fsmstate7: fsm_state := s3;
	
	signal state_c: std_logic := '0';
	
	signal state_z: std_logic := '0';
	
begin
	FSM_0:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(0), IR_a=>IR_a, state(0)=>fsm_state_array(0), state(1)=>fsm_state_array(1));
	FSM_1:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(1), IR_a=>IR_a, state(0)=>fsm_state_array(2), state(1)=>fsm_state_array(3));
	FSM_2:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(2), IR_a=>IR_a, state(0)=>fsm_state_array(4), state(1)=>fsm_state_array(5));
	FSM_3:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(3), IR_a=>IR_a, state(0)=>fsm_state_array(6), state(1)=>fsm_state_array(7));
	FSM_4:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(4), IR_a=>IR_a, state(0)=>fsm_state_array(8), state(1)=>fsm_state_array(9));
	FSM_5:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(5), IR_a=>IR_a, state(0)=>fsm_state_array(10), state(1)=>fsm_state_array(11));
	FSM_6:	FSM port map(CLK => CLK, fsm_flush=>flush_status, fsm_write => fsm_write(6), IR_a=>IR_a, state(0)=>fsm_state_array(12), state(1)=>fsm_state_array(13));
	
	-- R7 states
	process(CLK, flush_status)
		variable nfs : fsm_state;
	begin
		
		if fsmstate7 = s0 then
			nfs := s1;
		elsif fsmstate7 = s1 then
			nfs := s3;
		elsif fsmstate7 = s2 then
			nfs := s1;
		else
			nfs := s3;
		end if;
		
		if rising_edge(clk) then
			if flush_status = '1' then
				fsmstate7 <= s3;
			elsif fsm_write(7) = '1' then
				fsmstate7 <= s0;
			else
				fsmstate7 <= nfs;
			end if;
		end if;
		
	end process;
	
	process(fsmstate7)
	begin
		if fsmstate7=s0 then
			fsm_state_array(15 downto 14) <= "11";
		
		elsif fsmstate7=s1 then
			fsm_state_array(15 downto 14) <= "01";
		
		elsif fsmstate7=s2 then
			fsm_state_array(15 downto 14) <= "10";
		
		else
			fsm_state_array(15 downto 14) <= "00";
		end if;
	end process;
	
	-- Carry Flag
	process(CLK)
	begin
		if flush_status = '1' then
			state_c <= '0';
		else
			if (fsmc_write = '1' and (rising_edge(CLK)) and (IR_a(15 downto 13) = "000")) then
				state_c <= '1';
			elsif (rising_edge(CLK)) then
				if state_c = '1' then
					state_c <= '0';
				else
					state_c <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(state_c)
	begin
		flag_c <= state_c;
	end process;

	-- Zero Flag
	process(CLK)
	begin
		if flush_status = '1' then
			state_z <= '0';
		else
			if (fsmz_write = '1' and (rising_edge(CLK)) and ((IR_a(15 downto 13) = "000") 
					or (IR_a(15 downto 12) = "0010") or (IR_a(15 downto 12) = "0100")))then
				state_z <= '1';
			elsif (rising_edge(CLK)) then
				if state_z = '1' then
					state_z <= '0';
				else
					state_z <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(state_z)
	begin
		flag_z <= state_z;
	end process;
	
	-- LMSM Flag
	-- process(CLK)
	-- begin
	--	if flush_status = '1' then
		--	flag_LMSM <= '0';
		--else
			--if IR_a(15 downto 13) = "011" then
				--flag_LMSM <= '1';
			--elsif BM_d = "00000000" then
				--flag_LMSM <= '0';
			--end if;
		--end if;
	--end process;
end status_file_arch;
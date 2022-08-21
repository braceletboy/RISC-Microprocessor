-- The hazard unit takes in the current state_array of the FSM_file
-- The hazard unit controls the flushing and freezing of the pipeline and 
	-- Stalling is present for 
-- The hazard unit operates between edges

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity hazard_unit is
	port(state_array: in std_logic_vector(15 downto 0); IR_a: in std_logic_vector(15 downto 0); 
			eq, flag_c, flag_z: in std_logic; carry, zero: in std_logic;
			BM_d, BM_c: in std_logic_vector(7 downto 0); IR_c, IR_d, IR_e: in std_logic_vector(15 downto 0);
			fsm_write: out std_logic_vector(7 downto 0); fsmc_write, fsmz_write: out std_logic;
			freeze: out std_logic_vector(4 downto 0); flush: out std_logic_vector(4 downto 0); flush_status: out std_logic;
			pc_freeze: out std_logic; stalling: out std_logic; out_flag_LMSM : out std_logic);
end entity;

architecture hazard_unit_arch of hazard_unit is
	signal flag_LMSM : std_logic;
begin
	process(state_array, IR_a, eq, flag_c, flag_z, carry, zero, BM_d, IR_c)
		variable Sa, Sb: std_logic_vector(1 downto 0);
		variable ra, rb, rc: integer;
		variable n_fsm_write : std_logic_vector(7 downto 0);
	begin
	
		n_fsm_write := "00000000";
	
		if flag_LMSM = '1' then
			if ir_d(15 downto 13) = "011" and BM_d = "00000000" then
				flush <= (0 =>'0', 4=>'0', others => '1');
				freeze <= "00000";
				pc_freeze <= '0';
				n_fsm_write := "00000000";
				fsmc_write <= '0';
				fsmz_write <= '0';
				flush_status <= '1';
				stalling <= '0';
				flag_lmsm <= '0';
			elsif ir_c(15 downto 13) = "011" and bm_c = "00000000" then
				flush <= "00100";
				freeze <= "00001";
				pc_freeze <= '0';
				n_fsm_write := "00000000";
				fsmc_write <= '0';
				fsmz_write <= '0';
				flush_status <= '1';
				stalling <= '0';
				flag_lmsm <= '1';
				
			else
				freeze <= "00001";
				pc_freeze <= '0';
				flush <= "00000";
				n_fsm_write := "00000000";
				fsmc_write <= '0';
				fsmz_write <= '0';
				flush_status <= '0';
				stalling <= '1';
				flag_lmsm <= '1';
				
			end if;
		else
				-- LW r7 jump
			if ((IR_d(15 downto 12) = "0100") and (IR_d(11 downto 9) = "111")) then
				flush <= (4=>'0', others => '1');
				flush_status <= '1';
				freeze <= "00000";
				pc_freeze <= '0';
				n_fsm_write := "00000000";
				fsmc_write <= '0';
				fsmz_write <= '0';
				stalling <= '0';
				flush_status <= '0';
				flag_lmsm <= '0';
			else
				-- JAL, JLR jump
				if IR_c(15 downto 13)="100" then
					flush <= (0 => '1', 1=>'1', 2=>'1', others => '0');
					flush_status <= '1';
					freeze <= "00000";
					pc_freeze <= '0';
					n_fsm_write := "00000000";
					fsmc_write <= '0';
					fsmz_write <= '0';
					stalling <= '0';
					flag_lmsm <= '0';
				
				-- BEQ jump
				elsif (IR_c(15 downto 12) = "1100") and eq='1' then
					flush <= (0 => '1', 1=>'1', 2=>'1', others => '0');
					flush_status <= '1';
					freeze <= "00000";
					pc_freeze <= '0';
					n_fsm_write := "00000000";
					fsmc_write <= '0';
					fsmz_write <= '0';
					stalling <= '0';
					flag_lmsm <= '0';
					
				-- alu r7 jump
				elsif ((((IR_c(15 downto 12) = "0000") or (IR_c(15 downto 12) = "0010")) and (IR_c(5 downto 3) = "111")) or
								((IR_c(15 downto 12) = "0001") and (IR_c(8 downto 6) = "111")) or
								((IR_c(15 downto 12) = "0011") and (IR_c(11 downto 9) = "111")))then
					flush <= (0 => '1', 1=>'1', 2=>'1', others => '0');
					flush_status <= '1';
					freeze <= "00000";
					pc_freeze <= '0';
					n_fsm_write := "00000000";
					fsmc_write <= '0';
					fsmz_write <= '0';
					stalling <= '0';
					flag_lmsm <= '0';
				
				-- Instructions
				else
					Sa(0) := state_array(2*to_integer(unsigned(IR_a(11 downto 9))));
					Sa(1) := state_array(2*to_integer(unsigned(IR_a(11 downto 9)))+1);
					Sb(0) := state_array(2*to_integer(unsigned(IR_a(8 downto 6))));
					Sb(1) := state_array(2*to_integer(unsigned(IR_a(8 downto 6)))+1);
					ra := to_integer(unsigned(IR_a(11 downto 9)));
					rb := to_integer(unsigned(IR_a(8 downto 6)));
					rc := to_integer(unsigned(IR_a(5 downto 3)));
					
					-- ADD
					if ((IR_a(15 downto 12) = "0000") and IR_a(1 downto 0) = "00") then
						if (Sa = "11" or Sb = "11") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(rc) := '1';
							n_fsm_write(7) := '1';
							
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- NDU
					elsif ((IR_a(15 downto 12) = "0010") and IR_a(1 downto 0) = "00") then
						if (Sa = "11" or Sb = "11") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(rc) := '1';
							n_fsm_write(7) := '1';
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- SW
					elsif (IR_a(15 downto 12) = "0101") then
						if (Sa /= "00" or Sb = "11") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (7=>'1', others=>'0');
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- BEQ
					elsif (IR_a(15 downto 12) = "1100") then
						if (Sa /= "00" or Sb /= "00") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (7=>'1', others=>'0');
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- LHI
					elsif (IR_a(15 downto 12) = "0011") then
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(ra) := '1';
							n_fsm_write(7) := '1';
							fsmc_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
					

					-- ADI
					elsif (IR_a(15 downto 12) = "0001") then
						if (Sa = "11") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
							
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(rb) := '1';
							n_fsm_write(7) := '1';
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
							
						end if;
					
					-- LM
					elsif (IR_a(15 downto 12) = "0110") then
						if (Sa /= "00") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
							
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (0 => '1', others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others=>'0');
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '1';
							
						end if;
					
					-- SM
					elsif (IR_a(15 downto 12) = "0111") then
						if (Sa /= "00") then
							flush <= (1 =>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
							
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (0 => '1', others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others=>'0');
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '1';
							
						end if;
					
					-- LW
					elsif (IR_a(15 downto 12) = "0100") then
						if (Sb = "11") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(ra) := '1';
							n_fsm_write(7) := '1';
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- JLR
					elsif (IR_a(15 downto 12) = "1001") then
						if (Sb /= "00") then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							flush <= (others=>'0');
							flush_status <= '0';
							freeze <= (others=>'0');
							pc_freeze <= '0';
							n_fsm_write := (others => '0');
							n_fsm_write(ra) := '1';
							n_fsm_write(7) := '1';
							fsmc_write <= '1';
							fsmz_write <= '1';
							stalling <= '0';
							flag_lmsm <= '0';
						end if;
					
					-- ADC
					elsif (IR_a(15 downto 12) = "0000") and (IR_a(1 downto 0) = "10") then
						if flag_c = '1' then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							if(carry = '1') then
								flush(0) <= '0';
								if (Sa = "11" or Sb = "11") then
									flush <= (1=>'1', others=>'0');
									flush_status <= '0';
									freeze <= (0=>'1', others=>'0');
									pc_freeze <= '1';
									n_fsm_write := "00000000";
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '1';
									flag_lmsm <= '0';
								else
									flush <= (others=>'0');
									flush_status <= '0';
									freeze <= (others=>'0');
									pc_freeze <= '0';
									n_fsm_write := (others => '0');
									n_fsm_write(rc) := '1';
									n_fsm_write(7) := '1';
									fsmc_write <= '1';
									fsmz_write <= '1';
									flag_lmsm <= '0';
								end if;
							else
								flush <= (1=> '1', others=>'0');
								flush_status <= '0';
								freeze <= (others=>'0');
								pc_freeze <= '0';
								n_fsm_write := "00000000";
								fsmc_write <= '0';
								fsmz_write <= '0';
								stalling <= '0';
								flag_lmsm <= '0';
							end if;
						end if;
					
					-- NDC
					elsif (IR_a(15 downto 12) = "0010") and (IR_a(1 downto 0) = "10") then
						if flag_c = '1' then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							if(carry = '1') then
								flush(0) <= '0';
								if (Sa = "11" or Sb = "11") then
									flush <= (1=>'1', others=>'0');
									flush_status <= '0';
									freeze <= (0=>'1', others=>'0');
									pc_freeze <= '1';
									n_fsm_write := "00000000";
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '1';
									flag_lmsm <= '0';
								else
									flush <= (others=>'0');
									flush_status <= '0';
									freeze <= (others=>'0');
									pc_freeze <= '0';
									n_fsm_write := (others => '0');
									n_fsm_write(rc) := '1';
									n_fsm_write(7) := '1';
									fsmc_write <= '1';
									fsmz_write <= '1';
									stalling <= '0';
									flag_lmsm <= '0';
								end if;
							else
								flush <= (1=> '1', others=>'0');
								flush_status <= '0';
								freeze <= (others=>'0');
								pc_freeze <= '0';
								n_fsm_write := "00000000";
								fsmc_write <= '0';
								fsmz_write <= '0';
								stalling <= '0';
								flag_lmsm <= '0';
							end if;
						end if;
					
					-- ADZ
					elsif (IR_a(15 downto 12) = "0000") and (IR_a(1 downto 0) = "01") then
						if flag_z = '1' then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							if (Sa = "11" or Sb = "11") then
								if(zero = '1') then
									flush <= (1=>'1', others=>'0');
									flush_status <= '0';
									freeze <= (0=>'1', others=>'0');
									pc_freeze <= '1';
									n_fsm_write := "00000000";
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '1';
									flag_lmsm <= '0';
								else
									flush <= (others=>'0');
									flush_status <= '0';
									freeze <= (others=>'0');
									pc_freeze <= '0';
									n_fsm_write := (others => '0');
									n_fsm_write(rc) := '1';
									n_fsm_write(7) := '1';
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '0';
									flag_lmsm <= '0';
								end if;
							else
								if(zero = '1') then
									flush <= "00000";
									flush_status <= '0';
									freeze <= "00000";
									pc_freeze <= '0';
									n_fsm_write := "00000000";
									fsmc_write <= '1';
									fsmz_write <= '1';
									stalling <= '1';
									flag_lmsm <= '0';
								else
									flush <= (1 => '1', others=>'0');
									flush_status <= '0';
									freeze <= (others=>'0');
									pc_freeze <= '0';
									n_fsm_write := (others => '0');
									n_fsm_write(rc) := '1';
									n_fsm_write(7) := '1';
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '0';
									flag_lmsm <= '0';
								end if;
							end if;
						end if;
					
					-- NDZ
					elsif (IR_a(15 downto 12) = "0010") and (IR_a(1 downto 0) = "01") then
						if flag_z = '1' then
							flush <= (1=>'1', others=>'0');
							flush_status <= '0';
							freeze <= (0=>'1', others=>'0');
							pc_freeze <= '1';
							n_fsm_write := "00000000";
							fsmc_write <= '0';
							fsmz_write <= '0';
							stalling <= '1';
							flag_lmsm <= '0';
						else
							if(zero = '1') then
								if (Sa = "11" or Sb = "11") then
									flush <= (1=>'1', others=>'0');
									flush_status <= '0';
									freeze <= (0=>'1', others=>'0');
									pc_freeze <= '1';
									n_fsm_write := "00000000";
									fsmc_write <= '0';
									fsmz_write <= '0';
									stalling <= '1';
									flag_lmsm <= '0';
								else
									flush <= (others=>'0');
									flush_status <= '0';
									freeze <= (others=>'0');
									pc_freeze <= '0';
									n_fsm_write := (others => '0');
									n_fsm_write(rc) := '1';
									n_fsm_write(7) := '1';
									fsmc_write <= '1';
									fsmz_write <= '1';
									stalling <= '0';
									flag_lmsm <= '0';
								end if;
							else
								flush <= (1=> '1', others=>'0');
								freeze <= (others=>'0');
								pc_freeze <= '0';
								n_fsm_write := "00000000";
								fsmc_write <= '0';
								fsmz_write <= '0';
								stalling <= '0';
								flag_lmsm <= '0';
							end if;
						end if;
					
					-- JAL
					elsif (IR_a(15 downto 12) = "1000") then
						flush <= (others => '0');
						flush_status <= '0';
						freeze <= (others => '0');
						pc_freeze <= '0';
						n_fsm_write := (others => '0');
						n_fsm_write(ra) := '1';
						n_fsm_write(7) := '1';
						fsmc_write <= '1';
						fsmz_write <= '1';
						flag_lmsm <= '0';
					
					-- NOP
					else 
						freeze <= "00000";
						flush <= "00000";
						flush_status <= '0';
						pc_freeze <= '0';
						n_fsm_write := "00000000";
						fsmc_write <= '0';
						fsmz_write <= '0';
						stalling <= '0';
						flag_lmsm <= '0';
						flag_lmsm <= '0';
					end if;
				end if;
			end if;
		end if;
		
		fsm_write <= n_fsm_write;
		
	end process;
	
	out_flag_lmsm <= flag_lmsm;
end hazard_unit_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity Controller is
	port(
		
		--Program Counter
		pc_write : out std_logic;
		pc_in : out std_logic_vector(1 downto 0);
		
		--Instruction Register
		ir_write : out std_logic;
		
		--Memory write and read
		mem_write : out std_logic;
		mem_addr : out std_logic_vector(1 downto 0);
		mem_din : out std_logic;
		
		--Register File
		reg_write : out std_logic;
		rf_a1_in : out std_logic_vector(1 downto 0);
		rf_a3_in : out std_logic_vector(2 downto 0);
		rf_d3_in : out std_logic_vector(2 downto 0);
		
		--ALU
		alu_a_in : out std_logic_vector(1 downto 0);
		alu_b_in : out std_logic_vector(1 downto 0);
		op_select : out std_logic_vector(1 downto 0);
		
		--Temporary Registers
		t1_in : out std_logic_vector(1 downto 0);
		t2_in : out std_logic_vector(2 downto 0);
		t3_in : out std_logic;
		t1_write : out std_logic;
		t2_write : out std_logic;
		t3_write : out std_logic;
		

		carry : in std_logic;
		zero : in std_logic;
		equal : in std_logic;

		instr : in std_logic_vector(15 downto 0);
		t3 : in std_logic_vector(2 downto 0);
		
		clk : in std_logic;
		reset : in std_logic;
		stateVal : out integer
		
	);
end entity;

architecture Behave of Controller is
	type state is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, 
	s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24);
	
	signal curState : state;
	
begin

	process(instr, clk, reset, carry, zero, equal)
		variable newState : state;
		variable tmpState : integer := 0;
	begin
		case curState is
			when s0 =>
				newState := s1;
				tmpState := 1;
			when s1 =>
				newState := s2;
				tmpState := 2;
			when s2 =>
				newState := s3;
				tmpState := 3;
			when s3 =>
				if instr(15 downto 12) = "0000" then
					if instr(1 downto 0) = "00" or (instr(1 downto 0) = "10" and carry = '1') or (instr(1 downto 0) = "01" and zero = '1') then
						newState := s4;
						tmpState := 4;
					else
						newState := s1;
						tmpState := 1;
					end if;
				elsif instr(15 downto 12) = "0001" then
					newState := s6;
					tmpState := 6;
				elsif instr(15 downto 12) = "0010" then
					if instr(1 downto 0) = "00" or (instr(1 downto 0) = "10" and carry = '1') or (instr(1 downto 0) = "01" and zero = '1') then
						newState := s4;
						tmpState := 4;
					else
						newState := s1;
						tmpState := 1;
					end if;
				elsif instr(15 downto 0) = "0011" then
					newState := s8;
					tmpState := 8;
				elsif instr(15 downto 12) = "0100" then
					newState := s9;
					tmpState := 9;
				elsif instr(15 downto 12) = "0101" then
					newState := s12;
					tmpState := 12;
				elsif instr(15 downto 12) = "1000" then
					newState := s15;
					tmpState := 15;
				elsif instr(15 downto 12) = "1001" then
					newState := s16;
					tmpState := 16;
				elsif instr(15 downto 12) = "0111" or instr(15 downto 12) = "0110" then
					newState := s18;
					tmpState := 18;
				elsif instr(15 downto 12) = "1100" then
					newState := s4;
					tmpState := 4;
				end if;
			when s4 =>
				if instr(15 downto 12) = "0000" or instr(15 downto 12) = "0010" then
					newState := s5;
					tmpState := 5;
				elsif instr(15 downto 12) = "0001" then
					newState := s7;
					tmpState := 7;
				elsif instr(15 downto 12) = "1100" then
					if equal = '1' then
						newState := s14;
						tmpState := 14;
					else
						newState := s1;
						tmpState := 1;
					end if;
				end if;
			when s5 =>
				newState := s1;
				tmpState := 1;
			when s6 =>
				newState := s4;
				tmpState := 4;
			when s7 =>
				newState := s1;
				tmpState := 1;
			when s8 =>
				newState := s1;
				tmpState := 1;
			when s9 =>
				newState := s10;
				tmpState := 10;
			when s10 =>
				newState := s11;
				tmpState := 11;
			when s11 =>
				newState := s1;
				tmpState := 1;
			when s12 =>
				newState := s13;
				tmpState := 13;
			when s13 =>
				newState := s1;
				tmpState := 1;
			when s14 =>
				newState := s17;
				tmpState := 17;
			when s15 =>
				newState := s17;
				tmpState := 17;
			when s16 =>
				newState := s17;
				tmpState := 17;
			when s17 =>
				newState := s1;
				tmpState := 1;
			when s18 =>
				if instr(15 downto 12) = "0111" then
					newState := s22;
					tmpState := 22;
				else
					newState := s19;
					tmpState := 19;
				end if;
			when s19 =>
				if instr(to_integer(unsigned(t3))) = '1' then
					newState := s20;
					tmpState := 20;
				else
					newState := s24;
					tmpState := 24;
				end if;
			when s20 =>
				newState := s24;
				tmpState := 24;
			when s21 =>
				newState := s19;
				tmpState := 19;
			when s22 =>
				if instr(to_integer(unsigned(t3))) = '1' then
					newState := s23;
					tmpState := 23;
				else
					newState := s24;
					tmpState := 24;
				end if;
			when s23 =>
				newState := s24;
				tmpState := 24;
			when s24 =>
				if t3 = "111" then
					newState := s1;
					tmpState := 1;
				else
					newState := s21;
					tmpState := 21;
				end if;
			when others =>
				newState := s1;
				tmpState := 1;
		end case;
		
		if reset = '1' then
			curState <= s0;
			stateVal <= 0;
		elsif clk'event and clk = '1' then
			curState <= newState;
			stateVal <= tmpState;
		end if;
			
	end process;
	
	process(reset, curState)
		
		variable n_pc_write : std_logic;
		variable n_pc_in : std_logic_vector(1 downto 0);
		variable n_ir_write : std_logic;
		variable n_mem_write : std_logic;
		variable n_mem_addr : std_logic_vector(1 downto 0);
		variable n_mem_din : std_logic;
		variable n_reg_write : std_logic;
		variable n_rf_a1_in : std_logic_vector(1 downto 0);
		variable n_rf_a3_in : std_logic_vector(2 downto 0);
		variable n_rf_d3_in : std_logic_vector(2 downto 0);
		variable n_alu_a_in : std_logic_vector(1 downto 0);
		variable n_alu_b_in : std_logic_vector(1 downto 0);
		variable n_op_select : std_logic_vector(1 downto 0);
		variable n_t1_in : std_logic_vector(1 downto 0);
		variable n_t2_in : std_logic_vector(2 downto 0);
		variable n_t3_in : std_logic;
		variable n_t1_write : std_logic;
		variable n_t2_write : std_logic;
		variable n_t3_write : std_logic;
		
	begin
		
		case curState is
			when s0 =>
				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
			
			when s1 =>
				n_pc_write := '1';
				n_pc_in := "01";
				n_rf_a1_in := "00";

				-----------------
				
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
			
			when s2 =>
				n_mem_addr := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "11";
				n_pc_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "100";
				n_pc_write := '1';
				n_ir_write := '1';
				n_reg_write := '1';
				n_op_select := "11";
				
				-----------------
				
				n_mem_write := '0';
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
		
			when s3 =>
				n_rf_a1_in := "10";
				n_t1_in := "10";
				n_t2_in := "000";
				n_t1_write := '1';
				n_t2_write := '1';

				-----------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t3_in := '0';
				n_t3_write := '0';
				
			when s4 =>
				n_t1_in := "00";
				n_alu_a_in := "01";
				n_alu_b_in := "01";
				n_t1_write := '1';
				
				if instr(15 downto 12) = "0000" or instr(15 downto 12) = "0001" then
					n_op_select := "00";
				elsif instr(15 downto 12) = "0010" then
					n_op_select := "01";
				elsif instr(15 downto 12) = "1100" then
					n_op_select := "10";
				else
					n_op_select := "11";
				end if;
					

				-----------------

				n_pc_write := '0';
				n_reg_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
			when s5 =>
				n_rf_a3_in := "100";
				n_rf_d3_in := "010";
				n_reg_write := '1';
				
				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s6 =>
				n_t2_in := "100";
				n_t2_write := '1';
				
				-----------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t3_write := '0';
				
				
			when s7 =>
				n_rf_a3_in := "011";
				n_rf_d3_in := "010";
				n_reg_write := '1';

				--------------------
				
				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s8 =>
				n_rf_a3_in := "010";
				n_rf_d3_in := "001";
				n_reg_write := '1';
				
				---------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s9 =>
				n_t1_in := "00";
				n_alu_a_in := "10";
				n_alu_b_in := "01";
				n_t1_write := '1';
				n_op_select := "11";

				--------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s10 =>
				n_mem_addr := "10";
				n_t1_in := "01";
				n_t1_write := '1';

				-----------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
			when s11 =>
				
				n_rf_a3_in := "010";
				n_rf_d3_in := "010";
				n_reg_write := '1';

				------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s12 =>
				n_t2_in := "010";
				n_alu_a_in := "10";
				n_alu_b_in := "01";
				n_t2_write := '1';
				n_op_select := "11";

				-------------------
				
				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_t1_in := "00";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t3_write := '0';
				
				
			when s13 =>
				n_mem_addr := "01";
				n_mem_din := '0';
				n_mem_write := '1';

				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s14 =>
				n_pc_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_pc_write := '1';
				n_op_select := "11";

				------------------
				
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s15 =>
				n_pc_in := "00";
				n_rf_a3_in := "010";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "10";
				n_pc_write := '1';
				n_reg_write := '1';
				n_op_select := "11";

				-------------------
				
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
				
			when s16 =>
				n_pc_in := "10";
				n_rf_a3_in := "010";
				n_rf_d3_in := "000";
				n_pc_write := '1';
				n_reg_write := '1';

				-------------------

				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
				
			when s17 =>
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_reg_write := '1';

				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
								
			when s18 =>
				n_t3_in := '0';
				n_rf_a1_in := "10";
				n_t1_in := "10";
				n_t1_write := '1';
				n_t3_write := '1';

				------------------
				
				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t2_in := "000";
				n_t2_write := '0';


			when s19 =>
				n_mem_addr := "10";
				n_t2_in := "011";
				n_t2_write := '1';

				------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t3_write := '0';


			when s20 =>
				n_rf_a3_in := "001";
				n_rf_d3_in := "011";
				n_t1_in := "00";
				n_alu_a_in := "01";
				n_alu_b_in := "11";
				n_reg_write := '1';
				n_t1_write := '1';
				n_op_select := "11";

				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_rf_a1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t2_write := '0';
				n_t3_write := '0';


			when s21 =>
				n_t3_in := '1';
				n_t3_write := '1';
				
				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t1_write := '0';
				n_t2_write := '0';
				

			when s22 =>
				n_rf_a1_in := "01";
				n_t2_in := "001";
				n_t2_write := '1';

				-------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t3_write := '0';


			when s23 =>
				n_mem_addr := "10";
				n_mem_din := '1';
				n_t1_in := "00";
				n_alu_a_in := "01";
				n_alu_b_in := "11";
				n_mem_write := '1';
				n_t1_write := '1';
				n_op_select := "11";
				
				------------------

				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t2_write := '0';
				n_t3_write := '0';


			when s24 =>
				n_pc_write := '0';
				n_pc_in := "00";
				n_ir_write := '0';
				n_mem_write := '0';
				n_mem_addr := "00";
				n_mem_din := '0';
				n_reg_write := '0';
				n_rf_a1_in := "00";
				n_rf_a3_in := "000";
				n_rf_d3_in := "000";
				n_alu_a_in := "00";
				n_alu_b_in := "00";
				n_op_select := "11";
				n_t1_in := "00";
				n_t2_in := "000";
				n_t3_in := '0';
				n_t1_write := '0';
				n_t2_write := '0';
				n_t3_write := '0';
		end case;

		if reset = '1' then
			pc_write <= '0';
			pc_in <= "00";
			ir_write <= '0';
			mem_write <= '0';
			mem_addr <= "00";
			mem_din <= '0';
			reg_write <= '0';
			rf_a1_in <= "00";
			rf_a3_in <= "000";
			rf_d3_in <= "000";
			alu_a_in <= "00";
			alu_b_in <= "00";
			op_select <= "00";
			t1_in <= "00";
			t2_in <= "000";
			t3_in <= '0';
			t1_write <= '0';
			t2_Write <= '0';
			t3_write <= '0';
		else 
			pc_write <= n_pc_write;
			pc_in <= n_pc_in;
			ir_write <= n_ir_write;
			mem_write <= n_mem_write;
			mem_addr <= n_mem_addr;
			mem_din <= n_mem_din;
			reg_write <= n_reg_write;
			rf_a1_in <= n_rf_a1_in;
			rf_a3_in <= n_rf_a3_in;
			rf_d3_in <= n_rf_d3_in;
			alu_a_in <= n_alu_a_in;
			alu_b_in <= n_alu_b_in;
			op_select <= n_op_select;
			t1_in <= n_t1_in;
			t2_in <= n_t2_in;
			t3_in <= n_t3_in;
			t1_write <= n_t1_write;
			t2_Write <= n_t2_write;
			t3_write <= n_t3_write;
		end if;
	end process;
	
end Behave;
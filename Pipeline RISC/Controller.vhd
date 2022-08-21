library ieee;
use ieee.std_logic_1164.all;

entity Controller is
	port(
		ir : in std_logic_vector(15 downto 0);
		-- EX control signals out
		pc_in, alu_a_in, alu_b_in, alu_op : out std_logic_vector(1 downto 0);
		ao_d_in, bm_c_in, r1_c_in : out std_logic;	
		-- MM control signals out
		rf_a2_in ,mem_addr_in ,mem_din_in, r7_write ,mem_write ,ao_e_in : out std_logic;
		r7_din_in : out std_logic_vector(1 downto 0);		
		-- WB control signals out
		rf_a3_in : out std_logic_vector(1 downto 0);
		rf_d3_in ,reg_write : out std_logic
	);
end entity;

architecture Behave of Controller is
begin

	process(ir)
	begin
		if ir(15 downto 12) = "0000" then --ADX
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "10";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "00";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '1';
			
		elsif ir(15 downto 12) = "0010" then --NDX
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "10";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "01";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '1';
		
		elsif ir(15 downto 12) = "0001" then -- ADI
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "10";
			alu_b_in <= "01";
			ao_d_in <= '1';
			alu_op <= "00";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "01";
			rf_d3_in <= '0';
			reg_write <= '1';
		
		elsif ir(15 downto 12) = "0011" then --LHI
		
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "00";
			ao_d_in <= '0';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "10";
			rf_d3_in <= '0';
			reg_write <= '1';
		
		elsif ir(15 downto 12) = "0100" then --LW
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "01";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "00";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '1';
			
			-- WB
			rf_a3_in <= "10";
			rf_d3_in <= '0';
			reg_write <= '1';
			
		elsif ir(15 downto 12) = "0101" then --SW
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "01";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '1';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '1';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '0';
			
		elsif ir(15 downto 12) = "0110" then --LM
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '1';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '1';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '1';
			
			-- WB
			rf_a3_in <= "11";
			rf_d3_in <= '0';
			reg_write <= '1';
			
		elsif ir(15 downto 12) = "0111" then --SM
		
			-- EX
			pc_in <= "00";
			bm_c_in <= '1';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '1';
			mem_addr_in <= '1';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '1';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '0';
		
		elsif ir(15 downto 12) = "1100" then --BEQ
		
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "01";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "10";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '0';
		
		elsif ir(15 downto 12) = "1000" then --JAL
			
			-- EX
			pc_in <= "01";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "10";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "01";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "10";
			rf_d3_in <= '1';
			reg_write <= '1';
			
		elsif ir(15 downto 12) = "1001" then --JLR
			
			-- EX
			pc_in <= "10";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "00";
			ao_d_in <= '1';
			alu_op <= "10";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "00";
			r7_write <= '1';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "10";
			rf_d3_in <= '1';
			reg_write <= '1';
		else
			
			-- EX
			pc_in <= "00";
			bm_c_in <= '0';
			r1_c_in <= '0';
			alu_a_in <= "00";
			alu_b_in <= "00";
			ao_d_in <= '0';
			alu_op <= "00";
			
			-- MM
			rf_a2_in <= '0';
			mem_addr_in <= '0';
			mem_din_in <= '0';
			r7_din_in <= "00";
			r7_write <= '0';
			mem_write <= '0';
			ao_e_in <= '0';
			
			-- WB
			rf_a3_in <= "00";
			rf_d3_in <= '0';
			reg_write <= '0';
			
		end if;
		
	end process;

end Behave;
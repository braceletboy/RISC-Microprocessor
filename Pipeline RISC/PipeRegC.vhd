library ieee;
use ieee.std_logic_1164.all;

entity PipeRegC is
	port(
		clk, flush, freeze : in std_logic;
		
		pc_c_din, ir_c_din, ipc_c_din, r1_c_din,r2_c_din : in std_logic_vector(15 downto 0);
		bm_c_din : in std_logic_vector(7 downto 0);
		
		pc_c_dout, ir_c_dout, ipc_c_dout,r1_c_dout, r2_c_dout : out std_logic_vector(15 downto 0);
		bm_c_dout : out std_logic_vector(7 downto 0);
		-- EX control signals in
		pc_in_din, alu_a_in_din, alu_b_in_din, alu_op_din : in std_logic_vector(1 downto 0);
		bm_c_in_din, r1_c_in_din, ao_d_in_din: in std_logic;
		-- MM control signals in
		rf_a2_in_din, mem_addr_in_din, mem_din_in_din, r7_write_din, mem_write_din, ao_e_in_din : in std_logic;
		r7_din_in_din : in std_logic_vector(1 downto 0);
		-- WB control signals in
		rf_a3_in_din : in std_logic_vector(1 downto 0);
		rf_d3_in_din, reg_write_din : in std_logic;
		
		alu_af_in_din, alu_bf_in_din : in std_logic_vector(1 downto 0);
		
		-- EX control signals out
		pc_in_dout,alu_a_in_dout, alu_b_in_dout, alu_op_dout : out std_logic_vector(1 downto 0);
		bm_c_in_dout, r1_c_in_dout, ao_d_in_dout : out std_logic;
		-- MM control signals out
		rf_a2_in_dout, mem_addr_in_dout, mem_din_in_dout, r7_write_dout, mem_write_dout, ao_e_in_dout : out std_logic;		
		r7_din_in_dout : out std_logic_vector(1 downto 0);
		-- WB control signals out
		rf_a3_in_dout : out std_logic_vector(1 downto 0);
		rf_d3_in_dout, reg_write_dout : out std_logic;
		
		alu_af_in_dout, alu_bf_in_dout : out std_logic_vector(1 downto 0)
	);
end entity;

architecture Behave of PipeRegC is
	
	signal pc_c : std_logic_vector(15 downto 0);
	signal ir_c : std_logic_vector(15 downto 0);
	signal ipc_c : std_logic_vector(15 downto 0);
	signal bm_c : std_logic_vector(7 downto 0);
	signal r1_c : std_logic_vector(15 downto 0);
	signal r2_c : std_logic_vector(15 downto 0);
	
	-- EX control signals
	signal pc_in : std_logic_vector(1 downto 0);
	signal bm_c_in : std_logic;
	signal r1_c_in : std_logic;	
	signal alu_a_in : std_logic_vector(1 downto 0);
	signal alu_b_in : std_logic_vector(1 downto 0);
	signal ao_d_in : std_logic;
	signal alu_op : std_logic_vector(1 downto 0);
	
	-- MM control signals
	signal rf_a2_in : std_logic;
	signal mem_addr_in : std_logic;
	signal mem_din_in : std_logic;
	signal r7_din_in : std_logic_vector(1 downto 0);
	signal r7_write : std_logic;
	signal mem_write : std_logic;
	signal ao_e_in : std_logic;
	
	-- WB control signals
	signal rf_a3_in : std_logic_vector(1 downto 0);
	signal rf_d3_in : std_logic;
	signal reg_write : std_logic;
	
	signal alu_af_in : std_logic_vector(1 downto 0);
	signal alu_bf_in : std_logic_vector(1 downto 0);
	
begin

	process(clk, flush, freeze)
	begin
		
		if clk'event and clk = '1' then
			if flush = '1' then
				
				pc_c <= (others => '0');
				ir_c <= (others => '1');
				ipc_c <= (others => '0');
				bm_c <= (others => '0');
				r1_c <= (others => '0');
				r2_c <= (others => '0');
				
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
				
				--WB
				rf_a3_in <= "00";
				rf_d3_in <= '0';
				reg_write <= '0';
				
				alu_af_in <= "00";
				alu_bf_in <= "00";
				
			elsif freeze = '0' then
			
				pc_c <= pc_c_din;
				ir_c <= ir_c_din;
				ipc_c <= ipc_c_din;
				bm_c <= bm_C_din;
				r1_c <= r1_C_din;
				r2_c <= r2_C_din;
				
				-- EX
				pc_in <= pc_in_din;
				bm_c_in <= bm_c_in_din;
				r1_c_in <= r1_c_in_din;
				alu_a_in <= alu_a_in_din;
				alu_b_in <= alu_b_in_din;
				ao_d_in <= ao_d_in_din;
				alu_op <= alu_op_din;
				
				-- MM
				rf_a2_in <= rf_a2_in_din;
				mem_addr_in <= mem_addr_in_din;
				mem_din_in <= mem_din_in_din;
				r7_din_in <= r7_din_in_din;
				r7_write <= r7_write_din;
				mem_write <= mem_write_din;
				ao_e_in <= ao_e_in_din;
				
				-- WB
				rf_a3_in <= rf_a3_in_din;
				rf_d3_in <= rf_d3_in_din;
				reg_write <= reg_write_din;
				
				alu_af_in <= alu_af_in_din;
				alu_bf_in <= alu_bf_in_din;
			
			end if;
		end if;
			
		
	end process;
	
	pc_c_dout <= pc_c;
	ir_c_dout <= ir_c;
	ipc_c_dout <= ipc_c;
	bm_c_dout <= bm_c;
	r1_c_dout <= r1_c;
	r2_c_dout <= r2_c;
	
	-- EX	
	pc_in_dout <= pc_in;
	bm_c_in_dout <= bm_c_in;
	r1_c_in_dout <= r1_c_in;
	alu_a_in_dout <= alu_a_in;
	alu_b_in_dout <= alu_b_in;
	ao_d_in_dout <= ao_d_in;
	alu_op_dout <= alu_op;
	
	-- MM
	rf_a2_in_dout <= rf_a2_in;
	mem_addr_in_dout <= mem_addr_in;
	mem_din_in_dout <= mem_din_in;
	r7_din_in_dout <= r7_din_in;
	r7_write_dout <= r7_write;
	mem_write_dout <= mem_write;
	ao_e_in_dout <= ao_e_in;
	
	-- WB
	rf_a3_in_dout <= rf_a3_in;
	rf_d3_in_dout <= rf_d3_in;
	reg_write_dout <= reg_write;
	
	alu_af_in_dout <= alu_af_in;
	alu_bf_in_dout <= alu_bf_in;

end Behave;
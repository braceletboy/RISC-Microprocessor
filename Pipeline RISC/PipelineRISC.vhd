library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity PipelineRISC is
	port(
		clk : in std_logic;
		nrst : in std_logic;
		clk_50 : in std_logic;
		r0, r1, r2, r3, r4, r5, r6, r7 : out std_logic_vector(15 downto 0)
	);
end entity;

architecture Behave of PipelineRISC is

component PC is
	port(
		clk : in std_logic;
		flush : in std_logic;
		freeze : in std_logic;
	
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end component;

component Adder is
	port(
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end component;

component Mux4 is
	generic(n : integer := 16);
	port(
		data_in0, data_in1, data_in2, data_in3 : in std_logic_vector(n-1 downto 0) := (others => '0');
		input_select : in std_logic_vector(1 downto 0) := (others => '0');
		data_out : out std_logic_vector(n-1 downto 0)
	);
end component;

component Mux2 is
	generic(n : integer := 16);
	port(
		data_in0, data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
		input_select : in std_logic := '0';
		data_out : out std_logic_vector(n-1 downto 0)
	);
end component;

component InstrMem is 
	port(
		addr : in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(15 downto 0)
		);
end component;

component PipeRegA is
	port(
		clk, flush, freeze : in std_logic;
		pc_a_din, ir_a_din, ipc_a_din : in std_logic_vector(15 downto 0);
		pc_a_dout, ir_a_dout, ipc_a_dout: out std_logic_vector(15 downto 0)
	);
end component;

component PipeRegB is
	port(
		clk, flush, freeze : in std_logic;
		pc_b_din, ir_b_din, ipc_b_din : in std_logic_vector(15 downto 0);
		pc_b_dout, ir_b_dout, ipc_b_dout : out std_logic_vector(15 downto 0);
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
		
		alu_af_in_dout : out std_logic_vector(1 downto 0);
		alu_bf_in_dout : out std_logic_vector(1 downto 0)
	);
end component;

component Controller is
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
end component;

component RegFile is
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
end component;

component forwarding_unit is
	port(flag_LMSM: in std_logic; IR_a, IR_c, IR_d, state_array: in std_logic_vector(15 downto 0); pcf_in, alu_af_in, alu_bf_in: out std_logic_vector(1 downto 0));
end component;

component BitRem is
	port(
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
end component;

component PipeRegC is
	port(
		clk, flush, freeze : in std_logic;
		
		pc_c_din, ir_c_din, ipc_c_din, r1_c_din,r2_c_din : in std_logic_vector(15 downto 0);
		bm_c_din : in std_logic_vector(7 downto 0);
		
		pc_c_dout, ir_c_dout, ipc_c_dout, r1_c_dout, r2_c_dout : out std_logic_vector(15 downto 0);
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
end component;

component PipeRegD is
	port(
		clk, flush, freeze : in std_logic;
		
		pc_d_din, ir_d_din, ipc_d_din, r1_d_din, r2_d_din, ao_d_din : in std_logic_vector(15 downto 0);
		bm_d_din : in std_logic_vector(7 downto 0);
		
		pc_d_dout, ir_d_dout, ipc_d_dout, r1_d_dout, r2_d_dout, ao_d_dout : out std_logic_vector(15 downto 0);
		bm_d_dout : out std_logic_vector(7 downto 0);
		-- MM control signals in
		rf_a2_in_din, mem_addr_in_din, mem_din_in_din, r7_write_din, mem_write_din, ao_e_in_din : in std_logic;
		r7_din_in_din : in std_logic_vector(1 downto 0);
		-- WB control signals in
		rf_a3_in_din : in std_logic_vector(1 downto 0);
		rf_d3_in_din, reg_write_din : in std_logic;
		
		-- MM control signals out
		rf_a2_in_dout, mem_addr_in_dout, mem_din_in_dout, r7_write_dout, mem_write_dout, ao_e_in_dout : out std_logic;		
		r7_din_in_dout : out std_logic_vector(1 downto 0);
		-- WB control signals out
		rf_a3_in_dout : out std_logic_vector(1 downto 0);
		rf_d3_in_dout, reg_write_dout : out std_logic
	);
end component;

component ALU is
	port(
		alu_a, alu_b : in std_logic_vector(15 downto 0) := "0000000000000000";
		alu_op :in std_logic_vector(1 downto 0);
		alu_out : out std_logic_vector(15 downto 0); 
		zero, carry : out std_logic
	);
end component;

component Padder is
	port (
		data_in : in std_logic_vector(8 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end component;

component DataMem is 
	port(
		clk, reset, mem_write: in std_logic;
		
		addr, data_in : in std_logic_vector(15 downto 0); 
		data_out: out std_logic_vector(15 downto 0)
		);
end component;

component priority_encoder is
	port(BM_d: in std_logic_vector(7 downto 0); priority_bits: out std_logic_vector(2 downto 0));
end component;

component PipeRegE is
	port(
		clk, flush, freeze : in std_logic;
		
		pc_e_din, ir_e_din, ao_e_din : in std_logic_vector(15 downto 0);
		bm_e_din : in std_logic_vector(7 downto 0);
		
		pc_e_dout, ir_e_dout, ao_e_dout : out std_logic_vector(15 downto 0);
		bm_e_dout : out std_logic_vector(7 downto 0);
		-- WB control signals in
		rf_a3_in_din : in std_logic_vector(1 downto 0);
		rf_d3_in_din, reg_write_din : in std_logic;
		
		-- WB control signals out
		rf_a3_in_dout : out std_logic_vector(1 downto 0);
		rf_d3_in_dout, reg_write_dout : out std_logic
	);
end component;

component Equal is
	port(
		eq_a : in std_logic_vector(15 downto 0);
		eq_b : in std_logic_vector(15 downto 0);
		eq : out std_logic
	);
end component;

component hazard_unit is
	port(state_array: in std_logic_vector(15 downto 0); IR_a: in std_logic_vector(15 downto 0); 
			eq, flag_c, flag_z: in std_logic; carry, zero: in std_logic;
			BM_d, BM_c: in std_logic_vector(7 downto 0); IR_c, IR_d, IR_e: in std_logic_vector(15 downto 0);
			fsm_write: out std_logic_vector(7 downto 0); fsmc_write, fsmz_write: out std_logic;
			freeze: out std_logic_vector(4 downto 0); flush: out std_logic_vector(4 downto 0); flush_status: out std_logic;
			pc_freeze: out std_logic; stalling: out std_logic; out_flag_LMSM : out std_logic);
end component;

component status_file is
	port(CLK: in std_logic; fsm_write: in std_logic_vector(7 downto 0); IR_a: in std_logic_vector(15 downto 0);
			BM_d: in std_logic_vector(7 downto 0); fsmc_write, fsmz_write: in std_logic; flush_status: in std_logic;
			flag_c, flag_z: out std_logic; fsm_state_array: out std_logic_vector(15 downto 0));
end component;

component SignExtender1 is
	port (
		data_in : in std_logic_vector(5 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end component;

component SignExtender2 is
	port (
		data_in : in std_logic_vector(8 downto 0);
		data_out : out std_logic_vector(15 downto 0)
	);
end component;
	
	-- EX control signals
	signal pc_in, pc_in_a, pc_in_b, pc_in_tmp : std_logic_vector(1 downto 0);
	signal bm_c_in, bm_c_in_a, bm_c_in_b, bm_c_in_tmp : std_logic;
	signal r1_c_in, r1_c_in_a, r1_c_in_b, r1_c_in_tmp : std_logic;	
	signal alu_a_in, alu_a_in_a, alu_a_in_b : std_logic_vector(1 downto 0);
	signal alu_b_in, alu_b_in_a, alu_b_in_b : std_logic_vector(1 downto 0);
	signal ao_d_in, ao_d_in_a, ao_d_in_b : std_logic;
	signal alu_op, alu_op_a, alu_op_b : std_logic_vector(1 downto 0);
	-- MM control signals
	signal rf_a2_in, rf_a2_in_a, rf_a2_in_b, rf_a2_in_c : std_logic;
	signal mem_addr_in, mem_addr_in_a, mem_addr_in_b, mem_addr_in_c : std_logic;
	signal mem_din_in, mem_din_in_a, mem_din_in_b, mem_din_in_c : std_logic;
	signal r7_din_in, r7_din_in_a, r7_din_in_b, r7_din_in_c, r7_din_in_tmp : std_logic_vector(1 downto 0);
	signal r7_write, r7_write_a, r7_write_b, r7_write_c : std_logic;
	signal mem_write, mem_write_a, mem_write_b, mem_write_c : std_logic;
	signal ao_e_in, ao_e_in_a, ao_e_in_b, ao_e_in_c : std_logic;
	-- WB control signals
	signal rf_a3_in, rf_a3_in_a, rf_a3_in_b, rf_a3_in_c, rf_a3_in_d : std_logic_vector(1 downto 0);
	signal rf_d3_in, rf_d3_in_a, rf_d3_in_b, rf_d3_in_c, rf_d3_in_d : std_logic;
	signal reg_write, reg_write_a, reg_write_b, reg_write_c, reg_write_d : std_logic;

	
	
	signal reset : std_logic;
	signal pc_freeze, flag_LMSM, zero, carry, eq, eq_p, flag_c, flag_z, flush_status, flush_status_tmp, stalling: std_logic;
	signal flush, flush_tmp, freeze : std_logic_vector(4 downto 0);
	signal pcf_in, alu_af_in_a, alu_af_in_b, alu_af_in, alu_bf_in_a, alu_bf_in_b, alu_bf_in: std_logic_vector(1 downto 0);
	signal pc_out, state_array : std_logic_vector(15 downto 0);
	signal mux1_in0, mux1_in1, mux1_in2, mux1_in3, mux1_out : std_logic_vector(15 downto 0);
	signal mux2_in0, mux2_in1, mux2_out : std_logic_vector(2 downto 0);
	signal mux3_in0, mux3_in1, mux3_out : std_logic_vector(7 downto 0);
	signal mux4_in0, mux4_in1, mux4_out : std_logic_vector(15 downto 0);
	signal mux5_in0, mux5_in1, mux5_in2, mux5_in3, mux5_out : std_logic_vector(15 downto 0);
	signal mux6_in0, mux6_in1, mux6_in2, mux6_in3, mux6_out : std_logic_vector(15 downto 0);
	signal mux7_in0, mux7_in1, mux7_out : std_logic_vector(15 downto 0);
	signal mux8_in0, mux8_in1, mux8_out : std_logic_vector(15 downto 0);
	signal mux9_in0, mux9_in1, mux9_out : std_logic_vector(15 downto 0);
	signal mux10_in0, mux10_in1, mux10_in2, mux10_in3, mux10_out : std_logic_vector(2 downto 0);
	signal mux11_in0, mux11_in1, mux11_out : std_logic_vector(15 downto 0);
	signal mux12_in0, mux12_in1, mux12_in2, mux12_in3, mux12_out : std_logic_vector(15 downto 0);
	signal mux13_in0, mux13_in1, mux13_out : std_logic_vector(15 downto 0);
	signal fmux1_in0, fmux1_in1, fmux1_in2, fmux1_in3, fmux1_out : std_logic_vector(15 downto 0);
	signal fmux2_in0, fmux2_in1, fmux2_in2, fmux2_in3, fmux2_out : std_logic_vector(15 downto 0);
	signal fmux3_in0, fmux3_in1, fmux3_in2, fmux3_in3, fmux3_out : std_logic_vector(15 downto 0);
	signal pc_a, ir_a, ipc_a : std_logic_vector(15 downto 0); 
	signal pc_b, ir_b, ipc_b : std_logic_vector(15 downto 0);
	signal pc_c, ir_c, ipc_c, r1_c, r2_c: std_logic_vector(15 downto 0);
	signal pc_d, ir_d, ipc_d, r1_d, r2_d, ao_d : std_logic_vector(15 downto 0);
	signal pc_e, ir_e, ao_e : std_logic_vector(15 downto 0);
	signal bm_c, bm_d, bm_e : std_logic_vector(7 downto 0);
	signal im_out : std_logic_vector(15 downto 0);
	signal adder1_out, adder2_out, alu_out, padder_out, se1_out, se2_out, mem_dout: std_logic_vector(15 downto 0); 
	signal rf_d1, rf_d2 : std_logic_vector(15 downto 0);
	signal r7_data: std_logic_vector(15 downto 0);
	signal prienc1_out, prienc2_out : std_logic_vector(2 downto 0);
	signal fsm_write, bitrem_out : std_logic_vector(7 downto 0);
	signal fsmc_write, fsmz_write : std_logic;
	
begin

	flush(0) <= flush_tmp(0) or reset;
	flush(1) <= flush_tmp(1) or reset;
	flush(2) <= flush_tmp(2) or reset;
	flush(3) <= flush_tmp(3) or reset;
	flush(4) <= flush_tmp(4) or reset;
	
	hdu : hazard_unit port map(state_array, ir_a, eq, flag_c, flag_z, carry, zero,
										bm_d, bm_c, ir_c, ir_d, ir_e, fsm_write, fsmc_write, fsmz_write,
										freeze, flush_tmp, flush_status_tmp, pc_freeze, stalling,flag_LMSM);
										
	flush_status <= flush_status_tmp or reset;
										
	stfile : status_file port map(clk, fsm_write, ir_a, bm_d, fsmc_write, fsmz_write, flush_status,	flag_c, flag_z, state_array);
	
	pc_reg : PC port map(clk => clk, flush => reset, freeze => pc_freeze, data_in => fmux1_out, data_out => pc_out);
	mx1 : Mux4 generic map(16) port map(mux1_in0, mux1_in1, mux1_in2, mux1_in3, pc_in, mux1_out);
	mux1_in0 <= adder1_out;
	mux1_in1 <= alu_out;
	mux1_in2 <= r2_c;
	mux1_in3 <= r2_c;
	
	fmx1 : Mux4 generic map(16) port map(fmux1_in0, fmux1_in1, fmux1_in2, fmux1_in3, pcf_in, fmux1_out);
	fmux1_in0 <= mux1_out;
	fmux1_in1 <= alu_out;
	fmux1_in2 <= r7_data;
	fmux1_in3 <= mem_dout;
	
	adder1 : Adder port map(data_in => pc_out, data_out => adder1_out);
	im : InstrMem port map(pc_out, im_out);
	
	pipe_a : PipeRegA port map(clk, flush(0), freeze(0), pc_out, im_out, adder1_out, pc_a, ir_a, ipc_a);
	ctrl : Controller port map(ir_a, pc_in_a, alu_a_in_a, alu_b_in_a, alu_op_a, ao_d_in_a, bm_c_in_a, r1_c_in_a,
										rf_a2_in_a, mem_addr_in_a, mem_din_in_a, r7_write_a, mem_write_a ,ao_e_in_a, r7_din_in_a, 
										rf_a3_in_a, rf_d3_in_a, reg_write_a);
	fwd_unit : forwarding_unit port map(flag_LMSM, ir_a, ir_b, ir_c, state_array, pcf_in, alu_af_in_a, alu_bf_in_a);
	
	pipe_b : PipeRegB port map(clk, flush(1), freeze(1), pc_a, ir_a, ipc_a,	pc_b, ir_b, ipc_b,
										pc_in_a, alu_a_in_a, alu_b_in_a, alu_op_a, bm_c_in_a, r1_c_in_a, ao_d_in_a,
										rf_a2_in_a, mem_addr_in_a, mem_din_in_a, r7_write_a, mem_write_a, ao_e_in_a, r7_din_in_a,
										rf_a3_in_a, rf_d3_in_a, reg_write_a,
										alu_af_in_a, alu_bf_in_a,
										pc_in_b, alu_a_in_b, alu_b_in_b, alu_op_b, bm_c_in_b, r1_c_in_b, ao_d_in_b,
										rf_a2_in_b, mem_addr_in_b, mem_din_in_b, r7_write_b, mem_write_b, ao_e_in_b, r7_din_in_b,
										rf_a3_in_b, rf_d3_in_b, reg_write_b,
										alu_af_in_b, alu_bf_in_b);
	mx2 : Mux2 generic map(3) port map(mux2_in0, mux2_in1, rf_a2_in, mux2_out);
	mux2_in0 <= ir_b(8 downto 6);
	mux2_in1 <= prienc1_out;
	
	mx10 : Mux4 generic map(3) port map(mux10_in0, mux10_in1, mux10_in2, mux10_in3, rf_a3_in, mux10_out);
	mux10_in0 <= ir_e(5 downto 3);
	mux10_in1 <= ir_e(8 downto 6);
	mux10_in2 <= ir_e(11 downto 9);
	mux10_in3 <= prienc2_out;
	
	mx4 : Mux2 generic map(16) port map(mux4_in0, mux4_in1, r1_c_in, mux4_out);
	mux4_in1 <= adder2_out;
	mux4_in0 <= rf_d1;
	
	mx11 : Mux2 generic map(16) port map(mux11_in0, mux11_in1, rf_d3_in, mux11_out);
	mux11_in0 <= ao_e;
	mux11_in1 <= pc_e;
	
	mx12 : Mux4 generic map(16) port map(mux12_in0, mux12_in1, mux12_in2, mux12_in3, r7_din_in, mux12_out);
	mux12_in0 <= r2_d;
	mux12_in1 <= ao_d;
	mux12_in2 <= ipc_d;
	mux12_in3 <= ipc_d;
	
	mx3 : Mux2 generic map(8) port map(mux3_in0, mux3_in1, bm_c_in, mux3_out);
	mux3_in0 <= ir_b(7 downto 0);
	mux3_in1 <= bitrem_out;
	
	reg_file : RegFile port map(clk, reset, reg_write, r7_write, ir_a(11 downto 9), mux2_out, mux10_out, rf_d1, rf_d2, mux11_out, mux12_out, r7_data,
										r0, r1, r2, r3, r4, r5, r6, r7);
	
	btrm : BitRem port map(bm_c, bitrem_out);
	adder2 : Adder port map(r1_c, adder2_out);
	
	pipe_c : PipeRegC port map(clk, flush(2), freeze(2), pc_b, ir_b, ipc_b, mux4_out, rf_d2, mux3_out,
										pc_c, ir_c, ipc_c, r1_c, r2_c, bm_c,
										pc_in_b, alu_a_in_b, alu_b_in_b, alu_op_b, bm_c_in_b, r1_c_in_b, ao_d_in_b,
										rf_a2_in_b, mem_addr_in_b, mem_din_in_b, r7_write_b, mem_write_b, ao_e_in_b, r7_din_in_b,
										rf_a3_in_b, rf_d3_in_b, reg_write_b,
										alu_af_in_b, alu_bf_in_b,
										pc_in_tmp, alu_a_in, alu_b_in, alu_op, bm_c_in_tmp, r1_c_in_tmp, ao_d_in,
										rf_a2_in_c, mem_addr_in_c, mem_din_in_c, r7_write_c, mem_write_c, ao_e_in_c, r7_din_in_c,
										rf_a3_in_c, rf_d3_in_c, reg_write_c,
										alu_af_in, alu_bf_in);
	
	process(ir_c, bm_c_in_tmp)
	begin
		if ir_c(15 downto 13) = "011" then
			bm_c_in <= '1';
		else
			bm_c_in <= bm_c_in_tmp;
		end if;
	end process;
	
	process(ir_c, r1_c_in_tmp)
	begin
		if ir_c(15 downto 13) = "011" then
			r1_c_in <= '1';
		else
			r1_c_in <= r1_c_in_tmp;
		end if;
	end process;
	
	process(ir_c, eq, pc_in_tmp)
	begin
		
		if ir_c(15 downto 12) = "1100" and eq = '1' then
			pc_in <= "01";
		else
			pc_in <= pc_in_tmp;
		end if;
		
	end process;
	
	process(clk)
	begin
		
		if rising_edge(clk) then
			eq_p <= eq;
		end if;
		
	end process;
	
	mx5 : Mux4 generic map(16) port map(mux5_in0, mux5_in1, mux5_in2, mux5_in3, alu_a_in, mux5_out);
	mux5_in0 <= pc_c;
	mux5_in1 <= se1_out;
	mux5_in2 <= r1_c;
	mux5_in3 <= r1_c;
	
	mx6 : Mux4 generic map(16) port map(mux6_in0, mux6_in1, mux6_in2, mux6_in3, alu_b_in, mux6_out);
	mux6_in0 <= r2_c;
	mux6_in1 <= se1_out;
	mux6_in2 <= se2_out;
	mux6_in3 <= se2_out;
	
	fmx2 : Mux4 generic map(16) port map(fmux2_in0, fmux2_in1, fmux2_in2, fmux2_in3, alu_af_in, fmux2_out);
	fmux2_in0 <= mux5_out;
	fmux2_in1 <= ao_d;
	fmux2_in2 <= ao_e;
	fmux2_in3 <= ao_e;
	
	fmx3 : Mux4 generic map(16) port map(fmux3_in0, fmux3_in1, fmux3_in2, fmux3_in3, alu_bf_in, fmux3_out);
	fmux3_in0 <= mux6_out;
	fmux3_in1 <= ao_d;
	fmux3_in2 <= ao_e;
	fmux3_in3 <= ao_e;
	
	alu_unit : ALU port map(fmux2_out, fmux3_out, alu_op, alu_out, zero, carry);
	
	padder_unit : Padder port map(ir_c(8 downto 0), padder_out);
	
	se1 : SignExtender1 port map(ir_c(5 downto 0), se1_out);
	se2 : SignExtender2 port map(ir_c(8 downto 0), se2_out);
	
	mx7 : Mux2 generic map(16) port map(mux7_in0, mux7_in1, ao_d_in, mux7_out);
	mux7_in0 <= padder_out;
	mux7_in1 <= alu_out;
	
	eqCheck : Equal port map(r1_c, r2_c, eq);
	
	pipe_d : PipeRegD port map(clk, flush(3), freeze(3),
										pc_c, ir_c, ipc_c, r1_c, r2_c, mux7_out, bm_c,
										pc_d, ir_d, ipc_d, r1_d, r2_d, ao_d, bm_d,
										rf_a2_in_c, mem_addr_in_c, mem_din_in_c, r7_write_c, mem_write_c, ao_e_in_c, r7_din_in_c,
										rf_a3_in_c, rf_d3_in_c, reg_write_c,
										rf_a2_in, mem_addr_in, mem_din_in, r7_write, mem_write, ao_e_in, r7_din_in_tmp,
										rf_a3_in_d, rf_d3_in_d, reg_write_d);
										
	process(ir_d, r7_din_in_tmp, eq)
	begin
		
		if ir_d(15 downto 12) = "1100" then
			if eq_p = '1' then
				r7_din_in <= "01";
			else
				r7_din_in <= "10";
			end if;
		else
			r7_din_in <= r7_din_in_tmp;
		end if;
		
	end process;
	
	mx8 : Mux2 generic map(16) port map(mux8_in0, mux8_in1, mem_addr_in, mux8_out);
	mux8_in0 <= ao_d;
	mux8_in1 <= r1_d;
	
	mx9 : Mux2 generic map(16) port map(mux9_in0, mux9_in1, mem_din_in, mux9_out);
	mux9_in0 <= rf_d2;
	mux9_in1 <= r1_d;
	
	dmem : DataMem port map(clk, reset, mem_write, mux8_out, mux9_out, mem_dout);
	prienc1 : priority_encoder port map(bm_d, prienc1_out);
	
	mx13 : Mux2 generic map(16) port map(mux13_in0, mux13_in1, ao_e_in, mux13_out);
	mux13_in0 <= ao_d;
	mux13_in1 <= mem_dout;
	
	pipe_e : PipeRegE port map(clk, flush(4), freeze(4),
										pc_d, ir_d, mux13_out, bm_d,
										pc_e, ir_e, ao_e, bm_e,
										rf_a3_in_d, rf_d3_in_d, reg_write_d,
										rf_a3_in, rf_d3_in, reg_write);
	
	prienc2 : priority_encoder port map(bm_e, prienc2_out);
	
	reset <= not nrst;
end Behave;
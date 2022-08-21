library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;

entity TopLevel is
	port(
		clk, nreset : in std_logic
	);
end entity;


architecture Behave of TopLevel is

	component Mux2 is
		generic(n : integer := 16);
		port(
			data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
			input_select : in std_logic := '0';
			data_out : out std_logic_vector(n-1 downto 0)
		);
	end component;

	component Mux4 is
		generic(n : integer := 16);
		port(
			data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in2 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in3 : in std_logic_vector(n-1 downto 0) := (others => '0');
			input_select : in std_logic_vector(1 downto 0) := (others => '0');
			data_out : out std_logic_vector(n-1 downto 0)
		);
	end component;

	component Mux8 is
		generic(n : integer := 16);
		port(
			data_in0 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in1 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in2 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in3 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in4 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in5 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in6 : in std_logic_vector(n-1 downto 0) := (others => '0');
			data_in7 : in std_logic_vector(n-1 downto 0) := (others => '0');
			input_select : in std_logic_vector(2 downto 0) := (others => '0');
			data_out : out std_logic_vector(n-1 downto 0)
		);
	end component;

	component SignExtender6 is
		port (
			data_in : in std_logic_vector(5 downto 0);
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;

	component Register3 is
		port(
			data_in : in std_logic_vector(2 downto 0);
			clk : in std_logic;
			reset : in std_logic;
			reg_write : in std_logic;
			data_out : out std_logic_vector(2 downto 0)
		);
	end component;

	component Register16 is
		port(
			data_in : in std_logic_vector(15 downto 0);
			clk : in std_logic;
			reset : in std_logic;
			reg_write : in std_logic;
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;

	component SignExtender9 is
		port (
			data_in : in std_logic_vector(8 downto 0);
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;

	component Padder is
		port (
			data_in : in std_logic_vector(8 downto 0);
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;

	component ALU is
		port(
			data_a,data_b: in std_logic_vector(15 downto 0) := "0000000000000000";
			opSelect:in std_logic_vector(1 downto 0);
			output: out std_logic_vector(15 downto 0); 
			z,c,eq: out std_logic
		);
	end component;

	component RegFile is
		port(
			a1,a2,a3: in std_logic_vector(2 downto 0);
			d3: in std_logic_vector(15 downto 0);
			d1,d2: out std_logic_vector(15 downto 0);
			reset: in std_logic;
			CLK, regWrite: in std_logic;
			r0, r1, r2, r3, r4, r5, r6, r7: out std_logic_vector(15 downto 0)
			);
	end component;

	component Memory is 
		port(addr, data_in: in std_logic_vector(15 downto 0); 
				data_out: out std_logic_vector(15 downto 0); 
				reset : in std_logic;
				CLK, memWrite: in std_logic
			);
	end component;

	component INC is
		port(input: in std_logic_vector(2 downto 0); output: out std_logic_vector(2 downto 0));
	end component;

	component Controller is
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
	end component;
	
	signal reset : std_logic;
	signal pc_write : std_logic;
	signal pc_in : std_logic_vector(1 downto 0);
	signal ir_write : std_logic;	
	signal mem_write : std_logic;
	signal mem_addr : std_logic_vector(1 downto 0);
	signal mem_din : std_logic;
	signal reg_write : std_logic;
	signal rf_a1_in : std_logic_vector(1 downto 0);
	signal rf_a3_in : std_logic_vector(2 downto 0);
	signal rf_d3_in : std_logic_vector(2 downto 0);
	signal alu_a_in : std_logic_vector(1 downto 0);
	signal alu_b_in : std_logic_vector(1 downto 0);
	signal op_select : std_logic_vector(1 downto 0);
	signal t1_in : std_logic_vector(1 downto 0);
	signal t2_in : std_logic_vector(2 downto 0);
	signal t3_in : std_logic;
	signal t1_write : std_logic;
	signal t2_write : std_logic;
	signal t3_write : std_logic;
	signal carry : std_logic;
	signal zero : std_logic;
	signal equal : std_logic;
	signal t3 : std_logic_vector(2 downto 0);
	signal stateVal : integer;

	signal pc_reg_in, pc_reg_out: std_logic_vector(15 downto 0);
	signal ir_reg_in, ir_reg_out: std_logic_vector(15 downto 0);
	signal t1_reg_in, t1_reg_out: std_logic_vector(15 downto 0);
	signal t2_reg_in, t2_reg_out: std_logic_vector(15 downto 0);
	signal t3_reg_in, t3_reg_out, inc_out: std_logic_vector(2 downto 0);
	signal mem_blk_addr_in, mem_blk_data_in, mem_blk_data_out: std_logic_vector(15 downto 0);
	signal padder_out, se1_out, se2_out : std_logic_vector(15 downto 0);
	signal alu_a, alu_b, alu_out: std_logic_vector(15 downto 0);
	signal reg_a1, reg_a2, reg_a3 : std_logic_vector(2 downto 0);
	signal reg_d1, reg_d2, reg_d3 : std_logic_vector(15 downto 0);
	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0);

begin
	
	reset <= not nreset;
	
	ControlStore : Controller port map(
		pc_write => pc_write,
		pc_in => pc_in,
		ir_write => ir_write,
		mem_write => mem_write,
		mem_addr => mem_addr,
		mem_din => mem_din,
		reg_write => reg_write,
		rf_a1_in => rf_a1_in,
		rf_a3_in => rf_a3_in,
		rf_d3_in => rf_d3_in,
		alu_a_in => alu_a_in,
		alu_b_in => alu_b_in,
		op_select => op_select,
		t1_in => t1_in,
		t2_in => t2_in,
		t3_in => t3_in,
		t1_write => t1_write,
		t2_write => t2_write,
		t3_write => t3_write,
		carry => carry,
		zero => zero,
		equal => equal,
		instr => ir_reg_out,
		t3 => t3,
		clk => clk,
		reset => reset,
		stateVal => stateVal
	);

	PC : Register16 port map (
		data_in => pc_reg_in,
		clk => clk,
		reset => reset,
		reg_write => pc_write,
		data_out => pc_reg_out
	);

	IR : Register16 port map (
		data_in => ir_reg_in,
		clk => clk,
		reset => reset,
		reg_write => ir_write,
		data_out => ir_reg_out
	);

	tempReg1 : Register16 port map (
		data_in => t1_reg_in,
		clk => clk,
		reset => reset,
		reg_write => t1_write,
		data_out => t1_reg_out
	);

	tempReg2 : Register16 port map (
		data_in => t2_reg_in,
		clk => clk,
		reset => reset,
		reg_write => t2_write,
		data_out => t2_reg_out
	);

	tempReg3 : Register3 port map (
		data_in => t3_reg_in,
		clk => clk,
		reset => reset,
		reg_write => t3_write,
		data_out => t3_reg_out
	);

	incrementer : INC port map(
		input => t3_reg_out,
		output => inc_out
	);

	MemoryBlock : Memory port map(
		addr => mem_blk_addr_in,
		data_in => mem_blk_data_in,
		data_out => mem_blk_data_out,
		CLK => clk,
		reset => reset,
		memWrite => mem_write
	);

	PadderBlock : Padder port map(
		data_in => ir_reg_out(8 downto 0),
		data_out => padder_out
	);

	SignExtender1 : SignExtender6 port map(
		data_in => ir_reg_out(5 downto 0),
		data_out => se1_out
	);

	SignExtender2 : SignExtender9 port map(
		data_in => ir_reg_out(8 downto 0),
		data_out => se2_out
	);

	aluBlock : ALU port map(
		data_a => alu_a,
		data_b => alu_b,
		opSelect => op_select,
		output => alu_out,
		z => zero,
		c => carry,
		eq => equal
	);

	registerFile : RegFile port map(
		a1 => reg_a1,
		a2 => reg_a2,
		a3 => reg_a3,
		d1 => reg_d1,
		d2 => reg_d2,
		d3 => reg_d3,
		reset => reset,
		CLK => clk,
		regWrite => reg_write,
		r0 => r0,
		r1 => r1,
		r2 => r2,
		r3 => r3,
		r4 => r4,
		r5 => r5,
		r6 => r6,
		r7 => r7
	);

	pc_mux : Mux4 generic map(16) port map(
		data_in0 => alu_out,
		data_in1 => reg_d1,
		data_in2 => t2_reg_out,
		data_in3 => t2_reg_out,
		data_out => pc_reg_in,
		input_select => pc_in
	);

	mem_addr_mux : Mux4 generic map(16) port map(
		data_in0 => pc_reg_out,
		data_in1 => t2_reg_out,
		data_in2 => t1_reg_out,
		data_in3 => t1_reg_out,
		data_out => mem_blk_addr_in,
		input_select => mem_addr
	);

	rfa3in_mux : Mux8 generic map(3) port map(
		data_in0 => "111",
		data_in1 => t3_reg_out,
		data_in2 => ir_reg_out(11 downto 9),
		data_in3 => ir_reg_out(8 downto 6),
		data_in4 => ir_reg_out(5 downto 3),
		data_in5 => ir_reg_out(5 downto 3),
		data_in6 => ir_reg_out(5 downto 3),
		data_in7 => ir_reg_out(5 downto 3),
		data_out => reg_a3,
		input_select => rf_a3_in
	);

	rfd3in_mux : Mux8 generic map(16) port map(
		data_in0 => pc_reg_out,
		data_in1 => padder_out,
		data_in2 => t1_reg_out,
		data_in3 => t2_reg_out,
		data_in4 => alu_out,
		data_in5 => alu_out,
		data_in6 => alu_out,
		data_in7 => alu_out,
		data_out => reg_d3,
		input_select => rf_d3_in
	);

	t3in_mux : Mux2 generic map(3) port map(
		data_in0 => "000",
		data_in1 => inc_out,
		input_select => t3_in,
		data_out => t3_reg_in
	);

	aluain_mux : Mux4 generic map(16) port map(
		data_in0 => pc_reg_out,
		data_in1 => t1_reg_out,
		data_in2 => se1_out,
		data_in3 => se1_out,
		data_out => alu_a,
		input_select => alu_a_in
	);

	memdin_mux : Mux2 generic map(16) port map(
		data_in0 => t1_reg_out,
		data_in1 => t2_reg_out,
		input_select => mem_din,
		data_out => mem_blk_data_in
	);

	rfa1in_mux : Mux4 generic map(3) port map(
		data_in0 => "111",
		data_in1 => t3_reg_out,
		data_in2 => ir_reg_out(11 downto 9),
		data_in3 => ir_reg_out(11 downto 9),
		data_out => reg_a1,
		input_select => rf_a1_in
	);

	t1in_mux : Mux4 generic map(16) port map(
		data_in0 => alu_out,
		data_in1 => mem_blk_data_out,
		data_in2 => reg_d1,
		data_in3 => reg_d1,
		data_out => t1_reg_in,
		input_select => t1_in
	);

	t2in_mux : Mux8 generic map(16) port map(
		data_in0 => reg_d2,
		data_in1 => reg_d1,
		data_in2 => alu_out,
		data_in3 => mem_blk_data_out,
		data_in4 => se1_out,
		data_in5 => se1_out,
		data_in6 => se1_out,
		data_in7 => se1_out,
		data_out => t2_reg_in,
		input_select => t2_in
	);

	alubin_mux : Mux4 generic map(16) port map(
		data_in0 => se1_out,
		data_in1 => t2_reg_out,
		data_in2 => se2_out,
		data_in3 => "0000000000000001",
		input_select => alu_b_in,
		data_out => alu_b
	);
	
	t3 <= t3_reg_out;
	reg_a2 <= ir_reg_out(8 downto 6);
	ir_reg_in <= mem_blk_data_out;
	
end Behave;
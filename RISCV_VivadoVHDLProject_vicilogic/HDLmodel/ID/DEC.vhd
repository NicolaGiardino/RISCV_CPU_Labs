library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DEC is
	Port( instruction : in std_logic_vector(31 downto 0);
			branch		: in std_logic;								--when the instruction is branch, if it is equal, then branch, w/ jal and jalr branch
			extImm		: out std_logic_vector(31 downto 0);	--OK
			rs1			: out std_logic_vector(4 downto 0);		--OK
			rs2			: out std_logic_vector(4 downto 0);		--OK
			RWr			: out std_logic;								--OK
			rd				: out std_logic_vector(4 downto 0);		--OK
			selPCSrc		: out std_logic;								
			jalr			: out std_logic;
			auipc			: out std_logic;
			selALUBSrc  : out std_logic;
			selALUOp		: out std_logic_vector(3 downto 0);
			selDToM		: out std_logic_vector(1 downto 0);
			MWr			: out std_logic;
			MRd			: out std_logic;
			selDFrM		: out std_logic_vector(2 downto 0);
			selWBD		: out std_logic_vector(1 downto 0)
			);
end DEC;

architecture combinational of DEC is

signal opCode	: std_logic_vector(6 downto 0);
signal f7		: std_logic_vector(6 downto 0);
signal f3		: std_logic_vector(2 downto 0);
signal dec_bits : std_logic_vector(10 downto 0);
signal out_bits : std_logic_vector(17 downto 0);
signal is_u_instr, is_r_instr, is_b_instr, is_s_instr, is_i_instr, is_j_instr : std_logic;
signal rs1_valid, rs2_valid, rd_valid : std_logic;

begin

instr_type_i: process(instruction)
begin
	opCode <= instruction(6 downto 0);
	if opCode(6 downto 2) = "00101" then
		is_u_instr <= '1';
	else 
		is_u_instr 	<='0';
	end if;
	
	if ((opCode(6 downto 4) = "011" and opCode(2) = '0') or opCode(6 downto 2) = "01011" or opCode(6 downto 2) = "10100") then
		is_r_instr <= '1';
	else 
		is_r_instr <= '0';
	end if;
	
	if opCode(6 downto 2) = "11000" then
		is_b_instr <= '1';
	else 
		is_b_instr <= '0';
	end if;
	
	if (opCode(6 downto 2) = "01000" or opCode(6 downto 2) = "01001") then
		is_s_instr <= '1';
	else 
		is_s_instr <= '0';
	end if;
	
	if (opCode(6 downto 3) = "0000" or (opCode(6 downto 4) = "001" and opCode(2) = '0') or opCode(6 downto 2) = "11001") then
		is_i_instr <= '1';
	else 
		is_i_instr <= '0';
	end if;
	
	if opCOde(6 downto 2) = "11011" then
		is_j_instr <= '1';
	else 
		is_j_instr <= '0';
	end if;
end process;

valid_i : process(is_i_instr, is_r_instr, is_b_instr, is_s_instr, is_u_instr, is_j_instr)
begin
	if (is_i_instr = '1' or is_r_instr = '1' or is_b_instr = '1' or is_s_instr = '1') then
		rs1_valid <= '1';
	else 
		rs1_valid <= '0';
	end if;
	
	if (is_r_instr = '1' or is_b_instr = '1' or is_s_instr = '1') then
		rs2_valid <= '1';
	else 
		rs2_valid <= '0';
	end if;
	
	if (is_i_instr = '1' or is_r_instr = '1' or is_u_instr = '1' or is_j_instr = '1') then
		rd_valid  <= '1';
	else 
		rd_valid  <= '0';
	end if;

	if is_r_instr = '0' then
		if is_i_instr = '1' then
			if instruction(31) = '1' then
				extImm <= (31 downto 11 => '1') & instruction(30 downto 20);
			else 
				extImm <= (31 downto 11 => '0') & instruction(30 downto 20);
			end if;
			
		elsif is_s_instr = '1' then
			if instruction(31) = '1' then
				extImm <= (31 downto 11 => '1') & instruction(30 downto 25) & instruction(11 downto 7);
			else 
				extImm <= (31 downto 11 => '0') & instruction(30 downto 25) & instruction(11 downto 7);
			end if;
			
		elsif is_b_instr = '1' then
			if instruction(31) = '1' then
				extImm <= (31 downto 12 => '1') & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';	
			else 
				extImm <= (31 downto 12 => '0') & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';	
			end if;
			
		elsif is_u_instr = '1' then
			extImm <= instruction(31 downto 12) & (11 downto 0 => '0');
			
		elsif is_j_instr = '1'  then
			if instruction(31) = '1' then
				extImm <= (31 downto 20 => '1') & instruction(19 downto 12) & instruction(20) & instruction(30 downto 25) & instruction(24 downto 21) & '0';
			else 
				extImm <= (31 downto 20 => '0') & instruction(19 downto 12) & instruction(20) & instruction(30 downto 25) & instruction(24 downto 21) & '0';
			end if;
			
		else
			extImm 	<= (others => '0');
		end if;
	else
		extImm 	<= (others => '0');
	end if;
end process;

reg_i : process(rs1_valid, rs2_valid, rd_valid)
begin
    if rs1_valid = '1' then
		rs1 <= instruction(19 downto 15);
	else 
		rs1 <= (others => '0');
	end if;
	
	if rs2_valid = '1' then 
		rs2 <= instruction(24 downto 20);
	else
		rs2 <= (others => '0');
	end if;
	
	if rd_valid = '1' then
		rd	<= instruction(11 downto 7);
	else
		rd <= (others => '0');
	end if;
end process;

out_bits_i : process(is_i_instr, is_r_instr, is_b_instr, is_s_instr, is_u_instr, is_j_instr)
begin
	if (is_r_instr = '1' or (is_i_instr = '1' and instruction(31 downto 25) = "0100000" and instruction(14 downto 12) = "101" and instruction(6 downto 0) = "0010011")) then
		f7 <= instruction(31 downto 25); 
	else 
		f7 <= (others => '0');
	end if;
	
	if (is_r_instr = '1' or is_i_instr = '1' or is_s_instr = '1' or is_b_instr = '1') then
		f3	<= instruction(14 downto 12);
	else
		f3 <= (others => '0');
	end if;
end process;

dec_bits_i: dec_bits <= f7(5) & f3(2 downto 0) & instruction(6 downto 0);

DEC_i : process(dec_bits)
begin
	-- Processing instructions by assigning to out reg
	-- out_bits <= RWr & selWBD(2) & selDFrM(3) & MRd & MWr & selDToM(2) & selALUOp(4) & selALUBSrc & auipc & jalr & selPCSrc
	if(is_u_instr = '1' or is_j_instr = '1') then
	   case dec_bits(6 downto 0) is
		  -- U-Type Instructions
		  when "0110111" =>	--LUI
	   		  out_bits <= (others => '0');
		  when "0010111" => --AUIPC
			 out_bits <= (17 downto 4 => '0') & "010" & '0';
		  -- J-Type Instructions
		  when "1101111" => --JAL
			 out_bits <= '0' & "10" & (14 downto 1 => '0') & '1';
		  when others =>
			 out_bits <= (others => '0');
		end case;
		elsif (is_i_instr = '1' or is_b_instr = '1' or is_s_instr = '1') then
		  case dec_bits(9 downto 0) is
		      -- I-Type Instruction
		      when "0001100111" => --JALR
			     out_bits <= '1' & '1' & (15 downto 2 => '0') & "11";
		      -- B-Type Instructions
		      when "0001100011" => --BEQ
			     out_bits <= (17 downto 8 => '0') & "1010" & "100" & branch;
		      when "0011100011" => --BNE
			     out_bits <= (17 downto 8 => '0') & "1011" & "100" & branch;
		      when "1001100011" => --BLT
			     out_bits <= (17 downto 8 => '0') & "1100" & "100" & branch;
		      when "1011100011" => --BGE
			     out_bits <= (17 downto 8 => '0') & "1101" & "100" & branch;
		      when "1101100011" => --BLTU
			     out_bits <= (17 downto 8 => '0') & "1110" & "100" & branch;
		      when "1111100011" => --BGEU
			     out_bits <= (17 downto 8 => '0') & "1111" & "100" & branch;
		      -- I-Type Instructions
		      when "0000000011"	=> --LB
			     out_bits <= '0' & "01" & "010" & '1' & '0' & (9 downto 0 => '0');
		      when "0010000011" => --LH
			     out_bits <= '0' & "01" & "001" & '1' & '0' & (9 downto 0 => '0');
		      when "0100000011" => --LW
			     out_bits <= '0' & "01" & "000" & '1' & '0' & (9 downto 0 => '0');
		      when "1000000011" => --LBU
			     out_bits <= '0' & "01" & "100" & '1' & '0' & (9 downto 0 => '0');
		      when "1100000011" => --LWU
			     out_bits <= '0' & "01" & "011" & '1' & '0' & (9 downto 0 => '0');
		      when "0000010011" => --ADDI
			     out_bits <= '1' & (16 downto 0 => '0');
		      when "0100010011" => --SLTI
			     out_bits <= '1' & (16 downto 8 => '0') & "0001" & "000" & '0';
		      when "0110010011" => --SLTIU
			     out_bits <= '1' & (16 downto 8 => '0') & "1001" & "000" & '0';
		      when "1000010011" => --XORI
			     out_bits <= '1' & (16 downto 8 => '0') & "0100" & "000" & '0';
		      when "1100010011" => --ORI
			     out_bits <= '1' & (16 downto 8 => '0') & "0011" & "000" & '0';
		      when "1110010011" => --ANDI
			     out_bits <= '1' & (16 downto 8 => '0') & "0010" & "000" & '0';
		      -- S-Type Instructions
		      when "0000100011" => --SB
			     out_bits <= '1' & "00" & "000" & '0' & '1' & "10" & (7 downto 0 => '0');
		      when "0010100011" => --SH
			     out_bits <= '1' & "00" & "000" & '0' & '1' & "01" & (7 downto 0 => '0');
		      when "0100100011" => --SW
			     out_bits <= '1' & "00" & "000" & '0' & '1' & "00" & (7 downto 0 => '0');
		     when others =>
			     out_bits <= (others => '0');
		  end case;
		 else
		  case dec_bits is
		      when "00010010011" => --SLLI
			     out_bits <= '1' & (16 downto 8 => '0') & "0101" & "000" & '0';
		      when "01010010011" => --SRLI
			     out_bits <= '1' & (16 downto 8 => '0') & "0110" & "000" & '0';
		      when "11010010011" => --SRAI
			     out_bits <= '1' & (16 downto 8 => '0') & "0111" & "000" & '0';
		      -- R-Type Instructions
		      when "00000110011" => --ADD
			     out_bits <= '1' & (16 downto 8 => '0') & "0000" & "100" & '0';
		      when "10000110011" => --SUB
		      	 out_bits <= '1' & (16 downto 8 => '0') & "0001" & "100" & '0';
		      when "00010110011" => --SLL
			     out_bits <= '1' & (16 downto 8 => '0') & "0101" & "100" & '0';
		      when "00100110011" => --SLT
			     out_bits <= '1' & (16 downto 8 => '0') & "1000" & "100" & '0';
		      when "00110110011" => --SLTU
			     out_bits <= '1' & (16 downto 8 => '0') & "1001" & "100" & '0';
		      when "01000110011" => --XOR
			     out_bits <= '1' & (16 downto 8 => '0') & "0100" & "100" & '0';
		      when "01010110011" => --SRL
			     out_bits <= '1' & (16 downto 8 => '0') & "0110" & "100" & '0';
		      when "11010110011" => --SRA
			     out_bits <= '1' & (16 downto 8 => '0') & "0111" & "100" & '0';
		      when "01100110011" => --OR
			     out_bits <= '1' & (16 downto 8 => '0') & "0011" & "100" & '0';
 		     when "01110110011" => --AND
			     out_bits <= '1' & (16 downto 8 => '0') & "0010" & "100" & '0';
		     when others =>
			     out_bits <= (others => '0');
	       end case;
	  end if;
end process;

assign_i: process(out_bits)
begin
	-- out_bits <= selWBD(2) & selDFrM(3) & MRd & MWr & selDToM(2) & selALUOp(4) & selALUBSrc & auipc & jalr & selPCSrc
	selWBD 		<= out_bits(16 downto 15);
	selDFrM 		<= out_bits(14 downto 12);
	MRd			<= out_bits(11);
	MWr			<= out_bits(10);
	selDToM 		<= out_bits(9 downto 8);
	selALUOp		<= out_bits(7 downto 4);
	selALUBSrc	<= out_bits(3);
	auipc			<= out_bits(2);
	jalr 			<= out_bits(1);
	selPCSrc		<= out_bits(0);
		
	RWr <= out_bits(17);
	
end process;

end combinational;
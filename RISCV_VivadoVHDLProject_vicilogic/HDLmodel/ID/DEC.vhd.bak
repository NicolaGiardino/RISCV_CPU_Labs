-- Engineer: Fearghal Morgan 
-- National University of Ireland Galway
-- 
-- Module Name: DEC
-- Description: Instruction Decoder Module for the RISC-V Processor

-- Signal dictionary

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DEC is
  Port (instruction        : in  std_logic_vector(31 downto 0);
        branch             : in  std_logic;
		extImm             : out std_logic_vector(31 downto 0);
		rs1                : out std_logic_vector( 4 downto 0);
		rs2                : out std_logic_vector( 4 downto 0);
		RWr                : out std_logic;
		rd                 : out std_logic_vector( 4 downto 0);
		selPCSrc           : out std_logic;
		jalr               : out std_logic;
		auipc              : out std_logic;
		selALUBSrc         : out std_logic;
		selALUOp           : out std_logic_vector( 3 downto 0);
		selDToM            : out std_logic_vector( 1 downto 0);
		MWr                : out std_logic;
		MRd                : out std_logic;
		selDFrM            : out std_logic_vector( 2 downto 0);
		selWBD             : out std_logic_vector( 1 downto 0)
		);
end DEC;

architecture combinational of DEC is
signal opcode       : std_logic_vector(6 downto 0);
signal f3           : std_logic_vector(2 downto 0);
signal f7           : std_logic_vector(6 downto 0);
signal opcode_f3_f7 : std_logic_vector(16 downto 0);
signal zero5Bit     : std_logic_vector(4 downto 0) := "00000";
signal bitEq0       : std_logic := '0';
signal bitEq1       : std_logic := '1';

signal instrID      : std_logic_vector(5 downto 0); -- included to aid simulation waveform viewing of instruction ID
signal imm_I : std_logic_vector(11 downto 0);
signal imm_R : std_logic_vector(11 downto 0);
signal imm_S : std_logic_vector(11 downto 0);
signal imm_B : std_logic_vector(12 downto 0);
signal imm_U : std_logic_vector(31 downto 0);
signal imm_J : std_logic_vector(20 downto 0);
signal extImm_I : std_logic_vector(31 downto 0);
signal extImm_R : std_logic_vector(31 downto 0);
signal extImm_S : std_logic_vector(31 downto 0);
signal extImm_B : std_logic_vector(31 downto 0);
signal extImm_U : std_logic_vector(31 downto 0);
signal extImm_J : std_logic_vector(31 downto 0);

signal DEC_vector              : std_logic_vector(70 downto 0); -- assign 71 bit vector for f7, f3, opcode combinations

signal abc : std_logic; 

begin 


-- I-type format: imm[11:0] rs1	f3	rd opcode 
 imm_I_i:    imm_I    <= instruction(31 downto 20); 
 extImm_I_i: extImm_I <= std_logic_vector(  resize( signed(imm_I), instruction'length )  ); 

 imm_R_i:    imm_R    <= "0000000" & instruction(24 downto 20); 
 extImm_R_i: extImm_R <= std_logic_vector(  resize( signed(imm_R), instruction'length )  ); 

-- S-type format: imm[11:5] rs2 rs1 f3 imm[4:0] opcode 
 imm_S_i:    imm_S <= instruction(31 downto 25) & instruction(11 downto 7);                      
 extImm_S_i: extImm_S <= std_logic_vector(  resize( signed(imm_S), instruction'length )  ); 
 
 -- B-type format: imm[12¦10:5]	rs2	rs1	f3 imm[4:1¦11] opcode
 imm_B_i:    imm_B <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'; 
 extImm_B_i: extImm_B <= std_logic_vector(  resize( signed(imm_B), instruction'length )  ); 

 -- U-type format: imm[31:12] rd opcode 
 imm_U_i:    imm_U <= instruction(31 downto 12) & X"000"; 
 extImm_U_i: extImm_U <= std_logic_vector(  resize( signed(imm_U), instruction'length )  ); 

 -- J-type format: imm[20¦10:1¦11¦19:12] rd	opcode
 imm_J_i:    imm_J <= instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0'; 
 extImm_J_i: extImm_J <= std_logic_vector(  resize( signed(imm_J), instruction'length )  ); 


opcode_i: opcode <= instruction( 6 downto 0);  -- always
f3_i: process (instruction) 
begin
    f3  <= instruction(14 downto 12);  -- default
    if instruction(6 downto 0) = "0110111" or  instruction(6 downto 0) = "0010111" or  instruction(6 downto 0) = "1101111" then 
   	  f3 <= "000";
	end if;
end process;
f7_i: process (instruction) 
begin
	abc <='0';
    f7 <= "0000000"; -- default
	if instruction(6 downto 0) = "0010011" then
       if instruction(14 downto 12) = "001" or instruction(14 downto 12) = "101" then 
          f7  <= instruction(31 downto 25); 
    	  abc <= '1';
       elsif instruction(6 downto 0) = "0110011" then
          f7  <= instruction(31 downto 25); 
    	  abc <= '1';
	   end if;
	end if;
end process;
opcode_f3_f7 <= opcode & f3 & f7;


DEC_i: process (opcode_f3_f7, instruction, branch, extImm_I, extImm_R, extImm_S, extImm_B, extImm_U, extImm_J) 
begin
DEC_vector <=  (others => '0'); -- default assignment
case opcode_f3_f7 is 

 when "01101110000000000" => DEC_vector <=  "000001" & "00000" & "00000" & '1' & instruction(11 downto 7) & extImm_U & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '0' & "000" & "00"; --  U-type. Instruction LUI
 when "00101110000000000" => DEC_vector <=  "000010" & "00000" & "00000" & '1' & instruction(11 downto 7) & extImm_U & bitEq0 & '0' & '1' & '0' & "0000" & "00" & '0' & '0' & "000" & "00"; --  U-type. Instruction AUIPC

 when "11011110000000000" => DEC_vector <=  "000011" & "00000" & "00000" & '1' & instruction(11 downto 7) & extImm_J & bitEq1 & '0' & '0' & '0' & "0000" & "00" & '0' & '0' & "000" & "10"; --  J-type. Instruction JAL




 when "11000110000000000" => DEC_vector <=  "000100" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1010" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BEQ
 when "11000110010000000" => DEC_vector <=  "000101" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1011" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BNE
 when "11000111000000000" => DEC_vector <=  "000110" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1100" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BLT
 when "11000111010000000" => DEC_vector <=  "000111" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1101" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BGE
 when "11000111100000000" => DEC_vector <=  "001000" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1110" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BLTU
 when "11000111110000000" => DEC_vector <=  "001001" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_B & branch & '0' & '0' & '0' & "1111" & "00" & '0' & '0' & "000" & "00"; --  B-type. Instruction BGEU


 when "11001110000000000" => DEC_vector <=  "001010" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq1 & '1' & '0' & '0' & "0000" & "00" & '0' & '0' & "000" & "10"; --  I-type. Instruction JALR

 when "00000110000000000" => DEC_vector <=  "001011" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '1' & "010" & "01"; --  I-type. Instruction LB
 when "00000110010000000" => DEC_vector <=  "001100" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '1' & "001" & "01"; --  I-type. Instruction LH
 when "00000110100000000" => DEC_vector <=  "001101" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '1' & "000" & "01"; --  I-type. Instruction LW
 when "00000111000000000" => DEC_vector <=  "001110" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '1' & "100" & "01"; --  I-type. Instruction LBU
 when "00000111010000000" => DEC_vector <=  "001111" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '1' & "011" & "01"; --  I-type. Instruction LHU

 when "00100110000000000" => DEC_vector <=  "010000" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction ADDI
 when "00100110100000000" => DEC_vector <=  "010001" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "1000" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction SLTI
 when "00100110110000000" => DEC_vector <=  "010010" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "1001" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction SLTIU
 when "00100111000000000" => DEC_vector <=  "010011" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0100" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction XORI
 when "00100111100000000" => DEC_vector <=  "010100" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0011" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction ORI
 when "00100111110000000" => DEC_vector <=  "010101" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0010" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction ANDI


 when "01000110000000000" => DEC_vector <=  "010110" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_S & bitEq0 & '0' & '0' & '0' & "0000" & "10" & '1' & '1' & "000" & "00"; --  S-type. Instruction SB
 when "01000110010000000" => DEC_vector <=  "010111" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_S & bitEq0 & '0' & '0' & '0' & "0000" & "01" & '1' & '1' & "000" & "00"; --  S-type. Instruction SH
 when "01000110100000000" => DEC_vector <=  "011000" & instruction(19 downto 15) & instruction(24 downto 20) & '0' & "00000" & extImm_S & bitEq0 & '0' & '0' & '0' & "0000" & "00" & '1' & '1' & "000" & "00"; --  S-type. Instruction SW


 when "00100110010000000" => DEC_vector <=  "011001" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0101" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction SLLI
 when "00100111010000000" => DEC_vector <=  "011010" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0110" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction SRLI
 when "00100111010100000" => DEC_vector <=  "011011" & instruction(19 downto 15) & "00000" & '1' & instruction(11 downto 7) & extImm_I & bitEq0 & '0' & '0' & '0' & "0111" & "00" & '0' & '0' & "000" & "00"; --  I-type. Instruction SRAI

 when "01100110000000000" => DEC_vector <=  "011100" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0000" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction ADD 
 when "01100110000100000" => DEC_vector <=  "011101" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0001" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SUB
 when "01100110010000000" => DEC_vector <=  "011110" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0101" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SLL 
 when "01100110100000000" => DEC_vector <=  "011111" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "1000" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SLT
 when "01100110110000000" => DEC_vector <=  "100000" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "1001" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SLTU
 when "01100111000000000" => DEC_vector <=  "100001" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0100" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction XOR 
 when "01100111010000000" => DEC_vector <=  "100010" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0110" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SRL  
 when "01100111010100000" => DEC_vector <=  "100011" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0111" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction SRA  
 when "01100111100000000" => DEC_vector <=  "100100" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0011" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction OR 
 when "01100111110000000" => DEC_vector <=  "100101" & instruction(19 downto 15) & instruction(24 downto 20) & '1' & instruction(11 downto 7) & X"00000000" & bitEq0 & '0' & '0' & '1' & "0010" & "00" & '0' & '0' & "000" & "00"; --  R-type. Instruction AND 

when others => null;
end case;
end process;

-- Assign output signals
instrID    <= DEC_vector(70 downto 65);
rs1        <= DEC_vector(64 downto 60);
rs2        <= DEC_vector(59 downto 55);
RWr        <= DEC_vector(54);
rd         <= DEC_vector(53 downto 49);
extImm     <= DEC_vector(48 downto 17);
selPCSrc   <= DEC_vector(16);
jalr       <= DEC_vector(15);  
auipc      <= DEC_vector(14);
selALUBSrc <= DEC_vector(13);
selALUOp   <= DEC_vector(12 downto  9);
selDToM    <= DEC_vector( 8 downto  7);
MWr        <= DEC_vector( 6);
MRd        <= DEC_vector( 5);
selDFrM    <= DEC_vector( 4 downto  2);
selWBD     <= DEC_vector( 1 downto  0);

end combinational;
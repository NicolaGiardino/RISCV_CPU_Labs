\m4_TLV_version 1d: tl-x.org
\SV
   // The original code this one is based upon can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])



   //---------------------------------------------------------------------------------
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
   //m4_asm(ADDI, x14, x0, 0)             // Initialize sum register a4 with 0
   //m4_asm(ADDI, x12, x0, 1010)          // Store count of 10 in register a2.
   //m4_asm(ADDI, x13, x0, 1)             // Initialize loop count register a3 with 0
   // Loop:
   //m4_asm(ADD, x14, x13, x14)           // Incremental summation
   //m4_asm(ADDI, x13, x13, 1)            // Increment loop count by 1
   //m4_asm(BLT, x13, x12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   // Test result value in x14, and set x31 to reflect pass/fail.
   //m4_asm(ADDI, x30, x14, 111111010100) // Subtract expected value of 44 to set x30 to 1 if and only iff the result is 45 (1 + 2 + ... + 9).
   //m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   //m4_asm_end()
   //m4_define(['M4_MAX_CYC'], 50)
   //---------------------------------------------------------------------------------
   m4_test_prog()


\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_off WIDTH */
\TLV
   $reset = *reset;
   
   //PROGRAM COUNTER instructions
   $pc[31:0] = >>1$next_pc[31:0];
   $next_pc[31:0] = $reset ? 0 : (32'b100 + $pc[31:0]);
   
   //INSTRUCTION MEMORY can be set using a library
   `READONLY_MEM($pc, $$instr[31:0])
   
   //DECODER
   //Look at opcode $instr[6:0] for the type of the instruction
   //All values are assumed to be valid (instr[1:0] = 2'b11)
   //U-code could be decoded as:
   //instruction U is if instr[6:2] is 101 or is 1101,
   //by looking at the table
   //$is_u_instr = $instr[6:2] == 5'b00101 || $instr[6:2] == 5'b01101;
   //or simpler instruction: (x is don't care)
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_r_instr = $instr[6:2] ==? 5'b011x0 || $instr[6:2] == 5'b01011 || $instr[6:2] == 5'b10100;
   $is_b_instr = $instr[6:2] == 5'b11000;
   $is_s_instr = $instr[6:2] == 5'b01000 || $instr[6:2] == 5'b01001;
   $is_i_instr = $instr[6:2] ==? 5'b0000x || $instr[6:2] ==? 5'b001x0 || $instr[6:2] == 5'b11001;
   $is_j_instr = $instr[6:2] == 5'b11011;
   
   //Decoding instruction fields
   //Checking valid values
   $rs1_valid = $is_i_instr || $is_r_instr || $is_b_instr || $is_s_instr;
   $rs2_valid = $is_r_instr || $is_b_instr || $is_s_instr;
   $rd_valid = $is_i_instr || $is_r_instr || $is_u_instr || $is_j_instr;
   $imm_valid = ! $is_r_instr;
   
   //Shut up the LOG
   `BOGUS_USE($rd $rd_valid $rs1 $rs1_valid ...)
   
   //Assign instruction fields
   $rs1[4:0] = $rs1_valid ? $instr[19:15] : 5'b0;
   $rs2[4:0] = $rs2_valid ? $instr[24:20] : 5'b0;
   $rd[4:0] = $rd_valid ? $instr[11:7] : 5'b0;
   
   //To verify if corresponds to the instr in test progr, 
   //verify that ADDI, x12, x10, 1010 shows the val in bin of i[10] or 'a'
   $imm[31:0] =
      $imm_valid
         ? ($is_i_instr
               ? ({ {21{$instr[31]}}, $instr[30:20]}) :
            $is_s_instr
               ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
            $is_b_instr
               ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
            $is_u_instr
               ? {$instr[31], $instr[30:20], $instr[19:12], 12'b0} :
            $is_j_instr
               ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} :
               
               32'b0) :
         32'b0;
   
   //Then determine the instruction from opcode funct7[5] and funct3
   $funct7[6:0] =
      $is_r_instr ? $instr[31:25] :
      ($is_i_instr && $instr[31:25] == 7'b0100000 && $instr[14:12] == 3'b101 && $instr[6:0] == 7'b0010011) ? $instr[31:25] :
      7'b0;
   $funct3[2:0] = ($is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr) ? $instr[14:12] : 3'b0;
   $dec_bits[10:0] = {$funct7[5], $funct3, $instr[6:0]};
   
   //Check which instruction is being called
   //U-Type instructions
   $is_lui = $dec_bits ==? 11'bx_0110111;
   $is_auipc = $dec_bits ==? 11'bx_0010111;
   //J-Type instruction
   $is_jal = $dec_bits ==? 11'bx_1101111;
   //I-Type instruction
   $is_jalr = $dec_bits ==? 11'bx_000_1100111;
   //B-Type instructions
   $is_beq = $dec_bits ==? 11'bx_000_1100011;
   $is_bne = $dec_bits ==? 11'bx_001_1100011;
   $is_blt = $dec_bits ==? 11'bx_100_1100011;
   $is_bge = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   //I-Type instructions
   $is_load = $dec_bits ==? 11'bx_0000011;
   //I-Type instructions
   $is_addi = $dec_bits ==? 11'bx_000_0010011;
   $is_slti = $dec_bits ==? 11'bx_010_0010011;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori = $dec_bits ==? 11'bx_100_0010011;
   $is_ori = $dec_bits ==? 11'bx_110_0010011;
   $is_andi = $dec_bits ==? 11'bx_111_0010011;
   $is_slli = $dec_bits == 11'b0_001_0010011;
   $is_srli = $dec_bits == 11'b0_101_0010011;
   $is_srai = $dec_bits == 11'b1_101_0010011;
   //R-Type instructions
   $is_add = $dec_bits == 11'b0_000_0110011;
   $is_sub = $dec_bits == 11'b1_000_0110011;
   $is_sll = $dec_bits == 11'b0_001_0110011;
   $is_slt = $dec_bits == 11'b0_010_0110011;
   $is_sltu = $dec_bits == 11'b0_011_0110011;
   $is_xor = $dec_bits == 11'b0_100_0110011;
   $is_srl = $dec_bits == 11'b0_101_0110011;
   $is_sra = $dec_bits == 11'b1_101_0110011;
   $is_or = $dec_bits == 11'b0_110_0110011;
   $is_and = $dec_bits == 11'b0_111_0110011;
   
   
   
   //REGISTER FILE
   //Data to be passed to the Register File
   $rd1_en = $rs1_valid;
   $rd2_en = $rs2_valid;
   $wr_en = $rd_valid;
   
   $rd1_index[4:0] = $rs1[4:0];
   $rd2_index[4:0] = $rs2[4:0];
   $wr_index[4:0] = $rd[4:0];
   
   //Connecting the data in output to the source values:
   $src1_value[31:0] = $rd1_data[31:0];
   $src2_value[31:0] = $rd2_data[31:0];
   
   //If SLTU or SLTIU instructions are being called:
   //Set if less than unsigned value
   $sltu_rslt[31:0] = $is_sltu ? {31'b0, $src1_value < $src2_value} : 32'b0;
   $sltiu_rslt[31:0] = $is_sltiu ? {31'b0, $src1_value < $imm} : 32'b0;
   
   //If SLT or SLTI instructions are being called:
   //Set if less than signed value
   $slt_rslt[31:0] = $is_slt
      ? ($src1_value[31] == $src2_value[31] ? $sltu_rslt : {31'b0, $src1_value[31]}) : 
         32'b0;
   $slti_rslt[31:0] = $is_slti
      ? ($src1_value[31] == $imm[31] ? $sltiu_rslt : {31'b0, $src1_value[31]}) : 
         32'b0;
   
   //If SRA or SRAI are being called:
   //sign extended src1:
   $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value};
   //64 bit sign extended to be truncated:
   $sra_rslt[63:0] = $is_sra ? $sext_src1 >> $src2_value[4:0] : 64'b0;
   $srai_rslt[63:0] = $is_srai ? $sext_src1 >> $imm[4:0] : 64'b0;
   
   //ALU
   $result[31:0] =
      $is_lui ? {$imm[31:12], 12'b0} :
      $is_auipc ? $pc + $imm :
      $is_jal ? $pc + 32'b100 :
      $is_jalr ? $pc + 32'b100 :
      $is_addi || $is_load || $is_s_instr ? $src1_value + $imm :
      $is_slti ? $slti_rslt[31:0] :
      $is_sltiu ? $sltiu_rslt[31:0] :
      $is_xori ? $src1_value ^ $imm :
      $is_ori ? $src1_value | $imm :
      $is_andi ? $src1_value & $imm :
      $is_slli ? $src1_value << $imm[5:0] :
      $is_srli ? $src1_value >> $imm[5:0] :
      $is_srai ? $srai_rslt[31:0] :
      $is_add ? $src1_value + $src2_value :
      $is_sub ? $src1_value - $src2_value :
      $is_sll ? $src1_value << $src2_value[4:0] :
      $is_slt ? $slt_rslt[31:0] :
      $is_sltu ? $sltu_rslt[31:0] :
      $is_xor ? $src1_value ^ $src2_value :
      $is_srl ? $src1_value >> $src2_value[4:0] :
      $is_sra ? $sra_rslt[31:0] :
      $is_or ? $src1_value | $src2_value :
      $is_and ? $src1_value & $src2_value :
         32'b0;
   
   
   //BRANCH INSTRUCTIONS
   $taken_br =
      $is_jal
         ? 1'b1 :
      $is_beq
         ? ($src1_value == $src2_value) :
      $is_bne
         ? ($src1_value != $src2_value) :
      $is_blt
         ?  (($src1_value < $src2_value)  ^ ($src1_value[31] != $src2_value[31])) :
      $is_bge
         ?  (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
      $is_bltu
         ? ($src1_value < $src2_value) :
      $is_bgeu
         ? ($src1_value >= $src2_value) :
         1'b0;
   
   //DATA MEMORY Instructions
   $d_wr_en = $is_s_instr;
   $d_rd_en = $is_load;
   
   $addr[4:0] = ($d_wr_en || $d_rd_en) ? $result[6:2] : 5'b0;
   
   $d_wr_data[31:0] = $d_wr_en ? $src2_value[31:0] : 32'b0;
   $ld_data[31:0] = $d_rd_en ? $d_rd_data[31:0] : 32'b0;
   
   //Write into RF
   $wr_data[31:0] =
      $is_load ? $ld_data[31:0] :
      $rd[4:0] == 5'b0 ? 32'b0 :
      $is_s_instr ? $src2_value :
      $result[31:0];
   
   $jalr_tgt_pc[31:0] = $is_jalr ? $src1_value + $imm[31:0] : 0;
   $br_tgt_pc[31:0] = $taken_br ? $pc[31:0] + $imm[31:0] : 0;
   
   $next_pc[31:0] = $taken_br ? $br_tgt_pc : $next_pc;
   
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > M4_MAX_CYC;
   *failed = 1'b0;
   
   //Instantiate a REGISTER FILE, 32way 32bit wide, output sig names, input expressions
   m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd1_en, $rd1_index[4:0], $rd1_data[31:0], $rd2_en, $rd2_index[4:0], $rd2_data[31:0])
   //Instantiate a DATA MEMORY, same size as RF
   m4+dmem(32, 32, $reset, $addr[4:0], $d_wr_en, $d_wr_data[31:0], $d_rd_en, $d_rd_data[31:0])
   m4+cpu_viz()
\SV
   endmodule

-- Description: RISCV.vhd
-- Engineer: Fearghal Morgan, Joseph Clancy, Arthur Beretta
-- National University of Ireland, Galway (NUI Galway)
--
-- structurally connects IF, ID, EX, MEM, WB components
-- Completed


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.all;

entity RISCV is
   Port (clk  : in std_logic;       
         rst  : in std_logic;
         ce   : in std_logic;
		 useDebugInstruction : in std_logic;
		 debugInstruction : in std_logic_vector(31 downto 0)
        );
end RISCV;

architecture struct of RISCV is
component RISCV_IF is
  Port (clk        			: in  std_logic;
        rst      			: in  std_logic;
        ce         			: in  std_logic;
        brAddr   			: in  std_logic_vector(31 downto 0);
        selPCSrc        	: in  std_logic;
		  PCPlus4 			: out std_logic_vector(31 downto 0);
		  instruction         : out std_logic_vector(31 downto 0);
        PC                  : out std_logic_vector(31 downto 0)
		);
end component;

component ID is
  Port (clk         : in  std_logic;
        rst         : in  std_logic;
        ce          : in  std_logic;
        instruction : in  std_logic_vector(31 downto 0);
        branch      : in  std_logic;
        rs1D        : out  std_logic_vector(31 downto 0);
        rs2D        : out  std_logic_vector(31 downto 0);
        WBDat  	    : in  std_logic_vector(31 downto 0);
		extImm      : out std_logic_vector(31 downto 0);
		selPCSrc    : out std_logic;
		jalr        : out std_logic;
		auipc       : out std_logic;
		selALUBSrc  : out std_logic;
		selALUOp    : out std_logic_vector( 3 downto 0);
		selDToM     : out std_logic_vector( 1 downto 0);
		MWr         : out std_logic;
		MRd         : out std_logic;
		selDFrM     : out std_logic_vector( 2 downto 0);
		selWBD      : out std_logic_vector( 1 downto 0)
		);
end component;

component EX is
  Port (extImm     : in  std_logic_vector(31 downto 0); 
		rs1D       : in  std_logic_vector(31 downto 0);
        rs2D       : in  std_logic_vector(31 downto 0);
        jalr       : in  std_logic;                    
        PC         : in  std_logic_vector(31 downto 0);
        auipc      : in  std_logic;                    
        selALUBSrc : in  std_logic;  
        selALUOp   : in  std_logic_vector( 3 downto 0);  
        selDToM    : in  std_logic_vector( 1 downto 0); 
        ALUOut     : out std_logic_vector(31 downto 0);
        DToM       : out std_logic_vector(31 downto 0);
        brAddr     : out std_logic_vector(31 downto 0);
        branch     : out std_logic
        );        
end component; 

component MEM is
   Port (clk  : in std_logic;       
         rst  : in std_logic;
         MWr  : in std_logic;                      -- Memory write control (1 : write)
         MRd  : in std_logic;                      -- Memory read control  (0 : read)
         add  : in std_logic_vector(31 downto 0);  -- Address 
         DToM : in std_logic_vector(31 downto 0);  -- Data in 
         inport : in std_logic_vector(15 downto 0);
         DFrM : out std_logic_vector(31 downto 0);  -- Data in 
         outport : out std_logic_vector(15 downto 0) 
        );
end component;       

component WB is
   Port (selWBD   : in  std_logic_vector( 1 downto 0);
		 ALUOut   : in  std_logic_vector(31 downto 0);
		 DFrM     : in  std_logic_vector(31 downto 0);
         selDFrM  : in  std_logic_vector(2 downto 0);
		 PCPlus4  : in  std_logic_vector(31 downto 0);
         WBDat    : out std_logic_vector(31 downto 0)
         );
end component;

-- signal memArray : array64x32;
-- signal addrSlice : std_logic_vector(5 downto 0);

signal PC          : std_logic_vector(31 downto 0); 
signal instruction : std_logic_vector(31 downto 0);
signal rs1D        : std_logic_vector(31 downto 0);
signal rs2D        : std_logic_vector(31 downto 0);
signal extImm      : std_logic_vector(31 downto 0);
signal selALUBSrc  : std_logic;
signal selALUOp    : std_logic_vector(3 downto 0);
signal ALUOut      : std_logic_vector(31 downto 0);
signal branch      : std_logic;
signal brAddr      : std_logic_vector(31 downto 0); 
signal selPCSrc    : std_logic;
signal PCPlus4     : std_logic_vector(31 downto 0);
signal jalr        : std_logic;
signal auipc       : std_logic;    
signal selDToM     : std_logic_vector(1 downto 0);   
signal DToM        : std_logic_vector(31 downto 0);   
--signal add         : std_logic_vector(31 downto 0);   
signal MWr         : std_logic;
signal MRd         : std_logic;    
signal selDFrM     : std_logic_vector(2 downto 0);    
signal DFrM        : std_logic_vector(31 downto 0);   
signal selWBD      : std_logic_vector(1 downto 0);
signal WBDat  	   : std_logic_vector(31 downto 0);

signal inport      : std_logic_vector(15 downto 0) := (others => '0');
signal outport     : std_logic_vector(15 downto 0) := (others => '0');

signal IMInstruction : std_logic_vector(31 downto 0);

begin

IF_i: RISCV_IF port map
       (clk        	=> clk,        
        rst      	=> rst,      	
        ce         	=> ce,         
        brAddr   	=> brAddr,   	
        selPCSrc    => selPCSrc,   
		PCPlus4 	=> PCPlus4, 	
		instruction => IMInstruction,
        PC          => PC
		);

debugInstruction_i: process (useDebugInstruction, IMInstruction, debugInstruction)
begin
  instruction <= IMInstruction; -- default
  if useDebugInstruction = '1' then
	instruction <= debugInstruction; 
  end if;
end process;

ID_i: ID port map
       (clk         => clk,        
        rst         => rst,        
        ce          => ce,         
        instruction => instruction,
        branch      => branch,     
        rs1D        => rs1D,       
        rs2D        => rs2D,       
        WBDat  	    => WBDat,  	   
		extImm      => extImm,    
		selPCSrc    => selPCSrc,   
		jalr        => jalr,       
		auipc       => auipc,      
		selALUBSrc  => selALUBSrc, 
		selALUOp    => selALUOp,   
		selDToM     => selDToM,   
		MWr         => MWr,        
		MRd         => MRd,        
		selDFrM     => selDFrM,    
		selWBD      => selWBD   
		);

EX_i: EX port map
       (extImm     => extImm,     
		  rs1D       => rs1D,       
        rs2D       => rs2D,       
        jalr       => jalr,       
        PC         => PC,         
        auipc      => auipc,      
        selALUBSrc => selALUBSrc, 
        selALUOp   => selALUOp,   
        selDToM    => selDToM,    
        ALUOut     => ALUOut,     
        DToM       => DToM,       
        brAddr     => brAddr,      
        branch     => branch     
        );        

MEM_i: MEM port map
        (clk  => clk, 
         rst  => rst, 
         MWr  => MWr, 
         MRd  => MRd, 
         add  => ALUOut, 
         DToM => DToM,
         DFrM => DFrM,
         inport => inport,
         outport => outport
        );

WB_i: WB port map
        (selWBD  => selWBD,  
		 ALUOut  => ALUOut,  
		 DFrM    => DFrM,    
         selDFrM => selDFrM, 
		 PCPlus4 => PCPlus4, 
         WBDat   => WBDat   
         );

end struct;
-- Engineer: Fearghal Morgan, Arthur Beretta (AB), Joseph Clancy (JC) 
-- National University of Ireland Galway
-- 
-- Module Name: ID
-- Description: Instruction Decoder stage for the RISC-V Processor
-- Includes
--  1. DEC instruction decoder component
--  2. RB register bank component 
--
-- structurally connects DEC and RB components
-- Completed


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ID is
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
end ID;

architecture struct of ID is

component DEC is
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
end component;

component RB is
  Port (clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        rs1 	 : in  std_logic_vector(4 downto 0);
        rs2 	 : in  std_logic_vector(4 downto 0);
		RWr      : in  std_logic;
        WBDat  	 : in  std_logic_vector(31 downto 0);
        rd  	 : in  std_logic_vector(4 downto 0);
        rs1D     : out std_logic_vector(31 downto 0);
        rs2D     : out std_logic_vector(31 downto 0)
		);
end component;

signal rs2   : std_logic_vector( 4 downto 0);
signal rs1   : std_logic_vector( 4 downto 0);
signal RWr   : std_logic;
signal rd    : std_logic_vector( 4 downto 0);

begin 

DEC_i: DEC port map
       (instruction => instruction,  
        branch      => branch,
		extImm      => extImm,      
		rs1         => rs1,    
		rs2         => rs2,    
		RWr         => RWr,    
		rd          => rd,     
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
		
RB_i: RB port map 
       (clk   => clk,  
        rst   => rst,  
        ce    => ce,   
        rs2   => rs2,  
        rs1   => rs1,  
		RWr   => RWr,  
        WBDat => WBDat,
        rd    => rd,   
        rs1D  => rs1D, 
        rs2D  => rs2D 
		);
		
end struct;
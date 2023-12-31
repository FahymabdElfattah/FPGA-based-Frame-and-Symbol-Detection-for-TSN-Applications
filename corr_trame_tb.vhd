-- =====================================| fichier VHDL de test bench |====================================== --

------------------  les biblioth�ques necessaires------------------------------------------
LIBRARY ieee  ; 
library std;
use std.textio.ALL;
USE ieee.std_logic_1164.all  ; 
USE ieee.numeric_std.all; 

-------------- Entit� du  test bench -------------------------------------- 
ENTITY corr_trame_tb  IS 
END ; 
 
------------- Architecture qui d�finie le test bench ----------------------
ARCHITECTURE corr_trame_tb_arch OF corr_trame_tb IS
  SIGNAL In_re    :  std_logic_vector (13 downto 0)  := (others => '0'); -- L'�chantillon d'entr�e  sous la forme d'un fichier .txt
  SIGNAL corr_s   :  std_logic_vector (18 downto 0)  ;                   -- la corr�lation symbole sortie  sous la forme d'un fichier .txt
  SIGNAL corr_t   :  std_logic_vector (20 downto 0)  ;                   --la coor�lation de trame sortie  sous la forme d'un fichier .txt
  SIGNAL Evalue   :  STD_LOGIC  ;                                        -- controle du multiplexeur
  SIGNAL CLK      :  STD_LOGIC  ;                                        -- l'horloge globale
  SIGNAL RSTn     :  STD_LOGIC  ;                                        -- le reset global

---------------- d�claration du component du code sourc e-------------------
  COMPONENT corr_trame  
    PORT ( 
            corr_symbole : out std_logic_vector(18 downto 0);
	    corr_trame : out std_logic_vector(20 downto 0);	
	    In_re 	: in std_logic_vector(13 downto 0);
	    Evalue  : in STD_LOGIC ; 
            CLK  : in STD_LOGIC ; 
            RSTn  : in STD_LOGIC ); 
  END COMPONENT ; 

---------------- production du signal Evalue utile pour la simulation ----------
  COMPONENT timer is
   port (
           RSTn : in std_logic;
           CLK  : in std_logic;
           Evalue : out std_logic);
   end component;
   
BEGIN
------------------- Affectation Entr�e/Sortie pour corr_trame.vhd ---------------------------------
  DUT  : corr_trame  
    PORT MAP ( 
      In_re   => In_re  ,
      corr_symbole   => corr_s,
      corr_trame => corr_t,
      Evalue   => Evalue  ,
      CLK   => CLK  ,
      RSTn   => RSTn   ) ; 
------------------- Affectation Entr�e/Sortie pourd timer.vhd ---------------------------------
timer0 : timer
      port map (
           RSTn => RSTn,
           CLK  => CLK,
           Evalue => Evalue);

-----------------remis a z�ro du syst�me pendant 5ns ----------------------------------------
RSTn <= '0', '1' after 5 ns;
 
--------------- signale d'horloge de p�riode 20ns -------------------------------------------     
P: process
    begin
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
end process P;
-- ENTREE <== in_re5_chan2.txt
-- SORTIE_t ==> corr_trame.txt
-- SORTIE_s ==> corr_symbole.txt
LECTURE : process
  variable L,M	: LINE;
  file ENTREE	 : TEXT open READ_MODE is	"in_re5_chan2.txt"; --fichier des �chantillons |
  file SORTIE_t	 : TEXT open WRITE_MODE is	"corr_trame.txt"; -- fichier du r�sultats du deuxi�me bloc
  file SORTIE_s : TEXT open WRITE_MODE is	"corr_symbole.txt"; --fichier du r�sultats du premi�re bloc 
  variable A	: integer := 0;
 
begin
  while not endfile(ENTREE) loop
    wait for 10 ns;
    READLINE(ENTREE, L);
    READ(L,A);
    in_re <= std_logic_vector(TO_SIGNED(A,14)) after 2 ns;
    wait for 10 ns; 
    WRITE(M,to_INTEGER(SIGNED(corr_s))	,LEFT, 8);
    WRITELINE(SORTIE_s, M);
    WRITE(M,to_INTEGER(SIGNED(corr_t))	,LEFT, 8);
    WRITELINE(SORTIE_t, M);
	 end loop;
   wait;
end process LECTURE;      
END ; 



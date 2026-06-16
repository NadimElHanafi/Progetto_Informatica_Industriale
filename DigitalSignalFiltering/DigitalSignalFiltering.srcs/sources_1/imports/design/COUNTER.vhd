library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
	 	 
entity counter is
    generic ( Nb : integer) ;
    port( T           :in std_logic;
          clk         :in std_logic; 
          OUT_COUNT   :out std_logic_vector(Nb-1 downto 0)
    );
    end counter;  
architecture counter_behavior of counter is
    signal count : std_logic_vector(Nb-1 downto 0) := (others => '0');
begin
 
    process(clk)
    begin
        if rising_edge(clk) then
            if T = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;
 
    OUT_COUNT <= count;
      
end counter_behavior;

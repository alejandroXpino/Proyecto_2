library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divisor_frecuencia is
    port (
        clk_entrada : in  std_logic;
        selector    : in  std_logic_vector(1 downto 0);
        clk_salida  : out std_logic
    );
end entity divisor_frecuencia;

architecture behavioral of divisor_frecuencia is
    signal cuenta : integer range 0 to 50000000 := 0;
    signal limite : integer range 0 to 50000000;
    signal pulso  : std_logic := '0';
begin
    proceso_selector: process(selector)
    begin
        case selector is
            when "00"   => limite <= 50000000;   -----problema corregido del contador ya que se tenia un desfase de 3 segundos (no fue la mejor forma de corregirlo)
            when "01"   => limite <= 25000000;
            when "10"   => limite <= 12500000;
            when others => limite <= 6250000;
        end case;
    end process proceso_selector;

    proceso_division: process(clk_entrada)
    begin
        if rising_edge(clk_entrada) then
            if cuenta = 0 then
                cuenta <= limite;
                pulso  <= not pulso;
            else
                cuenta <= cuenta - 1;
            end if;
        end if;
    end process proceso_division;

    clk_salida <= pulso;
end architecture behavioral;
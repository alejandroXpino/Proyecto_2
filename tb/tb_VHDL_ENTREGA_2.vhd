library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_pkg.all;

entity tb_VHDL_ENTREGA_2_sim is
end entity;

architecture sim of tb_VHDL_ENTREGA_2_sim is
    -- Señales de estímulo
    signal clk_50m   : std_logic := '0';
    signal rst_n     : std_logic := '1';
    signal start_btn : std_logic := '1';
    signal sel       : std_logic_vector(1 downto 0) := "11";
    
    -- Señales de observación
    signal hex_u, hex_d, hex_c : std_logic_vector(6 downto 0);
    
    constant PERIOD : time := 20 ns;
begin 

    -- Instanciación de la Unidad Bajo Prueba (UUT)
    uut : entity work.VHDL_ENTREGA_2
        port map (
            clk       => clk_50m,
            rst       => rst_n,
            start     => start_btn,
            selector  => sel,
            seg_out_u => hex_u,
            seg_out_d => hex_d,
            seg_out_c => hex_c
        );

    -- Generador de Reloj Principal
    clk_process : process 
    begin
        clk_50m <= '0'; wait for PERIOD / 2; 
        clk_50m <= '1'; wait for PERIOD / 2; 
    end process; 

    -- Proceso de Estímulos corto
    estimulos_proc : process 
    begin
        -- Reporte de datos guardados en la ROM
        report "========================================================";
        report "DATOS GUARDADOS EN LA ROM (rom_sync):";
        report "Direccion 0: AA | Direccion 1: 55";
        report "Direccion 2: F0 | Direccion 3: 0F";
        report "========================================================";
        report "ESTADOS DE LA FSM: PARADO -> LEER_ROM -> GUARDAR_EN_RAM -> LEER_DE_RAM -> ESPERAR";
        report "========================================================";

        -- Secuencia de inicio rápida
        rst_n <= '0'; wait for 100 ns;
        rst_n <= '1'; wait for 100 ns;
        
        report "--- GENERANDO FLANCO EN START ---";
        start_btn <= '0'; wait for 100 ns;
        start_btn <= '1';
        
        -- Espera para observación (en simulación real sin forzado)
        wait for 1 ms; 
        
        assert false report "Fin de la simulacion" severity failure; 
        wait;
    end process; 

end architecture;
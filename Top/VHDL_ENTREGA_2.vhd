library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.mem_pkg.all;     -- Paquete de ROM y RAM

entity VHDL_ENTREGA_2 is
    port (
        clk         : in  std_logic;                    --divisro de frecuencia
        rst         : in  std_logic;                    -- boton 
        start       : in  std_logic;                    -- Botón para iniciar la secuencia
        selector    : in  std_logic_vector(1 downto 0); -- Selector para el divisor de frecuencia
        seg_out_u   : out std_logic_vector(6 downto 0); -- Salida 7 segmentos: Unidades
        seg_out_d   : out std_logic_vector(6 downto 0); -- Salida 7 segmentos: Decenas
        seg_out_c   : out std_logic_vector(6 downto 0)  -- Salida 7 segmentos: Centenas
    );
end VHDL_ENTREGA_2;

architecture Behavioral of VHDL_ENTREGA_2 is

 
    component divisor_frecuencia --componente que ya tenia almacenados y los reutilice, el divisor_frecuencia  y el decodificadore
        port (
            clk_entrada : in  std_logic;
            selector    : in  std_logic_vector(1 downto 0);
            clk_salida  : out std_logic
        );
    end component;

    component dec7seg
        port (
            char : in  std_logic_vector(7 downto 0);
            seg  : out std_logic_vector(6 downto 0)
        );
    end component;

  
    type state_t is (PARADO, LEER_ROM, GUARDAR_EN_RAM, LEER_DE_RAM, ESPERAR);  -- Definición de los estados de la FSM 
    signal state : state_t := PARADO;


    signal clk_lento : std_logic;                      
    signal addr      : std_logic_vector(3 downto 0) := (others => '0'); -- Dirección de memoria
    signal rom_data  : std_logic_vector(7 downto 0);    -- Dato leído de la ROM
    signal ram_data  : std_logic_vector(7 downto 0);    -- Dato leído de la RAM
    signal rd_en      : std_logic := '0';               -- Habilitador de lectura RAM
    signal wr_en      : std_logic := '0';               -- Habilitador de escritura RAM

   
    signal rst_sync     : std_logic := '1';
    signal rst_sync2    : std_logic := '1';
    signal start_sync   : std_logic := '1';
    signal start_sync2  : std_logic := '1';
    signal start_prev   : std_logic := '1'; -- Para detectar el flanco de bajada

  
    signal numero_decimal : integer range 0 to 255 := 0;
    signal centenas_ascii : std_logic_vector(7 downto 0);
    signal decenas_ascii  : std_logic_vector(7 downto 0);
    signal unidades_ascii : std_logic_vector(7 downto 0);

    
    signal mostrar_cero : std_logic;

begin

    -- Instancia del divisor: Reduce la velocidad del reloj según el selector
    DIV1: divisor_frecuencia
        port map (
            clk_entrada => clk,
            selector    => selector,
            clk_salida  => clk_lento
        );

    -- Instancia de la ROM: Contiene los datos predefinidos
    ROM1: rom_sync
        port map (
            clk      => clk_lento,
            addr     => addr,
            data_out => rom_data
        );

    -- Instancia de la RAM: Donde se copiarán los datos de la ROM
    RAM1: ram_sincrona
        port map (
            clk      => clk_lento,
            rd_en    => rd_en,
            wr_en    => wr_en,
            addr     => addr,
            data_in  => rom_data, -- La entrada de la RAM es la salida de la ROM
            data_out => ram_data
        );

    
    process(clk_lento)
    begin
        if rising_edge(clk_lento) then
            rst_sync    <= rst;
            rst_sync2   <= rst_sync;

            start_sync  <= start;
            start_sync2 <= start_sync;
            start_prev  <= start_sync2; -- Almacena el valor anterior para detectar cambios
        end if;
    end process;

    
    process(clk_lento)
    begin
        if rising_edge(clk_lento) then
            case state is

                -- Estado inicial espera la señal del boton start
                when PARADO =>
                    rd_en <= '0';
                    wr_en <= '0';
                    if start_prev = '1' and start_sync2 = '0' then 
                        addr  <= (others => '0');
                        state <= LEER_ROM;
                    end if;

                -- Lectura
                when LEER_ROM =>
                    rd_en <= '0';
                    wr_en <= '0';
                    state <= GUARDAR_EN_RAM;

                -- Paso de la rom a la ram 
                when GUARDAR_EN_RAM =>
                    wr_en <= '1';
                    rd_en <= '0';
                    state <= LEER_DE_RAM;

                --enviar el dato a los decodificadores
                when LEER_DE_RAM =>
                    wr_en <= '0';
                    rd_en <= '1';
                    state <= ESPERAR;

                when ESPERAR =>
                    wr_en <= '0';
                    rd_en <= '0';
                    if addr < "0011" then 
                        addr <= std_logic_vector(unsigned(addr) + 1);
                    else
                        addr <= (others => '0');
                    end if;
                    state <= LEER_ROM; -- Vuelve a empezar el ciclo de lectura/escritura

            end case;
        end if;
    end process;

    mostrar_cero <= '1' when (rst_sync2 = '0' or state = PARADO) else '0';

    numero_decimal <= 0 when mostrar_cero = '1' else to_integer(unsigned(ram_data));

   
    process(numero_decimal)
        variable centenas_digit : integer range 0 to 9;
        variable decenas_digit  : integer range 0 to 9;
        variable unidades_digit : integer range 0 to 9;
    begin
        centenas_digit := numero_decimal / 100;
        decenas_digit  := (numero_decimal mod 100) / 10;
        unidades_digit := numero_decimal mod 10;

     
        centenas_ascii <= std_logic_vector(to_unsigned(centenas_digit + 48, 8));
        decenas_ascii  <= std_logic_vector(to_unsigned(decenas_digit  + 48, 8));
        unidades_ascii <= std_logic_vector(to_unsigned(unidades_digit + 48, 8));
    end process;

  
    DEC_U: dec7seg port map (char => unidades_ascii, seg => seg_out_u);
    DEC_D: dec7seg port map (char => decenas_ascii,  seg => seg_out_d);
    DEC_C: dec7seg port map (char => centenas_ascii, seg => seg_out_c);

end Behavioral;
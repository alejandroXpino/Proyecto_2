library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package mem_pkg is

    constant DATA_WIDTH : integer := 8;
    constant ADDR_WIDTH : integer := 4;

    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    subtype addr_t is std_logic_vector(ADDR_WIDTH-1 downto 0);

    -- ================= ROM =================
    component rom_sync
        generic (
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4
        );
        port (
            clk      : in  std_logic;
            addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- ================= RAM =================
    component ram_sincrona
        generic (
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4;
            RDW_MODE   : string   := "READ_FIRST"
        );
        port (
            clk      : in  std_logic;
            rd_en    : in  std_logic;
            wr_en    : in  std_logic;
            addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

end package;

package body mem_pkg is
end package body;
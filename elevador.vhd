Library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity elevador is
Port(clk_master: in std_logic;
	  segmentos: out std_logic_vector(6 downto 0);
	  segmentos2: out std_logic_vector(6 downto 0); --quitar dsp
	  filas: out std_logic_vector(3 downto 0);
	  columnas: in std_logic_vector(2 downto 0);
	  leds: out std_logic_vector(9 downto 0);
	  wr: in std_logic);
end elevador;

architecture comportamiento of elevador is
	signal clk_200Hz, clk_1Hz, clk_02Hz, bandera: std_logic;
	signal reinicia, inicia: std_logic;
	signal valorRegistro: integer range 0 to 9 := 0; --[0..9]
	signal valorDeco: integer range 0 to 9; --[0..9]
	signal piso: integer range 0 to 9 := 0;
	signal valorTeclado: integer range 0 to 12 := 0;
	signal fila: integer range 0 to 3 := 0;
	signal digito: integer range 0 to 16 := 0;
	signal teclaPrecionada: std_logic := '0';
	signal estado: integer range 0 to 1 := 0;
	signal respuesta: std_logic := '0';
	signal detectaPiso: std_logic;
	--Registros de botones
	signal reg_b1 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b2 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b3 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b4 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b5 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b6 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b7 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b8 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b9 : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_b0 : std_logic_vector(7 downto 0) := (others => '0'); 
	signal reg_basterisco : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_bgato : std_logic_vector(7 downto 0) := (others => '0');
	
	begin 
		
		divisor_de_frecuencia: process(clk_master)
			variable contador: integer range 0 to 124_999_999 := 0;
			begin
				if rising_edge(clk_master) then
					if (contador = 124_999) then
						clk_200hz <= not clk_200Hz;
						bandera <= '1';
					elsif(contador = 24_999_999) then
						clk_1Hz <= not clk_1Hz;
					elsif(contador = 24_999_999) then
						clk_02Hz <= not clk_02Hz;
					else 
						contador := contador + 1;
						bandera <= '0';
					end if;
				end if;
		end process;
		
		sondeo_filas: process(clk_200Hz)
			begin
				if rising_edge(clk_200Hz) then
					if fila = 3 then 
						fila <= 0;
					else
						fila <= fila + 1;
					end if;
				end if;
				
				case fila is
				when 0 => 
					filas <= "0001";
				when 1 =>
					filas <= "0010";
				when 2 =>
					filas <= "0100";
				when 3 =>
					filas <= "1000";
			end case;
		end process;
		
		sondeo_columnas: process(columnas, clk_200Hz)
		begin
			if rising_edge(clk_200Hz) then
				if fila = 0 then --primera fila
					reg_b1 <= reg_b1(6 downto 0)&columnas(0);
					reg_b2 <= reg_b2(6 downto 0)&columnas(1);
					reg_b3 <= reg_b3(6 downto 0)&columnas(2);
				elsif fila = 1 then --segunda fila
					reg_b4 <= reg_b4(6 downto 0)&columnas(0);
					reg_b5 <= reg_b5(6 downto 0)&columnas(1);
					reg_b6 <= reg_b6(6 downto 0)&columnas(2);
				elsif fila = 2 then --tercera fila
					reg_b7 <= reg_b7(6 downto 0)&columnas(0);
					reg_b8 <= reg_b8(6 downto 0)&columnas(1);
					reg_b9 <= reg_b9(6 downto 0)&columnas(2);
				elsif fila = 3 then -- cuarta fila
					reg_basterisco <= reg_basterisco(6 downto 0)&columnas(2);
					reg_b0 <= reg_b0(6 downto 0)&columnas(1);
					reg_bgato <= reg_bgato(6 downto 0)&columnas(0);
				end if;
			end if;
		end process;
		
		respuesta_teclado: process(clk_200Hz)
			begin 
				if rising_edge(clk_200Hz) then
					if reg_b0 = "1111111" then
						digito <= 0;
						teclaPrecionada <= '1';
					elsif reg_b1 = "1111111" then
						digito <= 1;
						teclaPrecionada <= '1';
					elsif reg_b2 = "1111111" then
						digito <= 2;
						teclaPrecionada <= '1';
					elsif reg_b3 = "1111111" then
						digito <= 3;
						teclaPrecionada <= '1';
					elsif reg_b4 = "1111111" then
						digito <= 4;
						teclaPrecionada <= '1';
					elsif reg_b5 = "1111111" then
						digito <= 5;
						teclaPrecionada <= '1';
					elsif reg_b6 = "1111111" then
						digito <= 6;
						teclaPrecionada <= '1';
					elsif reg_b7 = "1111111" then
						digito <= 7;
						teclaPrecionada <= '1';
					elsif reg_b8 = "1111111" then
							digito <= 8;
							teclaPrecionada <= '1';
					elsif reg_b9 = "1111111" then
							digito <= 9;
							teclaPrecionada <= '1';
					elsif reg_basterisco = "1111111" then
							digito <= 10;
							teclaPrecionada <= '1';
					elsif reg_bgato = "1111111" then
							digito <= 11;
							teclaPrecionada <= '1';
					else 
						teclaPrecionada <= '0';
					end if;
				end if;
		end process;
		
		indicador_tecla: process(clk_200Hz)
			begin
				if rising_edge(clk_200Hz) then
				if estado = 0 then
					if teclaPrecionada = '1' then
						respuesta <= '1';
						estado <= 1;
					else
						estado <= 0;
						respuesta <= '0';
					end if;
				else
					if teclaPrecionada = '1' then
						estado <= 1;
						respuesta <= '0';
					else
						estado <= 0;
					end if;
				end if;
			end if;
		end process;
		
		deco_Tec: process(digito)
		begin
			if teclaPrecionada = '1' then 
				if(digito = 10) then
					reinicia <= '1';
					detectaPiso <= '0';
				elsif(digito = 11) then
					inicia <= '1';
					reinicia <= '0';
					detectaPiso <= '0';
				else 
					valorDeco <= digito;
					reinicia <= '0';
					detectaPiso <= '1';
				end if;
			end if;
		end process;
		
		reg1: process(clk_1Hz, wr, detectaPiso)
		begin
			if(wr = '0' and detectaPiso = '1') then
				valorRegistro <= valorDeco;
			end if;
		end process;
		
		contador: process(clk_1Hz, valorRegistro, reinicia, inicia)
		begin
			if reinicia = '1' then
				piso <= 0; 
			elsif rising_edge(clk_1Hz) then
				if inicia = '1' then
					if piso < valorRegistro then
						piso <= piso + 1;
					elsif piso > valorRegistro then
						piso <= piso - 1;
					else 
						piso <= piso;
					end if;
				end if;
			end if;	
		end process;
		
		decoluces: process(piso)
		begin
			case piso is
				when 0 =>
					segmentos <= "0000001";
					leds <= "0000000001";
				when 1 =>
					segmentos <= "1001111";
					leds <="0000000010";
				when 2 =>
					segmentos <= "0010010";
					leds <= "0000000100";
				when 3 =>
					segmentos <= "0000110";
					leds <= "0000001000";
				when 4 =>
					segmentos <= "1001100";
					leds <= "0000010000";
				when 5 =>
					segmentos <= "0100100";
					leds <= "0000100000";
				when 6 =>
					segmentos <= "0100000";
					leds <= "0001000000";
				when 7 =>
					segmentos <= "0001111";
					leds <= "0010000000";
				when 8 =>
					segmentos <= "0000000";
					leds <= "0100000000";
				when others =>
					segmentos <= "0000100";
					leds <= "1000000000";
				end case;
		end process;
		
		
		with valorRegistro select
		segmentos2 <= "0000001" when 0, 
						 "1001111" when 1, 
						 "0010010" when 2, 
						 "0000110" when 3, 
						 "1001100" when 4, 
						 "0100100" when 5, 
						 "0100000" when 6, 
						 "0001111" when 7, 
						 "0000000" when 8, 
						 "0000100" when 9,
						 --"0001000" when 10,
						 --"1100000" when 11,
						 "1111111" when others; --F
end comportamiento;






















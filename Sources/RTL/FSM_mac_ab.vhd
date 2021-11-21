----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/21/2021 07:09:07 PM
-- Design Name: 
-- Module Name: FSM_mac_ab - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_mac_ab is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (0 downto 0);
           b : in STD_LOGIC_VECTOR (0 downto 0);
           t_mac_in : in STD_LOGIC_VECTOR (0 downto 0);
           t_adder_in : in STD_LOGIC_VECTOR (0 downto 0);
           t_mac_out : out STD_LOGIC_VECTOR (0 downto 0);
           c_mac_out : out STD_LOGIC_VECTOR (0 downto 0));
end FSM_mac_ab;

architecture Behavioral of FSM_mac_ab is

begin


end Behavioral;

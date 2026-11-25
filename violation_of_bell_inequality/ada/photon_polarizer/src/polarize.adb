
--  with Ada.Float_Text_IO; use Ada.Float_Text_IO;
--  with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Text_IO; use Ada.Text_IO;

with Polarizer_Model; use Polarizer_Model;
--  with Maths; use Maths;

procedure Polarize is
   N            : constant Positive := 100_000;
   Single_0     : constant Polarizer_Train := (1 => Create_Polarizer (0.0));
   Crossed_0_90 : constant Polarizer_Train :=
     (Create_Polarizer (0.0), Create_Polarizer (90.0));
   Three_Pol   : constant Polarizer_Train :=
     (Create_Polarizer (0.0), Create_Polarizer (45.0),
       Create_Polarizer (90.0));
   Imperfect   : constant Polarizer_Train :=
     (Create_Polarizer (0.0, 30.0), Create_Polarizer (90.0, 30.0));
begin
   Put_Line ("Polarizer Simulator");
   Print_Result
     ("1. Unpolarized -> 0 deg          ",
      Simulate_Beam (N, Single_0, Unpolarized => True), 0.5000);

   Print_Result
     ("2. Crossed (0 deg -> 90 deg)     ",
      Simulate_Beam (N, Crossed_0_90, Unpolarized => True), 0.0000);

   Print_Result
     ("3. 3-Polarizer (0 -> 45 -> 90)   ",
      Simulate_Beam (N, Three_Pol, Unpolarized => True), 0.1250);

   Print_Result
     ("4. Imperfect 0 -> 90 (30 dB ER)  ",
      Simulate_Beam (N, Imperfect, Unpolarized => True), 0.0005);

end Polarize;


--  with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Text_IO; use Ada.Text_IO;

with Polarizer_Model; use Polarizer_Model;
with Maths; use Maths;
with Simulate; use Simulate;

procedure Polarize is
   a       : constant Long_3D_Vector := (0.0, 0.5, 0.0);
   b       : constant Long_3D_Vector := (0.5, 0.5, 0.0);
   lambda  : constant Long_3D_Vector := (0.5, -0.3, 0.6);
   --  Result  : constant Long_Float := AB (a, b, lambda);
   Theta_I : constant Long_Float := Pi / 10.0;
   Trans_1 : Transmission_Operator;  --  Green
   Trans_2 : Transmission_Operator;  --  Violet
begin
   Put_Line ("Polarizer Simulator");
   Print_Result
     ("1. Unpolarized -> 0 deg          ",
      Simulate_Beam (N, Single_0, Unpolarized => True),
      0.5000);

   Print_Result
     ("2. Crossed (0 deg -> 90 deg)     ",
      Simulate_Beam (N, Crossed_0_90, Unpolarized => True),
      0.0000);

   Print_Result
     ("3. 3-Polarizer (0 -> 45 -> 90)   ",
      Simulate_Beam (N, Three_Pol, Unpolarized => True),
      0.1250);

   Print_Result
     ("4. Imperfect 0 -> 90 (30 dB ER)  ",
      Simulate_Beam (N, Imperfect, Unpolarized => True),
      0.0005);

end Polarize;

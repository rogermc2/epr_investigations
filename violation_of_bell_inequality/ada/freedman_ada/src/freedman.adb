
--  with Ada.Float_Text_IO; use Ada.Float_Text_IO;
--  with Ada.Numerics; use Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;

with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;
with Maths; use Maths;
with Simulate; use Simulate;

procedure Freedman is
   a       : constant Long_3D_Vector := (0.0, 0.5, 0.0);
   b       : constant Long_3D_Vector := (0.5, 0.5, 0.0);
   lambda  : constant Long_3D_Vector := (0.5, -0.3, 0.6);
   --  Result  : constant Long_Float := AB (a, b, lambda);
   Theta_I : constant Long_Float := Pi / 10.0;
   Trans_1 : Transmission_Operator;  --  Green
   Trans_2 : Transmission_Operator;  --  Violet
begin
   Put_Line ("Freedman Simulator");
   --  Put (Result);
   Trans_1 := Initialize_Polarizer (Green_551nm, Theta_I);
   Trans_2 := Initialize_Polarizer (Violet_423nm, Theta_I);

end Freedman;

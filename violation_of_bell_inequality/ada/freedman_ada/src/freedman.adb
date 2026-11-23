
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
--  with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Real_Arrays; use Ada.Numerics.Real_Arrays;
with Ada.Text_IO; use Ada.Text_IO;

with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;
with Maths; use Maths;
with Polarizer; use Polarizer;

procedure Freedman is
   a      : constant Real_Vector := (0.0, 0.5, 0.0);
   b      : constant Real_Vector := (0.5, 0.5, 0.0);
   lambda : constant Real_Vector := (0.5, -0.3, 0.6);
   Result : constant Float := AB (a, b, lambda);
   Theta_I : constant Long_Float := Pi /10.0;
   Transmittance : Ray_Transmittance;
begin
   Put_Line ("Hello!");
   Put (Result);

   Test_Polarize;
   Transmittance := Evaluate_Ray (Green_551nm, Theta_I);
   
end Freedman;


with Ada.Float_Text_IO;
--  with Ada.Numerics; use Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;

with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;
--  with Maths; use Maths;

procedure Freedman is
   --  a       : constant Long_3D_Vector := (0.0, 0.5, 0.0);
   --  b       : constant Long_3D_Vector := (0.5, 0.5, 0.0);
   --  lambda  : constant Long_3D_Vector := (0.5, -0.3, 0.6);
   --  Result  : constant Long_Float := AB (a, b, lambda);
   --  Theta_I : constant Long_Float := Pi / 10.0;
   --  Trans_1 : Transmission_Operator;  --  Green
   --  Trans_2 : Transmission_Operator;  --  Violet

   N          : constant Positive := 500_000;
   Angles     : constant array (1 .. 5) of Float :=
    (0.0, 22.5, 45.0, 67.5, 90.0);
   Sim_Val    : Float;
   Theory_Val : Float;
begin
   Put_Line
      ("Freedman (1972) Pile-of-Plates Coincidence Simulation R(phi)/R0");

   for Phi of Angles loop
      Sim_Val := Simulate_Freedman_Coincidence (N, 0.0, Phi);
      Theory_Val := Freedman_Theory_Ratio (Phi);

      Ada.Text_IO.Put ("Angle ");
      Ada.Float_Text_IO.Put (Phi, Fore => 2, Aft => 1, Exp => 0);
      Ada.Text_IO.Put (" deg -> Simulated: ");
      Ada.Float_Text_IO.Put (Sim_Val, Fore => 1, Aft => 4, Exp => 0);
      Ada.Text_IO.Put (" | Freedman Eq: ");
      Ada.Float_Text_IO.Put (Theory_Val, Fore => 1, Aft => 4, Exp => 0);
      New_Line;
   end loop;

end Freedman;

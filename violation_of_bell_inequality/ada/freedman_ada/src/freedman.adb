
with Ada.Float_Text_IO;
with Ada.Text_IO; use Ada.Text_IO;

with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;
with Random_Unit_Vectors;

procedure Freedman is
   N          : constant Positive := 500_000;
   Angles     : constant array (1 .. 5) of Float :=
    (0.0, 22.5, 45.0, 67.5, 90.0);
   Sim_Val    : Float;
   Theory_Val : Float;
begin
   Put_Line
      ("Freedman (1972) Pile-of-Plates Coincidence Simulation R(phi)/R0");
   Random_Unit_Vectors.Test_Random_Unit_Vectors;
   for Phi of Angles loop
      Sim_Val := Simulate_Coincidence (N, 0.0, Phi);
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

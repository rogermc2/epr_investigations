
with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;

package body Simulate is

   procedure Initialize_Polarizer
      (Arm : out Polarizer_Arm; Theta_I : Long_Float := 0.0) is
      Trans : Ray_Transmittance := Evaluate_Ray (Arm, Theta_I);
   begin
      null;
   end Initialize_Polarizer;

   procedure Simulate_Measurement_System is
   begin
      null;
   end Simulate_Measurement_System;

end Simulate;
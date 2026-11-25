
with Freedman_Polarizer_Model; use Freedman_Polarizer_Model;
with Maths; use Maths;

package Simulate is

   function Initialize_Polarizer (Arm : Polarizer_Arm;
      Theta_I : Long_Float := 0.0) return Transmission_Operator;
   function Rotated_Operator
      (OP_In : Transmission_Operator; Angle : Long_Float)
       return Transmission_Operator;
   procedure Simulate_Measurement_System;

end Simulate;
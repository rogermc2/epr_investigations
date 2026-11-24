
with Ada.Numerics.Long_Elementary_Functions;

package body Simulate is

   function Initialize_Polarizer
      (Arm : Polarizer_Arm; Theta_I : Long_Float := 0.0)
          return Transmission_Operator is
      Trans : constant Ray_Transmittance := Evaluate_Ray (Arm, Theta_I);
      --  Op    : Transmission_Operator :=
      --     ((Trans.T_Parallel, 0.0), (0.0, Trans.T_Perp));
   begin
      return ((Trans.T_Parallel, 0.0), (0.0, Trans.T_Perp));

   end Initialize_Polarizer;

   function Rotated_Operator
      (OP_In : Transmission_Operator; Angle : Long_Float)
       return Transmission_Operator is
      use Ada.Numerics.Long_Elementary_Functions;
      Cos_2_Phi : constant Long_Float := Cos (2.0 * Angle);
      Sin_2_Phi : constant Long_Float := Sin (2.0 * Angle);
      EMpEm     : constant Long_Float := 0.5 * (OP_In (1, 1) + OP_In (2, 2));
      EMmEm     : constant Long_Float := 0.5 * (OP_In (1, 1) + OP_In (2, 2));
      Result    : Transmission_Operator;
   begin
      Result (1, 1) := EMpEm + EMmEm * Cos_2_Phi;
      Result (1, 2) := EMmEm * Sin_2_Phi;
      Result (2, 1) := EMmEm * Sin_2_Phi;
      Result (2, 2) := EMpEm - EMmEm * Cos_2_Phi;

      return Result;

   end Rotated_Operator;

   procedure Simulate_Measurement_System is
   begin
      null;
   end Simulate_Measurement_System;

end Simulate;
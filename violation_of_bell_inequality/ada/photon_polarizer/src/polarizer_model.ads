
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;

package Polarizer_Model is

   --  Core Quantum & Optical Data Types
   type Jones_Vector is record
      Ex : Complex;
      Ey : Complex;
   end record;
   type Jones_Matrix is array (1 .. 2, 1 .. 2) of Complex;

   type Linear_Polarizer is record
      Matrix : Jones_Matrix;
   end record;
   type Polarizer_Train is array (Positive range <>) of Linear_Polarizer;

   function Create_Polarizer (Angle_Deg : Float;
      Extinction_Ratio_dB : Float := -1.0) return Linear_Polarizer;
   procedure Print_Result (Label : String; Measured, Theory : Float);
   function Simulate_Beam (Num_Photons : Positive; Train : Polarizer_Train;
      Polarized : Boolean := True; Init_Angle_Deg : Float := 0.0;
      Seed : Integer := 42) return Float;

end Polarizer_Model;
 
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;

package Polarizer_Model is
 
 --  1. Core Quantum & Optical Data Types
   type Jones_Vector is record
      Ex : Complex;
      Ey : Complex;
   end record;

   type Jones_Matrix is array (1 .. 2, 1 .. 2) of Complex;

   type Linear_Polarizer is record
      Matrix : Jones_Matrix;
   end record;

   type Polarizer_Train is array (Positive range <>) of Linear_Polarizer;

  procedure Print_Result (Label : String; Measured, Theory : Float);

end Polarizer_Model;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
--  with Ada.Numerics.Complex_Arrays; use Ada.Numerics.Complex_Arrays;
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Random_Unit_Vectors is

   Gen : Generator;

   --  The most accurate way to generate a uniformly distributed random
   --  3D unit vector in Ada is to use spherical coordinates with
   --  inverse transform sampling (Marsaglia's method).
   --  Uniformity z and theta:
   --  On a sphere, surface area is proportional to dz/dtheta.
   --  By drawing z uniformly from [-1, 1] and theta uniformly from [0, 2\pi)
   --  every equal-area patch on the sphere has an equal probability of being
   --  chosen.
   function Random_Complex_Unit_Vector (G : Generator)
      return Complex_Vector_3D is
      --  1. Sample Z uniformly in [-1.0, 1.0] (Archimedes' hat-box theorem)
      Z      : constant Float   := 2.0 * Random (G) - 1.0;
      --  2. Sample azimuthal angle Theta uniformly in [0.0, 2*Pi)
      Theta  : constant Float   := 2.0 * Pi * Random (G);
      --  3. Compute radius in the XY-plane (Max guards against -0.0 rounding)
      Radius : constant Float   := Sqrt (Float'Max (0.0, 1.0 - Z * Z));
      --  4. Project onto XY-plane
      XY     : constant Complex := Compose_From_Polar (Radius, Theta);
   begin
      return ((XY.Re, 0.0), (XY.Im, 0.0), (Z, 0.0));

   end Random_Complex_Unit_Vector;

   function Random_Real_Unit_Vector (G : Generator) return Real_Vector_3D is

      --  1. Sample Z uniformly in [-1.0, 1.0]
      Z      : constant Float := 2.0 * Random (G) - 1.0;
      --  2. Sample azimuthal angle Theta uniformly in [0.0, 2*Pi)
      Theta  : constant Float := 2.0 * Pi * Random (G);
      --  3. Compute radius in the XY-plane
      Radius : constant Float := Sqrt (1.0 - Z * Z);
   begin

      return (Radius * Cos (Theta), Radius * Sin (Theta), Z);

   end Random_Real_Unit_Vector;

   --  Helper function to verify the vector's magnitude is 1.0
   function Magnitude (V : Real_Vector_3D) return Float is
   begin
      return Sqrt (V (1) * V (1) + V (2) * V (2) + V (3) * V (3));

   end Magnitude;

   function Magnitude (V : Complex_Vector_3D) return Float is
   begin
      return Sqrt (abs (V (1)) * abs (V (1)) + abs (V (2)) * abs (V (2)) +
                   abs (V (3)) * abs (V (3)));

   end Magnitude;

   procedure Test_Random_Unit_Vectors is
      Vec : Complex_Vector_3D;
   begin
      --  Seed the random number generator using the system clock
      Reset (Gen);

      Put_Line ("Generating 5 uniform random 3D unit vectors:");
      New_Line;
      for I in 1 .. 5 loop
         Vec := Random_Complex_Unit_Vector (Gen);
         Put ("Vector" & Integer'Image (I) & ": (");
         Put (abs (Vec (1)), Fore => 2, Aft => 5, Exp => 0);
         Put (", ");
         Put (abs (Vec (2)), Fore => 2, Aft => 5, Exp => 0);
         Put (", ");
         Put (abs (Vec (3)), Fore => 2, Aft => 5, Exp => 0);
         Put (") | Mag: ");
         Put (Magnitude (Vec), Fore => 1, Aft => 5, Exp => 0);
         New_Line;
      end loop;
      Put_Line ("Test_Random_Unit_Vectors completed");
      
   end Test_Random_Unit_Vectors;

end Random_Unit_Vectors;
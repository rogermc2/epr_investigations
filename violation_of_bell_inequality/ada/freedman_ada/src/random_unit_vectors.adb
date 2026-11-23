
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Random_Unit_Vectors is

  Gen : Generator;

  function Random_Unit_Vector (G : Generator) return Vector_3D is
      Z    : Float;
      Theta : Float;
      R     : Float;
  begin
    --  1. Sample Z uniformly in [-1.0, 1.0]
    Z := 2.0 * Random (G) - 1.0;

    --  2. Sample azimuthal angle Theta uniformly in [0.0, 2*Pi)
    Theta := 2.0 * Pi * Random (G);

    --  3. Compute radius in the XY-plane
    R := Sqrt (1.0 - Z * Z);

    return (R * Cos (Theta), Y => R * Sin (Theta), Z);

  end Random_Unit_Vector;

  --  Helper function to verify the vector's magnitude is 1.0
   function Magnitude (V : Vector_3D) return Float is
   begin
      return Sqrt (V.X * V.X + V.Y * V.Y + V.Z * V.Z);
   end Magnitude;

procedure Test_Random_Unit_Vectors is
   Vec : Vector_3D;
begin
   --  Seed the random number generator using the system clock
   Reset (Gen);

   Put_Line ("Generating 5 uniform random 3D unit vectors:");
   New_Line;
   for I in 1 .. 5 loop
      Vec := Random_Unit_Vector (Gen);
      Put ("Vector" & Integer'Image (I) & ": (");
      Put (Vec.X, Fore => 2, Aft => 5, Exp => 0);
      Put (", ");
      Put (Vec.Y, Fore => 2, Aft => 5, Exp => 0);
      Put (", ");
      Put (Vec.Z, Fore => 2, Aft => 5, Exp => 0);
      Put (") | Mag: ");
      Put (Magnitude (Vec), Fore => 1, Aft => 5, Exp => 0);
      New_Line;
   end loop;
end Test_Random_Unit_Vectors;

end Random_Unit_Vectors;
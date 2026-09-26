with Ada.Numerics.Float_Random;
with Ada.Numerics.Elementary_Functions;

package body Random_Pair is

   package FR renames Ada.Numerics.Float_Random;
   package EF renames Ada.Numerics.Elementary_Functions;

   Gen : FR.Generator;

   procedure Random_Perpendicular_Unit_Vectors
     (U, V : out Vector_3D)
   is
      Pi : constant Float := Ada.Numerics.Pi;
      Z, Phi : Float;
      Rxy    : Float;
      --  Random angle used to choose V in the plane
      --  perpendicular to U.
      Alpha : Float;
      --  Orthonormal basis for the plane perpendicular to U
      E1, E2 : Vector_3D;
      S : Float;
   begin
      --  Uniformly distributed U on the unit sphere.
      --  z is uniform in [-1,1], phi uniform in [0,2*pi).
      Z   := 2.0 * FR.Random (Gen) - 1.0;
      Phi := 2.0 * Pi * FR.Random (Gen);
      Rxy := EF.Sqrt (1.0 - Z * Z);
      U :=
        (1 => Rxy * EF.Cos (Phi),
         2 => Rxy * EF.Sin (Phi),
         3 => Z);

      --  Construct one unit vector E1 perpendicular to U.
      --  Since U(1)^2 + U(2)^2 = Rxy^2, this is convenient
      --  except very close to the poles.
      S := EF.Sqrt (U (1) * U (1) +
                    U (2) * U (2));

      if S > 1.0E-6 then
         E1 :=
           (1 => -U (2) / S,
            2 =>  U (1) / S,
            3 =>  0.0);
      else
         --  U is essentially parallel to the z axis.
         E1 := (1 => 1.0,
                2 => 0.0,
                3 => 0.0);
      end if;

      --  E2 = U x E1
      E2 :=
        (1 => U (2) * E1 (3) - U (3) * E1 (2),
         2 => U (3) * E1 (1) - U (1) * E1 (3),
         3 => U (1) * E1 (2) - U (2) * E1 (1));

      --  Uniform random direction in the plane perpendicular to U.
      Alpha := 2.0 * Pi * FR.Random (Gen);

      V :=
        (1 => EF.Cos (Alpha) * E1 (1) +
              EF.Sin (Alpha) * E2 (1),

         2 => EF.Cos (Alpha) * E1 (2) +
              EF.Sin (Alpha) * E2 (2),

         3 => EF.Cos (Alpha) * E1 (3) +
              EF.Sin (Alpha) * E2 (3));
   end Random_Perpendicular_Unit_Vectors;

begin
   FR.Reset (Gen);
end Random_Pair;
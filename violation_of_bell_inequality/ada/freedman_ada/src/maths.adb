
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Maths is

   function Adot (a, lambda : Long_3D_Vector) return Long_Float is
   begin
      return (a * lambda);  --  Dot prdoct
   end Adot;

   function AB (a, b, lambda : Long_3D_Vector) return Long_Float is
   begin
      return Adot (a, lambda) * Adot (b, lambda);
   end AB;

   function Dot (A : Complex_Vector_3D; B : Real_Vector_3D) return Complex is
   begin
      return A (1) * B (1) + A (2) * B (2) + A (3) * B (3);
   end Dot;

   function Cross (A, B : Real_Vector_3D) return Real_Vector_3D is
   begin
      return (1 => A (2) * B (3) - A (3) * B (2),
            2 => A (3) * B (1) - A (1) * B (3),
            3 => A (1) * B (2) - A (2) * B (1));
   end Cross;

   --  Squared norm <psi | psi> = |Ex|^2 + |Ey|^2
   function Norm_Squared (Psi : Jones_Vector) return Float is
   begin
      return (Psi.Ex.Re ** 2 + Psi.Ex.Im ** 2) +
             (Psi.Ey.Re ** 2 + Psi.Ey.Im ** 2);

   end Norm_Squared;

   function Normalize (Psi : Jones_Vector) return Jones_Vector is
      Mag : constant Float := Sqrt (Norm_Squared (Psi));
   begin
      if Mag = 0.0 then
         raise Constraint_Error with "Zero-norm quantum state";
      end if;
      return (Ex => Psi.Ex / Mag, Ey => Psi.Ey / Mag);

   end Normalize;

   function To_Jones_Vector (E_3D : Complex_Vector_3D;
      K_Hat  : Real_Vector_3D;   --  Unit propagation vector
      Up_Ref  : Real_Vector_3D := (0.0, 1.0, 0.0)) return Jones_Vector is
      S_Hat, P_Hat : Real_Vector_3D;
      S_Norm       : Float;
      E_Long       : constant Complex := Dot (E_3D, K_Hat);
      E_Trans      : Complex_Vector_3D;
      Raw_Jones    : Jones_Vector;
   begin
      --  1. Remove any longitudinal component along K_Hat
      for I in 1 .. 3 loop
         E_Trans (I) := E_3D (I) - E_Long * K_Hat (I);
      end loop;

      --  2. Build local orthonormal basis
      --    (S_Hat, P_Hat) perpendicular to K_Hat
      S_Hat  := Cross (K_Hat, Up_Ref);
      S_Norm := Sqrt (S_Hat (1)**2 + S_Hat (2)**2 + S_Hat (3)**2);

      --  Handle gimbal lock if K_Hat is parallel to Up_Ref
      if S_Norm < 1.0E-6 then
         S_Hat  := Cross (K_Hat, (1.0, 0.0, 0.0));
         S_Norm := Sqrt (S_Hat (1)**2 + S_Hat (2)**2 + S_Hat (3)**2);
      end if;

      for I in 1 .. 3 loop
         S_Hat (I) := S_Hat (I) / S_Norm;
      end loop;
      P_Hat := Cross (K_Hat, S_Hat);

      --  3. Project onto local 2D plane and normalize
      Raw_Jones := (Ex => Dot (E_Trans, S_Hat),
                  Ey => Dot (E_Trans, P_Hat));

      return Normalize (Raw_Jones);

   end To_Jones_Vector;

end Maths;

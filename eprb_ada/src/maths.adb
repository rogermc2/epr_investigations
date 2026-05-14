
with Ada.Numerics; use Ada.Numerics;

package body Maths is

   --  NaN representation
   --  function NaN return Float is
   --     use Ada.Numerics.Elementary_Functions;
   --     X : constant Float := 0.0 / 0.0;
   --  begin
   --     return X;
   --  exception
   --     when others => return 0.0 / 0.0;
   --  end NaN;

   function Sign (X : Interfaces.C.double) return Integer is
   begin
      if X > 0.0 then
         return 1;
      elsif X < 0.0 then
         return -1;
      else
         return 0;
      end if;

   end Sign;

   --  Convert degrees to radians
   function To_Radians (Degrees : Float) return Float is
   begin
      return Degrees * Pi / 180.0;
   end To_Radians;

   function Linear_Space (Start_Val, End_Val : Float; Num : Positive)
                       return Float_Vector is
      Step   : constant Float :=  (End_Val - Start_Val) / Float (Num - 1);
      Result : Float_Vector;
   begin
      for I in 0 .. Num - 1 loop
         Result.Append (Start_Val + Step * Float (I));
      end loop;

      return Result;

   end Linear_Space;

end Maths;

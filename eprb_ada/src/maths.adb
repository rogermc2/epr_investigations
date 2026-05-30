
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;
with Ada.Text_IO; use Ada.Text_IO;

package body Maths is

   --  Random number generator for angles
   Gen : Float_Random.Generator;

   function Mean_Product (A, B : Float_Vector) return Float is
      use Float_Vector_Package;
      Curs_A  : Cursor := A.First;
      Curs_B  : Cursor := B.First;
      Sum_Val : Float := 0.0;
   begin
      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Sum_Val := Sum_Val + Element (Curs_A) * Element (Curs_B);
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      if Sum_Val > 0.00009 then
         return Sum_Val /
           Float (Integer'Min (Integer (Length (A)), Integer (Length (B))));
      else
         return 0.0;
      end if;

   end Mean_Product;

   function Mean_Product
     (Selector : Boolean_Vector; A, B : Result_Vector) return Float is
      use Boolean_Vector_Package;
      Curs    : Cursor := Selector.First;
      Sum_Val : Integer := 0;
      Index   : Natural := 0;
      Count   : Natural := 0;
   begin
      while Has_Element (Curs) loop
         Index := Index + 1;
         if Element (Curs) then
            Sum_Val := Sum_Val + A (Index).Outcome * B (Index).Outcome;
            Count := Count + 1;
         end if;
         Next (Curs);
      end loop;

      if Count > 0 then
         return Float (Sum_Val) / Float (Count);
      else
         return 0.0;
      end if;

   end Mean_Product;

   function QM_Func (A, Spin : Float) return Float is
      use Ada.Numerics.Elementary_Functions;
      Result : Float;
   begin
      if 0.4999 < Spin and then Spin < 0.50001 then
         Result := -Cos (A);
      else
         Result := Cos (2.0 * A);
      end if;

      return Result;

   end QM_Func;

   function Random_Index (Max : Positive) return Positive is
      Result : constant Positive :=
        Natural (abs (Float_Random.Random (Gen) * (Float (Max - 1)))) + 1;
   begin
      return Result;

   exception
      when Error : others =>
         Put_Line ("Maths.Random_Index Exception information:  " &
                     Exception_Information (Error));
         Put_Line ("Max, Result : " & Integer'Image (Max) & "  "  &
                     Integer'Image (Result));
         raise;

   end Random_Index;

   function Random_Settings_Choice (Settings : Settings_Vector)
                                    return Settings_Vector is
      use Settings_Vector_Package;
      Size   : constant Float := Float (Length (Settings));
      Index  : Positive;
      Result : Settings_Vector;
   begin
      if Integer (Length (Settings)) > 0 then
         declare
            Curs : Cursor := Settings.First;
         begin
            while Has_Element (Curs) loop
               Index := Integer (Float_Random.Random (Gen) * Size) + 1;
               if Index <= Integer (Length (Settings)) then
                  Result.Append (Element (To_Cursor (Settings, Index)));
               else
                  Result.Append
                    (Element (To_Cursor (Settings,
                     Integer (Length (Settings)))));
               end if;
               Next (Curs);
            end loop;
         end;
      else
         Put ("Maths Settings_Vector Random_Settings_Choice ");
         Put_Line ("called with empty settings vector.");
      end if;

      return Result;

   end Random_Settings_Choice;

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

   --  Python Vec.sum ()
   function Sum_Boolean (Vec : Boolean_Vector) return Natural is
      use Boolean_Vector_Package;
      Curs   : Cursor := Vec.First;
      Result : Natural := 0;
   begin
      while Has_Element (Curs) loop
         if Element (Curs) then
            Result := Result + 1;
         end if;
         Next (Curs);
      end loop;

      return Result;
   end Sum_Boolean;

   function To_Degrees (Angle : MilliRad) return Float is
   begin
      return Float (Angle / 1000) * 180.0 / Pi;
   end To_Degrees;

   function To_Degrees (Radians : Float) return Float is
   begin
      return Radians * 180.0 / Pi;
   end To_Degrees;

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

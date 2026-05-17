
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random;
with Ada.Text_IO;           use Ada.Text_IO;

package body Maths is

   --  Random number generator for angles
   Gen : Float_Random.Generator;

   --  NaN representation
   --  function NaN return Float is
   --     use Ada.Numerics.Elementary_Functions;
   --     X : constant Float := 0.0 / 0.0;
   --  begin
   --     return X;
   --  exception
   --     when others => return 0.0 / 0.0;
   --  end NaN;

   function Random_Choice (Settings : Float_Array) return Float is
      Index : Integer :=
        Integer (Float (Settings'Length) * Float_Random.Random (Gen)) + 1;
   begin
      --  Put_Line ("Maths Float_Array Random_Choice" );
      if Index > Settings'Length then
         Index := Settings'Length;
      elsif Index < 1 then
         Index := 1;
      end if;
      return Settings (Index);

   end Random_Choice;

   function Random_Choice (Settings : Settings_Vector)
                           return Settings_Vector is
      use Settings_Vector_Package;
      Size   : constant Float := Float (Length (Settings));
      Index  : Positive;
      Result : Settings_Vector;
   begin
      if Integer (Length (Settings)) > 0 then
         declare
            Curs   : Cursor := Settings.First;
         begin
            while Has_Element (Curs) loop
               Index := Integer (Float_Random.Random (Gen) * Size) + 1;
               --  Put_Line ("Index: " & Integer'Image (Index));
               if Index <= Integer (Length (Settings)) then
                  Result.Append (Element (To_Cursor (Settings, Index)));
               else
                  Result.Append (Element (To_Cursor (Settings, Integer (Length (Settings)))));
               end if;
               Next (Curs);
            end loop;
         end;
      else
         Put ("Maths Settings_Vector Random_Choice ");
         Put_Line ("called with empty settings vector.");
      end if;

      return Result;

   end Random_Choice;

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

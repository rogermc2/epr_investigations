
with Ada.Containers.Ordered_Sets;
--  with Ada.Numerics.Elementary_Functions;
--  with Ada.Text_IO; use Ada.Text_IO;

package body Vector_Functions is

   function Abs_Vector (Vec : Result_Vector) return Natural_Vector is
      use Result_Vector_Package;
      Curs   : Cursor := Vec.First;
      Item   : Result_Data;
      Result : Natural_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Result.Append (abs (Item.Outcome));
         Next (Curs);
      end loop;

      return Result;

   end Abs_Vector;

   function Angles_Vector_To_Array
     (Settings : Settings_Vector) return Float_Array is
      use Settings_Vector_Package;
      Curs       : Cursor := Settings.First;
      Temp_Array : Float_Array  (1 .. Integer (Length (Settings)));
      Index      : Natural := 0;
   begin
      while Has_Element (Curs) loop
         Index := Index + 1;
         Temp_Array (Index) := Element (Curs);
         Next (Curs);
      end loop;
      return Temp_Array;

   end Angles_Vector_To_Array;

   function Coincidence (Prod : Float_Vector) return Boolean_Vector is
      use Float_Vector_Package;
      Curs   : Cursor := Prod.First;
      Item   : Float;
      Result : Boolean_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Result.Append (abs (Item) = 1.0);
         Next (Curs);
      end loop;
      return Result;

   end Coincidence;

   function Filter_Rows (Vec : Result_Vector; Mask : Boolean_Vector)
                         return Result_Vector is
      use Boolean_Vector_Package;
      Result : Result_Vector;
   begin
      for index in 1 .. Positive (Length (Mask)) loop
         if Mask (index) then
            Result.Append (Vec (index));
         end if;
      end loop;
      return Result;

   end Filter_Rows;

   function Get_Settings (Res : Result_Vector) return Settings_Vector is
      use Result_Vector_Package;
      Curs     : Cursor := Res.First;
      Settings : Settings_Vector;
   begin
      while Has_Element (Curs) loop
         Settings.Append (Element (Curs).Setting);
         Next (Curs);
      end loop;

      return Settings;

   end Get_Settings;

   function Mod_Vector (Vec_1, Vec_2 : Float_Vector) return Float_Vector is
      use Float_Vector_Package;
      Curs_1  : Cursor := Vec_1.First;
      Curs_2  : Cursor := Vec_2.First;
      Item_1  : Float;
      Item_2  : Float;
      Mod_1_2 : Float;
      Result  : Float_Vector;
   begin
      while Has_Element (Curs_1) and then Has_Element (Curs_2) loop
         Item_1 := Element (Curs_1);
         Item_2 := Element (Curs_2);

         if Item_2 = 0.0 then
            Mod_1_2 := Item_1;
         else
            Mod_1_2 := Item_1 - (Item_2 * (Item_1 / Item_2));
         end if;

         Result.Append (Mod_1_2);
         Next (Curs_1);
         Next (Curs_2);
      end loop;
      return Result;

   end Mod_Vector;

   function Parse_Floats (Str : String) return Float_Vector is
      use Float_Vector_Package;
      Result    : Float_Vector;
      Start_Pos : Natural := 0;
      Comma_Pos : Natural := 0;
      --  Val       : Float;

      procedure Form_Value (Val_Str : String) is
         --  Val_Str : String := Sub_Str;
         --  Val_Pos : Positive := Val_Str'First;
         --  Val_End : Positive := Val_Str'Last;
         Val_IO : Float := 0.0;
         --  Last : Positive;
      begin
         --  declare
         --     package Float_IO is new Ada.Float_Text_IO (Float);
         --     use Float_IO;
         --  begin
         Val_IO := Float'Value (Val_Str);

         Result.Append (Val_IO);
      end Form_Value;

   begin
      loop
         Comma_Pos := 0;
         for I in Start_Pos .. Str'Length loop
            if Str (I) = ',' then
               Comma_Pos := I;
               exit;
            end if;
         end loop;

         if Comma_Pos = 0 then
            declare
               Sub_Str : constant String := Str (Start_Pos .. Str'Last);
            begin
               Form_Value (Sub_Str);
            end;
         else
            declare
               Sub_Str : constant String :=
                 Str (Start_Pos .. Comma_Pos - 1);
            begin
               Form_Value (Sub_Str);
            end;
         end if;

         if Comma_Pos = 0 then
            exit;
         else
            Start_Pos := Comma_Pos + 1;
         end if;
      end loop;

      return Result;

   end Parse_Floats;

   function Product_Column2 (Vec_1, Vec_2 : Result_Vector)
                             return Natural_Vector is
      use Result_Vector_Package;
      Curs_1  : Cursor := Vec_1.First;
      Curs_2  : Cursor := Vec_2.First;
      Item_1  : Result_Data;
      Item_2  : Result_Data;
      Result  : Natural_Vector;
   begin
      while Has_Element (Curs_1) and then Has_Element (Curs_2) loop
         Item_1 := Element (Curs_1);
         Item_2 := Element (Curs_2);
         Result.Append (Item_1.Outcome * Item_2.Outcome);
         Next (Curs_1);
         Next (Curs_2);
      end loop;
      return Result;

   end Product_Column2;

   function Sample_Mean (Vec : Natural_Vector) return Float is
      use Natural_Vector_Package;
      Curs : Cursor := Vec.First;
      Sum  : Integer := 0;
   begin
      while Has_Element (Curs) loop
         Sum := Sum + Element (Curs);
         Next (Curs);
      end loop;
      return Float (Sum) / Float (Length (Vec));

   end  Sample_Mean;

   --  function Setting_Pairs (Setting_A, Setting_B : Float_Vector)
   --                          return Setting_Pairs_Vector is
   --     use Float_Vector_Package;
   --     Setting_Pairs : Setting_Pairs_Vector;
   --
   --     --  Compute Cartesian product of unique elements of adeg and bdeg
   --     Unique_A : constant Float_Vector := Unique (Setting_A);
   --     Unique_B : constant Float_Vector := Unique (Setting_B);
   --     Curs_A   : Cursor := Unique_A.First;
   --     Curs_B   : Cursor := Unique_B.First;
   --  begin
   --     while Has_Element (Curs_A) loop
   --        while Has_Element (Curs_B) loop
   --           Setting_Pairs.Append ((Element (Curs_A), Element (Curs_B)));
   --           Next (Curs_B);
   --        end loop;
   --        Next (Curs_A);
   --     end loop;
   --
   --     return Setting_Pairs;

   --  end Setting_Pairs;

   function Setting_Pairs (A, B : Result_Vector)
                           return Setting_Pairs_Vector is
      use Result_Vector_Package;
      --  Compute Cartesian product of unique elements of adeg and bdeg
      Item_A        : Result_Data;
      Item_B        : Result_Data;
      Curs_A        : Cursor := A.First;
      Curs_B        : Cursor := B.First;
      Setting_Pairs : Setting_Pairs_Vector;
   begin
      while Has_Element (Curs_A) loop
         Item_A := Element (Curs_A);
         while Has_Element (Curs_B) loop
            Item_B := Element (Curs_B);
            Setting_Pairs.Append ((Item_A.Setting, Item_B.Setting));
            Next (Curs_B);
         end loop;
         Next (Curs_A);
      end loop;

      return Setting_Pairs;

   end Setting_Pairs;

   function Unique (Vec : Float_Vector) return Float_Vector is
      package Float_Set is new Ada.Containers.Ordered_Sets (Float);
      use Float_Set;
      use Float_Vector_Package;
      Use_Set     : Float_Set.Set := Float_Set.Empty_Set;
      Curs        : Float_Vector_Package.Cursor := Vec.First;
      Item        : Float;
      Result_List : Float_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         if not Float_Set.Contains (Use_Set, Item) then
            Insert (Use_Set, Item);
            Result_List.Append (Item);
         end if;
         Next  (Curs);
      end loop;
      return Result_List;

   end Unique;

end Vector_Functions;

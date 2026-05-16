
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Numerics;
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Maths;

package body Vector_Functions is

   function Abs_Array (Arr : Raw_Data_Array; Col : Positive)
                        return Float_Array is
      Len : constant Positive := Arr'Length(1);
      Result : Float_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := Float'Magnitude(Arr(I, Col));
      end loop;
      return Result;
   end Abs_Array;

   --  Convert Angles_Vector to array for easier indexing
   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array is
      use Float_Vector_Package;
      Curs       : Cursor := Angles_Vector.First;
      Temp_Array : Float_Array  (1 .. Integer (Length (Angles_Vector)));
      Index      : Natural := 0;
   begin
      while Has_Element (Curs) loop
         Index := Index + 1;
         Temp_Array (Index) := Element (Curs);
         Next (Curs);
      end loop;
      return Temp_Array;

   end Angles_Vector_To_Array;

   -- Function to check if absolute value of product equals 1.0
   function Coincidence (Prod : Float_Array) return Boolean_Array is
      Len : constant Positive := Prod'Length;
      Result : Boolean_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := Float'Magnitude(Prod(I)) = 1.0;
      end loop;
      return Result;
   end Coincidence;

   -- Function to filter rows by a boolean mask
   function Filter_Rows (Arr : Raw_Data_Array; Mask : Boolean_Array)
                         return Raw_Data_Array is
      Count : Natural := 0;
   begin
      for I in Mask'Range loop
         if Mask(I) then
            Count := Count + 1;
         end if;
      end loop;

      declare
         Result : Raw_Data_Array(1 .. Count, 1 .. Arr'Length(2));
         Index  : Natural := 0;
      begin
         for I in Mask'Range loop
            if Mask(I) then
               Index := Index + 1;
               for J in Arr'Range(2) loop
                  Result(Index, J) := Arr(I, J);
               end loop;
            end if;
         end loop;
         return Result;
      end;
   end Filter_Rows;

    -- Function to get a column from 2D array
   function Get_Column (Arr : Raw_Data_Array; Col : Positive)
                        return Float_Array is
      Len : constant Positive := Arr'Length(1);
      Result : Float_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := Arr(I, Col);
      end loop;
      return Result;
   end Get_Column;

 -- Function to compute modulo for arrays
   function Mod_Array (Arr1, Arr2 : Float_Array) return Float_Array is
      Len : constant Positive := Arr1'Length;
      Result : Float_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := Float'Mod(Arr1(I), Arr2(I));
      end loop;
      return Result;
   end Mod_Array;

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

function Product_Column2 (Arr1, Arr2 : Raw_Data_Array) return Float_Array is
      Len : constant Positive := Arr1'Length(1);
      Result : Float_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := Arr1(I, 2) * Arr2(I, 2);
      end loop;
      return Result;
   end Product_Column2;

    -- Function to get unique values from Float_Array simple implementation
   function Unique (Arr : Float_Array) return Float_Array is
      package Float_Set is
        new Ada.Containers.Ordered_Sets (Element_Type => Float);
      Use_Set : Float_Set.Set := Float_Set.Empty_Set;
      Result_List : Float_Array(1 .. Arr'Length);
      Count : Natural := 0;
   begin
      for I in Arr'Range loop
         if not Float_Set.Contains(Use_Set, Arr(I)) then
            Use_Set := Float_Set.Insert(Use_Set, Arr(I));
            Count := Count + 1;
            Result_List(Count) := Arr(I);
         end if;
      end loop;
      return Result_List(1 .. Count);
   end Unique;

   function Zeros_Like (Arr : Float_Array) return Float_Array is
      Len : constant Positive := Arr'Length;
      Result : Float_Array(1 .. Len);
   begin
      for I in 1 .. Len loop
         Result(I) := 0.0;
      end loop;
      return Result;
   end Zeros_Like;

end Vector_Functions;

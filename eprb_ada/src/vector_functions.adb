
with Ada.Numerics;
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Maths;

package body Vector_Functions is

   function Abs_Vector (Vec : Result_Vector; Col : Positive)
                        return Float_Vector is
      use Result_Vector_Package;
      Curs   : Cursor := Vec.First;
      Item   : Result_Data;
      Result : Float_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Result.Append (Float'Magnitude (Item.Outcome));
         Next (Curs);
      end loop;
      return Result;

   end Abs_Vector;

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
   function Coincidence (Prod : Float_Vector) return Boolean_Vector is
      use Float_Vector_Package;
      Curs   : Cursor := Prod.First;
      Item   : Float;
      Result : Boolean_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Result.Append (Float'Magnitude (Item) = 1.0);
         Next (Curs);
      end loop;
      return Result;

   end Coincidence;

   -- Function to filter rows by a boolean mask
   function Filter_Rows (Vec : Result_Vector; Mask : Boolean_Vector)
                         return Result_Vector is
      use Boolean_Vector_Package;
      use Float_Vector_Package;
      Curs_M : Cursor := Vec.First;
      Curs_F : Cursor := Mask.First;
      Item   : Float;
      Count  : Natural := 0;
      Result : Result_Vector;
   begin
      while Has_Element (Curs_M) loop
         if Element (Curs) then
            Count := Count + 1;
         end if;
         Next (Curs);
      end loop;

      declare
         use Result_Matrix_Package;
         Result_Mat : Result_Matrix (1 .. Count, 1 .. Arr'Length(2));
         Index  : Natural := 0;
      begin
         while Has_Element (Curs_M) loop
            if Element (Curs_M) then
               Index := Index + 1;
               for J in Arr'Range(2) loop
                  Result(Index, J) := Arr(I, J);
               end loop;
            end if;
         end loop;
         return Result;
      end;

      return Result;

   end Filter_Rows;

   -- Function to get a column from 2D array
   function Get_Column (Vec : Result_Vector; Col : Positive)
                        return Float_Vector is
      use Float_Vector_Package;
      Curs_1 : Cursor := Vec_1.First;
      Result : Float_Vector;
   begin
      for I in 1 .. Len loop
         Result(I) := Arr(I, Col);
      end loop;
      return Result;

   end Get_Column;

   function Mod_Vector (Vec_1, Vec_2 : Float_Vector) return Float_Vector is
      use Float_Vector_Package;
      Curs_1 : Cursor := Vec_1.First;
      Curs_2 : Cursor := Vec_2.First;
      Item_1 : Float;
      Item_1 : Float;
      Result : Float_Vector;
   begin
      while Has_Element (Curs_1) and then Has_Element (Curs_2) loop
         Item_1 := Element (Curs_1);
         Item_2 := Element (Curs_2);
         Result.Append (Float'Mod (Item_1 * Item_2);
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

                        function Product_Column2 (Vec_1, Vec_2 : Result_Vector) return Float_Vector is
                        use Result_Vector_Package;
                        Curs_1 : Cursor := Vec_1.First;
                        Curs_2 : Cursor := Vec_2.First;
                        Result : Float_Vector;
                        begin
                        while Has_Element (Curs_1) and then Has_Element (Curs_2) loop
                        Result.Append (Element (Curs_1) * Element (Curs_2) );
                        Next (Curs_1);
                        Next (Curs_2);
                        end loop;
                        return Result;

                        end Product_Column2;

                        function Sample_Mean (Vec : Float_Vector) return Float is
                        use Float_Vector_Package;
                        Curs : Cursor := Vec.First;
                        Sum : Float := 0.0;
                        begin
                        while Has_Element (Curs) loop
                        Sum := Sum + Element (Curs);
                        Next (Curs);
                        end loop;
                        return Sum / Float (Length (Vec));

                        end  Sample_Mean;

                        -- Function to get unique values from Float_Vector simple implementation
                        function Unique (Arr : Float_Vector) return Float_Vector is
                        package Float_Set is
                          new Ada.Containers.Ordered_Sets (Element_Type => Float);
                        Use_Set : Float_Set.Set := Float_Set.Empty_Set;
                        Result_List : Float_Vector (1 .. Arr'Length);
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

                        function Zeros_Like (Arr : Float_Vector) return Float_Vector is
                        Len : constant Positive := Arr'Length;
                        Result : Float_Vector (1 .. Len);
                        begin
                        for I in 1 .. Len loop
                        Result(I) := 0.0;
                        end loop;
                        return Result;

                        end Zeros_Like;

                        end Vector_Functions;

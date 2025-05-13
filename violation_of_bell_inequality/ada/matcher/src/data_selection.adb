
--  with Ada.Integer_Text_IO;
--  with Ada.Float_Text_IO;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Data_Selection is

   type Data_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
      Difference : Double;
   end record;

   function Parse_Line (aLine : String) return Data_Record is
      use Ada.Strings.Fixed;
      Line_Length : constant Natural := aLine'Length;
      Pos_1       : Natural := 1;
      Pos_2       : Natural := Index (aLine, ",", 1);
      Data        : Data_Record;
   begin
      Data.A_Index := Integer'Value (aLine (aLine'First .. Pos_2 - 1));
      Pos_1 := Pos_2 + 2;
      Pos_2 := Index (aLine (Pos_1 .. Line_Length), ",", Pos_1);
      Data.B_Index := Integer'Value (aLine (Pos_1 .. Pos_2 - 1));
      Pos_1 := Pos_2 + 2;
      Data.Difference := Double'Value (aLine (Pos_1 .. Line_Length));

      return Data;

   end Parse_Line;

   procedure Select_Pairs (Match_CSV : String; C : out Match_List) is
      Routine_Name : constant String := "Process_Data.Select_Pairs ";
      u            : constant Double := Double (4.0 * 10.0 ** (-9));
      v            : constant Double := Double (8.0 * 10.0 ** (-9));
      w            : constant Double := Double (0.5 * abs (v - u));
      File_ID      : File_Type;
      --  delta       : Double :=  Double (0.5 * (u + v));
      Count        : Natural := 0;

   begin
      --  w := 5.0 * 10.0 ** (-9);
      Put_Line (Routine_Name & "w: " & Double'Image (w));

      Open (File_ID, In_File, Match_CSV);
      while not End_Of_File (File_ID) loop
         declare
            aLine : constant String := Get_Line (File_ID);
            Data  : constant Data_Record := Parse_Line (aLine);
         begin
            if Data.Difference < w then
               Count := Count + 1;
               C.Append ((Data.A_Index, Data.B_Index));
               if Count < 10 then
                  Put_Line (Routine_Name &
                              "C: " & Integer'Image (Data.A_Index) & "   " &
                              Integer'Image (Data.B_Index));
               end if;
            end if;
         end ;
      end loop;

      Put_Line (Routine_Name & "C length:" & Integer'Image (Integer (C.Length)));

   end Select_Pairs;

end Data_Selection;

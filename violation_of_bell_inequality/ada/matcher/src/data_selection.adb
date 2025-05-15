
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

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

   procedure Select_OEM_Data (OEM_A, OEM_B, Selected_OEM : String;
                              Selected_Indices           : Match_List) is
      use Match_Package;
      --  Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_A_ID   : File_Type;
      OEM_B_ID   : File_Type;
      Select_ID  : File_Type;
      A_Line     : String_3;
      B_Line     : String_3;
      Indices    : Match_Record;
   begin
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);
      Create (Select_ID, Out_File, Selected_OEM);

      for item of Selected_Indices loop
         Indices := item;
         A_Line := Get_Line (OEM_A_ID);
         B_Line := Get_Line (OEM_B_ID);
         --  Put (Select_ID, );
      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (Select_ID);

   end Select_OEM_Data;

   procedure Pair_Indices (Match_CSV : String; Width : Double;
                           Selected  : out Match_List) is
      use Ada.Directories;
      use Match_Package;
      Routine_Name : constant String := "Data_Selection.Pair_Indices ";
      File_ID      : File_Type;
      Count        : Natural := 0;
   begin
      Open (File_ID, In_File, Match_CSV);
      Put_Line (Routine_Name & "Match_CSV file size:" &
                  Integer'Image (Integer (Size (Match_CSV))) & " bytes");
      Put_Line (Routine_Name & "Width:" & Double'Image (Width));

      while not End_Of_File (File_ID) loop
         declare
            aLine : constant String := Get_Line (File_ID);
            Data  : constant Data_Record := Parse_Line (aLine);
         begin
            if Data.Difference <= Width then
               Count := Count + 1;
               Selected.Append ((Data.A_Index, Data.B_Index));
               if Count < 10 then
                  Put_Line (Routine_Name &
                            "Selected: " & Integer'Image (Data.A_Index)
                            & "   " & Integer'Image (Data.B_Index) & "   " &
                              Double'Image (Data.Difference));
               end if;
            end if;
         end ;
      end loop;

      Close (File_ID);
      Put_Line (Routine_Name & "Selected length:" &
                  Integer'Image (Integer (Selected.Length)));

   end Pair_Indices;

end Data_Selection;


with Ada.Direct_IO;
with Ada.Text_IO; use Ada.Text_IO;

package body Data_Selection is

   package String3_IO is new Ada.Direct_IO (String_3);

   function OEM_Data (OEM_A, OEM_B: String_3) return OEM_String is
      --  Routine_Name : constant String := "Data_Selection.OEM_Data ";
      A_Val : constant Natural := Natural'Value (OEM_A (3 .. 3));
      B_Val : constant Natural := Natural'Value (OEM_B (3 .. 3));
   begin
      --  Put_Line (Routine_Name & "B_Val: " & Integer'Image (B_Val));
      --  Put_Line (Routine_Name & "OEM_A (3), OEM_B (3): " & OEM_A (3) & "  " &
      --           OEM_B (3));
      --  Put_Line (Routine_Name & "A_Val * B_Val: " &  Natural'Image (A_Val * B_Val));
      --  Put_Line (Routine_Name & "Result: " &  OEM_A (3) & "," & OEM_B (3) & "," &
      --       Natural'Image (A_Val * B_Val) & "," & Natural'Image (A_Val + B_Val));
      return
        (OEM_A (3) & "," & OEM_B (3) & "," &
           Natural'Image (A_Val * B_Val) & "," & Natural'Image (A_Val + B_Val));

   end OEM_Data;

   procedure Select_OEM_Data
     (Selected_Pairs : Match_List;
      OEM_A, OEM_B, OEM_00, OEM_01, OEM_10, OEM_11 : String) is
      use String3_IO;
      use Match_Package;
      Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_A_ID   : String3_IO.File_Type;
      OEM_B_ID   : String3_IO.File_Type;
      OEM_00_ID  : Ada.Text_IO.File_Type;
      OEM_01_ID  : Ada.Text_IO.File_Type;
      OEM_10_ID  : Ada.Text_IO.File_Type;
      OEM_11_ID  : Ada.Text_IO.File_Type;
      OEM_A_Line : String_3;
      OEM_B_Line : String_3;
      Indices    : Data_Record;
      A_Index    : String3_IO.Positive_Count;
      B_Index    : String3_IO.Positive_Count;
      Count      : Natural := 0;
   begin
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);
      Create (OEM_00_ID, Out_File, OEM_00);
      Create (OEM_01_ID, Out_File, OEM_01);
      Create (OEM_10_ID, Out_File, OEM_10);
      Create (OEM_11_ID, Out_File, OEM_11);

      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));

      for item of Selected_Pairs loop
         Count := Count + 1;
         Indices := item;
         A_Index :=  String3_IO.Positive_Count (item.A_Index);
         B_Index :=  String3_IO.Positive_Count (item.B_Index);
         Read (OEM_A_ID, OEM_A_Line, A_Index);
         Read (OEM_B_ID, OEM_B_Line, B_Index);
         if Count < 4 then
            Put_Line (Routine_Name & "OEM_A_Line:  !" &  OEM_A_Line & "!");
            Put_Line (Routine_Name & "OEM_B_Line:  !" &  OEM_B_Line & "!");
            New_Line;
         end if;

         if OEM_A_Line (1) = '0' and then OEM_B_Line (1) = '0' then
            Put_Line (OEM_00_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '0' and then OEM_B_Line (1) = '1' then
            Put_Line (OEM_01_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '1' and then OEM_B_Line (1) = '0' then
            Put_Line (OEM_10_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '1' and then OEM_B_Line (1) = '1' then
            Put_Line (OEM_11_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         else
            null;
            --  Put_Line (Routine_Name & "Invalid data");
            --  Put (Routine_Name & "OEM_A_Line:  " &  OEM_A_Line);
            --  New_Line;
            --  Put (Routine_Name & "OEM_B_Line:  " &  OEM_B_Line);
            --  New_Line;
         end if;

      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (OEM_00_ID);
      Close (OEM_01_ID);
      Close (OEM_10_ID);
      Close (OEM_11_ID);

      Put_Line (Routine_Name & "OEM selected data files written.");
      Put_Line (Routine_Name & "OEM_00 length:" & Integer'Image (Integer (OEM_00'Length)));
      Put_Line (Routine_Name & "OEM_01 length:" & Integer'Image (Integer (OEM_01'Length)));
      Put_Line (Routine_Name & "OEM_10 length:" & Integer'Image (Integer (OEM_10'Length)));
      Put_Line (Routine_Name & "OEM_11 length:" & Integer'Image (Integer (OEM_11'Length)));

   end Select_OEM_Data;

end Data_Selection;

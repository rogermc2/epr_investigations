
with Ada.Direct_IO;
with Ada.Directories;  use Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

package body Data_Selection is

   --  String_4 includes terminating carriage return.
   package String4_IO is new Ada.Direct_IO (String_4);

   function OEM_Data (OEM_A, OEM_B: String_4) return OEM_String is
      --  Routine_Name : constant String := "Data_Selection.OEM_Data ";
      A_Val : constant Natural := Natural'Value (OEM_A (3 .. 3));
      B_Val : constant Natural := Natural'Value (OEM_B (3 .. 3));
   begin
      return
        (OEM_A (3) & "," & OEM_B (3) & "," &
           Natural'Image (A_Val * B_Val) & "," & Natural'Image (A_Val + B_Val));

   end OEM_Data;

   procedure Select_OEM_Data
     (Selected_Pairs : Match_List;
      OEM_A, OEM_B, OEM_00, OEM_01, OEM_10, OEM_11 : String) is
      use String4_IO;
      use Match_Package;
      Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_A_ID   : String4_IO.File_Type;
      OEM_B_ID   : String4_IO.File_Type;
      OEM_00_ID  : Ada.Text_IO.File_Type;
      OEM_01_ID  : Ada.Text_IO.File_Type;
      OEM_10_ID  : Ada.Text_IO.File_Type;
      OEM_11_ID  : Ada.Text_IO.File_Type;
      OEM_A_Line : String_4;
      OEM_B_Line : String_4;
      Indices    : Data_Record;
      A_Index    : Integer;
      B_Index    : Integer;
      Count      : Natural := 0;
   begin
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);
      Create (OEM_00_ID, Out_File, OEM_00);
      Create (OEM_01_ID, Out_File, OEM_01);
      Create (OEM_10_ID, Out_File, OEM_10);
      Create (OEM_11_ID, Out_File, OEM_11);

      for item of Selected_Pairs loop
         Count := Count + 1;
         Indices := item;
         A_Index :=  item.A_Index;
         B_Index :=  item.B_Index;
         Read (OEM_A_ID, OEM_A_Line, String4_IO.Positive_Count (A_Index));
         Read (OEM_B_ID, OEM_B_Line, String4_IO.Positive_Count (B_Index));

         if OEM_A_Line (1) = '0' and then OEM_B_Line (1) = '0' then
            Put_Line (OEM_00_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '0' and then OEM_B_Line (1) = '1' then
            Put_Line (OEM_01_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '1' and then OEM_B_Line (1) = '0' then
            Put_Line (OEM_10_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         elsif OEM_A_Line (1) = '1' and then OEM_B_Line (1) = '1' then
            Put_Line (OEM_11_ID, OEM_Data (OEM_A_Line, OEM_B_Line));
         else
            Put_Line (Routine_Name & "Invalid data");
            Put (Routine_Name & "OEM_A_Line:  " &  OEM_A_Line);
            Put (Routine_Name & "OEM_B_Line:  " &  OEM_B_Line);
         end if;

      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (OEM_00_ID);
      Close (OEM_01_ID);
      Close (OEM_10_ID);
      Close (OEM_11_ID);

      Put_Line (Routine_Name & "OEM_00 length:" & Integer'Image (Integer (Size (OEM_00))));
      Put_Line (Routine_Name & "OEM_01 length:" & Integer'Image (Integer (Size (OEM_01))));
      Put_Line (Routine_Name & "OEM_10 length:" & Integer'Image (Integer (Size (OEM_10))));
      Put_Line (Routine_Name & "OEM_11 length:" & Integer'Image (Integer (Size (OEM_11))));
      Put_Line ("OEM selected data files written to:");
      Put_Line (OEM_00);
      Put_Line (OEM_01);
      Put_Line (OEM_10);
      Put_Line (OEM_11);

   end Select_OEM_Data;

end Data_Selection;

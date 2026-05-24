
--  with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Combine_Data is

   procedure Load_Data (Data_File : String; Data : out String8_Array) is
      Routine_Name : constant String := "Combine_Data.Load_Data ";
      Data_ID      : File_Type;
      Row          : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Open (Data_ID, In_File, Data_File);

      Skip_Line (Data_ID);  -- Skip Header row
      while Row < Data'Length and then not End_Of_File (Data_ID) loop
         Row := Row + 1;
         Data (Row) := Get_Line (Data_ID);
      end loop;
      --  Put_Line (Routine_Name & "Last row, data: " & Integer'Image (Row)
      --                  & ",   !" & Data (Row) & "!");
      Close (Data_ID);

   end Load_Data;

   procedure Save_Data (Data_File : String; Data : String23_Array) is
      Routine_Name : constant String := "Combine_Data.Save_Data ";
      Out_ID       : File_Type;
   begin
      Create (Out_ID, Out_File, Data_File);

      for row in Data'First .. Data'Last loop
         Put_Line (Out_ID, Data (row));
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);

   end Save_Data;

end Combine_Data;

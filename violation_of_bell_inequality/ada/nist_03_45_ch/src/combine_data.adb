
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Combine_Data is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String21_Array) is
      Routine_Name : constant String := "Combine_Data.Load_Photon_Data ";
      Data_ID      : File_Type;
      Row          : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Open (Data_ID, In_File, Data_File);
        while Row < Integer (Data'Length) and then
        not End_Of_File (Data_ID) loop
         Row := Row + 1;
         Data (Row) := Get_Line (Data_ID);
      end loop;

      Close (Data_ID);
      Ada.Text_IO.Put_Line (Routine_Name & "Number of rows: " &
                              Integer'Image (Row - 1));

   exception
      when Error : others =>
         Ada.Text_IO.Put_Line (Routine_Name & Exception_Information (Error));
         Ada.Text_IO.Put_Line (Routine_Name & "Row: " & Integer'Image (Row));

   end Load_Photon_Data;
   
   procedure Load_NIST_Data (Data_File : String;
                               Data    : out String19_Array) is
      Routine_Name : constant String := "Combine_Data.Load_NIST_Data ";
      Data_ID      : File_Type;
      Row          : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Open (Data_ID, In_File, Data_File);
      --    while Row < Integer (Data'Length) and then
      while not End_Of_File (Data_ID) loop
         Row := Row + 1;
         declare
            aline : String := Get_Line (Data_ID);
         begin
            if Row < 4 then
               Ada.Text_IO.Put_Line (Routine_Name & "aline: " & aline);
            end if;
            Data (Row) := aline;
         end;

      end loop;

      Close (Data_ID);
      Ada.Text_IO.Put_Line (Routine_Name & "Number of rows: " &
                              Integer'Image (Row - 1));

   exception
      when Error : others =>
         Ada.Text_IO.Put_Line (Routine_Name & Exception_Information (Error));

   end Load_NIST_Data;

   procedure Load_OEM_Data (Data_File : String; Data : out String4_Array) is
      Routine_Name : constant String := "Combine_Data.Load_OEM_Data ";
      Data_ID      : File_Type;
      Row          : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Data_File);
      Open (Data_ID, In_File, Data_File);

      while Row < Data'Length and then not End_Of_File (Data_ID) loop
         Row := Row + 1;
         Data (Row) := Get_Line (Data_ID);
         --  if Row < 6 then
         --     Ada.Text_IO.Put_Line (Routine_Name & "Row, data: " & Integer'Image (Row)
         --                           & ",   !" & Data (Row) & "!");
         --  end if;
      end loop;

      Close (Data_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Load_OEM_Data;
   
   procedure Save_Data (Data_File : String; Data : String53_Array) is
      Routine_Name : constant String := "Combine_Data.Save_Data ";
      Out_ID       : File_Type;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Create (Out_ID, Out_File, Data_File);

      --  Table Header
      Put (Out_ID, "A Arrival Time,B Arrival Time,A Setting,");
      Put_Line (Out_ID, "B Setting,A Polarization,B Polarization");
      for row in Data'Range loop
         --  if Row > Data'Last - 4 then
         --     Ada.Text_IO.Put_Line (Routine_Name & "Row, data: " & Integer'Image (Row)
         --                           & ",   !" & Data (Row) & "!");
         --  end if;
         Put_Line (Out_ID, Data (row));
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);
   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Save_Data;

end Combine_Data;

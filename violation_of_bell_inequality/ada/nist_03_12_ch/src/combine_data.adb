
--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

package body Combine_Data is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String21_Array) is
      Routine_Name : constant String := "Combine_Data.Load_Photon_Data ";
      Data_ID      : File_Type;
      Row          : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Ada.Text_IO.Open (Data_ID, In_File, Data_File);
        while Row < Natural (Data'Length) and then
        not End_Of_File (Data_ID) loop
         Row := Row + 1;
         Data (Row) := Get_Line (Data_ID);
      end loop;

      Ada.Text_IO.Close (Data_ID);
      Ada.Text_IO.Put_Line (Routine_Name & "Number of rows: " &
                              Integer'Image (Row));

   exception
      when Error : others =>
         Ada.Text_IO.Put_Line (Routine_Name & Exception_Information (Error));
         Ada.Text_IO.Put_Line (Routine_Name & "Row: " & Integer'Image (Row));

   end Load_Photon_Data;

   procedure Load_NIST_Data (Data_File : String;
                              Data     : in out StringD19_Vector) is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use StringD19_Package;
      Routine_Name : constant String := "Combine_Data.Load_NIST_Data ";
      Data_ID      : File_Type;
      Curs         : Cursor := Data.First;
      Row          : Double_Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Put_Line (Routine_Name & Data_File & " length: " & 
         Integer'Image (Data_File'Length));
      Open (Data_ID, In_File, Data_File);
      while not End_Of_File (Data_ID) and then Has_Element (Curs) loop
         Row := Row + 1;
         declare
            aLine   : constant String := Get_Line (Data_ID);
            Line_19 : String (1 .. 19);
         begin
            Move (Source  => aLine, Target => Line_19,
                  Justify => Left, Pad => Space);
            if Row < 4 then
               Put_Line (Routine_Name & "Row, Line: " &
                Double_Natural'Image (Row) & ", " & Line_19);
            end if;
            Data.Append (Line_19);
         end;

      end loop;

      Close (Data_ID);
      Put_Line (Routine_Name & "Number of rows: " &
                              Double_Natural'Image (Row - 1));

   exception
      when Error : others =>
         Close (Data_ID);
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

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

   procedure Save_NIST_Data (Data_File : String; Data : StringD40_Vector) is
      use StringD40_Package;
      Routine_Name : constant String := "Combine_Data.Save_NIST_Data ";
      Out_ID       : File_Type;
      Curs         : Cursor := Data.First;
   begin
      Create (Out_ID, Out_File, Data_File);

      --  Table Header
      Put_Line (Out_ID, "A Setting,A Time,B Setting,B_Time");
      while Has_Element (Curs) loop
         Put_Line (Out_ID, Data (Curs));
         Next (Curs);
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);
   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Save_NIST_Data;

   procedure Save_NIST_Sync_Data (Data_File : String; Data : StringD40_Vector) is
      use StringD40_Package;
      Routine_Name : constant String := "Combine_Data.Save_NIST_Sync_Data ";
      Curs         : Cursor := Data.First;
      Out_ID       : File_Type;
   begin
      Create (Out_ID, Out_File, Data_File);

      --  Table Header
      Put_Line (Out_ID, "A Sync Time,B Sync Time");
      while Has_Element (Curs) loop
         --  if Row > Data'Last - 4 then
         --     Ada.Text_IO.Put_Line (Routine_Name & "Row, data: " &
         --   Integer'Image (Row)
         --                           & ",   !" & Data (Row) & "!");
         --  end if;
         Put_Line (Out_ID, Data (Curs));
         Next (Curs);
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);
   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Save_NIST_Sync_Data;

end Combine_Data;

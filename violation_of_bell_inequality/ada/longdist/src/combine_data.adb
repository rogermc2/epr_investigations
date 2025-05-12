
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

package body Combine_Data is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String20_Array) is
      use Ada.Streams;
      Routine_Name : constant String := "Combine_Data.Load_Photon_Data ";
      Data_ID      : Stream_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Row          : Positive := 1;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Data_File);
      Stream_IO.Open (Data_ID, Stream_IO.In_File, Data_File);
      Data_Stream := Stream_IO.Stream (Data_ID);

      while Row < Integer (Stream_IO.Size (Data_ID)) / 13 and
        not Stream_IO.End_Of_File (Data_ID) loop
         String_20'Read (Data_Stream, Data (Row));
         --  if Row < 3 then
         --     Ada.Text_IO.Put_Line (Routine_Name & Integer'Image (Row) & "   " &
         --                 Data (Row));
         --  end if;
         Row := Row + 1;
      end loop;
      Ada.Text_IO.Put_Line (Routine_Name & "Number of rows: " &
                              Integer'Image (Row - 1));

   exception
      when Error : others =>
         Ada.Text_IO.Put_Line (Routine_Name & Exception_Information (Error));
         Ada.Text_IO.Put_Line (Routine_Name & "Row: " & Integer'Image (Row));

   end Load_Photon_Data;

   procedure Load_OEM_Data (Data_File : String;
                            Data      : out String4_Array) is
      use Ada.Streams;
      --  use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Load_OEM_Data ";
      Data_ID      : Stream_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Row          : Positive := 1;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Data_File);
      Stream_IO.Open (Data_ID, Stream_IO.In_File, Data_File);
      Data_Stream := Stream_IO.Stream (Data_ID);

      while not Stream_IO.End_Of_File (Data_ID) loop
         String_4'Read (Data_Stream, Data (Row));
         Row := Row + 1;
      end loop;

   end Load_OEM_Data;

   procedure Save_Data (Data_File : String; Data : String47_Array) is
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Save_Data ";
      Out_ID       : File_Type;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Create (Out_ID, Out_File, Data_File);

      Put_Line (Out_ID,
               "A Arrival Time,B Arrival Time,A Set,B Set,A Polarization,B Polarization");
      for row in Data'Range loop
         Put_Line (Out_ID, Data (row));
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);

   end Save_Data;

end Combine_Data;

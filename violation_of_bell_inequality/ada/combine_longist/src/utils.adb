
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

package body Utils is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String1_Array) is
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Load_Photon_Data ";
      Data_ID      : Stream_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Row          : Positive := 1;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Data_File);
      Stream_IO.Open (Data_ID, Stream_IO.In_File, Data_File);
      Data_Stream := Stream_IO.Stream (Data_ID);

      while not Stream_IO.End_Of_File (Data_ID) loop
         String_1'Read (Data_Stream, Data (Row));
         Row := Row + 1;
      end loop;

   end Load_Photon_Data;

   procedure Load_OEM_Data (Data_File : String;
                            Data      : out String2_Array) is
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Load_OEM_Data ";
      Data_ID      : Stream_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Row          : Positive := 1;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Data_File);
      Stream_IO.Open (Data_ID, Stream_IO.In_File, Data_File);
      Data_Stream := Stream_IO.Stream (Data_ID);

      while not Stream_IO.End_Of_File (Data_ID) loop
         String_2'Read (Data_Stream, Data (Row));
         Row := Row + 1;
      end loop;

   end Load_OEM_Data;

   procedure Save_Data (Data_File : String; Data : String6_Array) is
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Save_Data ";
      Out_ID       : File_Type;
      aRow         : String_6;
   begin
      Put_Line (Routine_Name & "Source File: " & Data_File);
      Create (Out_ID, Out_File, Data_File);

      for row in Data'Range loop
         aRow := Data (row);
         for index in 1 .. 5 loop
            Put (Out_ID, aRow (index) & ",");
         end loop;

         Put (Out_ID, aRow (6));
         if row < Data'Last then
            Put (Out_ID, ",");
         end if;
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & Data_File);

   end Save_Data;

end Utils;

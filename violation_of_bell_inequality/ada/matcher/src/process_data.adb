
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   procedure Load_Data (CSV_Data : String; Data : out String33_List) is
      use String33_Package;
      File_ID  : File_Type;
      --  aLine    : String_33;
   begin
      Open (File_ID, In_File, CSV_Data);
      while not End_Of_File (File_ID) loop
         Data.Append (Get_Line (File_ID));
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Photon_Times (CSV_A, CSV_B, CSV_Match : String) is
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      use String33_Package;
      Match_ID     : File_Type;
      A_Data       : String33_List;
      B_Data       : String33_List;
      A_Index      : Extended_Index;
      A_Val        : Double;
      function Difference (B_Curs : String33_Package.Cursor) return Double is
         B_Val : constant Double := Double'Value (Element (B_Curs));
      begin
         return abs (B_Val - A_Val);
      end Difference;

      procedure Find_Closest (B_Curs : String33_Package.Cursor) is
         Min_Diff : Double := Double'Safe_Last;
         Diff     : Double := Min_Diff - 1.0;
      begin
         while Diff < Min_Diff loop
            Diff := Double'Value (Element (B_Curs)) - A_Val;
            if Diff < Min_Diff then
               Min_Diff := Diff;
            end if;
         end loop;

      end Find_Closest;

      procedure B_Iterate (A_Curs : String33_Package.Cursor) is
      begin
         A_Index := To_Index (A_Curs);
         A_Val := Double'Value (Element (A_Curs));
         Iterate (B_Data, Find_Closest'Access);

      end B_Iterate;

   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      Create (Match_ID, Out_File, CSV_Match);
      Iterate (A_Data, B_Iterate'Access);

      Ada.Text_IO.Close (Match_ID);

      Ada.Text_IO.Put_Line (Routine_Name & "CSV_Match file written to " &
                              CSV_Match);
      Ada.Text_IO.Put_Line
        (Routine_Name & "CSV_Match file length: " &
           Natural'Image (Natural (Size (CSV_Match))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

end Process_Data;

with Ada.Directories; use Ada.Directories;
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO;     use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   procedure Load_Data (CSV_Data : String; Data : out String19_List);

   procedure Match_Photon_Times (CSV_A, CSV_B, CSV_Match : String) is
      use String19_Package;
      Routine_Name : constant String :=
        "Process_Data.Closest_Match_With_Vectors ";
      Match_ID     : File_Type;
      A_Data       : String19_List;
      B_Data       : String19_List;
      Match_Index  : Natural := 0;
      B_Index      : Natural := 0;

      procedure Find_Closest (A_Curs : String19_Package.Cursor) is
         A_Index   : constant Extended_Index := To_Index (A_Curs);
         A_Value   : constant Double := Double'Value (Element (A_Curs));
         Best_Diff : Double                  :=
           abs (A_Value - Double'Value (B_Data.Element (B_Index)));
         New_Diff  : Double;
         Done      : Boolean                 := False;
      begin
         --  Try to move forward in B_Data if it improves the match
         while not Done loop
            Done := B_Index + 1 >= Integer (B_Data.Length);

            if not Done then
               New_Diff :=
                 abs (A_Value - Double'Value (B_Data.Element (B_Index + 1)));
               Done     := New_Diff >= Best_Diff;
               if not Done then
                  B_Index   := B_Index + 1;
                  Best_Diff := New_Diff;
               end if;
            end if;
         end loop;

         Put_Line
           (Match_ID,
            Integer'Image (A_Index) & "," & Integer'Image (B_Index) & "," &
              Double'Image (Best_Diff));

         Match_Index := Match_Index + 1;

      end Find_Closest;

   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      Create (Match_ID, Out_File, CSV_Match);
      A_Data.Iterate (Find_Closest'Access);
      Close (Match_ID);

      Put_Line (Routine_Name & "CSV_Match file written to " & CSV_Match);
      Put_Line
        (Routine_Name & "CSV_Match file length: " &
           Natural'Image (Natural (Size (CSV_Match))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

   procedure Load_Data (CSV_Data : String; Data : out String19_List) is
      use String19_Package;
      File_ID : File_Type;
      aLine   : String_19;
   begin
      Open (File_ID, In_File, CSV_Data);
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         Data.Append (aLine);
      end loop;

      Close (File_ID);

   end Load_Data;

end Process_Data;

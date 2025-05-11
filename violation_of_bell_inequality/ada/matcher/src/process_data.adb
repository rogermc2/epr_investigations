
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   procedure Load_Data (CSV_Data : String; Data : out String19_List) is
      use String19_Package;
      File_ID  : File_Type;
      aLine    : String_19;
   begin
      Open (File_ID, In_File, CSV_Data);
      while not End_Of_File (File_ID) loop
         --  Put_Line ("aLine length: " &
         --              Integer'Image (Integer (Get_Line (File_ID)'Length)));
         aLine := Get_Line (File_ID);
         Data.Append (aLine);
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Photon_Times (CSV_A, CSV_B, CSV_Match : String) is
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      use String19_Package;
      Match_ID     : File_Type;
      A_Data       : String19_List;
      B_Data       : String19_List;

      procedure Find_Closest (A_Curs : String19_Package.Cursor) is
         A_Index  : constant Extended_Index:= To_Index (A_Curs);
         A_Val    : constant Double := Double'Value (Element (A_Curs));
         B_Size   : constant Integer := Integer (Length (B_Data));
         B_Index  : Extended_Index := A_Index;
         B_Val    : Double;
         Min_Diff : Double := Double'Safe_Last;
         Diff     : Double;
         Inc      : Integer range -1 .. 1 := 0;
         Done     : Boolean := False;
      begin
         if B_Index < B_Size - 1 then
            B_Val := Double'Value (Element (B_Data, B_Index));
            Diff := abs (B_Val - A_Val);

            if  B_Val < A_Val then
               Inc := -1;
            else
               Inc := 1;
            end if;

            if Inc = 0 then
               Min_Diff := Diff;
            else
               while B_Index < B_Size -1 and then not Done loop
                  B_Index := B_Index + Inc;
                  B_Val := Double'Value (Element (B_Data, B_Index));
                  Diff := abs (B_Val - A_Val);
                  Done := Diff >= Min_Diff;
                  if not Done then
                     Min_Diff := Diff;
                  end if;
               end loop;
            end if;
            B_Index := B_Index - Inc;

            Put_Line (Match_ID, Integer'Image (A_Index - 1) & ","  &
                        Integer'Image (B_Index - 1) & ","  &
                        Double'Image (Min_Diff));
         end if;

      exception
         when Error : others =>
            Put_Line (Routine_Name & "B_Index, B_Size: " & Integer'Image (B_Size) &
                        "  " & Integer'Image (B_Size));
            Put_Line (Routine_Name & "Find_Closest " & Exception_Information (Error));
            raise;

      end Find_Closest;

   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      Create (Match_ID, Out_File, CSV_Match);
      Iterate (A_Data, Find_Closest'Access);

      Close (Match_ID);

      Put_Line (Routine_Name & "CSV_Match file written to " &
                  CSV_Match);
      Put_Line (Routine_Name & "CSV_Match file length: " &
                  Natural'Image (Natural (Size (CSV_Match))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

end Process_Data;

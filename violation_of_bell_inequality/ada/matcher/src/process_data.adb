
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO;     use Ada.Text_IO;

package body Process_Data is

   procedure Load_Data (CSV_Data : String; Data : out String21_List) is
      use String21_Package;
      File_ID : File_Type;
      aLine   : String_21;
   begin
      Open (File_ID, In_File, CSV_Data);
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         Data.Append (aLine);
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Photon_Times
     (CSV_A, CSV_B   : String; Delta_A, Width : Double;
      Selected_Pairs : out Match_List) is
      use String21_Package;
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      A_Data       : String21_List;
      B_Data       : String21_List;
      B_Index      : Positive := 1;
      Num_Found    : Natural := 0;

      procedure Find_All_Matches (A_Curs : String21_Package.Cursor) is
         A_Index   : constant Extended_Index := To_Index (A_Curs);
         A_Value   : constant Double :=
           Double'Value (Element (A_Curs)) + Delta_A;
         B_Value   : Double;
      begin
         --  Move B_Index forward until B_Value is >= (A_Value - Width)
         while B_Index < Integer (B_Data.Length) and then
           Double'Value (B_Data.Element (B_Index)) < A_Value - Width
         loop
            B_Index := B_Index + 1;
         end loop;

         --  From B_Index, check all within A_Value + Width
         declare
            B1_Index : Integer := B_Index;
            Done     : Boolean := False;
         begin
            while not Done and then B1_Index < Integer (B_Data.Length) loop
               B_Value := Double'Value (B_Data.Element (B1_Index));
               --  exit when B_Value > A_Value + Width;
               Done := B_Value > A_Value + Width;

               if not Done then
                  --  Match found within window
                  Selected_Pairs.Append
                    ((A_Index, B1_Index, abs (A_Value - B_Value)));
                  Num_Found := Num_Found + 1;
                  if Num_Found < 6 then
                     Put_Line
                       (Routine_Name & "Find_All_Matches " & Integer'Image (A_Index) &
                          "," & Integer'Image (B_Index) & "," &
                          Double'Image (abs (A_Value - B_Value)));
                  end if;
                  B1_Index := B1_Index + 1;
               end if;
            end loop;
         end;

      end Find_All_Matches;

   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      A_Data.Iterate (Find_All_Matches'Access);

      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

end Process_Data;

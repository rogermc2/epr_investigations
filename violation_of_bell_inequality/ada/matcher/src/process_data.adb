with Ada.Directories; use Ada.Directories;
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
     (CSV_A, CSV_B, CSV_Match : String; Delta_A, Width : Double) is
      use String21_Package;
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      Match_ID     : File_Type;
      A_Data       : String21_List;
      B_Data       : String21_List;
      B_Index      : Positive := 1;

      --  ----------------
      --  Time_Window  : constant Double := 4.0E-9;  -- 4 ns
      --  Time_Window  : constant Double := 4.0 * 10.0 ** (-9);  -- 4 ns

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
            Temp_B_Index : Integer := B_Index;
         begin
            while Temp_B_Index < Integer (B_Data.Length) loop
               B_Value := Double'Value (B_Data.Element (Temp_B_Index));
               exit when B_Value > A_Value + Width;

               --  Match found within window
               Put_Line (Match_ID,
                         Integer'Image (A_Index) & "," &
                           Integer'Image (Temp_B_Index) & "," &
                         --  Double'Image (A_Value) & "," &
                         --  Double'Image (B_Value) & "," &
                           Double'Image (abs (A_Value - B_Value))
                        );

               Temp_B_Index := Temp_B_Index + 1;
            end loop;
         end;
         --  if A_Index < 6 then
         --     Put_Line
         --       (Integer'Image (A_Index) & "," & Integer'Image (B_Index) & "," &
         --          Double'Image (abs (A_Value - B_Value)));
         --  end if;

      end Find_All_Matches;

      --   -------

      --  procedure Closest_B_To_A (A_Curs : String21_Package.Cursor) is
      --     A_Index   : constant Extended_Index := To_Index (A_Curs);
      --     A_Value   : constant Double :=
      --       Double'Value (Element (A_Curs)) + Delta_A;
      --     Best_Diff : Double :=
      --       abs (A_Value - Double'Value (B_Data.Element (B_Index)));
      --     New_Diff  : Double;
      --     Done      : Boolean := False;
      --  begin
      --     --  Try to move forward in B_Data if it improves the match
      --     while B_Index < Integer (B_Data.Length) and then not Done loop
      --
      --        New_Diff :=
      --          abs (A_Value - Double'Value (B_Data.Element (B_Index + 1)));
      --        Done := New_Diff >= Best_Diff;
      --        if not Done then
      --           B_Index   := B_Index + 1;
      --           Best_Diff := New_Diff;
      --        end if;
      --     end loop;
      --     if A_Index < 6 then
      --        Put_Line
      --          (Integer'Image (A_Index) & "," & Integer'Image (B_Index) & "," &
      --             Double'Image (Best_Diff));
      --     end if;
      --
      --     Put_Line
      --       (Match_ID,
      --        Integer'Image (A_Index) & "," & Integer'Image (B_Index) & "," &
      --          Double'Image (Best_Diff));
      --
      --  end Closest_B_To_A;

   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      Create (Match_ID, Out_File, CSV_Match);
      --  A_Data.Iterate (Closest_B_To_A'Access);
      A_Data.Iterate (Find_All_Matches'Access);
      Close (Match_ID);

      Put_Line (Routine_Name & "CSV_Match file written to " & CSV_Match);
      Put_Line
        (Routine_Name & "CSV_Match file length: " &
           Natural'Image (Natural (Size (CSV_Match))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

end Process_Data;

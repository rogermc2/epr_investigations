
--  with Ada.Directories;
with Ada.Exceptions;  use Ada.Exceptions;
--  with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

package body Process_Data is

   procedure Load_Data (CSV_Data : String;
                Data_A, Data_B : in out String19_List);
   procedure Save_Match_List (File_Name : String; Pairs : Match_List);

   procedure Find_Raw_Window_Width
     (CSV_Times_A, CSV_Times_B : String; Delta_A : Float;
      Min_Width, Max_Width     : out Float) is
      use String19_Package;
      --  Routine_Name : constant String := "Process_Data.Find_Raw_Window_Width ";
      A_Data       : String19_List;
      B_Data       : String19_List;
      B_Index      : Integer := 1;

      procedure Find_Width (A_Curs : String19_Package.Cursor) is
         A_Value   : constant Double :=
           Double'Value (Element (A_Curs)) + Double (Delta_A);
         Width     : Float;
      begin
         while B_Index < Integer (B_Data.Length) and then
           Double'Value (B_Data.Element (B_Index)) < A_Value
         loop
            B_Index := B_Index + 1;
         end loop;

         Width := Float (Double'Value (B_Data.Element (B_Index)) - A_Value);
         if Width > Max_Width then
            Max_Width := Width;
         elsif Width < Min_Width and then Width > 0.0 then
            --   Width can be < 0.0 at end of files.
            Min_Width := Width;
         end if;

      end Find_Width;

   begin
      Load_Data (CSV_Times_A, A_Data, B_Data);
      Min_Width := 1.0;
      Max_Width := 0.0;

      A_Data.Iterate (Find_Width'Access);

   end  Find_Raw_Window_Width;

   procedure Load_Data (CSV_Data : String; Data_A, Data_B: in out String19_List) is
      --  use Ada.Directories;
      --  use Ada.Strings.Unbounded;
      use String19_Package;
      File_ID : File_Type;
      Header  : String_33;
      aLine   : String_40;
   begin
      Open (File_ID, In_File, CSV_Data);
      Header := Get_Line (File_ID);        -- Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         --  Put_Line ("aline: " & aline);
         --  Put_Line ("aline (1 .. 19): " & aline (1 .. 19));
         --  Put_Line ("aline (22 .. 40): " & aline (22 .. 40));
         --  Put_Line ("aline length: " & Integer'Image (Integer (aline'Length)));
         Data_A.Append (aLine (aLine'First .. aLine'First + 18));
         Data_B.Append (aLine (aLine'First + 21 .. aLine'Last));
         --  Data_A.Append (aLine (1 .. 19));
         --  Data_B.Append (aLine (22 .. 40));
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Times
     (Pairs_CSV, Match_CSV : String; Delta_A, Width : Float;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Num_Rows  : Natural := 0) is
      use Match_Package;
      use String19_Package;
      Routine_Name : constant String := "Process_Data.Match_Times ";
      Use_Num_Rows : constant Boolean := Num_Rows > 0;
      --  Half_Width   : constant Double := Double (Width) * 0.5;
      D_Width      : constant Double := Double (Width);
      A_Data       : String19_List;
      B_Data       : String19_List;
      B_Curs       : String19_Package.Cursor := B_Data.First;
      Item         : Index_Record;
      Count        : Natural := 0;

      procedure Find_All_Matches (A_Curs : String19_Package.Cursor) is
         A_Item    : constant String_19 := Element (A_Curs);
         A_Value   : constant Double :=
           Double'Value (A_Item (3 .. 19)) + Double (Delta_A);
         B_Val_Min : constant Double := A_Value - D_Width;
         B_Item    : String_19;
         B_Value   : Double;
         Match     : Boolean := False;
      begin
         Count := Count + 1;
         if Use_Num_Rows and Count > Num_Rows then
            null;
         elsif Has_Element (B_Curs) then
            B_Item := Element (B_Curs);
            B_Value := Double'Value (B_Item (3 .. 19));
            --  Move B_Index forward until B_Value is >= (A_Value - Width)
            while Has_Element (B_Curs) and then B_Value < B_Val_Min loop
               B_Item := Element (B_Curs);
               B_Value := Double'Value (B_Item (3 .. 19));
               Next (B_Curs);
            end loop;

            --  Element (B_Curs) is = or > B_Val_Min
            if Has_Element (B_Curs) then
               B_Item := Element (B_Curs);
               B_Value := Double'Value (B_Item (3 .. 19));
               Match := Abs (B_Value - A_Value) <= D_Width;

               if Match then
                  --  Matched times found within window
                  Item := (To_Index (A_Curs), To_Index (B_Curs));
                  Selected_Pairs.Append (Item);
                  Num_Found := Num_Found + 1;
                  if Num_Found < 6 then
                     Put_Line (Routine_Name & "Match, A, B index:" &
                                 Integer'Image (To_Index (A_Curs)) & ",  " &
                                 Integer'Image (To_Index (B_Curs)));
                  end if;
               end if;
            end if;
         end if;

      end Find_All_Matches;

   begin
      Num_Found := 0;
      Load_Data (Pairs_CSV, A_Data, B_Data);
      B_Curs := First (B_Data);
      Next (B_Curs);  --  Skip header

      Put_Line (Routine_Name & "Data loaded");
      A_Data.Iterate (Find_All_Matches'Access);
      Put_Line (Routine_Name & "All matches found");
      New_Line;

      Save_Match_List (Match_CSV, Selected_Pairs);
      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Times;

   function Number_Of_Matches (File_Name : String) return Natural is
      Routine_Name : constant String := "Process_Data.Number_Of_Matches ";
      File_ID      : File_Type;
      aLine        : String_8;
      Num_Matches  : Natural := 0;
   begin
      Open (File_ID, In_File, File_Name);
      Skip_Line (File_ID);   --  Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         if aLine (1 .. 2) = aLine (4 .. 5) then
            Num_Matches := Num_Matches + 1;
         end if;
      end loop;

      Close (File_ID);

      return Num_Matches;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return Num_Matches;

   end Number_Of_Matches;

   procedure Save_Match_List (File_Name : String; Pairs : Match_List) is
      use Match_Package;
      Routine_Name : constant String := "Process_Data.Save_Match_List ";
      Match_ID     : File_Type;
      M_Curs       : Cursor := First (Pairs);
      Rec          : Index_Record;
   begin
      Create (Match_ID, Out_File, File_Name);
      while Has_Element (M_Curs) loop
         Rec :=  Element (M_Curs);
         Put_Line (Match_ID, Integer'Image (Rec.A_Index) & ", " & Integer'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Data;


with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Process_Detection_Data is

   procedure Load_Data
    (CSV_AB_Data : String; Data_A, Data_B : out Setting_Time_Vector);
   procedure Save_Match_List (File_Name : String; Pairs : Match_List);

   --  procedure Find_Raw_Window_Width
   --     (CSV_AB_Data : String; Delta_A : Float; Min_Width, Max_Width : out Float) is
   --     use String21_Package;
   --     --  Routine_Name : constant String := "Process_Data.Find_Raw_Window_Width ";
   --     A_Data       : String21_List;
   --     B_Data       : String21_List;
   --     B_Index      : Integer := 1;

   --     procedure Find_Width (A_Curs : String21_Package.Cursor) is
   --        A_Value   : constant Double :=
   --          Double'Value (Element (A_Curs)) + Double (Delta_A);
   --        Width     : Float;
   --     begin
   --        while B_Index < Integer (B_Data.Length) and then
   --          Double'Value (B_Data.Element (B_Index)) < A_Value
   --        loop
   --           B_Index := B_Index + 1;
   --        end loop;

   --        Width := Float (Double'Value (B_Data.Element (B_Index)) - A_Value);
   --        if Width > Max_Width then
   --           Max_Width := Width;
   --        elsif Width < Min_Width and then Width > 0.0 then
   --           --   Width can be < 0.0 at end of files.
   --           Min_Width := Width;
   --        end if;

   --     end Find_Width;

   --  begin
   --     Load_Data (CSV_AB_Data, A_Data, B_Data);
   --     Min_Width := 1.0;
   --     Max_Width := 0.0;

   --     A_Data.Iterate (Find_Width'Access);

   --  end  Find_Raw_Window_Width;

   procedure Load_Data
    (CSV_AB_Data : String; Data_A, Data_B : out Setting_Time_Vector) is
      File_ID : File_Type;
      aLine   : String_40;
      Str_A  : String_19;
      Str_B  : String_19;
      Item_A  : Setting_Time_Record;
      Item_B  : Setting_Time_Record;
   begin
      Open (File_ID, In_File, CSV_AB_Data);
      Skip_Line (File_ID);   --  Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         Str_A := aLine (1 .. 19);
         Str_B := aLine (22 .. 40);
         if Str_A (1 .. 1) = "0" then
            Item_A.Setting := Polarizer_0;
         elsif Str_A (1 .. 1) = "1" then
            Item_A.Setting := Polarizer_45;
         else
            Put_Line ("Load_Data: Invalid A setting: " & Str_A (1 .. 1));
         end if;

         Item_A.Time := Double_Natural'Value (Str_A (3 .. 19));

         if Str_B (1 .. 1) = "0" then
            Item_B.Setting := Polarizer_0;
         elsif Str_B (1 .. 1) = "1" then
            Item_B.Setting := Polarizer_45;
         else
            Put_Line ("Load_Data: Invalid B setting: " & Str_B (1 .. 1));
         end if;
         Item_B.Time := Double_Natural'Value (Str_B (3 .. 19));

         Data_A.Append (Item_A);
         Data_B.Append (Item_B);
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Photon_Times
     (CSV_AB, Match : String; Delta_Val : Double_Natural; Width : Natural;
      Num_Found     : out Natural; Selected_Pairs : out Match_List;
      Num_Rows      : Natural := 0) is
      use Setting_Time_Package;
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      Use_Num_Rows : constant Boolean := Num_Rows > 0;
      D_Width      : constant Double_Natural := Double_Natural (Width);
      Item         : Setting_Time_Record;
      A_Data       : Setting_Time_Vector;
      B_Data       : Setting_Time_Vector;
      B_Curs       : Cursor;
   begin
      --  CSV_AB file contains four columns of A and B setting and photon
      --  time data
      Load_Data (CSV_AB, A_Data, B_Data);
      B_Curs := B_Data.First;
      while Has_Element (B_Curs) loop
         Item := Element (B_Curs);
         Item.Time := Item.Time + Delta_Val;
         B_Data.Replace_Element (Position => B_Curs, New_Item => Item);
         Next (B_Curs);
      end loop;
      New_Line;

      Save_Match_List (Match, Selected_Pairs);
      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Photon_Times;

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
         Put_Line (Match_ID, Double_Positive'Image (Rec.A_Index) & ", " &
          Double_Positive'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Detection_Data;


with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;
with Utils; use Utils;

package body Process_Data is

   type Field_Array is array (1 .. 17) of Natural;

   procedure Parse_Line (Line : String; Data : out Raw_Result_Record);

   procedure Get_Data (Source_File : String; Target : out Delft_Data_List) is
      Routine_Name : constant String := "Process_Data.Get_Data ";
      Source_ID    : File_Type;
      Line_Num     : Natural := 0;
      Raw_Data     : Raw_Result_Record;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      New_Line;
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         declare
            aline : constant String := Get_Line (Source_ID);
         begin
            Parse_Line (aline, Raw_Data);
            Target.Append (Raw_Data);
         end;
      end loop;

      Close (Source_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Get_Data;

   procedure Parse_Line (Line : String; Data : out Raw_Result_Record) is
      Routine_Name : constant String := "Process_Data.Parse_Line ";
      Comma_Count     : Natural := 0;
      Idx             : Positive := Line'First;
      Comma_Positions : Field_Array := (others => 0);
   begin
      while Idx <= Line'Last loop
         if Line(Idx) = ',' then
            Comma_Count := Comma_Count + 1;
            if Comma_Count <= 17 then
               Comma_Positions(Comma_Count) := Idx;
            end if;
         end if;
         Idx := Idx + 1;
      end loop;
      --  2015-12-08 13:19:45.442647,6,1,5424324,0,5672427,0,0,0,10646,10631,11031,0,0,0,70,71
      --  Column 5 (A Setting) lives between the 4th and 5th comma
      --  Put_Line ("between the 2nd and 3rd comma: " & Line(Comma_Positions(2) + 1 .. Comma_Positions (3) - 1));
      Data.A_Setting :=
       Integer'Value (Line(Comma_Positions(4) + 1 .. Comma_Positions (5) - 1));
      --  Column 8 (A Outcome) lives between the 7th and 8th comma
      Data.A_Result :=
         Integer'Value (Line(Comma_Positions(7) + 1 .. Comma_Positions(8) - 1));
      --  Column 7 (B Setting) lives between the 6th and 7th comma
      Data.B_Setting :=
         Integer'Value (Line(Comma_Positions(6) + 1 .. Comma_Positions(7) - 1));
      --  Column 9 (B Outcome) lives between the 8th and 9th comma
      Data.B_Result :=
         Integer'Value (Line(Comma_Positions(8) + 1 .. Comma_Positions(9) - 1));

   exception
      when Error : others =>
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         Put_Line ("Between commas 2 and 3: " & Line(Comma_Positions(2) + 1 .. Comma_Positions (3) - 1));
         raise;
   end Parse_Line;

   procedure Save_Data (aa, ab, ba, bb : String; Data : Delft_Data_List) is
      use Delft_Data_Package;
      Routine_Name : constant String := "Process_Data.Save_Data ";
      Header       : constant String := "A, B";
      aa_ID        : Ada.Text_IO.File_Type;
      ab_ID        : Ada.Text_IO.File_Type;
      ba_ID        : Ada.Text_IO.File_Type;
      bb_ID        : Ada.Text_IO.File_Type;
      W_Item       : W_Record;
      Num_aa       : Natural := 0;
      Num_ab       : Natural := 0;
      Num_ba       : Natural := 0;
      Num_bb       : Natural := 0;
      Curs         : Cursor := Data.First;
      Item         : Raw_Result_Record;
      Count        : Natural := 0;

      procedure Write_Data (File : Ada.Text_IO.File_Type) is
      begin
         if W_Item.A_Result = " 0" then
            W_Item.A_Result := "-1";
         end if;
         if W_Item.B_Result = " 0" then
            W_Item.B_Result := "-1";
         end if;

         Put_Line (File, W_Item.A_Result & "," & W_Item.B_Result);

      end Write_Data;

   begin
      Create (aa_ID, Out_File, aa);
      Create (ab_ID, Out_File, ab);
      Create (ba_ID, Out_File, ba);
      Create (bb_ID, Out_File, bb);

      Put_Line (aa_ID, Header);
      Put_Line (ab_ID, Header);
      Put_Line (ba_ID, Header);
      Put_Line (bb_ID, Header);

      while Has_Element (Curs) loop
         item := Element (Curs);
         Count := Count + 1;
         W_Item.A_Result := UV'Image (item.A_Result);
         W_Item.B_Result := UV'Image (item.B_Result);
         W_Item.AB_Result := UV'Image (item.A_Result * item.B_Result);
         if item.A_Setting = 0 and then item.B_Setting = 0 then
            Num_aa := Num_aa + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'a';
            Write_Data (aa_ID);
         elsif item.A_Setting = 0 and then item.B_Setting = 1 then
            Num_ab := Num_ab + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'b';
            Write_Data (ab_ID);
         elsif item.A_Setting = 1 and then item.B_Setting = 0 then
            Num_ba := Num_ba + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'a';
            Write_Data (ba_ID);
         elsif item.A_Setting = 1 and then item.B_Setting = 1 then
            Num_bb := Num_bb + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'b';
            Write_Data (bb_ID);
         else
            Put_Line (Routine_Name & "Invalid data:");
         end if;
         Curs := Next (Curs);
      end loop;

      Close (aa_ID);
      Close (ab_ID);
      Close (ba_ID);
      Close (bb_ID);

      Put_Line (Routine_Name & "aa length: " &
                  Integer'Image (Count_Text_File_Lines (aa)));
      Put_Line (Routine_Name & "ab length: " &
                  Integer'Image (Count_Text_File_Lines (ab)));
      Put_Line (Routine_Name & "ba length: " &
                  Integer'Image (Count_Text_File_Lines (ba)));
      Put_Line (Routine_Name & "aa length: " &
                  Integer'Image (Count_Text_File_Lines (aa)));

      Put_Line (Routine_Name & "Number of coincident aa detections: " &
                  Integer'Image (Num_aa));
      Put_Line (Routine_Name & "Number of coincident ab detections: " &
                  Integer'Image (Num_ab));
      Put_Line (Routine_Name & "Number of coincident ba detections: " &
                  Integer'Image (Num_ba));
      Put_Line (Routine_Name & "Number of coincident bb detections: " &
                  Integer'Image (Num_bb));

      Put_Line ("Selected data files written to:");
      Put_Line (aa);
      Put_Line (ab);
      Put_Line (ba);
      Put_Line (bb);
      New_Line;

   exception
      when Error : others =>
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;

   end Save_Data;

end Process_Data;

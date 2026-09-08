
with Ada.Exceptions; use Ada.Exceptions;
--  with Ada.Direct_IO;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

with Utils; use Utils;

package body Data_Selection is

   --  Direct_IO line includes line terminator; hence process string_4 as String_5.
   --  package Direct_String_5 is new Ada.Direct_IO (String_5);

   procedure Print_W_Record (Message : String; Data : W_Record);

   procedure Count_xx (Counts : in out xxCounts; aline : String) is
      Item : constant String_4 := aline (aline'First .. aline'First + 3);
   begin
      if Item (1) = 'a' and then Item (3 .. 4) = "+1" then
         Counts.av_Count := Counts.av_Count + 1;
      elsif Item (1) = 'a' and then Item (3 .. 4) = "-1" then
         Counts.ah_Count := Counts.ah_Count + 1;
      elsif Item (1) = 'b' and then Item (3 .. 4) = "+1" then
         Counts.bv_Count := Counts.bv_Count + 1;
      elsif Item (1) = 'b' and then Item (3 .. 4) = "-1" then
         Counts.bh_Count := Counts.bh_Count + 1;
      end if;

   end Count_xx;

   procedure Print_xxCounts (Message : String; Data : xxCounts) is
   begin
      Put_Line (Message & ": ");
      Put ("av: " & Integer'Image (Data.av_Count));
      Put (",  ah: " & Integer'Image (Data.ah_Count));
      Put (",  bv: " & Integer'Image (Data.bv_Count));
      Put (",  bh: " & Integer'Image (Data.bh_Count));
      New_Line;

   end Print_xxCounts;

   procedure Print_W_Record (Message : String; Data : W_Record) is
   begin
      Put_Line (Message & ": ");
      Put_Line ("A_Setting: " & Data.A_Setting & ", A_Result: " & Data.A_Result);
      Put_Line ("B_Setting: " & Data.B_Setting & ", B_Result: " & Data.B_Result);
      Put_Line ("AB_Result: " & Data.AB_Result);

   end Print_W_Record;

   procedure Select_Data
      --  File Names
     (Matched_Det, Det_aa, Det_ab, Det_ba, Det_bb : String;
      A_Count, B_Count  : out xxCounts; Selected_Pairs : Match_List) is
      use  Ada.Strings.Fixed;
      use Match_Package;
      Routine_Name : constant String := "Data_Selection.Select_Data ";
      Header       : constant String := "A Det,B Det";
      Matched_Size : constant Natural := Count_Text_File_Lines (Matched_Det);
      Matched_ID   : File_Type;
      aa_ID        : Ada.Text_IO.File_Type;
      ab_ID        : Ada.Text_IO.File_Type;
      ba_ID        : Ada.Text_IO.File_Type;
      bb_ID        : Ada.Text_IO.File_Type;
      Indices      : Index_Record;
      W_Item       : W_Record;
      Num_aa       : Natural := 0;
      Num_ab       : Natural := 0;
      Num_ba       : Natural := 0;
      Num_bb       : Natural := 0;
      Curs         : Cursor := Selected_Pairs.First;
      Item         : Index_Record;
      W            : W_List;
      Count        : Natural := 0;
      Bad_aa       : Natural := 0;

      procedure Write_Data (File : Ada.Text_IO.File_Type;
             A_Result, B_Result : String_2) is
             AB_Result : String_2;
         begin
         AB_Result := Integer'Image
           (Integer'Value (A_Result) * Integer'Value (B_Result));
         if AB_Result = " 1" then
            AB_Result := "+1";
         end if;
         Put_Line (File, A_Result & "," & B_Result & "," & AB_Result);

      end Write_Data;

   begin
      Put_Line (Routine_Name & "Matched_Det file length: " &
                  Natural'Image (Matched_Size) & "  lines");
      Create (aa_ID, Out_File, Det_aa);
      Create (ab_ID, Out_File, Det_ab);
      Create (ba_ID, Out_File, Det_ba);
      Create (bb_ID, Out_File, Det_bb);

      Put_Line (aa_ID, Header);
      Put_Line (ab_ID, Header);
      Put_Line (ba_ID, Header);
      Put_Line (bb_ID, Header);
      Put_Line (Routine_Name & "Selected_Pairs length " &
          integer'Image
          (integer (Match_Package.Length (Selected_Pairs))));

      --  Process Selected_Pairs
      Open (Matched_ID, In_File, Matched_Det);
      Skip_Line (Matched_ID);  -- skip header line
      while Has_Element (Curs) loop
         item := Element (Curs);
         Count := Count + 1;
         Indices := Item;

         declare
            aLine     : constant String := Get_Line (Matched_ID);
            A_Setting : Channel_Type;
            B_Setting : Channel_Type;
            Pos       : Natural := Index (aLine (1 .. aLine'Last), ",");
         begin
            Pos := Index (aLine (Pos .. aLine'Last), ",");
            A_Setting := Channel_Type'Value (aLine (1 .. Pos - 1));
            B_Setting := Channel_Type'Value (aLine (Pos + 2 .. aLine'Last));

            Count_xx (A_Count, aLine);
            Count_xx (B_Count, aLine);

            if A_Setting = Polarizer_0 and then B_Setting = Polarizer_0 then
               Num_aa := Num_aa + 1;
               W_Item.A_Setting := 'a';
               W_Item.B_Setting := 'a';
               Write_Data (aa_ID, W_Item.A_Result, W_Item.B_Result);
               if W_Item.A_Result = W_Item.B_Result then
                  Bad_aa := Bad_aa + 1;
               end if;
            --  elsif A_Setting = " 0" and then B_Setting = " 1" then
            elsif A_Setting = Polarizer_0 and then B_Setting = Polarizer_45 then
               Num_ab := Num_ab + 1;
               W_Item.A_Setting := 'a';
               W_Item.B_Setting := 'b';
               Write_Data (ab_ID, W_Item.A_Result, W_Item.B_Result);
            --  elsif A_Setting = " 1" and then B_Setting = " 0" then
            elsif A_Setting = Polarizer_45 and then B_Setting = Polarizer_0 then
               Num_ba := Num_ba + 1;
               W_Item.A_Setting := 'b';
               W_Item.B_Setting := 'a';
               Write_Data (ba_ID, W_Item.A_Result, W_Item.B_Result);
            elsif A_Setting = Polarizer_45 and then B_Setting = Polarizer_45 then
               Num_bb := Num_bb + 1;
               W_Item.A_Setting := 'b';
               W_Item.B_Setting := 'b';
               Write_Data (bb_ID, W_Item.A_Result, W_Item.B_Result);
            else
               Put_Line (Routine_Name & "Invalid data:");
               Put ("A index: '" & Double_Positive'Image (item.A_Index));
               Put ("B index: '" & Double_Positive'Image (item.B_Index));
               Put_Line (" Matched_Line: '" & aLine & "'");
            end if;
            W.Append (W_Item);
         end;  -- declare
         Curs := Next (Curs);
      end loop;

      Close (Matched_ID);
      Close (aa_ID);
      Close (ab_ID);
      Close (ba_ID);
      Close (bb_ID);

      Put_Line (Routine_Name & "aa length: " &
                  Integer'Image (Count_Text_File_Lines (Det_aa)));
      Put_Line (Routine_Name & "**** bad aa Count:"  & Integer'Image (Bad_aa));

      Put_Line (Routine_Name & "Number of coincident aa detections: " &
                  Integer'Image (Num_aa));
      Put_Line (Routine_Name & "Number of coincident ab detections: " &
                  Integer'Image (Num_ab));
      Put_Line (Routine_Name & "Number of coincident ba detections: " &
                  Integer'Image (Num_ba));
      Put_Line (Routine_Name & "Number of coincident bb detections: " &
                  Integer'Image (Num_bb));

      Put_Line (Routine_Name & "W length: " &
                  Integer'Image (Integer (W.Length)));
      Put_Line ("Selected data files written to:");
      Put_Line (Det_aa);
      Put_Line (Det_ab);
      Put_Line (Det_ba);
      Put_Line (Det_bb);
      New_Line;

   exception
      when Error : others =>
         Close (Matched_ID);
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;

   end Select_Data;

end Data_Selection;


--  with Ada.Assertions; use Ada.Assertions;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed ;
with Ada.Text_IO; use Ada.Text_IO;

with Interfaces;
with NIST_Printing;
with Printing;
with Types; use Types;
--  with Printing; use Printing;

package body Process_Data is

   function Match_Events (A_Data, B_Data : Nist_Data_List) return Nist_Event_List;

   procedure Build_Event_List (A_Data, B_Data : in out Nist_Data_List;
      Events : out Nist_Event_List) is
      Routine_Name : constant String := "Process_Data.Build_Event_List ";
      --  A_Index       : Nist_Event_Package.Extended_Index := A_Data.First_Index;
      --  B_Index       : Nist_Event_Package.Extended_Index := B_Data.First_Index;
      --  Synch_Index   : Nist_Event_Package.Extended_Index;
      --  Setting_Index : Nist_Event_Package.Extended_Index;
      --  Click_Index   : Nist_Event_Package.Extended_Index;
   begin
      Events := Match_Events (A_Data, B_Data);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Build_Event_List;

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List) is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use Nist_Data_Package;
      Routine_Name : constant String  := "Process_Data.Load_NIST_Data ";
      Source_Size  : constant Double_Natural :=
         Double_Natural (Ada.Directories.Size (Source_File));
      Source_ID    : File_Type;
      Data         : Data_Record;
      Line_Num     : Double_Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      Put_Line (Routine_Name & Source_File & " length: " &
         Double_Natural'Image (Source_Size));
      New_Line;
      Put_Line (Routine_Name &
       Source_File (Source_File'First + 19 .. Source_File'Last) & " size: " &
                     Double_Natural'Image (Source_Size));
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
        Line_Num := Line_Num + 1;
         declare
            aline : constant String := Get_Line (Source_ID);
            Pos_1 : constant Natural :=
             Index (aLine (aLine'First .. aLine'Last), ",");
            Pos_2 : constant Natural :=
             Index (aLine (Pos_1 + 1 .. aLine'Last), ",");
         begin
            if Pos_1 - aline'First > 1 then
               Data.Channel :=
               Channel_Type'Value (aline (aline'First .. Pos_1 - 1));
               Data.Time_Tag :=
                  Double_Positive'Value (aline (Pos_1 + 1 .. Pos_2 - 1));
               Data.Transfer_ID := Integer'Value (aline (Pos_2 + 1 .. aLine'Last));
               --  Assert (Data.Time_Tag > 0, "Data.Time_Tag invalid: " &
               --  Double_Positive'Image (Data.Time_Tag));
            else
               Put_Line (Routine_Name & "aline'First, Pos_1: " &
               Integer'Image (aline'First) & "," & Integer'Image (Pos_1));
            end if;
        end;

         if Data.Channel /= Overflow then
            NIST_Data.Append (Data);
         end if;

         if Line_Num mod 4000000 = 0 then
            Put (".");
         end if;
      end loop;
      New_Line;

      Close (Source_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Load_NIST_Data;

   function Match_Events (A_Data, B_Data : Nist_Data_List)
       return Nist_Event_List  is
      use Nist_Data_Package;
      Routine_Name    : constant String := "Process_Data.Match_Events ";
      A_Index         : Extended_Index := A_Data.First_Index;
      B_Index         : Extended_Index := B_Data.First_Index;
      A_Synch_Index   : Extended_Index := A_Index;
      --  A_Setting_Index : Extended_Index := A_Synch_Index + 1;
      --  A_Click_Index   : Extended_Index := A_Synch_Index + 2;
      B_Synch_Index   : Extended_Index := B_Index;
      --  B_Setting_Index : Extended_Index := B_Synch_Index + 1;
      --  B_Click_Index   : Extended_Index := B_Synch_Index + 2;
      Count           : Natural := 0;
      anEvent         : NIST_Event_Record;
      Events          : Nist_Event_List;

      procedure Nearest_A_Time is
         Ref_Time   : constant Double_Positive :=
          B_Data (B_Index).Time_Tag;
          A_Time    : Double_Positive;
          Time_Diff : Double_Natural;
      begin
         while A_Index < A_Data.Last_Index and then
            A_Data (A_Index).Time_Tag <  Ref_Time loop
               A_Index := A_Index + 1;
         end loop;
         A_Time := A_Data (A_Index).Time_Tag;
         Time_Diff := Double_Natural (abs (A_Time - Ref_Time));
         if A_Index < A_Data.Last_Index and then
            Double_Natural
            (abs (A_Data (A_Index + 1).Time_Tag - Ref_Time)) < Time_Diff then
            A_Index := A_Index + 1;
         end if;

      end Nearest_A_Time;

      procedure Nearest_B_Time is
         Ref_Time   : constant Double_Positive :=
          A_Data (A_Index).Time_Tag;
          B_Time    : Double_Positive;
          Time_Diff : Double_Natural;
      begin
         while B_Index < B_Data.Last_Index and then
            B_Data (B_Index).Time_Tag <  Ref_Time loop
               B_Index := B_Index + 1;
         end loop;

         B_Time := B_Data (B_Index).Time_Tag;
         Time_Diff := Double_Natural (abs (B_Time - Ref_Time));
         if B_Index < B_Data.Last_Index and then
            Double_Natural
            (abs (B_Data (B_Index + 1).Time_Tag - Ref_Time)) < Time_Diff then
            B_Index := B_Index + 1;
         end if;

      end Nearest_B_Time;

      procedure Next_Sync is
      begin
         A_Synch_Index := A_Synch_Index + 1;
         B_Synch_Index := B_Synch_Index + 1;
         while A_Synch_Index < A_Data.Last_Index - 2 and then
            A_Data (A_Synch_Index).Channel /= Sync loop
               A_Synch_Index := A_Synch_Index + 1;
         end loop;

         while B_Synch_Index < B_Data.Last_Index - 2 and then
            B_Data (B_Synch_Index).Channel /= Sync loop
               B_Synch_Index := B_Synch_Index + 1;
         end loop;

      end Next_Sync;

   begin
      while A_Synch_Index < A_Data.Last_Index - 2 and then
         B_Synch_Index < B_Data.Last_Index - 2 loop
         Count := Count + 1;
         if A_Data (A_Synch_Index + 2).Channel=Click then
            Nearest_B_Time;
            anEvent.A_Click_Mask := 1;
            anEvent.A_Setting := A_Data (A_Synch_Index + 1).Channel;
            if B_Data (B_Synch_Index + 2).Channel = Click then
                  anEvent.B_Click_Mask := 1;
            else
                  anEvent.B_Click_Mask := 0;
            end if;
            anEvent.B_Setting := B_Data (B_Synch_Index + 1).Channel;
            Events.Append (anEvent);

         elsif B_Data (B_Synch_Index + 2).Channel=Click then
            Nearest_A_Time;
            anEvent.B_Click_Mask := 1;
            anEvent.b_Setting := b_Data (B_Synch_Index + 1).Channel;
            if A_Data (A_Synch_Index + 2).Channel = Click then
                  anEvent.A_Click_Mask := 1;
            else
                  anEvent.A_Click_Mask := 0;
            end if;
            anEvent.A_Setting := A_Data (A_Synch_Index + 1).Channel;
            Events.Append (anEvent);
         end if;

         if Count < 7 then
            Put_Line (Routine_Name & "A_Synch_Index, B_Synch_Index"
             & Double_Positive'Image (A_Synch_Index) & ", " &
            Double_Positive'Image (B_Synch_Index));
         end if;
         Next_Sync;
      end loop;
      NIST_Printing.Print_NIST_Event_List ("Events", Events, 1, 7);

      return Events;

   end Match_Events;

   procedure Save_Events (AA_File_Name, AB_File_Name, BA_File_Name,
    BB_File_Name  : String; Events : Nist_Event_List) is
      use Interfaces;
      use Nist_Event_Package;
      Routine_Name : constant String := "Process_Sync_Data.Save_Events ";
      AA_ID        : File_Type;
      BA_ID        : File_Type;
      AB_ID        : File_Type;
      BB_ID        : File_Type;
      Events_Curs  : Cursor := First (Events);
      Rec          : NIST_Event_Record;
      Click_A      : Integer;
      Click_B      : Integer;
   begin
      Create (AA_ID, Out_File, AA_File_Name);
      Create (AB_ID, Out_File, AB_File_Name);
      Create (BA_ID, Out_File, BA_File_Name);
      Create (BB_ID, Out_File, BB_File_Name);

      while Has_Element (Events_Curs) loop
         Rec :=  Element (Events_Curs);
         if Rec.A_Click_Mask > 0 then
            Click_A := 1;
         else
             Click_A := -1;
         end if;

         if Rec.B_Click_Mask > 0 then
            Click_B := 1;
         else
             Click_B := -1;
         end if;
         case Rec.A_Setting is
            when Pol_0 =>
               if Rec.B_Setting = Pol_0 then
                  Put_Line (AA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B));
               else
                  Put_Line (AB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B));
               end if;
            when Pol_45 =>
               if Rec.B_Setting = Pol_0 then
                  Put_Line (BA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B));
               else
                  Put_Line (BB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B));
               end if;

            when others => null;
         end case;
         Next (Events_Curs);
      end loop;

      Close (AA_ID);
      Close (AB_ID);
      Close (BA_ID);
      Close (BB_ID);
      Put_Line (Routine_Name & "AA Events written to " & AA_File_Name);
      Put_Line (Routine_Name & "AB Events written to " & AB_File_Name);
      Put_Line (Routine_Name & "BA Events written to " & BA_File_Name);
      Put_Line (Routine_Name & "BB Events written to " & BB_File_Name);

   end Save_Events;

end Process_Data;

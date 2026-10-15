
with Interfaces;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed ;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   --  Max Unsigned_16 is 65535
   Max_Click_Delay : constant Interfaces.Unsigned_16 := 65535;

   procedure Process_Event (A_Data, B_Data : Nist_Data_List;
      A_Index, B_Index : in out Double_Positive;
      Events : in out Nist_Event_List);
   procedure Process_Event_2 (A_Data, B_Data : Nist_Data_List;
      A_Index, B_Index : in out Double_Positive;
      Events : in out Nist_Event_List);
   procedure Set_AB_Clicks
      (Rec : NIST_Event_Record; Click_A, Click_B : out Integer;
      Max_Click_Delay : Interfaces.Unsigned_16);

   function Build_Event_List (A_Data, B_Data : Nist_Data_List;
       Events_Kind : Events_Type) return Nist_Event_List is
      use Nist_Data_Package;
      Routine_Name : constant String := "Process_Data.Build_Event_List ";
      A_Index      : Double_Positive := A_Data.First_Index;
      B_Index      : Double_Positive := B_Data.First_Index;
      Count        : Natural := 0;
      Events       : Nist_Event_List;
   begin
      while A_Index <= A_Data.Last_Index - 2 and then
       B_Index < B_Data.Last_Index - 2 loop
         Count := Count + 1;
         if abs (A_Data (A_Index).Time_Tag - B_Data (B_Index).Time_Tag) < 20 then
            --  This is a confirmed global trial.
            --  Check local SYNC-to-CLICK windows for both A and B separately.
            if Events_Kind = Events_1 then
               Process_Event (A_Data, B_Data, A_Index, B_Index, Events);
            else
               Process_Event_2 (A_Data, B_Data, A_Index, B_Index, Events);
            end if;
         A_Index := A_Index + 1;
         B_Index := B_Index + 1;
         elsif A_Data (A_Index).Time_Tag < B_Data (B_Index).Time_Tag then
            --  A's clock is lagging B's clock.
            A_Index := A_Index + 1;
         else  --  B's clock is lagging than A's clock.
            B_Index := B_Index + 1;
         end if;
      end loop;

      Put_Line (Routine_Name & "Count:" & Integer'Image (Count));

      return Events;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Build_Event_List;

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List; Num_Lines : Natural := 0) is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use Nist_Data_Package;
      Routine_Name : constant String  := "Process_Data.Load_NIST_Data ";
      Source_Size  : constant Double_Natural :=
         Double_Natural (Ada.Directories.Size (Source_File));
      Max_Lines    : Double_Natural;
      Source_ID    : File_Type;
      Data         : Data_Record;
      Line_Num     : Double_Natural := 0;
   begin
      if Num_Lines > 0 then
         Max_Lines := Double_Natural (Num_Lines);
      else
         Max_Lines := Source_Size;
      end if;

      Put_Line (Routine_Name & "Source File: " & Source_File);
      Put_Line (Routine_Name & Source_File & " length: " &
         Double_Natural'Image (Source_Size));
      New_Line;
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) and then
       Line_Num < Max_Lines loop
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
               if Pos_2 > 0 then
               Data.Time_Tag :=
                  Double_Positive'Value (aline (Pos_1 + 1 .. Pos_2 - 1));
               Data.Transfer_ID := Integer'Value (aline (Pos_2 + 1 .. aLine'Last));
               else
                  Data.Time_Tag :=
                     Double_Positive'Value (aline (Pos_1 + 1 .. aLine'Last));
               end if;
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

   procedure Process_Event (A_Data, B_Data : Nist_Data_List;
      A_Index, B_Index : in out Double_Positive;
      Events : in out Nist_Event_List) is
      use Interfaces;
      use Nist_Event_Package;
      Routine_Name   : constant String := "Process_Data.Process_Event ";
      Pulse_Interval : constant Double_Positive := 8064;
      Click_Delay    : Double_Positive;
      anEvent        : NIST_Event_Record;

      function Is_Click_Frame (Data : Nist_Data_List; Index : Double_Positive)
       return Boolean is
      begin
         return Data (Index + 2).Channel = Click and then
          (Data (Index + 1).Channel = Pol_0 or else
          Data (Index + 1).Channel = Pol_45) and then
          Data (Index).Channel = Sync;
      end Is_Click_Frame;

   begin
      if Is_Click_Frame (A_Data, A_Index) or else
         Is_Click_Frame (B_Data, B_Index) then
         anEvent.A_Setting := A_Data (A_Index + 1).Channel;
         anEvent.A_Time_Tag := A_Data (A_Index).Time_Tag;
         anEvent.B_Setting := B_Data (B_Index + 1).Channel;
         anEvent.B_Time_Tag := B_Data (B_Index).Time_Tag;

         if A_Data (A_Index + 2).Channel = Click then
            Click_Delay :=
               A_Data (A_Index + 2).Time_Tag - A_Data (A_Index).Time_Tag;
            anEvent.A_Click_Mask := Shift_Left (unsigned_16 (1),
                  Natural (Click_Delay / Pulse_Interval));
            A_Index := A_Index + 3;
         else
            anEvent.A_Click_Mask := 0;
            A_Index := A_Index + 2;
         end if;

         if B_Data (B_Index + 2).Channel = Click then
            Click_Delay :=
               B_Data (B_Index + 2).Time_Tag - B_Data (B_Index).Time_Tag;
            anEvent.B_Click_Mask := Shift_Left (unsigned_16 (1),
                  Natural (Click_Delay / Pulse_Interval));
         else
            anEvent.B_Click_Mask := 0;
            B_Index := B_Index + 2;
         end if;

         if anEvent.A_Click_Mask <= Max_Click_Delay and then
            anEvent.B_Click_Mask <= Max_Click_Delay then
            Put_Line (Routine_Name & "Appending Event ");
            Events.Append (anEvent);
         else
            Put_Line (Routine_Name & "A, B Click_Masks: " & ", " &
             Unsigned_16'Image (anEvent.B_Click_Mask));
         end if;
      else
         Put_Line (Routine_Name & "not a click");
      end if;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Process_Event;

   procedure Process_Event_2 (A_Data, B_Data : Nist_Data_List;
      A_Index, B_Index : in out Double_Positive;
      Events : in out Nist_Event_List) is
      use Interfaces;
      use Nist_Event_Package;
      Routine_Name   : constant String := "Process_Data.Process_Event_2 ";
      Pulse_Interval : constant Double_Positive := 8064;
      Click_Delay    : Double_Natural;
      anEvent        : NIST_Event_Record;

      function Is_Click_Frame (Data : Nist_Data_List; Index : Double_Positive)
       return Boolean is
      begin
         return Data (Index + 1).Channel = Click and then
          (Data (Index + 2).Channel = Pol_0 or else
          Data (Index + 2).Channel = Pol_45) and then
          Data (Index).Channel = Sync;
      end Is_Click_Frame;

   begin
      if Is_Click_Frame (A_Data, A_Index) or else
         Is_Click_Frame (B_Data, B_Index) then
         anEvent.A_Setting := A_Data (A_Index + 2).Channel;
         anEvent.A_Time_Tag := A_Data (A_Index).Time_Tag;
         anEvent.B_Setting := B_Data (B_Index + 2).Channel;
         anEvent.B_Time_Tag := B_Data (B_Index).Time_Tag;

         if A_Data (A_Index + 1).Channel = Click then
            Put_Line (Routine_Name & "A_Index: " &
                Double_Positive'Image (A_Index));
            Put_Line (Routine_Name & "A_Data (A_Index).Time_Tag: " &
                Double_Positive'Image (A_Data (A_Index).Time_Tag));
            Click_Delay := Types.Double_Natural
                (A_Data (A_Index + 1).Time_Tag - A_Data (A_Index).Time_Tag);
            anEvent.A_Click_Mask := Shift_Left (unsigned_16 (1),
                  Natural (Click_Delay / Double_Natural (Pulse_Interval)));
            A_Index := A_Index + 3;
         else
            anEvent.A_Click_Mask := 0;
            A_Index := A_Index + 2;
         end if;

         if B_Data (B_Index + 1).Channel = Click then
            Click_Delay :=
               Double_Natural
                (B_Data (B_Index + 1).Time_Tag - B_Data (B_Index).Time_Tag);
            anEvent.B_Click_Mask := Shift_Left (unsigned_16 (1),
                  Natural (Click_Delay / Double_Natural (Pulse_Interval)));
         else
            anEvent.B_Click_Mask := 0;
            B_Index := B_Index + 2;
         end if;

         if anEvent.A_Click_Mask <= Max_Click_Delay and then
            anEvent.B_Click_Mask <= Max_Click_Delay then
            Events.Append (anEvent);
         else
            Put_Line (Routine_Name & "Event not added for A, B Click_Masks: " &
               ", " & Unsigned_16'Image (anEvent.B_Click_Mask));
         end if;
      end if;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Process_Event_2;

   procedure Save_Events (AA_File_Name, AB_File_Name, BA_File_Name,
    BB_File_Name  : String; Events : Nist_Event_List) is
      use Nist_Event_Package;
      Routine_Name : constant String := "Process_Data.Save_Events ";
      AA_ID        : File_Type;
      BA_ID        : File_Type;
      AB_ID        : File_Type;
      BB_ID        : File_Type;
      Events_Curs  : Cursor := First (Events);
      anEvent      : NIST_Event_Record;
      Click_A      : Integer;
      Click_B      : Integer;
   begin
      Create (AA_ID, Out_File, AA_File_Name);
      Create (AB_ID, Out_File, AB_File_Name);
      Create (BA_ID, Out_File, BA_File_Name);
      Create (BB_ID, Out_File, BB_File_Name);

      while Has_Element (Events_Curs) loop
         anEvent :=  Element (Events_Curs);
         Set_AB_Clicks (anEvent, Click_A, Click_B, Max_Click_Delay);

         case anEvent.A_Setting is
            when Pol_0 =>
               if anEvent.B_Setting = Pol_0 then
                  Put (AA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (AA_ID, Double_Positive'Image (anEvent.A_Time_Tag) &
                   "," & Double_Positive'Image (anEvent.B_Time_Tag));
               else  --  B_Setting = Pol_45
                  Put (AB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (AB_ID, Double_Positive'Image (anEvent.A_Time_Tag) &
                   "," & Double_Positive'Image (anEvent.B_Time_Tag));
               end if;
            when Pol_45 =>
               if anEvent.B_Setting = Pol_0 then
                  Put(BA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (BA_ID, Double_Positive'Image (anEvent.A_Time_Tag) &
                   "," & Double_Positive'Image (anEvent.B_Time_Tag));
               else  --  B_Setting = Pol_45
                  Put (BB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (BB_ID, Double_Positive'Image (anEvent.A_Time_Tag) &
                   "," & Double_Positive'Image (anEvent.B_Time_Tag));
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

   procedure Set_AB_Clicks
      (Rec : NIST_Event_Record; Click_A, Click_B : out Integer;
      Max_Click_Delay : Interfaces.Unsigned_16) is
      use Interfaces;
   begin
      if Rec.A_Click_Mask > 0 and then
         Rec.A_Click_Mask <= Max_Click_Delay then
         Click_A := 1;
      else
         Click_A := -1;
      end if;

      if Rec.B_Click_Mask > 0 and then
         Rec.B_Click_Mask < Max_Click_Delay then
         Click_B := 1;
      else
         Click_B := -1;
      end if;

   end Set_AB_Clicks;

end Process_Data;

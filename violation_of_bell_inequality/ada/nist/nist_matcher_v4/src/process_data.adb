
with Interfaces;
--  with Ada.Assertions; use Ada.Assertions;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed ;
with Ada.Text_IO; use Ada.Text_IO;

with NIST_Printing; use NIST_Printing;
with Printing; use Printing;
with Types; use Types;

package body Process_Data is

   function Match_Events (A_Data, B_Data : Nist_Data_List;
    Sync_Pairs : Match_List) return Nist_Event_List;
   function Match_Syncs (A_Data, B_Data : Nist_Data_List)
       return Match_List;
   procedure Set_AB_Clicks
      (Rec : NIST_Event_Record; Click_A, Click_B : out Integer;
      Max_Click_Delay : Interfaces.Unsigned_16);
   --  function Set_Outcome (Click_A, Click_B : Integer) return String_3;

   procedure Build_Event_List (A_Data, B_Data : in out Nist_Data_List;
      Events : out Nist_Event_List) is
      Routine_Name : constant String := "Process_Data.Build_Event_List ";
      Sync_Pairs   : constant Match_List := Match_Syncs (A_Data, B_Data);
   begin
      Events := Match_Events (A_Data, B_Data, Sync_Pairs);

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
               Data.Time_Tag :=
                  Double_Positive'Value (aline (Pos_1 + 1 .. Pos_2 - 1));
               Data.Transfer_ID := Integer'Value (aline (Pos_2 + 1 .. aLine'Last));
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

   function Match_Events (A_Data, B_Data : Nist_Data_List;
    Sync_Pairs : Match_List) return Nist_Event_List  is
      use Interfaces;
      use Nist_Data_Package;
      Routine_Name    : constant String := "Process_Data.Match_Events ";
      Pulse_Interval  : constant Double_Positive := 8064;
      Sync_Pairs_Curs : Match_Package.Cursor := Sync_Pairs.First;
      Synch_Pair      : Index_Record;
      Click_Delay     : Double_Positive;
      Count           : Natural := 0;
      anEvent         : NIST_Event_Record;
      Events          : Nist_Event_List;
   begin
      while Match_Package.Has_Element (Sync_Pairs_Curs) and then
         Match_Package.To_Index (Sync_Pairs_Curs) + 2 <=
          Sync_Pairs.Last_Index loop
         Count := Count + 1;
         Synch_Pair := Match_Package.Element (Sync_Pairs_Curs);
         if A_Data (Synch_Pair.A_Index + 2).Channel = Click or else
            B_Data (Synch_Pair.B_Index + 2).Channel = Click then
            if A_Data (Synch_Pair.A_Index + 2).Channel = Click then
               Click_Delay := A_Data (Synch_Pair.A_Index + 2).Time_Tag -
                              A_Data (Synch_Pair.A_Index).Time_Tag;
               anEvent.A_Click_Mask :=
                  Shift_Left (unsigned_16 (1), Natural (Click_Delay / Pulse_Interval));
            else
               anEvent.A_Click_Mask := 0;
            end if;
            anEvent.A_Setting := A_Data (Synch_Pair.A_Index + 1).Channel;
            anEvent.Time_Tag := A_Data (Synch_Pair.A_Index + 1).Time_Tag;

            if B_Data (Synch_Pair.B_Index + 2).Channel = Click then
               Click_Delay := B_Data (Synch_Pair.B_Index + 2).Time_Tag -
                              B_Data (Synch_Pair.B_Index).Time_Tag;
               anEvent.B_Click_Mask :=
                  Shift_Left (unsigned_16 (1), Natural (Click_Delay / 8064));
            else
               anEvent.B_Click_Mask := 0;
            end if;
            anEvent.B_Setting := B_Data (Synch_Pair.B_Index + 1).Channel;
            anEvent.Time_Tag := B_Data (Synch_Pair.B_Index + 1).Time_Tag;

            if A_Data (Synch_Pair.A_Index + 2).Channel /= Overflow and then
               B_Data (Synch_Pair.B_Index + 2).Channel /= Overflow then
               Events.Append (anEvent);
            end if;
         end if;

         Match_Package.Next (Sync_Pairs_Curs);
      end loop;

      --  Put_Line (Routine_Name & "Max Click_Delay" &
      --     Double_Positive'Image (Max_Click_Delay));
      --  Put_Line (Routine_Name & "Max Click_Delay / 16:" &
      --     Double_Positive'Image (Max_Click_Delay / 16));
      Print_NIST_Event_List ("Events", Events, 61, 81);

      return Events;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Events;

   function Match_Syncs (A_Data, B_Data : Nist_Data_List)
       return Match_List  is
      use Match_Package;
      use Nist_Data_Package;
      Routine_Name    : constant String := "Process_Data.Match_Syncs ";
      --  Time difference between first two A syncs: 129104
      Time_Slot       : constant Double_Positive := 20;
      A_Index         : Double_Positive := A_Data.First_Index;
      B_Index         : Double_Positive := B_Data.First_Index;
      A_Time          : Double_Positive;
      Item            : Index_Record;
      Synch_Pairs     : Match_List;
      Found           : Boolean := False;
   begin
      Put_Line (Routine_Name & "A_Data size: " &
       Integer'Image (Integer (A_Data.Length)));
      Put_Line (Routine_Name & "B_Data size: " &
       Integer'Image (Integer (B_Data.Length)));

      while A_Index < A_Data.Last_Index and then
       B_Index < B_Data.Last_Index loop
         if A_Data (A_Index).Channel = Sync then
            A_Time := A_Data (A_Index).Time_Tag;
            Found := False;
            while not Found and then B_Index < B_Data.Last_Index loop
               Found := B_Data (B_Index).Channel = Sync;
               if Found then
                  if abs (B_Data (B_Index).Time_Tag - A_Time) <= Time_Slot then
                     Item.A_Index := A_Index;
                     Item.B_Index := B_Index;
                  elsif A_Time < B_Data (B_Index).Time_Tag  then
                     A_Index := A_Index + 1;
                  else
                     B_Index := B_Index + 1;
                  end if;
                  Synch_Pairs.Append (Item);
               end if;
               B_Index := B_Index + 1;
            end loop;
         end if;
         A_Index := A_Index + 1;
         B_Index := B_Index + 1;
      end loop;

      Put_Line (Routine_Name & "Number of synch matches: " &
       Integer'Image (Integer (Synch_Pairs.Length)) & ",  Time Slot:" &
       Double_Positive'Image (Time_Slot));
      Print_Match_List ("Synch_Pairs", Synch_Pairs, 195, 200);
      Print_NIST_Data_List ("A_Data", A_Data, 95, 100);
      Print_NIST_Data_List ("B_Data", B_Data, 95, 100);
      return Synch_Pairs;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Syncs;

   function Match_Syncs_1 (A_Data, B_Data : Nist_Data_List)
       return Match_List  is
      use Match_Package;
      use Nist_Data_Package;
      Routine_Name    : constant String := "Process_Data.Match_Syncs ";
      --  Time difference between first two A syncs: 129104
      Time_Slot       : constant Double_Positive := 1000;
      A_Time          : Double_Positive;
      B_Index         : Double_Positive := B_Data.First_Index;
      Item            : Index_Record;
      Synch_Pairs     : Match_List;
      Found           : Boolean := False;
   begin
      Put_Line (Routine_Name & "A_Data size: " &
       Integer'Image (Integer (A_Data.Length)));
      Put_Line (Routine_Name & "B_Data size: " &
       Integer'Image (Integer (B_Data.Length)));

      for A_Index in A_Data.First_Index .. A_Data.Last_Index loop
         if A_Data (A_Index).Channel = Sync then
            A_Time := A_Data (A_Index).Time_Tag;
            Found := False;
            while not Found and then B_Index < B_Data.Last_Index loop
               Found := B_Data (B_Index).Channel = Sync and then
                B_Data (B_Index).Time_Tag - A_Time <= Time_Slot;
               if Found then
                  Item.A_Index := A_Index;
                  Item.B_Index := B_Index;
                  Synch_Pairs.Append (Item);
               end if;
               B_Index := B_Index + 1;
            end loop;
         end if;
      end loop;

      Put_Line (Routine_Name & "Number of synch matches: " &
       Integer'Image (Integer (Synch_Pairs.Length)) & ",  Time Slot:" &
       Double_Positive'Image (Time_Slot));
      Print_Match_List ("Synch_Pairs", Synch_Pairs, 195, 200);
      Print_NIST_Data_List ("A_Data", A_Data, 195, 200);
      Print_NIST_Data_List ("B_Data", B_Data, 195, 200);
      return Synch_Pairs;

   end Match_Syncs_1;

   procedure Save_Events (AA_File_Name, AB_File_Name, BA_File_Name,
    BB_File_Name  : String; Events : Nist_Event_List) is
      use Interfaces;
      use Nist_Event_Package;
      Routine_Name : constant String := "Process_Data.Save_Events ";
      Max_Click_Delay : constant Unsigned_16 := 32768;
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
         Set_AB_Clicks (Rec, Click_A, Click_B, Max_Click_Delay);

         case Rec.A_Setting is
            when Pol_0 =>
               if Rec.B_Setting = Pol_0 then
                  Put (AA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (AA_ID, Double_Positive'Image (Rec.Time_Tag));
               else
                  Put (AB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (AB_ID, Double_Positive'Image (Rec.Time_Tag));
               end if;
            when Pol_45 =>
               if Rec.B_Setting = Pol_0 then
                  Put(BA_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (BA_ID, Double_Positive'Image (Rec.Time_Tag));
               else
                  Put (BB_ID, Integer'Image (Click_A)
                     & "," & Integer'Image (Click_B) & ",");
                  Put_Line (BB_ID, Double_Positive'Image (Rec.Time_Tag));
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
         Rec.A_Click_Mask < Max_Click_Delay then
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

   --  function Set_Outcome (Click_A, Click_B : Integer) return String_3 is
   --     Outcome : String_3 := "?,?";
   --  begin
   --     case Click_A is
   --        when 1 =>
   --           case Click_B is
   --              when 1 =>
   --                 Outcome := "+,+";
   --              when -1 =>
   --                 Outcome := "+,0";
   --              when others =>
   --                 Outcome := "+,?";
   --           end case;
   --        when -1 =>
   --           case Click_B is
   --              when 1 =>
   --                 Outcome := "0,+";
   --              when -1 =>
   --                 Outcome := "0,0";
   --              when others =>
   --                 Outcome := "0,?";
   --           end case;
   --        when others =>
   --           case Click_B is
   --              when 1 =>
   --                 Outcome := "?,+";
   --              when -1 =>
   --                 Outcome := "?,0";
   --              when others =>
   --                 Outcome := "?,?";
   --           end case;
   --     end case;

   --     return Outcome;

   --  end Set_Outcome;

end Process_Data;

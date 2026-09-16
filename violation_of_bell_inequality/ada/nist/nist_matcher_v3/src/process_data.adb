
with Ada.Assertions; use Ada.Assertions;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed ;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;
--  with Printing; use Printing;

package body Process_Data is

   function Get_Events (Data_In : Nist_Data_List) return  Nist_Data_List;
   function Match_Events (A_Data, B_Data : Nist_Data_List) return Nist_Event_List;
   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List);

   procedure Build_Event_List (A_Data, B_Data : in out Nist_Data_List;
      Events : out Nist_Event_List) is
      use Nist_Data_Package;
      use Nist_Event_Package;
      Routine_Name : constant String := "Process_Data.Build_Event_List ";
      --  A_Index       : Nist_Event_Package.Extended_Index := A_Data.First_Index;
      --  B_Index       : Nist_Event_Package.Extended_Index := B_Data.First_Index;
      --  Synch_Index   : Nist_Event_Package.Extended_Index;
      --  Setting_Index : Nist_Event_Package.Extended_Index;
      --  Click_Index   : Nist_Event_Package.Extended_Index;
   begin
      A_Data := Get_Events (A_Data);
      B_Data := Get_Events (B_Data);
      Events := Match_Events (A_Data, B_Data);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Build_Event_List;

   function Get_Events (Data_In : Nist_Data_List) return  Nist_Data_List is
      use Nist_Data_Package;
      Routine_Name  : constant String := "Process_Data.Get_Events ";
      Data_Index    : Nist_Event_Package.Extended_Index := Data_In.First_Index;
      Synch_Index   : Nist_Event_Package.Extended_Index;
      Setting_Index : Nist_Event_Package.Extended_Index;
      Click_Index   : Nist_Event_Package.Extended_Index;
      Item          : Data_Record;
      Data_Out      : Nist_Data_List;
   begin
      while Data_Index < Data_In.Last_Index - 2 loop
         while Data_In (Data_Index).Channel /= Click and then
         Data_Index < Data_In.Last_Index - 2 loop
            Data_Index := Data_Index + 1;
         end loop;
         Click_Index := Data_Index;
         if Data_In (Click_Index - 2).Channel = Sync and then
            (Data_In (Click_Index - 1).Channel = Pol_0 or else
          Data_In (Click_Index - 1).Channel = Pol_45) then
            Setting_Index := Data_Index - 1;
            Synch_Index := Data_Index - 2;
            Item.Channel := Sync;
            Item.Time_Tag := Data_In (Synch_Index).Time_Tag;
            Data_Out.Append (Item);

            Item.Channel := Sync;
            Item.Channel := Data_In (Setting_Index).Channel;
            Item.Time_Tag := Data_In (Setting_Index).Time_Tag;
            Data_Out.Append (Item);

            Item.Channel := Click;
            Item.Time_Tag := Data_In (Click_Index).Time_Tag;
            Data_Out.Append (Item);
         end if;
         Data_Index := Data_Index + 1;
      end loop;

      return Data_Out;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Get_Events;

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
      A_Setting_Index : Extended_Index := A_Synch_Index + 1;
      A_Click_Index   : Extended_Index := A_Synch_Index + 2;
      B_Synch_Index   : Extended_Index := B_Index;
      B_Setting_Index : Extended_Index := B_Synch_Index + 1;
      B_Click_Index   : Extended_Index := B_Synch_Index + 2;
      A_Item          : Data_Record := A_Data.First_Element;
      B_Item          : Data_Record := B_Data.First_Element;
      Time_Width      : constant Double_Positive := 600000;
      anEvent         : NIST_Event_Record;
      Events          : Nist_Event_List;
   begin
      while A_Index < A_Data.Last_Index - 2 and then
         B_Index < B_Data.Last_Index - 2 loop
         Assert (A_Item.Channel = Sync, Routine_Name &
            "invalid A item; " & Channel_Type'Image (A_Item.Channel) &
            " should be Sync");
         Assert (B_Item.Channel = Sync, Routine_Name &
            "invalid B item; " & Channel_Type'Image (B_Item.Channel) &
            " should be Sync");
         if A_Item.Time_Tag <= B_Item.Time_Tag then
            anEvent.A_Setting := A_Item.Channel;
            if B_Item.Time_Tag > A_Item.Time_Tag - Time_Width and then
               B_Item.Time_Tag < A_Item.Time_Tag + Time_Width then
               anEvent.B_Setting := B_Item.Channel;
               B_Index := B_Index + 3;
               B_Item := B_Data (B_Index);
            end if;
            A_Index := A_Index + 3;
            A_Item := A_Data (A_Index);
         else
            anEvent.B_Setting := B_Item.Channel;
            if A_Item.Time_Tag > B_Item.Time_Tag - Time_Width and then
               A_Item.Time_Tag < B_Item.Time_Tag + Time_Width then
               anEvent.A_Setting := A_Item.Channel;
               A_Index := A_Index + 3;
               A_Item := A_Data (A_Index);
            end if;
            B_Index := B_Index + 3;
            B_Item := B_Data (B_Index);
         end if;
      end loop;
      return Events;

   end Match_Events;

   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List) is
     use Match_Package;
      Routine_Name : constant String :=
       "Process_Sync_Data.Save_Match_List ";
      Match_ID     : File_Type;
      M_Curs       : Cursor := First (Index_Pairs);
      Rec          : Index_Record;
   begin
      Create (Match_ID, Out_File, File_Name);
      while Has_Element (M_Curs) loop
         Rec :=  Element (M_Curs);
         Put_Line (Match_ID, Double_Positive'Image (Rec.A_Index) & "," &
         Double_Positive'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Data;

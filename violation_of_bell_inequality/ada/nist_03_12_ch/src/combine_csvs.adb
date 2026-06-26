
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_Data; use Combine_Data;
--  with Printing; use Printing;

with Utils; use Utils;

package body Combine_CSVs is

   procedure Add_Photon_Data
     (Data_CSV     : String; Combined : in out String53_Array; A : Boolean;
      AB_Length    : Positive) is
      Routine_Name : constant String := "Combine_CSVs.Add_Photon_Data ";
      Data         : String21_Array (1 .. AB_Length);
      Data_Item    : String_21;
      aRow         : String_53 := (others => '@');
      Item_Start   : Positive;
      Item_End     : Positive;
   begin
      if A then
         Item_Start := 1;
         Item_End :=  21;
      else
         Item_Start := 23;
         Item_End := 43;
      end if;
      --  Put_Line ("Add_Photon_Data Item_Start, Item_End: " &  Integer'Image (Item_Start) &
      --              ", " & Integer'Image (Item_End));

      Load_Photon_Data (Data_CSV, Data);
      New_Line;

      for row in Combined'Range loop
         if not A then
            aRow := Combined (row);
         end if;

         Data_Item := Data (row);
         for index in Item_Start .. Item_End loop
            aRow (index) := Data_Item (index - Item_Start + 1);
         end loop;
         aRow (Item_End + 1) := ',';
         Combined (row) := aRow;
      end loop;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Add_Photon_Data;

   procedure Combine
     (Photon_Data_A_CSV, Photon_Data_B_CSV, OEM_Data_A_CSV,
      OEM_Data_B_CSV, Combined_CSV : String;  Num_Rows : Positive := 30) is
      Routine_Name    : constant String := "Combine_CSVs.Combine ";
      Photon_A_Length : constant Positive :=
        Positive (Size (Photon_Data_A_CSV));
      Photon_B_Length : constant Positive :=
        Positive (Size (Photon_Data_B_CSV));
      OEM_A_Length    : constant Positive :=
        Positive (Size (OEM_Data_A_CSV));
      OEM_B_Length    : constant Positive :=
        Positive (Size (OEM_Data_B_CSV));
      OEM_Data_A      : String4_Array (1 .. Num_Rows);
      OEM_Data_B      : String4_Array (1 .. Num_Rows);
      aRow            : String_53 := (others => '#');
      Combined        : String53_Array (1 .. Num_Rows) :=
        (others => (others => '#'));
   begin
      --  Set stack size:  ulimit -s 64000
      --  Original photon data is sorted ascendingly
      Put_Line (Routine_Name & "Photon_Data_A length:" &
                  Integer'Image (Photon_A_Length));
      Put_Line (Routine_Name & "Photon_Data_B length:" &
                  Integer'Image (Photon_B_Length));
      Put_Line (Routine_Name & "OEM_Data_A length:" &
                  Integer'Image (OEM_A_Length));
      Put_Line (Routine_Name & "OEM_Data_B length:" &
                  Integer'Image (OEM_B_Length));

      Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
      Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);

      Add_Photon_Data (Photon_Data_A_CSV, Combined, True, Num_Rows);
      Add_Photon_Data (Photon_Data_B_CSV, Combined, False, Num_Rows);

      for row in Combined'Range loop
         aRow := Combined (row);
         aRow (45 .. 46) := OEM_Data_A (row) (1 .. 2);  --  includes ,
         aRow (47 .. 48) := OEM_Data_B (row) (1 .. 2);
         aRow (49 .. 50) := OEM_Data_A (row) (3 .. 4);
         aRow (51 .. 51) := ",";
         aRow (52 .. 53) := OEM_Data_B (row) (3 .. 4);
         Combined (row) := aRow;
      end loop;

      --  Print_String53_Array (Routine_Name & "Combined", Combined,
      --                        Combined'Last - 4, Combined'Last);
      Save_Data (Combined_CSV, Combined);
      Put_Line (Routine_Name & "Combined_CSV length: " &
                  Integer'Image (Count_Text_File_Lines (Combined_CSV)) & " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Combine;

    procedure Combine_Nist_Det (A_CSV, B_CSV, Combined_CSV : String;
      Num_Rows : Double_Natural := 30) is
      use StringD19_Package;
      Routine_Name : constant String := "Combine_CSVs.Combine_Nist_Det ";
      A_Length     : constant Double_Natural := Double_Natural (Size (A_CSV));
      B_Length     : constant Double_Natural := Double_Natural (Size (B_CSV));
   --     Data_A       : StringD19_Array (1 .. Num_Rows);
   --     Data_B       : StringD19_Array (1 .. Num_Rows);
   --     Combined     : StringD40_Array (1 .. Num_Rows) :=
   --    (others => (others => '#'));
      Data_A       : StringD19_Vector;
      Data_B       : StringD19_Vector;
      Curs_A       : Cursor := Data_A.First;
      Curs_B       : Cursor := Data_B.First;
      Combined     : StringD40_Vector;
      aRow         : String_40 := (others => '#');
      Count        : Double_Natural := 0;
   begin
      --  Set stack size:  ulimit -s 64000
      Put_Line (Routine_Name & "A length:" & Double_Natural'Image (A_Length));
      Put_Line (Routine_Name & "B length:" & Double_Natural'Image (B_Length));

      Load_NIST_Data (A_CSV, Data_A);
      --  Put_Line (Routine_Name & "A_CSV size after Loading: " &
      --           Integer'Image (Count_Text_File_Lines (A_CSV)));
      Load_NIST_Data (B_CSV, Data_B);
      --  Put_Line (Routine_Name & "B_CSV size after Loading: " &
      --           Integer'Image (Count_Text_File_Lines (B_CSV)));

      --  for row in Combined'Range loop
         --    aRow := Combined (row);
      while Has_Element (Data_A.First) and then
       Has_Element (Data_B.First) and then Count < Num_Rows loop
         Count := Count + 1;
         aRow (1 .. 19) := Element (Curs_A);  --  includes ,
         aRow (20 .. 21) := ", ";
         aRow (22 .. 40) := Element (Curs_B);
         Combined.Append (aRow);
      Next (Curs_A);
      Next (Curs_B);
      end loop;
         --    aRow (1 .. 19) := Data_A (row);  --  includes ,
         --    aRow (20 .. 21) := ", ";
         --    aRow (22 .. 40) := Data_B (row);
         --    Combined (row) := aRow;
      --  end loop;

      --  Print_String40_Array (Routine_Name & "Combined", Combined,
      --                        Combined'Last - 4, Combined'Last);
      Save_NIST_Data (Combined_CSV, Combined);
      Put_Line (Routine_Name & "Det Combined_CSV length: " &
                  Integer'Image (Count_Text_File_Lines (Combined_CSV)) &
                   " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Combine_Nist_Det;

   procedure Combine_Nist_Synch (A_CSV, B_CSV, Combined_Synch_CSV : String;
      Num_Rows : Double_Natural := 30) is
      use StringD19_Package;
      Routine_Name : constant String := "Combine_CSVs.Combine_Nist_Synch ";
      A_Length     : constant Double_Natural := Double_Natural (Size (A_CSV));
      B_Length     : constant Double_Natural := Double_Natural (Size (B_CSV));
      --  Min_A_Rows   : constant Double_Natural :=
      --     Double_Natural'Min (A_Length, Num_Rows);
      --  Min_Rows     : constant Double_Natural :=
      --     Double_Natural'Min (B_Length, Min_A_Rows);
      --  Data_A       : StringD19_Array (1 .. Num_Rows);
      --  Data_B       : StringD19_Array (1 .. Num_Rows);
      Data_A       : StringD19_Vector;
      Data_B       : StringD19_Vector;
      Curs_A       : Cursor := Data_A.First;
      Curs_B       : Cursor := Data_B.First;
      Combined     : StringD40_Vector;
      aRow         : String_40 := (others => '#');
      Count        : Double_Natural := 0;
   begin
      --  Set stack size:  ulimit -s 64000 if necessary
      Put_Line (Routine_Name & "A length:" & Double_Natural'Image (A_Length));
      Put_Line (Routine_Name & "B length:" & Double_Natural'Image (B_Length));

      Load_NIST_Data (A_CSV, Data_A);
      Load_NIST_Data (B_CSV, Data_B);

      --  for row in Data_A'Range loop
      while Has_Element (Curs_A) and then
       Has_Element (Curs_B) and then Count < Num_Rows loop
         Count := Count + 1;
         aRow (1 .. 19) := Data_A (Curs_A);  --  includes ,
         aRow (20 .. 21) := ", ";
         aRow (22 .. 40) := Data_B (Curs_B);
         Combined.Append (aRow);
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      --  Print_String40_Array (Routine_Name & "Combined", Combined,
      --                        Combined'Last - 4, Combined'Last);
      Save_NIST_Sync_Data (Combined_Synch_CSV, Combined);
      Put_Line (Routine_Name & "Synch Combined_CSV length: " &
                  Integer'Image (Count_Text_File_Lines (Combined_Synch_CSV)) &
                   " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Combine_Nist_Synch;

end Combine_CSVs;


with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_Data; use Combine_Data;
--  with Printing; use Printing;

with Utils; use Utils;

package body Combine_CSVs is

    procedure Combine_Nist (A_CSV, B_CSV, Combined_CSV : String;
      Num_Rows : Double_Natural := 30) is
      use Ada.Directories;
      use StringD19_Package;
      Routine_Name : constant String := "Combine_CSVs.Combine_Nist_Det ";
      A_Length     : constant Double_Natural := Double_Natural (Size (A_CSV));
      B_Length     : constant Double_Natural := Double_Natural (Size (B_CSV));
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
      Load_NIST_Data (B_CSV, Data_B);

      Curs_A := Data_A.First;
      Curs_B := Data_B.First;
      while Has_Element (Curs_A) and then
       Has_Element (Curs_B) and then Count < Num_Rows loop
         Count := Count + 1;
         aRow (1 .. 19) := Element (Curs_A);  --  includes ,
         aRow (20 .. 21) := ", ";
         aRow (22 .. 40) := Element (Curs_B);
         Combined.Append (aRow);
      Next (Curs_A);
      Next (Curs_B);
      end loop;

      Save_NIST_Data (Combined_CSV, Combined);
      Put_Line (Routine_Name & "Det Combined_CSV length: " &
                  Integer'Image (Count_Text_File_Lines (Combined_CSV)) &
                   " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Combine_Nist;


end Combine_CSVs;

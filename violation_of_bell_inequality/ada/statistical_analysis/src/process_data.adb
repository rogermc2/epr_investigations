
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   --  Sample_Data (OEM_A (3) & "," & OEM_B (3) & "," &
   --  Natural'Image (A_Val * B_Val) & "," & Natural'Image (A_Val + B_Val));
   function Get_Detections(OEM : String) return Sample_Data_List is
      OEM_ID : File_Type;
      aLine  : OEM_String;
      Sample : Sample_Data_Record;
      Detections : Sample_Data_List;
   begin
      Open (OEM_ID, In_File, OEM);
      while not End_Of_File (OEM_ID) loop
         aLine := Get_Line (OEM_ID);
         Sample.A_Detection := Natural'Value (aLine (1 .. 1));
         Sample.B_Detection := Natural'Value (aLine (3 .. 3));
         Detections.Append (Sample);
      end loop;
      Close (OEM_ID);

      return Detections;

   end Get_Detections;

end Process_Data;

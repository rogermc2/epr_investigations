
with Interfaces;

with Types; use Types;

package  Utils is

   function Count_Text_File_Lines (File_Name  : String) return Natural;
   pragma Inline (Count_Text_File_Lines);
   function Get_Integer_List (Data : Sample_Data_List;
                              Selection : Detect_Type) return Integer_List;
   procedure Swap_Endian (Data : in out Interfaces.Unsigned_16);
   function To_IEEE_Double_Big_Endian (Data : Byte_Array) return Double;

end Utils;


with Types; use Types;

package Maths is

   function Sample_Error
     (Data : Sample_Data_List; Std_Deviation : Float) return Float;
   function Sample_Std_Deviation
     (Data : Integer_List; Mean : Float) return Float;

end Maths;

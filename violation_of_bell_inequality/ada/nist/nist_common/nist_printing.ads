
with NIST_Types; use NIST_Types;

package NIST_Printing is

   procedure Print_Processed_Data (Data : Data_Record);
   procedure Print_Raw_Data (Raw_Data : Raw_Data_Record);
   procedure Print_Setting_Time_Vector
    (Name  : String; Data : Setting_Time_Vector;
      Start : Positive := 1; Finish : Natural := 0);

end NIST_Printing;
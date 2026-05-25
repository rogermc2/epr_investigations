
with Types; use Types;

package Printing is

   --  procedure Print_Integer_List
   --    (Name  : String; Data : Integer_List;
   --     Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Result_Vector
     (Name : String; Data : Result_Vector;
      Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Statistics
   --    (Message : String; Mean_A, Mean_B, Mean_AB : Float;
   --     Detections : Sample_Data_List; Det_A, Det_B : Detect_Type);

end Printing;

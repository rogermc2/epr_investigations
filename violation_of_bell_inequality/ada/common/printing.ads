
with Types; use Types;

package Printing is

   procedure Print_Byte_Array (Name  : String; Data : Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
   --     Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Integer_List
     (Name  : String; Data : Integer_List;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Double_Integer_Vector
      (Name  : String; Data : Double_Integer_Vector;
       Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Match_List (Name  : String; Data : Match_List;
                              Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Double_Natural_Vector
   --      (Name  : String; Data : Double_Natural_Vector;
   --       Start : Positive := 1; Finish : Natural := 0);
   procedure Print_StringD40_Vector
       (Name  : String; Data : StringD40_Vector;
        Start : Double_Positive := 1; Finish : Double_Natural := 0);
   procedure Print_Statistics
     (Message : String; Mean_A, Mean_B, Mean_AB : Float;
      Detections : Sample_Data_List; Det_A, Det_B : Detect_Type);
   procedure Print_String1_Array
     (Name  : String; Data : String1_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String20_Array
     (Name  : String; Data : String20_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String3_Array
     (Name  : String; Data : String3_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String23_Array
     (Name  : String; Data : String23_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String33_Array
     (Name  : String; Data : String33_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String53_Array
     (Name  : String; Data : String53_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String8_Array
     (Name  : String; Data : String8_Array;
      Start : Positive := 1; Finish : Natural := 0);

end Printing;

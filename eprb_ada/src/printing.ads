
with Analysis_Types; use Analysis_Types;
with Types; use Types;

package Printing is

   procedure Print_Analysis_Data (Analysis_Data : Analysis_Vector);
   procedure Print_Analysis_Item (Name          : String := "";
                                  Analysis_Data : Analysis_Record;
                                  Print_Header  : Boolean := False);
   procedure Print_Data_Record (Name : String; Data : Data_Record);
   procedure Print_Float_Vector
     (Name   : String; Data : Float_Vector; Start : Positive := 1;
      Finish : Natural := 0);
   procedure Print_Outcome_Vector
     (Name   : String; Data : Outcome_Vector; Start : Positive := 1;
      Finish : Natural := 0);
   procedure Print_Particles
     (Name  : String; Data : Particle_Vector;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Settings (Name : String; Data : Settings_Vector);
   procedure Print_Result_Vector
     (Name  : String; Data : Result_Vector;
      Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Statistics
   --    (Message : String; Mean_A, Mean_B, Mean_AB : Float;
   --     Detections : Sample_Data_List; Det_A, Det_B : Detect_Type);

end Printing;

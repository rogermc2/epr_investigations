
with Estimators;
with Process_Data; use Process_Data;
with Samples;

procedure Statistics is

  type Data_Vector is array (Positive range <>) of Float;
  type Quantile_Table is array (Positive range <>) of Float;
   package Float_Estimators is new Estimators (Float, Data_Vector);
   package Float_Samples is new
     Samples (Float, Quantile_Table,  use_sub_histogram_index => False);

   A_Directory   : constant String := "../";
   B_Directory   : constant String := A_Directory;
   OEM_00        : constant String := A_Directory & "OEM_00.csv";
   OEM_01        : constant String := A_Directory & "OEM_10.csv";
   OEM_10        : constant String := A_Directory & "OEM_01.csv";
   OEM_11        : constant String := A_Directory & "OEM_11.csv";
   Detections_00 : Sample_Data_List := Get_Detections (OEM_00);
   Detections_01 : Sample_Data_List := Get_Detections (OEM_01);
   Detections_10 : Sample_Data_List := Get_Detections (OEM_10);
   Detections_11 : Sample_Data_List := Get_Detections (OEM_11);
begin
   null;
end Statistics;

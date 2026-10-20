
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Data is

   function Build_Event_List (A_Data, B_Data : Nist_Data_List;
       Events_Kind : Events_Type) return Nist_Event_List;
   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List; Num_Lines : Natural := 0);
   procedure Match_Sync_Times
     (CSV_A, CSV_B, Match : String; Delta_A, Width : Double_Natural;
      Num_Found           : out Natural; Selected_Pairs : out Match_List;
      Num_Rows            : Natural := 0);
   procedure Save_Events (AA_File_Name, AB_File_Name,
    BA_File_Name, BB_File_Name : String;
    Events : Nist_Event_List);

end Process_Data;

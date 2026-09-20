
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Data is

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List);
   procedure Build_Event_List (A_Data, B_Data : in out Nist_Data_List;
      Events : out Nist_Event_List);
   procedure Save_Events (AA_File_Name, AB_File_Name,
    BA_File_Name, BB_File_Name : String;
    Events : Nist_Event_List);

end Process_Data;

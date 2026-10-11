
with NIST_Types; use NIST_Types;

package Process_Data is

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List; Num_Lines : Natural := 0);
   function Build_Event_List (A_Data, B_Data : Nist_Data_List)
    return Nist_Event_List;
   procedure Save_Events (AA_File_Name, AB_File_Name,
    BA_File_Name, BB_File_Name : String;
    Events : Nist_Event_List);

end Process_Data;


with Delft_Types; use Delft_Types;

package Process_Data is

   procedure Get_Data (Source_File, Settings_File : String;
          Target : out Delft_Data_List);
   procedure Save_Data (aa, ab, ba, bb : String; Data : Delft_Data_List);

end Process_Data;

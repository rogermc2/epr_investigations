
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Types; use Types;

package Detection is

   procedure Run_Detection (File_Name : String; Settings : Settings_Vector;
                            Out_File : out Unbounded_String);

end Detection;


with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Types; use Types;

package Detection is

   procedure Run_Detection (Settings : Settings_Vector; File_Name : String;
                            Out_File : out Unbounded_String);

end Detection;

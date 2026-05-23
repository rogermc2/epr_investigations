
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Types; use Types;

package Analysis is

   procedure Analyse (A_File_Name, B_File_Name : Unbounded_String;
                      Settings                 : Settings_Vector);

end Analysis;

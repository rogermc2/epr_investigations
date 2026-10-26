
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;
package body Display is

   procedure Display_Detector_Settings (Settings : Angles_Record) is
   begin
      Put_Line ("Detector settings:");
      Print_Float_Line ("a0", Float (Settings.A_0));
      Print_Float_Line ("a1", Float (Settings.A_1));
      Print_Float_Line ("b0", Float (Settings.B_0));
      Print_Float_Line ("b1", Float (Settings.B_1));
      New_Line;
   end Display_Detector_Settings;

end Display;
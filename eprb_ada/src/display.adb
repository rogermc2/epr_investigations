with Vector_Functions; use Vector_Functions;

package body Display is

   procedure Display_Results (A, B : Settings_Vector) is
      use Setting_Pairs_Vector_Package;
      Pairs : Setting_Pairs_Vector :=  Setting_Pairs (A, B);
      Size  : constant Natural := Natural (Length (Pairs));
   begin
      if Size > 4 then
         Pairs := Empty_Vector;
         Pairs.Append ((0.0, 22.5));
         Pairs.Append ((0.0, 67.5));
         Pairs.Append ((45.0, 22.5));
         Pairs.Append ((45.0, 67.5));
      end if;

   end Display_Results;

end Display;

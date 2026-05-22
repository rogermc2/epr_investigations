
with Ada.Text_IO; use Ada.Text_IO;

with Vector_Functions; use Vector_Functions;

package body Display is

   procedure Display_Results (A, B : Result_Vector) is
      use Setting_Pairs_Vector_Package;
      Pairs    : Setting_Pairs_Vector :=  Setting_Pairs (A, B);
      --  Size     : Natural := Natural (Length (Pairs));
      Curs     : Cursor := Pairs.First;
      Pair     : Pair_Data;
      Result_A : Result_Data;
      Result_B : Result_Data;
      Item_1   : Float;
      Item_2   : Float;
      A_Deg    : Float;
      B_Deg    : Float;
      As       : Boolean;
      Bs       : Boolean;
      Ts       : Boolean;
      K        : Natural := 0;
   begin
      if Natural (Length (Pairs)) > 4 then
         Pairs := Empty_Vector;
         Pairs.Append ((0.0, 22.5));
         Pairs.Append ((0.0, 67.5));
         Pairs.Append ((45.0, 22.5));
         Pairs.Append ((45.0, 67.5));
      end if;

      Put_Line ("Expectation values:");
      Put_Line ("Settings  N_ab  Sim<AB>  QM<AB> Sim Std Err");

      Filter_Matrix (A, B, Pairs);

   end Display_Results;

end Display;

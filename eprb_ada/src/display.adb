
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
      Put_Line ("Settings  N_ab  Sim <AB>  QM <AB> Sim Std Err");

      --  while Has_Element (Curs) loop
      --     Pair := Element (Curs);
      --     K := K + 1;
      --     Result_A := A (K);
      --     Result_B := B (K);
      --     A_Deg := Result_A.Setting;
      --     B_Deg := Result_B.Setting;
      --     declare
      --        P_1 : Integer := Pair.First;
      --        P_2 : Integer := Pair.Second;
      --     begin
      --        As := A_Deg = P_1;
      --        Bs := B_Deg = P_2;
      --        Ts := As and Bs;
      --        Ai := alice [Ts, 1] ;
      --        Bj := bob [Ts, 1];
      --     end;
      --     Next (Curs);
      --  end loop;

   end Display_Results;

end Display;


package body Types is

--     Precision : constant Float := 10.0 ** (-6);

   --  ------------------------------------------------------------------------

   function Transpose (Values : Integer_List_2D) return  Integer_List_2D is
      use Ada.Containers;
      Num_Rows : constant Positive := Positive (Values.Length);
      Num_Cols : constant Count_Type := Values.Element (1).Length;
      In_Row   : Integer_List;
      Out_Row  : Integer_List;
      Result   : Integer_List_2D;
   begin
      Result.Set_Length (Num_Cols);
      for row in 1 .. Num_Rows loop
         In_Row := Values.Element (row);
         for index in In_Row.First_Index ..  In_Row.Last_Index loop
            Out_Row := Result.Element (index);
            Out_Row.Append (In_Row.Element (index));
            Result.Replace_Element (index, Out_Row);
         end loop;
      end loop;

      return Result;

   end Transpose;

   --  -------------------------------------------------------------------------

end Types;

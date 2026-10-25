
package Chi_Sq is
   type Quadrant_Index is range 1 .. 4;
   type Count_Array is array (Quadrant_Index) of Long_Float;
   --  Observed counts from your 1.0 ns optimal window run
   Observed : constant Count_Array :=
      (1 => 20.0,  -- 00 (AA)
      2 => 55.0,  -- 01 (AB)
      3 => 13.0,  -- 10 (BA)
      4 => 22.0);   -- 11 (BB)

   function Compute_Chi_Square (Obs : Count_Array) return Long_Float;

end Chi_Sq;
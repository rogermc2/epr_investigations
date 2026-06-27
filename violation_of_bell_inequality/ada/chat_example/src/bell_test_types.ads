
with Ada.Numerics.Discrete_Random;

package Bell_Test_Types is

   subtype Rand_Range is Integer range 1 .. 100;
   package Rand_Int is new Ada.Numerics.Discrete_Random (Rand_Range);
   use Rand_Int;

   -- 64-bit integers for precision time bins
   type Timetag_Bin is new Long_Long_Integer;
   type Timetag_Array is array (Positive range <>) of Timetag_Bin;

   -- Define a Record for matched events
   type Coincidence_Event is record
      Alice_Time : Timetag_Bin;
      Bob_Time   : Timetag_Bin;
      Delta_Time : Timetag_Bin;
   end record;

end Bell_Test_Types;
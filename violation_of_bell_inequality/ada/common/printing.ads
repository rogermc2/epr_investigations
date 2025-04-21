
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types;

package Printing is

   procedure Print_Byte_Array (Name  : String; Data : Types.Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
   --     Start : Positive := 1; Finish : Natural := 0);

   procedure Print_String6_Array (Name  : String; Data : Types.String6_Array;
                                 Start : Positive := 1; Finish : Natural := 0);

end Printing;

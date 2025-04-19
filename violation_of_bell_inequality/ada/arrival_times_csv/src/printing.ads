
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types;

package Printing is

   procedure Print_Byte_Array (Name  : String; Data : Types.Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
      Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String_List (Name : String; UB : Types.Bounded_String_List;
                                 Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Unbound_List (Name : String; UB : Types.Unbounded_List;
                                 Start : Positive := 1; Finish : Natural := 0);

end Printing;

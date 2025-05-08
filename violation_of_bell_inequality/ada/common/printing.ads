
--  with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types;

package Printing is

   procedure Print_Byte_Array (Name  : String; Data : Types.Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
   --     Start : Positive := 1; Finish : Natural := 0);

   procedure Print_String1_Array (Name  : String; Data : Types.String1_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String20_Array (Name  : String; Data : Types.String20_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String4_Array (Name  : String; Data : Types.String4_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String33_Array (Name  : String; Data : Types.String33_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String46_Array (Name  : String; Data : Types.String46_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_UB_String_Array (Name  : String; Data : Types.UB_String_Array;
   --                                   Start : Positive := 1; Finish : Natural := 0);

end Printing;


with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types;

package Printing is

   procedure Print_Byte_Array (Name  : String; Data : Types.Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0);
   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
   --     Start : Positive := 1; Finish : Natural := 0);

   procedure Print_String1_Array (Name  : String; Data : Types.String1_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String13_Array (Name  : String; Data : Types.String13_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String3_Array (Name  : String; Data : Types.String3_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_String30_Array (Name  : String; Data : Types.String30_Array;
                                  Start : Positive := 1; Finish : Natural := 0);
   procedure Print_UB_String_Array (Name  : String; Data : Types.UB_String_Array;
                                    Start : Positive := 1; Finish : Natural := 0);


end Printing;

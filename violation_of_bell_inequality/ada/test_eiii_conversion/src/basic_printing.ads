
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types;

package Basic_Printing is

   procedure Print_String_List (Name : String; UB : Types.Bounded_String_List;
                                 Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Unbound_List (Name : String; UB : Types.Unbounded_List;
                                 Start : Positive := 1; Finish : Natural := 0);

end Basic_Printing;

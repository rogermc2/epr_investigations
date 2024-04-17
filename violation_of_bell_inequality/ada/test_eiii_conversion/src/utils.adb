with Interfaces;

--  with Ada.Directories; use Ada.Directories;
with Ada.Sequential_IO;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;

with Basic_Printing; use Basic_Printing;

package body Utils is

   package Seq_IO_U8 is new Ada.Sequential_IO (Interfaces.Unsigned_8);

   --  ------------------------------------------------------------------------

   procedure Convert_To_Text (Hex_Source_File, Text_Target_File : String) is
      Hex_Data : Types.Bounded_String_List;
   begin
      Hex_Data := Load_Data (Hex_Source_File);
      Save_Data (Text_Target_File, Hex_Data);
   end Convert_To_Text;

   --  ------------------------------------------------------------------------

   function Hex (Byte : Interfaces.Unsigned_8) return String is
      use Interfaces;
      Hex_Chars    : constant array (Unsigned_8 range 0 .. 15)
        of Character := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                        'A', 'B', 'C', 'D', 'E', 'F');
      Half_Byte_1  : constant Unsigned_8 := Byte mod 16;
      Half_Byte_2  : constant Unsigned_8 := Byte / 16;
   begin
      return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
   end Hex;

   --  ------------------------------------------------------------------------

   function Load_Data (File_Name : String)
                       return Types.Bounded_String_List is
      use Seq_IO_U8;
      Routine_Name : constant String := "Utils.Load_Data ";
      Data_File    : File_Type;
      Data         : Interfaces.Unsigned_8;
      Hex_Data     : Types.Bounded_String_List;
   begin

      Open (Data_File, In_File, File_Name);

      while not End_Of_File (Data_File) loop
         Read (Data_File, Data);
         Hex_Data.Append (Hex (Data));
      end loop;

      Close (Data_File);

      Print_String_List (Routine_Name &
                           "Hex_Data items 1 - 40", Hex_Data, 1, 40);

      return Hex_Data;

   exception
      when others =>
         Ada.Text_IO.Put_Line (Routine_Name & "failed.");
         return Hex_Data;

   end Load_Data;

   --  -------------------------------------------------------------------------

   --     procedure Photon_Data (Source_File, Photon_Times_Directory : String) is
   --        use Ada.Text_IO;
   --        Routine_Name      : constant String := "Utils.Photon_Data ";
   --        Photon_Times_File : constant String :=
   --          Photon_Times_Directory & "Photon_Times.csv";
   --        Source_Size       : constant Natural := Natural (Size (Source_File));
   --        Source_ID         : File_Type;
   --        PT_ID             : File_Type;
   --        Val               : String (1 .. 8);
   --     begin
   --        Ada.Text_IO.Put_Line (Routine_Name & "Source File: " &
   --                                Source_File);
   --        New_Line;
   --        Open (Source_ID, In_File, Source_File);
   --        Create (PT_ID, Out_File, Photon_Times_File);
   --
   --        while Line_Num < Source_Size / 8 and then
   --          not End_Of_File (Source_ID) loop
   --           Line_Num := Line_Num + 1;
   --           for field_num in 1 .. 2 loop
   --              if not End_Of_File (Source_ID) then
   --                 Get (Source_ID, Val);
   --                 if Val = "0000" then
   --                    Put (PT_ID, "0");
   --
   --                 elsif Val = "0001" then
   --                    Put (PT_ID, "1");
   --
   --                 elsif Val = "0002" then
   --                    Put (PT_ID, "2");
   --
   --                 elsif Val = "0003" then
   --                    Put (PT_ID, "3");
   --                 end if;
   --
   --                 if field_num = 1 then
   --                    Put (PT_ID, ",");
   --                 end if;
   --              end if;
   --           end loop;
   --
   --           New_Line (PT_ID);
   --        end loop;
   --
   --        Close (PT_ID);
   --        Close (Source_ID);
   --
   --        Ada.Text_IO.Put_Line (Routine_Name & "Photon times file written to " &
   --                                Photon_Times_Directory);
   --
   --     end Photon_Data;

   --  -------------------------------------------------------------------------

   procedure Photon_Data (Source_File, Photon_Times_Directory : String) is
      use Interfaces;
      use Ada.Streams;
      Routine_Name      : constant String := "Utils.Photon_Data ";
      Photon_Times_File : constant String :=
        Photon_Times_Directory & "Photon_Times.csv";

--        type Data_Format is record
--           Fraction : String (1 .. 52);
--           Exponent : String (53 .. 63);
--           Sign     : String (64 .. 64);
--        end record;

      --  Define the LSB
      FP_Delta          : constant Float := 2.0**(-32);

      type FP is delta FP_Delta range -2.0**15 .. 2.0**15-FP_Delta;
      for FP'Small use FP_Delta;
      for FP'Size use 64;

--        F1 : constant FP := FP'First;
--        F2 : constant FP := FP'Last;

--        Fore      : constant Positive := 53;  --  including sign
--        Aft       : constant Positive := 11;

      package FP_IO is new Ada.Text_IO.Fixed_IO (FP);

--        package Unsigned_64_IO is new Ada.Text_IO.Modular_IO (Unsigned_64);
--        use Unsigned_64_IO;

--        function To_Unsigned_64 is new Ada.Unchecked_Conversion
--          (Source => FP, Target => Unsigned_64);

      Source_ID    : Stream_IO.File_Type;
      PT_ID        : Ada.Text_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Line_Num     : Natural := 0;
--        Val          : String (1 .. 8);
--        Data         : Data_Format;
      Data_String  : String (1 .. 64);
      Out_String   : String (1 .. 64);
      Fraction     : String (1 .. 52);
      Exponent     : String (1 .. 11);
      Sign         : String (1 .. 1);
      Item         : FP;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Ada.Text_IO.New_Line;
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (PT_ID, Ada.Text_IO.Out_File, Photon_Times_File);

      --  Put (File : File_Type; Item : Unsigned_64;
      --  Fore : Field := Default_Fore; Aft : Field := Default_Aft,
      --  Exp  : Field) outputs:
      --  the value of the parameter Item as a decimal literal with the format
      --  defined by Fore, Aft and Exp.
      --  where subtype Field is Integer range 0 .. 255
      --  The format of each floating point value consists of a Fore field,
      --  a decimal point, an Aft field, and
      --  if a nonzero Exp parameter is supplied, the letter E and an Exp field.
      --  bits 0:51 store the 52-bit fraction, f;
      --  bits 52:62 store the 11-bit biased exponent, e;
      --  bit 63 stores the sign bit, s.
      while Line_Num < 21 and then not Stream_IO.End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         String'Read (Data_Stream, Data_String);
         Fraction := Data_String (1 .. 52);
         Exponent := Data_String (53 .. 63);
         Sign := Data_String (64 .. 64);
--           Item := Unsigned_64'Value (Fraction);
         Item := FP'Value (Fraction);

         FP_IO.Put (To => Out_String,  Item => Item);
         Ada.Text_IO.Put_Line (Out_String);
--           Ada.Text_IO.New_Line;
--           FP_IO.Put (PT_ID, F2, Aft => 16);
--           New_Line;
--           FP_IO.Put (PT_ID, To_Unsigned_64 (F1), Base => 16);
--           New_Line;
--           FP_IO.Put (PT_ID, To_Unsigned_64 (F2), Base => 16);
--           New_Line;
      end loop;

      Ada.Text_IO.Close (PT_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line (Routine_Name & "Photon times file written to " &
                              Photon_Times_Directory);

   end Photon_Data;

   --  -------------------------------------------------------------------------

   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List) is
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Save_Data ";
      File_ID      : File_Type;
   begin
      Create (File_ID, Out_File, File_Name);
      for index in Data.First_Index .. Data.Last_Index loop
         Put (File_ID, Data (index));
      end loop;
      Close (File_ID);

      Ada.Text_IO.Put_Line (Routine_Name & File_Name & " written.");

   end Save_Data;

   --  -------------------------------------------------------------------------

end Utils;


with Ada.Integer_Text_IO;
--  with Ada.Float_Text_IO;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Data_Selection is

   type Data_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
      Difference : Double;
   end record;

   function Parse_Line (aLine : String) return Data_Record is
      S_Line : constant String := aLine;
      Pos    : Positive;
      Data   : Data_Record;
   begin
      Ada.Integer_Text_IO.Get (S_Line, Data.A_Index, Pos);
      --  Ada.Integer_Text_IO.Get (S_Line (Pos + 2), Data.B_Index, Pos);
      --  Ada.Float_Text_IO.Get (S_Line (Pos + 2), Data.Difference, Pos);

      return Data;

   end Parse_Line;

   procedure Select_Pairs (Match_CSV : String; C : out Match_List) is
      Routine_Name : constant String := "Process_Data.Select_Pairs ";
      u          : constant Double := Double (10.0 ** (-6));
      v          : constant Double := Double (5.0 * 10.0 ** (-6));
      w          : Double := Double (0.5 * abs (v - u));
      File_ID    : File_Type;
      --  aLine      : String_19;
      Data       : Data_Record;
      Match_Data : Match_List;
      --  delta       : Double :=  Double (0.5 * (u + v));

   begin
      w := 5.0 * 10.0 ** (-9);
      --  print("all_pairs A.head\n", A.head())
      --  print("all_pairs B.head\n", B.head())
      --  print ("all_pairs match\n", match.head(10))

      Put_Line ("w: " & Double'Image (w));

      Open (File_ID, In_File, Match_CSV);
      while not End_Of_File (File_ID) loop
         declare
            aLine : constant String := Get_Line (File_ID);
            Data  : constant Data_Record := Parse_Line (aLine);
         begin
            null;
            --  Put_Line (Routine_Name & "aLine length:" & Integer'Image (Integer (aLine'Length)));
            --  Put_Line (Routine_Name & "aLine: !" & aLine & "!");
            --  if Integer (aLine'Length) = 19 then
               --  Data := Parse_Line (aLine (1 .. 33));
               --  if Data.Difference < w then
               --     C.Append ((Data.A_Index, Data.B_Index));
               --  end if;
            --  end if;
         end ;
         --      if (abs(B.at[b_index,"B Arrival Time"] - A.at[a_index,"A Arrival Time"]) <= w):
         --          C.append([a_index,b_index])
         --  print("C size: ", len(C))
         --  for i in C[:10]:
         --      print(i[0],i[1],A.at[i[0],"A Arrival Time"],B.at[i[1],"B Arrival Time"])
         --  # For individual values
         --  print("all_pairs ndividual A values",f"A[221]: {A.at[221, 'A Arrival Time']:.12f}")
         --  print("all_pairs ndividual B values",f"B[140]: {B.at[140, 'B Arrival Time']:.12f}")
      end loop;

      Put_Line (Routine_Name & "C length:" & Integer'Image (Integer (C.Length)));

   end Select_Pairs;

end Data_Selection;


with Interfaces;

with Types; use Types;

package Utils is

   procedure OEM_Data (Source_File, OEM_Directory : String);
   procedure Swap_Endian (Data : in out Interfaces.Unsigned_16);
   function To_IEEE_Double_Big_Endian (Data  : Byte_Array) return Float;

end Utils;

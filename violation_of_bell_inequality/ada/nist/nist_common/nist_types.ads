
with Ada.Containers.Vectors;

with Types; use Types;

package NIST_Types is

   type Unsigned_Byte is mod 2**8;
   type Unsigned_2_Byte is mod 2**16;
   type Unsigned_8_Byte is mod 2**64;

   type Channel_Type is (Detector_Click, Polarizer_0, Polarizer_45,
                         GPS_Pps, Sync, Overflow, Ch_Error);
   for Channel_Type use (Detector_Click => 0, Polarizer_0 => 2,
                         Polarizer_45 => 3,   GPS_Pps => 5,
                         Sync => 6,           Overflow => 64,
                         Ch_Error => 127);

   type Raw_Data_Record is record
      Channel     : Unsigned_Byte;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Unsigned_2_Byte;
   end record;

   type Data_Record is record
      Channel     : Channel_Type;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Integer;
   end record;

   type Setting_Time_Record is record
      Setting : Channel_Type;
      Time    : Double_Natural;
   end record;

   package Setting_Time_Package is new
     Ada.Containers.Vectors (Double_Positive, Setting_Time_Record);
   subtype Setting_Time_Vector is Setting_Time_Package.Vector;

   end NIST_Types;
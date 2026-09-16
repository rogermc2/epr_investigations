
with Interfaces;
with Ada.Containers.Vectors;

with Types; use Types;

package NIST_Types is

   type Unsigned_Byte is mod 2**8;
   type Unsigned_2_Byte is mod 2**16;
   type Unsigned_8_Byte is mod 2**64;

   type Channel_Type is (Click, Pol_0, Pol_45,
                         GPS_Pps, Sync, Overflow, Ch_Error);
   for Channel_Type use (Click => 0, Pol_0 => 2, Pol_45 => 3,
                        GPS_Pps => 5, Sync => 6, Overflow => 64,
                         Ch_Error => 127);

   type Raw_Data_Record is record
      Channel     : Unsigned_Byte;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Unsigned_2_Byte;
   end record;

   --  package Nist_Raw_Data_Package is new
   --    Ada.Containers.Vectors (Double_Positive, Raw_Data_Record);
   --  subtype Nist_Raw_Data_List is Nist_Raw_Data_Package.Vector;

   type Data_Record is record
      Channel     : Channel_Type;
      Time_Tag    : Double_Positive;
      Transfer_ID : Integer := 0;
   end record;

   package Nist_Data_Package is new
     Ada.Containers.Vectors (Double_Positive, Data_Record);
   subtype Nist_Data_List is Nist_Data_Package.Vector;

   type Setting_Time_Record is record
      Setting : Channel_Type;
      Time    : Double_Natural;
   end record;

   package Setting_Time_Package is new
     Ada.Containers.Vectors (Double_Positive, Setting_Time_Record);
   subtype Setting_Time_Vector is Setting_Time_Package.Vector;

   type NIST_Event_Record is record
      A_Setting    : Channel_Type;
      B_Setting    : Channel_Type;
      A_Click_Mask : Interfaces.Unsigned_16;
      B_Click_Mask : Interfaces.Unsigned_16;
   end record;

   package Nist_Event_Package is new
     Ada.Containers.Vectors (Double_Positive, NIST_Event_Record);
   subtype Nist_Event_List is Nist_Event_Package.Vector;

   end NIST_Types;
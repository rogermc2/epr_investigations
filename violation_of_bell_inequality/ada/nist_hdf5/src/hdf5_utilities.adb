
with Interfaces.C; use Interfaces.C;
with System;
with Ada.Text_IO; use Ada.Text_IO;

package body HDF5_Utilities is

   procedure Read_HDF5 is

      type hid_t is new long;
      type herr_t is new int;
 
      H5F_ACC_RDONLY : constant unsigned := 0;
      H5P_DEFAULT    : constant hid_t := 0;
      H5S_ALL        : constant hid_t := 0;

      H5T_NATIVE_DOUBLE : hid_t;
      pragma Import (C, H5T_NATIVE_DOUBLE, "H5T_NATIVE_DOUBLE_g");

      function H5Fopen
      (Name : char_array; Flags : unsigned; Fapl : hid_t) return hid_t;
      pragma Import (C, H5Fopen, "H5Fopen");

      function H5Dopen2
      (File_Id : hid_t; Name : char_array; Dapl : hid_t) return hid_t;
      pragma Import (C, H5Dopen2, "H5Dopen2");

      function H5Dread
      (Dset_Id    : hid_t;
         Mem_Type   : hid_t;
         Mem_Space  : hid_t;
         File_Space : hid_t;
         Xfer_Plist : hid_t;
         Buf        : System.Address) return herr_t;
      pragma Import (C, H5Dread, "H5Dread");

      function H5Dclose (Dset_Id : hid_t) return herr_t;
      pragma Import (C, H5Dclose, "H5Dclose");

      function H5Fclose (File_Id : hid_t) return herr_t;
      pragma Import (C, H5Fclose, "H5Fclose");

      type Double_Array is array (Positive range <>) of aliased double;

      Data : Double_Array (1 .. 100);

      File : hid_t;
      Dset : hid_t;
      Err  : herr_t;
    begin
      File := H5Fopen (To_C ("yourfile.h5"), H5F_ACC_RDONLY, H5P_DEFAULT);
      Dset := H5Dopen2 (File, To_C ("/data"), H5P_DEFAULT);

      Err := H5Dread
      (Dset,
         H5T_NATIVE_DOUBLE,
         H5S_ALL,
         H5S_ALL,
         H5P_DEFAULT,
         Data (Data'First)'Address);

      for I in Data'Range loop
         Put_Line (I'Image & "  " & double'Image (Data (I)));
      end loop;

      Err := H5Dclose (Dset);
      Err := H5Fclose (File);
end Read_HDF5;

end HDF5_Utilities;
   LIBRARY VendorLib;
   ARCHITECTURE Vendor OF DFlipflop IS
      COMPONENT Dff PORT(D, Clk: IN Bit; Qout: OUT Bit); END COMPONENT;
   BEGIN 
      Ff1: Dff PORT MAP (D => D , Clk => Clk, Qout => Q );
      FOR ALL : Dff USE ENTITY VendorLib.Component.Dff;
   END Vendor;

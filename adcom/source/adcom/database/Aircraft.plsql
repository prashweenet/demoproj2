-----------------------------------------------------------------------------
--
--  Logical unit: Aircraft
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210416  majslk  AD-1086, Added Override Insert___ method and Update___ method
--  210205  waislk  DISO2020R1-564 Added Get_Aircraft_Id_By_Natural_Kys
--  201012  supklk  LMM2020R1-1317, handle aircraft_id for modifications
--  200915  themlk  DISCOP2020R1-123, added get_aircraft_id
--  200831  SWiclk  LMM2020R1-1000, Added Pre_Sync_Action() in order to handle Country Code.
--  200723  TAJALK  LMM2020R1-501, Changes due to generic FW for Sync
--  200716  TAJALK  LMM2020R1-219, Added Get_Key_Id_By_Mx_Unique_Key
--  200703  SWiclk  LMM2020R1-277, Added methods Add_Or_Modify_Sync_Record, Check_Mx_Unique_Id_Exist___, Get_Key_Id_By_Mx_Unique_Id___. 
--  200622  dildlk  LMM2020R1-71, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override

PROCEDURE Check_Insert___ (
   newrec_ IN OUT aircraft_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   aircraft_id_ NUMBER;
   CURSOR get_aircraft_id_cursor IS 
   SELECT AIRCRAFT_ID_SEQ.nextval 
   FROM dual;
BEGIN
   IF(newrec_.aircraft_id IS NULL) THEN
      OPEN get_aircraft_id_cursor;
      FETCH get_aircraft_id_cursor INTO aircraft_id_;
      CLOSE get_aircraft_id_cursor;
      newrec_.aircraft_id := aircraft_id_;
      Client_SYS.Add_To_Attr('AIRCRAFT_ID', aircraft_id_, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT aircraft_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.aircraft_id   = newrec_.aircraft_id;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     aircraft_tab%ROWTYPE,
   newrec_     IN OUT aircraft_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.aircraft_id   = newrec_.aircraft_id;
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
END Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Natural_Keys(
      objid_      OUT VARCHAR2,
      objversion_ OUT VARCHAR2,
      attr_       IN OUT VARCHAR2)
   IS
      serial_number_ aircraft_tab.serial_number%TYPE;
      aircraft_type_code_ aircraft_tab.aircraft_type_code%TYPE;
      
      CURSOR get_key IS 
      SELECT ROWID, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')
      FROM aircraft_tab
      WHERE AIRCRAFT_TYPE_CODE = aircraft_type_code_
      AND SERIAL_NUMBER = serial_number_;
   BEGIN 
      
      serial_number_      :=  Client_SYS.Get_Item_Value('SERIAL_NUMBER', attr_);
      aircraft_type_code_ := Client_SYS.Get_Item_Value('AIRCRAFT_TYPE_CODE', attr_);
      
      OPEN get_key;
      FETCH get_key INTO objid_,objversion_;
      CLOSE get_key;
        
   IF  objid_ IS NOT NULL AND objversion_ IS NOT NULL THEN
      attr_ := Client_SYS.Remove_Attr('SERIAL_NUMBER', attr_);
      attr_ := Client_SYS.Remove_Attr('AIRCRAFT_TYPE_CODE', attr_);
   END IF;
END Get_Id_Version_By_Natural_Keys;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   mxi_country_code_          VARCHAR2(100);
   country_code_              aircraft_tab.country_code%TYPE;
   inventory_id_              av_inventory_tab.inventory_id%TYPE;
   inv_serial_no_oem_         av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_               av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_           av_inventory_tab.manufacture_code%TYPE;
   inv_barcode_               av_inventory_tab.barcode%TYPE;

   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = inv_barcode_;  
   
BEGIN
   local_attr_   := attr_;
   mxi_country_code_ := Client_SYS.Get_Item_Value('COUNTRY_CODE', local_attr_); 
   
   IF (mxi_country_code_ IS NOT NULL AND LENGTH(mxi_country_code_) != 2 ) THEN
      country_code_ := Iso_Country_API.Get_Country_Code_By_Code3(mxi_country_code_);
      IF (country_code_ IS NULL) THEN 
         Error_SYS.Appl_General(lu_name_, 'NOCOUNTRYCODE2: Could not find the country code against Alpha-3 code :P1', mxi_country_code_);
      ELSE 
         Client_SYS.Set_Item_Value('COUNTRY_CODE', country_code_, local_attr_);         
      END IF;
   END IF;
   
   -- Fetching inventory_id from av_inventory_tab
   IF Client_SYS.Item_Exist('PART_NUMBER', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('SERIAL_NUMBER', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NUMBER', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURER', local_attr_);
      inv_barcode_       := Client_SYS.Get_Item_Value('BARCODE', local_attr_);              
      
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;
      
      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated inventory:P1', inv_barcode_);
      END IF;
      
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Aircraft_Id(
   aircraft_alt_id_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_aircraft_id IS
   SELECT aircraft_id
   FROM aircraft_tab
   WHERE alt_id = aircraft_alt_id_;
   
   aircraft_id_ aircraft_tab.aircraft_id%TYPE;
BEGIN
   IF (aircraft_alt_id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO aircraft_id_;
   CLOSE get_aircraft_id;
   RETURN aircraft_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Aircraft_Id;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ aircraft.aircraft_id%TYPE;
   
   CURSOR get_aircraft_id IS 
      SELECT aircraft_id         
        FROM aircraft_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO temp_; 
   CLOSE get_aircraft_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;


FUNCTION Get_Aircraft_Id_By_Natural_Kys(
   aircraft_type_cd_ IN VARCHAR2,
   serial_number_    IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_aircraft_id IS
   SELECT aircraft_id
   FROM aircraft_tab 
   WHERE aircraft_type_code = aircraft_type_cd_
   AND serial_number = serial_number_;
   
   aircraft_id_ aircraft_tab.aircraft_id%TYPE;
BEGIN
   IF (aircraft_type_cd_ IS NULL AND serial_number_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO aircraft_id_;
   CLOSE get_aircraft_id;
   RETURN aircraft_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Aircraft_Id_By_Natural_Kys;

FUNCTION Get_Reg_Code_By_Alt(
   alt_id_ VARCHAR2) RETURN VARCHAR2
IS
   return_ VARCHAR2(10);
   CURSOR get_reg_code_ IS
   SELECT reg_code
   FROM aircraft_tab
   WHERE alt_id = alt_id_;
BEGIN
   OPEN get_reg_code_;
   FETCH get_reg_code_ INTO return_;
   CLOSE get_reg_code_;
   
   RETURN return_;
END Get_Reg_Code_By_Alt;
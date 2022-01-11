-----------------------------------------------------------------------------
--
--  Logical unit: AvHistFault
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Component_Change_Id, Get_Fault_Id
--  200911  gdeslk  DISO2020R1-218, Added Get_Id_Version_By_Mx_Uniq_Key and Pre_Sync_Action to check availabiity of
--                                  record in AvHistFlight, AvInventory, UsgUsageSnapshotRec and HistWorkpackage
--  200925  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;
 
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Fault_Id(
   fault_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_fault_barcode IS
   SELECT fault_barcode
   FROM av_hist_fault_tab
   WHERE fault_alt_id = fault_alt_id_;
   
   fault_barcode_ av_hist_fault_tab.fault_barcode%TYPE;
BEGIN
   IF (fault_alt_id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_fault_barcode;
   FETCH get_fault_barcode INTO fault_barcode_;
   CLOSE get_fault_barcode;
   RETURN fault_barcode_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Fault_Id;

PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_fault_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify(
   newrec_         IN OUT NOCOPY av_hist_fault_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   fault_barcode_ IN VARCHAR2 ) RETURN av_hist_fault_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(fault_barcode_);
END Get_Object_By_Keys;


FUNCTION Get_Flight_Id_From_Alt_Id(
   fault_alt_id_ IN VARCHAR2)RETURN av_hist_fault_tab.flight_id%TYPE 
IS
   CURSOR get_flight_id IS
   SELECT flight_id 
   FROM av_hist_fault_tab
   WHERE fault_alt_id = fault_alt_id_;
   
   flight_id_ NUMBER;
BEGIN
   
   OPEN get_flight_id;
   FETCH get_flight_id INTO flight_id_;
   CLOSE get_flight_id;
   
   RETURN flight_id_;
END Get_Flight_Id_From_Alt_Id;


FUNCTION Get_Fault_Name_From_Alt_Id(
   fault_alt_id_ VARCHAR2) RETURN av_hist_fault_tab.fault_name%TYPE
IS
   CURSOR get_fault_name IS
   SELECT fault_name 
   FROM av_hist_fault_tab
   WHERE fault_alt_id = fault_alt_id_;
   
   fault_name_ av_hist_fault_tab.fault_name%TYPE;
BEGIN
   OPEN get_fault_name;
   FETCH get_fault_name INTO fault_name_;
   CLOSE get_fault_name;
   
   RETURN fault_name_;
   
END Get_Fault_Name_From_Alt_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_hist_fault_tab
      WHERE fault_barcode = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                          VARCHAR2(4000);
   av_hist_flight_unique_key_           av_hist_flight_tab.flight_leg_alt_id%TYPE;
   flight_id_                           av_hist_fault.flight_id%TYPE;
   inventory_id_                        av_hist_fault.inventory_id%TYPE;
   wp_barcode_                          av_hist_work_package_tab.wp_barcode%TYPE;
   wp_mx_unique_key_                    av_hist_work_package_tab.mx_unique_key%TYPE;
   inv_serial_no_oem_                   av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                         av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_                     av_inventory_tab.manufacture_code%TYPE;
   barcode_                             av_inventory_tab.barcode%TYPE;
   
   CURSOR get_hist_flight_id IS
      SELECT flight_id
      FROM   av_hist_flight_tab
      WHERE  flight_leg_alt_id = av_hist_flight_unique_key_;
      
   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = barcode_;  
      
   CURSOR check_wp_barcode_ref_exists IS 
      SELECT mx_unique_key
      FROM av_hist_work_package_tab
      WHERE wp_barcode = wp_mx_unique_key_;   
      
BEGIN
   local_attr_ := attr_;
   
   -- If the record already exists, remove Fault_Barcode from attribute string since it's not updatable
   IF Check_Exist___(Client_SYS.Get_Item_Value('FAULT_BARCODE', local_attr_)) THEN
      local_attr_:= Client_SYS.Remove_Attr('FAULT_BARCODE',  local_attr_);
   END IF;
   
   -- Fetching flight_id from av_hist_flight_tab
   IF Client_SYS.Item_Exist('FLIGHT_UNIQUE_KEY', local_attr_) THEN
      av_hist_flight_unique_key_ := Client_SYS.Get_Item_Value('FLIGHT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_hist_flight_id;
      FETCH get_hist_flight_id INTO flight_id_;
      CLOSE get_hist_flight_id;
      
      Client_SYS.Add_To_Attr('FLIGHT_ID', flight_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FLIGHT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   -- Fetching inventory_id from av_inventory_tab
   IF Client_SYS.Item_Exist('PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NO_OEM', attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', attr_);
      barcode_           := Client_SYS.Get_Item_Value('BARCODE', attr_);      
      
      --Fetching inventory_id
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;
      
      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated Inventory:P1', barcode_);
      END IF;
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('BARCODE',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('WP_BARCODE', attr_) THEN
      wp_mx_unique_key_:= Client_SYS.Get_Item_Value('WP_BARCODE', local_attr_);
      --checks whether wp_barcode exists in the av_hist_work_package_tab.
      OPEN  check_wp_barcode_ref_exists;
      FETCH check_wp_barcode_ref_exists INTO wp_barcode_;
      CLOSE check_wp_barcode_ref_exists;
      
      IF wp_mx_unique_key_ IS NOT NULL AND wp_barcode_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'WORKPACKAGESYNCERR: Could not find the indicated Work Package record :P1', wp_barcode_);
      END IF;
   END IF; 

   attr_ := local_attr_;
END Pre_Sync_Action;

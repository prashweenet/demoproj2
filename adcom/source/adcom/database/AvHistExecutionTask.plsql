-----------------------------------------------------------------------------
--
--  Logical unit: AvHistExecutionTask
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201122  chdslk  AD2020R1-1086, Added get_inst_rmvl_inv_record_id to get the inventory of installed or removed inv.
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Task_Id
--  201006  kapalk  DISCO2020R1-396 , Added pre sync action
-----------------------------------------------------------------------------

layer Core;
  
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Id(
   task_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_et_barcode IS
   SELECT et_barcode
   FROM av_hist_execution_task_tab
   WHERE task_alt_id = task_alt_id_;
  
   et_barcode_ av_hist_execution_task_tab.et_barcode%TYPE;
BEGIN
   IF (task_alt_id_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_et_barcode;
   FETCH get_et_barcode INTO et_barcode_;
   CLOSE get_et_barcode;
   RETURN et_barcode_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Id;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_execution_task_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_execution_task_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   et_barcode_ IN VARCHAR2 ) RETURN av_hist_execution_task_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(et_barcode_);
END Get_Object_By_Keys;


FUNCTION Get_Inventory_Id_From_Alt_Id(
   inventory_alt_id_ IN VARCHAR2 ) RETURN av_inventory_tab.inventory_id%type
IS
   CURSOR get_inv_id IS
   SELECT inventory_id 
   FROM av_inventory_tab 
   WHERE inventory_alt_id = inventory_alt_id_;
   
   inventory_id_ av_inventory_tab.inventory_id%type;
   
BEGIN
   
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
  
   RETURN inventory_id_;
   
END Get_Inventory_Id_From_Alt_Id;

FUNCTION Get_Fault_Barcode_From_Alt_Id(
   fault_alt_id_ IN VARCHAR2 ) RETURN av_hist_fault_tab.fault_barcode%type
IS
   CURSOR get_fault_barcode IS
   SELECT fault_barcode 
   FROM av_hist_fault_tab 
   WHERE fault_alt_id = fault_alt_id_;
   
   fault_barcode_ av_hist_fault_tab.fault_barcode%type;
   
BEGIN
   
   OPEN get_fault_barcode;
   FETCH get_fault_barcode INTO fault_barcode_;
   CLOSE get_fault_barcode;
  
   RETURN fault_barcode_;
   
END Get_Fault_Barcode_From_Alt_Id;

FUNCTION Get_Wp_Barcode_From_Alt_Id(
   workpackage_alt_id_ IN VARCHAR2 ) RETURN av_hist_work_package_tab.wp_barcode%type
IS
   CURSOR get_wpbarcode IS
   SELECT wp_barcode 
   FROM av_hist_work_package_tab 
   WHERE work_package_alt_id = workpackage_alt_id_;
   
   wp_barcode_ av_hist_work_package_tab.wp_barcode%type;
   
BEGIN
   
   OPEN get_wpbarcode;
   FETCH get_wpbarcode INTO wp_barcode_;
   CLOSE get_wpbarcode;
  
   RETURN wp_barcode_;
   
END Get_Wp_Barcode_From_Alt_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM av_hist_execution_task_tab
   WHERE et_barcode = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                     VARCHAR2(4000);
   inventory_id_                   av_inventory_tab.inventory_id%TYPE;
   parent_inv_id_                  av_inventory_tab.inventory_id%TYPE;
   wp_barcode_                     av_hist_work_package_tab.wp_barcode%TYPE;
   wp_mx_unique_key_               av_hist_work_package_tab.mx_unique_key%TYPE;
   et_barcode_attr_                av_hist_execution_task_tab.et_barcode%TYPE;
   et_barcode_                     av_hist_execution_task_tab.et_barcode%TYPE;
   inv_serial_no_oem_              av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                    av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_                av_inventory_tab.manufacture_code%TYPE;
   barcode_                        av_inventory_tab.barcode%TYPE;
     
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
      
   CURSOR get_existing_record IS
      SELECT et_barcode
      FROM av_hist_execution_task_tab
      WHERE et_barcode = et_barcode_attr_;
BEGIN
   local_attr_ := attr_;
   IF Client_SYS.Item_Exist('PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', local_attr_);
      barcode_           := Client_SYS.Get_Item_Value('BARCODE', local_attr_);      
      
      --Fetching inventory_id
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;

      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated Inventory :P1', barcode_);
      ELSE 
         Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);
      END IF;
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('BARCODE',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PARENT_PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('PARENT_INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PARENT_PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('PARENT_MANUFACTURE_CODE', local_attr_);
      barcode_           := Client_SYS.Get_Item_Value('PARENT_BARCODE', local_attr_);          
      --selects parent inventory id 
      OPEN get_inventory;
      FETCH get_inventory INTO parent_inv_id_;
      CLOSE get_inventory;

      IF parent_inv_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARENTINVENTORYSYNCERR: Could not find the indicated Inventory :P1', barcode_);
      ELSE 
         Client_SYS.Add_To_Attr('PARENT_INVENTORY_ID', parent_inv_id_, local_attr_);
      END IF;
      local_attr_:= Client_SYS.Remove_Attr('PARENT_BARCODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PARENT_INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PARENT_PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PARENT_MANUFACTURE_CODE',  local_attr_);
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
   
   IF Client_SYS.Item_Exist('ET_BARCODE', attr_) THEN
      et_barcode_attr_ := Client_SYS.Get_Item_Value('ET_BARCODE', local_attr_);
      --check whether the planning task already exists.
      OPEN  get_existing_record;
      FETCH get_existing_record INTO et_barcode_;
      CLOSE get_existing_record;
      
      IF et_barcode_attr_ IS NOT NULL AND et_barcode_ IS NOT NULL THEN
         local_attr_ := Client_SYS.Remove_Attr('ET_BARCODE', local_attr_); 
      END IF;
   END IF;  
    
   attr_ := local_attr_;
END Pre_Sync_Action;

-----------------------------------------------------------------------------
--
--  Logical unit: AvHistPlanningTask
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201122  chdslk  AD2020R1-1086, Added get_inst_rmvl_inv_record_id to get the inventory of installed or removed inv.
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Component_Change_Id, Get_Task_Planning_Id
--  200923  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Planning_Id(
   task_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_pt_barcode IS
   SELECT pt_barcode
   FROM av_hist_planning_task_tab
   WHERE task_alt_id = task_alt_id_;
  
   pt_barcode_ av_hist_planning_task_tab.pt_barcode%TYPE;
BEGIN
   IF (task_alt_id_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_pt_barcode;
   FETCH get_pt_barcode INTO pt_barcode_;
   CLOSE get_pt_barcode;
   RETURN pt_barcode_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Planning_Id;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_planning_task_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_planning_task_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   pt_barcode_ IN VARCHAR2 ) RETURN av_hist_planning_task_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(pt_barcode_);
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


FUNCTION Get_Task_Code_From_Alt_Id(
    task_alt_id_ IN VARCHAR2) RETURN VARCHAR2 
IS
   CURSOR get_task_code IS
   SELECT task_code
   FROM av_hist_planning_task_tab
   WHERE task_alt_id = task_alt_id_;
  
   task_code_ av_hist_planning_task_tab.task_code%TYPE;
BEGIN
   IF (task_alt_id_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_task_code;
   FETCH get_task_code INTO task_code_;
   CLOSE get_task_code;
   RETURN task_code_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Code_From_Alt_Id;

FUNCTION Get_Ptbarcode_From_Alt_Id(
   alt_id_ IN VARCHAR2) RETURN av_hist_planning_task_tab.pt_barcode%TYPE
IS
   CURSOR get_pt_barcode IS
   SELECT pt_barcode 
   FROM av_hist_planning_task_tab
   WHERE task_alt_id = alt_id_;
   
   pt_barcode_ av_hist_planning_task_tab.pt_barcode%TYPE;
BEGIN
   OPEN get_pt_barcode;
   FETCH get_pt_barcode INTO pt_barcode_;
   CLOSE get_pt_barcode;
   
   RETURN pt_barcode_;
   
END Get_Ptbarcode_From_Alt_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM av_hist_planning_task_tab
   WHERE pt_barcode = mx_unique_key_;
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
   pt_barcode_attr_                av_hist_planning_task_tab.pt_barcode%TYPE;
   pt_barcode_                     av_hist_planning_task_tab.pt_barcode%TYPE;
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
      
   CURSOR get_parent_inventory IS
      SELECT inventory_id
      FROM av_inventory_tab
      WHERE INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = barcode_;  
   
   CURSOR check_wp_barcode_ref_exists IS 
      SELECT mx_unique_key
      FROM av_hist_work_package_tab
      WHERE wp_barcode = wp_mx_unique_key_;
      
   CURSOR get_existing_record IS
      SELECT pt_barcode
      FROM av_hist_planning_task_tab
      WHERE pt_barcode = pt_barcode_attr_;
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
      OPEN get_parent_inventory;
      FETCH get_parent_inventory INTO parent_inv_id_;
      CLOSE get_parent_inventory;
      
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
   
   IF Client_SYS.Item_Exist('PT_BARCODE', attr_) THEN
      pt_barcode_attr_ := Client_SYS.Get_Item_Value('PT_BARCODE', local_attr_);
      --check whether the planning task already exists.
      OPEN  get_existing_record;
      FETCH get_existing_record INTO pt_barcode_;
      CLOSE get_existing_record;
      
      IF pt_barcode_attr_ IS NOT NULL AND pt_barcode_ IS NOT NULL THEN
         local_attr_ := Client_SYS.Remove_Attr('PT_BARCODE', local_attr_); 
      END IF;
   END IF;  
    
   local_attr_ := Client_SYS.Remove_Attr('INV_MX_UNIQUE_KEY',  local_attr_); 
   local_attr_ := Client_SYS.Remove_Attr('PARENT_INV_MX_UNIQUE_KEY',  local_attr_);
   attr_ := local_attr_;
END Pre_Sync_Action;

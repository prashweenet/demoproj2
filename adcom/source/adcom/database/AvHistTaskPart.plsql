-----------------------------------------------------------------------------
--
--  Logical unit: AvHistTaskPart
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210205  chdslk  DISO2020R1-516, Added Get_Inventory_Id_From_Alt_Id and included installed and inventory id check in Pre_Sync_Action method.
--  201109  themlk  AD2020R1-1066, Removed Remove and added Modify
--  200915  themlk  DISCOP2020R1-123, New, Remove, Get_Objects_By_Keys, Get_Task_Part_Id
--  200924  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
--  201007  baablk  DISO2020R1-413, Added Check_Insert___, Get_Id_Version_By_Mx_Uniq_Key, Pre_Sync_Action methods

-----------------------------------------------------------------------------

layer Core;
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_task_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS

   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_task_part_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.task_part_id IS NULL) THEN
      newrec_.task_part_id := key_id_;
   END IF;   
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('TASK_PART_ID', key_id_, attr_);
   
END Check_Insert___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_task_part_tab
   WHERE  mx_unique_key  = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                     VARCHAR2(4000);
   execution_task_unique_key_      VARCHAR2(80);
   et_barcode_                     av_hist_execution_task_tab.et_barcode%TYPE;
   installed_inv_id_mx_unique_key_ av_inventory_tab.mx_unique_key%TYPE;
   installed_inv_id_               av_inventory_tab.inventory_id%TYPE;
   removed_inv_id_mx_unique_key_   av_inventory_tab.mx_unique_key%TYPE;
   removed_inv_id_                 av_inventory_tab.inventory_id%TYPE;
   inv_serial_no_oem_              av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                    av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_                av_inventory_tab.manufacture_code%TYPE;
   barcode_                        av_inventory_tab.barcode%TYPE;
   
   CURSOR check_barcode_ref_ IS 
   SELECT et_barcode 
   FROM av_hist_execution_task_tab
   WHERE et_barcode = execution_task_unique_key_;
   
   CURSOR get_installed_inv_record_id IS
     SELECT inventory_id
     FROM   av_inventory_tab
     WHERE  inventory_serial_no_oem = inv_serial_no_oem_ AND 
      part_no_oem = part_no_oem_ AND 
      manufacture_code = manufacturer_cd_ AND 
      barcode = barcode_; 
     
   CURSOR get_removed_inv_record_id IS
     SELECT inventory_id
     FROM   av_inventory_tab
     WHERE  inventory_serial_no_oem = inv_serial_no_oem_ AND 
      part_no_oem = part_no_oem_ AND 
      manufacture_code = manufacturer_cd_ AND 
      barcode = barcode_; 
   
BEGIN
   local_attr_ := attr_;
   IF Client_SYS.Item_Exist('ET_BARCODE', local_attr_) THEN
      execution_task_unique_key_ := Client_SYS.Get_Item_Value('ET_BARCODE', local_attr_);
      
      OPEN check_barcode_ref_;
      FETCH check_barcode_ref_ INTO et_barcode_;
      CLOSE check_barcode_ref_;
      
      IF execution_task_unique_key_ IS NOT NULL AND et_barcode_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSTEPSYNCERR: Could not find the indicated Execution task :P1', et_barcode_);
      END IF;
   END IF;
   
   IF Client_SYS.Item_Exist('INST_PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INST_INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('INST_PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('INST_MANUFACTURE_CODE', local_attr_);
      barcode_           := Client_SYS.Get_Item_Value('INST_BARCODE', local_attr_);
      --selects inventory id using mx unique key 
      OPEN  get_installed_inv_record_id;
      FETCH get_installed_inv_record_id INTO installed_inv_id_;
      CLOSE get_installed_inv_record_id;
      
      IF installed_inv_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INSTINVENTORYSYNCERR: Could not find the indicated Inventory :P1', barcode_);
      ELSE 
         Client_SYS.Add_To_Attr('INSTALLED_INVENTORY_ID', installed_inv_id_, local_attr_);
      END IF;
      attr_:= Client_SYS.Remove_Attr('INST_INVENTORY_SERIAL_NO_OEM',  local_attr_);
      attr_:= Client_SYS.Remove_Attr('INST_PART_NO_OEM',  local_attr_);
      attr_:= Client_SYS.Remove_Attr('INST_MANUFACTURE_CODE',  local_attr_);
      attr_:= Client_SYS.Remove_Attr('INST_BARCODE',  local_attr_);
   END IF;
   
  IF Client_SYS.Item_Exist('RMVD_PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('RMVD_INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('RMVD_PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('RMVD_MANUFACTURE_CODE', local_attr_);
      barcode_           := Client_SYS.Get_Item_Value('RMVD_BARCODE', local_attr_);
    
      --selects inventory id using mx unique key 
      OPEN  get_removed_inv_record_id;
      FETCH get_removed_inv_record_id INTO removed_inv_id_;
      CLOSE get_removed_inv_record_id;
      
      IF removed_inv_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'RMVDINVENTORYSYNCERR: Could not find the indicated Inventory :P1', barcode_);
      ELSE 
         Client_SYS.Add_To_Attr('REMOVED_INVENTORY_ID', removed_inv_id_, local_attr_);
      END IF;
   END IF;
   
   local_attr_:= Client_SYS.Remove_Attr('RMVD_INVENTORY_SERIAL_NO_OEM',  local_attr_);
   local_attr_:= Client_SYS.Remove_Attr('RMVD_PART_NO_OEM',  local_attr_);
   local_attr_:= Client_SYS.Remove_Attr('RMVD_MANUFACTURE_CODE',  local_attr_);
   local_attr_:= Client_SYS.Remove_Attr('RMVD_BARCODE',  local_attr_);
   attr_ := local_attr_;
   
END Pre_Sync_Action;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_task_part_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_task_part_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   task_part_id_ IN NUMBER ) RETURN av_hist_task_part_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(task_part_id_);
END Get_Object_By_Keys;

FUNCTION Get_Task_Part_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_task_part_id IS
   SELECT task_part_id
   FROM av_hist_task_part_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   task_part_id_ av_hist_task_part_tab.task_part_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_task_part_id;
   FETCH get_task_part_id INTO task_part_id_;
   CLOSE get_task_part_id;
   RETURN task_part_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Part_Id;

FUNCTION Mig_Get_Task_Part_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_task_part_id IS
   SELECT task_part_id
   FROM av_hist_task_part_tab
   WHERE mx_unique_key = mx_unique_key_ ;
  
   task_part_id_ NUMBER;
BEGIN
   
   OPEN get_task_part_id;
   FETCH get_task_part_id INTO task_part_id_ ;
   CLOSE get_task_part_id;
   
   IF task_part_id_ IS NULL THEN
      task_part_id_:= av_hist_task_part_seq.nextval;    
   END IF;
   
   RETURN task_part_id_;
   
END Mig_Get_Task_Part_Id;


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

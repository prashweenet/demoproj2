-----------------------------------------------------------------------------
--
--  Logical unit: AvHistComponentChange
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Component_Change_Id
--  200909  kapalk   created presync action for evt_event table in MXI trigger
--  200925  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
--  ------  ------  ---------------------------------------------------------

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Override 
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_component_change_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_ NUMBER;
   
   CURSOR get_key_cursor IS
   SELECT av_hist_comp_chg_seq.NEXTVAL
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO key_;
   CLOSE get_key_cursor;
   
   IF(newrec_.compoenent_change_id IS NULL) THEN
      newrec_.compoenent_change_id := key_;
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('COMPOENENT_CHANGE_ID', key_, attr_);
END Check_Insert___;


PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_component_change_tab
   WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                     VARCHAR2(4000);
   inventory_id_                   av_inventory_tab.inventory_id%TYPE;
   inventory_serial_no_            av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_                        av_inventory_tab.part_no_oem%TYPE;
   et_barcode_                     av_hist_execution_task_tab.et_barcode%TYPE;
   is_task_exist_                  NUMBER;
   parent_assmbl_                  VARCHAR2(400);
   event_status_code_              VARCHAR2(16);
   newrec_                         av_hist_component_change_tab%ROWTYPE;
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
      SELECT inventory_id,inventory_serial_no_oem,part_no_oem
      FROM   av_inventory_tab
      WHERE  INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = barcode_;  
            
   CURSOR get_task_details IS
      SELECT count(*)
      FROM av_hist_execution_task
      WHERE et_barcode = et_barcode_;
      
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
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated inventory:P1', barcode_);
      END IF;
    
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('BARCODE',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('HIGHEST_PART_NO_OEM', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('HIGHEST_INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('HIGHEST_PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('HIGHEST_MANUFACTURE_CODE', local_attr_);
      barcode_           := Client_SYS.Get_Item_Value('HIGHEST_BARCODE', local_attr_);      
    
      OPEN  get_parent_inventory;
      FETCH get_parent_inventory INTO inventory_id_,inventory_serial_no_,part_no_;
      CLOSE get_parent_inventory;

      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARENTINVENTORYSYNCERR: Could not find the indicated parent inventory:P1', barcode_);
      END IF;
    
      Client_SYS.Add_To_Attr('PARENT_ASSM_INVENTORY_ID', inventory_id_, local_attr_);
      
      IF part_no_ IS NOT NULL AND inventory_serial_no_ IS NOT NULL THEN
         parent_assmbl_ := TO_CHAR(part_no_)||':'||TO_CHAR(inventory_serial_no_);
         Client_SYS.Add_To_Attr('PARENT_ASSEMBLY',parent_assmbl_ , local_attr_);
      END IF;
      
      Client_SYS.Add_To_Attr('PARENT_INVENTORY_ID', inventory_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('HIGHEST_BARCODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('HIGHEST_INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('HIGHEST_PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('HIGHEST_MANUFACTURE_CODE',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('ET_BARCODE', local_attr_) THEN
      et_barcode_:= Client_SYS.Get_Item_Value('ET_BARCODE', local_attr_);
      
      OPEN get_task_details;
      FETCH get_task_details INTO is_task_exist_;
      CLOSE get_task_details;
      
      IF et_barcode_ IS NOT NULL AND is_task_exist_ < 1 THEN 
         Error_SYS.Appl_General(lu_name_, 'EXETASKSYNCERR: Could not find the indicated et ETBARCODE:P1',et_barcode_ );
      END IF;
      
   END IF;
   
   IF Client_SYS.Item_Exist('EVENT_STATUS_CD', local_attr_) THEN
      event_status_code_:= Client_SYS.Get_Item_Value('EVENT_STATUS_CD', local_attr_);
      IF event_status_code_ = 'FGINST' THEN 
         newrec_.event_type := Event_Type_API.Encode(Event_Type_API.Get_Client_Value(0));
         Client_SYS.Add_To_Attr('EVENT_TYPE',Event_Type_API.Decode(newrec_.event_type), local_attr_);
      ELSIF event_status_code_ = 'FGRMVL' THEN 
         newrec_.event_type := Event_Type_API.Encode(Event_Type_API.Get_Client_Value(1));
         Client_SYS.Add_To_Attr('EVENT_TYPE',Event_Type_API.Decode(newrec_.event_type), local_attr_);
      ELSE 
         Client_SYS.Add_To_Attr('EVENT_TYPE','', local_attr_);
      END IF;
   END IF;
   
   local_attr_:= Client_SYS.Remove_Attr('EVENT_STATUS_CD',  local_attr_);
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_component_change_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_component_change_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   compoenent_change_id_ IN NUMBER ) RETURN av_hist_component_change_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(compoenent_change_id_);
END Get_Object_By_Keys;

FUNCTION Get_Component_Change_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_component_cahnge_id IS
   SELECT compoenent_change_id
   FROM av_hist_component_change_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   component_change_id_ av_hist_component_change_tab.compoenent_change_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_component_cahnge_id;
   FETCH get_component_cahnge_id INTO component_change_id_;
   CLOSE get_component_cahnge_id;
   RETURN component_change_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Component_Change_Id;

FUNCTION  Get_Parent_Assembly(
   parent_unique_key_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_parent_inv_rec IS
      SELECT inventory_serial_no_oem,part_no_oem
      FROM av_inventory_tab
      WHERE mx_unique_key = parent_unique_key_;
      
   inventory_serial_no_oem_    av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                av_inventory_tab.part_no_oem%TYPE;
   parent_assembly_ VARCHAR2(400);
BEGIN
   OPEN get_parent_inv_rec;
   FETCH get_parent_inv_rec INTO inventory_serial_no_oem_, part_no_oem_;
   CLOSE get_parent_inv_rec;
   
   IF inventory_serial_no_oem_ IS NOT NULL AND part_no_oem_ IS NOT NULL THEN
      parent_assembly_ := TO_CHAR(part_no_oem_)||':'||TO_CHAR(inventory_serial_no_oem_);
   END IF;
    RETURN parent_assembly_;
END Get_Parent_Assembly;

FUNCTION Get_Inventory_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_inv_id IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  mx_unique_key = mx_unique_key_;
      
      inv_id_ NUMBER;
BEGIN
   OPEN get_inv_id;
   FETCH get_inv_id INTO inv_id_;
   CLOSE get_inv_id;
   
   RETURN inv_id_;
   
END Get_Inventory_Id;

FUNCTION Get_Event_Type(
   event_status_code_ IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
     
      IF event_status_code_ = 'FGINST' THEN 
         RETURN  Event_Type_API.Encode(Event_Type_API.Get_Client_Value(0));
      ELSIF event_status_code_ = 'FGRMVL' THEN 
        RETURN Event_Type_API.Encode(Event_Type_API.Get_Client_Value(1));
      ELSE 
         RETURN NULL;
      END IF;      
   
END Get_Event_Type;

FUNCTION Mig_Get_Component_Change_Id(
   mx_unique_key_        IN VARCHAR2
   ) RETURN NUMBER
IS
   CURSOR get_component_c_id IS
   SELECT compoenent_change_id FROM av_hist_component_change_tab 
   WHERE mx_unique_key = mx_unique_key_;
   
   compoenent_change_id_ NUMBER;
BEGIN
   OPEN get_component_c_id;
   FETCH get_component_c_id INTO compoenent_change_id_;
   CLOSE get_component_c_id;
   
   IF compoenent_change_id_ IS NULL THEN
      compoenent_change_id_ := av_hist_comp_chg_seq.nextval;
   END IF;
RETURN compoenent_change_id_;   
END Mig_Get_Component_Change_Id;
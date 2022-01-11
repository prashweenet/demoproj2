-----------------------------------------------------------------------------
--
--  Logical unit: AvHistUsgSnapshot
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------
PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                     VARCHAR2(4000);
   inventory_id_                   av_inventory_tab.inventory_id%TYPE;
   inv_serial_no_oem_              av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                    av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_                av_inventory_tab.manufacture_code%TYPE;
   inv_barcode_                    av_inventory_tab.barcode%TYPE;
   record_type_                    VARCHAR2(10);
   barcode_                        VARCHAR2(80);
   component_change_unique_key_    av_hist_component_change.mx_unique_key%TYPE;
   compoenent_change_id_           av_hist_component_change.compoenent_change_id%TYPE;
   
   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  inventory_serial_no_oem = inv_serial_no_oem_ AND 
      part_no_oem = part_no_oem_ AND 
      manufacture_code = manufacturer_cd_ AND 
      barcode = inv_barcode_;  
   
   CURSOR get_component_change_id IS
      SELECT compoenent_change_id FROM av_hist_component_change_tab
      WHERE mx_unique_key = component_change_unique_key_;
   
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('PART_NO_OEM', local_attr_) AND Client_SYS.Item_Exist('INVENTORY_SERIAL_NO_OEM', local_attr_) AND Client_SYS.Item_Exist('MANUFACTURE_CODE', local_attr_) AND Client_SYS.Item_Exist('INVENTORY_BARCODE', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', local_attr_);
      inv_barcode_       := Client_SYS.Get_Item_Value('INVENTORY_BARCODE', local_attr_);              
      
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;
      
      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated inventory:P1 ', inv_barcode_);
      END IF;
      
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_BARCODE',  local_attr_);
   END IF;
   
   --get the barcode 
   barcode_ := Client_SYS.Get_Item_Value('BARCODE', local_attr_); 
   --Get record type (Work Package/ Task/ Fault) 
   IF Client_SYS.Item_Exist('RECORD_TYPE', local_attr_) THEN
      record_type_ := Client_SYS.Get_Item_Value('RECORD_TYPE', local_attr_);
   END IF;
   
   IF (record_type_ = 'WKPKG') THEN --Work Package
      Client_SYS.Add_To_Attr('WP_BARCODE', barcode_, local_attr_);
   ELSIF (record_type_ = 'PTNET') THEN --Planning Task & Execution Task
      Client_SYS.Add_To_Attr('PT_BARCODE', barcode_, local_attr_);
      Client_SYS.Add_To_Attr('ET_BARCODE', barcode_, local_attr_);
   ELSIF (record_type_ = 'EXETK') THEN --Execution Task
      Client_SYS.Add_To_Attr('ET_BARCODE', barcode_, local_attr_);
   ELSIF (record_type_ = 'PLNTK') THEN --Planning Task
      Client_SYS.Add_To_Attr('PT_BARCODE', barcode_, local_attr_);
   ELSIF (record_type_ = 'FAULT') THEN --Fault
      Client_SYS.Add_To_Attr('FAULT_BARCODE', barcode_, local_attr_);
   ELSIF (record_type_ = 'CMPCG') THEN --Component Changes
      
      IF Client_SYS.Item_Exist('COMP_UNIQUE_KEY', local_attr_) THEN
         component_change_unique_key_ := Client_SYS.Get_Item_Value('COMP_UNIQUE_KEY', local_attr_);
      END IF;

      OPEN get_component_change_id;
      FETCH get_component_change_id INTO compoenent_change_id_;
      CLOSE get_component_change_id;

      Client_SYS.Add_To_Attr('COMPOENENT_CHANGE_ID', compoenent_change_id_, local_attr_);
      
   END IF;
   local_attr_:= Client_SYS.Remove_Attr('BARCODE',  local_attr_);
   local_attr_:= Client_SYS.Remove_Attr('COMP_UNIQUE_KEY',  local_attr_);
   
    attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_usg_snapshot_tab
   WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_usg_snapshot_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_usg_snapshot_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;
   
   IF(newrec_.usage_snapshot_id IS NULL) THEN
      newrec_.usage_snapshot_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('USAGE_SNAPSHOT_ID', key_id_, attr_);
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_usg_snapshot_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_usg_snapshot_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   usage_snapshot_id_ IN NUMBER ) RETURN av_hist_usg_snapshot_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(usage_snapshot_id_);
END Get_Object_By_Keys;

FUNCTION Get_Snapshot_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER 
IS
   CURSOR get_snapshot_id IS
   SELECT usage_snapshot_id
   FROM av_hist_usg_snapshot_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   usage_snapshot_id_ NUMBER;
BEGIN
   OPEN get_snapshot_id;
   FETCH get_snapshot_id INTO usage_snapshot_id_;
   CLOSE get_snapshot_id;
   
   RETURN usage_snapshot_id_;
END Get_Snapshot_Id;

FUNCTION Get_Snapshot_Record_Id(
   inventory_id_          IN VARCHAR2,
   component_change_id_   IN VARCHAR2) RETURN NUMBER
IS
   snapshot_rec_id_ av_hist_usg_snapshot_tab.usage_snapshot_id%TYPE;
   CURSOR get_snapshot_rec IS
   SELECT usage_snapshot_id
   FROM av_hist_usg_snapshot_tab
   WHERE compoenent_change_id = component_change_id_ AND inventory_id = inventory_id_;
BEGIN
   OPEN get_snapshot_rec;
   FETCH get_snapshot_rec INTO snapshot_rec_id_;
   CLOSE get_snapshot_rec;
   
   RETURN snapshot_rec_id_;
END Get_Snapshot_Record_Id;

FUNCTION Get_Inventory_Id_From_Unq_Ky(
   inventory_unique_key_ IN VARCHAR2) RETURN NUMBER 
IS
   CURSOR get_inv_id IS
   SELECT inventory_id 
   FROM av_inventory_tab 
   WHERE mx_unique_key = inventory_unique_key_;
   
   inventory_id_ NUMBER;
   
BEGIN
   
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
   
   RETURN inventory_id_;
   
END Get_Inventory_Id_From_Unq_Ky;

FUNCTION Mig_Get_Snapshot_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER 
IS
   CURSOR get_snapshot_id IS
   SELECT usage_snapshot_id
   FROM av_hist_usg_snapshot_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   usage_snapshot_id_ NUMBER;
BEGIN
   OPEN get_snapshot_id;
   FETCH get_snapshot_id INTO usage_snapshot_id_;
   CLOSE get_snapshot_id;
   
   IF usage_snapshot_id_ IS NULL THEN
      usage_snapshot_id_ := av_hist_usg_snapshot_seq.nextval;
   END IF;
   
   RETURN usage_snapshot_id_;
END Mig_Get_Snapshot_Id;
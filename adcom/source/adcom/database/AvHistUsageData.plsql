-----------------------------------------------------------------------------
--
--  Logical unit: AvHistUsageData
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Usage_Data_Id
--  200827  kapalk  Pre Sync Action
--  200918  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_usage_data_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_ NUMBER;
   
   CURSOR get_key_cursor IS
   SELECT av_hist_usage_data_seq.NEXTVAL
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO key_;
   CLOSE get_key_cursor;
   
   IF(newrec_.usage_data_id IS NULL) THEN
      newrec_.usage_data_id:= key_;
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('USAGE_DATA_ID', key_, attr_);
END Check_Insert___;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_usage_data_tab
   WHERE  mx_unique_key  = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                      VARCHAR2(4000);   
   inventory_id_                    av_inventory_tab.inventory_id%TYPE;
   usage_record_unique_id_          av_hist_usage_record_tab.usage_record_alt_id%TYPE;
   inv_serial_no_oem_               av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_                     av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_                 av_inventory_tab.manufacture_code%TYPE;
   inv_barcode_                     av_inventory_tab.barcode%TYPE;
   
   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = inv_barcode_;  
   
BEGIN    
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('PART_NO_OEM', local_attr_) AND Client_SYS.Item_Exist('INVENTORY_SERIAL_NO_OEM', local_attr_) AND Client_SYS.Item_Exist('MANUFACTURE_CODE', local_attr_) AND Client_SYS.Item_Exist('BARCODE', local_attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', local_attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NO_OEM', local_attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', local_attr_);
      inv_barcode_       := Client_SYS.Get_Item_Value('BARCODE', local_attr_);              
      
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;
      
      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated inventory:P1', inv_barcode_);
      END IF;
      
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, local_attr_);   
      local_attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('BARCODE',  local_attr_);
      
   END IF; 
   
   IF Client_SYS.Item_Exist('USAGE_RECORD_UNIQUE_ID', local_attr_) THEN
      usage_record_unique_id_ := Client_SYS.Get_Item_Value('USAGE_RECORD_UNIQUE_ID', local_attr_); 
      Client_SYS.Add_To_Attr('USAGE_RECORD_ALT_ID', usage_record_unique_id_, local_attr_);
   END IF;
   
   local_attr_ := Client_SYS.Remove_Attr('USAGE_RECORD_UNIQUE_ID', local_attr_);  
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_usage_data_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify(
   newrec_         IN OUT NOCOPY av_hist_usage_data_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   usage_data_id_ IN NUMBER ) RETURN av_hist_usage_data_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(usage_data_id_);
END Get_Object_By_Keys;

FUNCTION Get_Usage_Data_Id(
   usage_data_alt_id_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_usage_data_id IS
   SELECT usage_data_id
   FROM av_hist_usage_data_tab
   WHERE usage_data_alt_id = usage_data_alt_id_;
   
   usage_data_id_ av_hist_usage_data_tab.usage_data_id%TYPE;
BEGIN
   IF (usage_data_alt_id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_usage_data_id;
   FETCH get_usage_data_id INTO usage_data_id_;
   CLOSE get_usage_data_id;
   RETURN usage_data_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Usage_Data_Id;


FUNCTION Mig_Get_Usage_Data_Id(
   usage_data_alt_id_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_usage_data_id IS
   SELECT usage_data_id
   FROM av_hist_usage_data_tab
   WHERE usage_data_alt_id = usage_data_alt_id_;
   
   usage_data_id_ av_hist_usage_data_tab.usage_data_id%TYPE;
   
BEGIN
   OPEN get_usage_data_id;
   FETCH get_usage_data_id INTO usage_data_id_;
   CLOSE get_usage_data_id;
   
   
   IF usage_data_id_ IS NULL THEN 
      usage_data_id_ := av_hist_usage_data_seq.nextval;
   END IF;
   
   RETURN usage_data_id_;
END Mig_Get_Usage_Data_Id;

FUNCTION Get_Inventory_Id(
   inventory_alt_id_ IN VARCHAR2 ) RETURN av_inventory_tab.inventory_id%TYPE
IS
   CURSOR get_inv_id IS
   SELECT inventory_id 
   FROM av_inventory_tab 
   WHERE inventory_alt_id = inventory_alt_id_;
   
   inventory_id_ av_inventory_tab.inventory_id%TYPE;
   
BEGIN
   
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
   
   RETURN inventory_id_;
   
END Get_Inventory_Id;

FUNCTION Get_Usage_Record_Id(
   usage_record_alt_id_ IN VARCHAR2 ) RETURN av_hist_usage_record_tab.usage_record_id%TYPE
IS
   CURSOR get_usage_rec_id IS
   SELECT usage_record_id 
   FROM av_hist_usage_record_tab 
   WHERE usage_record_alt_id = usage_record_alt_id_;
   
   usage_record_id_ av_hist_usage_record_tab.usage_record_id%TYPE;
   
BEGIN
   
   OPEN get_usage_rec_id;
   FETCH get_usage_rec_id INTO usage_record_id_;
   CLOSE get_usage_rec_id;
   
   RETURN usage_record_id_;
END Get_Usage_Record_Id;


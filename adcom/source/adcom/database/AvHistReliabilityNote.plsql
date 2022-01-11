-----------------------------------------------------------------------------
--
--  Logical unit: AvHistReliabilityNote
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Reliability_Note_Id
--  200824  gdeslk  DISO2020R1-214, Added Get_Id_Version_By_Mx_Uniq_Key and Overriden Check_Insert___ 
--  200907  gdeslk  DISO2020R1-214, Added Pre_Sync_Action to fetch inventory_id and parent_inventory_id from av_inventory
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Hist_Reliability_Note_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_reliability_note_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;
   
   IF(newrec_.reliability_note_id IS NULL) THEN
      newrec_.reliability_note_id := key_id_;
   END IF;
   
   Client_SYS.Add_To_Attr('RELIABILITY_NOTE_ID', key_id_, attr_);
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_hist_reliability_note_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   inventory_id_              av_inventory_tab.inventory_id%TYPE;
   parent_inventory_id_       av_inventory_tab.inventory_id%TYPE;
   inv_serial_no_oem_         av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_               av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_           av_inventory_tab.manufacture_code%TYPE;
   barcode_                   av_inventory_tab.barcode%TYPE;
   
   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  inventory_serial_no_oem = inv_serial_no_oem_ AND 
      part_no_oem = part_no_oem_ AND 
      manufacture_code = manufacturer_cd_ AND 
      barcode = barcode_;  
   
BEGIN
   -- Fetching Inventory_Id of the Inventory from Av_Inventory_Tab.
   IF Client_SYS.Item_Exist('PART_NO_OEM', attr_) THEN
      inv_serial_no_oem_ := Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', attr_);
      part_no_oem_       := Client_SYS.Get_Item_Value('PART_NO_OEM', attr_);
      manufacturer_cd_   := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', attr_);
      barcode_           := Client_SYS.Get_Item_Value('BARCODE', attr_);
      
      --Fetching inventory_id
      OPEN get_inventory;
      FETCH get_inventory INTO inventory_id_;
      CLOSE get_inventory;
      
      IF inventory_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated Inventory :P1', barcode_);
      END IF;
      
      -- Adding attributes required for Av_Hist_Reliability_Note_Tab
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, attr_);
      
      IF Client_SYS.Item_Exist('PARENT_PART_NO_OEM', attr_) THEN
         inv_serial_no_oem_ := Client_SYS.Get_Item_Value('PARENT_INVENTORY_SERIAL_NO_OEM', attr_);
         part_no_oem_       := Client_SYS.Get_Item_Value('PARENT_PART_NO_OEM', attr_);
         manufacturer_cd_   := Client_SYS.Get_Item_Value('PARENT_MANUFACTURE_CODE', attr_);
         barcode_           := Client_SYS.Get_Item_Value('PARENT_BARCODE', attr_);
         
         --Fetching parent inventory_id
         OPEN get_inventory;
         FETCH get_inventory INTO parent_inventory_id_;
         CLOSE get_inventory;
         
         Client_SYS.Add_To_Attr('PARENT_INVENTORY_ID', parent_inventory_id_, attr_);
         
      END IF;
   END IF;
   
   attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  attr_);
   attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  attr_);
   attr_:= Client_SYS.Remove_Attr('BARCODE',  attr_);
   attr_:= Client_SYS.Remove_Attr('PARENT_INVENTORY_SERIAL_NO_OEM',  attr_);
   attr_:= Client_SYS.Remove_Attr('PARENT_PART_NO_OEM',  attr_);
   attr_:= Client_SYS.Remove_Attr('PARENT_MANUFACTURE_CODE',  attr_);
   attr_:= Client_SYS.Remove_Attr('PARENT_BARCODE',  attr_);
END Pre_Sync_Action;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_reliability_note_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_reliability_note_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   reliability_note_id_ IN NUMBER ) RETURN av_hist_reliability_note_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(reliability_note_id_);
END Get_Object_By_Keys;

FUNCTION Get_Reliability_Note_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_reliability_note_id IS
   SELECT reliability_note_id
   FROM av_hist_reliability_note_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   reliability_note_id_ av_hist_reliability_note_tab.reliability_note_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_reliability_note_id;
   FETCH get_reliability_note_id INTO reliability_note_id_;
   CLOSE get_reliability_note_id;
   RETURN reliability_note_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Reliability_Note_Id;

FUNCTION Mig_Get_Reliability_Note_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_reliability_note_id IS
   SELECT reliability_note_id
   FROM av_hist_reliability_note_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   reliability_note_id_ av_hist_reliability_note_tab.mx_unique_key%TYPE;
BEGIN
   OPEN get_reliability_note_id;
   FETCH get_reliability_note_id INTO reliability_note_id_;
   CLOSE get_reliability_note_id;
   
   IF reliability_note_id_ IS NULL THEN 
      reliability_note_id_ := av_hist_reliability_note_seq.nextval;
   END IF;
   
   RETURN reliability_note_id_;
END Mig_Get_Reliability_Note_Id;


FUNCTION Get_Inventory_Id_From_Unq_Key(
   inventory_unique_key_ IN VARCHAR2 ) RETURN av_inventory_tab.inventory_id%TYPE
IS
   CURSOR get_inv_id IS
   SELECT inventory_id 
   FROM av_inventory_tab 
   WHERE mx_unique_key = inventory_unique_key_;
   
   inventory_id_ av_inventory_tab.inventory_id%TYPE;
   
BEGIN
   
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
   
   RETURN inventory_id_;
   
END Get_Inventory_Id_From_Unq_Key;

FUNCTION Get_Parent_Inv_Id_Frm_Inv(
   inventory_unique_key_ IN VARCHAR2 ) RETURN av_inventory_tab.parent_inventory_id%TYPE
   
IS
   CURSOR get_parent_inv_id(inventory_id_ NUMBER) IS    
   SELECT parent_inventory_id
   FROM av_inventory_tab 
   WHERE inventory_id = inventory_id_;     
   
   id_ NUMBER;
   parent_inv_id_ NUMBER;
   
BEGIN
   id_ := Get_Inventory_Id_From_Unq_Key(inventory_unique_key_);
   OPEN get_parent_inv_id(id_);
   FETCH get_parent_inv_id INTO parent_inv_id_;
   CLOSE get_parent_inv_id;
   
   RETURN parent_inv_id_;
   
END Get_Parent_Inv_Id_Frm_Inv;
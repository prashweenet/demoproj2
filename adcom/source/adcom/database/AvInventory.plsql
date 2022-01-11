-----------------------------------------------------------------------------
--
--  Logical unit: AvInventory
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Inventory_Id 
--  200824  gdeslk  DISO2020R1-214, Added Get_Id_Version_By_Mx_Uniq_Key
--  200904  gdeslk  DISO2020R1-340, Overriden Check_Insert___, added Pre_Sync_Action() to fetch parent_inventory_id
--  200921  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Inventory_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_inventory_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.inventory_id IS NULL) THEN
      newrec_.inventory_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('INVENTORY_ID', key_id_, attr_);

   super(newrec_, indrec_, attr_);

END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

   PROCEDURE Get_Id_Version_By_Natural_Keys(
      objid_      OUT VARCHAR2,
      objversion_ OUT VARCHAR2,
      attr_       IN OUT VARCHAR2)
   IS
      inventory_serial_no_oem_ av_inventory_tab.inventory_serial_no_oem%TYPE;
      part_no_oem_ av_inventory_tab.part_no_oem%TYPE;
      manufacture_code_ av_inventory_tab.manufacture_code%TYPE;
      barcode_ av_inventory_tab.barcode%TYPE;
      
      CURSOR get_key IS 
      SELECT ROWID, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')
      FROM av_inventory_tab
      WHERE INVENTORY_SERIAL_NO_OEM = inventory_serial_no_oem_
      AND PART_NO_OEM = part_no_oem_
      AND MANUFACTURE_CODE = manufacture_code_
      AND barcode = barcode_;
   BEGIN 
      
      inventory_serial_no_oem_ :=  Client_SYS.Get_Item_Value('INVENTORY_SERIAL_NO_OEM', attr_);
      part_no_oem_ := Client_SYS.Get_Item_Value('PART_NO_OEM', attr_);
      manufacture_code_ := Client_SYS.Get_Item_Value('MANUFACTURE_CODE', attr_); 
      barcode_ := Client_SYS.Get_Item_Value('BARCODE', attr_);
      
      OPEN get_key;
      FETCH get_key INTO objid_,objversion_;
      CLOSE get_key;
        
   IF  objid_ IS NOT NULL AND objversion_ IS NOT NULL THEN
      attr_ := Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM', attr_);
      attr_ := Client_SYS.Remove_Attr('PART_NO_OEM', attr_);
      attr_ := Client_SYS.Remove_Attr('MANUFACTURE_CODE', attr_);
      attr_ := Client_SYS.Remove_Attr('BARCODE', attr_);
   END IF;
   END Get_Id_Version_By_Natural_Keys;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   parent_inv_serial_no_oem_              av_inventory_tab.inventory_serial_no_oem%TYPE;
   parent_part_no_oem_                    av_inventory_tab.part_no_oem%TYPE;
   parent_manufacturer_cd_                av_inventory_tab.manufacture_code%TYPE;
   parent_inventory_id_                   av_inventory_tab.inventory_id%TYPE;
   parent_barcode_                        av_inventory_tab.barcode%TYPE;
   
   CURSOR get_parent_inventory_id_ IS
      SELECT inventory_id
      FROM av_inventory_tab
      WHERE INVENTORY_SERIAL_NO_OEM = parent_inv_serial_no_oem_ AND 
      PART_NO_OEM = parent_part_no_oem_ AND 
      MANUFACTURE_CODE = parent_manufacturer_cd_ AND 
      BARCODE = parent_barcode_;
     
BEGIN
   -- Fetching Inventory_Id of the Parent Inventory from Av_Inventory_Tab.
   IF Client_SYS.Item_Exist('PARENT_PART_NO_OEM', attr_) THEN
      parent_inv_serial_no_oem_ := Client_SYS.Get_Item_Value('PARENT_INVENTORY_SERIAL_NO_OEM', attr_);
      parent_part_no_oem_       := Client_SYS.Get_Item_Value('PARENT_PART_NO_OEM', attr_);
      parent_manufacturer_cd_   := Client_SYS.Get_Item_Value('PARENT_MANUFACTURE_CODE', attr_);
      parent_barcode_           := Client_SYS.Get_Item_Value('PARENT_BARCODE', attr_);
      
      IF parent_part_no_oem_ IS NOT NULL THEN
         OPEN  get_parent_inventory_id_;
         FETCH get_parent_inventory_id_ INTO parent_inventory_id_;
         CLOSE get_parent_inventory_id_;
         
         IF parent_inventory_id_ IS NULL THEN
            Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated Parent Inventory :P1',parent_barcode_);
         END IF;
         
         Client_SYS.Add_To_Attr('PARENT_INVENTORY_ID', parent_inventory_id_, attr_);
      END IF;
      attr_:= Client_SYS.Remove_Attr('PARENT_INVENTORY_SERIAL_NO_OEM',  attr_);
      attr_:= Client_SYS.Remove_Attr('PARENT_PART_NO_OEM',  attr_);
      attr_:= Client_SYS.Remove_Attr('PARENT_MANUFACTURE_CODE',  attr_);
      attr_:= Client_SYS.Remove_Attr('PARENT_BARCODE',  attr_);

   END IF;
END Pre_Sync_Action;

FUNCTION Get_Inventory_Id(
   inventory_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_inv_id IS
   SELECT inventory_id
   FROM av_inventory_tab
   WHERE inventory_alt_id = inventory_alt_id_;
  
   inventory_id_ av_inventory_tab.inventory_id%TYPE;
BEGIN
   IF (inventory_alt_id_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
   RETURN inventory_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Inventory_Id;

FUNCTION Get_Inventory(
   inventory_serial_no_oem_ IN VARCHAR2,
   part_no_oem_ IN VARCHAR2,
   manufacture_code_ IN VARCHAR2,
   barcode_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_inv_id IS
   SELECT inventory_id
   FROM av_inventory_tab
   WHERE inventory_serial_no_oem = inventory_serial_no_oem_
   AND part_no_oem = part_no_oem_
   AND manufacture_code = manufacture_code_
   AND barcode = barcode_;
  
   inventory_id_ av_inventory_tab.inventory_id%TYPE;
BEGIN
   IF (inventory_serial_no_oem_ IS NULL OR part_no_oem_ IS NULL OR manufacture_code_ IS NULL OR barcode_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_inv_id;
   FETCH get_inv_id INTO inventory_id_;
   CLOSE get_inv_id;
   RETURN inventory_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Inventory;

FUNCTION Mig_Get_Inventory_Id(
   mx_unique_key_        IN VARCHAR2
   ) RETURN NUMBER
IS
   CURSOR get_inventory_id IS
   SELECT inventory_id FROM av_inventory_tab 
   WHERE mx_unique_key = mx_unique_key_;
   
   inventory_id_ NUMBER;
BEGIN
   OPEN get_inventory_id;
   FETCH get_inventory_id INTO inventory_id_;
   CLOSE get_inventory_id;
   
   IF inventory_id_ IS NULL THEN
      inventory_id_ := av_inventory_seq.nextval;
   END IF;
RETURN inventory_id_;   
END Mig_Get_Inventory_Id;

FUNCTION Get_Parent_Inventory_Id(
   parent_unique_key_ IN VARCHAR2  
   ) RETURN NUMBER
IS
   inventory_id_ NUMBER;
   
   CURSOR get_inventory_id IS
   SELECT inventory_id FROM av_inventory_tab 
   WHERE mx_unique_key = parent_unique_key_;    
   
BEGIN      
   
   OPEN get_inventory_id;
   FETCH get_inventory_id INTO inventory_id_;
   CLOSE get_inventory_id;

RETURN inventory_id_;   
END Get_Parent_Inventory_Id;

FUNCTION Get_Aircraft_Mx_Unique_Key(
   aircraft_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_aircraft_mx_unique_key IS
   SELECT mx_unique_key
   FROM aircraft_tab
   WHERE alt_id = aircraft_alt_id_;
   
   mx_unique_key_ VARCHAR2(100);
BEGIN
   OPEN get_aircraft_mx_unique_key;
   FETCH get_aircraft_mx_unique_key INTO mx_unique_key_;
   CLOSE get_aircraft_mx_unique_key;
   
   RETURN mx_unique_key_;
   
END Get_Aircraft_Mx_Unique_Key;

FUNCTION Get_Aircraft_Desc_From_Alt(
   aircraft_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_aircraft_mx_unique_key IS
   SELECT aircraft_desc
   FROM aircraft_tab
   WHERE alt_id = aircraft_alt_id_;
   
   aircraft_desc_ VARCHAR2(400);
BEGIN
   OPEN get_aircraft_mx_unique_key;
   FETCH get_aircraft_mx_unique_key INTO aircraft_desc_;
   CLOSE get_aircraft_mx_unique_key;
   
   RETURN aircraft_desc_;
   
END Get_Aircraft_Desc_From_Alt;


PROCEDURE New(
   newrec_ IN OUT NOCOPY av_inventory_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_inventory_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   inv_barcode_ IN VARCHAR2 ) RETURN av_inventory_tab%ROWTYPE
IS
  
BEGIN
   RETURN Get_Object_By_Keys___(inv_barcode_);
END Get_Object_By_Keys;
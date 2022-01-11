-----------------------------------------------------------------------------
--
--  Logical unit: AvHistWorkPackage
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys,Get_Work_Package_Id
--  200923  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   mx_unique_key_             av_hist_work_package_tab.mx_unique_key%TYPE;
   unique_key_                av_hist_work_package_tab.wp_barcode%TYPE;
   av_inventory_unique_key_   av_inventory_tab.mx_unique_key%TYPE;
   inventory_id_              av_inventory_tab.inventory_id%TYPE;
   inv_serial_no_oem_         av_inventory_tab.inventory_serial_no_oem%TYPE;
   part_no_oem_               av_inventory_tab.part_no_oem%TYPE;
   manufacturer_cd_           av_inventory_tab.manufacture_code%TYPE;
   barcode_                   av_inventory_tab.barcode%TYPE;
   
   CURSOR get_unique_key IS
      SELECT wp_barcode
      FROM av_hist_work_package_tab
      WHERE mx_unique_key = mx_unique_key_;
   
   CURSOR get_inventory IS
      SELECT inventory_id
      FROM   av_inventory_tab
      WHERE  INVENTORY_SERIAL_NO_OEM = inv_serial_no_oem_ AND 
      PART_NO_OEM = part_no_oem_ AND 
      MANUFACTURE_CODE = manufacturer_cd_ AND 
      BARCODE = barcode_;  
   
BEGIN   
   
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
         Error_SYS.Appl_General(lu_name_, 'INVENTORYSYNCERR: Could not find the indicated Inventory:P1', av_inventory_unique_key_);
      END IF;
      Client_SYS.Add_To_Attr('INVENTORY_ID', inventory_id_, attr_);
      attr_:= Client_SYS.Remove_Attr('INVENTORY_SERIAL_NO_OEM',  attr_);
      attr_:= Client_SYS.Remove_Attr('PART_NO_OEM',  attr_);
      attr_:= Client_SYS.Remove_Attr('MANUFACTURE_CODE',  attr_);
      attr_:= Client_SYS.Remove_Attr('BARCODE',  attr_);
      
   END IF;
   
   IF Client_SYS.Item_Exist('WP_BARCODE', attr_) THEN
      mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', attr_);
      --check whether the planning task already exists.
      OPEN  get_unique_key;
      FETCH get_unique_key INTO unique_key_;
      CLOSE get_unique_key;
      
      IF mx_unique_key_ IS NOT NULL AND unique_key_ IS NOT NULL THEN
         attr_ := Client_SYS.Remove_Attr('WP_BARCODE', attr_); 
      END IF;
   END IF;  
   
END Pre_Sync_Action;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_work_package_tab
   WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_work_package_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_work_package_tab%ROWTYPE,
   lock_mode_wait_ IN            BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   wp_barcode_ IN VARCHAR2 ) RETURN av_hist_work_package_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(wp_barcode_);
END Get_Object_By_Keys;

FUNCTION Get_Work_Package_Id(
   work_package_alt_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_wp_barcode IS
   SELECT wp_barcode
   FROM av_hist_work_package_tab
   WHERE work_package_alt_id = work_package_alt_id_;
   
   wp_barcode_ av_hist_work_package_tab.wp_barcode%TYPE;
BEGIN
   IF (work_package_alt_id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_wp_barcode;
   FETCH get_wp_barcode INTO wp_barcode_;
   CLOSE get_wp_barcode;
   RETURN wp_barcode_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Work_Package_Id;

FUNCTION  Get_Inventory_Id_From_Unq_Key(
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


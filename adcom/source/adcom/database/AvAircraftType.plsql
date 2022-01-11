-----------------------------------------------------------------------------
--
--  Logical unit: AvAircraftType
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date     Sign    History
--  ------   ------  -----------------------------------------------------
--  200902   SWiclk  LMM2020R1-1058, Modified Get_Id_Version_By_Mx_Uniq_Key() in order to check aircraft_type_code as mx_unique_key.
--  200824   SWIclk  LMM2020R1-916, Added Pre_Sync_Action() in order to check and remove AIRCRAFT_TYPE_CODE if exists.
--  200820   SWiclk  LMM2020R1-870, Removed Check_Insert___() since aircraft_type_id is no longer valid hence AIRCRAFT_TYPE_SEQ.NEXTVAL is not used.
--  200723   SWiclk  LMM2020R1-495, Removed Check_Mx_Unique_Id_Exist___, Get_Key_Id_By_Mx_Unique_Id___, 
--  200723           Add_Or_Modify_Sync_Record and added Get_Id_Version_By_Mx_Uniq_Key
--  200630   SWiclk  LMM2020R1-234, Added methods Check_Mx_Unique_Id_Exist___, Get_Key_Id_By_Mx_Unique_Id___, Add_Or_Modify_Sync_Record 
--  200630           in order to handling sync process from MXI to IFS.  
--  200618   SURBLK  LMM2020R1-78, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_aircraft_type_tab
       WHERE aircraft_type_code = mx_unique_key_;

BEGIN
   OPEN get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   aircraft_type_code_         av_aircraft_type_tab.aircraft_type_code%TYPE;
BEGIN
   local_attr_         := attr_;
   aircraft_type_code_ := Client_SYS.Get_Item_Value('AIRCRAFT_TYPE_CODE', local_attr_); 
   
   IF Check_Exist___(aircraft_type_code_) THEN
      local_attr_:= Client_SYS.Remove_Attr('AIRCRAFT_TYPE_CODE',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;



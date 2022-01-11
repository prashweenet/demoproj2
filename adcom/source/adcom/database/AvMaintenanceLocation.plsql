-----------------------------------------------------------------------------
--
--  Logical unit: AvMaintenanceLocation
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200904  TAJALK  LMM2020R1-869, Sync corrections after refactoring
--  200811  TAJALK  LMM2020R1-668, Additional call related to ROWID removed from Pre_Sync_Action
--  200729  TAJALK  LMM2020R1-405, Changed Pre_Sync_Action 
--  200724  TAJALK  LMM2020R1-405, Added Pre_Sync_Action 
--  200723  TAJALK  LMM2020R1-501, Changes due to generic FW for Sync
--  200716  TAJALK  LMM2020R1-219, Added Get_Key_Id_By_Mx_Unique_Key___, Get_Key_Id_By_Mx_Unique_Key
--  200703  SatGlk  Created, Overidden Check_Insert___ to add next seq val to MaintenanceLocationId
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')    
      FROM  av_maintenance_location_tab
      WHERE location_code = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2) 
IS
   local_attr_                VARCHAR2(4000);
   airport_unique_key_        av_airport_tab.mx_unique_key%TYPE;
   airport_id_                av_airport_tab.airport_id%TYPE;
   location_code_             av_maintenance_location_tab.location_code%TYPE;
   
   CURSOR get_airport_id IS
      SELECT airport_id
      FROM   av_airport_tab
      WHERE  mx_unique_key = airport_unique_key_;
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('AIRPORT_UNIQUE_KEY', local_attr_) THEN

      airport_unique_key_ := Client_SYS.Get_Item_Value('AIRPORT_UNIQUE_KEY', local_attr_);    

      OPEN  get_airport_id;
      FETCH get_airport_id INTO airport_id_;
      CLOSE get_airport_id;
      
      IF airport_unique_key_ IS NOT NULL AND airport_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'AIRPORTSYNCERR: Could not find the indicated Airport :P1', airport_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('AIRPORT_ID', airport_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('AIRPORT_UNIQUE_KEY',  local_attr_);
   END IF;
  
   location_code_ := Client_SYS.Get_Item_Value('LOCATION_CODE', local_attr_); 
   
   IF Check_Exist___(Client_SYS.Get_Item_Value('LOCATION_CODE', local_attr_)) THEN
      local_attr_:= Client_SYS.Remove_Attr('LOCATION_CODE',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;
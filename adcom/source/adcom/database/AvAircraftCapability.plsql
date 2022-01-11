-----------------------------------------------------------------------------
--
--  Logical unit: AvAircraftCapability
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210205  waislk  DISO2020R1-564, Modified Pre_Sync_Action
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys
--  200925  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
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
   local_attr_             VARCHAR2(4000);
   aircraft_unique_key_    VARCHAR2(50);
   aircraft_id_            aircraft_tab.aircraft_id%TYPE;
   capability_cd_attr_     av_aircraft_capability_tab.capability_code%TYPE;
   capability_code_        av_aircraft_capability_tab.capability_code%TYPE;
   
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  aircraft_type_code ||':'|| serial_number = aircraft_unique_key_;
      
   CURSOR get_ids IS
      SELECT capability_code
      FROM av_aircraft_capability_tab 
      WHERE aircraft_id = aircraft_id_ AND capability_code = capability_cd_attr_;
BEGIN
   
   local_attr_ := attr_;
 
   IF Client_SYS.Item_Exist('AIRCRAFT_UNIQUE_KEY', local_attr_) THEN
      aircraft_unique_key_ := Client_SYS.Get_Item_Value('AIRCRAFT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_aircraft_id;
      FETCH get_aircraft_id INTO aircraft_id_;
      CLOSE get_aircraft_id;
     
      IF aircraft_unique_key_ IS NOT NULL AND aircraft_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'AIRCRAFTSYNCERR: Could not find the indicated Aircraft :P1', aircraft_unique_key_);
      END IF;
   
      IF Client_SYS.Item_Exist('CAPABILITY_CODE', attr_) THEN
      capability_cd_attr_ := Client_SYS.Get_Item_Value('CAPABILITY_CODE', local_attr_);
      
      OPEN  get_ids;
      FETCH get_ids INTO capability_code_;
      CLOSE get_ids;
      
         IF capability_cd_attr_ IS NOT NULL AND capability_code_ IS NOT NULL THEN 
            local_attr_:= Client_SYS.Remove_Attr('AIRCRAFT_ID',  local_attr_);
            local_attr_:= Client_SYS.Remove_Attr('CAPABILITY_CODE',  local_attr_);
         ELSE
            Client_SYS.Add_To_Attr('AIRCRAFT_ID', aircraft_id_, local_attr_);         
     
         END IF;
      END IF;
   END IF;
  
       
   attr_ := local_attr_;

END Pre_Sync_Action;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT c.rowid, TO_CHAR(c.rowversion,'YYYYMMDDHH24MISS')     
   FROM   aircraft_tab a
   INNER JOIN av_aircraft_capability_tab c
   ON a.aircraft_id = c.aircraft_id
   WHERE  a.aircraft_type_code ||':'|| a.serial_number || ':' || c.capability_code = mx_unique_key_;
   
   
BEGIN
   
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_aircraft_capability_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_aircraft_capability_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   aircraft_id_ IN NUMBER,
   capability_code_ IN VARCHAR2 ) RETURN av_aircraft_capability_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(aircraft_id_, capability_code_);
END Get_Object_By_Keys;

FUNCTION Get_Aircraft_Id(
   mx_unique_key_ IN VARCHAR2) RETURN aircraft_tab.aircraft_id%TYPE
IS
   CURSOR get_aircraft_id IS
   SELECT aircraft_id 
   FROM aircraft_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   aircraft_id_ aircraft_tab.aircraft_id%TYPE;
BEGIN
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO aircraft_id_;
   CLOSE get_aircraft_id;
   
   RETURN aircraft_id_;
END Get_Aircraft_Id;

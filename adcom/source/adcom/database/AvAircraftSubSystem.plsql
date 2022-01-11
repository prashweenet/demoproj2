-----------------------------------------------------------------------------
--
--  Logical unit: AvAircraftSubSystem
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date     Sign    History
--  ------  ------  ---------------------------------------------------------
--  210112  KAWJLK  LMM2020R1-1477, Added overridden Check_Insert___, Check_Common___, Check_Common_Data.
--  210105  sevhlk  LMM2020R1-1482, Changes made to pre_sync_action method
--  210108  supklk  LMM2020R1-1502, Added Get_System_Id_By_Unique_Key to fetch system id in data migration
--  210108  supklk  LMM2020R1-1502, Added Get_Key_By_Mx_Unique_Key to handle duplications in data migration
--  201019  rosdlk  LMM2020R1-794  Changed presync action
--  200927  lahnlk  LMM2020R1-1274 removed overridden check_insert
--  200924  rosdlk  LMM2020R1-1087, Sync corrections after refactoring
--  200811  rosdlk  LMM2020R1-464: Added aircraft sub system related sync methods.
--  200625  LAHNLK  LMM2020R1-84:  created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Aircraft_Sub_System_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_sub_system_seq.NEXTVAL
      FROM dual;
BEGIN
      IF(newrec_.sub_system_id IS NULL) THEN
         OPEN get_key_set;
         FETCH get_key_set INTO newrec_.sub_system_id;
         CLOSE get_key_set;
      END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('SUB_SYSTEM_ID', newrec_.sub_system_id, attr_);
END Check_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     Av_Aircraft_Sub_System_Tab%ROWTYPE,
   newrec_ IN OUT Av_Aircraft_Sub_System_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
    IF NOT Check_Common_Data(newrec_) THEN
      Error_SYS.Record_Exist('AvAircraftSubSystem', NULL, newrec_.sub_system_code, NULL, NULL);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   
END Check_Common___;


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
      FROM  av_aircraft_sub_system_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS 
   local_attr_          VARCHAR2(4000);
   system_unique_key_   av_aircraft_system_tab.mx_unique_key%TYPE;
   system_id_           av_aircraft_system_tab.system_id%TYPE;
   
   CURSOR get_aircraft_system_id IS
      SELECT system_id
      FROM   av_aircraft_system_tab
      WHERE  mx_unique_key = system_unique_key_;
BEGIN
   
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('SYSTEM_UNIQUE_KEY', local_attr_) THEN
      system_unique_key_ := Client_SYS.Get_Item_Value('SYSTEM_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_aircraft_system_id;
      FETCH get_aircraft_system_id INTO system_id_;
      CLOSE get_aircraft_system_id;
      
      IF system_unique_key_ IS NOT NULL AND system_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'AIRCRAFTSYSTEMSYNCER: Could not find the indicated Aircraft System :P1', system_unique_key_);
      END IF;
      
   Client_SYS.Add_To_Attr('SYSTEM_ID', system_id_, local_attr_);
   local_attr_:= Client_SYS.Remove_Attr('SYSTEM_UNIQUE_KEY',  local_attr_);
   END IF;
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Check_Common_Data (rec_ IN Av_Aircraft_Sub_System_Tab%ROWTYPE)RETURN BOOLEAN
IS
   sub_system_id_ NUMBER;
   CURSOR check_common_data IS 
      SELECT t.sub_system_id
      FROM Av_Aircraft_Sub_System_Tab t
      WHERE t.aircraft_type_code = rec_.aircraft_type_code AND 
            t.sub_system_code = rec_.sub_system_code AND 
            (t.sub_system_id != rec_.sub_system_id OR rec_.sub_system_id IS NULL);
BEGIN 
   OPEN check_common_data;
   FETCH check_common_data INTO sub_system_id_;
   CLOSE check_common_data;
   
   IF sub_system_id_ IS NOT NULL THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END Check_Common_Data;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_sub_system_tab.sub_system_id%TYPE;
   
   CURSOR get_sub_system_id IS 
      SELECT sub_system_id         
      FROM av_aircraft_sub_system_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_sub_system_id;
   FETCH get_sub_system_id INTO temp_; 
   CLOSE get_sub_system_id;

   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;


FUNCTION Get_System_Id_By_Unique_Key (
   system_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_system_tab.system_id%TYPE;
   
   CURSOR get_system_id IS 
      SELECT system_id         
      FROM av_aircraft_system_tab
      WHERE mx_unique_key = system_unique_key_;
BEGIN
   OPEN get_system_id;
   FETCH get_system_id INTO temp_; 
   CLOSE get_system_id;

   RETURN temp_;
END Get_System_Id_By_Unique_Key;
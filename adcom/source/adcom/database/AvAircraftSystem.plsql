-----------------------------------------------------------------------------
--
--  Logical unit: AvAircraftSystem
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210112  KAWJLK  LMM2020R1-1477, Added overridden Check_Insert___, Check_Common___, Check_Common_Data.
--  210108  supklk  LMM2020R1-1502, Added Get_Key_By_Mx_Unique_Key to handle duplications in data migration
--  201019  rosdlk  LMM2020R1-794,  Added presync action
--  200924  rosdlk  LMM2020R1-1087, Sync corrections after refactoring
--  200907  rosdlk  LMM2020R1-1083, Removed pre sync method.
--  200821  SWiclk  LMM2020R1-870, Replaced AircraftTypeId by AircraftTypeCode due to key change.
--  200812  ROSDLK  LMM2020R1-690, Removed unused mehod call from Pre_Sync_Action procedure.
--  200729  ROSDLK  LMM2020R1-461, Added Aircraft system related sync methods.
--  200625  ARUFLK  Created, Overidden Check_Insert___() and created sequence for deferral_id.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_aircraft_system_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Aircraft_System_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_system_seq.NEXTVAL
      FROM dual;
   
BEGIN
   
      IF(newrec_.system_id IS NULL) THEN
         OPEN get_key_set;
         FETCH get_key_set INTO newrec_.system_id;
         CLOSE get_key_set;
      END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('SYSTEM_ID', newrec_.system_id, attr_);
END Check_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     Av_Aircraft_System_Tab%ROWTYPE,
   newrec_ IN OUT Av_Aircraft_System_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF NOT Check_Common_Data(newrec_) THEN
       Error_SYS.Record_Exist('AvAircraftSystem', NULL, newrec_.system_code, NULL, NULL);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   
END Check_Common___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Check_Common_Data (rec_ IN Av_Aircraft_System_Tab%ROWTYPE)RETURN BOOLEAN
IS
   system_id_ NUMBER;
   CURSOR check_common_data IS 
      SELECT t.system_id
      FROM Av_Aircraft_System_Tab t
      WHERE t.aircraft_type_code = rec_.aircraft_type_code AND 
            t.system_code = rec_.system_code AND 
            (t.system_id != rec_.system_id OR rec_.system_id IS NULL);
BEGIN 
   OPEN check_common_data;
   FETCH check_common_data INTO system_id_;
   CLOSE check_common_data;
   
   IF system_id_ IS NOT NULL THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END Check_Common_Data;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_system_tab.system_id%TYPE;
   
   CURSOR get_system_id IS 
      SELECT system_id         
        FROM av_aircraft_system_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_system_id;
   FETCH get_system_id INTO temp_; 
   CLOSE get_system_id;

   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;
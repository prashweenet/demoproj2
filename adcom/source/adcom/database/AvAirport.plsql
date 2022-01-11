-----------------------------------------------------------------------------
--
--  Logical unit: AvAirport
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210308  majslk  LMM2020R1-1901, Removed Component_Flm_SYS.INSTALLED, added Dictionary_SYS.Component_Is_Active
--  200304  majslk  LMM2020R1-1665, Override Insert___, Update___.
--  200923  SURBLK  Added Get_Key_By_Mx_Unique_Key to support for Data Migration.
--  200723  SWiclk  LMM2020R1-503, Removed Check_Mx_Unique_Id_Exist___, Get_Key_Id_By_Mx_Unique_Id___, 
--  200723          Add_Or_Modify_Sync_Record and added Get_Id_Version_By_Mx_Uniq_Key
--  200720  dildlk  LMM2020R1-335, Added methods Check_Mx_Unique_Key_Exist___, Get_Key_Id_By_Mx_Unique_Key___, Add_Or_Modify_Sync_Record in order to handling sync process from MXI to IFS.
--  200714  SURBLK  Overidden Prepare_Insert___ to set the default values.
--  200618  SatGlk  Created, Overidden Check_Insert___ to add next seq val to AirportId
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_airport_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   airport_id_ NUMBER;
   
   CURSOR get_airport_id_cursor IS 
   SELECT AIRPORT_ID_SEQ.nextval 
   FROM dual;
BEGIN
   IF(newrec_.airport_id IS NULL) THEN
      OPEN get_airport_id_cursor;
      FETCH get_airport_id_cursor INTO airport_id_;
      CLOSE get_airport_id_cursor;
      newrec_.airport_id := airport_id_;
      Client_SYS.Add_To_Attr('AIRPORT_ID', airport_id_, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(attr_);
   Client_SYS.Add_To_Attr('ARRIVAL_OFFSET','3',attr_);
   Client_SYS.Add_To_Attr('DEPARTURE_OFFSET','3',attr_);
   Client_SYS.Add_To_Attr('FAULTS_OFFSET','3',attr_);
   --Add post-processing code here
END Prepare_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_airport_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.arrival_airport_Id   = newrec_.airport_id
      OR     f.departure_airport_id = newrec_.airport_id;
   
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_airport_tab%ROWTYPE,
   newrec_     IN OUT av_airport_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS   
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.arrival_airport_Id   = newrec_.airport_id
      OR     f.departure_airport_id = newrec_.airport_id;
      
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
END Update___;
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
        FROM av_airport_tab
       WHERE mx_unique_key = mx_unique_key_;

BEGIN
   OPEN get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_airport_tab.airport_id%TYPE;
   
   CURSOR get_airport_id IS 
      SELECT airport_id         
        FROM av_airport_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_airport_id;
   FETCH get_airport_id INTO temp_; 
   CLOSE get_airport_id;

   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;
-----------------------------------------------------------------------------
--
--  Logical unit: AvHistFlight
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Component_Change_Id, Get_Flight_Id
--  200917  gdeslk  DISCOP2020R1-215, Added Get_Id_Version_By_Mx_Uniq_Key and
--                  Pre_Sync_Action to fetch IDs from referenced tables using unique_keys
--  200922  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;
-----------------------------------------------------------------------------

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Hist_Flight_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   flight_id_ Av_Hist_Flight_Tab.flight_id%TYPE;
   
   CURSOR get_key_set IS
      SELECT av_hist_flight_seq.NEXTVAL
      FROM dual;
BEGIN
   OPEN get_key_set;
   FETCH get_key_set INTO flight_id_;
   CLOSE get_key_set;
   
   IF newrec_.flight_id IS NULL THEN
      newrec_.flight_id := flight_id_;
   END IF;
   
   Client_SYS.Add_To_Attr('FLIGHT_ID', flight_id_, attr_);
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Flight_Id(
   flight_leg_alt_id_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_flight_id IS
   SELECT flight_id
   FROM av_hist_flight_tab
   WHERE flight_leg_alt_id = flight_leg_alt_id_;
  
   flight_id_ av_hist_flight_tab.flight_id%TYPE;
BEGIN
   IF (flight_leg_alt_id_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_flight_id;
   FETCH get_flight_id INTO flight_id_;
   CLOSE get_flight_id;
   RETURN flight_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Flight_Id;

PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_flight_tab%ROWTYPE )
IS
  BEGIN
   New___(newrec_);
  END New;
  
PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_flight_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
 BEGIN
   Modify___(newrec_, lock_mode_wait_);
 END Modify;
 
 FUNCTION Get_Object_By_Keys (
   flight_id_ IN NUMBER ) RETURN av_hist_flight_tab%ROWTYPE
 IS
    BEGIN
   RETURN Get_Object_By_Keys___(flight_id_);
END Get_Object_By_Keys;


FUNCTION Mig_Get_Flight_Id(
   flight_leg_alt_id_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_flight_id IS
   SELECT flight_id
   FROM av_hist_flight_tab
   WHERE flight_leg_alt_id = flight_leg_alt_id_;
  
   flight_id_ av_hist_flight_tab.flight_id%TYPE;
BEGIN
   
   OPEN get_flight_id;
   FETCH get_flight_id INTO flight_id_;
   CLOSE get_flight_id;
   
   IF flight_id_ IS NULL THEN
     flight_id_ := av_hist_flight_seq.NEXTVAL;
   END IF;
   
   RETURN flight_id_;

END Mig_Get_Flight_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 )
IS

   CURSOR get_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')
      FROM  av_hist_flight_tab
      WHERE flight_leg_alt_id = mx_unique_key_;
      
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                   VARCHAR2(4000);
   mx_unique_key_                av_hist_flight.flight_leg_alt_id%TYPE;
   aircraft_unique_key_          aircraft_tab.mx_unique_key%TYPE;
   aircraft_id_                  aircraft_tab.aircraft_id%TYPE;
   departure_airport_unique_key_ av_airport_tab.mx_unique_key%TYPE;
   departure_airport_id_         av_airport_tab.airport_id%TYPE;
   arrival_airport_unique_key_   av_airport_tab.mx_unique_key%TYPE;
   arrival_airport_id_           av_airport_tab.airport_id%TYPE;
   aircraft_type_code_           aircraft_tab.aircraft_type_code%TYPE;
   serial_number_                aircraft_tab.serial_number%TYPE;
   
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  aircraft_type_code = aircraft_type_code_
      AND serial_number = serial_number_;
      
   CURSOR get_departure_airport_id IS
      SELECT airport_id
      FROM   av_airport_tab
      WHERE  mx_unique_key = departure_airport_unique_key_;
      
   CURSOR get_arrival_airport_id IS
      SELECT airport_id
      FROM   av_airport_tab
      WHERE  mx_unique_key = arrival_airport_unique_key_;

BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('AIRCRAFT_TYPE_CODE', local_attr_) THEN
      aircraft_type_code_ := Client_SYS.Get_Item_Value('AIRCRAFT_TYPE_CODE', local_attr_);
      serial_number_ := Client_SYS.Get_Item_Value('SERIAL_NO_OEM', local_attr_);    
      
      OPEN  get_aircraft_id;
      FETCH get_aircraft_id INTO aircraft_id_;
      CLOSE get_aircraft_id;
      
      IF aircraft_unique_key_ IS NOT NULL AND aircraft_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'AIRCRAFTSYNCERR: Could not find the indicated Aircraft :P1', aircraft_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('AIRCRAFT_ID', aircraft_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('AIRCRAFT_TYPE_CODE',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('SERIAL_NO_OEM',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('DEPARTURE_AIRPORT_UNIQUE_KEY', local_attr_) THEN
      departure_airport_unique_key_ := Client_SYS.Get_Item_Value('DEPARTURE_AIRPORT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_departure_airport_id;
      FETCH get_departure_airport_id INTO departure_airport_id_;
      CLOSE get_departure_airport_id;
      
      IF departure_airport_unique_key_ IS NOT NULL AND departure_airport_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'DEPARTUREAIRPORTSYNCERR: Could not find the Depature Airport Type:P1', departure_airport_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('DEPARTURE_AIRPORT_ID', departure_airport_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('DEPARTURE_AIRPORT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('ARRIVAL_AIRPORT_UNIQUE_KEY', local_attr_) THEN
      arrival_airport_unique_key_ := Client_SYS.Get_Item_Value('ARRIVAL_AIRPORT_UNIQUE_KEY', local_attr_);    

      OPEN  get_arrival_airport_id;
      FETCH get_arrival_airport_id INTO arrival_airport_id_;
      CLOSE get_arrival_airport_id;
      
      IF arrival_airport_unique_key_ IS NOT NULL AND arrival_airport_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'ARRIVALAIRPORTSYNCERR: Could not find the indicated Arrival Airport :P1', arrival_airport_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('ARRIVAL_AIRPORT_ID', arrival_airport_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('ARRIVAL_AIRPORT_UNIQUE_KEY',  local_attr_);
   END IF;
   local_attr_:= Client_SYS.Remove_Attr('USAGE_RECORD_UNIQUE_KEY',  local_attr_);
   mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_);
   Client_SYS.Add_To_Attr('FLIGHT_LEG_ALT_ID', mx_unique_key_, local_attr_);

   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Aircraft_Id(
   aircraft_unique_key_ IN VARCHAR2) RETURN aircraft_tab.aircraft_id%TYPE
IS
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  mx_unique_key = aircraft_unique_key_;

   aircraft_id_  aircraft_tab.aircraft_id%TYPE;  
BEGIN
   OPEN  get_aircraft_id;
      FETCH get_aircraft_id INTO aircraft_id_;
      CLOSE get_aircraft_id;
      
      RETURN aircraft_id_;
END Get_Aircraft_Id;

FUNCTION Get_Departure_Airport_Id(
    departure_airport_unique_key_ IN VARCHAR2) RETURN av_airport_tab.airport_id%TYPE
IS

   CURSOR get_departure_airport_id IS
      SELECT airport_id
      FROM   av_airport_tab
      WHERE  mx_unique_key = departure_airport_unique_key_;
      
   departure_airport_id_  av_airport_tab.airport_id%TYPE;
BEGIN
   
      OPEN  get_departure_airport_id;
      FETCH get_departure_airport_id INTO departure_airport_id_;
      CLOSE get_departure_airport_id;
      
      RETURN departure_airport_id_;
END Get_Departure_Airport_Id;

FUNCTION Get_Arrival_Airport_Id(
   arrival_airport_unique_key_ IN VARCHAR2) RETURN av_airport_tab.airport_id%TYPE
IS
   CURSOR get_arrival_airport_id IS
      SELECT airport_id
      FROM   av_airport_tab
      WHERE  mx_unique_key = arrival_airport_unique_key_;
      
   arrival_airport_id_  av_airport_tab.airport_id%TYPE;  
BEGIN
      OPEN  get_arrival_airport_id;
      FETCH get_arrival_airport_id INTO arrival_airport_id_;
      CLOSE get_arrival_airport_id;
      
      RETURN arrival_airport_id_;
END Get_Arrival_Airport_Id;

FUNCTION Get_Usage_Record_Id(
   usage_record_unique_key_ IN VARCHAR2) RETURN av_hist_usage_record_tab.usage_record_id%TYPE
IS
   CURSOR get_usage_record_id IS
      SELECT usage_record_id
      FROM   av_hist_usage_record_tab
      WHERE  usage_record_alt_id = usage_record_unique_key_;
      
   usage_record_id_ av_hist_usage_record_tab.usage_record_id%TYPE;
BEGIN
      OPEN get_usage_record_id;
      FETCH get_usage_record_id INTO usage_record_id_;
      CLOSE get_usage_record_id;
      
      RETURN usage_record_id_;
END Get_Usage_Record_Id;
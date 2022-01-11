-----------------------------------------------------------------------------
--
--  Logical unit: AvAircraftWorkPackage
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210505  SatGlk  AD-1701, Modifications to Update_Status to check WP status before Commiting the WP
--  210407  siselk  AD-1026, Modifications to Get_Work_Package_Id
--  210310  kawjlk  LMM2020R1-1930, Added Update_Work_Package, Delete_Duplicate_Rec to handle WP duplication issue 
--  210308  tprelk  LMM2020R1-1581, Created Get_Av_Work_Package_id.
--  210308  majslk  LMM2020R1-1800, Updated Insert___ method.
--  210308  majslk  LMM2020R1-1901, Removed Component_Flm_SYS.INSTALLED, added Dictionary_SYS.Component_Is_Active
--  210305  hasmlk  LMM2020R1-917, Complete work package API related procedures added.
--  210305  majslk  LMM2020R1-1904, Added conditions for null check in Insert___, Update___
--  210304  majslk  LMM2020R1-1665, Change variable names in Update___ method
--  210303  majslk  LMM2020R1-1665, Override Insert___, Update___, Finite_State_Set___ methods
--  210301  SWiclk  AD2020R1-1538, Annotated Get_Func_Actual_Start(), Get_Func_Actual_End(), Get_Work_Package_Id() with UncheckedAcces.
--  210225  CSarLK  LMM2020R1-1708, refactored methods used in my_aircraft_turns view for avFlight
--  210218  SatGlk  LMM2020R1-1552, Modified Sync_State_Handle method to handle state change from InWork to Committed
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 068_FLM_AIRCRAFT_WP when setting the rowstate.
--  200111  SEVHLK  LMM2020R1-1478, Changed Sync_State_Handle method to handle state change from commit to avtive
--  201217  SUPKLK  LMM2020R1-1116, Implemented Get_Aircraft_By_Unique_Key to fetch Aircraft in data migration
--  201217  SUPKLK  LMM2020R1-1116, Implemented Get_Key_By_Mx_Unique_Key to handle duplications in data migration
--  201125  LAHNLK  LMM2020R1-1441, created Get_Func_Actual_Start and Get_Func_Actual_End
--  201026  siselk  AD2020R1-950, Updated Get_Work_Package_Id
--  200925  KAWJLK  LMM2020R1-1044, Changed logic in Get_Work_Package_Id.
--  200924  siselk  LMM2020R1-1249, Updated Get_Work_Package_Id, Get_Func_Scheduled_Start and Get_Func_Scheduled_End
--  200922  ROSDLK  LMM2020R1-1239, Added UpdateStatus() method to update wp status when start a task
--  200811  TAJALK  LMM2020R1-669, Additional call related to ROWID removed from Pre_Sync_Action
--  200729  TAJALK  LMM2020R1-501, Changed Pre_Sync_Action 
--  200723  TAJALK  LMM2020R1-501, Changes due to generic FW for Sync
--  200714  TAJALK  LMM2020R1-219, Added Mxi -> IFS Sync methods
--  200701  SISELK  LMM2020R1-167, Modified Get_Work_Package_Id, Get_Duration
--  200630  TAJALK  LMM2020R1-208, Fixed issue
--  200617  ROSDLK  LMM2020R1-76, Created.
--  200615  SISELK  LMM2020R1-14, Created
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_aircraft_work_package_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_ NUMBER;
  
   CURSOR get_key_cursor IS
   SELECT AIRCRAFT_WORK_PACKAGE_SEQ.NEXTVAL
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO key_;
   CLOSE get_key_cursor;
  
   IF(newrec_.aircraft_work_package_id IS NULL) THEN
      newrec_.aircraft_work_package_id := key_;
   END IF;
   super(newrec_, indrec_, attr_);
  
   Client_SYS.Add_To_Attr('AIRCRAFT_WORK_PACKAGE_ID', key_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_aircraft_work_package_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   flight_id_            NUMBER;
   
   CURSOR get_flights IS
      SELECT flight_id
      FROM   Av_Flight_Tab
      WHERE  aircraft_id = newrec_.aircraft_id;
            
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      flight_id_ := Get_Flight_Id(newrec_.aircraft_work_package_id);
      IF flight_id_ IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(flight_id_);
      END IF;
      
      IF newrec_.actual_end_date_time IS NOT NULL THEN
         FOR rec_ IN get_flights LOOP
            Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
         END LOOP;
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_aircraft_work_package_tab%ROWTYPE,
   newrec_     IN OUT av_aircraft_work_package_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   --flight_id_of_wp will hold the flight before updating the location code and 
   --new_flight_id_of_wp will hold the new flight which the wp will be set after updating the location code.
   flight_id_of_wp     NUMBER;
   new_flight_id_of_wp NUMBER;
   
   CURSOR get_flights IS
      SELECT flight_id
      FROM   Av_Flight_Tab
      WHERE  aircraft_id = newrec_.aircraft_id;
            
BEGIN
   new_flight_id_of_wp := Get_Flight_Id(newrec_.aircraft_work_package_id);
   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      flight_id_of_wp := Get_Flight_Id(newrec_.aircraft_work_package_id);
      
      IF flight_id_of_wp IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(flight_id_of_wp);
      END IF;
      
      IF new_flight_id_of_wp IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(new_flight_id_of_wp);
      END IF;
      
      IF oldrec_.actual_end_date_time != newrec_.actual_end_date_time THEN
         FOR rec_ IN get_flights LOOP
            Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
         END LOOP;
      END IF;
   END IF;
END Update___;

@Override
PROCEDURE Finite_State_Set___ (
   rec_   IN OUT av_aircraft_work_package_tab%ROWTYPE,
   state_ IN     VARCHAR2 )
IS
   flight_id_  NUMBER;
BEGIN
   super(rec_, state_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      flight_id_ := Get_Flight_Id(rec_.aircraft_work_package_id);
      IF flight_id_ IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(flight_id_);
      END IF;
   END IF;
END Finite_State_Set___;

PROCEDURE Sync_State_Handle___(
   current_rowstate_  IN VARCHAR2,
   incoming_rowstate_ IN VARCHAR2,
   input_objid_       IN VARCHAR2,
   input_objversion_  IN VARCHAR2)
IS
   info_                    VARCHAR2(4000);
   action_                  VARCHAR2(5)    := 'DO';
   state_attr_              VARCHAR2(4000);
   objid_                   VARCHAR2(4000) := input_objid_;
   objversion_              VARCHAR2(4000) := input_objversion_;
BEGIN
   IF (incoming_rowstate_ IS NULL) OR
      (current_rowstate_ = 'Active'    AND incoming_rowstate_ = 'ACTV')     OR
      (current_rowstate_ = 'Active'    AND incoming_rowstate_ = 'FORECAST') OR
      (current_rowstate_ = 'Committed' AND incoming_rowstate_ = 'COMMIT')   OR
      (current_rowstate_ = 'Canceled'  AND incoming_rowstate_ = 'CANCEL')   OR
      (current_rowstate_ = 'InWork'    AND incoming_rowstate_ = 'IN WORK')  OR
      (current_rowstate_ = 'Completed' AND incoming_rowstate_ = 'COMPLETE') THEN
      
      RETURN;
   END IF;
   
   IF current_rowstate_ = 'Active' AND incoming_rowstate_ = 'COMMIT' THEN
      Commit_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Active' AND incoming_rowstate_ = 'CANCEL' THEN
      Cancel_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Active' AND incoming_rowstate_ = 'IN WORK' THEN
      Commit_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Start_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Active' AND incoming_rowstate_ = 'COMPLETE' THEN
      Commit_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Start_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Complete_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Committed' AND incoming_rowstate_ = 'IN WORK' THEN
      Start_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Committed' AND incoming_rowstate_ = 'COMPLETE' THEN
      Start_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Complete_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'InWork' AND incoming_rowstate_ = 'COMPLETE' THEN
      Complete_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
    
   ELSIF current_rowstate_ = 'InWork' AND incoming_rowstate_ = 'COMMIT' THEN
      Undo_Start_Work_Package__(info_, objid_, objversion_, state_attr_, action_); 
      
   ELSIF current_rowstate_ = 'Committed' AND incoming_rowstate_ = 'ACTV' THEN
      Uncommit_Work_Package__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);
      
   END IF;
END Sync_State_Handle___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@UncheckedAccess
FUNCTION Get_Last_Release_Date(
   aircraft_id_  IN NUMBER) RETURN TIMESTAMP
IS
   act_end_date_ av_aircraft_work_package_tab.actual_end_date_time%TYPE;
 
   CURSOR get_actual_end_dates IS
      SELECT   actual_end_date_time
      FROM     av_aircraft_work_package_tab
      WHERE    aircraft_id          = aircraft_id_
      AND      actual_end_date_time < sysdate
      ORDER BY actual_end_date_time DESC
      FETCH first 1 ROW ONLY;
       
BEGIN
   OPEN  get_actual_end_dates;
   FETCH get_actual_end_dates INTO act_end_date_;
   CLOSE get_actual_end_dates;
   RETURN act_end_date_;
END Get_Last_Release_Date;

@UncheckedAccess
FUNCTION Get_Work_Package_Id(
   aircraft_id_               IN NUMBER,
   arr_airport_id_            IN NUMBER,
   flight_id_                 IN NUMBER,
   fl_sched_arr_time_         IN TIMESTAMP DEFAULT NULL,
   fl_next_sched_depart_time_ IN TIMESTAMP DEFAULT NULL,
   fl_actual_arr_time_        IN TIMESTAMP DEFAULT NULL,
   turn_status_               IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
IS
   aircraft_status_           VARCHAR2(50) := turn_status_;
   output_                    av_aircraft_work_package_tab.aircraft_work_package_id%TYPE;
   sched_arrival_time_        TIMESTAMP := fl_sched_arr_time_;
   next_sched_departure_time_ TIMESTAMP := fl_next_sched_depart_time_;
   actual_arrival_time_       TIMESTAMP := fl_actual_arr_time_;
      
   CURSOR get_work_pack_id_in_ar_dep IS --FOR inbound and arrived with departure
      SELECT aircraft_work_package_id
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_id = aircraft_id_
      AND    sched_start_date_time IS NOT NULL
      AND    sched_arrival_time_ IS NOT NULL
      AND    next_sched_departure_time_ IS NOT NULL
      AND    sched_start_date_time >= sched_arrival_time_
      AND    sched_start_date_time < next_sched_departure_time_
      AND    aircraft_work_package_id  IN(
                                          SELECT wp.aircraft_work_package_id
                                          FROM   av_aircraft_work_package_tab wp, av_maintenance_location_tab ml
                                          WHERE  ml.location_code = wp.location_code
                                          AND    ml.airport_id              = arr_airport_id_)
      ORDER BY sched_start_date_time ASC
      FETCH first 1 ROW ONLY; 
   
   CURSOR get_work_pack_id_in_ar_nodep IS --FOR inbound and arrived without departure
      SELECT aircraft_work_package_id
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_id = aircraft_id_
      AND    sched_start_date_time IS NOT NULL
      AND    sched_arrival_time_ IS NOT NULL
      AND    sched_start_date_time >= sched_arrival_time_
      AND    aircraft_work_package_id  IN(
                                          SELECT wp.aircraft_work_package_id
                                          FROM   av_aircraft_work_package_tab wp, av_maintenance_location_tab ml
                                          WHERE  ml.location_code = wp.location_code
                                          AND    ml.airport_id              = arr_airport_id_)
      ORDER BY sched_start_date_time ASC
      FETCH first 1 ROW ONLY; 
      
   CURSOR get_work_pack_id_mn IS --FOR maintenance
      SELECT aircraft_work_package_id
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_id = aircraft_id_ 
      AND    actual_start_date_time IS NOT NULL
      AND    aircraft_work_package_id IN (
                                          SELECT wp.aircraft_work_package_id
                                          FROM   av_aircraft_work_package_tab wp, av_maintenance_location_tab ml
                                          WHERE  ml.location_code = wp.location_code
                                          AND    ml.airport_id              = arr_airport_id_)
      ORDER BY actual_start_date_time DESC
      FETCH first 1 ROW ONLY; 
   
   CURSOR get_work_pack_id_rl IS --FOR released and outbound
      SELECT aircraft_work_package_id
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_id = aircraft_id_ 
      AND    actual_end_date_time IS NOT NULL
      AND    sched_end_date_time IS NOT NULL
      AND    sched_arrival_time_ IS NOT NULL
      AND    sched_end_date_time > sched_arrival_time_
      AND    aircraft_work_package_id IN (
                                          SELECT wp.aircraft_work_package_id
                                          FROM   av_aircraft_work_package_tab wp, av_maintenance_location_tab ml
                                          WHERE  ml.location_code = wp.location_code
                                          AND    ml.airport_id              = arr_airport_id_)
      ORDER BY actual_end_date_time DESC
      FETCH first 1 ROW ONLY; 
   
BEGIN
   IF(sched_arrival_time_ IS NULL ) THEN 
      sched_arrival_time_        := Av_Flight_API.Get_Shed_Arrival_Date_Time(flight_id_);
   END IF;
   IF ( next_sched_departure_time_ IS  NULL) THEN 
      next_sched_departure_time_ := Av_Flight_API.Get_Departure_Timestamp(aircraft_id_, arr_airport_id_, sched_arrival_time_);
   END IF;
   IF (actual_arrival_time_ IS NULL) THEN 
      actual_arrival_time_       := Av_Flight_API.Get_Actual_Arrival_Date_Time(flight_id_);
   END IF;
   IF (aircraft_status_ IS NULL ) THEN 
      aircraft_status_           := Av_Flight_API.Get_Turn_Status(flight_id_);
   END IF;
   
   IF (aircraft_status_ = 'Inbound' OR aircraft_status_ = 'Arrived') THEN 
      IF (next_sched_departure_time_ IS NOT NULL) THEN 
         OPEN  get_work_pack_id_in_ar_dep;                                                               
         FETCH get_work_pack_id_in_ar_dep INTO output_;
         CLOSE get_work_pack_id_in_ar_dep;  
      ELSE 
         OPEN  get_work_pack_id_in_ar_nodep;                                                               
         FETCH get_work_pack_id_in_ar_nodep INTO output_;
         CLOSE get_work_pack_id_in_ar_nodep; 
      END IF;
   ELSIF (aircraft_status_ = 'InMaintenance') THEN
      OPEN  get_work_pack_id_mn;                                                               
      FETCH get_work_pack_id_mn INTO output_;
      CLOSE get_work_pack_id_mn; 
   ELSIF (aircraft_status_ = 'Released' OR aircraft_status_ = 'Departed') THEN
      OPEN  get_work_pack_id_rl;                                                               
      FETCH get_work_pack_id_rl INTO output_;
      CLOSE get_work_pack_id_rl; 
   END IF;
   RETURN output_;
END Get_Work_Package_Id;

FUNCTION Get_Func_Scheduled_Start (
   aircraft_id_     IN NUMBER,
   arr_airport_id_  IN NUMBER,
   flight_id_       IN NUMBER) RETURN TIMESTAMP
IS
   work_package_id_  NUMBER;
   sched_start_date_ TIMESTAMP;
   
BEGIN
   work_package_id_  := Av_Aircraft_Work_Package_API.Get_Work_Package_Id(aircraft_id_,arr_airport_id_,flight_id_);
   sched_start_date_ := Av_Aircraft_Work_Package_API.Get_Sched_Start_Date_Time(work_package_id_);
   RETURN sched_start_date_;
END Get_Func_Scheduled_Start;


FUNCTION Get_Func_Scheduled_End (
   aircraft_id_     IN NUMBER,
   arr_airport_id_  IN NUMBER,
   flight_id_       IN NUMBER) RETURN TIMESTAMP
IS
   work_package_id_  NUMBER;
   sched_end_date_ TIMESTAMP;
   
BEGIN
   work_package_id_  := Av_Aircraft_Work_Package_API.Get_Work_Package_Id(aircraft_id_,arr_airport_id_,flight_id_);
   sched_end_date_   := Av_Aircraft_Work_Package_API.Get_Sched_End_Date_Time(work_package_id_);
   
   RETURN sched_end_date_;
END Get_Func_Scheduled_End;

@UncheckedAccess
FUNCTION Get_Duration (
   aircraft_id_          IN NUMBER,
   arr_airport_id_       IN NUMBER,
   flight_id_            IN VARCHAR2,
   turn_status_parm_     IN VARCHAR2 DEFAULT NULL,
   work_package_id_parm_ IN NUMBER DEFAULT NULL) RETURN VARCHAR2
IS
   work_package_id_      NUMBER :=work_package_id_parm_;
   time_dif_             NUMBER;
   minutes_dif_          NUMBER;
   hours_dif_            NUMBER;
   duration_             VARCHAR2(20);
   sched_start_time_     TIMESTAMP;
   sched_end_time_       TIMESTAMP;
   actual_start_time_    TIMESTAMP;
   actual_end_time_      TIMESTAMP;
   aircraft_status_      VARCHAR2(50):= turn_status_parm_;
      
   CURSOR get_time_in_ar IS --for inbound
      SELECT (EXTRACT(DAY FROM sched_end_time_-sched_start_time_)*24*60)+
             (EXTRACT(HOUR FROM sched_end_time_-sched_start_time_)*60)+
             (EXTRACT(MINUTE FROM sched_end_time_-sched_start_time_))
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_work_package_id = work_package_id_;
      
   CURSOR get_time_mn IS --FOR maintenance
      SELECT (EXTRACT(DAY FROM sched_end_time_-actual_start_time_)*24*60)+
             (EXTRACT(HOUR FROM sched_end_time_-actual_start_time_)*60)+
             (EXTRACT(MINUTE FROM sched_end_time_-actual_start_time_))
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_work_package_id = work_package_id_;
   
   CURSOR get_time_rl IS --FOR release
      SELECT (EXTRACT(DAY FROM actual_end_time_-actual_start_time_)*24*60)+
             (EXTRACT(HOUR FROM actual_end_time_-actual_start_time_)*60)+
             (EXTRACT(MINUTE FROM actual_end_time_-actual_start_time_))
      FROM   av_aircraft_work_package_tab
      WHERE  aircraft_work_package_id = work_package_id_;
   
BEGIN
   IF (aircraft_status_ IS NULL) THEN
      aircraft_status_   := Av_Flight_API.Get_Turn_Status(flight_id_);
   END IF;
   IF(work_package_id_ IS NULL) THEN
      work_package_id_   := Get_Work_Package_Id(aircraft_id_,arr_airport_id_,flight_id_);
   END IF;
   sched_start_time_  := Get_Sched_Start_Date_Time(work_package_id_);
   sched_end_time_    := Get_Sched_End_Date_Time(work_package_id_);
   actual_start_time_ := Get_Actual_Start_Date_Time(work_package_id_);
   actual_end_time_   := Get_Actual_End_Date_Time(work_package_id_);

   IF (aircraft_status_ = 'Inbound' OR aircraft_status_ = 'Arrived') THEN 
      OPEN  get_time_in_ar;                                                               
      FETCH get_time_in_ar INTO time_dif_;
      CLOSE get_time_in_ar;                                                                     
   ELSIF (aircraft_status_ = 'InMaintenance') THEN
      OPEN  get_time_mn;                                                               
      FETCH get_time_mn INTO time_dif_;
      CLOSE get_time_mn; 
   ELSIF (aircraft_status_ = 'Released' OR aircraft_status_ = 'Departed') THEN
      OPEN  get_time_rl;                                                               
      FETCH get_time_rl INTO time_dif_;
      CLOSE get_time_rl; 
   END IF;
   
   hours_dif_   := FLOOR (time_dif_ / 60);
   minutes_dif_ := (time_dif_ mod 60);
   
   IF minutes_dif_    < 10 AND hours_dif_   > 10 THEN
      duration_ := CONCAT(CONCAT(hours_dif_, ':0'), minutes_dif_);
   ELSIF hours_dif_   < 10 AND minutes_dif_ > 10 THEN
      duration_ := CONCAT(CONCAT(CONCAT('0',hours_dif_), ':'), minutes_dif_);
   ELSIF minutes_dif_ < 10 AND hours_dif_   < 10 THEN
      duration_ := CONCAT(CONCAT(CONCAT('0',hours_dif_), ':0'), minutes_dif_);
   ELSE
      duration_ := CONCAT(CONCAT(hours_dif_, ':'), minutes_dif_);
   END IF;
   
   RETURN duration_;
END Get_Duration;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_aircraft_work_package_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

/*
   This procedure will fetch the objid and objversion using the barcode (unique)
   and update the mx_unique_key of the record.
*/

PROCEDURE Get_Id_Version_By_Natural_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   barcode_       IN  VARCHAR2) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_aircraft_work_package_tab
   WHERE barcode = barcode_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Natural_Key;



PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   aircraft_unique_key_        aircraft_tab.mx_unique_key%TYPE;
   aircraft_id_                aircraft_tab.aircraft_id%TYPE;
   barcode_                    VARCHAR2(80);
   
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  mx_unique_key = aircraft_unique_key_;
      
BEGIN
   local_attr_ := attr_;

   IF Client_SYS.Item_Exist('BARCODE', local_attr_) THEN
      barcode_ := Client_SYS.Get_Item_Value('BARCODE', local_attr_);          
      Client_SYS.Add_To_Attr('NATURAL_KEY', barcode_, local_attr_);
   END IF;
      
   IF Client_SYS.Item_Exist('AIRCRAFT_UNIQUE_KEY', local_attr_) THEN
      aircraft_unique_key_ := Client_SYS.Get_Item_Value('AIRCRAFT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_aircraft_id;
      FETCH get_aircraft_id INTO aircraft_id_;
      CLOSE get_aircraft_id;
      
      IF aircraft_unique_key_ IS NOT NULL AND aircraft_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'AIRCRAFTSYNCERR: Could not find the indicated Aircraft :P1', aircraft_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('AIRCRAFT_ID', aircraft_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('AIRCRAFT_UNIQUE_KEY',  local_attr_);
   END IF;
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(4000);
   current_rowstate_        av_aircraft_work_package_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   aircraft_wp_rec_         av_aircraft_work_package_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50)    := 'ROWSTATE';
BEGIN
   local_attr_ := attr_;
   
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   aircraft_wp_rec_   := Get_Object_By_Id___(objid_);
   current_rowstate_  := Get_Objstate(aircraft_wp_rec_.aircraft_work_package_id);
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
END Post_Sync_Action;


PROCEDURE Update_Status (
   wp_id_         IN NUMBER,
   status_        IN VARCHAR2)
 IS
   -- Params required to modify the work package record
   info_          VARCHAR2(32000);
   attr_          VARCHAR2(32000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
 BEGIN
   -- Modify the work package entity
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('ROWSTATE', status_, attr_);
   Get_Id_Version_By_Keys___(objid_, objversion_, wp_id_);
   -- This method is called only only when the WP is either in 'Active' or 'Committed' state
   -- Before Commit_Work_Package__, checking if the WP's state is in the "Active" state so that it obeys the AvAircraftWorkPackage's state machine
   IF(Av_Aircraft_Work_Package_API.Get_Objstate(wp_id_) = 'Active') THEN
      Commit_Work_Package__(info_, objid_, objversion_, attr_, 'DO');
   END IF;
   Start_Work_Package__(info_, objid_, objversion_, attr_, 'DO');
END Update_Status;


FUNCTION Get_Flight_Id (
   wp_id_   IN NUMBER
   ) RETURN NUMBER
   
IS
   flight_id_       NUMBER;
   aircraft_id_     NUMBER;
   airport_id_      NUMBER;
   scheduled_start_ TIMESTAMP;
   scheduled_end_   TIMESTAMP;
   CURSOR get_flight_id IS
      SELECT flight_id
      FROM av_flight_tab f
      WHERE f.arrival_airport_id = airport_id_ AND f.aircraft_id = aircraft_id_ 
      AND f.shed_arrival_date_time <= scheduled_start_ 
      ORDER BY shed_arrival_date_time DESC
      FETCH first 1 ROW ONLY;
BEGIN
   aircraft_id_ := Av_Aircraft_Work_Package_API.Get_Aircraft_Id(wp_id_);
   airport_id_  := Av_Maintenance_Location_API.Get_Airport_Id(Av_Aircraft_Work_Package_API.Get_Location_Code(wp_id_));
   scheduled_start_ := Av_Aircraft_Work_Package_API.Get_Sched_Start_Date_Time(wp_id_);
   scheduled_end_ := Av_Aircraft_Work_Package_API.Get_Sched_End_Date_Time(wp_id_);
   
   OPEN get_flight_id;
   FETCH get_flight_id INTO flight_id_;
   CLOSE get_flight_id;
   
   RETURN flight_id_;
END Get_Flight_Id;

@UncheckedAccess
FUNCTION Get_Func_Actual_Start (
   aircraft_id_     IN NUMBER,
   arr_airport_id_  IN NUMBER,
   flight_id_       IN NUMBER) RETURN TIMESTAMP
IS
   work_package_id_  NUMBER;
   sched_start_date_ TIMESTAMP;
   
BEGIN
   work_package_id_  := Av_Aircraft_Work_Package_API.Get_Work_Package_Id(aircraft_id_,arr_airport_id_,flight_id_);
   sched_start_date_ := Av_Aircraft_Work_Package_API.Get_Actual_Start_Date_Time(work_package_id_);
   RETURN sched_start_date_;
END Get_Func_Actual_Start;

@UncheckedAccess
FUNCTION Get_Func_Actual_End (
   aircraft_id_     IN NUMBER,
   arr_airport_id_  IN NUMBER,
   flight_id_       IN NUMBER) RETURN TIMESTAMP
IS
   work_package_id_  NUMBER;
   sched_end_date_ TIMESTAMP;
   
BEGIN
   work_package_id_  := Av_Aircraft_Work_Package_API.Get_Work_Package_Id(aircraft_id_,arr_airport_id_,flight_id_);
   sched_end_date_   := Av_Aircraft_Work_Package_API.Get_Actual_End_Date_Time(work_package_id_);
   
   RETURN sched_end_date_;
END Get_Func_Actual_End;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_work_package_tab.aircraft_work_package_id%TYPE;
   
   CURSOR get_aircraft_work_package_id IS 
      SELECT aircraft_work_package_id         
      FROM av_aircraft_work_package_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_aircraft_work_package_id;
   FETCH get_aircraft_work_package_id INTO temp_; 
   CLOSE get_aircraft_work_package_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Aircraft_By_Unique_Key (
   ac_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ aircraft_tab.aircraft_id%TYPE;
   
   CURSOR get_aircraft_id IS 
      SELECT aircraft_id         
      FROM aircraft_tab
      WHERE mx_unique_key = ac_unique_key_;
BEGIN
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO temp_; 
   CLOSE get_aircraft_id;
   
   RETURN temp_;
END Get_Aircraft_By_Unique_Key;

-- This procedure will be used to set the work package state from the Migration Job 068_FLM_AIRCRAFT_WP
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_    IN VARCHAR2,
   state_            IN VARCHAR2)
IS
   work_package_id_  av_aircraft_work_package_tab.aircraft_work_package_id%TYPE;
   objid_            av_aircraft_work_package.objid%TYPE;
   objversion_       av_aircraft_work_package.objversion%TYPE;
   from_state_       av_aircraft_work_package_tab.rowstate%TYPE;
BEGIN
   work_package_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(work_package_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, work_package_id_);
      from_state_      := Get_Objstate(work_package_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;

/*
   Update barcode returns from the package fault response
*/
PROCEDURE Update_Barcode (
   wp_id_   IN NUMBER,
   barcode_ IN VARCHAR2)
   
 IS
   -- Params required to modify the work package record
   info_       VARCHAR2(32000);
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   
 BEGIN
   -- Modify the work package entity
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('BARCODE', barcode_, attr_);  
   Get_Id_Version_By_Keys___(objid_, objversion_, wp_id_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
   Update_Work_Package(wp_id_,barcode_);
END Update_Barcode;

FUNCTION Get_Av_Work_Package_id(
   fault_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(150);
  
   CURSOR get_wo_package_id IS
      SELECT av.aircraft_work_package_id
      FROM   av_exe_task_tab a, av_aircraft_work_package_tab av
      WHERE  a.aircraft_wp_id = av.aircraft_work_package_id
      AND    a.fault_id      = fault_id_;
      
BEGIN
   OPEN  get_wo_package_id;
   FETCH get_wo_package_id INTO output_;
   CLOSE get_wo_package_id;
   
   RETURN output_;
END Get_Av_Work_Package_id;



/*
   Complete a work package using the aircraft_work_package_id.
*/
PROCEDURE Complete_WP (
   wp_id_   IN NUMBER)
 IS

   -- Params required for the HTTP request
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      url_parameters_         Mx_Connect_Util_API.url_param_;
      header_parameters_      Mx_Connect_Util_API.header_param_;
      query_parameters_       Mx_Connect_Util_API.query_param_;
   $END
   wp_alt_id_        VARCHAR2(50);
   payload_          CLOB;
   error_msg_        VARCHAR2(2000);
   
   -- Params required for the request spec
   rest_service_     VARCHAR2(50) := 'MX_COMPLETE_WP';
   http_method_      VARCHAR2(10) := 'PUT';
   
   -- Get task alt_id from task.
   CURSOR get_alt_id (wp_id_ IN NUMBER) IS 
      SELECT alt_id
      FROM av_aircraft_work_package_tab
      WHERE aircraft_work_package_id = wp_id_;
BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      OPEN get_alt_id(wp_id_);
      FETCH get_alt_id INTO wp_alt_id_;
      CLOSE get_alt_id;
      
      payload_ := Build_Complete_WP_Body();
      
      url_parameters_('wpid') := wp_alt_id_;
      
      -- Call REST endpoint
      Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                               payload_,
                                               http_method_,
                                               '200,400',
                                               url_parameters_,
                                               header_parameters_,
                                               query_parameters_);
      
      error_msg_ := Get_Complete_WP_Error(payload_);
      
      IF (error_msg_ != 'SUCCESS') THEN
         Error_SYS.Record_General(lu_name_, error_msg_);
      END IF;
   $ELSE
      NULL;
   $END
END Complete_WP;


/*
   Build the request body of the complete work package request.
*/
FUNCTION Build_Complete_WP_Body RETURN VARCHAR2
IS
   request_jo_    JSON_OBJECT_T;
BEGIN
   request_jo_ := JSON_OBJECT_T.parse('{}');
   request_jo_.put ('status', 'COMPLETE');
   
   RETURN request_jo_.to_string;
END Build_Complete_WP_Body;


/*
   Error handling for publish part request.
*/
FUNCTION Get_Complete_WP_Error (
   payload_              IN VARCHAR2) RETURN VARCHAR2
IS
   response_jo_         JSON_OBJECT_T;
   error_msg_           VARCHAR2(2000);
BEGIN
   BEGIN
      response_jo_ := JSON_OBJECT_T(payload_);
      error_msg_ := response_jo_.get_String('message');

      -- Identify success response from the 'id' param in the body.
      IF ( response_jo_.get_String('id') IS NOT NULL) THEN
         RETURN 'SUCCESS';

      -- Identify error response from the 'message' param in the body.
      ELSIF ( error_msg_ IS NOT NULL ) THEN
         RETURN 'MXCOMWPERR: Maintenix complete work package failed with error - ' || error_msg_;

      -- Unidentified errors.
      ELSE
         RETURN 'MXUNIDERR: Unidentified error in response. Payload - ' || payload_;
      END IF;
   EXCEPTION WHEN OTHERS THEN
      
      -- Unexpected error in the response body.
      Error_SYS.Record_General(lu_name_, 'MXUNEXPECTEDERR: Unexpected Response Error, Response Body - :P1', dbms_lob.substr( payload_, 1500, 1 ));
   END;
END Get_Complete_WP_Error;


/*
   Change the state of the entity.
*/
PROCEDURE Change_State(
   wp_id_      IN NUMBER,
   objstate_   IN VARCHAR2)
IS
   rec_        av_aircraft_work_package_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(wp_id_);
   Finite_State_Set___(rec_, objstate_);
END Change_State;


/*
   Update barcode returns from the package fault response
*/
PROCEDURE Update_Actual_End_Date_Time (
   wp_id_   IN NUMBER)
IS
   
   -- Params required to modify the work package record
   info_       VARCHAR2(32000);
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   
   -- Modify the work package entity
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('ACTUAL_END_DATE_TIME', sysdate, attr_);
   Get_Id_Version_By_Keys___(objid_, objversion_, wp_id_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
END Update_Actual_End_Date_Time;



/*
Update barcode returns from the package fault response and
merge if there are duplicate records in wp entity for same barcode
*/
PROCEDURE Update_Work_Package (
   wp_id_   IN NUMBER,
   barcode_ IN VARCHAR2)
   
IS
   -- Params required to modify the work package record
   info_          VARCHAR2(32000);
   attr_          VARCHAR2(32000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000); 
   record_count_  NUMBER;
   wo_number_     VARCHAR2(80);
   mx_unique_key_ VARCHAR2(100);
   alt_id_        VARCHAR2(50);
   synced_wp_id_  NUMBER;
   
   CURSOR get_record_count IS
      SELECT COUNT(barcode)
      FROM av_aircraft_work_package_tab
      WHERE barcode = barcode_;
   
   CURSOR get_synced_rec IS
      SELECT aircraft_work_package_id, wo_number, mx_unique_key, alt_id
      FROM av_aircraft_work_package_tab
      WHERE barcode = barcode_ AND mx_unique_key IS NOT NULL;
   
   
BEGIN
   
   OPEN get_record_count;
   FETCH get_record_count INTO record_count_;
   CLOSE get_record_count;
   
   -- Check whether more than one record exist for same barcode
   -- There can be maximum two records. one created from API and another record
   -- can be synced back from related sync job
   IF record_count_ > 1 THEN
      OPEN get_synced_rec;
      FETCH get_synced_rec INTO synced_wp_id_, wo_number_, mx_unique_key_, alt_id_;
      CLOSE get_synced_rec;
      
      -- Delete the synced record after merging data to a single rec
      Delete_Duplicate_Rec(synced_wp_id_);
      
      -- Merge synced record info to the wp record created from app when package fault
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('WO_NUMBER', wo_number_, attr_);
      Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
      Client_SYS.Add_To_Attr('ALT_ID', alt_id_, attr_);
      Get_Id_Version_By_Keys___(objid_, objversion_, wp_id_);
      Modify__(info_, objid_, objversion_, attr_, 'DO'); 
      
   END IF;
END Update_Work_Package;


/*
Delete the duplicated wp record
*/
PROCEDURE Delete_Duplicate_Rec (
   av_aircraft_wp_id_ IN NUMBER)
IS
   objid_ VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_aircraft_work_package_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,av_aircraft_wp_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Delete_Duplicate_Rec;

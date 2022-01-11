-----------------------------------------------------------------------------
--
--  Logical unit: AvFlight
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210407  siselk  AD-1026, Modifications to Get_Ground_Time
--  210312  siydlk  LMM2020R1-1788, Modified Ground_time___ function to address all the possible conditions to make proper format for ground time. 
--  210304  majslk  LMM2020R1-1665, Added Override Insert__, Update__, Update_Inbound_Flight_For_Native___.
--  210302  majslk  LMM2020R1-1665, Added Update_Rowversion_For_Native method.
--  210302  HasRlk  LMM2020R1-1746, Added new items to the state machine and updated Sync_State_Handle___.
--  210301  SWiclk  AD2020R1-1538, Annotated Get_Arrival_Offset_Time(), Get_Departure_Offset_Time(), Get_Departure_Flight_Id(),
--  210301          Get_Departure_Leg_No(), Get_Split_Time(), Get_Ground_Time(), Get_Opened_Faults_Count() with UncheckedAcces.
--  210225  CSarLK  LMM2020R1-1708, refactored Get_Ground_time
--  210225  islilk  LMM2020R1-1561, Removed overriding Check_Common method since it causes sync to fail
--  210224  tprelk  LMM2020R1-1569, Added Get_Departure_Leg_No to get legno for particular flight id
--  210223  siselk  LMM2020R1-1744, Removed Get_Departure_Flight, updated Get_Departure_Timestamp, Get_Ground_Time
--  210215  UPIWLK  LMM2020R1-1613  Added Has_Logbook_Fault function and override the Check_Delete___ procedure
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 065_FLM_FLIGHT when setting the rowstate.
--  210205  aruflk  LMM2020R1-1475, Modified Get_Turn_Status().
--  201215  supklk  LMM2020R1-1127, Implemented functions to fetch required keys in data migration
--  201215  supklk  LMM2020R1-1127, Implemented Get_Key_By_Mx_Unique_Key and Modified Check_Insert___ to handle duplications in data migration
--  201014  KAWJLK  LMM2020R1-1351, Missing Unchecked Access Annotation to GET_TURN_STATUS.
--  201006  lahnlk  LMM2020R1-427,  Modified Get_Closed_Faults_Count,added Get_Arrival_Offset_Time and Get_Departure_Offset_Time
--  200913  dildlk  LMM2020R1-311, Modified sSync_State_Handle___ method.
--  200818  dildlk  LMM2020R1-311, Modified Flight related sync methods.
--  200806  sevhlk  LMM2020R1-220, Added Get_Id_Version_By_Mx_Uniq_Key for syncing
--  200805  dildlk  LMM2020R1-311, Added Flight related sync methods.
--  200710  rosdlk  LMM2020R1-306, Added functions to get total record count open, deferred, closed faults
--  200710  rosdlk  LMM2020R1-306, Added Get_Assigned_Task_Count to get total record count of work tasks
--  200701  majslk  LMM2020R1-290, Added Get_Departure_Flight_Id and modified Get_Ground_Time
--  200701  SISELK  LMM2020R1-167, Modified Get_Arrival_Timestamp and Get_Departure_Timestamp
--  200701  TAJALK  LMM2020R1-252, Changes
--  200629  Tajalk  LMM2020R1-208, Added Get_Turn_Status
--  200617  SISELK  Added GetDepartureFlight
--  200612  majslk  Created
--  200619  spatlk  Added PrepareInsert
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT Av_Flight_Tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_flight_seq.NEXTVAL
      FROM dual;
BEGIN
   IF(newrec_.flight_id IS NULL) THEN
      OPEN get_key_set;
      FETCH get_key_set INTO newrec_.flight_id;
      CLOSE get_key_set;
   END IF;
   
   super(newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_flight_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   
   Update_Inbound_Flight_For_Native___(newrec_.aircraft_id, newrec_.departure_airport_id, newrec_.shed_departure_date_time);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_flight_tab%ROWTYPE,
   newrec_     IN OUT av_flight_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);  
   
   Update_Inbound_Flight_For_Native___(newrec_.aircraft_id, newrec_.departure_airport_id, newrec_.shed_departure_date_time);
END Update___;

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
   IF (current_rowstate_ = 'Planned'    AND incoming_rowstate_ = 'MXPLAN')    OR
      (current_rowstate_ = 'Out' AND incoming_rowstate_        = 'MXOUT')     OR
      (current_rowstate_ = 'Canceled'  AND incoming_rowstate_  = 'MXCANCEL')  OR
      (current_rowstate_ = 'On'    AND incoming_rowstate_      = 'MXON')      OR
      (current_rowstate_ = 'Off'    AND incoming_rowstate_     = 'MXOFF')     OR
      (current_rowstate_ = 'In'    AND incoming_rowstate_      = 'MXIN')      OR
      (current_rowstate_ = 'Completed' AND incoming_rowstate_  = 'MXCMPLT') THEN    
      RETURN;
   END IF;
   
   IF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXOUT' THEN
      Start__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXCANCEL' THEN
      Cancel_Flight__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXON' THEN
      Planned_To_On__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXOFF' THEN
      Planned_To_Off__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXIN' THEN
      Planned_To_In__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Planned' AND incoming_rowstate_ = 'MXCMPLT' THEN
      Planned_To_Completed__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Out' AND incoming_rowstate_ = 'MXCANCEL' THEN
      Out_To_Canceled__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'Out' AND incoming_rowstate_ = 'MXON' THEN
      Out_To_On__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Out' AND incoming_rowstate_ = 'MXOFF' THEN
      Take_Off_Aircraft__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Out' AND incoming_rowstate_ = 'MXIN' THEN
      Out_To_In__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Out' AND incoming_rowstate_ = 'MXCMPLT' THEN
      Out_To_Completed__(info_, objid_, objversion_, state_attr_, action_);  
      
   ELSIF current_rowstate_ = 'On' AND incoming_rowstate_ = 'MXIN' THEN
      Arrived_At_Gate__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'On' AND incoming_rowstate_ = 'MXCMPLT' THEN
      On_To_Completed__(info_, objid_, objversion_, state_attr_, action_); 
      
   ELSIF current_rowstate_ = 'On' AND incoming_rowstate_ = 'MXCANCEL' THEN
      On_To_Canceled__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'Off' AND incoming_rowstate_ = 'MXON' THEN
      Land_Aircraft__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'Off' AND incoming_rowstate_ = 'MXIN' THEN
      Off_To_In__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Off' AND incoming_rowstate_ = 'MXCMPLT' THEN
      Off_To_Completed__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Off' AND incoming_rowstate_ = 'MXCANCEL' THEN
      Off_To_Canceled__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'In' AND incoming_rowstate_ = 'MXCMPLT' THEN
      Complete__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'In' AND incoming_rowstate_ = 'MXCANCEL' THEN
      In_To_Canceled__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDFLIGHTSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);
      
   END IF;
END Sync_State_Handle___;

--Updating av_flight_tab for inbound flight. Default update___ method not used because of recursion which will cause an infinite loop
PROCEDURE Update_Inbound_Flight_For_Native___(
   aircraft_id_              IN NUMBER,
   departure_airport_id_     IN NUMBER,
   shed_departure_date_time_ IN TIMESTAMP) 
IS 
   rowkey_   VARCHAR2(100);
   
   CURSOR get_rowid IS
      SELECT rowkey 
      FROM Av_Flight_Tab
      WHERE flight_id = ( SELECT flight_id
                          FROM   av_flight_tab
                          WHERE  aircraft_id            = aircraft_id_
                          AND    arrival_airport_id     = departure_airport_id_
                          AND    shed_arrival_date_time < shed_departure_date_time_
                          ORDER BY shed_arrival_date_time DESC
                          FETCH first 1 ROW ONLY );
   
BEGIN
   OPEN  get_rowid;
   FETCH get_rowid INTO rowkey_;
   CLOSE get_rowid;
   
   IF rowkey_ IS NOT NULL THEN
      UPDATE Av_flight_tab
      SET rowversion = TO_DATE(sysdate, 'yyyy-mm-dd HH:MI:SS')
      WHERE rowkey = rowkey_;
   END IF;
END Update_Inbound_Flight_For_Native___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

FUNCTION Ground_time___ (
   flight_id_      IN NUMBER,
   arrival_time_   IN TIMESTAMP,
   departure_time_ IN TIMESTAMP) RETURN VARCHAR2
IS
   time_dif_       NUMBER;
   hours_dif_      NUMBER;
   minutes_dif_    NUMBER;
   ground_time_    VARCHAR2(20) := ':';
   
   CURSOR get_time IS
      SELECT (EXTRACT(DAY FROM departure_time_-arrival_time_)*24*60)+
             (EXTRACT(HOUR FROM departure_time_-arrival_time_)*60)+
             (EXTRACT(MINUTE FROM departure_time_-arrival_time_))
      FROM   av_flight_tab
      WHERE  flight_id = flight_id_;
   
BEGIN
   OPEN  get_time;
   FETCH get_time INTO time_dif_;
   CLOSE get_time;
   
   hours_dif_   := FLOOR (time_dif_ / 60);
   minutes_dif_ := (time_dif_ mod 60);
   ground_time_ := TO_CHAR(hours_dif_,'00')||':'||TO_CHAR(minutes_dif_,'00'); 
   IF ground_time_ = ':' THEN
      RETURN 'N/A';
   ELSE 
      RETURN ground_time_;
   END IF;
END Ground_time___;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Departure_Flight_State(
   aircraft_id_    IN NUMBER,
   arr_airport_id_ IN NUMBER,
   shed_arr_time_  IN TIMESTAMP) RETURN VARCHAR2
IS
   output_ av_flight_tab.rowstate%TYPE;
   
   CURSOR get_flight IS
      SELECT   rowstate
      FROM     av_flight_tab
      WHERE    aircraft_id              = aircraft_id_
      AND      departure_airport_id     = arr_airport_id_
      AND      shed_departure_date_time > shed_arr_time_
      ORDER BY shed_departure_date_time ASC
      FETCH    first 1 ROW ONLY; 
BEGIN
   OPEN  get_flight;
   FETCH get_flight INTO output_;
   CLOSE get_flight;
   
   RETURN output_;
END Get_Departure_Flight_State;

FUNCTION Get_Departure_Gate(
   aircraft_id_    IN NUMBER,
   arr_airport_id_ IN NUMBER,
   shed_arr_time_  IN TIMESTAMP) RETURN VARCHAR2
IS
   output_ av_flight_tab.departure_gate%TYPE;
   
   CURSOR get_flight IS
      SELECT   departure_gate
      FROM     av_flight_tab
      WHERE    aircraft_id              = aircraft_id_
      AND      departure_airport_id     = arr_airport_id_
      AND      shed_departure_date_time > shed_arr_time_
      ORDER BY shed_departure_date_time ASC
      FETCH    first 1 ROW ONLY; 
BEGIN
   OPEN  get_flight;
   FETCH get_flight INTO output_;
   CLOSE get_flight;
   
   RETURN output_;
END Get_Departure_Gate;

FUNCTION Get_Arrival_Timestamp(
   flight_id_ IN NUMBER) RETURN TIMESTAMP
IS
   turn_status_   VARCHAR2(50);
   arrival_time_  TIMESTAMP;
   
BEGIN
   turn_status_      := Av_Flight_API.Get_Turn_Status(flight_id_);
   IF (turn_status_ = 'Inbound') THEN 
      arrival_time_  := Av_Flight_API.Get_Shed_Arrival_Date_Time(flight_id_);
   ELSE 
      arrival_time_  := Av_Flight_API.Get_Actual_Arrival_Date_Time(flight_id_);
   END IF;
   
   RETURN arrival_time_;
END Get_Arrival_Timestamp;

@UncheckedAccess
FUNCTION Get_Departure_Timestamp(
   aircraft_id_    IN NUMBER,
   arr_airport_id_ IN NUMBER,
   shed_arr_time_  IN TIMESTAMP) RETURN TIMESTAMP
IS
   flight_id_       av_flight_tab.flight_id%TYPE;
   leg_no_          av_flight_tab.leg_no%TYPE;
   turn_status_     VARCHAR2(50);
   departure_time_  TIMESTAMP;
   
BEGIN
   flight_id_     := Av_Flight_API.Get_Departure_Flight_Id(aircraft_id_, arr_airport_id_, shed_arr_time_);
   turn_status_   := Av_Flight_API.Get_Turn_Status(flight_id_);
   
   IF (turn_status_ = 'Departed') THEN 
      departure_time_  := Av_Flight_API.Get_Actual_Departure_Date_Time(flight_id_);
   ELSE 
      departure_time_  := Av_Flight_API.Get_Shed_Departure_Date_Time(flight_id_);
   END IF;
   
   RETURN departure_time_;
END Get_Departure_Timestamp;

@UncheckedAccess
FUNCTION Get_Ground_Time(
   flight_id_      NUMBER,
   aircraft_id_    NUMBER,
   arr_airport_id_ NUMBER,
   shed_arr_time_  TIMESTAMP) RETURN VARCHAR2
IS
   departure_time_   TIMESTAMP;
   arrival_time_     TIMESTAMP;
   departure_flight_ NUMBER;
   
   CURSOR get_arrival IS
      SELECT actual_arrival_date_time
      FROM   av_flight_tab 
      WHERE  flight_id = flight_id_;
   
   CURSOR get_departure IS
      SELECT actual_departure_date_time
      FROM   av_flight_tab 
      WHERE  flight_id = departure_flight_;
   
BEGIN
   departure_flight_ := Av_Flight_API.Get_Departure_Flight_Id(aircraft_id_, arr_airport_id_, shed_arr_time_);
   
   OPEN  get_arrival;
   FETCH get_arrival INTO arrival_time_;
   CLOSE get_arrival;
   
   OPEN  get_departure;
   FETCH get_departure INTO departure_time_;
   CLOSE get_departure;
   
   RETURN Ground_time___(flight_id_,
                         arrival_time_,
                         departure_time_);
END Get_Ground_Time;

@UncheckedAccess
FUNCTION Get_Ground_Time(
   flight_id_        NUMBER,
   arrival_time_     TIMESTAMP,
   departure_time_   TIMESTAMP) RETURN VARCHAR2
IS
   
BEGIN
   
   RETURN Ground_time___(flight_id_,
                         arrival_time_,
                         departure_time_);
END Get_Ground_Time;

@UncheckedAccess
FUNCTION Get_Split_Time(
   time_  TIMESTAMP) RETURN VARCHAR2
IS
   output_ VARCHAR2(15);
   
   CURSOR get_time IS
      SELECT to_char(time_, 'HH24:MI')
      FROM   av_flight_tab;
   
BEGIN
   OPEN  get_time;
   FETCH get_time INTO output_;
   CLOSE get_time;
   
   RETURN output_;
END Get_Split_Time;

@UncheckedAccess
FUNCTION Get_Turn_Status(
   flight_id_ IN NUMBER) RETURN VARCHAR2
IS
   departure_flight_status_    av_flight_tab.rowstate%TYPE;
   work_pkg_status_            av_aircraft_work_package_tab.rowstate%TYPE;
   turn_status_                VARCHAR2(20);
   flight_rec_                 Av_Flight_API.Public_Rec;
   
   CURSOR get_departure_flight_status IS
      SELECT rowstate
      FROM   av_flight_tab t
      WHERE  t.aircraft_id               = flight_rec_.aircraft_id
      AND    t.departure_airport_id      = flight_rec_.arrival_airport_id
      AND    t.shed_departure_date_time >= flight_rec_.actual_arrival_date_time
      ORDER BY t.shed_departure_date_time ASC
      FETCH    first 1 ROW ONLY; 
   
   CURSOR get_work_pkg_status IS
      SELECT rowstate
      FROM   av_aircraft_work_package_tab t
      WHERE  t.aircraft_id            = flight_rec_.aircraft_id
      AND    Av_Maintenance_Location_API.Get_Airport_Id(t.location_code) = 
             flight_rec_.arrival_airport_id
      AND    t.sched_start_date_time >= flight_rec_.actual_arrival_date_time
      ORDER BY t.sched_start_date_time ASC
      FETCH    first 1 ROW ONLY;
BEGIN
   flight_rec_    := Av_Flight_API.Get(flight_id_);
   
   IF flight_rec_.rowstate IN ('Planned', 'Out', 'Off', 'On', 'Diverted') THEN
      turn_status_ := 'Inbound';
      
      OPEN  get_work_pkg_status;
      FETCH get_work_pkg_status INTO work_pkg_status_;
      CLOSE get_work_pkg_status;
      IF work_pkg_status_ IS NOT NULL THEN
         IF work_pkg_status_ = 'InWork' THEN
            RETURN 'InMaintenance';
         END IF;
      END IF;
      
      RETURN turn_status_;
      
   ELSIF flight_rec_.rowstate IN ('In', 'Completed', 'Edit', 'Return') THEN
      turn_status_ := 'Arrived';
      
      OPEN  get_departure_flight_status;
      FETCH get_departure_flight_status INTO departure_flight_status_;
      CLOSE get_departure_flight_status;
      
      IF departure_flight_status_ IS NOT NULL AND 
         departure_flight_status_ != 'Planned' THEN
         
         RETURN 'Departed';
      ELSE
         OPEN  get_work_pkg_status;
         FETCH get_work_pkg_status INTO work_pkg_status_;
         CLOSE get_work_pkg_status;
         IF work_pkg_status_ IS NOT NULL THEN
            IF work_pkg_status_ = 'InWork' THEN
               RETURN 'InMaintenance';
            ELSIF work_pkg_status_ = 'Completed' THEN
               RETURN 'Released'; 
            END IF;
         END IF;
      END IF;
      
      RETURN turn_status_;
   END IF;
   
   RETURN 'NotApplicable';
END Get_Turn_Status;

@UncheckedAccess
FUNCTION Get_Departure_Flight_Id(
   aircraft_id_    IN NUMBER,
   arr_airport_id_ IN NUMBER,
   shed_arr_time_  IN TIMESTAMP) RETURN NUMBER
IS
   output_ av_flight_tab.flight_id%TYPE;
   
   CURSOR get_flight IS
      SELECT   flight_id
      FROM     av_flight_tab
      WHERE    aircraft_id              = aircraft_id_
      AND      departure_airport_id     = arr_airport_id_
      AND      shed_departure_date_time > shed_arr_time_
      ORDER BY shed_departure_date_time ASC
      FETCH    first 1 ROW ONLY; 
BEGIN
   OPEN  get_flight;
   FETCH get_flight INTO output_;
   CLOSE get_flight;
   
   RETURN output_;
END Get_Departure_Flight_Id;

@UncheckedAccess
FUNCTION Get_Assigned_Task_Count (
   work_package_id_ IN NUMBER) RETURN NUMBER
IS
   task_count_ NUMBER;  
BEGIN
      SELECT COUNT(task_id)
        INTO  task_count_
        FROM  av_exe_task_tab 
        WHERE aircraft_wp_id = work_package_id_ ;
   RETURN task_count_ ;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;  
END Get_Assigned_Task_Count ;

@UncheckedAccess
FUNCTION Get_Opened_Faults_Count (
   aircraft_id_ IN NUMBER) RETURN NUMBER
IS
   open_faults_count_ NUMBER;  
BEGIN
      SELECT COUNT(fault_id)
        INTO  open_faults_count_
        FROM  av_fault_tab 
        WHERE aircraft_id = aircraft_id_ AND
               rowstate = 'Open'; 
   RETURN open_faults_count_ ;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;
      
END Get_Opened_Faults_Count ;

@UncheckedAccess
FUNCTION Get_Deferred_Faults_Count (
   aircraft_id_ IN NUMBER) RETURN NUMBER
IS
   deferred_faults_count_ NUMBER;  
BEGIN
      SELECT COUNT(fault_id)
        INTO  deferred_faults_count_
        FROM  av_fault_tab 
        WHERE aircraft_id = aircraft_id_ AND
               rowstate = 'Deferred'; 
   RETURN deferred_faults_count_ ;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;
      
END Get_Deferred_Faults_Count ;

@UncheckedAccess
FUNCTION Get_Closed_Faults_Count (
   aircraft_id_        IN NUMBER,
   arrival_airport_id_ IN NUMBER) RETURN NUMBER
IS
   faults_off_set_ NUMBER;
   closed_faults_count_ NUMBER;
   closed_fault_offset_time_ TIMESTAMP;
   
   CURSOR get_closed_fault_offset_ IS
      select add_months(sysdate,(-1)*(faults_off_set_)) FROM dual;
   
   CURSOR get_closed_fault_count_ IS
      SELECT COUNT(fault_id)
        INTO  closed_faults_count_
        FROM  av_fault_tab 
        WHERE aircraft_id = aircraft_id_ AND
               rowstate = 'Closed' AND
               closed_date > (closed_fault_offset_time_);
BEGIN
   faults_off_set_ :=Av_Airport_API.Get_Faults_Offset(arrival_airport_id_);
   
   OPEN get_closed_fault_offset_;
   FETCH get_closed_fault_offset_ INTO closed_fault_offset_time_;
   CLOSE get_closed_fault_offset_;
   
   OPEN get_closed_fault_count_;
   FETCH get_closed_fault_count_ INTO closed_faults_count_;
   CLOSE get_closed_fault_count_;
   RETURN closed_faults_count_ ;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;
      
END Get_Closed_Faults_Count ;

@UncheckedAccess
FUNCTION Get_Outbound_Station (
   aircraft_id_        IN NUMBER,
   arrival_airport_id_ IN NUMBER,
   shed_arrival_date_  IN TIMESTAMP ) RETURN VARCHAR2
IS
   departure_flight_id_  NUMBER;  
   outbound_airport_id_  NUMBER;
   airport_iata_code_    av_airport_tab.iata_code%TYPE;
BEGIN
   departure_flight_id_  := Av_Flight_API.Get_Departure_Flight_Id(aircraft_id_, arrival_airport_id_, shed_arrival_date_);
   outbound_airport_id_  := Av_Flight_API.Get_Arrival_Airport_Id(departure_flight_id_);
   airport_iata_code_    := Av_Airport_API.Get_Iata_Code(outbound_airport_id_);
   
   RETURN airport_iata_code_;
END Get_Outbound_Station;


PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM  av_flight_tab
      WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                   VARCHAR2(4000);
   aircraft_unique_key_          aircraft_tab.mx_unique_key%TYPE;
   aircraft_id_                  aircraft_tab.aircraft_id%TYPE;
   departure_airport_unique_key_ av_airport_tab.mx_unique_key%TYPE;
   departure_airport_id_         av_airport_tab.airport_id%TYPE;
   arrival_airport_unique_key_   av_airport_tab.mx_unique_key%TYPE;
   arrival_airport_id_           av_airport_tab.airport_id%TYPE;
   
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  mx_unique_key = aircraft_unique_key_;
   
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
   
   attr_ := local_attr_;
END Pre_Sync_Action;


PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(4000);
   current_rowstate_        av_flight_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   flight_rec_              av_flight_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50)    := 'ROWSTATE';
BEGIN
   local_attr_ := attr_;
   
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   flight_rec_   := Get_Object_By_Id___(objid_);
   current_rowstate_  := Get_Objstate(flight_rec_.flight_id);
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
END Post_Sync_Action;

@UncheckedAccess
FUNCTION Get_Arrival_Offset_Time (
   arrival_airport_id_ IN NUMBER) RETURN TIMESTAMP
IS
   arrival_offset_time_ TIMESTAMP;
   arrival_offset_ NUMBER;
   
   CURSOR get_offset_time_ IS 
      SELECT SYSDATE + (arrival_offset_)/24 FROM dual;
BEGIN
   arrival_offset_:= Av_Airport_API.Get_Arrival_Offset(arrival_airport_id_);
   OPEN  get_offset_time_ ;
   FETCH  get_offset_time_ INTO arrival_offset_time_;
   CLOSE get_offset_time_;
   RETURN arrival_offset_time_;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
      
END Get_Arrival_Offset_Time ;

@UncheckedAccess
FUNCTION Get_Departure_Offset_Time (
   arrival_airport_id_ IN NUMBER) RETURN TIMESTAMP
IS
   departure_offset_time_ TIMESTAMP;
   departure_offset_ NUMBER;
   
   CURSOR get_offset_time_ IS 
      SELECT SYSDATE - (Departure_offset_)/24 FROM dual;
BEGIN
   departure_offset_:= Av_Airport_API.Get_Departure_Offset(arrival_airport_id_);
   OPEN  get_offset_time_ ;
   FETCH  get_offset_time_ INTO departure_offset_time_;
   CLOSE get_offset_time_;
   RETURN departure_offset_time_;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
      
END Get_Departure_Offset_Time ;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_flight_tab.flight_id%TYPE;
   
   CURSOR get_flight_id IS 
      SELECT flight_id         
        FROM av_flight_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_flight_id;
   FETCH get_flight_id INTO temp_; 
   CLOSE get_flight_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Airport_Id_By_Unique_Key (
   airport_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_airport_tab.airport_id%TYPE;
   
   CURSOR get_airport_id IS 
      SELECT airport_id         
        FROM av_airport_tab
       WHERE mx_unique_key = airport_unique_key_;
BEGIN
   OPEN get_airport_id;
   FETCH get_airport_id INTO temp_; 
   CLOSE get_airport_id;
   
   RETURN temp_;
END Get_Airport_Id_By_Unique_Key;

FUNCTION Get_Aircraft_Id_By_Unique_Key (
   aircraft_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ aircraft_tab.aircraft_id%TYPE;
   
   CURSOR get_aircraft_id IS 
      SELECT aircraft_id         
        FROM aircraft_tab
       WHERE mx_unique_key = aircraft_unique_key_;
BEGIN
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO temp_; 
   CLOSE get_aircraft_id;
   
   RETURN temp_;
END Get_Aircraft_Id_By_Unique_Key;

-- This procedure will be used to set the flight state from the Migration Job 065_FLM_FLIGHT
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_ IN VARCHAR2,
   state_         IN VARCHAR2)
IS
   flight_id_        av_flight_tab.flight_id%TYPE;
   objid_            av_flight.objid%TYPE;
   objversion_       av_flight.objversion%TYPE;
   from_state_       av_flight_tab.rowstate%TYPE;
BEGIN
   flight_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(flight_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, flight_id_);
      from_state_      := Get_Objstate(flight_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN av_flight_tab%ROWTYPE )
IS
BEGIN
   IF remrec_.rowstate != 'Planned' THEN
      Error_SYS.Record_General(lu_name_, 'STARTEDFLIGHTDELETE: Started planned flight cannot be deleted.');
   END IF;
   IF remrec_.mx_unique_key IS NOT NULL THEN
      Error_SYS.Record_General(lu_name_, 'MXIRECORDSDELETE: Maintenix synced records cannot be deleted.');
   END IF;
   IF Has_Logbook_Fault(remrec_.flight_id) = 'TRUE' THEN
      Error_SYS.Record_General(lu_name_, 'FAULTFLIGHTDELETE: Planned Flights that have a logbook error cannot be deleted.');
   END IF;
   super(remrec_);
END Check_Delete___;

FUNCTION Has_Logbook_Fault (
   flight_id_ IN NUMBER) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR get_logbook_faults IS 
      SELECT 1         
       FROM av_fault_tab
       WHERE found_on_id = flight_id_
       FETCH    first 1 ROW ONLY;    
BEGIN
   OPEN get_logbook_faults;
   FETCH get_logbook_faults INTO dummy_;
   IF (get_logbook_faults%FOUND) THEN
      CLOSE get_logbook_faults;
      RETURN 'TRUE';
   ELSE
      CLOSE get_logbook_faults;
      RETURN 'FALSE';
   END IF;
	
END Has_Logbook_Fault;


FUNCTION Overlapping_Planned_Flights(
   aircraft_id_           IN NUMBER,
   actual_departure_date_ IN TIMESTAMP,
   actual_arrival_date_   IN TIMESTAMP)RETURN VARCHAR2
IS
   no_of_flights_    NUMBER;
   
   CURSOR get_flight_ IS
   SELECT COUNT(flight_id)
   FROM av_flight_tab
   WHERE Aircraft_Id=aircraft_id_ AND Actual_Departure_Date_Time <= actual_arrival_date_ AND Actual_Arrival_Date_Time >= actual_departure_date_;
BEGIN
   OPEN get_flight_;
   FETCH get_flight_ INTO no_of_flights_;
   CLOSE get_flight_;
   
   IF(no_of_flights_ = 0) THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
   
END Overlapping_Planned_Flights;


PROCEDURE New (
   info_       OUT    VARCHAR2,
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN
   New__(info_, objid_, objversion_, attr_, action_);
END New;


FUNCTION Calculate_Ground_Time(
   shed_dep_time_  TIMESTAMP,
   shed_arr_time_  TIMESTAMP
   )RETURN VARCHAR2
IS
   time_dif_       NUMBER;
   minutes_dif_    NUMBER;
   hours_dif_      NUMBER;
   ground_time_    VARCHAR2(20);
   
   CURSOR get_time IS
      SELECT (EXTRACT(DAY FROM shed_arr_time_-shed_dep_time_)*24*60)+
             (EXTRACT(HOUR FROM shed_arr_time_-shed_dep_time_)*60)+
             (EXTRACT(MINUTE FROM shed_arr_time_-shed_dep_time_))
      FROM   dual;
BEGIN
   OPEN  get_time;
   FETCH get_time INTO time_dif_;
   CLOSE get_time;
   
   hours_dif_   := FLOOR (time_dif_ / 60);
   minutes_dif_ := (time_dif_ mod 60);
   
   IF minutes_dif_    < 10 AND hours_dif_   > 10   THEN
      ground_time_ := CONCAT(CONCAT(hours_dif_, ':0'),minutes_dif_);
   ELSIF hours_dif_   < 10 AND minutes_dif_ > 10   THEN
      ground_time_ := CONCAT(CONCAT(CONCAT('0',hours_dif_), ':'),minutes_dif_);
   ELSIF minutes_dif_ < 10 AND hours_dif_   < 10   THEN
      ground_time_ := CONCAT(CONCAT(CONCAT('0',hours_dif_), ':0'),minutes_dif_);
   ELSE
      ground_time_ := CONCAT(CONCAT(hours_dif_, ':'),minutes_dif_);
   END IF;
   
   IF ground_time_ = ':' THEN
      RETURN '00:00';
   ELSE 
      RETURN ground_time_;
   END IF;
END Calculate_Ground_Time;


FUNCTION Calculate_Arrival_Date(
   shed_dep_time_  TIMESTAMP,
   duration_       VARCHAR2) RETURN TIMESTAMP
IS
   hours_      NUMBER;
   mins_       NUMBER;
   arr_date_   TIMESTAMP;
   
   CURSOR get_time_(hrs_ NUMBER,mns_ NUMBER) IS
   SELECT shed_dep_time_ +(hrs_/24) + (mns_/(24*60))
   FROM dual;
BEGIN
   IF(INSTR(duration_,':')=2) THEN
      hours_ := SUBSTR(duration_,1,1);
      mins_  := SUBSTR(duration_,3,4);
   ELSE
      hours_ := SUBSTR(duration_,1,2);
      mins_  := SUBSTR(duration_,4,5);
   END IF;
   
   
   OPEN get_time_(hours_,mins_);
   FETCH get_time_ INTO arr_date_;
   CLOSE get_time_;
   
   RETURN arr_date_;
   
END Calculate_Arrival_Date;

FUNCTION Flight_Exist(
   flight_name_ IN VARCHAR2,
   dep_airport_ IN NUMBER,
   dep_date_    IN TIMESTAMP) RETURN VARCHAR2
IS
   no_of_flights_ NUMBER;
   
   CURSOR get_flight_ IS
   SELECT count(flight_id)
   FROM Av_Flight_Tab
   WHERE leg_no = flight_name_ AND departure_airport_id = dep_airport_ AND actual_departure_date_time = dep_date_;
BEGIN
   OPEN get_flight_;
   FETCH get_flight_ INTO no_of_flights_;
   CLOSE get_flight_;
   
   IF(no_of_flights_ >0) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
   
END Flight_Exist; 

@UncheckedAccess
FUNCTION Get_Departure_Leg_No(
   aircraft_id_    IN NUMBER,
   arr_airport_id_ IN NUMBER,
   shed_arr_time_  IN TIMESTAMP) RETURN VARCHAR2
IS
   output_ av_flight_tab.leg_no%TYPE;
   flight_id_   NUMBER;
   CURSOR get_flight IS
      SELECT   leg_no
      FROM     av_flight_tab
      WHERE    flight_id    = flight_id_
      FETCH    first 1 ROW ONLY; 
BEGIN
   
   flight_id_ := Get_Departure_Flight_Id(aircraft_id_, arr_airport_id_, shed_arr_time_);
   
   OPEN  get_flight;
   FETCH get_flight INTO output_;
   CLOSE get_flight;
   
   RETURN output_;
END Get_Departure_Leg_No;


PROCEDURE Update_Rowversion_For_Native (
   flight_id_ IN NUMBER)
IS
   av_flight_rec_    Av_Flight_Tab%ROWTYPE;
   objid_            VARCHAR2(100);
   attr_             VARCHAR2(100);
   objversion_       VARCHAR2(100);
   
   CURSOR get_rowid IS
      SELECT rowid 
      FROM Av_Flight_Tab
      WHERE flight_id = flight_id_;
   
BEGIN   
   OPEN  get_rowid;
   FETCH get_rowid INTO objid_;
   CLOSE get_rowid;
   
   av_flight_rec_ := Lock_By_Keys___(flight_id_);
   Update___(objid_, av_flight_rec_, av_flight_rec_, attr_, objversion_);
   
END Update_Rowversion_For_Native;


@Override
PROCEDURE Check_Common___(  
   oldrec_ IN            av_flight_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY av_flight_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
   sync_enabled_ BOOLEAN;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   $IF (Component_Mxcore_SYS.INSTALLED) $THEN
      sync_enabled_ := Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode();
   $ELSE
      sync_enabled_ := FALSE;
   $END
   
   IF(sync_enabled_= FALSE) THEN
      IF(indrec_.shed_arrival_date_time OR indrec_.shed_departure_date_time) THEN 
         IF (newrec_.shed_arrival_date_time IS NOT NULL AND newrec_.shed_departure_date_time IS NOT NULL) THEN
            IF(newrec_.shed_departure_date_time>= newrec_.shed_arrival_date_time) THEN
               Error_SYS.Record_General(lu_name_, 'SCHEDARRDATENOTLATER: Scheduled Arrival Date must be later than the Scheduled Departure Date');
            END IF;
         END IF;
      END IF;

      IF(indrec_.actual_departure_date_time OR indrec_.actual_arrival_date_time) THEN    
         IF (newrec_.actual_arrival_date_time IS NOT NULL AND newrec_.actual_departure_date_time IS NOT NULL) THEN
            IF(newrec_.actual_departure_date_time>= newrec_.actual_arrival_date_time) THEN
               Error_SYS.Record_General(lu_name_, 'ARRIVALDATENOTLATER: Arrival Date must be later than the Departure Date.');
            END IF;
         END IF;

         IF(newrec_.aircraft_id IS NOT NULL AND newrec_.actual_departure_date_time IS NOT NULL AND newrec_.actual_arrival_date_time IS NOT NULL) THEN
            IF(Overlapping_Planned_Flights(newrec_.aircraft_id, newrec_.actual_departure_date_time, newrec_.actual_arrival_date_time)='TRUE') THEN
               Error_SYS.Record_General(lu_name_, 'OVERLAPFLIGHT: Aircraft cannot have overlapping planned flights');
            END IF;
         END IF;
      END IF;

      IF(indrec_.leg_no OR indrec_.departure_airport_id OR indrec_.actual_departure_date_time) THEN
         IF(newrec_.leg_no IS NOT NULL AND newrec_.departure_airport_id IS NOT NULL AND newrec_.actual_departure_date_time IS NOT NULL) THEN
            IF(Flight_Exist(newrec_.leg_no,newrec_.departure_airport_id,newrec_.actual_departure_date_time)='TRUE') THEN
               Error_SYS.Record_General(lu_name_, 'FLIGHTEXIST: Record already exists with same Flight Name, Departure Date and Departure airport');
            END IF;
         END IF;
      END IF;

      IF(indrec_.aircraft_id AND newrec_.aircraft_id IS NOT NULL) THEN   
         IF(Av_Inventory_API.Get_Locked_Bool(Aircraft_API.Get_Inventory_Id(newrec_.aircraft_id)) = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_, 'AIRCRAFTLOCKED: Cannot create a flight on a locked aircraft');
         END IF;

         IF(Aircraft_API.Get_Condition(newrec_.aircraft_id) IN ('ARCHIVE','SCRAP')) THEN   
            Error_SYS.Record_General(lu_name_, 'AIRCRAFTCONDITION: Cannot create a flight on a scrapped or archived aircraft');
         END IF;
      END IF;
   END IF;
END Check_Common___;


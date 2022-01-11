-----------------------------------------------------------------------------
--
--  Logical unit: AvFault
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date     Sign    History
--  ------  ------  ---------------------------------------------------------
--  210412  majslk  AD-1075, Updated Sync_State_Handle___ method.
--  210406  hasmlk  AD-1061, Data set to foundDuringFlightLeg in Raise Fault API body.
--  210326  SatGlk  AD-1066, Added Update_API_Fault to handle fault API duplicate issue.
--  210322  majslk  AD-1036, Changed id value of payload in PublishRaiseFault___ method.
--  210308  SWiclk  LMM2020R1-1908, Modified PublishRaiseFault___() in order to check Mx_Config_API.Is_Maintenix_Connected
--  210308  tprelk  LMM2020R1-1581, Created Get_Aircraft.
--  210308  majslk  LMM2020R1-1901, Removed Component_Flm_SYS.INSTALLED, added Dictionary_SYS.Component_Is_Active
--  210303  majslk  LMM2020R1-1665, Override Update___, Finite_State_Set___ methods, Updated Insert___ method.
--  210302  siselk  LMM2020R1-1798, Added Update_Rowversion_For_Native
--  210224  SURBLK  LMM2020R1-1787, Modified Sync_State_Handle___ to support for incoming state CFERR and CFNFF as considering Closed fault.
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 450_FLM_FAULT when setting the rowstate.
--  210112  SatGlk  LMM2020R1-1483, In Pre_Sync_Action, natural_key of fault, barcode is set to local_attr_ to handle API call back scenario
--  210112  KAWJLK  LMM2020R1-1477, Modified PublishRaiseFault___.
--  210108  SUPKLK  LMM2020R1-1502, Added Get_Sub_Sys_Id_By_Unique_Key to fetch sub system id in data migration
--  210106  SatGlk  LMM2020R1-1483, Implemented Get_Id_Version_By_Natural_Key to avoid faults syncing back from maintenix
--  201127  SUPKLK  LMM2020R1-1139, Implemented functions to fetch keys for data migration
--  201126  SUPKLK  LMM2020R1-1139, Added Get_Key_By_Mx_Unique_Key and modified Check_Insert___ to handle duplicates in data migration
--  201111  SEVHLK  LMM2020R1-952, Added the Defer_Task___ method and overrided Defer__ method.
--  201014  KAWJLK  LMM2020R1-1352, Added conditional compilation for Component_Mxcore_SYS.
--  201006  lahnlk  LMM2020R1-427, added Get_Closed_Fault_Offset_Date
--  200929  hasmlk  LMM2020R1-1186: Publish raise fault error handling done.
--  200929  siselk  LMM2020R1-1088, Change_State added
--  200928  sevhlk  LMM2020R1-1284, Removed mx_unique_key used for aircraft_sub_system in pre sync.
--  200916  hasmlk  LMM2020R1-1186: Get the fault that is going to be inserted and publish it to maintenix.
--  200915  sevhlk  LMM2020R1,   Re added the deleted code due to conflicts.
--  200914  sevhlk  LMM2020R1-1189, Added pre_sync, post_sync,sync_state_handle methods
--  200909  aruflk  LMM2020R1-860, Added Get_Found_Faults_Count().
--  200831  KAWJLK  LMM2020R1-557, Implemented Defer Fault. Added Defer_Fault.
--  200617  LAHNLK  LMM2020R1-74: created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_fault_seq.NEXTVAL
      FROM dual;
BEGIN
   IF(newrec_.fault_id IS NULL) THEN
      OPEN get_key_set;
      FETCH get_key_set INTO newrec_.fault_id;
      CLOSE get_key_set;
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ID', newrec_.fault_id, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS 
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.Aircraft_Id = newrec_.aircraft_id;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   
   -- Check if Maintenix is connected
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
         PublishRaiseFault___(newrec_);
      END IF;
   $END
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_fault_tab%ROWTYPE,
   newrec_     IN OUT av_fault_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   flight_id_            NUMBER;
   
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.Aircraft_Id = newrec_.aircraft_id;
BEGIN
   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR rec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(rec_.flight_id);
      END LOOP;
   END IF;
      
END Update___;


@Override
PROCEDURE Finite_State_Set___ (
   rec_   IN OUT av_fault_tab%ROWTYPE,
   state_ IN     VARCHAR2 )
IS   
   CURSOR get_flights IS
      SELECT f.flight_id 
      FROM   Av_Flight_tab f
      WHERE  f.Aircraft_Id = rec_.aircraft_id;
BEGIN
   super(rec_, state_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      FOR newrec_ IN get_flights LOOP
         Av_Flight_API.Update_Rowversion_For_Native(newrec_.flight_id);
      END LOOP;
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
   IF (incoming_rowstate_ IS NULL )    OR
      (current_rowstate_ = 'Open'      AND (incoming_rowstate_ = 'CFACTV' OR  incoming_rowstate_ = 'ACTV'))   OR
      (current_rowstate_ = 'Deferred'  AND incoming_rowstate_ = 'CFDEFER')  OR
      (current_rowstate_ = 'Closed'    AND (incoming_rowstate_ = 'CFCERT' OR  incoming_rowstate_ = 'CFERR' OR  incoming_rowstate_ = 'CFNFF')) THEN
      
      RETURN;
   END IF;
   
   IF current_rowstate_ = 'Open' AND incoming_rowstate_ = 'CFDEFER' THEN
      Defer__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF (current_rowstate_ IN('Open', 'Deferred') AND incoming_rowstate_ IN('CFCERT', 'CFERR', 'CFNFF'))  THEN
      Complete__(info_, objid_, objversion_, state_attr_, action_);
          
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);    
   END IF;
END Sync_State_Handle___; 

PROCEDURE Defer_Task___(
   objid_ IN VARCHAR2)
IS
   rec_        av_fault_tab%ROWTYPE;
   fault_id_   NUMBER;
   task_id_    NUMBER;
   info_                    VARCHAR2(4000);
   action_                  VARCHAR2(5) := 'DO';
   attr_                    VARCHAR2(4000);
   task_objid_              VARCHAR2(4000);
   objversion_              VARCHAR2(4000);
   
   CURSOR get_task_id IS
      SELECT task_id, rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')  
      FROM av_exe_task_tab  
      WHERE  fault_id = fault_id_;
   
BEGIN
   rec_ := Get_Object_By_Id___(objid_);
   fault_id_ := rec_.fault_id;
   
   OPEN get_task_id;
   FETCH get_task_id INTO task_id_, task_objid_, objversion_;
   CLOSE get_task_id;
   
   IF task_id_ IS NOT NULL THEN
      Av_Exe_Task_API.Defer__(info_, task_objid_, objversion_, attr_, action_);
   ELSE
      RETURN;
   END IF;
END Defer_Task___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Override
PROCEDURE Defer__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN
   super(info_, objid_, objversion_, attr_, action_);
   Defer_Task___(objid_);
   --Add post-processing code here
END Defer__;




-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_fault_tab
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
   FROM  av_fault_tab
   WHERE barcode = barcode_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Natural_Key;


PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   aircraft_unique_key_        aircraft_tab.mx_unique_key%TYPE;
   aircraft_id_                aircraft_tab.aircraft_id%TYPE;
   flight_unique_key_          av_flight_tab.leg_no%TYPE;
   flight_id_                  av_flight_tab.flight_id%TYPE;
   task_unique_key_            av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                    av_exe_task_tab.task_id%TYPE;
   barcode_                    VARCHAR2(80);
   sub_system_id_              Av_Aircraft_Sub_System_Tab.sub_system_id%TYPE;
   sub_system_unique_key_      Av_Aircraft_Sub_System_Tab.mx_unique_key%TYPE;
   found_on_desc_              Av_Fault.found_on_desc%TYPE;
      
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  mx_unique_key = aircraft_unique_key_;
   
   CURSOR get_flight IS
      SELECT flight_id
      FROM   av_flight_tab
      WHERE  mx_unique_key = flight_unique_key_;
   
   CURSOR get_task IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
   
   CURSOR Get_Sub_System IS
      SELECT sub_system_id
      FROM   av_aircraft_sub_system_tab
      WHERE  mx_unique_key = sub_system_unique_key_;
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
   
   IF Client_SYS.Item_Exist('FLIGHT_UNIQUE_KEY', local_attr_) THEN
      flight_unique_key_ := Client_SYS.Get_Item_Value('FLIGHT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_flight;
      FETCH get_flight INTO flight_id_;
      CLOSE get_flight;
      
      IF flight_id_ IS NOT NULL THEN 
         Client_SYS.Add_To_Attr('FOUND_ON_ID', flight_id_, local_attr_);
      END IF;
      local_attr_:= Client_SYS.Remove_Attr('FLIGHT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_task;
      FETCH get_task INTO task_id_;
      CLOSE get_task;
      
      IF task_id_ IS NOT NULL THEN 
         Client_SYS.Add_To_Attr('FOUND_ON_ID', task_id_, local_attr_);
      END IF;
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('BARCODE', local_attr_) THEN
      barcode_ := Client_SYS.Get_Item_Value('BARCODE', local_attr_);          
      Client_SYS.Add_To_Attr('NATURAL_KEY', barcode_, local_attr_);
   END IF;   
      
   IF Client_SYS.Item_Exist('SUB_SYSTEM_UNIQUE_KEY', local_attr_) THEN
      sub_system_unique_key_ := Client_SYS.Get_Item_Value('SUB_SYSTEM_UNIQUE_KEY', local_attr_);    
      
      OPEN  Get_Sub_System;
      FETCH Get_Sub_System INTO sub_system_id_;
      CLOSE Get_Sub_System;
      
      IF sub_system_unique_key_ IS NOT NULL AND sub_system_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'SUBSYSTEMSYNCER: Could not find the indicated Sub System :P1', sub_system_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('SUB_SYSTEM_ID', sub_system_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('SUB_SYSTEM_UNIQUE_KEY',  local_attr_);
   END IF;
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(4000);
   current_rowstate_        av_fault_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   fault_rec_               av_fault_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50)    := 'ROWSTATE';
BEGIN
   local_attr_ := attr_;
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   fault_rec_         := Get_Object_By_Id___(objid_);
   current_rowstate_  := Get_Objstate(fault_rec_.fault_id);
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
   
END Post_Sync_Action;


PROCEDURE Defer_Fault(
   fault_id_ IN NUMBER )
IS
   state_ VARCHAR2(200);
   rec_ av_fault_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(fault_id_);
   state_ := 'Deferred';
   Finite_State_Set___(rec_, state_);
END Defer_Fault;


/*
   This method is publishing the fault in to Maintenix.
*/
PROCEDURE PublishRaiseFault___ (
   newrec_ IN OUT av_fault_tab%ROWTYPE)
IS
   
   -- Params required to modify the fault record
   info_                      VARCHAR2(32000);
   attr_                      VARCHAR2(32000);
   objid_                     VARCHAR2(2000);
   objversion_                VARCHAR2(2000);
   sub_system_code_           VARCHAR2(2000);
   
   -- Params required for the HTTP request/response
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      url_parameters_         Mx_Connect_Util_API.url_param_;
      header_parameters_      Mx_Connect_Util_API.header_param_;
      query_parameters_       Mx_Connect_Util_API.query_param_;
   $END
   payload_                   CLOB;
   response_ja_               JSON_ARRAY_T;
   response_jo_               JSON_OBJECT_T;
   found_on_aircraft_         VARCHAR2(50);
   found_on_flight_alt_id_    VARCHAR2(50);
   error_msg_                 VARCHAR2(2000);
   current_user_              VARCHAR2(100);
   barcode_                   VARCHAR2(100) := NULL;
   
   -- service name represents the API  to add modify and remove fault at maintenix
   rest_service_              VARCHAR2(50):= 'MX_RAISE_FAULT';
   http_method_               VARCHAR2(10) := 'POST';
   
   -- Get aircraft alt_id from the aircraft
   CURSOR aircraft_alt_id (aircraft_id_ IN NUMBER) IS 
      SELECT aircraft.alt_id
      FROM aircraft_tab aircraft
      WHERE aircraft.aircraft_id = aircraft_id_;
      
   -- Get flight leg no from the flight
   CURSOR get_flight_alt_id (flight_id_ IN NUMBER) IS 
      SELECT av_flight_tab.mx_unique_key
      FROM av_flight_tab
      WHERE av_flight_tab.flight_id = flight_id_;
   
BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF (Mx_Config_API.Is_Maintenix_Connected) THEN
         OPEN aircraft_alt_id(newrec_.aircraft_id);
         FETCH aircraft_alt_id INTO found_on_aircraft_;
         CLOSE aircraft_alt_id;
         
         OPEN get_flight_alt_id(newrec_.found_on_id);
         FETCH get_flight_alt_id INTO found_on_flight_alt_id_;
         CLOSE get_flight_alt_id;

         current_user_ :=  Fnd_Session_API.Get_Fnd_User();
         sub_system_code_ := Av_Aircraft_Sub_System_API.Get_Sub_System_Code(newrec_.sub_system_id);
         -- Build the payload
         payload_ := '[
                     {
                       "_meta": {
                         "tenant": "IFSAPP",
                         "product": "Maintenix",
                         "timestamp": "' || TO_CHAR(CAST(sysdate AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",
                         "type": "LOGBOOK_ENTRY_MODIFIED"
                       },
                       "id": "' || newrec_.logbook_reference || '",
                       "description": "' || newrec_.description || '",
                       "failedSystem": "' || sub_system_code_ || '",
                       "isTechnicalLogbookEntry": "true",
                       "isCabinLogbookEntry": "false",
                       "source": "' || newrec_.fault_source_code || '",
                       "foundOnAircraft": "' || found_on_aircraft_ || '",
                       "foundDuringFlightLeg": "' || found_on_flight_alt_id_ || '",
                       "foundDuringFlightPhase": "' || newrec_.phase_of_flight_code || '",
                       "foundOnDate": "' ||TO_CHAR(CAST(newrec_.found_on_date AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"')|| '",
                        "foundByPerson":"ifs'||current_user_||'"
                     }
                   ]';

         -- Call REST endpoint
         Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                                  payload_,
                                                  http_method_,
                                                  '200,400,500',
                                                  url_parameters_,
                                                  header_parameters_,
                                                  query_parameters_);
                                                  
      -- TODO: Fetch the response code and do the following validations.
      -- Cannot fetch the response code and do the below validations at the moment due to no framework support.

      -- Most outer element of the response body is an array.
      -- Validate if the response body is a success.
      BEGIN

         -- Extract response body into an JSON object.
         response_ja_ := JSON_ARRAY_T.parse(payload_);
         response_jo_ := JSON_OBJECT_T(response_ja_.get(0));
         EXCEPTION WHEN OTHERS THEN

      -- If response body cannot be parsed the same way that a success response body is parsed,
      -- But it can be parse as below, that is considered as an handled error scenario.
         BEGIN

            -- Check if it can be parsed as an error response body.
            response_jo_ := JSON_OBJECT_T.parse(payload_);
            EXCEPTION WHEN OTHERS THEN

         -- Unexpected error in the response body.
            Error_SYS.Record_General(lu_name_, 'MXUNEXPECTEDERR: Unexpected Response Error, Response Body - :P1', dbms_lob.substr( payload_, 1500, 1 ));
         END;
         error_msg_ := response_jo_.get_String('_message');

         -- If an error message is received from Maintenix, raise an exception with the error message.
         IF (error_msg_ IS NOT NULL )THEN
            Error_SYS.Record_General(lu_name_, 'MXRAISEFAULTERR: Maintenix raise fault validation failed with error - :P1', error_msg_);
         ELSE
            Error_SYS.Record_General(lu_name_, 'MXNOERRORERR: Error not found in response. Payload - :P1', payload_);
         END IF;
      END;

      -- Execution comes to this point if all the validations are successful.
      -- Then modify the fault entity.
      Client_SYS.Clear_Attr(attr_);
      barcode_ := response_jo_.get_String('barcode');
      IF (barcode_ IS NULL) THEN
         Error_SYS.Record_General(lu_name_, 'MXNOBARCODEERR: Barcode not found in response. Payload - :P1', payload_);
      END IF;
      Client_SYS.Add_To_Attr('BARCODE', barcode_, attr_);
      IF (response_jo_.get_String('faultId') IS NULL )THEN
         Error_SYS.Record_General(lu_name_, 'MXNOFAULTIDERR: Fault ID not found in response. Payload - :P1', payload_);
      END IF;
      Client_SYS.Add_To_Attr('ALT_ID', response_jo_.get_String('faultId'), attr_);
      Get_Id_Version_By_Keys___(objid_, objversion_, newrec_.fault_id);
      Modify__(info_, objid_, objversion_, attr_, 'DO');
      Update_API_Fault(newrec_.fault_id, barcode_);
   END IF;
   $ELSE
      NULL;
   $END
END PublishRaiseFault___;


PROCEDURE Update_API_Fault (
   fault_id_            IN NUMBER,
   barcode_             IN VARCHAR2)
IS
   -- Params required to modify the fault record
   record_count_        NUMBER;  
   synced_fault_id_     NUMBER;
   info_                VARCHAR2(32000);
   attr_                VARCHAR2(32000);
   objid_               VARCHAR2(2000);
   objversion_          VARCHAR2(2000); 
   mx_unique_key_       VARCHAR2(100);
   found_by_user_       VARCHAR2(50);
   
   CURSOR get_record_count IS
      SELECT COUNT(barcode)
      FROM av_fault_tab
      WHERE barcode = barcode_;
   
   CURSOR get_synced_rec IS
      SELECT fault_id, mx_unique_key, found_by_user
      FROM av_fault_tab
      WHERE barcode = barcode_ AND mx_unique_key IS NOT NULL;
BEGIN
   OPEN  get_record_count;
   FETCH get_record_count INTO record_count_;
   CLOSE get_record_count;
   
   -- Check if more than one record exist for same barcode
   -- There can be maximum of two records. one created from API and another record
   -- can be synced back from related sync job
   IF record_count_ > 1 THEN
      OPEN  get_synced_rec;
      FETCH get_synced_rec INTO synced_fault_id_, mx_unique_key_, found_by_user_;
      CLOSE get_synced_rec;
      
      -- Delete the synced record after merging data to a single rec
      Delete_Fault_Rec(synced_fault_id_);
      
      -- Merge the synced record info to the fault record created from IFS Apps
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
      Client_SYS.Add_To_Attr('FOUND_BY_USER', found_by_user_, attr_);      
      Get_Id_Version_By_Keys___(objid_, objversion_, fault_id_);
      Modify__(info_, objid_, objversion_, attr_, 'DO'); 
   END IF;
END Update_API_Fault;

/*
   Delete the duplicated fault record
*/
PROCEDURE Delete_Fault_Rec (
   fault_id_    IN NUMBER)
IS
   info_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
BEGIN
   Get_Id_Version_By_Keys___ (objid_, objversion_ , fault_id_);
   Remove__( info_, objid_, objversion_, 'DO' );
END Delete_Fault_Rec;

FUNCTION Get_Found_Faults_Count (
   task_id_ IN NUMBER) RETURN NUMBER
IS
   count_    NUMBER;
   
   CURSOR get_found_faults_count IS
      SELECT   COUNT(*)
      FROM     Av_Fault_Tab
      WHERE    found_on_id = task_id_
      AND      found_on_type = 'TASK';    
BEGIN
   OPEN  get_found_faults_count;
   FETCH get_found_faults_count INTO count_;
   CLOSE get_found_faults_count;
   
   RETURN count_;  
END Get_Found_Faults_Count;

PROCEDURE Change_State(
   fault_id_ IN NUMBER,
   objstate_ IN VARCHAR2)
IS
   rec_ av_fault_tab%ROWTYPE;
BEGIN
   rec_ := Av_Fault_API.Get_Object_By_Keys___(fault_id_);
   Av_Fault_API.Finite_State_Set___(rec_, objstate_);
END Change_State;

FUNCTION Get_Closed_Fault_Offset_Date (
   signed_by_user_ IN VARCHAR2,
   fault_id_       IN NUMBER) RETURN TIMESTAMP
IS
   objstate_ VARCHAR2(20);
   closed_fault_offset_date_ TIMESTAMP;
   offset_val_ NUMBER;
   CURSOR get_closed_fault_offset_date_ IS
      SELECT add_months(sysdate,(-1)*(offset_val_)) FROM dual;
BEGIN
   objstate_:= Av_Fault_API.Get_Objstate(fault_id_);
   IF(objstate_ = 'Closed')THEN
      offset_val_ := Av_Airport_API.Get_Faults_Offset(Av_Airport_For_User_API.Get_Airport_Id(signed_by_user_));   
      OPEN get_closed_fault_offset_date_;
      FETCH get_closed_fault_offset_date_ INTO closed_fault_offset_date_;
      CLOSE get_closed_fault_offset_date_;
      RETURN closed_fault_offset_date_ ;
   ELSE
      RETURN NULL ;
   END IF;
   
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
      
END Get_Closed_Fault_Offset_Date ;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_tab.fault_id%TYPE;
   
   CURSOR get_fault_id IS 
      SELECT fault_id         
        FROM av_fault_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_fault_id;
   FETCH get_fault_id INTO temp_; 
   CLOSE get_fault_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Aircraft_Id_By_Unique_Key (
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
END Get_Aircraft_Id_By_Unique_Key;

FUNCTION Get_Sub_Sys_Id_By_Unique_Key (
   sub_system_unique_key_ IN   VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_sub_system_tab.sub_system_id%TYPE;
   
   CURSOR get_sub_system_id IS 
      SELECT sub_system_id         
        FROM av_aircraft_sub_system_tab
       WHERE mx_unique_key = sub_system_unique_key_;
BEGIN
   OPEN get_sub_system_id;
   FETCH get_sub_system_id INTO temp_; 
   CLOSE get_sub_system_id;

   RETURN temp_;
END Get_Sub_Sys_Id_By_Unique_Key;

-- This procedure will be used to set the fault state from the Migration Job 450_FLM_FAULT
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_    IN VARCHAR2,
   state_            IN VARCHAR2)
IS
   fault_id_         av_fault_tab.fault_id%TYPE;
   objid_            av_fault.objid%TYPE;
   objversion_       av_fault.objversion%TYPE;
   from_state_       av_fault_tab.rowstate%TYPE;
BEGIN
   fault_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(fault_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, fault_id_);
      from_state_      := Get_Objstate(fault_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;


PROCEDURE Update_Rowversion_For_Native (
   fault_id_ IN NUMBER)
IS
   av_fault_rec_     Av_Fault_Tab%ROWTYPE;
   objid_            VARCHAR2(100);
   attr_             VARCHAR2(100);
   objversion_       VARCHAR2(100);
   
   CURSOR get_rowid IS
      SELECT   rowid 
      FROM     Av_Fault_Tab
      WHERE    fault_id = fault_id_;
      
BEGIN
   av_fault_rec_  := Get_Object_By_Keys___(fault_id_);

   OPEN  get_rowid;
   FETCH get_rowid INTO objid_;
   CLOSE get_rowid;
   
   Update___(objid_, av_fault_rec_, av_fault_rec_, attr_, objversion_);
   
END Update_Rowversion_For_Native;

FUNCTION Get_Aircraft(
   fault_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(150);
  
   CURSOR get_aircraft_name IS
      SELECT CONCAT( CONCAT( CONCAT( a.reg_code, ' (' ), av.aircraft_type_name ), ')' )
      FROM   av_fault_tab f
      INNER JOIN aircraft_tab a
      ON f.aircraft_id = a.aircraft_id
      INNER JOIN av_aircraft_type_tab av
      ON  a.aircraft_type_code = av.aircraft_type_code
      where  f.fault_id      = fault_id_;
      
BEGIN
   OPEN  get_aircraft_name;
   FETCH get_aircraft_name INTO output_;
   CLOSE get_aircraft_name;
   
   RETURN output_;
END Get_Aircraft;



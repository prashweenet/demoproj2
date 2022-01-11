-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTask
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210507  SatGlk  AD-1739, Modified Change_State to support packaging deferred fault process
--  210505  rosdlk  AD-1519, Change the condition of copying changes when package the fault
--  210504  supklk  AD-1074, Added condition to only copy the ACTIVE labours after packaging the fault
--  210430  rosdlk  AD-1519, Copy tools, skills and actions to task after packaging the fault
--  210428  SatGlk  AD-1089, Added Build_JSON_Obj_for_Batch_API___, Build_Payload_for_Pack_Fault_New_WP___, to build JSON payload for PublishPackageFaultWithNewWP.
--  210423  SatGlk  AD-1089, Added PublishPackageFaultWithNewWPError___ to handle errors for PublishPackageFaultWithNewWP.
--  210423  SatGlk  AD-1089, Modified PublishPackageFaultWithNewWP to support batch API call.
--  210322  spatlk  AD-1132,Add Part changes complete task.
--  210308  SWiclk  LMM2020R1-1908, Modified PublishPackageFaultExistingWP(), PublishPackageFaultWithNewWP()
--  210308          PublishWorkPackageModify___ in order to check Mx_Config_API.Is_Maintenix_Connected
--  210308  majslk  LMM2020R1-1901, Removed Component_Flm_SYS.INSTALLED, added Dictionary_SYS.Component_Is_Active
--  210305  majslk  LMM2020R1-1904, Added conditions for null check in Insert___, Update___
--  210303  majslk  LMM2020R1-1665, Override Update___ method, updated Insert___ method
--  210302  siselk  LMM2020R1-1798, Added Update_Rowversion_For_Native
--  210222  SatGlk  LMM2020R1-1729, Modifed Sync_State_Handle___ to support unhandled statuses of ERROR, FORECAST, INSPREQ, PAUSE.
--  210218  KAWJLK  LMM2020R1-1475, modified Sync_State_Handle___,Pre_Sync_Action. 
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 200_FLM_EXE_TASK when setting the rowstate.
--  210208  dildlk  LMM2020R1-1480, Added natural key.
--  210205  ROSDLK  LMM2020R1-1526, Check whether any wp exists and the wp status before package fault.
--  210205  aruflk  LMM2020R1-1475, Modified PublishWorkPackageModify___().
--  210106  SatGlk  LMM2020R1-1483, Implemented Get_Id_Version_By_Natural_Key to avoid tasks syncing back from maintenix
--  201105  supklk  LMM2020R1-1134, Implemented functions to get keys to handle data migration
--  201105  supklk  LMM2020R1-1134, Implemented Get_Key_By_Mx_Unique_Key to handle duplicates in data migration
--  201105  sevhlk  AD2020R1-952, Added changes to handle all the state changes when syncing
--  201102  sevhlk  AD2020R1-952, Changes made to Sync_State_Handle___ method for handling defered tasks.
--  201019  dildlk  LMM2020R1-872, Added PublishPackageFaultWithNewWP().
--  201013  Tajalk  LMM2020R1-1348, Added missing conditional compilation 
--  200929  siselk  LMM2020R1-1088, Change_State added
--  200925  dildlk  LMM2020R1-872, Added PublishAvTaskNew().
--  200922  rosdlk  LMM2020R1-1239, Get the wp that needs to get started and publish it to maintenix.
--  200831  KAWJLK  LMM2020R1-557, Implemented Defer Fault. Added Defer_Fault_And_Remove_Wp___, Remove_wp.
--  200730  sevhlk  LMM2020R1-691, Changes made to Pre_Sync_Action method.
--  200730  sevhlk  LMM2020R1-218, Added Pre_Sync_Action, Post_Sync_Action and Sync_State_Handle___ methods.
--  200701  aruflk  LMM2020R1-239, Modified Get_Task_Id().
--  200618  aruflk  LMM2020R1-75, Override Check_Insert___().
--  200626  majslk  LMM2020R1-20, Added Get_Aircraft().
--  200617  dildlk  LMM2020R1-17, Added Is_Wp_Assigned() and Get_Task_Id().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   task_id_ NUMBER;
  
   CURSOR get_key_cursor IS
   SELECT TASK_ID_SEQ.nextval
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO task_id_;
   CLOSE get_key_cursor;
  
   IF (newrec_.task_id IS NULL) THEN
      newrec_.task_id := task_id_;
   END IF;
   super(newrec_, indrec_, attr_); 
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___(
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_exe_task_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
    wp_barcode_           VARCHAR2(80);
    wp_status_            VARCHAR2(80);
    flight_id_            NUMBER;
    
    CURSOR get_aircraft_wp_barcode IS
    SELECT barcode
    FROM   av_aircraft_work_package_tab
    WHERE  av_aircraft_work_package_tab.aircraft_work_package_id = newrec_.aircraft_wp_id;
    
    CURSOR get_aircraft_wp_status IS
    SELECT rowstate
    FROM   av_aircraft_work_package_tab
    WHERE  av_aircraft_work_package_tab.aircraft_work_package_id = newrec_.aircraft_wp_id;
   
BEGIN
   
      OPEN get_aircraft_wp_barcode;
      FETCH get_aircraft_wp_barcode INTO wp_barcode_;
      CLOSE get_aircraft_wp_barcode;
      
      OPEN get_aircraft_wp_status;
      FETCH get_aircraft_wp_status INTO wp_status_;
      CLOSE get_aircraft_wp_status;
    
   super(objid_, objversion_, newrec_, attr_);
   $IF Component_Mxcore_SYS.INSTALLED $THEN
     IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
        
        IF (wp_barcode_ IS NULL OR wp_status_ = 'Canceled' OR 
            wp_status_ = 'Completed') THEN 
         PublishPackageFaultWithNewWP(newrec_);
      ELSE
         PublishPackageFaultExistingWP(newrec_);
      END IF; 
      
    END IF;
   $END
   
   IF newrec_.fault_id IS NOT NULL THEN
      CopyChanges(newrec_);
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      flight_id_ := Av_Aircraft_Work_Package_API.Get_Flight_Id(newrec_.aircraft_wp_id);
      IF flight_id_ IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(flight_id_);
      END IF;
   END IF;
END Insert___;
   
@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_exe_task_tab%ROWTYPE,
   newrec_     IN OUT av_exe_task_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
    flight_id_            NUMBER;
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      flight_id_ := Av_Aircraft_Work_Package_API.Get_Flight_Id(newrec_.aircraft_wp_id);
      IF flight_id_ IS NOT NULL THEN
         Av_Flight_API.Update_Rowversion_For_Native(flight_id_);
      END IF;
   END IF;
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
   IF (incoming_rowstate_ IS NULL )    OR
      (current_rowstate_ = 'Active'    AND (incoming_rowstate_ = 'ACTV' OR incoming_rowstate_ = 'FORECAST'))  OR
      (current_rowstate_ = 'InWork'    AND (incoming_rowstate_ = 'IN WORK' OR incoming_rowstate_ = 'INSPREQ' OR incoming_rowstate_ = 'PAUSE'))  OR
      (current_rowstate_ = 'Completed' AND (incoming_rowstate_ = 'COMPLETE' OR incoming_rowstate_ = 'ERROR')) OR
      (current_rowstate_ = 'InWork'    AND (incoming_rowstate_ = 'ACTV' OR incoming_rowstate_ = 'FORECAST'))    OR
      (current_rowstate_ = 'Removed'   AND incoming_rowstate_ = 'CFDEFER')  THEN
      
      RETURN;
   END IF;

   IF current_rowstate_ = 'Active' AND (incoming_rowstate_ = 'IN WORK' OR incoming_rowstate_ = 'INSPREQ' OR incoming_rowstate_ = 'PAUSE') THEN
      Start__(info_, objid_, objversion_, state_attr_, action_);
   
   ELSIF current_rowstate_ = 'Active' AND (incoming_rowstate_ = 'COMPLETE' OR incoming_rowstate_ = 'ERROR') THEN
      Start__(info_, objid_, objversion_, state_attr_, action_);
          
      Get_Version_By_Id___(objid_, objversion_);
      To_Complete__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Active' AND incoming_rowstate_ = 'CFDEFER' THEN
      Defer__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'InWork' AND incoming_rowstate_ = 'CFDEFER' THEN
      Defer__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'InWork' AND (incoming_rowstate_ = 'COMPLETE' OR incoming_rowstate_ = 'ERROR') THEN 
      To_Complete__(info_, objid_, objversion_, state_attr_, action_);      
      
   ELSIF current_rowstate_ = 'Removed' AND (incoming_rowstate_ = 'ACTV' OR incoming_rowstate_ = 'FORECAST') THEN
      Schedule__(info_, objid_, objversion_, state_attr_, action_);
   
   ELSIF current_rowstate_ = 'Removed' AND (incoming_rowstate_ = 'IN WORK' OR incoming_rowstate_ = 'INSPREQ' OR incoming_rowstate_ = 'PAUSE') THEN
      Schedule__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Start__(info_, objid_, objversion_, state_attr_, action_);
   ELSIF current_rowstate_ = 'Removed' AND (incoming_rowstate_ = 'COMPLETE' OR incoming_rowstate_ = 'ERROR') THEN
      Schedule__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Start__(info_, objid_, objversion_, state_attr_, action_);      
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);    
   END IF;
END Sync_State_Handle___;

PROCEDURE Defer_Fault_And_Remove_Wp___ (
   rec_  IN OUT NOCOPY av_exe_task_tab%ROWTYPE,
   attr_ IN OUT NOCOPY VARCHAR2 )
IS 
BEGIN
   Remove_wp(rec_.task_id);
   Av_Fault_API.Defer_Fault(rec_.fault_id);
END Defer_Fault_And_Remove_Wp___;

@Override
PROCEDURE Start__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   rowid_ VARCHAR2(200);
   wp_id_ NUMBER;
BEGIN
   --Add pre-processing code here
   rowid_ := objid_;  
   super(info_, objid_, objversion_, attr_, action_);
   wp_id_ := Get_Wp_Id(rowid_);
   --Add post-processing code here
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      PublishWorkPackageModify___(wp_id_);
   $END
END Start__;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Is_Wp_Assigned (
  fault_id_             IN NUMBER ) RETURN VARCHAR2
IS
   aircraft_wp_id_ Number;
   is_assigned_ VARCHAR2(200);
BEGIN
   is_assigned_ :='FALSE';
      SELECT aircraft_wp_id
         INTO  aircraft_wp_id_
         FROM  av_exe_task_tab 
         WHERE fault_id = fault_id_ ;
      
   IF (aircraft_wp_id_ IS NOT NULL) THEN
     is_assigned_ := 'TRUE';
   END IF;
  
  RETURN is_assigned_ ;
  EXCEPTION
   WHEN no_data_found THEN
      RETURN is_assigned_;
  
END Is_Wp_Assigned ;



FUNCTION Get_Task_Id (
  fault_id_   IN NUMBER ) RETURN NUMBER
IS
   task_id_ NUMBER;  
   BEGIN
      SELECT task_id
        INTO  task_id_
        FROM  av_exe_task_tab 
        WHERE fault_id = fault_id_ ;
   RETURN task_id_ ;
   
   EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;
      
END Get_Task_Id ;


FUNCTION Get_Aircraft(
   aircraft_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(150);
  
   CURSOR get_aircraft_name IS
      SELECT CONCAT( CONCAT( CONCAT( a.reg_code, ' (' ), av.aircraft_type_name ), ')' )
      FROM   aircraft_tab a, av_aircraft_type_tab av
      WHERE  a.aircraft_type_code = av.aircraft_type_code
      AND    a.aircraft_id      = aircraft_id_;
      
BEGIN
   OPEN  get_aircraft_name;
   FETCH get_aircraft_name INTO output_;
   CLOSE get_aircraft_name;
   
   RETURN output_;
END Get_Aircraft;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_tab
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
   FROM  av_exe_task_tab
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
   fault_unique_key_           av_fault_tab.mx_unique_key%TYPE;
   fault_id_                   av_fault_tab.fault_id%TYPE;
   barcode_                    VARCHAR2(80);
   aircraft_wp_unique_key_     av_aircraft_work_package_tab.mx_unique_key%TYPE;
   aircraft_wp_id_             av_aircraft_work_package_tab.aircraft_work_package_id%TYPE;
   config_slot_unique_key_     av_config_slot_position_tab.mx_unique_key%TYPE;
   config_slot_code_           av_config_slot_position_tab.config_slot_position_code%TYPE;
   current_rowstate_           av_exe_task_tab.rowstate%TYPE;
   incoming_rowstate_          VARCHAR2(50);
   rowstate_attribute_name_    VARCHAR2(50)    := 'ROWSTATE';
   mx_unique_key_              av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                    av_exe_task_tab.task_id%TYPE;
   
   CURSOR get_aircraft_id IS
      SELECT aircraft_id
      FROM   aircraft_tab
      WHERE  mx_unique_key = aircraft_unique_key_;
   
   CURSOR get_fault_id IS
      SELECT fault_id
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
      
   CURSOR get_aircraft_wp_id IS
      SELECT aircraft_work_package_id
      FROM   av_aircraft_work_package_tab
      WHERE  mx_unique_key = aircraft_wp_unique_key_;
      
   CURSOR get_config_slot_position_code IS
      SELECT config_slot_position_code
      FROM   av_config_slot_position_tab
      WHERE  mx_unique_key = config_slot_unique_key_;
   
BEGIN
   local_attr_ := attr_;
   mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_);
   task_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   current_rowstate_  := Get_Objstate(task_id_);

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
   
   IF Client_SYS.Item_Exist('WORK_PACKAGE_UNIQUE_KEY', local_attr_) THEN
      aircraft_wp_unique_key_ := Client_SYS.Get_Item_Value('WORK_PACKAGE_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_aircraft_wp_id;
      FETCH get_aircraft_wp_id INTO aircraft_wp_id_;
      CLOSE get_aircraft_wp_id;
      
      IF aircraft_wp_unique_key_ IS NOT NULL AND aircraft_wp_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'WORKPACKAGESYNCER: Could not find the indicated Work Package :P1', aircraft_wp_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('AIRCRAFT_WP_ID', aircraft_wp_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('WORK_PACKAGE_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('CONFIG_SLOT_UNIQUE_KEY', local_attr_) THEN
      config_slot_unique_key_ := Client_SYS.Get_Item_Value('CONFIG_SLOT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_config_slot_position_code;
      FETCH get_config_slot_position_code INTO config_slot_code_;
      CLOSE get_config_slot_position_code;
      
      IF config_slot_unique_key_ IS NOT NULL AND config_slot_code_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'CONFIGSLOTSYNCER: Could not find the indicated Config Slot Position :P1', config_slot_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('CONFIG_SLOT_POSITION_CODE', config_slot_code_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('CONFIG_SLOT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('FAULT_UNIQUE_KEY', local_attr_) THEN
      fault_unique_key_ := Client_SYS.Get_Item_Value('FAULT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_fault_id;
      FETCH get_fault_id INTO fault_id_;
      CLOSE get_fault_id;
      
      IF fault_unique_key_ IS NOT NULL AND fault_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'FAULTSYNCER: Could not find the indicated Fault :P1', fault_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FAULT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF current_rowstate_ = 'InWork' AND incoming_rowstate_ = 'ACTV' THEN
      local_attr_:= Client_SYS.Remove_Attr('ACTUAL_START_DATE_TIME',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(4000);
   current_rowstate_        av_exe_task_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   task_rec_                av_exe_task_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50)    := 'ROWSTATE';
BEGIN
   local_attr_ := attr_;
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   task_rec_          := Get_Object_By_Id___(objid_);
   current_rowstate_  := Get_Objstate(task_rec_.task_id);
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
END Post_Sync_Action;

PROCEDURE Remove_wp (
   task_id_ IN NUMBER)
IS
   oldrec_ av_exe_task_tab%ROWTYPE;
   newrec_ av_exe_task_tab%ROWTYPE;
   objid_ VARCHAR2(2000);
   attr_ VARCHAR2(4000);
   objversion_ VARCHAR2(2000);
BEGIN
   oldrec_ := Get_Object_By_Keys___ (task_id_);
   newrec_ := oldrec_;
   newrec_.aircraft_wp_id := NULL;
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Remove_wp;

PROCEDURE Change_State(
   task_id_          IN NUMBER,
   objstate_         IN VARCHAR2)
IS
   rec_              av_exe_task_tab%ROWTYPE;
   old_state_        VARCHAR2(20); 
   wp_barcode_       VARCHAR2(80);
   wp_status_        VARCHAR2(80);
   
   CURSOR get_aircraft_wp_info (aircraft_wp_id IN NUMBER) IS
      SELECT barcode, rowstate
      FROM   av_aircraft_work_package_tab
      WHERE  av_aircraft_work_package_tab.aircraft_work_package_id = aircraft_wp_id;
BEGIN   
   rec_ := Av_Exe_Task_API.Get_Object_By_Keys___(task_id_);   
   old_state_ := rec_.rowstate;
   Av_Exe_Task_API.Finite_State_Set___(rec_, objstate_);
   
   IF(old_state_ = 'Removed' AND objstate_ = 'Active') THEN
      OPEN  get_aircraft_wp_info(rec_.aircraft_wp_id);
      FETCH get_aircraft_wp_info INTO wp_barcode_, wp_status_;
      CLOSE get_aircraft_wp_info;

      $IF Component_Mxcore_SYS.INSTALLED $THEN
         IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
            IF (wp_barcode_ IS NULL OR wp_status_ = 'Canceled' OR 
                wp_status_ = 'Completed') THEN 
                PublishPackageFaultWithNewWP(rec_);
             ELSE
                PublishPackageFaultExistingWP(rec_);
             END IF;
          END IF;
      $END
   
      IF rec_.fault_id IS NOT NULL THEN
         CopyChanges(rec_);
      END IF;
   END IF;

   IF( objstate_ ='Completed' OR objstate_ = 'COMPLETED' )THEN
      CompleteTaskWithPartReq___(rec_);
   END IF;
END Change_State;

/**
This method is use to complete task which has part requirements in Maintenix .**/

PROCEDURE CompleteTaskWithPartReq___ (
   newrec_ IN OUT av_exe_task_tab%ROWTYPE)
IS
       -- Params required for the HTTP request/response
   $IF Component_Mxcore_SYS.INSTALLED $THEN
     
      url_parameters_         Mx_Connect_Util_API.url_param_;
      header_parameters_      Mx_Connect_Util_API.header_param_;
      query_parameters_       Mx_Connect_Util_API.query_param_;
      
   $END
   
   payload_                CLOB;
   error_msg_              VARCHAR2(2000);
   current_user_           VARCHAR2(100);
   part_changes_           VARCHAR2(32000);
   
   -- service name represents the API  to add modify and remove fault at maintenix
   rest_service_        VARCHAR2(50):= 'MX_COMPLETE_TASK';
   http_method_         VARCHAR2(10) := 'POST';
   
   
BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      
     current_user_ :=  Fnd_Session_API.Get_Fnd_User();
     
     --get Part changes sign off for the task 
     part_changes_ := Get_Part_Changes_Str_For_Task(newrec_.task_id);
     
      IF part_changes_ IS NOT NULL OR part_changes_ ='' THEN 
         part_changes_ := '['||part_changes_||']';
      ELSE 
         part_changes_ := 'null';
      END IF ;
      
     
    -- Build the payload
     payload_ := '{
                  "taskAltid": "' || newrec_.alt_id || '",
                  "completeDate": "' || TO_CHAR(CAST(sysdate AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",
                  "username": "'||current_user_||'",
                  "partsChange": '||part_changes_||'
                  }';
  
      -- Call REST endpoint
      Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                               payload_,
                                               http_method_,
                                               '200,400,500,404',
                                               url_parameters_,
                                               header_parameters_,
                                               query_parameters_);
   
     error_msg_ := CompleteTaskWithtPartReqError___(payload_);
      
      IF (error_msg_ != 'SUCCESS') THEN
         Error_SYS.Record_General(lu_name_, error_msg_);
      END IF;
      
   $ELSE
      NULL;
   $END

END CompleteTaskWithPartReq___;



/**
Error Handling method CompleteTaskWithtPartReqError___
**/
FUNCTION CompleteTaskWithtPartReqError___ (
   payload_              IN VARCHAR2) RETURN VARCHAR2
IS
   response_jo_         JSON_OBJECT_T;
   error_msg_           VARCHAR2(2000);
BEGIN
    BEGIN
     
       -- Extract response body into an JSON object.  
       response_jo_ := JSON_OBJECT_T(payload_);
      
       -- Extract error response message into an JSON object.  
       error_msg_ := response_jo_.get_String('message');
      
       -- Identify success response from the 'taskAltid' param in the body.
       IF ( response_jo_.get_String('taskAltid') IS NOT NULL ) THEN       
          RETURN 'SUCCESS';
          
       -- Identify error response from the 'message' param in the body.
       ELSIF (error_msg_ IS NOT NULL ) THEN 
          RETURN 'MXCOMPLETEERR: Maintenix task completion failed with error - ' || error_msg_;
          
       -- If respose body is error but not in the format expected. 
       ELSIF (response_jo_.get_String('taskAltid') IS NULL ) THEN       
          RETURN 'MXFAILRERR: Maintenix task completion failed.';
       END IF;
      
    EXCEPTION WHEN OTHERS THEN 
      -- Unexpected error in the response body.
      Error_SYS.Record_General(lu_name_, 'MXUNEXPECTEDERR: Unexpected Response Error, Response Body - :P1', dbms_lob.substr( payload_, 1500, 1 ));
      
    END;
END CompleteTaskWithtPartReqError___;


PROCEDURE PublishWorkPackageModify___ (
   wp_id_        IN OUT NUMBER)
IS
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      parameters_             Mx_connect_Util_API.url_param_;
      header_parameters_      Mx_connect_Util_API.header_param_;
      query_parameters_       Mx_connect_Util_API.query_param_;
      payload_       CLOB;
      response_jo_            JSON_OBJECT_T;
   $END

   -- service name represents the API  to start wp at maintenix
   rest_service_         VARCHAR2(50):= 'MX_START_WP';
   http_method_          VARCHAR2(10) := 'PUT';
   work_package_alt_id_         VARCHAR2(50);

   CURSOR work_package_alt_id IS 
      SELECT wp.alt_id
      FROM av_aircraft_work_package_tab wp
      WHERE wp.aircraft_work_package_id = wp_id_;

BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN
      IF wp_id_ IS NOT NULL THEN
         OPEN work_package_alt_id;
         FETCH work_package_alt_id INTO work_package_alt_id_;
         CLOSE work_package_alt_id;

         parameters_('param1') := work_package_alt_id_; 
         payload_ := '{"status": "IN WORK"}';
                  
         Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                               payload_,
                                               http_method_,
                                               '200',
                                               parameters_,
                                               header_parameters_,
                                               query_parameters_);
                                               
         -- Extract response body into an JSON object
         response_jo_ := JSON_OBJECT_T(payload_);

      END IF;  
   END IF;
   $ELSE
      NULL;
   $END
END PublishWorkPackageModify___;


FUNCTION Get_Wp_Id(
  objid_   IN VARCHAR2 ) RETURN NUMBER
IS
   aircraft_wp_id_ NUMBER;  
   wp_status_ VARCHAR2(50); 
   CURSOR get_wp_id IS
      SELECT aircraft_wp_id
      FROM   av_exe_task_tab t
      WHERE  t.rowid  = objid_;
   
   CURSOR get_work_package_status IS
      SELECT rowstate
      FROM   av_aircraft_work_package_tab t
      WHERE  t.aircraft_work_package_id  = (SELECT aircraft_wp_id
                                            FROM   av_exe_task_tab e
                                            WHERE  e.rowid  = objid_);
BEGIN  
   OPEN  get_wp_id;
   FETCH get_wp_id INTO aircraft_wp_id_;
   CLOSE get_wp_id;
   
   OPEN  get_work_package_status;
   FETCH get_work_package_status INTO wp_status_;
   CLOSE get_work_package_status;
   
   IF wp_status_ = 'Active' OR wp_status_ = 'Committed' THEN
      RETURN aircraft_wp_id_;
   ELSE
      RETURN NULL;
   END IF;

   EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END Get_Wp_Id ;

/*
* This method is publishing Package Fault With Existing Work Package in to Maintenix.
*/
PROCEDURE PublishPackageFaultExistingWP (
   newrec_        IN OUT av_exe_task_tab%ROWTYPE)
IS

   wp_barcode_           VARCHAR2(80);
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   -- Params required for the HTTP request
   url_parameters_         Mx_connect_Util_API.url_param_;
   header_parameters_      Mx_connect_Util_API.header_param_;
   query_parameters_       Mx_connect_Util_API.query_param_;
   $END
   
   payload_                CLOB;
   response_ja_            JSON_ARRAY_T;
   response_jo_            JSON_OBJECT_T;
   rest_service_           VARCHAR2(50):= 'MX_PACKAGE_FAULT_WITH_EXISTING_WP';
   http_method_            VARCHAR2(10) := 'POST';
   error_msg_              VARCHAR2(2000);


   -- Get aircraft wp barcode from the work package
 CURSOR get_aircraft_wp_barcode IS
    SELECT barcode
    FROM   av_aircraft_work_package_tab
    WHERE  av_aircraft_work_package_tab.aircraft_work_package_id = newrec_.aircraft_wp_id;
   
BEGIN 
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN
      OPEN get_aircraft_wp_barcode;
      FETCH get_aircraft_wp_barcode INTO wp_barcode_;
      CLOSE get_aircraft_wp_barcode;

     -- Build the payload
        payload_ := '{ 
                    "workPackage": "'|| wp_barcode_ ||'",
                    "tasks": [
                              { 
                                "task" : "'|| newrec_.barcode ||'", 
                                "scheduledStartDate" : "'||TO_CHAR(cast(newrec_.sched_start_date_time AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"')||'" 
                              }
                             ]
                    }';


     -- Call REST endpoint
        Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                              payload_,
                                              http_method_,
                                              '207',
                                              url_parameters_,
                                              header_parameters_,
                                              query_parameters_);
   END IF;
   
   $ELSE
    NULL;
   $END

END PublishPackageFaultExistingWP;


/*
* This method is publishing Package Fault Without Existing Work Package in to Maintenix.
*/
PROCEDURE PublishPackageFaultWithNewWP (
   newrec_        IN OUT av_exe_task_tab%ROWTYPE)
IS
   work_package_name_      VARCHAR2(500);
   sched_start_date_time_  DATE;
   sched_end_date_time_    DATE;
   location_code_          VARCHAR2(1000);
   actf_alt_id_            VARCHAR2(60);
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   -- Params required for the HTTP request
   url_parameters_         Mx_connect_Util_API.url_param_;
   header_parameters_      Mx_connect_Util_API.header_param_;
   query_parameters_       Mx_connect_Util_API.query_param_;
   $END
   payload_                CLOB;
   response_ja_            JSON_ARRAY_T;
   response_jo_            JSON_OBJECT_T; 
   rest_service_           VARCHAR2(50) := 'MX_AMAPI_BATCH';
   http_method_            VARCHAR2(10) := 'POST';
   error_msg_              VARCHAR2(2000);

   CURSOR get_work_package_details IS
      SELECT work_package_name, sched_start_date_time, sched_end_date_time, location_code
      FROM   av_aircraft_work_package_tab t
      WHERE  t.aircraft_work_package_id  = (SELECT aircraft_wp_id
                                            FROM   av_exe_task_tab e
                                            WHERE  e.task_id  = newrec_.task_id);                              
BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF (Mx_Config_API.Is_Maintenix_Connected) THEN

         actf_alt_id_ := Aircraft_API.Get_Alt_Id(newrec_.aircraft_id);

         OPEN  get_work_package_details;
         FETCH get_work_package_details INTO work_package_name_, sched_start_date_time_, sched_end_date_time_, location_code_;
         CLOSE get_work_package_details;    

         -- Build the payload 
         payload_ := Build_Payload_for_Pack_Fault_New_WP___(location_code_, work_package_name_, actf_alt_id_, newrec_.barcode, sched_start_date_time_, sched_end_date_time_);

         -- Call REST endpoint
          Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                                  payload_,
                                                  http_method_,
                                                  '207,400,500',
                                                  url_parameters_,
                                                  header_parameters_,
                                                  query_parameters_);


         -- Validate if the response body is a success.
         BEGIN      
            -- Extract response body into an JSON object.
            response_ja_ := JSON_ARRAY_T.parse(payload_);
            response_jo_ := JSON_OBJECT_T(response_ja_.get(0));
            EXCEPTION WHEN OTHERS THEN

         -- If response body cannot be parsed the same way that a success response body is parsed,
         -- But it can be parse as below, that is considered as an handled error scenario.
            BEGIN
               error_msg_ := PublishPackageFaultWithNewWPError___(payload_, newrec_.aircraft_wp_id, newrec_.barcode, location_code_);
               IF (error_msg_ != 'SUCCESS') THEN
                  Error_SYS.Record_General(lu_name_, error_msg_);
               END IF;
            END;
         END;
      END IF;
   $ELSE
      NULL;
   $END
END PublishPackageFaultWithNewWP;

/*
   Constructing the individual item for the apiCalls array used in
   PublishPackageFaultWithNewWP (MX_AMAPI_BATCH)
*/
FUNCTION Build_JSON_Obj_for_Batch_API___(
   rest_method_         IN VARCHAR2,
   rest_endpoint_url_   IN VARCHAR2,
   json_body_           IN JSON_OBJECT_T DEFAULT NULL) RETURN JSON_OBJECT_T
IS
   jo_nested_inst_      JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   request_obj_inst_    JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   header_obj_inst_     JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   header_arr_inst_     JSON_ARRAY_T  := JSON_ARRAY_T('[]');
BEGIN  
   jo_nested_inst_.put('method', rest_method_);
   header_arr_inst_.append('application/json');
   header_obj_inst_.put('Content-Type', header_arr_inst_);
   jo_nested_inst_.put('headers', header_obj_inst_);
   jo_nested_inst_.put('url', rest_endpoint_url_);            

   IF(json_body_ IS NOT NULL) THEN
     jo_nested_inst_.put('body', json_body_);
   ELSE
     jo_nested_inst_.put('body', JSON_OBJECT_T.parse('{}'));
   END IF;
   request_obj_inst_.put('request', jo_nested_inst_);

   RETURN request_obj_inst_;
END Build_JSON_Obj_for_Batch_API___;

/*
   Constructing the JSON payload for PublishPackageFaultWithNewWP (MX_AMAPI_BATCH)
*/
FUNCTION Build_Payload_for_Pack_Fault_New_WP___(
   location_code_             IN VARCHAR2,
   work_package_name_         IN VARCHAR2,
   actf_alt_id_               IN VARCHAR2,
   barcode_                   IN VARCHAR2,
   sched_start_date_time_     IN DATE,
   sched_end_date_time_       IN DATE) RETURN VARCHAR2
IS
   temp_jo_inst_              JSON_OBJECT_T;
   jo_payload_                JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   jo_item_2_                 JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   jo_item_4_                 JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   jo_item_5_                 JSON_OBJECT_T := JSON_OBJECT_T.parse('{}');
   ja_inst_                   JSON_ARRAY_T  := JSON_ARRAY_T('[]');
BEGIN  
   --Constructing the 1st item for apiCall array
   --Building an API request to get location ALT_ID by LOCATION_CODE.
   temp_jo_inst_ := Build_JSON_Obj_for_Batch_API___('GET', 'erp/location?code=' || location_code_ || '' );
   ja_inst_.append(temp_jo_inst_);

   --Constructing the 2nd item for apiCall array
   --Building an API request to create a new WP based on given sched dates and aircraft   
   jo_item_2_.put('name', work_package_name_);
   jo_item_2_.put('status', 'ACTV');
   jo_item_2_.put('inventoryId', actf_alt_id_);
   jo_item_2_.put('taskClass', 'CHECK');
   jo_item_2_.put('schedEndDate', TO_CHAR(cast(sched_end_date_time_ AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
   jo_item_2_.put('schedStartDate', TO_CHAR(cast(sched_start_date_time_ AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
   jo_item_2_.put('locationId', '{result=0:$.[0].id}');
   temp_jo_inst_ := Build_JSON_Obj_for_Batch_API___('POST', 'maintenance/exec/work/pkg', jo_item_2_);
   ja_inst_.append(temp_jo_inst_);

   --Constructing the 3rd item for apiCall array   
   --Building an API request to get Task/Fault ALT_ID to assign it to WP
   temp_jo_inst_ := Build_JSON_Obj_for_Batch_API___('GET', 'maintenance/exec/task?barcode=' ||  barcode_  || '');
   ja_inst_.append(temp_jo_inst_);

   --Constructing the 4th item for apiCall array
   --Building an API request to assign the Task/Fault to the newly created WP
   jo_item_4_.put('workPackageId', '{result=1:$.id}');
   jo_item_4_.put('scheduledStartDate', TO_CHAR(cast(sched_start_date_time_ AS TIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
   temp_jo_inst_ := Build_JSON_Obj_for_Batch_API___('PUT', 'maintenance/exec/task/{result=2:$.[0].id}', jo_item_4_);
   ja_inst_.append(temp_jo_inst_);

   --Constructing the 5th item for apiCall array
   --Building an API request to set the newly created WP to 'COMMIT' state   
   jo_item_5_.put('status', 'COMMIT');
   temp_jo_inst_ := Build_JSON_Obj_for_Batch_API___('PUT', 'maintenance/exec/work/pkg/{result=1:$.id}', jo_item_5_);
   ja_inst_.append(temp_jo_inst_);
   
   --Finally the JSON Array ja_inst_ is added to the JSON object jo_payload_.
   jo_payload_.put('apiCalls', ja_inst_);
   RETURN jo_payload_.to_string;
END Build_Payload_for_Pack_Fault_New_WP___;

/*
   Error handling for publish package fault with new WP.
*/
FUNCTION PublishPackageFaultWithNewWPError___ (
   payload_             IN CLOB, 
   aircraft_wp_id_      IN NUMBER,
   barcode_             IN VARCHAR2,
   location_code_       IN VARCHAR2) RETURN VARCHAR2
IS
   wp_barcode_          VARCHAR2(80);
   response_jo_         JSON_OBJECT_T;
   api_jo_              JSON_OBJECT_T;
   temp_jo_             JSON_OBJECT_T;   
   error_msg_           VARCHAR2(2000);
   api_arr_             JSON_ARRAY_T;
   temp_arr_            JSON_ARRAY_T;
   temp_element_        JSON_ELEMENT_T;
BEGIN
   BEGIN
      response_jo_ := JSON_OBJECT_T(payload_);
      api_arr_     := response_jo_.get_array('apiCalls');

      FOR i IN 0 .. api_arr_.get_size - 1 LOOP
         api_jo_ := TREAT(api_arr_.get(i) AS JSON_OBJECT_T);

         temp_element_ :=  api_jo_.get_object('response').get('body');
         IF (temp_element_.IS_OBJECT) THEN 
            temp_jo_   := TREAT(temp_element_ AS JSON_OBJECT_T);
            error_msg_ := temp_jo_.get_string('message');
            IF (i = 4) THEN
               wp_barcode_ := temp_jo_.get_string('barcode');
            END IF;   
         ELSIF (temp_element_.IS_ARRAY) THEN
            temp_arr_  := TREAT(temp_element_ AS JSON_ARRAY_T);
            temp_jo_   := TREAT(temp_arr_.get('0') AS JSON_OBJECT_T);
            IF (temp_arr_.get_size() = 0) THEN
               IF (i = 0) THEN
                  RETURN 'MXNOLOCERR: LOCATION_CODE ' || location_code_ ||' not found';
               ELSIF (i = 2) THEN 
                  RETURN 'MXNOTSKBCODEERR: BARCODE ' || barcode_ ||' not found';
               ELSE 
                  error_msg_ := temp_jo_.get_string('message');
               END IF;
            END IF;   
         END IF;

         IF (error_msg_ IS NOT NULL) THEN
            RETURN 'MXPACKAGEFAULTERR: Maintenix packaging fault failed with error - ' || error_msg_;
         END IF;
      END LOOP; 
         
      -- Execution comes to this point if all the validations are successful.
      -- Then modify the work package entity.
      IF (wp_barcode_ IS NULL )THEN
         RETURN 'MXNOBARCODEERR: Work Package Barcode not found in response';
      END IF;
      Av_Aircraft_Work_Package_API.Update_Barcode(aircraft_wp_id_, wp_barcode_);

      RETURN 'SUCCESS';
   EXCEPTION WHEN OTHERS THEN
      
      -- Unexpected error in the response body.
      Error_SYS.Record_General(lu_name_, 'MXPACKAGEFAULT: Unexpected Response Error, Response Body - :P1', dbms_lob.substr( payload_, 1500, 1 ));
   END;
END PublishPackageFaultWithNewWPError___;

/**
Return Task part Change String to Payload
**/
FUNCTION Get_Part_Changes_Str_For_Task(task_id_ IN NUMBER)RETURN VARCHAR2
   
IS 
   part_changes_str_ VARCHAR2(32000):=NULL;
   part_changes_str_each_ VARCHAR2(1000);
   inx1_ PLS_INTEGER:=0;
   no_part_changes_ PLS_INTEGER:=0;
   
   CURSOR get_part_changes IS
      SELECT DISTINCT f.part_request_id
      FROM   av_exe_task_part_tab f
      WHERE  f.task_id = task_id_; 
   
   
BEGIN 
   
   part_changes_str_ :='';
   
   --get the total Number of partchanges 
   FOR rec_ IN get_part_changes LOOP
      inx1_ := inx1_ + 1;
   END LOOP;
   no_part_changes_ := inx1_; 
   
   
   FOR rec_ IN get_part_changes LOOP
      
      IF rec_.part_request_id IS NOT NULL THEN    
         part_changes_str_each_:= Av_Exe_Task_Part_API.Get_Part_Change_by_Part_Req(rec_.part_request_id);   
         part_changes_str_ := part_changes_str_ ||''||part_changes_str_each_||'';
         IF no_part_changes_ = 1 AND no_part_changes_>0 THEN 
            RETURN part_changes_str_;
         ELSE 
            part_changes_str_ := part_changes_str_ ||',';
            no_part_changes_ := no_part_changes_ -1 ;
         END IF;          
      END IF;
   END LOOP;  
   RETURN part_changes_str_;
   
END Get_Part_Changes_Str_For_Task;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_tab.task_id%TYPE;
   
   CURSOR get_task_id IS 
      SELECT task_id         
        FROM av_exe_task_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_id;
   FETCH get_task_id INTO temp_; 
   CLOSE get_task_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Aircraft_Id_By_Mx_Uniq_Key (
   ac_mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ aircraft_tab.aircraft_id%TYPE;
   
   CURSOR get_aircraft_id IS 
      SELECT aircraft_id         
        FROM aircraft_tab
       WHERE mx_unique_key = ac_mx_unique_key_;
BEGIN
   OPEN get_aircraft_id;
   FETCH get_aircraft_id INTO temp_; 
   CLOSE get_aircraft_id;
   
   RETURN temp_;
END Get_Aircraft_Id_By_Mx_Uniq_Key;

FUNCTION Get_Ac_Wp_Id_By_Mx_Unique_Key (
   wp_mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_aircraft_work_package_tab.aircraft_work_package_id%TYPE;
   
   CURSOR get_aircraft_work_package_id IS 
      SELECT aircraft_work_package_id         
        FROM av_aircraft_work_package_tab
       WHERE mx_unique_key = wp_mx_unique_key_;
BEGIN
   OPEN get_aircraft_work_package_id;
   FETCH get_aircraft_work_package_id INTO temp_; 
   CLOSE get_aircraft_work_package_id;
   
   RETURN temp_;
END Get_Ac_Wp_Id_By_Mx_Unique_Key;

FUNCTION Get_Fault_Id_By_Mx_Unique_Key (
   fault_mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_tab.fault_id%TYPE;
   
   CURSOR get_fault_id IS 
      SELECT fault_id         
        FROM av_fault_tab
       WHERE mx_unique_key = fault_mx_unique_key_;
BEGIN
   OPEN get_fault_id;
   FETCH get_fault_id INTO temp_; 
   CLOSE get_fault_id;
   
   RETURN temp_;
END Get_Fault_Id_By_Mx_Unique_Key;

-- This procedure will be used to set the task state from the Migration Job 200_FLM_EXE_TASK
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_    IN VARCHAR2,
   state_            IN VARCHAR2)
IS
   task_id_          av_exe_task_tab.task_id%TYPE;
   objid_            av_exe_task.objid%TYPE;
   objversion_       av_exe_task.objversion%TYPE;
   from_state_       av_exe_task_tab.rowstate%TYPE;
BEGIN
   task_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(task_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, task_id_);
      from_state_      := Get_Objstate(task_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;


PROCEDURE Update_Rowversion_For_Native (
   task_id_ IN NUMBER)
IS
   av_task_rec_      Av_Exe_Task_Tab%ROWTYPE;
   objid_            VARCHAR2(100);
   attr_             VARCHAR2(100);
   objversion_       VARCHAR2(100);
   
   CURSOR get_rowid IS
      SELECT   rowid 
      FROM     Av_Exe_Task_Tab
      WHERE    task_id = task_id_;
      
BEGIN
   av_task_rec_ := Get_Object_By_Keys___(task_id_);

   OPEN  get_rowid;
   FETCH get_rowid INTO objid_;
   CLOSE get_rowid;
   
   Update___(objid_, av_task_rec_, av_task_rec_, attr_, objversion_);
   
END Update_Rowversion_For_Native;

/*
   After packaging the fault add skills, tools, actions to corresponding task
*/
PROCEDURE CopyChanges (
   newrec_        IN OUT av_exe_task_tab%ROWTYPE)
IS  
    CURSOR get_fault_skills IS
    SELECT *
    FROM   av_fault_labour_tab
    WHERE  av_fault_labour_tab.fault_id = newrec_.fault_id AND av_fault_labour_tab.labour_status = 'ACTIVE';
    
    CURSOR get_fault_tools IS
    SELECT *
    FROM   av_fault_tool_tab
    WHERE  av_fault_tool_tab.fault_id = newrec_.fault_id;
    
    CURSOR get_fault_actions IS
    SELECT *
    FROM   av_fault_action_tab
    WHERE  av_fault_action_tab.fault_id = newrec_.fault_id;
   
 BEGIN
    FOR rec_ IN get_fault_skills LOOP
      IF(NOT Av_Exe_Task_Labour_API.Exists(rec_.fault_labour_id)) THEN
         Av_Exe_Task_Labour_API.New(rec_.fault_labour_id, newrec_.task_id, rec_.competency_id, rec_.num_people_required, rec_.hours_per_person, NULL, rec_.mx_unique_key);
      END IF; 
    END LOOP;
    
   FOR rec_ IN get_fault_tools LOOP
      IF(NOT Av_Exe_Task_Tool_API.Exists(rec_.fault_tool_id)) THEN
         Av_Exe_Task_Tool_API.New(rec_.fault_tool_id, newrec_.task_id, rec_.tool_specification_code, rec_.part_number_id, rec_.serial_no, rec_.assigned_user, rec_.scheduled_hours, rec_.mx_unique_key);
      END IF; 
   END LOOP;
   
   FOR rec_ IN get_fault_actions LOOP
      IF(NOT Av_Exe_Task_Action_API.Exists(rec_.fault_action_id)) THEN
         Av_Exe_Task_Action_API.New(rec_.fault_action_id, newrec_.task_id, rec_.action_ord, rec_.action_user, rec_.action_desc, rec_.action_date, rec_.mx_unique_key, 'Deferred');
      END IF; 
   END LOOP;  
END CopyChanges;
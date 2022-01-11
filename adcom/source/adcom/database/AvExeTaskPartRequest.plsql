-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskPartRequest
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210419  dildlk  AD-1064, Modified Insert___
--  210419  siselk  AD-1032, Modified PublishRequestPart___ by adding IsRepairable
--  210415  dildlk  AD-1064, Added Delete_Rec and override Delete___
--  210324  rosdlk  AD-1041, Added alt_id to attr string to copy to the AvFaultPartRequest alt_id 
--  210324  siselk  AD-1056, Changed PRIORITY_DB to PRIORITY in Insert___ and Modify__
--  210321  SWiclk  LMM2020R1-1908, Modified PublishRequestPart___ in order to check Mx_Config_API.Is_Maintenix_Connected  
--  210319  majslk  AD-1080, Updated Insert___ method and added the Update___ method.
--  210309  lahnlk  LMM2020R1-1824, Modified PublishRequestPart___
--  210307  SatGlk  LMM2020R1-1895, Modified overridden Insert___ to include MX_UNIQUE_KEY when making a new Fault Part Request.
--  210211  aruflk  LMM2020R1-1476, Modified PublishRequestPartError___(), Pre_Sync_Action() and added Get_Id_Version_By_Natural_Key().
--  210111  majslk  LMM2020R1-1478, Updated check_insert__.
--  201125  aruflk  AD2020R1-1053, Modified Insert___() and Modify__().
--  201118  SUPKLK  LMM2020R1-1160, Implemented functions to get keys to handle data migration
--  201118  SUPKLK  LMM2020R1-1160, Added Get_Key_By_Mx_Unique_Key function to handle duplicates in data migration
--  201014  KAWJLK  LMM2020R1-1352, Added conditional compilation for Component_Mxcore_SYS.
--  201012  TAJALK  LMM2020R1-1319, Fixed Duplicate Message Constant 
--  201008  lahnlk  LMM2020R1-1309, overtake Modify__ ,added Modify
--  200929  lahnlk  LMM2020R1-1273, overtake Check_Insert___
--  200918  SatGlk  LMM2020R1-811, Added Get_Id_Version_By_Mx_Uniq_Key, Pre_Sync_Action
--  200917  hasmlk  LMM2020R1-548: Publish part requirement.
--  200803  aruflk  LMM2020R1-448, Get_Next_Seq(), Added Insert___() and modified Check_Insert___().
--  200731  aruflk  LMM2020R1-448, Added New().
--  200728  lahnlk  LMM2020R1-429, modified Get_Task_Part_Request_Count function
--  200626  sevhlk  LMM2020R1-164, Added Get_Material_Availability().    
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_part_request_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_exe_task_part_request_tab%ROWTYPE;
   fault_part_request_id_ NUMBER;
   
   CURSOR get_fault_part_request(mx_unique_key_ VARCHAR2) IS
      SELECT fault_part_request_id
      FROM   av_fault_part_request_tab
      WHERE  mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_fault_part_request(newrec_.mx_unique_key);
   FETCH get_fault_part_request INTO fault_part_request_id_;
   CLOSE get_fault_part_request;
   
   IF ((newrec_.task_part_request_id < 0) OR (newrec_.task_part_request_id IS NULL)) THEN
      IF fault_part_request_id_ IS NULL THEN 
         newrec_.task_part_request_id := Av_Exe_Task_Part_Request_API.Get_Next_Seq();
      ELSE
         newrec_.task_part_request_id := fault_part_request_id_;
      END IF;
      Client_SYS.Add_To_Attr('TASK_PART_REQUEST_ID', newrec_.task_part_request_id, attr_);
   END IF;
   --Validate_SYS.Item_Insert(lu_name_, 'TASK_PART_REQUEST_ID', indrec_.task_part_request_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_exe_task_part_request_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   fault_id_   NUMBER;
   inventory_class_code_      VARCHAR2(50);
   is_repairable_             VARCHAR2(20);
   
   -- Get inventory_class_code and is_repairable by part number.
   CURSOR get_repaiable_bool (part_number_id_ IN NUMBER) IS 
   SELECT av_part_number.inventory_class_code, av_part_number.is_repairable
   FROM av_part_number
   WHERE av_part_number.part_number_id = part_number_id_;
   
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   
   IF(fault_id_ IS NOT NULL AND NOT Av_Fault_Part_Request_API.Exists(newrec_.task_part_request_id)) THEN
      Client_SYS.Add_To_Attr('FAULT_PART_REQUEST_ID',   newrec_.task_part_request_id,    attr_);
      Client_SYS.Add_To_Attr('FAULT_ID',                fault_id_,                       attr_);
      Client_SYS.Add_To_Attr('AIRCRAFT_TYPE_CODE',      newrec_.aircraft_type_code,      attr_);
      Client_SYS.Add_To_Attr('PART_NUMBER_ID',          newrec_.part_number_id,          attr_);
      Client_SYS.Add_To_Attr('REQUIRED_QUANTITY',       newrec_.required_quantity,       attr_);
      Client_SYS.Add_To_Attr('AVAILABILITY_STATUS_DB',  'OPEN',                          attr_);
      Client_SYS.Add_To_Attr('PRIORITY',                newrec_.priority,                attr_);
      Client_SYS.Add_To_Attr('PART_GROUP_ID',           newrec_.part_group_id,           attr_);
      Client_SYS.Add_To_Attr('CONFIG_SLOT_CODE',        newrec_.config_slot_code,        attr_);
      Client_SYS.Add_To_Attr('CONFIG_SLOT_POSITION_CODE', newrec_.config_slot_position_code, attr_);
      Client_SYS.Add_To_Attr('MX_UNIQUE_KEY',           newrec_.mx_unique_key,           attr_);
      Client_SYS.Add_To_Attr('ALT_ID',                  newrec_.alt_id,                  attr_);
      
      Av_Fault_Part_Request_API.New(attr_);
   END IF;  
   
   -- Check if Maintenix is connected.
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
         
         -- Publish request part to Maintenix.
         PublishRequestPart___(newrec_);      

         OPEN get_repaiable_bool(newrec_.part_number_id);
         FETCH get_repaiable_bool INTO inventory_class_code_,is_repairable_;
         CLOSE get_repaiable_bool;

         IF (inventory_class_code_ != 'BATCH' OR (inventory_class_code_ = 'BATCH' AND is_repairable_ = 'True'))THEN
         -- add removed task part change

         Av_Exe_Task_Part_API.New(NULL, newrec_.task_id, newrec_.config_slot_position_code, newrec_.part_group_id, 
                                  newrec_.part_number_id, NULL , NULL , NULL , newrec_.required_quantity,
                                  NULL, NULL , NULL , NULL, NULL , newrec_.task_part_request_id,  NULL );
         END IF;

         -- add installed task part change
         Av_Exe_Task_Part_API.New(NULL, newrec_.task_id, newrec_.config_slot_position_code, newrec_.part_group_id, 
                                  NULL, NULL, newrec_.part_number_id, NULL, NULL, NULL, NULL, newrec_.required_quantity, 
                                  NULL, NULL, newrec_.task_part_request_id, NULL);
      END IF;
   $END
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(newrec_.task_id);
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_exe_task_part_request_tab%ROWTYPE,
   newrec_     IN OUT av_exe_task_part_request_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
      
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(newrec_.task_id);
      END IF;
   END IF;
END Update___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_exe_task_part_request_tab%ROWTYPE )
IS
   fault_id_   NUMBER;
BEGIN
   super(objid_, remrec_);  
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(remrec_.task_id);  
   IF(fault_id_ IS NOT NULL AND Av_Fault_Part_Request_API.Exists(remrec_.task_part_request_id)) THEN
      Av_Fault_Part_Request_API.Delete_Rec(remrec_.task_part_request_id);     
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF remrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(remrec_.task_id);
      END IF;
   END IF;
   
END Delete___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Overtake Base
PROCEDURE Modify__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   oldrec_   av_exe_task_part_request_tab%ROWTYPE;
   newrec_   av_exe_task_part_request_tab%ROWTYPE;
   indrec_   Indicator_Rec;
   fault_id_   NUMBER;
BEGIN
   IF (action_ = 'CHECK') THEN
      oldrec_ := Get_Object_By_Id___(objid_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
   ELSIF (action_ = 'DO') THEN
      oldrec_ := Lock_By_Id___(objid_, objversion_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_);
      
      fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
      
      IF(fault_id_ IS NOT NULL AND Av_Fault_Part_Request_API.Exists(newrec_.task_part_request_id)) THEN
         Client_SYS.Add_To_Attr('FAULT_ID',                fault_id_,                       attr_);
         Client_SYS.Add_To_Attr('AIRCRAFT_TYPE_CODE',      newrec_.aircraft_type_code,      attr_);
         Client_SYS.Add_To_Attr('PART_NUMBER_ID',          newrec_.part_number_id,          attr_);
         Client_SYS.Add_To_Attr('REQUIRED_QUANTITY',       newrec_.required_quantity,       attr_);
         Client_SYS.Add_To_Attr('AVAILABILITY_STATUS_DB',  newrec_.availability_status,     attr_);
         Client_SYS.Add_To_Attr('PRIORITY',                newrec_.priority,                attr_);
         Client_SYS.Add_To_Attr('PART_GROUP_ID',           newrec_.part_group_id,           attr_);
         Client_SYS.Add_To_Attr('CONFIG_SLOT_CODE',        newrec_.config_slot_code,        attr_);
         Client_SYS.Add_To_Attr('CONFIG_SLOT_POSITION_CODE', newrec_.config_slot_position_code, attr_);
         Client_SYS.Add_To_Attr('MX_UNIQUE_KEY',           newrec_.mx_unique_key,           attr_);
         Client_SYS.Add_To_Attr('ALT_ID',                  newrec_.alt_id,                  attr_);
         
         Av_Fault_Part_Request_API.Modify(newrec_.task_part_request_id,attr_);
      END IF;  
      
   END IF;
   info_ := Client_SYS.Get_All_Info;
END Modify__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Material_Availability(
   task_id_ IN NUMBER) RETURN VARCHAR2
IS 
   available_parts_count_     NUMBER;
   not_available_parts_count_ NUMBER;
   issued_parts_count_        NUMBER;
   
   CURSOR get_available_parts_ IS
   SELECT COUNT(availability_status)
   FROM av_exe_task_part_request_tab 
   WHERE task_id = task_id_
   AND availability_status = 'Available';
   
   CURSOR get_not_available_parts_ IS
   SELECT COUNT(availability_status)
   FROM av_exe_task_part_request_tab 
   WHERE task_id = task_id_
   AND availability_status = 'Open';
   
   CURSOR get_issued_parts_ IS
   SELECT COUNT(availability_status)
   FROM av_exe_task_part_request_tab 
   WHERE task_id = task_id_
   AND availability_status = 'Issued';
BEGIN
   OPEN get_available_parts_;
   OPEN get_not_available_parts_;
   OPEN get_issued_parts_;
   FETCH get_available_parts_ INTO available_parts_count_;
   FETCH get_not_available_parts_ INTO not_available_parts_count_;
   FETCH get_issued_parts_ INTO issued_parts_count_;
   
   IF available_parts_count_ > 0 AND not_available_parts_count_ = 0 AND issued_parts_count_ = 0 THEN
      RETURN 'Avail';
   ELSIF available_parts_count_ = 0 AND not_available_parts_count_ > 0 AND issued_parts_count_ = 0 THEN 
      RETURN 'Open';
   ELSIF available_parts_count_ = 0 AND not_available_parts_count_ = 0 AND issued_parts_count_ > 0 THEN 
      RETURN 'Issued';
   ELSIF available_parts_count_ = 0 AND not_available_parts_count_ = 0 AND issued_parts_count_ = 0 THEN  
      RETURN 'N/A';
   ELSE 
      RETURN 'Partially Available';
   END IF;
   CLOSE get_available_parts_;
   CLOSE get_not_available_parts_;
   CLOSE get_issued_parts_;
END Get_Material_Availability;

FUNCTION Get_Task_Part_Request_Count(
   task_id_ IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
   
   CURSOR get_task_part_req_count IS
      SELECT   COUNT(*)
      FROM     av_exe_task_part_request_tab
      WHERE    task_id = task_id_
      AND availability_status != Part_Req_Avail_Status_API.DB_CANCELED;
BEGIN
   OPEN  get_task_part_req_count;
   FETCH get_task_part_req_count INTO output_;
   CLOSE get_task_part_req_count;
   
   RETURN output_;
END Get_Task_Part_Request_Count;

PROCEDURE New (
   attr_ IN OUT VARCHAR2 )
IS
   info_       VARCHAR2(32000);
   objid_      VARCHAR2(32000);
   objversion_ VARCHAR2(32000);
BEGIN
   New__(info_, objid_, objversion_, attr_, 'DO');
END New;

FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT AV_EXE_TASK_PART_REQUEST_SEQ.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN (seq_no_);
END Get_Next_Seq;


/*
   This method is publishing the part request to Maintenix.
*/
PROCEDURE PublishRequestPart___ (
   newrec_ IN OUT av_exe_task_part_request_tab%ROWTYPE )
IS
   
   -- Params required to modify the part request record
   info_       VARCHAR2(32000);
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   
   -- Params required for the HTTP request
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      url_parameters_         Mx_Connect_Util_API.url_param_;
      header_parameters_      Mx_Connect_Util_API.header_param_;
      query_parameters_       Mx_Connect_Util_API.query_param_;
   $END
   payload_                CLOB;
   response_jo_            JSON_OBJECT_T;
   
   -- Params required for the request spec
   rest_service_        VARCHAR2(50):= 'MX_REQUEST_PART';
   http_method_         VARCHAR2(10) := 'POST';
   
   -- Params required for the payload
   jo_                              JSON_OBJECT_T;
   jo_nested_inst_                  JSON_OBJECT_T;
   ja_inst_                         JSON_ARRAY_T;
   jo_nested_rmvd_                  JSON_OBJECT_T;
   ja_rmvd_                         JSON_ARRAY_T;
   task_alt_id_                     VARCHAR2(50);
   config_slot_position_alt_id_     VARCHAR2(50);
   part_group_alt_id_               VARCHAR2(50);
   part_number_alt_id_              VARCHAR2(50);
   inventory_class_code_            VARCHAR2(50);
   is_repairable_                   VARCHAR2(20);
   error_msg_                       VARCHAR2(2000);
   
   -- Get task alt_id from task.
   CURSOR get_task_alt_id (task_id_ IN NUMBER) IS 
      SELECT av_exe_task_tab.alt_id
      FROM av_exe_task_tab
      WHERE av_exe_task_tab.task_id = task_id_;
   
   -- Get config slot position alt_id by position.
   CURSOR get_config_pos_alt_id (
      config_slot_position_code_ IN VARCHAR2, 
      config_slot_code_ IN VARCHAR2,
      aircraft_type_code_ IN VARCHAR2
   ) IS
      SELECT av_config_slot_position.alt_id
      FROM av_config_slot_position
      WHERE av_config_slot_position.config_slot_position_code = config_slot_position_code_ AND
         av_config_slot_position.config_slot_code = config_slot_code_ AND
         av_config_slot_position.aircraft_type_code = aircraft_type_code_;
   
   -- Get part group alt_id by part group.
   CURSOR get_part_group_alt_id (part_group_id_ IN NUMBER) IS 
      SELECT av_part_group.alt_id
      FROM av_part_group
      WHERE av_part_group.part_group_id = part_group_id_;
   
   -- Get part number alt_id by part number.
   CURSOR get_part_number_alt_id (part_number_id_ IN NUMBER) IS 
      SELECT av_part_number.alt_id, av_part_number.inventory_class_code, av_part_number.is_repairable
      FROM av_part_number
      WHERE av_part_number.part_number_id = part_number_id_;
BEGIN
   
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN
      OPEN get_task_alt_id(newrec_.task_id);
      FETCH get_task_alt_id INTO task_alt_id_;
      CLOSE get_task_alt_id;
      
      OPEN get_config_pos_alt_id (
         newrec_.config_slot_position_code, 
         newrec_.config_slot_code, 
         newrec_.aircraft_type_code
      );
      FETCH get_config_pos_alt_id INTO config_slot_position_alt_id_;
      CLOSE get_config_pos_alt_id;
      
      OPEN get_part_group_alt_id(newrec_.part_group_id);
      FETCH get_part_group_alt_id INTO part_group_alt_id_;
      CLOSE get_part_group_alt_id;
      
      OPEN get_part_number_alt_id(newrec_.part_number_id);
      FETCH get_part_number_alt_id INTO part_number_alt_id_,inventory_class_code_,is_repairable_;
      CLOSE get_part_number_alt_id;
      
      -- Build the payload

      jo_nested_inst_ := JSON_OBJECT_T.parse('{}');
      jo_nested_inst_.put ('partId', part_number_alt_id_);
      ja_inst_ := JSON_ARRAY_T('[]');
      ja_inst_.append(jo_nested_inst_);
       
      jo_ := JSON_OBJECT_T.parse('{}');
      jo_.put ('taskId', task_alt_id_);
      jo_.put ('quantity', newrec_.required_quantity);
      jo_.put ('requestActionCode', 'REQ');
      jo_.put ('positionId', config_slot_position_alt_id_);
      jo_.put ('partGroupId', part_group_alt_id_);
      jo_.put ('installedParts', ja_inst_);
      IF (inventory_class_code_ != 'BATCH' OR (inventory_class_code_ = 'BATCH' AND is_repairable_ = 'True'))THEN
         jo_nested_rmvd_ := JSON_OBJECT_T.parse('{}');
         jo_nested_rmvd_.put ('partId', part_number_alt_id_);
         ja_rmvd_ := JSON_ARRAY_T('[]');
         ja_rmvd_.append(jo_nested_rmvd_);
         jo_.put ('removedParts', ja_rmvd_);
      END IF;
      
      payload_ := jo_.to_string;
      
      -- Call REST endpoint
      Mx_Connect_Util_API.Invoke_Rest_Endpoint(rest_service_,
                                               payload_,
                                               http_method_,
                                               '200,400',
                                               url_parameters_,
                                               header_parameters_,
                                               query_parameters_);     
      
      error_msg_ := PublishRequestPartError___(payload_, newrec_.task_part_request_id);
      
      IF (error_msg_ != 'SUCCESS') THEN
         Error_SYS.Record_General(lu_name_, error_msg_);
      END IF;
   END IF;   
   $ELSE
      NULL;
   $END
END PublishRequestPart___;


/*
   Error handling for publish part request.
*/
FUNCTION PublishRequestPartError___ (
   payload_              IN VARCHAR2, 
   task_part_request_id_ IN NUMBER ) RETURN VARCHAR2
IS
   response_jo_         JSON_OBJECT_T;
   error_msg_           VARCHAR2(2000);
   info_                VARCHAR2(32000);
   attr_                VARCHAR2(32000);
   objid_               VARCHAR2(2000);
   objversion_          VARCHAR2(2000);
BEGIN
   BEGIN
      response_jo_ := JSON_OBJECT_T(payload_);
      error_msg_ := response_jo_.get_String('message');

      -- Identify success response from the 'id' param in the body.
      IF ( response_jo_.get_String('id') IS NOT NULL) THEN
         Client_SYS.Add_To_Attr('ALT_ID', response_jo_.get_String('id'), attr_);
         Get_Id_Version_By_Keys___(objid_, objversion_, task_part_request_id_);
         Modify__(info_, objid_, objversion_, attr_, 'DO');
         Update_Task_Part_Request_Rec(task_part_request_id_, response_jo_.get_String('id'));
        
         RETURN 'SUCCESS';

      -- Identify error response from the 'message' param in the body.
      ELSIF ( error_msg_ IS NOT NULL ) THEN
         RETURN 'MXREQPARTERR: Maintenix request part validation failed with error - ' || error_msg_;

      -- Unidentified errors.
      ELSE
         RETURN 'MXUNIDERR: Unidentified error in response. Payload - ' || payload_;
      END IF;
   EXCEPTION WHEN OTHERS THEN
      
      -- Unexpected error in the response body.
      Error_SYS.Record_General(lu_name_, 'MXUNEXPECTEDERR: Unexpected Response Error, Response Body - :P1', dbms_lob.substr( payload_, 1500, 1 ));
   END;
END PublishRequestPartError___;


PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_part_request_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   task_unique_key_           av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                   av_exe_task_tab.task_id%TYPE;
   part_number_unique_key_    av_part_number_tab.mx_unique_key%TYPE;
   part_number_id_            av_part_number_tab.part_number_id%TYPE;
   part_group_unique_key_     av_part_group_tab.mx_unique_key%TYPE;
   part_group_id_             av_part_group_tab.part_group_id%TYPE;
   alt_id_                    av_exe_task_part_request_tab.alt_id%TYPE;
   
   CURSOR get_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
   
   CURSOR get_part_number_id IS
      SELECT part_number_id
      FROM   av_part_number_tab
      WHERE  mx_unique_key = part_number_unique_key_;   
   
   CURSOR get_part_group_id IS
      SELECT part_group_id
      FROM   av_part_group_tab
      WHERE  mx_unique_key = part_group_unique_key_;      
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;
      
      IF task_unique_key_ IS NOT NULL AND task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSYNCERR: Could not find the indicated task :P1', task_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('TASK_ID', task_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PART_NUMBER_UNIQUE_KEY', local_attr_) THEN
      part_number_unique_key_ := Client_SYS.Get_Item_Value('PART_NUMBER_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_number_id;
      FETCH get_part_number_id INTO part_number_id_;
      CLOSE get_part_number_id;
      
      IF part_number_unique_key_ IS NOT NULL AND part_number_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARTSYNCERR: Could not find the indicated part number :P1', part_number_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('PART_NUMBER_ID', part_number_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NUMBER_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PART_GROUP_UNIQUE_KEY', local_attr_) THEN
      part_group_unique_key_ := Client_SYS.Get_Item_Value('PART_GROUP_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_group_id;
      FETCH get_part_group_id INTO part_group_id_;
      CLOSE get_part_group_id;
      
      IF part_group_unique_key_ IS NOT NULL AND part_group_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARTGROUPSYNCERR: Could not find the indicated part group :P1', part_group_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('PART_GROUP_ID', part_group_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_GROUP_UNIQUE_KEY',  local_attr_);
   END IF;
      
   IF Client_SYS.Item_Exist('ALT_ID', local_attr_) THEN
      alt_id_ := Client_SYS.Get_Item_Value('ALT_ID', local_attr_);          
      Client_SYS.Add_To_Attr('NATURAL_KEY', alt_id_, local_attr_);
   END IF;   
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Modify (
   task_part_request_id_ IN     NUMBER,
   attr_                 IN OUT VARCHAR2
   )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   oldrec_   av_exe_task_part_request_tab%ROWTYPE;
   newrec_   av_exe_task_part_request_tab%ROWTYPE;
   indrec_   Indicator_Rec;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,task_part_request_id_);
   oldrec_ := Lock_By_Id___(objid_, objversion_);
   newrec_ := oldrec_;
   Unpack___(newrec_, indrec_, attr_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_);
END Modify;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_part_request_tab.task_part_request_id%TYPE;
   
   CURSOR get_task_part_request_id IS 
      SELECT task_part_request_id         
        FROM av_exe_task_part_request_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_part_request_id;
   FETCH get_task_part_request_id INTO temp_; 
   CLOSE get_task_part_request_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Task_Id_By_Unique_Key (
   task_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_tab.task_id%TYPE;
   
   CURSOR get_task_id IS 
      SELECT task_id         
        FROM av_exe_task_tab
       WHERE mx_unique_key = task_unique_key_;
BEGIN
   OPEN get_task_id;
   FETCH get_task_id INTO temp_; 
   CLOSE get_task_id;
   
   RETURN temp_;
END Get_Task_Id_By_Unique_Key;

FUNCTION Get_Part_Numb_Id_By_Unique_Key (
   part_number_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_number_tab.part_number_id%TYPE;
   
   CURSOR get_part_number_id IS 
      SELECT part_number_id         
        FROM av_part_number_tab
       WHERE mx_unique_key = part_number_unique_key_;
BEGIN
   OPEN get_part_number_id;
   FETCH get_part_number_id INTO temp_; 
   CLOSE get_part_number_id;
   
   RETURN temp_;
END Get_Part_Numb_Id_By_Unique_Key;

FUNCTION Get_Part_Group_Id_By_Uniqu_Key (
   part_group_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_part_group_tab.part_group_id%TYPE;
   
   CURSOR get_part_group_id IS 
      SELECT part_group_id         
        FROM av_part_group_tab
       WHERE mx_unique_key = part_group_unique_key_;
BEGIN
   OPEN get_part_group_id;
   FETCH get_part_group_id INTO temp_; 
   CLOSE get_part_group_id;
   
   RETURN temp_;
END Get_Part_Group_Id_By_Uniqu_Key;

/*
   This procedure will fetch the objid and objversion using the alt_id (unique)
   and update the mx_unique_key of the record.
*/
PROCEDURE Get_Id_Version_By_Natural_Key (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   alt_id_        IN  VARCHAR2) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_exe_task_part_request_tab
   WHERE alt_id = alt_id_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Natural_Key;

/*
Delete related fault part request record
*/
PROCEDURE Delete_Rec (
   task_part_request_id_ IN NUMBER)
IS
   objid_ VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_exe_task_part_request_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,task_part_request_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Delete_Rec;

 /*
Update alt_id returns from the request part API response and
merge if there are duplicate records in task part request entity for same alt_id
*/
PROCEDURE Update_Task_Part_Request_Rec (
   part_req_id_   IN NUMBER,
   alt_id_ IN VARCHAR2)
IS
   -- Params required to modify the task part request record
   info_          VARCHAR2(32000);
   attr_          VARCHAR2(32000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000); 
   record_count_  NUMBER;
   mx_unique_key_ VARCHAR2(100);
   synced_part_req_id_  NUMBER;

   CURSOR get_record_count IS
      SELECT COUNT(alt_id)
      FROM av_exe_task_part_request_tab
      WHERE alt_id = alt_id_;

   CURSOR get_synced_rec IS
      SELECT task_part_request_id, mx_unique_key
      FROM av_exe_task_part_request_tab
      WHERE alt_id = alt_id_ AND mx_unique_key IS NOT NULL;

BEGIN
   OPEN get_record_count;
   FETCH get_record_count INTO record_count_;
   CLOSE get_record_count;

   -- Check whether more than one record exist for same alt_id
   -- There can be maximum two records. one created from API and another record
   -- can be synced back from related sync job
   IF record_count_ > 1 THEN     
      
      OPEN get_synced_rec;
      FETCH get_synced_rec INTO synced_part_req_id_, mx_unique_key_;
      CLOSE get_synced_rec;

      IF synced_part_req_id_ != 0 OR synced_part_req_id_ IS NOT NULL THEN
         -- Delete the synced record after merging data to a single rec
         Delete_Rec(synced_part_req_id_);

         -- Merge synced record info to the task part req record created from app
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
         Get_Id_Version_By_Keys___(objid_, objversion_, part_req_id_);
         Modify__(info_, objid_, objversion_, attr_, 'DO'); 
      END IF;
   END IF;
END Update_Task_Part_Request_Rec;


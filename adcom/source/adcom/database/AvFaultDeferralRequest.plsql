-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultDeferralRequest
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210308  SWiclk  LMM2020R1-1908, Modified PublishApplyReferenceNew___() and PublishWorkPackageStatusModify___() in order to check Mx_Config_API.Is_Maintenix_Connected
--  210308  majslk  LMM2020R1-1901, Removed Component_Flm_SYS.INSTALLED, added Dictionary_SYS.Component_Is_Active
--  201106  KAWJLK  LMM2020R1-1799, Added Get_Id_Version_By_Natural_Key, modified Pre_Sync_Action
--  210302  siselk  LMM2020R1-1798, Override Update___
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 420_FLM_FAULT_DEF_REQ when setting the rowstate.
--  201201  supklk  LMM2020R1-1167, Implemented functions to fetch keys for data migration
--  201201  supklk  LMM2020R1-1167, Implemented Get_Key_By_Mx_Unique_Key method and modified Check_Insert___ to handle duplicates in data migration
--  201102  Satglk  AD2020R1-1025, Added additional check in Pre_Sync_Action to check if the sync record is Approved before calling Set_Mx_Unique_Key
--  201015  SWiclk  AD2020R1-818, Modified Pre_Sync_Action() and added Set_Mx_Unique_Key___().
--  201015  SWiclk  AD2020R1-787, Added Post_Sync_Action() Sync_State_Handle___() in order to handle statuses.
--  200930  rosdlk  LMM2020R1-1099, Added Apply reference API related implementation.
--  200916  SWiclk  LMM2020R1-721, Added Get_Id_Version_By_Mx_Uniq_Key() and Pre_Sync_Action().
--  200904  KAWJLK  LMM2020R1-1038, Added EXCEPTION no_data_found to Get_Active_Deferral_Request().
--  200618  Madglk  LMM2020R1-53, Added Get_Active_Deferral_Request().
--  200629  ARUFLK  LMM2020R1-116, Override Check_Insert___().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_deferral_request_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   deferral_request_id_ NUMBER;
   
   CURSOR get_deferral_req_id IS 
   SELECT DEFERRAL_REQ_ID_SEQ.nextval 
   FROM dual;
BEGIN
   IF((newrec_.deferral_request_id < 0) OR (newrec_.deferral_request_id IS NULL)) THEN
      OPEN get_deferral_req_id;
      FETCH get_deferral_req_id INTO deferral_request_id_;
      CLOSE get_deferral_req_id;

      newrec_.deferral_request_id := deferral_request_id_;
   END IF;
   Client_SYS.Add_To_Attr('DEFERRAL_REQUEST_ID', newrec_.deferral_request_id, attr_);
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_deferral_request_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   wp_status_ VARCHAR2(50);
BEGIN
   --Add pre-processing code here
   super(objid_, objversion_, newrec_, attr_);
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
         wp_status_ := Av_Fault_Deferral_API.Get_Wp_Status(newrec_.fault_id);
         IF wp_status_ = 'Active' OR wp_status_ = 'Committed' THEN 
            PublishWorkPackageStatusModify___(newrec_);
         ELSIF wp_status_ = 'InWork' THEN
            PublishApplyReferenceNew___(newrec_);
         END IF;
      END IF;
   $END  
END Insert___;

PROCEDURE Set_Mx_Unique_Key___ (
   deferral_request_id_ IN NUMBER,   
   mx_unique_key_       IN VARCHAR2 )
IS
   attr_       VARCHAR2(2000);
   objid_      av_fault_deferral_request.objid%TYPE;
   objversion_ av_fault_deferral_request.objversion%TYPE;  
   oldrec_     av_fault_deferral_request_tab%ROWTYPE;
   newrec_     av_fault_deferral_request_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   oldrec_ := Lock_By_Keys___(deferral_request_id_);
   newrec_ := oldrec_;
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);   
   Unpack___(newrec_, indrec_, attr_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Set_Mx_Unique_Key___;

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
      (current_rowstate_ = 'Requested' AND incoming_rowstate_ = 'PENDING') OR
      (current_rowstate_ = 'Rejected'  AND incoming_rowstate_ = 'CANCELLED') THEN
      RETURN;
   END IF;
   
   IF current_rowstate_ = 'Requested' AND incoming_rowstate_ = 'APPROVED' THEN
      Approve__(info_, objid_, objversion_, state_attr_, action_);      
   ELSIF current_rowstate_ = 'Requested' AND incoming_rowstate_ = 'REJECTED' THEN
      Reject__(info_, objid_, objversion_, state_attr_, action_);      
   ELSIF current_rowstate_ = 'Requested' AND incoming_rowstate_ = 'CANCELLED' THEN
      Reject__(info_, objid_, objversion_, state_attr_, action_);      
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);
   END IF;
END Sync_State_Handle___;

PROCEDURE PublishWorkPackageStatusModify___ (
   newrec_        IN OUT av_fault_deferral_request_tab%ROWTYPE)
IS
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      parameters_             Mx_connect_Util_API.url_param_;
      header_parameters_      Mx_connect_Util_API.header_param_;
      query_parameters_       Mx_connect_Util_API.query_param_;
      payload_       CLOB;
      response_jo_            JSON_OBJECT_T;
   $END

   -- service name represents the API  to apply deferral reference at maintenix
   rest_service_         VARCHAR2(50):= 'MX_START_WP';
   http_method_          VARCHAR2(10) := 'PUT';
   work_package_alt_id_  VARCHAR2(50);
   fault_id_             NUMBER;
   error_msg_            VARCHAR2(2000);
   wp_id_                NUMBER;

   CURSOR work_package_alt_id IS 
      SELECT wp.alt_id
      FROM av_aircraft_work_package_tab wp
      WHERE wp.aircraft_work_package_id = wp_id_;

BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN
      wp_id_ := Av_Fault_Deferral_API.Get_Wp_Id(newrec_.fault_id);
   
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
         Av_Aircraft_Work_Package_API.Update_Status(wp_id_, response_jo_.get_String('status'));    
          
         -- If all the validations are successful, update the wp entity and call apply ref API
         IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
            IF  response_jo_.get_String('status') = 'IN WORK' THEN      
               PublishApplyReferenceNew___(newrec_);
            ELSE
               Error_SYS.Record_General('AvFaultDeferral', 'MXWPSTARTERROR: Work Package not started. WP status: - :P1', response_jo_.get_String('status'));
            END IF;
         END IF;
      END IF;
   END IF;   
   $ELSE
      NULL;
   $END
END PublishWorkPackageStatusModify___;

PROCEDURE PublishApplyReferenceNew___ (
   newrec_     IN OUT av_fault_deferral_request_tab%ROWTYPE)
IS
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      parameters_             Mx_connect_Util_API.url_param_;
      header_parameters_      Mx_connect_Util_API.header_param_;
      query_parameters_       Mx_connect_Util_API.query_param_;
      payload_                CLOB;
      jo_                     JSON_OBJECT_T;
   $END

   -- service name represents the API  to apply deferral reference at maintenix
   rest_service_                VARCHAR2(50):= 'MX_APPLY_REFERENCE';
   http_method_                 VARCHAR2(10) := 'POST';
   deferral_reference_alt_id_   VARCHAR2(50);
   fault_alt_id_                VARCHAR2(50);
   error_msg_                   VARCHAR2(2000);

   CURSOR deferral_reference_alt_id (deferral_reference_id_ IN NUMBER) IS 
      SELECT reference.alt_id
      FROM av_deferral_reference_tab reference
      WHERE reference.deferral_reference_id = deferral_reference_id_;
      
   CURSOR fault_alt_id (fault_id_ IN NUMBER) IS 
   SELECT fault.alt_id
   FROM av_fault_tab fault
   WHERE fault.fault_id = fault_id_;

BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN       
      OPEN deferral_reference_alt_id(newrec_.deferral_reference_id);
      FETCH deferral_reference_alt_id INTO deferral_reference_alt_id_;
      CLOSE deferral_reference_alt_id;
      
      OPEN fault_alt_id(newrec_.fault_id);
      FETCH fault_alt_id INTO fault_alt_id_;
      CLOSE fault_alt_id;
      
      jo_ := JSON_OBJECT_T.parse('{}');
      jo_.put ('selectedReferenceId', deferral_reference_alt_id_);
      jo_.put ('faultReferenceType', 'DEFERRAL');
      jo_.put ('stageReasonCode', newrec_.deferral_req_reason_code);
      jo_.put ('note', newrec_.note);

      payload_ := jo_.to_string; 
       parameters_('param1') := fault_alt_id_; 
                                                                     
      Mx_Connect_Util_API.Invoke_Rest_Endpoint_Callback(rest_service_,
                                               payload_,
                                               http_method_,
                                               '200,400,404,500',
                                               parameters_,
                                               header_parameters_,
                                               query_parameters_,
                                               'Av_Fault_deferral_API.PublishApplyReferenceResponse');
   END IF;           
   $ELSE
      NULL;
   $END
END PublishApplyReferenceNew___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_fault_deferral_request_tab%ROWTYPE,
   newrec_     IN OUT av_fault_deferral_request_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   fault_id_   NUMBER;
   task_id_    NUMBER;
   
   CURSOR get_task_id IS
      SELECT task_id 
      FROM Av_Exe_Task_Tab
      WHERE fault_id = fault_id_;
   
BEGIN
   fault_id_ := newrec_.fault_id;
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;

      IF fault_id_ IS NOT NULL AND task_id_ IS NOT NULL then
         Av_Fault_API.Update_Rowversion_For_Native(fault_id_);
         Av_Exe_Task_API.Update_Rowversion_For_Native(task_id_);
      END IF;
   END IF;
END Update___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Active_Deferral_Request(
   fault_id_ IN NUMBER ) RETURN NUMBER
IS
   deferral_request_id_ NUMBER; 
   CURSOR get_latest_deferral_request IS
      SELECT deferral_request_id
      FROM   av_fault_deferral_request_tab t
      WHERE  t.requested_date  = ( SELECT MAX(a.requested_date)
                                FROM   av_fault_deferral_request_tab a      
                                WHERE  a.fault_id = fault_id_)
      AND t.fault_id = fault_id_;    
BEGIN   
   OPEN  get_latest_deferral_request;
   FETCH get_latest_deferral_request INTO deferral_request_id_;
   CLOSE get_latest_deferral_request;
   RETURN deferral_request_id_ ; 
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END Get_Active_Deferral_Request ;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS  
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_fault_deferral_request_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2) 
IS
   local_attr_                VARCHAR2(4000);
   deferral_ref_unique_key_   av_deferral_reference_tab.mx_unique_key%TYPE;
   deferral_reference_id_     av_deferral_reference_tab.deferral_reference_id%TYPE;

   fault_unique_key_    av_fault_tab.mx_unique_key%TYPE;
   fault_id_            av_fault_tab.fault_id%TYPE;
   deferral_request_id_ NUMBER;
   mx_unique_key_       VARCHAR2(100);
   rowstate_            VARCHAR2(50);
   CURSOR get_deferral_ref_id IS
      SELECT deferral_reference_id
      FROM   av_deferral_reference_tab
      WHERE  mx_unique_key = deferral_ref_unique_key_;
   
   CURSOR get_fault_id_cursor IS
      SELECT fault_id
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('DEFERRAL_REF_UNIQUE_KEY', local_attr_) THEN
      deferral_ref_unique_key_ := Client_SYS.Get_Item_Value('DEFERRAL_REF_UNIQUE_KEY', local_attr_);    

      OPEN  get_deferral_ref_id;
      FETCH get_deferral_ref_id INTO deferral_reference_id_;
      CLOSE get_deferral_ref_id;
      
      IF deferral_ref_unique_key_ IS NOT NULL AND deferral_reference_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'DEFERRALREFSYNCERR: Could not find the indicated Deferral Reference ID :P1', deferral_ref_unique_key_);
      END IF;      
      Client_SYS.Add_To_Attr('DEFERRAL_REFERENCE_ID', deferral_reference_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('DEFERRAL_REF_UNIQUE_KEY',  local_attr_);
   END IF; 
   
   IF Client_SYS.Item_Exist('FAULT_UNIQUE_KEY', local_attr_) THEN
      fault_unique_key_ := Client_SYS.Get_Item_Value('FAULT_UNIQUE_KEY', local_attr_);
      Client_SYS.Add_To_Attr('NATURAL_KEY', fault_unique_key_, local_attr_);

      OPEN  get_fault_id_cursor;
      FETCH get_fault_id_cursor INTO fault_id_;
      CLOSE get_fault_id_cursor;
      
      IF fault_unique_key_ IS NOT NULL AND fault_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'FAULTSYNCERR: Could not find the indicated Fault ID :P1', fault_unique_key_);
      END IF;      
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FAULT_UNIQUE_KEY',  local_attr_);
   END IF; 
   
   -- Note: Since the deferral request can be created from IFS and later create the corresponding 
   --       MXI record we will not have the mx_unique_key available hence when the record
   --       comes to sync it should be able to find the corresponding record otherwise will
   --       create a new record which is wrong.
   --       Therefore we update the mx_unique_key in pre_sync so that later the sync FW shall find
   --       the correct record.
   rowstate_ := Client_SYS.Get_Item_Value('ROWSTATE', local_attr_);
   IF (fault_id_ IS NOT NULL AND rowstate_ != 'PENDING') THEN
      deferral_request_id_ := Get_Active_Deferral_Request(fault_id_);
      mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_);
      Set_Mx_Unique_Key___(deferral_request_id_, mx_unique_key_);
   END IF;
   
   -- AvDeferralReqReason check exists will be handled by the IFS FW
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(4000);
   current_rowstate_        av_fault_deferral_request_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   fault_def_request_rec_   av_fault_deferral_request_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50)    := 'ROWSTATE';
BEGIN
   local_attr_ := attr_;
   
   incoming_rowstate_      := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   fault_def_request_rec_  := Get_Object_By_Id___(objid_);
   current_rowstate_       := Get_Objstate(fault_def_request_rec_.deferral_request_Id);
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
END Post_Sync_Action;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_deferral_request_tab.deferral_request_id%TYPE;
   
   CURSOR get_deferral_request_id IS 
      SELECT deferral_request_id         
        FROM av_fault_deferral_request_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_deferral_request_id;
   FETCH get_deferral_request_id INTO temp_; 
   CLOSE get_deferral_request_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Fault_Id_By_Unique_Key (
   fault_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_tab.fault_id%TYPE;
   
   CURSOR get_fault_id IS 
      SELECT fault_id         
        FROM av_fault_tab
       WHERE mx_unique_key = fault_unique_key_;
BEGIN
   OPEN get_fault_id;
   FETCH get_fault_id INTO temp_; 
   CLOSE get_fault_id;
   
   RETURN temp_;
END Get_Fault_Id_By_Unique_Key;

FUNCTION Get_Def_Ref_Id_By_Unique_Key (
   def_ref_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_deferral_reference_tab.deferral_reference_id%TYPE;
   
   CURSOR get_def_ref_id IS 
      SELECT deferral_reference_id         
        FROM av_deferral_reference_tab
       WHERE mx_unique_key = def_ref_unique_key_;
BEGIN
   OPEN get_def_ref_id;
   FETCH get_def_ref_id INTO temp_; 
   CLOSE get_def_ref_id;
   
   RETURN temp_;
END Get_Def_Ref_Id_By_Unique_Key;

-- This procedure will be used to set the fault deferral request state from the Migration Job 420_FLM_FAULT_DEF_REQ
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_    IN VARCHAR2,
   state_            IN VARCHAR2)
IS
   deferral_request_id_          av_fault_deferral_request_tab.deferral_request_id%TYPE;
   objid_                        av_fault_deferral_request.objid%TYPE;
   objversion_                   av_fault_deferral_request.objversion%TYPE;
   from_state_                   av_fault_deferral_request_tab.rowstate%TYPE;
BEGIN
   deferral_request_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(deferral_request_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, deferral_request_id_);
      from_state_      := Get_Objstate(deferral_request_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;

/*
   This procedure will fetch the deferral request objid and objversion using the fault_unique_key_ (unique)
   and update the mx_unique_key of the record and stop creating duplicate records.
*/
PROCEDURE Get_Id_Version_By_Natural_Key (
   objid_                  OUT VARCHAR2,
   objversion_             OUT VARCHAR2,
   fault_unique_key_       IN  VARCHAR2) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_fault_deferral_request_tab
   WHERE fault_id =(SELECT fault_id
                    FROM   av_fault_tab
                    WHERE  mx_unique_key = fault_unique_key_);
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Natural_Key;
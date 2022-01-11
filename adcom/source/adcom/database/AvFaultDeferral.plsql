-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultDeferral
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210428  siselk  AD-1025, modified Get_Id_Version_By_Natural_Key to Get_Id_Version_By_Natural_Keys
--  210419  siselk  AD-1025, Get_Id_Version_By_Natural_Key added
--  210308  SWiclk  LMM2020R1-1908, Modified PublishWorkPackageStatusModify___(), PublishApplyReferenceNew___() and PublishDeferFaultNew___() in order to check Mx_Config_API.Is_Maintenix_Connected 
--  210308  majslk  LMM2020R1-1800, Updated Insert___ method, Added Update___ method.
--  210304  LAHNLK  LMM2020R1-1794, updated Get_Act_Deferral_reference_Id, Get_Act_Deferral methods
--  201201  SUPKLK  LMM2020R1-1166, Implemented functions to fetch keys for data migration
--  201201  SUPKLK  LMM2020R1-1166, Implemented Get_Key_By_Mx_Unique_Key and modified Check_Insert___ to handle duplicates in data migration
--  201012  rosdlk  LMM2020R1-879, Added defer fault API related implementation
--  200930  rosdlk  LMM2020R1-1099, Apply deferral reference API related implementation added
--  200911  TAJALK  LMM2020R1-716, Sync logic added
--  200619  KAWJLK  LMM2020R1-18, Implemented the Get_Act_Deferral_reference_Id Function
--  200619  MADGLK  LMM2020R1-53, Added Get_Active_Deferral().
--  200625  ARUFLK  LMM2020R1-83, Created sequence for deferral_id.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_deferral_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   deferral_id_ NUMBER;
   
   CURSOR get_deferral_id IS 
   SELECT DEFERRAL_ID_SEQ.nextval 
   FROM dual;
BEGIN
   IF((newrec_.deferral_id < 0) OR (newrec_.deferral_id IS NULL)) THEN
      OPEN get_deferral_id;
      FETCH get_deferral_id INTO deferral_id_;
      CLOSE get_deferral_id;

      newrec_.deferral_id := deferral_id_;
   END IF;
   Client_SYS.Add_To_Attr('DEFERRAL_ID', newrec_.deferral_id, attr_);
   
   super(newrec_, indrec_, attr_);

END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_deferral_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   wp_status_           VARCHAR2(50);
   is_moc_auth_required_ VARCHAR2(50);
BEGIN
   --Add pre-processing code here
   super(objid_, objversion_, newrec_, attr_);
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      IF NOT Mx_Data_Sync_Util_API.Is_Mx_Data_Sync_Receive_Mode() THEN
         wp_status_           := Get_Wp_Status(newrec_.fault_id);
         is_moc_auth_required_ := Av_Deferral_Reference_API.Get_Is_Moc_Approval_Required(newrec_.deferral_reference_id);
                 
         IF is_moc_auth_required_ = 'False' THEN
            IF wp_status_ = 'Active' OR wp_status_ = 'Committed' THEN 
               PublishWorkPackageStatusModify___(newrec_);
            ELSIF wp_status_ = 'InWork' THEN
               PublishApplyReferenceNew___(newrec_);
               PublishDeferFaultNew___(newrec_);
            END IF;
         ELSIF is_moc_auth_required_ = 'True' THEN
            PublishDeferFaultNew___(newrec_);
         END IF;   
      END IF;
   $END
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(newrec_.fault_id);
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_fault_deferral_tab%ROWTYPE,
   newrec_     IN OUT av_fault_deferral_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(newrec_.fault_id);
      END IF;
   END IF;
END Update___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Act_Deferral_reference_Id(
   fault_id_ IN Av_Fault_Deferral_Tab.fault_id%TYPE)RETURN NUMBER
IS
   
   deferral_reference_id_ Av_Fault_Deferral_Tab.deferral_reference_id%TYPE;
   
   CURSOR get_ref_id IS 
   SELECT t.deferral_reference_id
   FROM av_fault_deferral_tab t
   WHERE t.fault_id = fault_id_
   ORDER BY t.deferral_dt DESC
   FETCH    first 1 ROW ONLY; 
   
BEGIN
   
   OPEN  get_ref_id;
   FETCH get_ref_id INTO deferral_reference_id_;
   CLOSE get_ref_id;
   
   RETURN deferral_reference_id_;
   
END Get_Act_Deferral_reference_Id;

FUNCTION Get_Active_Deferral(
  fault_id_   IN NUMBER ) RETURN NUMBER
IS
   deferral_id_  NUMBER ;  
    
   CURSOR get_latest_deferral IS
   SELECT deferral_id
   FROM   av_fault_deferral_tab t
   WHERE t.fault_id = fault_id_
   ORDER BY t.deferral_dt DESC
   FETCH    first 1 ROW ONLY; 
BEGIN
   
   OPEN  get_latest_deferral;
   FETCH get_latest_deferral INTO deferral_id_;
   CLOSE get_latest_deferral;
   
   RETURN deferral_id_;
   EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END Get_Active_Deferral ;


PROCEDURE PublishApplyReferenceNew___ (
   newrec_     IN OUT av_fault_deferral_tab%ROWTYPE)
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


PROCEDURE PublishWorkPackageStatusModify___ (
   newrec_        IN OUT av_fault_deferral_tab%ROWTYPE)
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
   error_msg_            VARCHAR2(2000);
   wp_id_                NUMBER;

   CURSOR work_package_alt_id IS 
      SELECT wp.alt_id
      FROM av_aircraft_work_package_tab wp
      WHERE wp.aircraft_work_package_id = wp_id_;

BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN

   wp_id_ := Get_Wp_Id(newrec_.fault_id);
   
   IF wp_id_ IS NOT NULL AND Mx_Config_API.Is_Maintenix_Connected THEN
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
            PublishDeferFaultNew___(newrec_);
         ELSE
            Error_SYS.Record_General('AvFaultDeferral', 'MXWPSTARTERROR: Work Package not started. WP status: - :P1', response_jo_.get_String('status'));
         END IF;
      END IF;
      
   END IF;
   $ELSE
      NULL;
   $END
END PublishWorkPackageStatusModify___;

FUNCTION Get_Wp_Id(
  fault_id_   IN NUMBER ) RETURN NUMBER
IS
   aircraft_wp_id_ NUMBER;  
   wp_status_ VARCHAR2(50); 
   CURSOR get_aircraft_wp_id IS
      SELECT aircraft_wp_id
      FROM   av_exe_task_tab t
      WHERE  t.fault_id  = fault_id_;
   
   CURSOR get_work_package_status IS
      SELECT rowstate
      FROM   av_aircraft_work_package_tab t
      WHERE  t.aircraft_work_package_id  = (SELECT aircraft_wp_id
                                            FROM   av_exe_task_tab e
                                            WHERE  e.fault_id  = fault_id_);
BEGIN   
   OPEN  get_aircraft_wp_id;
   FETCH get_aircraft_wp_id INTO aircraft_wp_id_;
   CLOSE get_aircraft_wp_id;
   
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

FUNCTION Get_Wp_Status(
  fault_id_   IN NUMBER ) RETURN VARCHAR2
IS
   wp_status_ VARCHAR2(50); 
   
   CURSOR get_work_package_status IS
      SELECT rowstate
      FROM   av_aircraft_work_package_tab t
      WHERE  t.aircraft_work_package_id  = (SELECT aircraft_wp_id
                                            FROM   av_exe_task_tab e
                                            WHERE  e.fault_id  = fault_id_);
BEGIN
   OPEN  get_work_package_status;
   FETCH get_work_package_status INTO wp_status_;
   CLOSE get_work_package_status;
   
   RETURN wp_status_;
   EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END Get_Wp_Status ;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_fault_deferral_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   fault_unique_key_          av_fault_tab.mx_unique_key%TYPE;
   fault_id_                  av_fault_tab.fault_id%TYPE;
   def_ref_unique_key_        av_fault_tab.mx_unique_key%TYPE;
   def_ref_id_                av_fault_tab.fault_id%TYPE;
   unique_key_                VARCHAR2(10);
   
   CURSOR get_fault_id IS
      SELECT fault_id
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
      
   CURSOR get_def_ref_id IS
      SELECT deferral_reference_id
      FROM   av_deferral_reference_tab
      WHERE  mx_unique_key = def_ref_unique_key_;
      
BEGIN
   local_attr_ := attr_;
   unique_key_ := NULL;
   IF Client_SYS.Item_Exist('MX_UNIQUE_KEY', local_attr_) THEN
      Client_SYS.Set_Item_Value('MX_UNIQUE_KEY', unique_key_, local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('FAULT_UNIQUE_KEY', local_attr_) THEN
      fault_unique_key_ := Client_SYS.Get_Item_Value('FAULT_UNIQUE_KEY', local_attr_); 
      
      OPEN  get_fault_id;
      FETCH get_fault_id INTO fault_id_;
      CLOSE get_fault_id;
      
      IF fault_unique_key_ IS NOT NULL AND fault_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'FAULTSYNCERR: Could not find the indicated Fault :P1', fault_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FAULT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('DEF_REF_UNIQUE_KEY', local_attr_) THEN
      def_ref_unique_key_ := Client_SYS.Get_Item_Value('DEF_REF_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_def_ref_id;
      FETCH get_def_ref_id INTO def_ref_id_;
      CLOSE get_def_ref_id;
      
      IF def_ref_unique_key_ IS NOT NULL AND def_ref_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'DEFREFSYNCERR: Could not find the indicated Deferral Reference :P1', def_ref_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('DEFERRAL_REFERENCE_ID', def_ref_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('DEF_REF_UNIQUE_KEY',   local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


PROCEDURE PublishApplyReferenceResponse (
result_           CLOB, 
app_msg_id_       NUMBER, 
response_code_    VARCHAR2, 
headers_          VARCHAR2) 

IS
BEGIN
   IF (response_code_ != '200') THEN
      Error_SYS.Record_General('AvFaultDeferral','ERRORINAPPLYDEFREF: :P1', response_code_ || '____' || result_);
   ELSIF (response_code_ = '200') THEN
      RETURN;
   END IF;
END PublishApplyReferenceResponse;


PROCEDURE PublishDeferFaultNew___ (
   newrec_     IN OUT av_fault_deferral_tab%ROWTYPE)
IS
   $IF Component_Mxcore_SYS.INSTALLED $THEN
      parameters_             Mx_connect_Util_API.url_param_;
      header_parameters_      Mx_connect_Util_API.header_param_;
      query_parameters_       Mx_connect_Util_API.query_param_;
      payload_                CLOB DEFAULT EMPTY_CLOB();
      jo_                     JSON_OBJECT_T;
   $END

   -- service name represents the API  to apply deferral reference at maintenix
   rest_service_                VARCHAR2(50):= 'MX_DEFER_FAULT';
   http_method_                 VARCHAR2(10) := 'POST';
   fault_alt_id_                VARCHAR2(50);
    
   CURSOR fault_alt_id (fault_id_ IN NUMBER) IS 
   SELECT fault.alt_id
   FROM av_fault_tab fault
   WHERE fault.fault_id = fault_id_;

BEGIN
   $IF Component_Mxcore_SYS.INSTALLED $THEN
   IF (Mx_Config_API.Is_Maintenix_Connected) THEN   
      OPEN fault_alt_id(newrec_.fault_id);
      FETCH fault_alt_id INTO fault_alt_id_;
      CLOSE fault_alt_id;

      parameters_('param1') := fault_alt_id_; 
      
      jo_ := JSON_OBJECT_T.parse('{}');
      jo_.put ('faultId', fault_alt_id_);
      payload_ := jo_.to_string;  
                                                                         
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
END PublishDeferFaultNew___;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_deferral_tab.deferral_id%TYPE;
   
   CURSOR get_deferral_id IS 
      SELECT deferral_id         
        FROM av_fault_deferral_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_deferral_id;
   FETCH get_deferral_id INTO temp_; 
   CLOSE get_deferral_id;
   
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

/*
   This procedure will fetch the deferral request objid and objversion using the fault_unique_key_ (unique)
   and update the mx_unique_key of the record and stop creating duplicate records.
*/
PROCEDURE Get_Id_Version_By_Natural_Keys (
   objid_                  OUT VARCHAR2,
   objversion_             OUT VARCHAR2,
   attr_                   IN OUT  VARCHAR2) 
IS  
   CURSOR get_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM   av_fault_deferral_tab
      WHERE  fault_id = Client_SYS.Get_Item_Value('FAULT_ID', attr_);
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Natural_Keys;
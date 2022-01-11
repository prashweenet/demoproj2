-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultPart
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210507  dildlk  AD-1847, Modified Get_Id_Version_By_Natural_Keys
--  210419  dildlk  AD-1064, Removed Get_Id_Version_By_Mx_Uniq_Key and added Get_Id_Version_By_Natural_Keys
--  210415  dildlk  AD-1064, Added Delete_Rec and override Delete___
--  210319  majslk  AD-1080, Updated Insert___ method and added the Update___ method.
--  210308  rosdlk  LMM2020R1-1486, Override check_insert method
--  210307  SatGlk  LMM2020R1-1895, Modified New to include MX_UNIQUE_KEY when making a new Task Part.
--  210305  rosdlk  LMM2020R1-1486, Fixed cursor issue in Pre_sync method
--  210305  rosdlk  LMM2020R1-1486, Handled fault_part_id sequence in CheckInsert() and Insert() method
--  201123  supklk  LMM2020R1-1159, Implemented functions to fetch keys in data migration
--  201130  supklk  LMM2020R1-1159, Implemented Get_Key_by_MX_Unique_key to handle duplicates in data migration
--  201125  sevhlk  AD2020R1-921, Modified he pre_sync_action to properly find the mx_unique_key for deleting.
--  201113  sevhlk  AD2020R1-922, Changes in Get_Id_Version_By_Mx_Uniq_Key
--  201008  lahnlk  LMM2020R1-1309, added Modify
--  200929  sevhlk  LMM2020R1-766, modified Get_Id_Version_By_Mx_Uniq_Key method.
--  200922  sevhlk  LMM2020R1-766, Get_Id_Version_By_Mx_Uniq_Key,PRE_SYNC_ACTION added.
--  200915  siselk  LMM2020R1-1091, New procedure added
--  200710  lahnlk  deleted Get_Config_Slot_Position_Id function
--  200715  kawjlk  LMM2020R1-153, Add Get_Fault_Part_Count, Get_Removal_States and Get_Install_States Functions for fault part changes
--  200710  lahnlk  created.added Get_Config_Slot_Position_Id function
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF ((newrec_.fault_part_id < 0) OR (newrec_.fault_part_id IS NULL) ) THEN
      newrec_.fault_part_id := Av_Exe_Task_Part_API.Get_Next_Seq();
      Client_SYS.Add_To_Attr('FAULT_PART_ID', newrec_.fault_part_id, attr_);
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_part_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   task_id_    NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   task_id_    := Av_Exe_Task_API.Get_Task_Id(newrec_.fault_id);
   
   IF(task_id_ != 0 AND NOT Av_Exe_Task_Part_API.Exists(newrec_.fault_part_id)) THEN
      Av_Exe_Task_Part_API.New(newrec_.fault_part_id, task_id_, newrec_.config_slot_position_code, newrec_.part_group_id, newrec_.removed_part_no_id,
                               newrec_.removal_reason_code, newrec_.installed_part_no_id, newrec_.removed_serial_no, newrec_.removed_quantity,
                               newrec_.ipc_reference, newrec_.installed_serial_no, newrec_.installed_quantity, newrec_.removed_user,
                               newrec_.installed_user, newrec_.part_request_id, newrec_.mx_unique_key);
   END IF;  
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(newrec_.fault_id);
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_fault_part_tab%ROWTYPE,
   newrec_     IN OUT av_fault_part_tab%ROWTYPE,
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

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_fault_part_tab%ROWTYPE )
IS
   task_id_ NUMBER;
BEGIN
   super(objid_, remrec_);  
   task_id_    := Av_Exe_Task_API.Get_Task_Id(remrec_.fault_id);  
   IF(task_id_ != 0 AND  Av_Exe_Task_Part_API.Exists(remrec_.fault_part_id)) THEN 
      Av_Exe_Task_Part_API.Delete_Rec(remrec_.fault_part_id);     
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF remrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(remrec_.fault_id);
      END IF;
   END IF;
END Delete___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Fault_Part_Count(
   fault_id_ IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
   
   CURSOR get_fault_pat_count IS
      SELECT   COUNT(*)
      FROM     av_fault_part_tab
      WHERE    fault_id = fault_id_;
BEGIN
   OPEN  get_fault_pat_count;
   FETCH get_fault_pat_count INTO output_;
   CLOSE get_fault_pat_count;
   
   RETURN output_;
END Get_Fault_Part_Count;

FUNCTION Get_Removal_States(
   fault_part_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(200);
   
   CURSOR get_removal_state IS
      SELECT   removed_user
      FROM     av_fault_part_tab
      WHERE    fault_part_id = fault_part_id_;
BEGIN
   OPEN  get_removal_state;
   FETCH get_removal_state INTO output_;
   IF output_  IS NULL  THEN
      RETURN 'Pending';
   ELSE
      RETURN 'Signed';
   END IF;
   CLOSE get_removal_state;
END Get_Removal_States;

FUNCTION Get_Install_States(
   fault_part_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(200);
   
   CURSOR get_Install_state IS
      SELECT   installed_user
      FROM     av_fault_part_tab
      WHERE    fault_part_id = fault_part_id_;
BEGIN
   OPEN  get_Install_state;
   FETCH get_Install_state INTO output_;
   IF output_  IS NULL  THEN
      RETURN 'Pending';
   ELSE
      RETURN 'Signed';
   END IF;
   CLOSE get_Install_state;
END Get_Install_States;


PROCEDURE New (
   fault_part_id_             IN NUMBER,
   fault_id_                  IN NUMBER,
   config_slot_position_code_ IN VARCHAR2,
   part_group_id_             IN NUMBER,
   removed_part_no_id_        IN NUMBER,
   removal_reason_code_       IN VARCHAR2,
   installed_part_no_id_      IN NUMBER,
   removed_serial_no_         IN VARCHAR2,
   removed_quantity_          IN NUMBER,
   ipc_reference_             IN VARCHAR2,
   installed_serial_no_       IN VARCHAR2,
   installed_quantity_        IN NUMBER,
   removed_user_              IN VARCHAR2,
   installed_user_            IN VARCHAR2,
   part_request_id_           IN NUMBER,
   mx_unique_key_             IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_fault_part_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('FAULT_PART_ID', fault_part_id_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
   Client_SYS.Add_To_Attr('CONFIG_SLOT_POSITION_CODE', config_slot_position_code_, attr_);
   Client_SYS.Add_To_Attr('PART_GROUP_ID', part_group_id_, attr_);
   Client_SYS.Add_To_Attr('REMOVED_PART_NO_ID', removed_part_no_id_, attr_);
   Client_SYS.Add_To_Attr('REMOVAL_REASON_CODE', removal_reason_code_, attr_);
   Client_SYS.Add_To_Attr('INSTALLED_PART_NO_ID', installed_part_no_id_, attr_);
   Client_SYS.Add_To_Attr('REMOVED_SERIAL_NO', removed_serial_no_, attr_);
   Client_SYS.Add_To_Attr('REMOVED_QUANTITY', removed_quantity_, attr_);
   Client_SYS.Add_To_Attr('IPC_REFERENCE', ipc_reference_, attr_);
   Client_SYS.Add_To_Attr('INSTALLED_SERIAL_NO', installed_serial_no_, attr_);
   Client_SYS.Add_To_Attr('INSTALLED_QUANTITY', installed_quantity_, attr_);
   Client_SYS.Add_To_Attr('REMOVED_USER', removed_user_, attr_);
   Client_SYS.Add_To_Attr('INSTALLED_USER', installed_user_, attr_);
   Client_SYS.Add_To_Attr('PART_REQUEST_ID', part_request_id_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
      
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   fault_unique_key_          av_fault_tab.mx_unique_key%TYPE;
   fault_id_                  av_fault_tab.fault_id%TYPE;
   part_request_unique_key_   av_fault_part_request_tab.mx_unique_key%TYPE;
   part_request_id_           av_fault_part_request_tab.fault_part_request_id%TYPE; 
   part_group_unique_key_     av_part_group_tab.mx_unique_key%TYPE;
   part_group_id_             av_part_group_tab.part_group_id%TYPE;
   part_number_unique_key_    av_part_number_tab.mx_unique_key%TYPE;
   part_number_id_            av_part_number_tab.part_number_id%TYPE;
   mx_unique_key_             VARCHAR2(100);
   part_type_                 VARCHAR2(100);
   action_                    VARCHAR2(100);
   
   CURSOR get_fault_id IS  --get_task_id  task_unique_key_  task_id
      SELECT fault_id      
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
      
   CURSOR get_part_request_id IS
      SELECT fault_part_request_id 
      FROM   av_fault_part_request_tab
      WHERE  mx_unique_key = part_request_unique_key_;
      
   CURSOR get_part_group_id IS
      SELECT part_group_id
      FROM   av_part_group_tab
      WHERE  mx_unique_key = part_group_unique_key_;
      
   CURSOR get_part_number_id IS
      SELECT part_number_id
      FROM   av_part_number_tab
      WHERE  mx_unique_key = part_number_unique_key_;
      
BEGIN
   local_attr_ := attr_;
   IF Client_SYS.Item_Exist('FAULT_UNIQUE_KEY', local_attr_) THEN
      fault_unique_key_ := Client_SYS.Get_Item_Value('FAULT_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_fault_id;
      FETCH get_fault_id INTO fault_id_;
      CLOSE get_fault_id;
      
      IF fault_unique_key_ IS NOT NULL AND fault_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'FAULTSYNCER: Could not find the indicated fault :P1', fault_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FAULT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PART_REQUEST_UNIQUE_KEY', local_attr_) THEN
      part_request_unique_key_ := Client_SYS.Get_Item_Value('PART_REQUEST_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_request_id;
      FETCH get_part_request_id INTO part_request_id_;
      CLOSE get_part_request_id;
      
      IF part_request_unique_key_ IS NOT NULL AND part_request_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARTREQUESTSYNCER: Could not find the indicated Part Request Id :P1', part_request_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('PART_REQUEST_ID', part_request_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_REQUEST_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PART_GROUP_UNIQUE_KEY', local_attr_) THEN
      part_group_unique_key_ := Client_SYS.Get_Item_Value('PART_GROUP_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_group_id;
      FETCH get_part_group_id INTO part_group_id_;
      CLOSE get_part_group_id;
      
      IF part_group_unique_key_ IS NOT NULL AND part_group_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARTGROUPSYNCER: Could not find the indicated Part Group Id :P1', part_group_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('PART_GROUP_ID', part_group_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_GROUP_UNIQUE_KEY',  local_attr_);
   END IF;
   
   mx_unique_key_  := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', attr_);
   
   IF Client_SYS.Item_Exist('INST_PART_NUMBER_UNIQUE_KEY', local_attr_) THEN
      part_number_unique_key_ := Client_SYS.Get_Item_Value('INST_PART_NUMBER_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_number_id;
      FETCH get_part_number_id INTO part_number_id_;
      CLOSE get_part_number_id;
      
      IF part_number_unique_key_ IS NOT NULL AND part_number_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'INSTPARTNUMBERSYNCER: Could not find the indicated Installed Part Number Id :P1', part_number_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('INSTALLED_PART_NO_ID', part_number_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('INST_PART_NUMBER_UNIQUE_KEY',  local_attr_);
      
      IF mx_unique_key_ IS NOT NULL THEN 
         mx_unique_key_ := 'I' || mx_unique_key_;
         Client_SYS.Set_Item_Value('MX_UNIQUE_KEY', mx_unique_key_, local_attr_);
      END IF;
   END IF;
   
   IF Client_SYS.Item_Exist('RMVD_PART_NUMBER_UNIQUE_KEY', local_attr_) THEN
      part_number_unique_key_ := Client_SYS.Get_Item_Value('RMVD_PART_NUMBER_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_number_id;
      FETCH get_part_number_id INTO part_number_id_;
      CLOSE get_part_number_id;
      
      IF part_number_unique_key_ IS NOT NULL AND part_number_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'PARTNUMBERSYNCER: Could not find the indicated Removed Part Number Id :P1', part_number_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('REMOVED_PART_NO_ID', part_number_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('RMVD_PART_NUMBER_UNIQUE_KEY',  local_attr_);
      
      IF mx_unique_key_ IS NOT NULL THEN
         mx_unique_key_ := 'R' || mx_unique_key_;
         Client_SYS.Set_Item_Value('MX_UNIQUE_KEY', mx_unique_key_, local_attr_);
      END IF;
   END IF;
   
   IF Client_SYS.Item_Exist('PART_TYPE', local_attr_) AND  Client_SYS.Item_Exist('ACTION', local_attr_) THEN
      part_type_ := Client_SYS.Get_Item_Value('PART_TYPE', local_attr_); 
      action_    := Client_SYS.Get_Item_Value('ACTION', local_attr_);
      
      IF part_type_ = 'Installed' AND mx_unique_key_ IS NOT NULL AND action_ = 'DELETE' THEN  
         mx_unique_key_ := 'I' || mx_unique_key_;
         Client_SYS.Set_Item_Value('MX_UNIQUE_KEY', mx_unique_key_, local_attr_);
      ELSIF part_type_ = 'Removed' AND mx_unique_key_ IS NOT NULL AND action_ = 'DELETE' THEN
         mx_unique_key_ := 'R' || mx_unique_key_;
         Client_SYS.Set_Item_Value('MX_UNIQUE_KEY', mx_unique_key_, local_attr_);
      END IF;
      
      local_attr_:= Client_SYS.Remove_Attr('PART_TYPE',  local_attr_);
   END IF;

   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Modify (
   fault_part_id_     IN NUMBER,
   attr_       IN OUT NOCOPY VARCHAR2)
IS  
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   oldrec_   av_fault_part_tab%ROWTYPE;
   newrec_   av_fault_part_tab%ROWTYPE;
   indrec_   Indicator_Rec;
BEGIN
      Get_Id_Version_By_Keys___ (objid_,objversion_,fault_part_id_);
         oldrec_ := Lock_By_Id___(objid_, objversion_);
         newrec_ := oldrec_;
         Unpack___(newrec_, indrec_, attr_);
         Check_Update___(oldrec_, newrec_, indrec_, attr_);
         Update___(objid_, oldrec_, newrec_, attr_, objversion_);

END Modify;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_part_tab.fault_part_id%TYPE;
   
   CURSOR get_fault_part_id IS 
      SELECT fault_part_id         
        FROM av_fault_part_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_fault_part_id;
   FETCH get_fault_part_id INTO temp_; 
   CLOSE get_fault_part_id;
   
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

FUNCTION Get_Part_Reqst_Id_By_Uniqu_Key (
   part_request_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_part_request_tab.fault_part_request_id%TYPE;
   
   CURSOR get_fault_part_request_id IS 
      SELECT fault_part_request_id         
        FROM av_fault_part_request_tab
       WHERE mx_unique_key = part_request_unique_key_;
BEGIN
   OPEN get_fault_part_request_id;
   FETCH get_fault_part_request_id INTO temp_; 
   CLOSE get_fault_part_request_id;
   
   RETURN temp_;
END Get_Part_Reqst_Id_By_Uniqu_Key;

/*
Delete the fault part record
*/
PROCEDURE Delete_Rec (
   fault_part_id_ IN NUMBER)
IS
   objid_ VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_fault_part_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,fault_part_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Delete_Rec;

PROCEDURE Get_Id_Version_By_Natural_Keys (
   objid_       OUT     VARCHAR2,
   objversion_  OUT     VARCHAR2,
   attr_        IN OUT  VARCHAR2) 
IS  
   CURSOR get_inst_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM   av_fault_part_tab
      WHERE  fault_id = CLIENT_SYS.Get_Item_Value('FAULT_ID', attr_) AND 
             part_request_id = CLIENT_SYS.Get_Item_Value('PART_REQUEST_ID', attr_) AND
            (installed_quantity IS NOT NULL);
                   
     CURSOR get_remove_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM   av_fault_part_tab
      WHERE  fault_id = CLIENT_SYS.Get_Item_Value('FAULT_ID', attr_) AND 
             part_request_id = CLIENT_SYS.Get_Item_Value('PART_REQUEST_ID', attr_) AND
            (removed_quantity IS NOT NULL);
  BEGIN
    
   IF (Client_SYS.Get_Item_Value('REMOVED_PART_NO_ID', attr_) IS NOT NULL ) THEN 
      OPEN  get_remove_key;
      FETCH get_remove_key INTO objid_, objversion_;
      CLOSE get_remove_key;
   ELSE  
      OPEN  get_inst_key;
      FETCH get_inst_key INTO objid_, objversion_;
      CLOSE get_inst_key;
   END IF;
   
END Get_Id_Version_By_Natural_Keys;

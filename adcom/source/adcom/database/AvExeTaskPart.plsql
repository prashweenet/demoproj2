-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskPart
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210507  dildlk  AD-1847, Modified Get_Id_Version_By_Natural_Keys
--  210427  rosdlk  AD-1519, Copy MX_UNIQUE_KEY to fault part when updating
--  210419  dildlk  AD-1064, Removed Get_Id_Version_By_Mx_Uniq_Key and added Get_Id_Version_By_Natural_Keys
--  210415  dildlk  AD-1064, Added Delete_Rec and override Delete___
--  210322  spatlk  AD-1132,Get method to Part changes String.
--  210324  didlk   AD1069, Updated Check_Insert___
--  210319  majslk  AD-1080, Updated Insert___ and Update___ method.
--  210307  SatGlk  LMM2020R1-1895, Modified New to include MX_UNIQUE_KEY when making a new Fault Part.
--  210305  rosdlk  LMM2020R1-1486, Added a new procedure to update task part when adding a part change to a packaged fault
--  201125  sevhlk  AD2020R1-921, Modified he pre_sync_action to properly find the mx_unique_key for deleting.
--  201123  supklk  LMM2020R1-1157, Implemented functions to fetch keys in data migration
--  201123  supklk  LMM2020R1-1157, Implemented Get_Key_by_MX_Unique_key to handle duplicates in data migration
--  201103  sevhlk  AD2020R1-922, Changes in Get_Id_Version_By_Mx_Uniq_Key method.
--  201008  lahnlk  LMM2020R1-1309, override Update___ 
--  200929  lahnlk  LMM2020R1-1273, overtake Check_Insert___
--  200929  sevhlk  LMM2020R1-766, modified Get_Id_Version_By_Mx_Uniq_Key method.
--  200917  sevhlk  LMM2020R1-846, pre_sync added
--  200915  siselk  LMM2020R1-1091, Check_Insert___ modified, Insert___ added
--  200831  siselk  LMM2020R1-154, Check_Insert___ added
--  200720  kawjlk  LMM2020R1-354, Add Get_Task_Part_Count, Get_Removal_States and Get_Install_States Functions for task part changes
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_exe_task_part_tab%ROWTYPE;
    fault_part_id_ NUMBER;
   
   CURSOR get_fault_part(mx_unique_key_ VARCHAR2) IS
      SELECT fault_part_id
      FROM   av_fault_part_tab
      WHERE  mx_unique_key = mx_unique_key_;
BEGIN

 OPEN  get_fault_part(newrec_.mx_unique_key);
   FETCH get_fault_part INTO fault_part_id_;
   CLOSE get_fault_part;
   
   
   IF(newrec_.task_part_id < 0 OR newrec_.task_part_id IS NULL) THEN
      IF fault_part_id_ IS NULL THEN 
         newrec_.task_part_id := Av_Exe_Task_Part_API.Get_Next_Seq();
      ELSE
         newrec_.task_part_id := fault_part_id_;
      END IF;
      Client_SYS.Add_To_Attr('TASK_PART_ID', newrec_.task_part_id, attr_);
   END IF;
   
   
   --Validate_SYS.Item_Insert(lu_name_, 'TASK_PART_ID', indrec_.task_part_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_exe_task_part_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   fault_id_            NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   IF(fault_id_ IS NOT NULL AND NOT Av_Fault_Part_API.Exists(newrec_.task_part_id)) THEN
      Av_Fault_Part_API.New(newrec_.task_part_id, fault_id_, newrec_.config_slot_position_code, newrec_.part_group_id, newrec_.removed_part_no_id,
                           newrec_.removal_reason_code, newrec_.installed_part_no_id, newrec_.removed_serial_no, newrec_.removed_quantity,
                           newrec_.ipc_reference, newrec_.installed_serial_no, newrec_.installed_quantity, newrec_.removed_user,
                           newrec_.installed_user, newrec_.part_request_id, newrec_.mx_unique_key);
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(newrec_.task_id);
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_exe_task_part_tab%ROWTYPE,
   newrec_     IN OUT av_exe_task_part_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   fault_id_            NUMBER;
BEGIN
   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   IF(fault_id_ IS NOT NULL AND Av_Fault_Part_API.Exists(newrec_.task_part_id)) THEN
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
      Client_SYS.Add_To_Attr('CONFIG_SLOT_POSITION_CODE', newrec_.config_slot_position_code, attr_);
      Client_SYS.Add_To_Attr('PART_GROUP_ID', newrec_.part_group_id, attr_);
      Client_SYS.Add_To_Attr('REMOVED_PART_NO_ID', newrec_.removed_part_no_id, attr_);
      Client_SYS.Add_To_Attr('REMOVAL_REASON_CODE', newrec_.removal_reason_code, attr_);
      Client_SYS.Add_To_Attr('INSTALLED_PART_NO_ID', newrec_.installed_part_no_id, attr_);
      Client_SYS.Add_To_Attr('REMOVED_SERIAL_NO', newrec_.removed_serial_no, attr_);
      Client_SYS.Add_To_Attr('REMOVED_QUANTITY', newrec_.removed_quantity, attr_);
      Client_SYS.Add_To_Attr('IPC_REFERENCE', newrec_.ipc_reference, attr_);
      Client_SYS.Add_To_Attr('INSTALLED_SERIAL_NO', newrec_.installed_serial_no, attr_);
      Client_SYS.Add_To_Attr('INSTALLED_QUANTITY', newrec_.installed_quantity, attr_);
      Client_SYS.Add_To_Attr('REMOVED_USER', newrec_.removed_user, attr_);
      Client_SYS.Add_To_Attr('INSTALLED_USER', newrec_.installed_user, attr_);
      Client_SYS.Add_To_Attr('PART_REQUEST_ID', newrec_.part_request_id, attr_);
      Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', newrec_.mx_unique_key, attr_);
      Av_Fault_Part_API.Modify(newrec_.task_part_id,attr_);
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(newrec_.task_id);
      END IF;
   END IF;
END Update___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_exe_task_part_tab%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);  
   IF(  Av_Fault_Part_API.Exists(remrec_.task_part_id)) THEN
      Av_Fault_Part_API.Delete_Rec(remrec_.task_part_id);     
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF remrec_.task_id IS NOT NULL THEN
         Av_Exe_Task_API.Update_Rowversion_For_Native(remrec_.task_id);
      END IF;
   END IF;
END Delete___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New (
   task_part_id_              IN NUMBER,
   task_id_                   IN NUMBER,
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
   newrec_     av_exe_task_part_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('TASK_PART_ID', task_part_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
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

FUNCTION Get_Task_Part_Count(
   task_id_ IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
   
   CURSOR get_task_part_count IS
      SELECT   COUNT(*)
      FROM     av_exe_task_part_tab
      WHERE    task_id = task_id_;
BEGIN
   OPEN  get_task_part_count;
   FETCH get_task_part_count INTO output_;
   CLOSE get_task_part_count;
   
   RETURN output_;
END Get_Task_Part_Count;

FUNCTION Get_Removal_States(
   task_part_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(200);
   
   CURSOR get_removal_state IS
      SELECT   removed_user
      FROM     av_exe_task_part_tab
      WHERE    task_part_id = task_part_id_;
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
   task_part_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ VARCHAR2(200);
   
   CURSOR get_Install_state IS
      SELECT   installed_user
      FROM     av_exe_task_part_tab
      WHERE    task_Part_id = task_part_id_;
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


PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   task_unique_key_           av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                   av_exe_task_tab.task_id%TYPE;
   part_request_unique_key_   av_exe_task_part_request_tab.mx_unique_key%TYPE;
   part_request_id_           av_exe_task_part_request_tab.task_part_request_id%TYPE; 
   part_group_unique_key_     av_part_group_tab.mx_unique_key%TYPE;
   part_group_id_             av_part_group_tab.part_group_id%TYPE;
   part_number_unique_key_    av_part_number_tab.mx_unique_key%TYPE;
   part_number_id_            av_part_number_tab.part_number_id%TYPE;
   mx_unique_key_             VARCHAR2(100);
   part_type_                 VARCHAR2(100);
   action_                    VARCHAR2(100);
   
   CURSOR get_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
      
   CURSOR get_part_request_id IS
      SELECT task_part_request_id
      FROM   av_exe_task_part_request_tab
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
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;
      
      IF task_unique_key_ IS NOT NULL AND task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKPARTSYNCER: Could not find the indicated Task :P1', task_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('TASK_ID', task_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
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

FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT av_exe_task_part_seq.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN ( seq_no_ );
END Get_Next_Seq;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_part_tab.task_part_id%TYPE;
   
   CURSOR get_task_part_id IS 
      SELECT task_part_id         
        FROM av_exe_task_part_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_part_id;
   FETCH get_task_part_id INTO temp_; 
   CLOSE get_task_part_id;
   
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

FUNCTION Get_Part_Reqst_Id_By_Uniqu_Key (
   part_request_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_part_request_tab.task_part_request_id%TYPE;
   
   CURSOR get_task_part_request_id IS 
      SELECT task_part_request_id         
        FROM av_exe_task_part_request_tab
       WHERE mx_unique_key = part_request_unique_key_;
BEGIN
   OPEN get_task_part_request_id;
   FETCH get_task_part_request_id INTO temp_; 
   CLOSE get_task_part_request_id;
   
   RETURN temp_;
END Get_Part_Reqst_Id_By_Uniqu_Key;


/**This method return string required for part change json payload**/
FUNCTION Get_Part_Change_by_Part_Req(part_request_id_ IN NUMBER) RETURN VARCHAR2
IS 
   
   task_part_change_str_ VARCHAR2(1000):=NULL;
   remove_task_part_id_ av_exe_task_part_tab.task_part_id%TYPE:=NULL;
   install_task_part_id_ av_exe_task_part_tab.task_part_id%TYPE:=NULL;
   part_install_str_ VARCHAR2(400):=NULL;
   part_remove_str_ VARCHAR2(400):=NULL;
   position_cd_str_ VARCHAR2(400):=NULL;
   install_task_part_rec_ Public_Rec:=NULL;
   remove_task_part_rec_ Public_Rec:=NULL;
   position_code_ av_exe_task_part_tab.config_slot_position_code%TYPE:= NULL;
   part_request_alt_id_ av_exe_task_part_request_tab.alt_id%TYPE:=NULL;
   install_part_number_rec_alt_id_ av_part_number_tab.alt_id%TYPE:=NULL;
   remove_part_number_rec_alt_id_ av_part_number_tab.alt_id%TYPE:=NULL;
   install_part_inv_class_ av_part_number_tab.inventory_class_code%TYPE:=NULL;
   remove_part_inv_class_ av_part_number_tab.inventory_class_code%TYPE:=NULL;
   
       
   --cursor to get task part of part request. 
   CURSOR get_install_part_change IS 
    SELECT task_part_id 
    FROM av_exe_task_part_tab e
    WHERE e.part_request_id = part_request_id_ AND e.installed_part_no_id IS NOT NULL ;
    
    --cursor to get removed part of part request. 
   CURSOR get_remove_part_change IS 
    SELECT task_part_id 
    FROM av_exe_task_part_tab e
    WHERE e.part_request_id = part_request_id_ AND e.removed_part_no_id IS NOT NULL ;
   
                                               
   --get install part number alt id and inventory class from av_part_number by task_part_id_
   CURSOR get_install_part_number_data(install_task_part_id_ NUMBER) IS
      SELECT alt_id,inventory_class_code
      FROM   av_part_number_tab t
      WHERE  t.part_number_id  = (SELECT installed_part_no_id
                                         FROM   av_exe_task_part_tab e
                                         WHERE  e.task_part_id= install_task_part_id_);  
                                         
    --get Remove part number alt id and inventory class from av_part_number by task_part_id_
   CURSOR get_remove_part_number_data(remove_task_part_id_ NUMBER) IS
      SELECT alt_id,inventory_class_code
      FROM   av_part_number_tab t
      WHERE  t.part_number_id  = (SELECT removed_part_no_id
                                         FROM   av_exe_task_part_tab e
                                         WHERE  e.task_part_id= remove_task_part_id_);  
                                         
   --get part requirement alt id from av_exe_task_part_request by task_part_id_
   CURSOR get_task_part_req_alt_id IS
      SELECT alt_id
      FROM   av_exe_task_part_request_tab t
      WHERE  t.task_part_request_id  = (SELECT DISTINCT part_request_id
                                            FROM   av_exe_task_part_tab e
                                            WHERE  e.part_request_id= part_request_id_);                                      
   
BEGIN   
      
   --set install task part Id 
    OPEN get_install_part_change;
    FETCH get_install_part_change INTO install_task_part_id_;
    CLOSE get_install_part_change;
    
    IF(install_task_part_id_ IS NOT NULL)THEN
    --set install part number alt Id and inv class
    OPEN get_install_part_number_data(install_task_part_id_);
    FETCH get_install_part_number_data INTO install_part_number_rec_alt_id_,install_part_inv_class_;
    CLOSE get_install_part_number_data;
    
    install_task_part_rec_ := Av_Exe_Task_Part_API.Get(install_task_part_id_);
    
    END IF;
    
    --set remove task part Id 
    OPEN get_remove_part_change;
    FETCH get_remove_part_change INTO remove_task_part_id_;
    CLOSE get_remove_part_change;
    
    IF(install_task_part_id_ IS NOT NULL)THEN
    --set remove part number alt Id and inv class
    OPEN get_remove_part_number_data(remove_task_part_id_);
    FETCH get_remove_part_number_data INTO remove_part_number_rec_alt_id_,remove_part_inv_class_;
    CLOSE get_remove_part_number_data; 
    
    remove_task_part_rec_:= Av_Exe_Task_Part_API.Get(remove_task_part_id_);
    
    END IF;   
       
    --set task_part_request alt Id
    OPEN get_task_part_req_alt_id ;
    FETCH get_task_part_req_alt_id INTO part_request_alt_id_;
    CLOSE get_task_part_req_alt_id;  
    
    IF (install_part_number_rec_alt_id_ IS NOT NULL) THEN
     part_install_str_ := '
      "installedPart":{
            "partId":"' ||install_part_number_rec_alt_id_|| '",
            "quantity":"' ||install_task_part_rec_.installed_quantity|| '",
            "serialNumber": "' ||install_task_part_rec_.installed_serial_no|| '"}'; 
    END IF; 
     
    IF (remove_part_number_rec_alt_id_ IS NOT NULL) THEN 
     part_remove_str_ := ', 
      "removedPart": {
            "partId":"' ||remove_part_number_rec_alt_id_|| '",
            "quantity": "' ||remove_task_part_rec_.removed_quantity|| '",
            "serialNumber":"' ||remove_task_part_rec_.removed_serial_no|| '",
            "reasonCode": "' ||remove_task_part_rec_.removal_reason_code|| '"
        }';
     END IF; 
     
   /**setting position code if part is only TRK**/ 
     IF install_part_inv_class_ = 'TRK' OR remove_part_inv_class_ ='TRK' THEN
       IF (install_task_part_rec_.config_slot_position_code IS NOT NULL) THEN 
         position_code_ := install_task_part_rec_.config_slot_position_code;
       ELSE 
         position_code_ := remove_task_part_rec_.config_slot_position_code; 
       END IF;  
   position_cd_str_ := '"positionCode":"'||position_code_||'",'; 
      task_part_change_str_ := 
      '{ 
         "partRequirementId": "' ||part_request_alt_id_|| '",
         '||position_cd_str_||'
         '||part_install_str_||'
         '||part_remove_str_||'        
       }';
   ELSE
      task_part_change_str_ := 
      '{ 
         "partRequirementId": "' ||part_request_alt_id_|| '",
         '||part_install_str_||'
         '||part_remove_str_||'        
       }';
       
   END IF;
  
   RETURN task_part_change_str_; 

END Get_Part_Change_by_Part_Req;



/*
Delete the task part record
*/
PROCEDURE Delete_Rec (
   task_part_id_ IN NUMBER)
IS
   objid_ VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_exe_task_part_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,task_part_id_);
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
      FROM   av_exe_task_part_tab
      WHERE  task_id = CLIENT_SYS.Get_Item_Value('TASK_ID', attr_) AND 
             part_request_id = CLIENT_SYS.Get_Item_Value('PART_REQUEST_ID', attr_) AND
            (installed_quantity IS NOT NULL);
                   
     CURSOR get_remove_key IS
      SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
      FROM   av_exe_task_part_tab
      WHERE  task_id = CLIENT_SYS.Get_Item_Value('TASK_ID', attr_) AND 
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



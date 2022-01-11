-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskTool
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210311  Jihalk  LMM2020R1-1580, Added Converted_Sched_Time and Converted_Acc_Time methods.
--  210307  SatGlk  LMM2020R1-1895, Modified New to include MX_UNIQUE_KEY when making a new Task Tool.
--  210303  SUPKLK  LMM2020R1-1645, Implemented Get_Key_By_Mx_Unique_Key to handle duplicates in data migration
--  210111  majslk  LMM2020R1-1478, Updated check_insert__.
--  201008  lahnlk  LMM2020R1-1309, override Update___ 
--  200929  lahnlk  LMM2020R1-1273, overtake Check_Insert___,override Delete___, created Remove
--  200731  SatGlk  LMM2020R1-156, Implemented New to be called by AvFaultTool if a Task is connected to the Fault
--  200729  SatGlk  LMM2020R1-445, Implemented Get_Next_Seq to fetch the next sequence which is called from AvFaultTool Check_Insert___.
--  200729  SatGlk  LMM2020R1-445, Overriden Insert___ to sync the Av_Fault_Tool table accordingly.
--  200723  SatGlk  LMM2020R1-445, Overriden Check_Insert___ to add seqeuence to task_tool_id_.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_tool_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_exe_task_tool_tab%ROWTYPE;
   fault_tool_id_ NUMBER;
   
   CURSOR get_fault_tool(mx_unique_key_ VARCHAR2) IS
      SELECT fault_tool_id
      FROM   av_fault_tool_tab
      WHERE  mx_unique_key = mx_unique_key_;
      
BEGIN
   OPEN  get_fault_tool(newrec_.mx_unique_key);
   FETCH get_fault_tool INTO fault_tool_id_;
   CLOSE get_fault_tool;
   
   IF(newrec_.task_tool_id < 0 OR newrec_.task_tool_id IS NULL) THEN
      IF fault_tool_id_ IS NULL THEN 
         newrec_.task_tool_id := Av_Exe_Task_Tool_API.Get_Next_Seq();
      ELSE
         newrec_.task_tool_id := fault_tool_id_;
      END IF;
      Client_SYS.Add_To_Attr('TASK_TOOL_ID', newrec_.task_tool_id, attr_);
   END IF;
   --Validate_SYS.Item_Insert(lu_name_, 'TASK_TOOL_ID', indrec_.task_tool_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_exe_task_tool_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   fault_id_   NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   IF(fault_id_ IS NOT NULL AND NOT Av_Fault_Tool_API.Exists(newrec_.task_tool_id)) THEN
      Av_Fault_Tool_API.New(newrec_.task_tool_id, fault_id_, newrec_.tool_specification_code, newrec_.part_no_id, newrec_.serial_no, newrec_.assigned_user, newrec_.sched_duration, newrec_.mx_unique_key);
   END IF;   
END Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_exe_task_tool_tab%ROWTYPE )
IS
   fault_id_   NUMBER;
BEGIN
   
   super(objid_, remrec_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(remrec_.task_id);
   IF(fault_id_ IS NOT NULL AND Av_Fault_Tool_API.Exists(remrec_.task_tool_id)) THEN
     Av_Fault_Tool_API.Remove(remrec_.task_tool_id);
   END IF; 
END Delete___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_exe_task_tool_tab%ROWTYPE,
   newrec_     IN OUT av_exe_task_tool_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   fault_id_   NUMBER;
BEGIN
   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   IF(fault_id_ IS NOT NULL AND Av_Fault_Tool_API.Exists(newrec_.task_tool_id)) THEN
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
      Client_SYS.Add_To_Attr('TOOL_SPECIFICATION_CODE', newrec_.tool_specification_code, attr_);
      Client_SYS.Add_To_Attr('PART_NUMBER_ID', newrec_.part_no_id, attr_);
      Client_SYS.Add_To_Attr('SERIAL_NO', newrec_.serial_no, attr_);
      Client_SYS.Add_To_Attr('ASSIGNED_USER', newrec_.assigned_user, attr_);
      Client_SYS.Add_To_Attr('SCHEDULED_HOURS', newrec_.sched_duration, attr_);
      Client_SYS.Add_To_Attr('ACTUAL_HOURS', newrec_.actual_duration, attr_);
      Av_Fault_Tool_API.Modify(newrec_.task_tool_id,attr_);      
   END IF;  
END Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Tools_Count(
   task_id_    IN NUMBER) RETURN NUMBER
IS
   count_      NUMBER;
 
   CURSOR get_tool_count IS
      SELECT   COUNT(*)
      FROM     av_exe_task_tool_tab
      WHERE    task_id = task_id_;
BEGIN
   OPEN  get_tool_count;
   FETCH get_tool_count INTO count_;
   CLOSE get_tool_count;

   RETURN count_;
END Get_Task_Tools_Count;

FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT TASK_TOOL_ID_SEQ.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN ( seq_no_ );
END Get_Next_Seq;

--Creates a new Task Tool record
PROCEDURE New (
   task_tool_id_             IN NUMBER,
   task_id_                  IN NUMBER,
   tool_specification_code_  IN VARCHAR2,
   part_no_id_               IN NUMBER,
   serial_no_                IN VARCHAR2,
   assigned_user_            IN VARCHAR2,
   sched_duration_           IN NUMBER,
   mx_unique_key_            IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_exe_task_tool_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   
   Client_SYS.Add_To_Attr('TASK_TOOL_ID', task_tool_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
   Client_SYS.Add_To_Attr('TOOL_SPECIFICATION_CODE', tool_specification_code_, attr_);
   Client_SYS.Add_To_Attr('PART_NO_ID', part_no_id_, attr_);
   Client_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
   Client_SYS.Add_To_Attr('ASSIGNED_USER', assigned_user_, attr_);
   Client_SYS.Add_To_Attr('SCHED_DURATION', sched_duration_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);   

   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

FUNCTION Get_Tool_Status (
  task_tool_id_   IN NUMBER ) RETURN VARCHAR2
IS
   user_assigned_ VARCHAR2(40);
   status_ VARCHAR2(100);
   CURSOR Get_user IS
   SELECT Assigned_User 
   FROM  av_exe_task_tool_tab 
   WHERE task_tool_id=task_tool_id_;
BEGIN 
      OPEN Get_user;
      FETCH Get_user INTO user_assigned_;
      CLOSE Get_user;
      IF(user_assigned_ IS NULL OR user_assigned_ ='') THEN
         status_ :='Pending';
      ELSE 
         status_ :='Signed';
      END IF;
      RETURN status_;   
END Get_Tool_Status ;
   
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_tool_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;

END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                   VARCHAR2(4000);
   task_unique_key_              av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                      av_exe_task_tab.task_id%TYPE;
   av_exe_task_tool_task_id_     av_exe_task_tool_tab.task_id%TYPE;  
   tool_specification_code_      av_exe_task_tool_tab.tool_specification_code%TYPE;  
   av_exe_task_tool_unique_key_  av_exe_task_tool_tab.mx_unique_key%TYPE;
   part_number_unique_key_       av_part_number_tab.mx_unique_key%TYPE;
   part_number_id_               av_part_number_tab.part_number_id%TYPE;
   
   CURSOR get_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
      
   CURSOR get_exe_task_tool_task_id IS
      SELECT task_id, tool_specification_code
      FROM   av_exe_task_tool_tab
      WHERE  mx_unique_key = av_exe_task_tool_unique_key_; 
   
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
         Error_SYS.Appl_General(lu_name_, 'TASKTOOLSYNCERR: Could not find the indicated task :P1', task_unique_key_);
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
         Error_SYS.Appl_General(lu_name_, 'FAULTTOOLSYNCERR: Could not find the indicated part number :P1', part_number_id_);
      END IF;
       
      Client_SYS.Add_To_Attr('PART_NO_ID', part_number_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NUMBER_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('MX_UNIQUE_KEY', local_attr_) THEN
      av_exe_task_tool_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_exe_task_tool_task_id;
      FETCH get_exe_task_tool_task_id INTO av_exe_task_tool_task_id_, tool_specification_code_;
      CLOSE get_exe_task_tool_task_id;
     
      IF av_exe_task_tool_unique_key_ IS NOT NULL AND av_exe_task_tool_task_id_ IS NOT NULL THEN
         local_attr_:= Client_SYS.Remove_Attr('TASK_ID',  local_attr_);
      END IF;
      
      IF av_exe_task_tool_unique_key_ IS NOT NULL AND tool_specification_code_ IS NOT NULL THEN
         local_attr_:= Client_SYS.Remove_Attr('TOOL_SPECIFICATION_CODE',  local_attr_);
      END IF;
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Remove (
   task_tool_id_            IN NUMBER
  )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_exe_task_tool_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,task_tool_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Remove;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_tool_tab.task_tool_id%TYPE;
   
   CURSOR get_task_tool_id IS 
      SELECT task_tool_id         
        FROM av_exe_task_tool_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_tool_id;
   FETCH get_task_tool_id INTO temp_; 
   CLOSE get_task_tool_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Converted_Sched_Time (
   task_tool_id_ IN NUMBER) RETURN VARCHAR2
IS
   sched_hours_            NUMBER(10,2);
   converted_sched_value_  VARCHAR2(10);
   
   CURSOR get_hours IS
   SELECT Round((TRUNC(Sched_Duration)+(Sched_Duration-TRUNC(Sched_Duration))*.60),2)
   FROM   Av_Exe_Task_Tool_Tab
   WHERE  Task_Tool_Id = task_tool_id_;
BEGIN
   
   OPEN get_hours;
   FETCH get_hours INTO sched_hours_;
   CLOSE get_hours;  
   
   IF sched_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 1))<3 THEN
      converted_sched_value_ := regexp_substr (TO_CHAR(sched_hours_,'00.99'), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(sched_hours_,'00.99'), '[^.]+', 1, 2); 
   ELSIF sched_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 2))>1 THEN
      converted_sched_value_ := regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 2); 
   ELSIF sched_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 2))=1 THEN
      converted_sched_value_ := regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 2)||'0';   
   ELSIF sched_hours_ IS NOT NULL THEN
      converted_sched_value_ := regexp_substr (TO_CHAR(sched_hours_), '[^.]+', 1, 1)||':'||'00';   
   END IF;
   
   RETURN converted_sched_value_;
END Converted_Sched_Time;

FUNCTION Converted_Acc_Time (
   task_tool_id_ IN NUMBER) RETURN VARCHAR2
IS
   actual_hours_           NUMBER(10,2);
   converted_actual_value_ VARCHAR2(10);
   
   CURSOR get_hours IS
   SELECT Round((TRUNC(Actual_Duration)+(Actual_Duration-TRUNC(Actual_Duration))*.60),2)
   FROM   Av_Exe_Task_Tool_Tab
   WHERE  Task_Tool_Id = task_tool_id_;
BEGIN
   
   OPEN get_hours;
   FETCH get_hours INTO actual_hours_;
   CLOSE get_hours;  
   
   IF actual_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 1))<3 THEN
      converted_actual_value_ := regexp_substr (TO_CHAR(actual_hours_,'00.99'), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(actual_hours_,'00.99'), '[^.]+', 1, 2); 
   ELSIF actual_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 2))>1 THEN
      converted_actual_value_ := regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 2); 
   ELSIF actual_hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 2))=1 THEN
      converted_actual_value_ := regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 2)||'0';   
   ELSIF actual_hours_ IS NOT NULL THEN
      converted_actual_value_ := regexp_substr (TO_CHAR(actual_hours_), '[^.]+', 1, 1)||':'||'00';   
   END IF;
   
   RETURN converted_actual_value_;
END Converted_Acc_Time;
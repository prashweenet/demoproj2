-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultTool
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210311  Jihalk  LMM2020R1-1591, Added Converted_Sched_Time and Converted_Acc_Time methods.
--  210307  SatGlk  LMM2020R1-1895, Modified New to include MX_UNIQUE_KEY when making a new Fault Tool.
--  210301  SUPKLK  LMM2020R1-1649, Implemented Get_Key_By_Mx_Unique_Key to handle duplicates in Data Migration
--  201008  lahnlk  LMM2020R1-1309, added Modify
--  200929  lahnlk  LMM2020R1-1273, overtake Check_Insert___,override Delete___, created Remove
--  200729  SatGlk  LMM2020R1-445, Implemented New to be called by AvExeTaskTool if a Fault is connected to a Task
--  200729  SatGlk  LMM2020R1-445, Overriden Check_Insert___ to fetch the next sequence value from Av_Exe_Task_Tool if the fault is connected to a Task
--  200715  madglk  LMM2020R1-155,Added methods Get_Tool_Status() and Get_Fault_Tools_Count().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_tool_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_fault_tool_tab%ROWTYPE;
BEGIN
    IF (newrec_.fault_tool_id < 0 OR newrec_.fault_tool_id IS NULL) THEN      
      newrec_.fault_tool_id := Av_Exe_Task_Tool_API.Get_Next_Seq();
      Client_SYS.Add_To_Attr('FAULT_TOOL_ID', newrec_.fault_tool_id, attr_);
   END IF;
   --Validate_SYS.Item_Insert(lu_name_, 'FAULT_TOOL_ID', indrec_.fault_tool_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_tool_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   task_id_    NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   task_id_    := Av_Exe_Task_API.Get_Task_Id(newrec_.fault_id);
   
   IF(task_id_ != 0 AND NOT Av_Exe_Task_Tool_API.Exists(newrec_.fault_tool_id)) THEN
      Av_Exe_Task_Tool_API.New(newrec_.fault_tool_id, task_id_, newrec_.tool_specification_code, newrec_.part_number_id, newrec_.serial_no, newrec_.assigned_user, newrec_.scheduled_hours, newrec_.mx_unique_key);
   END IF;  
END Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_fault_tool_tab%ROWTYPE )
IS
   task_id_    NUMBER;
BEGIN
  
   super(objid_, remrec_);
   task_id_    := Av_Exe_Task_API.Get_Task_Id(remrec_.fault_id);
    IF(task_id_ != 0 AND Av_Exe_Task_Tool_API.Exists(remrec_.fault_tool_id)) THEN
     Av_Exe_Task_Tool_API.Remove(remrec_.fault_tool_id);
   END IF; 
END Delete___;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Tool_Status (
  fault_tool_id_   IN NUMBER ) RETURN VARCHAR2
IS
   user_assigned_ VARCHAR2(40);
   status_ VARCHAR2(100);
   CURSOR Get_user IS
   SELECT Assigned_User 
   FROM  av_fault_tool_tab 
   WHERE fault_tool_id=fault_tool_id_;
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


FUNCTION Get_Fault_Tools_Count(
   fault_id_    IN NUMBER) RETURN NUMBER
IS
   count_ NUMBER;
 
   CURSOR get_tool_count IS
      SELECT   COUNT(*)
      FROM     av_fault_tool_tab
      WHERE    fault_id = fault_id_;
BEGIN
   OPEN  get_tool_count;
   FETCH get_tool_count INTO count_;
   CLOSE get_tool_count;
   IF (count_ IS NULL )THEN
       count_:=0;
   END IF;
   RETURN count_;
END Get_Fault_Tools_Count;

--Creates a new Fault Tool record
PROCEDURE New (
   fault_tool_id_            IN NUMBER,
   fault_id_                 IN NUMBER,
   tool_specification_code_  IN VARCHAR2,
   part_number_id_           IN NUMBER,
   serial_no_                IN VARCHAR2,
   assigned_user_            IN VARCHAR2,
   scheduled_hours_          IN VARCHAR2,
   mx_unique_key_            IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_fault_tool_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('FAULT_TOOL_ID', fault_tool_id_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
   Client_SYS.Add_To_Attr('TOOL_SPECIFICATION_CODE', tool_specification_code_, attr_);
   Client_SYS.Add_To_Attr('PART_NUMBER_ID', part_number_id_, attr_);
   Client_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
   Client_SYS.Add_To_Attr('ASSIGNED_USER', assigned_user_, attr_);
   Client_SYS.Add_To_Attr('SCHEDULED_HOURS', scheduled_hours_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);

   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_fault_tool_tab
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
   part_number_unique_key_    av_part_number_tab.mx_unique_key%TYPE;
   part_number_id_            av_part_number_tab.part_number_id%TYPE;
   
   CURSOR get_fault_id IS
      SELECT fault_id
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
      
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
         Error_SYS.Appl_General(lu_name_, 'FAULTTOOLSYNCERR: Could not find the indicated fault :P1', fault_unique_key_);
      END IF;
       
      Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('FAULT_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('PART_NUMBER_UNIQUE_KEY', local_attr_) THEN
      part_number_unique_key_ := Client_SYS.Get_Item_Value('PART_NUMBER_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_part_number_id;
      FETCH get_part_number_id INTO part_number_id_;
      CLOSE get_part_number_id;

      IF part_number_unique_key_ IS NOT NULL AND part_number_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'FAULTTOOLPARTSYNCERR: Could not find the indicated part number :P1', part_number_id_);
      END IF;
       
      Client_SYS.Add_To_Attr('PART_NUMBER_ID', part_number_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('PART_NUMBER_UNIQUE_KEY',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Remove (
   fault_tool_id_            IN NUMBER
  )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_fault_tool_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,fault_tool_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Remove;

PROCEDURE Modify (
   fault_tool_id_            IN NUMBER,
   attr_       IN OUT VARCHAR2 )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   oldrec_   av_fault_tool_tab%ROWTYPE;
   newrec_   av_fault_tool_tab%ROWTYPE;
   indrec_   Indicator_Rec;
BEGIN
      
   Get_Id_Version_By_Keys___ (objid_,objversion_,fault_tool_id_);
   oldrec_ := Lock_By_Id___(objid_, objversion_);
   newrec_ := oldrec_;
   Unpack___(newrec_, indrec_, attr_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_);
     
END Modify;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_tool_tab.fault_tool_id%TYPE;
   
   CURSOR get_fault_tool_id IS 
      SELECT fault_tool_id         
        FROM av_fault_tool_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_fault_tool_id;
   FETCH get_fault_tool_id INTO temp_; 
   CLOSE get_fault_tool_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Converted_Sched_Time (
   fault_tool_id_ IN NUMBER) RETURN VARCHAR2
IS
   sched_hours_            NUMBER;
   converted_sched_value_  VARCHAR2(10);
   
   CURSOR get_hours IS
   SELECT Round((TRUNC(Scheduled_Hours)+(Scheduled_Hours-TRUNC(Scheduled_Hours))*.60),2)
   FROM   Av_Fault_Tool_Tab
   WHERE  Fault_Tool_Id = fault_tool_id_;
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
   fault_tool_id_ IN NUMBER) RETURN VARCHAR2
IS
   actual_hours_           NUMBER;
   converted_actual_value_ VARCHAR2(10);
   
   CURSOR get_hours IS
   SELECT Round((TRUNC(Actual_Hours)+(Actual_Hours-TRUNC(Actual_Hours))*.60),2)
   FROM   Av_Fault_Tool_Tab
   WHERE  Fault_Tool_Id = fault_tool_id_;
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
-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskStepSkill
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201112  SUPKLK  LMM2020R1-1137 Implemented Get_Task_Step_Id_By_Unique_Key for data migration
--  200827  TAJALK  LMM2020R1-469 - Sync Logic added
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_step_skill_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                 VARCHAR2(4000);
   task_step_unique_key_       av_exe_task_step_tab.mx_unique_key%TYPE;
   exe_task_step_id_           av_exe_task_step_tab.task_id%TYPE;
   competency_id_              av_exe_task_step_skill_tab.competency_id%TYPE;
         
   CURSOR get_exe_task_step_id IS
      SELECT task_step_id
      FROM   av_exe_task_step_tab
      WHERE  mx_unique_key = task_step_unique_key_;
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('TASK_STEP_UNIQUE_KEY', local_attr_) THEN
      task_step_unique_key_     := Client_SYS.Get_Item_Value('TASK_STEP_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_exe_task_step_id;
      FETCH get_exe_task_step_id INTO exe_task_step_id_;
      CLOSE get_exe_task_step_id;
      
      IF task_step_unique_key_ IS NOT NULL AND exe_task_step_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSTEPSYNCERR: Could not find the indicated Execution Task Step :P1', task_step_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('STEP_ID', exe_task_step_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('TASK_STEP_UNIQUE_KEY',  local_attr_);
   END IF;
   
   competency_id_ := Client_SYS.Get_Item_Value('COMPETENCY_ID', local_attr_);
   
   IF Check_Exist___(exe_task_step_id_, competency_id_) THEN
      local_attr_:= Client_SYS.Remove_Attr('STEP_ID',  local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('COMPETENCY_ID',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


FUNCTION Get_Task_Step_Id_By_Unique_Key (
   task_step_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_step_tab.task_step_id%TYPE;
   
   CURSOR get_task_step_id IS 
      SELECT task_step_id         
      FROM av_exe_task_step_tab
      WHERE mx_unique_key = task_step_unique_key_;
BEGIN
   OPEN get_task_step_id;
   FETCH get_task_step_id INTO temp_; 
   CLOSE get_task_step_id;
   
   RETURN temp_;
END Get_Task_Step_Id_By_Unique_Key;
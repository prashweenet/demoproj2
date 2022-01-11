-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskStep
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210208  SatGlk  LMM2020R1-1676, Implemented Set_State_from_Data_Mig to be used by Migration Job 210_FLM_EXE_TASK_STEP when setting the rowstate.
--  201222  sevhlk  AD2020R1-1080, Changed the size of the attribute string
--  201201  siselk  AD2020R1-927, Added Get_Awaiting_Insp_Count
--  201123  majslk  AD2020R1-896, Updated Sync_State_Handle___, Pre_Sync_Action, Post_Sync_Action, Added Add_Action method
--  201119  supklk  LMM2020R1-1136, Added Get_Task_Id_By_Unique_Key to fetch task id in data migration
--  201119  supklk  LMM2020R1-1136, Added Get_Key_By_Mx_Unique_Key to handle duplicates in data migration
--  201001  siselk  LMM2020R1-1248, updated Get_Task_Step_Ord_Set
--  200909  siselk  LMM2020R1-946, Change PassInspect to Complete in Sync_State_Handle___
--  200902  siselk  LMM2020R1-315, Partialy_Complete renamed to Change_State
--  200821  sevhlk  LMM2020R1-466, Added check_insert___ method.
--  200820  sevhlk  LMM2020R1-466, Added  Sync_State_Handle___, Pre_Sync and Post_Sync methods.
--  200811  siselk  LMM2020R1-154, Partialy_Complete
--  200731  siselk  LMM2020R1-114, Get_Task_Step_Ord_Set created
--  200713  SISELK  Created and added Get_Task_Step_Count
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_step_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   task_step_id_ NUMBER;
  
   CURSOR get_key_cursor IS
   SELECT av_exe_task_step_seq.nextval
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO task_step_id_;
   CLOSE get_key_cursor;
   
   IF (newrec_.task_step_id IS NULL) THEN
       newrec_.task_step_id := task_step_id_;
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('TASK_STEP_ID', task_step_id_, attr_);
END Check_Insert___;

PROCEDURE Sync_State_Handle___(
   current_rowstate_  IN VARCHAR2,
   incoming_rowstate_ IN VARCHAR2,
   input_objid_       IN VARCHAR2,
   input_objversion_  IN VARCHAR2)
IS
   info_                    VARCHAR2(4000);
   action_                  VARCHAR2(5)    := 'DO';
   state_attr_              VARCHAR2(7000);
   objid_                   VARCHAR2(4000) := input_objid_;
   objversion_              VARCHAR2(4000) := input_objversion_;
BEGIN
   IF (incoming_rowstate_ IS NULL )    OR
      (current_rowstate_ = 'Pending'    AND incoming_rowstate_ = 'MXPENDING')  OR
      (current_rowstate_ = 'Partial'    AND incoming_rowstate_ = 'MXPARTIAL')  OR
      (current_rowstate_ = 'Completed'  AND incoming_rowstate_ = 'MXCOMPLETE') OR
      (current_rowstate_ = 'NotApplicable' AND incoming_rowstate_ = 'MXNA')   THEN
      
      RETURN;
   END IF;

   IF current_rowstate_ = 'Pending' AND incoming_rowstate_ = 'MXPARTIAL' THEN
      Partialy_Complete__(info_, objid_, objversion_, state_attr_, action_);
   
   ELSIF current_rowstate_ = 'Pending' AND incoming_rowstate_ = 'MXNA' THEN
      Set_Not_Applicable__(info_, objid_, objversion_, state_attr_, action_);
      
   --MUST BE CHANGED HERE DOWN   
   ELSIF current_rowstate_ = 'Pending' AND incoming_rowstate_ = 'MXCOMPLETE' THEN
      Partialy_Complete__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Await_Inspect__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Complete__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSIF current_rowstate_ = 'Partial' AND incoming_rowstate_ = 'MXCOMPLETE' THEN
      Await_Inspect__(info_, objid_, objversion_, state_attr_, action_);
      
      Get_Version_By_Id___(objid_, objversion_);
      Complete__(info_, objid_, objversion_, state_attr_, action_);

   ELSIF current_rowstate_ = 'NotApplicable' AND incoming_rowstate_ = 'MXPENDING' THEN
      Set_Pending__(info_, objid_, objversion_, state_attr_, action_);
      
   ELSE
      Error_SYS.Appl_General(lu_name_, 'UNHANLEDSTATE: Could not handle the state :P1 to :P2', current_rowstate_, incoming_rowstate_);    
   END IF;
END Sync_State_Handle___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Step_Count(
   task_id_  IN NUMBER) RETURN NUMBER
IS
   count_ NUMBER;
   CURSOR get_task_step_count IS
      SELECT   COUNT(*)
      FROM     av_exe_task_step_tab
      WHERE    task_id = task_id_;
       
BEGIN
   OPEN  get_task_step_count;
   FETCH get_task_step_count INTO count_;
   CLOSE get_task_step_count;
   
   RETURN count_;
END Get_Task_Step_Count;


FUNCTION Get_Task_Step_Ord_Set(
   task_id_        IN NUMBER) RETURN VARCHAR2
IS
   step_ord_set_ VARCHAR2(50);

   CURSOR get_step_ord IS
      SELECT LISTAGG(step_ord, ', ') 
      WITHIN GROUP  (ORDER BY step_ord ASC)
      FROM           av_exe_task_step_tab
      WHERE          task_id = task_id_ AND (rowstate = 'Pending' OR rowstate = 'Partial' OR rowstate = 'AwaitingInspection');
      
BEGIN
   OPEN  get_step_ord;
   FETCH get_step_ord INTO step_ord_set_;
   CLOSE get_step_ord;  
   
   RETURN step_ord_set_;
END Get_Task_Step_Ord_Set;


PROCEDURE Change_State(
   task_step_id_ IN NUMBER,
   objstate_     IN VARCHAR2)
IS
   rec_   av_exe_task_step_tab%ROWTYPE;
BEGIN
   rec_ := Av_Exe_Task_Step_API.Get_Object_By_Keys___(task_step_id_);
   Av_Exe_Task_Step_API.Finite_State_Set___(rec_, objstate_);
   
END Change_State;


FUNCTION Is_Partial_State_Step_Exist (
   task_id_  IN NUMBER) RETURN VARCHAR2
IS
   is_partial_step_exist_  VARCHAR2(200);
   step_count_                  NUMBER;            
   
   CURSOR get_partial_task_step_count IS 
      SELECT COUNT(*)
      FROM   av_exe_task_step_tab
      WHERE  task_id = task_id_ AND 
             rowstate = 'Partial';  
BEGIN
   is_partial_step_exist_ :='FALSE';
   
   OPEN get_partial_task_step_count;
   FETCH get_partial_task_step_count INTO step_count_;
   CLOSE get_partial_task_step_count;
   
   IF step_count_ > 0 THEN
      is_partial_step_exist_ :='TRUE';
   END IF;
   RETURN is_partial_step_exist_;
   EXCEPTION
   WHEN no_data_found THEN
      RETURN is_partial_step_exist_;
END Is_Partial_State_Step_Exist;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_step_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_             VARCHAR2(7000);
   task_unique_key_        av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                av_exe_task_tab.task_id%TYPE;
   
   CURSOR get_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
   
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;
      
      IF task_unique_key_ IS NOT NULL AND task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSTEPSYNCERR: Could not find the indicated Task :P1', task_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('TASK_ID', task_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
   END IF;
   
   IF Client_SYS.Item_Exist('REASON', local_attr_) THEN
      Client_SYS.Add_To_Attr('REASON_STATUS', 1, local_attr_);
   ELSE
      Client_SYS.Add_To_Attr('REASON_STATUS', 0, local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Post_Sync_Action(
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2,
   attr_       IN VARCHAR2)
IS
   local_attr_              VARCHAR2(7000);
   current_rowstate_        av_exe_task_step_tab.rowstate%TYPE;
   incoming_rowstate_       VARCHAR2(50);
   task_step_rec_           av_exe_task_step_tab%ROWTYPE;
   rowstate_attribute_name_ VARCHAR2(50) := 'ROWSTATE';
   reason_                  av_exe_task_step_tab.reason%TYPE;
   action_user_             av_exe_task_action_tab.action_user%TYPE;
   action_date_             av_exe_task_action_tab.action_date%TYPE;
   reason_status_           NUMBER;
         
BEGIN
   local_attr_ := attr_;
   
   incoming_rowstate_ := Client_SYS.Get_Item_Value(rowstate_attribute_name_, local_attr_);
   task_step_rec_     := Get_Object_By_Id___(objid_);
   current_rowstate_  := Get_Objstate(task_step_rec_.task_step_id);
   reason_            := task_step_rec_.reason;
   
   Sync_State_Handle___(current_rowstate_, incoming_rowstate_, objid_, objversion_);
   
   reason_status_ := Client_SYS.Get_Item_Value('REASON_STATUS', local_attr_);    
   
   IF reason_status_ = 1 THEN
      action_user_ := Client_SYS.Get_Item_Value('ACTION_USER', local_attr_);  
      action_date_ := TO_DATE(Client_SYS.Get_Item_Value('ACTION_DATE', local_attr_),'yyyy-mm-dd HH24:MI:SS');
      Add_Action (objid_, objversion_, reason_, action_user_, action_date_);
   END IF;
   
END Post_Sync_Action;

FUNCTION Get_Rejected_Step (
   task_id_ IN NUMBER) RETURN VARCHAR2
IS
   rejected_step_ VARCHAR2(50);

   CURSOR get_rejected_step IS
      SELECT LISTAGG(step_ord, ', ') 
      WITHIN GROUP  (ORDER BY step_ord ASC)
      FROM           av_exe_task_step_tab
      WHERE          task_id = task_id_
      AND            is_rejected = 'TRUE';
      
BEGIN
   OPEN  get_rejected_step;
   FETCH get_rejected_step INTO rejected_step_;
   IF (get_rejected_step%FOUND) THEN
      RETURN rejected_step_;
   ELSE 
      RETURN NULL;
   END IF;
   CLOSE get_rejected_step;  
END Get_Rejected_Step;

PROCEDURE Add_Action (
   objid_        IN VARCHAR2,
   objversion_   IN VARCHAR2,
   reason_       IN VARCHAR2,
   action_user_  IN VARCHAR2,
   action_date_  IN TIMESTAMP)
IS
   action_ord_     NUMBER;
   new_action_ord_ NUMBER;
   task_action_id_ NUMBER;
   task_step_id_   NUMBER;
   action_type_    VARCHAR2(30);
   task_step_rec_  av_exe_task_step%ROWTYPE;

   CURSOR get_last_action_order IS
      SELECT   action_ord
      FROM     Av_Exe_Task_Action 
      WHERE    task_step_id = task_step_id_ AND action_ord IS NOT NULL 
      ORDER BY action_ord DESC
      FETCH    first 1 ROW ONLY;
      
   CURSOR get_task_step IS
      SELECT *
      FROM   Av_Exe_Task_Step
      WHERE  objid      = objid_
      AND    objversion = objversion_;
      
BEGIN
   OPEN  get_task_step;
   FETCH get_task_step INTO task_step_rec_;
   CLOSE get_task_step;  
   
   task_step_id_   := task_step_rec_.task_step_id;
   
   OPEN  get_last_action_order;
   FETCH get_last_action_order INTO action_ord_;
   CLOSE get_last_action_order;  
   
   task_action_id_ := Av_Exe_Task_Action_API.Get_Next_Seq();
   
   IF action_ord_ IS NOT NULL THEN 
      new_action_ord_ := action_ord_+1;
   ELSE 
      new_action_ord_ := 1;
   END IF;
     
   IF task_step_rec_.objstate = 'NotApplicable' THEN
      action_type_ := 'Marked as N/A';
   ELSIF task_step_rec_.objstate = 'Pending' THEN
      action_type_ := 'Marked as Applicable';
   END IF;
   
   Av_Exe_Task_Action_Api.New_Task_Action(task_action_id_, task_step_rec_.task_step_id, task_step_rec_.task_id, new_action_ord_, action_user_, reason_, action_date_, null, action_type_);
   
END Add_Action;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_step_tab.task_step_id%TYPE;
   
   CURSOR get_task_step_id IS 
      SELECT task_step_id         
        FROM av_exe_task_step_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_step_id;
   FETCH get_task_step_id INTO temp_; 
   CLOSE get_task_step_id;
   
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

FUNCTION Get_Awaiting_Insp_Count (
   task_id_ IN NUMBER ) RETURN NUMBER
IS
   return_ NUMBER;
   
   CURSOR get_awaiting_inspection_count IS 
      SELECT COUNT(*)
      FROM   av_exe_task_step_tab
      WHERE  task_id = task_id_ AND 
             rowstate = 'AwaitingInspection'; 
BEGIN
   OPEN get_awaiting_inspection_count;
   FETCH get_awaiting_inspection_count INTO return_; 
   CLOSE get_awaiting_inspection_count;
   
   RETURN return_;
END Get_Awaiting_Insp_Count;

-- This procedure will be used to set the task step state from the Migration Job 210_FLM_EXE_TASK_STEP
PROCEDURE Set_State_from_Data_Mig (
   mx_unique_key_    IN VARCHAR2,
   state_            IN VARCHAR2)
IS
   task_step_id_     av_exe_task_step_tab.task_step_id%TYPE;
   objid_            av_exe_task_step.objid%TYPE;
   objversion_       av_exe_task_step.objversion%TYPE;
   from_state_       av_exe_task_step_tab.rowstate%TYPE;
BEGIN
   task_step_id_ := Get_Key_By_Mx_Unique_Key(mx_unique_key_);
   IF(task_step_id_ IS NOT NULL) THEN
      Get_Id_Version_By_Keys___(objid_, objversion_, task_step_id_);
      from_state_      := Get_Objstate(task_step_id_);
      Sync_State_Handle___(from_state_, state_, objid_, objversion_);
   END IF;
END Set_State_from_Data_Mig;
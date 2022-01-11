-----------------------------------------------------------------------------
--
--  Logical unit: AvHistTaskAction
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201109  themlk  AD2020R1-1066, Removed Remove and added Modify
--  200915  themlk  DISCOP2020R1-123, New, Remove, Get_Objects_By_Keys, Get_Task_Action_Id
--  200924  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_task_action_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_task_action_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.task_action_id IS NULL) THEN
      newrec_.task_action_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('TASK_ACTION_ID', key_id_, attr_);
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_task_action_tab%ROWTYPE )
IS
   BEGIN
   New___(newrec_);
   END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_task_action_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   task_action_id_ IN NUMBER ) RETURN av_hist_task_action_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(task_action_id_);
END Get_Object_By_Keys;

FUNCTION Get_Task_Action_Id(
   mx_unique_key_  IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_task_action_id IS
   SELECT task_action_id
   FROM av_hist_task_action_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   task_action_id_ av_hist_task_action_tab.task_action_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_task_action_id;
   FETCH get_task_action_id INTO task_action_id_;
   CLOSE get_task_action_id;
   RETURN task_action_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Action_Id;


FUNCTION Mig_Get_Task_Action_Id(
   mx_unique_key_ IN VARCHAR2) RETURN av_hist_task_action_tab.task_action_id%TYPE
IS
   CURSOR get_task_action_id IS
   SELECT task_action_id
   FROM av_hist_task_action_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   task_action_id_ av_hist_task_action_tab.task_action_id%TYPE;
BEGIN
   
   OPEN get_task_action_id;
   FETCH get_task_action_id INTO task_action_id_;
   CLOSE get_task_action_id;
   
   IF task_action_id_ IS NULL THEN
      task_action_id_ := av_hist_task_action_seq.nextval;
   END IF;
   
   RETURN task_action_id_;
   
END Mig_Get_Task_Action_Id;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   step_id_             av_hist_task_step_tab.step_id%TYPE;
   step_unique_key_     VARCHAR2(100);
   
   CURSOR get_task_step IS
   SELECT step_id
   FROM av_hist_task_step_tab
   WHERE mx_unique_key =  step_unique_key_;
   
BEGIN
   IF Client_SYS.Item_Exist('STEP_UNIQUE_KEY', attr_) THEN
     step_unique_key_ := Client_SYS.Get_Item_Value('STEP_UNIQUE_KEY', attr_);   
   END IF;
   
   OPEN get_task_step;
   FETCH get_task_step INTO step_id_;
   CLOSE get_task_step;
   
   IF step_id_ IS NOT NULL THEN
      Client_SYS.Add_To_Attr('STEP_ID', step_id_, attr_);
   ELSIF step_id_ IS NULL THEN
      Error_SYS.Appl_General(lu_name_, 'SYNCERR: Could not find the indicated task step:P1', step_unique_key_);
   END IF;
   
   attr_:= Client_SYS.Remove_Attr('STEP_UNIQUE_KEY',  attr_);
END Pre_Sync_Action;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_task_action_tab
   WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
  
END Get_Id_Version_By_Mx_Uniq_Key;

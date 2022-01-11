-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskAction
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210408  siselk  AD-1536, Updated Pre_Sync_Action
--  210408  siselk  AD-1039, Updated Pre_Sync_Action
--  210308  majslk  LMM2020R1-1800, Updated Insert___ method, Added Update___ method
--  210303  SUPKLK  LMM2020R1-1643, Implemented Get_Key_By_Mx_Unique_Key to handle duplicates in data migration
--  210219  HasRLK  LMM2020R1-1571, Get_Task_Last_Action_Id change the selection process.
--  201123  majslk  AD2020R1-896, Added New_Task_Action method
--  201009  siselk  LMM2020R1-1268, New added
--  201001  siselk  LMM2020R1-1248, updated Check_Insert___ and override Insert___
--  200929  majslk  LMM2020R1-1217, Get_Task_Action method added
--  200902  Tajalk  LMM2020R1-841, Sync logic added
--  200731  siselk  LMM2020R1-114, Check_Insert___
--  200720  SISELK  LMM2020R1-115, Get_Task_Action_Count
--  200630  majslk  Created
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_action_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF((newrec_.task_action_id < 0) OR (newrec_.task_action_id IS NULL)) THEN
      newrec_.task_action_id := Av_Exe_Task_Action_API.Get_Next_Seq();
      Client_SYS.Add_To_Attr('TASK_ACTION_ID', newrec_.task_action_id, attr_);
   END IF;
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_exe_task_action_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   fault_id_   NUMBER;
   step_count_ NUMBER;
   task_id_    NUMBER;
   
   CURSOR Get_Task_Action_Bool IS 
   SELECT COUNT(*)
   FROM av_exe_task_step_tab
   WHERE task_id = task_id_ AND (rowstate = 'Pending' OR rowstate = 'Partial' OR rowstate = 'AwaitingInspection');
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   task_id_ := newrec_.task_id;
   OPEN Get_Task_Action_Bool;
   FETCH Get_Task_Action_Bool INTO step_count_;
   CLOSE Get_Task_Action_Bool;
   IF(fault_id_ IS NOT NULL AND NOT Av_Fault_Action_API.Exists(newrec_.task_action_id) AND step_count_ = 0) THEN
      Av_Fault_Action_API.New(newrec_.task_action_id, fault_id_, newrec_.action_user, newrec_.action_desc, newrec_.action_date, newrec_.action_ord
      , newrec_.mx_unique_key, 'True');
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
   oldrec_     IN     av_exe_task_action_tab%ROWTYPE,
   newrec_     IN OUT av_exe_task_action_tab%ROWTYPE,
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



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Last_Action_Id(
   task_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_ av_exe_task_action_tab.task_action_id%TYPE;
  
   CURSOR get_last_action_id IS
      SELECT task_action_id
      FROM   av_exe_task_action_tab
      WHERE  task_id = task_id_
      ORDER BY rowversion DESC
      FETCH FIRST 1 ROW ONLY;
      
BEGIN
   OPEN  get_last_action_id;  
   FETCH get_last_action_id INTO output_;
   CLOSE get_last_action_id;
   
   RETURN output_;
END Get_Task_Last_Action_Id;

FUNCTION Get_Task_Action_Count(
   task_id_  IN NUMBER) RETURN NUMBER
IS
   count_ NUMBER;
   CURSOR get_task_action_count IS
      SELECT COUNT(*)
      FROM   av_exe_task_action_tab
      WHERE  task_id = task_id_;
       
BEGIN
   OPEN  get_task_action_count;
   FETCH get_task_action_count INTO count_;
   CLOSE get_task_action_count;
   
   RETURN count_;
END Get_Task_Action_Count;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_exe_task_action_tab
       WHERE mx_unique_key = mx_unique_key_;

BEGIN
   OPEN  get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                    VARCHAR2(4000);
   task_unique_key_               av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                       av_exe_task_tab.task_id%TYPE;
   task_step_id_                  av_exe_task_step_tab.task_step_id%TYPE;
   
   CURSOR get_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = task_unique_key_;
      
   CURSOR get_task_first_step_id IS
      SELECT task_step_id
      FROM   av_exe_task_step_tab
      WHERE  task_id = task_id_
      AND    step_ord = (SELECT MIN(step_ord) 
                         FROM   av_exe_task_step_tab
                         WHERE  task_id = task_id_);
      
BEGIN
   local_attr_ := attr_;
    
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);
      
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;
      
      IF task_unique_key_ IS NOT NULL AND task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKASYNCERR: Could not find the indicated Task :P1', task_unique_key_);
      END IF;
      
      IF task_id_ IS NOT NULL THEN
         Client_SYS.Add_To_Attr('TASK_ID', task_id_, local_attr_);
      END IF;
      
      OPEN  get_task_first_step_id;
      FETCH get_task_first_step_id INTO task_step_id_;
      CLOSE get_task_first_step_id;
      
      IF task_id_ IS NOT NULL AND task_step_id_ IS NOT NULL THEN
         Client_SYS.Add_To_Attr('TASK_STEP_ID', task_step_id_, local_attr_);         
      END IF;
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT av_exe_task_action_seq.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN ( seq_no_ );
END Get_Next_Seq;

FUNCTION Get_Task_Action(
   task_step_id_  IN NUMBER) RETURN NUMBER
IS
   count_  NUMBER;
   
   CURSOR get_task_action IS
      SELECT   COUNT(*)
      FROM     av_exe_task_action_tab
      WHERE    task_step_id = task_step_id_;
       
BEGIN
   OPEN  get_task_action;
   FETCH get_task_action INTO count_;
   CLOSE get_task_action;
   
   IF count_ > 0 THEN
      RETURN 1;
   ELSE 
      RETURN 0;
   END IF;
END Get_Task_Action;

PROCEDURE New (
   task_action_id_ IN NUMBER,
   task_id_        IN NUMBER,
   action_ord_     IN NUMBER,
   action_user_    IN VARCHAR2,
   action_desc_    IN VARCHAR2,
   action_date_    IN av_exe_task_action_tab.action_date%TYPE,
   mx_unique_key_  IN VARCHAR2,
   action_type_    IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_exe_task_action_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('TASK_ACTION_ID', task_action_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
   Client_SYS.Add_To_Attr('ACTION_ORD', action_ord_, attr_);
   Client_SYS.Add_To_Attr('ACTION_USER', action_user_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DESC', action_desc_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DATE', action_date_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
   Client_SYS.Add_To_Attr('ACTION_TYPE', action_type_, attr_);
   
   Unpack___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE New_Task_Action (
   task_action_id_ IN NUMBER,
   task_step_id_   IN NUMBER,
   task_id_        IN NUMBER,
   action_ord_     IN NUMBER,
   action_user_    IN VARCHAR2,
   action_desc_    IN VARCHAR2,
   action_date_    IN av_exe_task_action_tab.action_date%TYPE,
   mx_unique_key_  IN VARCHAR2,
   action_type_    IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_exe_task_action_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('TASK_ACTION_ID', task_action_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_STEP_ID', task_step_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
   Client_SYS.Add_To_Attr('ACTION_ORD', action_ord_, attr_);
   Client_SYS.Add_To_Attr('ACTION_USER', action_user_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DESC', action_desc_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DATE', action_date_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
   Client_SYS.Add_To_Attr('ACTION_TYPE', action_type_, attr_);
   
   Unpack___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New_Task_Action;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_action_tab.task_action_id%TYPE;
   
   CURSOR get_task_action_id IS 
      SELECT task_action_id         
        FROM av_exe_task_action_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_action_id;
   FETCH get_task_action_id INTO temp_; 
   CLOSE get_task_action_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;
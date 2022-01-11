-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultAction
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210308  majslk  LMM2020R1-1800, Updated Insert___ method, Added Update___ method.
--  210301  SUPKLK  LMM2020R1-1646, Implemented Get_Key_By_Mx_Unique_Key and modified Check_Insert___ to handle duplicates and Implemented Get_Fault_Id_By_Unique_Key to fetch Fault Id in data migration
--  210224  asselk  LMM2020R1-1718, Get_Last_Action_Id change the selection process.
--  210118  SatGlk  LMM2020R1-1472, Modified Insert___, so that is corrective true is set for the last fault action in a given fault
--  201009  siselk  LMM2020R1-1268, Insert___ added
--  201001  siselk  LMM2020R1-1248, New created and Check_Insert___ updated to get sequence from task
--  200918  KAWJLK  LMM2020R1-711, Added Get_Fault_Action_Count.
--  200916  Tajalk  LMM2020R1-761, Sync logic added
--  200831  KAWJLK  LMM2020R1-557, Added @Override Check_Insert___.
--  200618  SatGlk  LMM2020R1-19, Added Get_Latest_Correct_Fault_Act to get the latest corrective action
--  200629  majslk  LMM2020R1-20, Added Get_Last_Action_Id to get the last corrective action id
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_action_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF newrec_.fault_action_id IS NULL THEN
      newrec_.fault_action_id := Av_Exe_Task_Action_API.Get_Next_Seq();
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ACTION_ID', newrec_.fault_action_id, attr_);
END Check_Insert___;
   
@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_action_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   fault_id_          NUMBER;
   task_id_           NUMBER;
  
   CURSOR Get_Task_Id IS 
    SELECT task_id
    FROM av_exe_task_tab
    WHERE fault_id = fault_id_;
BEGIN
   fault_id_ := newrec_.fault_id;
      
   -- if there is a last corrective action, set its is_corrective flag to false   
   Update_Is_Corr_to_False__(fault_id_);
   
   -- set the corrective flag of the new fault action to true
   newrec_.is_corrective := Fnd_Boolean_API.DB_TRUE;
   
   super(objid_, objversion_, newrec_, attr_);
   OPEN Get_Task_Id;
   FETCH Get_Task_Id INTO task_id_;
   CLOSE Get_Task_Id;
   IF(task_id_ IS NOT NULL AND NOT Av_Exe_Task_Action_API.Exists(newrec_.fault_action_id)) THEN
      Av_Exe_Task_Action_API.New(newrec_.fault_action_id, task_id_, newrec_.action_ord, newrec_.action_user, newrec_.action_desc, newrec_.action_date
      , newrec_.mx_unique_key, 'Deferred');
   END IF;
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(newrec_.fault_id);

         IF task_id_ IS NOT NULL THEN
            Av_Exe_Task_API.Update_Rowversion_For_Native(task_id_);
         END IF;
      END IF;
   END IF;
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     av_fault_action_tab%ROWTYPE,
   newrec_     IN OUT av_fault_action_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   task_id_     NUMBER;
   
   CURSOR get_task IS
      SELECT task_id
      FROM   Av_Exe_Task_Tab
      WHERE  fault_id = newrec_.fault_id;
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   
   IF (Dictionary_SYS.Component_Is_Active('FLM')) THEN
      IF newrec_.fault_id IS NOT NULL THEN
         Av_Fault_API.Update_Rowversion_For_Native(newrec_.fault_id);

         OPEN  get_task;
         FETCH get_task INTO task_id_;
         CLOSE get_task;

         IF task_id_ IS NOT NULL THEN
            Av_Exe_Task_API.Update_Rowversion_For_Native(task_id_);
         END IF;

      END IF;
   END IF;
END Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
-- This procedure set fault action(s) is_corrective flag to false of a given fault
PROCEDURE Update_Is_Corr_to_False__(
   fault_id_  IN NUMBER)
IS
BEGIN
   UPDATE av_fault_action_tab
     SET is_corrective = 'FALSE'
   WHERE fault_id = fault_id_
   AND   is_corrective = 'TRUE';
END Update_Is_Corr_to_False__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@UncheckedAccess
FUNCTION Get_Latest_Correct_Fault_Act (
   fault_id_ IN NUMBER) RETURN VARCHAR2
IS
   action_description_    AV_HIST_FAULT_ACTION_TAB.action_description%TYPE;
   CURSOR get_latest_action IS
      SELECT action_desc
      FROM   AV_FAULT_ACTION_TAB t
      WHERE  t.action_date  = ( SELECT MAX(a.action_date)
                                FROM   AV_FAULT_ACTION_TAB a      
                                WHERE  a.fault_id = fault_id_
                                AND    a.is_corrective =  Fnd_Boolean_API.DB_TRUE)
      AND    t.fault_id = fault_id_;
BEGIN
   OPEN  get_latest_action;
   FETCH get_latest_action INTO action_description_;
   IF (get_latest_action%NOTFOUND) THEN
      action_description_ := '';
   END IF;
   CLOSE get_latest_action;
   RETURN action_description_;
END Get_Latest_Correct_Fault_Act;

FUNCTION Get_Last_Action_Id (
   fault_id_ IN NUMBER) RETURN VARCHAR2
IS
   output_    av_fault_action_tab.fault_action_id%TYPE;
   
   CURSOR get_latest_action_id IS
      SELECT fault_action_id
      FROM   AV_FAULT_ACTION_TAB t
      WHERE  t.fault_id      =  fault_id_
      AND    t.is_corrective =  Fnd_Boolean_API.DB_TRUE
      ORDER BY t.action_date DESC
      FETCH FIRST 1 ROW ONLY;
      
BEGIN
   OPEN  get_latest_action_id;
   FETCH get_latest_action_id INTO output_;
   CLOSE get_latest_action_id;
   
   RETURN output_;
END Get_Last_Action_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_fault_action_tab
       WHERE mx_unique_key = mx_unique_key_;

BEGIN
   OPEN  get_id_version;
   FETCH get_id_version INTO objid_, objversion_; 
   CLOSE get_id_version;
  
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                     VARCHAR2(4000);
   fault_unique_key_               av_fault_tab.mx_unique_key%TYPE;
   fault_id_                       av_fault_tab.fault_id%TYPE;
   
   CURSOR get_fault_id IS
      SELECT fault_id
      FROM   av_fault_tab
      WHERE  mx_unique_key = fault_unique_key_;
      
BEGIN
   local_attr_ := attr_;
   
      
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
   
   attr_ := local_attr_;
END Pre_Sync_Action;

FUNCTION Get_Fault_Action_Count(
   fault_id_  IN NUMBER) RETURN NUMBER
IS
   count_ NUMBER;
   CURSOR get_fault_action_count IS
      SELECT   COUNT(*)
      FROM     av_fault_action_tab
      WHERE    fault_id = fault_id_;
       
BEGIN
   OPEN  get_fault_action_count;
   FETCH get_fault_action_count INTO count_;
   CLOSE get_fault_action_count;
   
   RETURN count_;
END Get_Fault_Action_Count;

PROCEDURE New (
   fault_action_id_ IN NUMBER,
   fault_id_        IN NUMBER,
   action_user_     IN VARCHAR2,
   action_desc_     IN VARCHAR2,
   action_date_     IN av_fault_action_tab.action_date%TYPE,
   action_ord_      IN NUMBER,
   mx_unique_key_   IN VARCHAR2,
   is_corrective_   IN av_fault_action_tab.is_corrective%TYPE)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_fault_action_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('FAULT_ACTION_ID', fault_action_id_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
   Client_SYS.Add_To_Attr('ACTION_USER', action_user_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DESC', action_desc_, attr_);
   Client_SYS.Add_To_Attr('ACTION_DATE', action_date_, attr_);
   Client_SYS.Add_To_Attr('ACTION_ORD', action_ord_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);
   Client_SYS.Add_To_Attr('IS_CORRECTIVE', is_corrective_, attr_);
   
   Unpack___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_action_tab.fault_action_id%TYPE;
   
   CURSOR get_fault_action_id IS 
      SELECT fault_action_id         
        FROM av_fault_action_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_fault_action_id;
   FETCH get_fault_action_id INTO temp_; 
   CLOSE get_fault_action_id;
   
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
-----------------------------------------------------------------------------
--
--  Logical unit: AvHistTaskStep
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Task_Step_Id
--  200924  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
--  201006  baablk  DISO2020R1-413, Added Check_Insert___, Get_Id_Version_By_Mx_Uniq_Key, Pre_Sync_Action methods
-----------------------------------------------------------------------------

layer Core;
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_task_step_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_ NUMBER;
   
   CURSOR get_key_cursor IS
   SELECT av_hist_task_step_seq.NEXTVAL
   FROM dual;
BEGIN
   OPEN get_key_cursor;
   FETCH get_key_cursor INTO key_;
   CLOSE get_key_cursor;
   
   IF(newrec_.step_id IS NULL) THEN
      newrec_.step_id:= key_;
   END IF;
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('STEP_ID', key_, attr_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_task_step_tab
   WHERE  mx_unique_key  = mx_unique_key_;
   
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_ IN OUT VARCHAR2)
IS
   local_attr_                  VARCHAR2(4000);
   execution_task_unique_key_   VARCHAR2(80);
   et_barcode_                  av_hist_execution_task_tab.et_barcode%TYPE;
   
   CURSOR check_barcode_ref_ IS 
   SELECT et_barcode 
   FROM av_hist_execution_task_tab
   WHERE et_barcode = execution_task_unique_key_;
   
BEGIN
   local_attr_ := attr_;
   IF Client_SYS.Item_Exist('ET_BARCODE', local_attr_) THEN
      execution_task_unique_key_ := Client_SYS.Get_Item_Value('ET_BARCODE', local_attr_);
      
      OPEN check_barcode_ref_;
      FETCH check_barcode_ref_ INTO et_barcode_;
      CLOSE check_barcode_ref_;
      
      IF execution_task_unique_key_ IS NOT NULL AND et_barcode_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSTEPSYNCERR: Could not find the indicated Execution task :P1', et_barcode_);
      END IF;
   END IF;
END Pre_Sync_Action;

FUNCTION Get_Task_Step_Id(
   mx_unique_key_  IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_task_step_id IS
   SELECT step_id
   FROM Av_Hist_Task_Step_Tab
   WHERE mx_unique_key = mx_unique_key_;
  
   task_step_id_ av_hist_task_step_tab.step_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_task_step_id;
   FETCH get_task_step_id INTO task_step_id_;
   CLOSE get_task_step_id;
   RETURN task_step_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Step_Id;

PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_task_step_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_task_step_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   step_id_ IN NUMBER ) RETURN av_hist_task_step_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(step_id_);
END Get_Object_By_Keys;


FUNCTION Mig_Get_Task_Step_Id(
   mx_unique_key_ IN VARCHAR2) RETURN Av_Hist_Task_Step_Tab.step_id%TYPE
IS
   CURSOR get_step_id IS
   SELECT step_id
   FROM Av_Hist_Task_Step_Tab
   WHERE mx_unique_key = mx_unique_key_;
   
   step_id_ Av_Hist_Task_Step_Tab.step_id%TYPE;
BEGIN
  
   OPEN get_step_id;
   FETCH get_step_id INTO step_id_;
   CLOSE get_step_id;
   
   IF step_id_ IS NULL THEN
      step_id_ := av_hist_task_step_seq.nextval;
   END IF;
   
   RETURN step_id_;
   
END Mig_Get_Task_Step_Id;

FUNCTION Get_Step_Id_From_Ord_N_Unq(
   step_ordinal_ IN NUMBER,
   mx_unique_key_ IN VARCHAR2) RETURN Av_Hist_Task_Step_Tab.step_id%TYPE
IS
   CURSOR get_stp_id IS
   SELECT step_id
   FROM Av_Hist_Task_Step_Tab
   WHERE mx_unique_key = mx_unique_key_ AND
   step_ordinal = step_ordinal_;
   
    step_id_ Av_Hist_Task_Step_Tab.step_id%TYPE;
BEGIN
   
   OPEN get_stp_id;
   FETCH get_stp_id INTO step_id_;
   CLOSE get_stp_id;
   
   RETURN step_id_;
   
END Get_Step_Id_From_Ord_N_Unq;
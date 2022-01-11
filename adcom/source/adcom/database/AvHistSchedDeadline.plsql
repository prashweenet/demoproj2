-----------------------------------------------------------------------------
--
--  Logical unit: AvHistSchedDeadline
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201109  themlk  AD2020R1-1066, Removed Remove and added Modify
--  200915  themlk  DISCOP2020R1-123, New, Remove, Get_Objects_By_Keys, Get_Sched_Deadline_Id
--  200924  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_sched_deadline_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_sched_deadline_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.sched_deadline_id IS NULL) THEN
      newrec_.sched_deadline_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('SCHED_DEADLINE_ID', key_id_, attr_);
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_sched_deadline_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_sched_deadline_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   sched_deadline_id_ IN NUMBER ) RETURN av_hist_sched_deadline_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(sched_deadline_id_);
END Get_Object_By_Keys;

FUNCTION Get_Sched_Deadline_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_sched_deadline_id IS
   SELECT sched_deadline_id
   FROM av_hist_sched_deadline_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   sched_deadline_id_ av_hist_sched_deadline_tab.sched_deadline_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_sched_deadline_id;
   FETCH get_sched_deadline_id INTO sched_deadline_id_;
   CLOSE get_sched_deadline_id;
   RETURN sched_deadline_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Sched_Deadline_Id;


FUNCTION Mig_Get_Sched_Deadline_Id(
   mx_unique_key_ IN VARCHAR2) RETURN av_hist_sched_deadline_tab.sched_deadline_id%TYPE
IS
   CURSOR get_sched_deadline_id IS
   SELECT sched_deadline_id
   FROM av_hist_sched_deadline_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   sched_deadline_id_ av_hist_sched_deadline_tab.sched_deadline_id%TYPE;
BEGIN
  
   OPEN get_sched_deadline_id;
   FETCH get_sched_deadline_id INTO sched_deadline_id_;
   CLOSE get_sched_deadline_id;
   IF sched_deadline_id_ IS NULL THEN
      sched_deadline_id_ := av_hist_sched_deadline_seq.nextval;
   END IF;
   
   RETURN sched_deadline_id_;   
   
END Mig_Get_Sched_Deadline_Id;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   pt_barcode_             av_hist_planning_task_tab.pt_barcode%TYPE;
   planning_task_barcode_  av_hist_planning_task_tab.pt_barcode%TYPE;
   
   CURSOR get_pt_barcode IS
   SELECT pt_barcode
   FROM av_hist_planning_task_tab
   WHERE pt_barcode =  pt_barcode_;
   
BEGIN
   IF Client_SYS.Item_Exist('PT_BARCODE', attr_) THEN
     pt_barcode_ := Client_SYS.Get_Item_Value('PT_BARCODE', attr_);   
   END IF;
   
   OPEN get_pt_barcode;
   FETCH get_pt_barcode INTO planning_task_barcode_;
   CLOSE get_pt_barcode;
   
   IF planning_task_barcode_ IS NULL THEN
      Error_SYS.Appl_General(lu_name_, 'TASKSYNCERR: Could not find the indicated barcode:P1', pt_barcode_);
   END IF;
   
   Client_SYS.Add_To_Attr('SCHED_DEADLINE_ID', av_hist_sched_deadline_seq.nextval, attr_);
END Pre_Sync_Action;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_sched_deadline_tab
   WHERE mx_unique_key = mx_unique_key_;
   
BEGIN
   
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
  
END Get_Id_Version_By_Mx_Uniq_Key;
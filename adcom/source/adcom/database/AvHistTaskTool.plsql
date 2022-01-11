-----------------------------------------------------------------------------
--
--  Logical unit: AvHistTaskTool
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  201109  themlk  AD2020R1-1066, Removed Remove and added Modify
--  200915  themlk  DISCOP2020R1-123, New, Remove, Get_Objects_By_Keys, Get_Task_Tool_Id
--  200924  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs 
--  201007  kapalk  DISCO2020R1-424, Added pre sync action procedure 
-----------------------------------------------------------------------------

layer Core;
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_task_tool_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_task_tool_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.task_tool_id IS NULL) THEN
      newrec_.task_tool_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('TASK_TOOL_ID', key_id_, attr_);
   super(newrec_, indrec_, attr_);
END Check_Insert___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_task_tool_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;
PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_task_tool_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys (
   task_tool_id_ IN NUMBER ) RETURN av_hist_task_tool_tab%ROWTYPE
IS   
BEGIN
   RETURN Get_Object_By_Keys___(task_tool_id_);
END Get_Object_By_Keys;

FUNCTION Get_Task_Tool_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_task_tool_id IS
   SELECT task_tool_id
   FROM av_hist_task_tool_tab
   WHERE mx_unique_key = mx_unique_key_;
  
   task_tool_id_ av_hist_task_tool_tab.task_tool_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
         RETURN NULL;
   END IF;
   OPEN get_task_tool_id;
   FETCH get_task_tool_id INTO task_tool_id_;
   CLOSE get_task_tool_id;
   RETURN task_tool_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Task_Tool_Id;

FUNCTION Mig_Get_Task_Tool_Id(
   mx_unique_key_ IN VARCHAR2) RETURN av_hist_task_tool_tab.task_tool_id%TYPE
IS
   CURSOR get_task_tool_id IS
   SELECT task_tool_id
   FROM av_hist_task_tool_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   task_tool_id_ av_hist_task_tool_tab.task_tool_id%TYPE;
BEGIN
  
   OPEN get_task_tool_id;
   FETCH get_task_tool_id INTO task_tool_id_;
   CLOSE get_task_tool_id;
   
   IF task_tool_id_ IS NULL THEN
      task_tool_id_ := av_hist_task_tool_seq.nextval;
   END IF;
   
   RETURN task_tool_id_;
   
END Mig_Get_Task_Tool_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM  av_hist_task_tool_tab
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
   
   CURSOR get_et_barcode IS
     SELECT et_barcode 
     FROM   av_hist_execution_task_tab
     WHERE  et_barcode = execution_task_unique_key_;
   
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('ET_BARCODE', local_attr_) THEN
      execution_task_unique_key_ := Client_SYS.Get_Item_Value('ET_BARCODE', local_attr_);    
      --checks whether et barcode is available in av_hist_execution_task_tab 
      OPEN  get_et_barcode;
      FETCH get_et_barcode INTO et_barcode_ ;
      CLOSE get_et_barcode;
      
      IF execution_task_unique_key_ IS NOT NULL AND et_barcode_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKTOOLSYNCERR: Could not find the indicated et_barcode  :P1', et_barcode_);
      END IF;
   END IF;   
   attr_ := local_attr_;
END Pre_Sync_Action;
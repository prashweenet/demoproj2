-----------------------------------------------------------------------------
--
--  Logical unit: AvTaskStepMeasurement
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200929  majslk  LMM2020R1-1217 - Get_Measurement_Status method added.
--  200824  TAJALK  LMM2020R1-746 - Added sync logic
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
      FROM  av_task_step_measurement_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                    VARCHAR2(4000);
   task_unique_key_               av_exe_task_tab.mx_unique_key%TYPE;
   task_id_                       av_exe_task_tab.task_id%TYPE;
   measurement_type_code_         av_exe_task_measurement_tab.measurement_type_code%TYPE;
   measurement_id_                av_exe_task_measurement_tab.measurement_id%TYPE;
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
      
   CURSOR get_task_measurement_id IS
      SELECT measurement_id
      FROM   av_exe_task_measurement_tab
      WHERE  task_id = task_id_
      AND    measurement_type_code = measurement_type_code_
      AND    rowversion = (SELECT MAX(rowversion)
                              FROM   av_exe_task_measurement_tab
                              WHERE  task_id = task_id_
                              AND    measurement_type_code = measurement_type_code_);
BEGIN
   local_attr_ := attr_;
   
   task_unique_key_ := Client_SYS.Get_Item_Value('TASK_UNIQUE_KEY', local_attr_);    
   IF Client_SYS.Item_Exist('TASK_UNIQUE_KEY', local_attr_) THEN
      
      OPEN  get_task_id;
      FETCH get_task_id INTO task_id_;
      CLOSE get_task_id;
      
      IF task_unique_key_ IS NOT NULL AND task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSYNCERR: Could not find the indicated Task :P1', task_unique_key_);
      END IF;
      
      OPEN  get_task_first_step_id;
      FETCH get_task_first_step_id INTO task_step_id_;
      CLOSE get_task_first_step_id;
      
      IF task_step_id_ IS NOT NULL THEN
         Client_SYS.Add_To_Attr('TASK_STEP_ID', task_step_id_, local_attr_);
         local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
         
         measurement_type_code_ := Client_SYS.Get_Item_Value('MEASUREMENT_TYPE_CODE', local_attr_);
         
         IF measurement_type_code_ IS NOT NULL THEN
            OPEN  get_task_measurement_id;
            FETCH get_task_measurement_id INTO measurement_id_;
            CLOSE get_task_measurement_id;
            
            IF measurement_id_ IS NOT NULL THEN
               Client_SYS.Add_To_Attr('MEASUREMENT_ID', measurement_id_, local_attr_);
               local_attr_:= Client_SYS.Remove_Attr('MEASUREMENT_TYPE_CODE',  local_attr_);
               
            ELSE
               Error_SYS.Appl_General(lu_name_, 'TASKMEASSYNCERR1: Could not find the indicated measurement for Task :P1 Measurement Type :P2', task_unique_key_, measurement_type_code_);
            END IF;
            
            IF Check_Exist___(task_step_id_, measurement_id_) THEN
               local_attr_:= Client_SYS.Remove_Attr('TASK_STEP_ID',   local_attr_);
               local_attr_:= Client_SYS.Remove_Attr('MEASUREMENT_ID', local_attr_);
            END IF;
         ELSE
            Error_SYS.Appl_General(lu_name_, 'TASKMEASSYNCERR2: Empty measurement type for Task :P1', task_unique_key_);
         END IF;
      ELSE
         Error_SYS.Appl_General(lu_name_, 'TASKSTEPSYNCERR: Could not find the indicated first step for Task :P1', task_unique_key_);
      END IF;
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


FUNCTION Get_Measurement_Status(
   task_step_id_  IN NUMBER) RETURN NUMBER
IS
   count_  NUMBER;
   
   CURSOR get_measurement_status IS
      SELECT COUNT(*)
      FROM   av_exe_task_measurement_tab 
      WHERE  measured_user IS NOT NULL 
      AND    measurement_id IN
                              (SELECT measurement_id
                               FROM   av_task_step_measurement
                               WHERE  task_step_id = task_step_id_);
       
BEGIN
   OPEN  get_measurement_status;
   FETCH get_measurement_status INTO count_;
   CLOSE get_measurement_status;
   
   IF count_ > 0 THEN
      RETURN 1;
   ELSE 
      RETURN 0;
   END IF;
END Get_Measurement_Status;
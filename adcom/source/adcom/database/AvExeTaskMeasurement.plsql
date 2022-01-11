-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskMeasurement
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210302  tprelk  LMM2020R1-1585, Added Get_Measurement_Value,Get_Measurement_Category.
--  201104  SUPKLK  LMM2020R1-1129 Created Get_Key_By_Mx_Unique_Key and Modified Check_Insert___ to handle duplicates in data migration
--  201104  SUPKLK  LMM2020R1-1129 Created Get_Task_Id_By_Mx_Unique_Key
--  200821  TAJALK  LMM2020R1-472 - Added sync logic
--  200731  majslk  LMM2020R1-451, Added Get_Measurment_Status, removed signed_user from Check_Insert.
--  200729  majslk  Removed Get_Task_Step_Set, Added Get_Task_Step_Ord_Set and Get_Measurement_Quantity.
--  200728  TAJALK  LMM2020R1-89,  Changed Check_Insert___ logic
--  200709  majslk  LMM2020R1-111, Created
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_measurement_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   CURSOR get_key_set IS
      SELECT av_exe_task_measurement_seq.NEXTVAL
      FROM dual;
BEGIN
   IF (newrec_.measurement_id IS NULL) THEN
      OPEN get_key_set;
      FETCH get_key_set INTO newrec_.measurement_id;
      CLOSE get_key_set; 
   END IF;  
   super(newrec_, indrec_, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Task_Measurement_Count(
   task_id_ IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
  
   CURSOR get_measurement_count IS
      SELECT COUNT(*)
      FROM   av_exe_task_measurement_tab
      WHERE  task_id = task_id_; 
BEGIN
   OPEN  get_measurement_count;
   FETCH get_measurement_count INTO output_;
   CLOSE get_measurement_count;
   
   RETURN output_;
END Get_Task_Measurement_Count;

FUNCTION Get_Task_Step_Ord_Set(
   task_id_        IN NUMBER,
   measurement_id_ IN NUMBER) RETURN VARCHAR2
IS
   step_ord_set_ VARCHAR2(50);

   CURSOR get_step_ord IS
      SELECT LISTAGG(s.step_ord, ';') 
      WITHIN GROUP  (ORDER BY measurement_id DESC)
      FROM           av_exe_task_step_tab s, av_task_step_measurement m
      WHERE          s.task_step_id IN (
                                        SELECT task_step_id
                                        FROM   av_exe_task_step_tab
                                        WHERE  task_id = task_id_)
      AND            m.task_step_id = s.task_step_id
      AND            measurement_id = measurement_id_;
      
BEGIN
   OPEN  get_step_ord;
   FETCH get_step_ord INTO step_ord_set_;
   CLOSE get_step_ord;  
   
   RETURN step_ord_set_;
END Get_Task_Step_Ord_Set;

FUNCTION Get_Measurement_Quantity(
   measurement_id_      NUMBER) RETURN VARCHAR2
IS
   measurement_qty_       av_exe_task_measurement.measurement_qty%TYPE;
   measurement_type_code_ av_exe_task_measurement.measurement_type_code%TYPE;
   measurement_type_      av_measurement_type.engineering_unit_code%TYPE;
   measurement_           VARCHAR2(30);

   CURSOR get_measurement IS
      SELECT measurement_qty, measurement_type_code
      FROM   av_exe_task_measurement 
      WHERE  measurement_id = measurement_id_;
      
   CURSOR get_measurement_type IS
      SELECT engineering_unit_code
      FROM   av_measurement_type 
      WHERE  measurement_type_code = measurement_type_code_;
           
BEGIN
   OPEN  get_measurement;
   FETCH get_measurement INTO measurement_qty_, measurement_type_code_;
   CLOSE get_measurement;
   
   OPEN  get_measurement_type;
   FETCH get_measurement_type INTO measurement_type_;
   CLOSE get_measurement_type;
   
   IF measurement_qty_ IS NULL THEN
      measurement_ := NULL;
   ELSE
      measurement_ := CONCAT(CONCAT(measurement_qty_, ' '), measurement_type_);
   END IF;
   
   RETURN measurement_;
END Get_Measurement_Quantity;

FUNCTION Get_Measurment_Status (
  measurement_id_   IN NUMBER ) RETURN VARCHAR2
IS
   measured_user_ VARCHAR2(40);
   status_        VARCHAR2(100);
   
   CURSOR get_signed_user IS
   SELECT measured_user
   FROM   av_exe_task_measurement 
   WHERE  measurement_id = measurement_id_;
   
BEGIN 
   OPEN  get_signed_user;
   FETCH get_signed_user INTO measured_user_;
   CLOSE get_signed_user;
   
   IF (measured_user_ IS NULL OR measured_user_ = '') THEN
      status_ := 'Pending';
   ELSE 
      status_ := 'Signed';
   END IF;
   
   RETURN status_;   
END Get_Measurment_Status;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_measurement_tab
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
   exe_task_unique_key_        av_exe_task_tab.mx_unique_key%TYPE;
   exe_task_id_                av_exe_task_tab.task_id%TYPE;
         
   CURSOR get_exe_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = exe_task_unique_key_;
BEGIN
   local_attr_ := attr_;
   
   IF Client_SYS.Item_Exist('EXE_TASK_UNIQUE_KEY', local_attr_) THEN
      exe_task_unique_key_     := Client_SYS.Get_Item_Value('EXE_TASK_UNIQUE_KEY', local_attr_);    
      
      OPEN  get_exe_task_id;
      FETCH get_exe_task_id INTO exe_task_id_;
      CLOSE get_exe_task_id;
      
      IF exe_task_unique_key_ IS NOT NULL AND exe_task_id_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'TASKSYNCERR: Could not find the indicated Execution Task :P1', exe_task_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('TASK_ID', exe_task_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('EXE_TASK_UNIQUE_KEY',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


FUNCTION Get_Task_Id_By_Mx_Unique_Key (
   exe_task_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   exe_task_id_   av_exe_task_tab.task_id%TYPE;
   
   CURSOR get_exe_task_id IS
      SELECT task_id
      FROM   av_exe_task_tab
      WHERE  mx_unique_key = exe_task_unique_key_;
BEGIN
   OPEN  get_exe_task_id;
   FETCH get_exe_task_id INTO exe_task_id_;
   CLOSE get_exe_task_id;
   
   RETURN exe_task_id_;
END Get_Task_Id_By_Mx_Unique_Key;


FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_measurement_tab.measurement_id%TYPE;
   
   CURSOR get_measurement_id IS 
      SELECT measurement_id         
      FROM av_exe_task_measurement_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_measurement_id;
   FETCH get_measurement_id INTO temp_; 
   CLOSE get_measurement_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;

FUNCTION Get_Measurement_Value(
   measurement_id_      NUMBER) RETURN VARCHAR2
IS
   measurement_qty_        av_exe_task_measurement.measurement_qty%TYPE;
   measurement_type_code_  av_exe_task_measurement.measurement_type_code%TYPE;
   measurement_date_time_  av_exe_task_measurement.measurement_date_time%TYPE;
   measurement_text_       av_exe_task_measurement.measurement_text%TYPE;
   measurement_type_       av_measurement_type.engineering_unit_code%TYPE;
   measurement_category_   av_measurement_type.measurement_category_code%TYPE;
   measurement_            VARCHAR2(30);

   CURSOR get_measurement IS
      SELECT measurement_qty, measurement_type_code,measurement_date_time,measurement_text
      FROM   av_exe_task_measurement_tab 
      WHERE  measurement_id = measurement_id_;
      
   CURSOR get_measurement_type IS
      SELECT engineering_unit_code,measurement_category_code
      FROM   av_measurement_type_tab 
      WHERE  measurement_type_code = measurement_type_code_;
           
BEGIN
   OPEN  get_measurement;
   FETCH get_measurement INTO measurement_qty_, measurement_type_code_,measurement_date_time_,measurement_text_;
   CLOSE get_measurement;
   
   OPEN  get_measurement_type;
   FETCH get_measurement_type INTO measurement_type_,measurement_category_;
   CLOSE get_measurement_type;
   
   IF measurement_qty_ IS NOT NULL THEN
      IF(measurement_category_ = 'CHK') THEN
         IF(measurement_qty_ =0) THEN
           measurement_ := 'NO';
         ELSE
           measurement_ := 'YES'; 
         END IF;
      ELSE
         measurement_ := CONCAT(CONCAT(measurement_qty_, ' '), measurement_type_);
      END IF;    
      
   ELSIF measurement_date_time_ IS NOT NULL THEN
      measurement_ :=  TO_CHAR( measurement_date_time_, 'DD-MON-YY' );
   ELSIF measurement_text_ IS NOT NULL THEN
      measurement_ := measurement_text_;
   ELSE
      measurement_ := null;
   END IF;
   
   RETURN measurement_;
   
END Get_Measurement_Value;
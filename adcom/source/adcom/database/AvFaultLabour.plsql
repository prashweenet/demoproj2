-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultLabour
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210311  Jihalk  LMM2020R1-1591, Modifed Converted_time Method.
--  210309  Jihalk  LMM2020R1-1591, Added Converted_time Method.
--  210307  SatGlk  LMM2020R1-1895, Modified overridden Insert___ to include MX_UNIQUE_KEY when making a new Task Labour.
--  210222  SUPKLK  LMM2020R1-1648, Implemented Get_Key_By_Mx_Unique_Key to handle duplicates in data migration and implemented Get_Fault_Id_By_Unique_Key to fetch fault_id
--  201008  lahnlk  LMM2020R1-1309, overtake Modify__ ,added Modify
--  200929  lahnlk  LMM2020R1-1273, overtake Check_Insert___,override Delete___, created Remove
--  200916  Tajalk  LMM2020R1-756, Sync logic added
--  200803  SatGlk  LMM2020R1-552, Implemented New to be called by AvExeTaskLabour if a Fault is connected to a Task
--  200731  KAWJLK  LMM2020R1-551, Added Insert_after_task public method.
--  200717  SatGlk  LMM2020R1-158, Overriden Check_Insert___ to add next sequence value to fault_labour_id.
--  200715  dildlk  LMM2020R1-157, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_labour_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_fault_labour_tab%ROWTYPE;
BEGIN
   IF ((newrec_.fault_labour_id < 0)OR (newrec_.fault_labour_id IS NULL)) THEN      
     newrec_.fault_labour_id := Av_Exe_Task_Labour_API.Get_Next_Seq();
      Client_SYS.Add_To_Attr('FAULT_LABOUR_ID', newrec_.fault_labour_id, attr_);
   END IF;
   --Validate_SYS.Item_Insert(lu_name_, 'FAULT_LABOUR_ID', indrec_.fault_labour_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT av_fault_labour_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   task_id_    NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   task_id_    := Av_Exe_Task_API.Get_Task_Id(newrec_.fault_id);
   
   IF(task_id_ != 0 AND NOT Av_Exe_Task_Labour_API.Exists(newrec_.fault_labour_id)) THEN
      Av_Exe_Task_Labour_API.New(newrec_.fault_labour_id, task_id_, newrec_.competency_id, newrec_.num_people_required, newrec_.hours_per_person, NULL, newrec_.mx_unique_key);
   END IF;  
END Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_fault_labour_tab%ROWTYPE )
IS
   task_id_    NUMBER;
BEGIN
   super(objid_, remrec_);
   
   task_id_    := Av_Exe_Task_API.Get_Task_Id(remrec_.fault_id);
   IF((task_id_ != 0) AND (Av_Exe_Task_Labour_API.Exists(remrec_.fault_labour_id)))THEN
      Av_Exe_Task_Labour_API.Remove(remrec_.fault_labour_id);
   END IF;
END Delete___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
@Overtake Base
PROCEDURE Modify__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   oldrec_   av_fault_labour_tab%ROWTYPE;
   newrec_   av_fault_labour_tab%ROWTYPE;
   indrec_   Indicator_Rec;
   task_id_    NUMBER;
BEGIN
   IF (action_ = 'CHECK') THEN
      oldrec_ := Get_Object_By_Id___(objid_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
   ELSIF (action_ = 'DO') THEN
      oldrec_ := Lock_By_Id___(objid_, objversion_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_);
      
      task_id_    := Av_Exe_Task_API.Get_Task_Id(newrec_.fault_id);
      IF((task_id_ != 0) AND (Av_Exe_Task_Labour_API.Exists(newrec_.fault_labour_id)))THEN
         Client_SYS.Add_To_Attr('TASK_ID',          task_id_,                 attr_);
         Client_SYS.Add_To_Attr('HOURS_PER_PERSON',  newrec_.hours_per_person,    attr_);
         Client_SYS.Add_To_Attr('NUM_PEOPLE_REQUIRED',  newrec_.num_people_required,    attr_);
         Client_SYS.Add_To_Attr('COMPETENCY_ID',  newrec_.competency_id,    attr_);
         Av_Exe_Task_Labour_API.Modify(newrec_.fault_labour_id,attr_); 
      END IF;
   END IF;
   info_ := Client_SYS.Get_All_Info;
END Modify__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Skills_Count(
   fault_id_    IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
   CURSOR get_skills_count IS
      SELECT   COUNT(*)
      FROM     av_fault_labour_tab
      WHERE    fault_id = fault_id_;
BEGIN
   OPEN  get_skills_count;
   FETCH get_skills_count INTO output_;
   CLOSE get_skills_count;
   RETURN output_;
   
END Get_Skills_Count;

--Creates a new Fault Labour record
PROCEDURE New (
   fault_labour_id_        IN NUMBER,
   fault_id_               IN NUMBER,
   competency_id_          IN VARCHAR2,
   num_people_required_    IN NUMBER,
   hours_per_person_       IN NUMBER,
   mx_unique_key_          IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_fault_labour_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   Client_SYS.Add_To_Attr('FAULT_LABOUR_ID', fault_labour_id_, attr_);
   Client_SYS.Add_To_Attr('FAULT_ID', fault_id_, attr_);
   Client_SYS.Add_To_Attr('COMPETENCY_ID', competency_id_, attr_);
   Client_SYS.Add_To_Attr('NUM_PEOPLE_REQUIRED', num_people_required_, attr_);
   Client_SYS.Add_To_Attr('HOURS_PER_PERSON', hours_per_person_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);

   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
        FROM av_fault_labour_tab
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
   mx_unique_key_                  av_fault_labour_tab.mx_unique_key%TYPE;
   objid_                          VARCHAR2(4000);
   objversion_                     VARCHAR2(4000);
   
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
   
   mx_unique_key_ := Client_SYS.Get_Item_Value('MX_UNIQUE_KEY', local_attr_); 
   Get_Id_Version_By_Mx_Uniq_Key(objid_, objversion_, mx_unique_key_);
   
   IF objid_ IS NOT NULL THEN
      local_attr_:= Client_SYS.Remove_Attr('FAULT_LABOUR_ID',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Remove (
   fault_labour_id_         IN NUMBER
   )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_fault_labour_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,fault_labour_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Remove;

PROCEDURE Modify (
   fault_labour_id_         IN NUMBER,
   attr_       IN OUT VARCHAR2
  )
IS
      objid_      VARCHAR2(2000);
      objversion_ VARCHAR2(2000);
      oldrec_   av_fault_labour_tab%ROWTYPE;
      newrec_   av_fault_labour_tab%ROWTYPE;
      indrec_   Indicator_Rec;
BEGIN
         Get_Id_Version_By_Keys___ (objid_,objversion_,fault_labour_id_);
         oldrec_ := Lock_By_Id___(objid_, objversion_);
         newrec_ := oldrec_;
         Unpack___(newrec_, indrec_, attr_);
         Check_Update___(oldrec_, newrec_, indrec_, attr_);
         Update___(objid_, oldrec_, newrec_, attr_, objversion_);

END Modify;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_labour_tab.fault_labour_id%TYPE;
   
   CURSOR get_labour_id IS 
      SELECT fault_labour_id         
        FROM av_fault_labour_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_labour_id;
   FETCH get_labour_id INTO temp_; 
   CLOSE get_labour_id;
   
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

FUNCTION Converted_time (
   labour_id_ IN NUMBER) RETURN VARCHAR2
IS
   hours_            NUMBER;
   converted_value_  VARCHAR2(10);
   
   CURSOR get_hours IS
   SELECT Round((TRUNC(Hours_Per_Person)+(Hours_Per_Person-TRUNC(Hours_Per_Person))*.60),2)
   FROM   Av_Fault_Labour_Tab
   WHERE  Fault_Labour_Id = labour_id_;
BEGIN
   
   OPEN get_hours;
   FETCH get_hours INTO hours_;
   CLOSE get_hours;  
   
   IF hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 1))<3 THEN
      converted_value_ := regexp_substr (TO_CHAR(hours_,'00.99'), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(hours_,'00.99'), '[^.]+', 1, 2); 
   ELSIF hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 2))>1 THEN
      converted_value_ := regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 2); 
   ELSIF hours_ IS NOT NULL AND length(regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 2))=1 THEN
      converted_value_ := regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 1)||':'||regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 2)||'0';   
   ELSIF hours_ IS NOT NULL THEN
      converted_value_ := regexp_substr (TO_CHAR(hours_), '[^.]+', 1, 1)||':'||'00';   
   END IF;
   
   RETURN converted_value_;
END Converted_time;
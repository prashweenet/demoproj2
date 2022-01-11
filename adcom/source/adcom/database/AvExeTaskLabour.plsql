-----------------------------------------------------------------------------
--
--  Logical unit: AvExeTaskLabour
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-- 210312   siydlk  LMM2020R1-1588, Added Get_Converted_Time Function.
-- 210307   SatGlk  LMM2020R1-1895, Modified overridden Insert___ to include MX_UNIQUE_KEY when making a new Fault Labour.
-- 210303   sevhlk  LMM2020R1-1644, Added Get_Key_By_Mx_Unique_Key method for data migration
-- 210111   majslk  LMM2020R1-1478, Updated check_insert__.
-- 201008   lahnlk  LMM2020R1-1309, overtake Modify__ ,added Modify
-- 200929   lahnlk  LMM2020R1-1273, overtake Check_Insert___,override Delete___, created Remove
-- 200825   sevhlk  LMM2020R1-836, Added Get_Id_Version_By_Mx_Uniq_Key and Pre_Sync_Action methods.
-- 200803   SatGlk  LMM2020R1-552, Implemented New to be called by AvFaultLabour if a Task is connected to the Fault
-- 200803   rosdlk  LMM2020R1-415, Added a function 'Get_Task_Labour_Id' to get the labour id.
-- 200731   kawjlk  LMM2020R1-551, Overriden Insert___ to impliment logic to sync av_exe_task_labour_tab with av_fault_labour_tab.
-- 200726   kawjlk  LMM2020R1-353, Created,Overriden Check_Insert___ to add next sequence value to task_labour_id, Add Get_Skills_Count function.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Overtake Base
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_exe_task_labour_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   oldrec_ av_exe_task_labour_tab%ROWTYPE;
   fault_labour_id_ NUMBER;
   
   CURSOR get_fault_labour(mx_unique_key_ VARCHAR2) IS
      SELECT fault_labour_id
      FROM   av_fault_labour_tab
      WHERE  mx_unique_key = mx_unique_key_;
      
BEGIN
   OPEN  get_fault_labour(newrec_.mx_unique_key);
   FETCH get_fault_labour INTO fault_labour_id_;
   CLOSE get_fault_labour;
   
   IF((newrec_.task_labour_id < 0) OR (newrec_.task_labour_id IS NULL)) THEN
      IF fault_labour_id_ IS NULL THEN 
         newrec_.task_labour_id := Av_Exe_Task_Labour_API.Get_Next_Seq();
      ELSE
         newrec_.task_labour_id := fault_labour_id_;
      END IF;
      Client_SYS.Add_To_Attr('TASK_LABOUR_ID', newrec_.task_labour_id, attr_);
   END IF;
   --Validate_SYS.Item_Insert(lu_name_, 'TASK_LABOUR_ID', indrec_.task_labour_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT      VARCHAR2,
   objversion_ OUT      VARCHAR2,
   newrec_     IN OUT   av_exe_task_labour_tab%ROWTYPE,
   attr_       IN OUT   VARCHAR2 )
IS
   fault_id_            NUMBER;
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
   IF(fault_id_ IS NOT NULL AND NOT Av_Fault_Labour_API.Exists(newrec_.task_labour_id)) THEN
      Av_Fault_Labour_API.New(newrec_.task_labour_id, fault_id_, newrec_.competency_id, newrec_.num_people_required, newrec_.hours_per_person, newrec_.mx_unique_key);
   END IF;
END Insert___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN av_exe_task_labour_tab%ROWTYPE )
IS
   fault_id_            NUMBER;
BEGIN
   super(objid_, remrec_);
   
   fault_id_ := Av_Exe_Task_API.Get_Fault_Id(remrec_.task_id);
   IF(fault_id_ IS NOT NULL AND Av_Fault_Labour_API.Exists(remrec_.task_labour_id)) THEN
      Av_Fault_Labour_API.Remove(remrec_.task_labour_id);
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
   oldrec_   av_exe_task_labour_tab%ROWTYPE;
   newrec_   av_exe_task_labour_tab%ROWTYPE;
   indrec_   Indicator_Rec;
   fault_id_            NUMBER;
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
      
      fault_id_ := Av_Exe_Task_API.Get_Fault_Id(newrec_.task_id);
      IF(fault_id_ IS NOT NULL AND Av_Fault_Labour_API.Exists(newrec_.task_labour_id)) THEN
         Client_SYS.Add_To_Attr('FAULT_ID',          fault_id_,                 attr_);
         Client_SYS.Add_To_Attr('HOURS_PER_PERSON',  newrec_.hours_per_person,    attr_);
         Client_SYS.Add_To_Attr('NUM_PEOPLE_REQUIRED',  newrec_.num_people_required,    attr_);
         Client_SYS.Add_To_Attr('COMPETENCY_ID',  newrec_.competency_id,    attr_);
         Av_Fault_Labour_API.Modify(newrec_.task_labour_id,attr_); 
      END IF;
   END IF;
   info_ := Client_SYS.Get_All_Info;
END Modify__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Skills_Count(
   task_id_ IN NUMBER) RETURN NUMBER
IS
   output_ NUMBER;
   CURSOR get_skills_count IS
      SELECT   COUNT(*)
      FROM     av_exe_task_labour_tab
      WHERE    task_id = task_id_;
BEGIN
   OPEN  get_skills_count;
   FETCH get_skills_count INTO output_;
   CLOSE get_skills_count;
   RETURN output_;
   
END Get_Skills_Count;

FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT TASK_LABOUR_ID_SEQ.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN ( seq_no_ );
END Get_Next_Seq;

--Creates a new Task Labour record
PROCEDURE New (
   task_labour_id_         IN NUMBER,
   task_id_                IN NUMBER,
   competency_id_          IN VARCHAR2,
   num_people_required_    IN NUMBER,
   hours_per_person_       IN NUMBER,
   assigned_user_          IN VARCHAR2 DEFAULT NULL,
   mx_unique_key_          IN VARCHAR2)
IS
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   newrec_     av_exe_task_labour_tab%ROWTYPE;
   indrec_     Indicator_Rec;
BEGIN
   Prepare_Insert___(attr_);
   
   Client_SYS.Add_To_Attr('TASK_LABOUR_ID', task_labour_id_, attr_);
   Client_SYS.Add_To_Attr('TASK_ID', task_id_, attr_);
   Client_SYS.Add_To_Attr('COMPETENCY_ID', competency_id_, attr_);
   Client_SYS.Add_To_Attr('NUM_PEOPLE_REQUIRED', num_people_required_, attr_);
   Client_SYS.Add_To_Attr('HOURS_PER_PERSON', hours_per_person_, attr_);
   Client_SYS.Add_To_Attr('ASSIGNED_USER', assigned_user_, attr_);
   Client_SYS.Add_To_Attr('MX_UNIQUE_KEY', mx_unique_key_, attr_);

   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);  
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_exe_task_labour_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_             VARCHAR2(4000);
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
         Error_SYS.Appl_General(lu_name_, 'TASKLABOURSYNCERR: Could not find the indicated Task :P1', task_unique_key_);
      END IF;
      
      Client_SYS.Add_To_Attr('TASK_ID', task_id_, local_attr_);
      local_attr_:= Client_SYS.Remove_Attr('TASK_UNIQUE_KEY',  local_attr_);
   END IF;

   attr_ := local_attr_;
END Pre_Sync_Action;

PROCEDURE Remove (
   task_labour_id_         IN NUMBER
   )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   remrec_ av_exe_task_labour_tab%ROWTYPE;
BEGIN
   Get_Id_Version_By_Keys___ (objid_,objversion_,task_labour_id_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Remove;

PROCEDURE Modify(
   task_labour_id_         IN NUMBER,
   attr_       IN OUT  VARCHAR2
   )
IS
      objid_      VARCHAR2(2000);
      objversion_ VARCHAR2(2000);
      oldrec_   av_exe_task_labour_tab%ROWTYPE;
      newrec_   av_exe_task_labour_tab%ROWTYPE;
      indrec_   Indicator_Rec;
BEGIN
         Get_Id_Version_By_Keys___ (objid_,objversion_,task_labour_id_);
         oldrec_ := Lock_By_Id___(objid_, objversion_);
         newrec_ := oldrec_;
         Unpack___(newrec_, indrec_, attr_);
         Check_Update___(oldrec_, newrec_, indrec_, attr_);
         Update___(objid_, oldrec_, newrec_, attr_, objversion_);
   

END Modify;

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_exe_task_labour_tab.task_labour_id%TYPE;
   
   CURSOR get_task_labour_id IS 
      SELECT task_labour_id         
        FROM av_exe_task_labour_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_task_labour_id;
   FETCH get_task_labour_id INTO temp_; 
   CLOSE get_task_labour_id;
   
   RETURN temp_;
END Get_Key_By_Mx_Unique_Key;


FUNCTION Get_Converted_Time (   
   task_labour_id_ IN NUMBER) RETURN VARCHAR2
IS
   hours_           NUMBER;
   converted_value_ VARCHAR2(10); 
   CURSOR get_hours IS   
      SELECT Round((TRUNC(Hours_Per_Person)+(Hours_Per_Person-TRUNC(Hours_Per_Person))*.60),2)
      FROM   av_exe_task_labour_tab
      WHERE  task_labour_id = task_labour_id_;      
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
END Get_Converted_Time;

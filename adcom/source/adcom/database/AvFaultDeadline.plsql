-----------------------------------------------------------------------------
--
--  Logical unit: AvFaultDeadline
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210223  SUPKLK  LMM2020R1-1647, Implemented Get_Key_By_Mx_Unique_Key and modified Check_Insert___ to handle duplicates and Implemented Get_Fault_Id_By_Unique_Key to fetch Fault Id in data migration
--  200918  Tajalk  LMM2020R1-736, Sync logic added
--  200619  KAWJLK  LMM2020R1-18, Implemented the Get_Act_Deadline_Date Function
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_fault_deadline_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
      CURSOR get_key_set IS
      SELECT av_fault_deadline_seq.NEXTVAL
      FROM dual;
BEGIN
   IF newrec_.fault_deadline_id IS NULL THEN
      OPEN  get_key_set;
      FETCH get_key_set INTO newrec_.fault_deadline_id;
      CLOSE get_key_set;
   END IF;
   super(newrec_, indrec_, attr_);
   
   Client_SYS.Add_To_Attr('FAULT_DEADLINE_ID', newrec_.fault_deadline_id, attr_);
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Act_Deadline_Date(
   fault_id_ IN Av_Fault_Deferral_Tab.fault_id%TYPE)RETURN DATE
IS
   
   deadline_date_ av_fault_deadline_tab.deadline_date%TYPE;
   
   CURSOR get_deadline_date IS 
      SELECT t.deadline_date
      FROM av_fault_deadline_tab t
      WHERE t.fault_id = fault_id_ AND t.deadline_driver = '1';
   
BEGIN
   
   OPEN  get_deadline_date;
   FETCH get_deadline_date INTO deadline_date_;
   CLOSE get_deadline_date;
   
   RETURN deadline_date_;
   
END Get_Act_Deadline_Date;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_         OUT  VARCHAR2,
   objversion_    OUT  VARCHAR2,
   mx_unique_key_ IN   VARCHAR2) 
IS      
   CURSOR get_id_version IS 
      SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')         
      FROM   av_fault_deadline_tab
      WHERE  mx_unique_key = mx_unique_key_;

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

FUNCTION Get_Key_By_Mx_Unique_Key (
   mx_unique_key_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ av_fault_deadline_tab.fault_deadline_id%TYPE;
   
   CURSOR get_fault_deadline_id IS 
      SELECT fault_deadline_id         
        FROM av_fault_deadline_tab
       WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN get_fault_deadline_id;
   FETCH get_fault_deadline_id INTO temp_; 
   CLOSE get_fault_deadline_id;
   
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
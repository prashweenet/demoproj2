-----------------------------------------------------------------------------
--
--  Logical unit: AvHistFaultAction
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  210217  tprelk  LMM2020R1-1578, Added Get_Latest_Correct_Fault_Act to get the latest corrective action
--  200915  themlk  DISCOP2020R1-123, New, Modify, Get_Objects_By_Keys, Get_Fault_Action_Id
--  200911  gdeslk  DISO2020R1-218, Added Get_Id_Version_By_Mx_Uniq_Key and Pre_Sync_Action
--                                  to check availabiity of record in AvHistFault
--  200925  waislk  DISO2020R1-297, Added Get methods to fetch data to use in data migration jobs  
-----------------------------------------------------------------------------

layer Core;
 
-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT av_hist_fault_action_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   key_id_ NUMBER;
   
   CURSOR get_key_set IS 
   SELECT av_hist_fault_act_seq.nextval 
   FROM dual;
BEGIN
   
   OPEN get_key_set;
   FETCH get_key_set INTO key_id_;
   CLOSE get_key_set;

   IF(newrec_.fault_action_id IS NULL) THEN
      newrec_.fault_action_id := key_id_;
   END IF;
   Client_SYS.Add_To_Attr('FAULT_ACTION_ID', key_id_, attr_);
   
   
   super(newrec_, indrec_, attr_);
   
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Fault_Action_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   CURSOR get_fault_action_id IS
   SELECT fault_action_id
   FROM av_hist_fault_action_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   fault_action_id_ av_hist_fault_action_tab.fault_action_id%TYPE;
BEGIN
   IF (mx_unique_key_ IS NULL) THEN
      RETURN NULL;
   END IF;
   OPEN get_fault_action_id;
   FETCH get_fault_action_id INTO fault_action_id_;
   CLOSE get_fault_action_id;
   RETURN fault_action_id_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;  
END Get_Fault_Action_Id;

PROCEDURE New (
   newrec_ IN OUT NOCOPY av_hist_fault_action_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Modify (
   newrec_         IN OUT NOCOPY av_hist_fault_action_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Modify___(newrec_, lock_mode_wait_);
END Modify;

FUNCTION Get_Object_By_Keys(
   fault_action_id_ IN NUMBER ) RETURN av_hist_fault_action_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(fault_action_id_);
END Get_Object_By_Keys;

FUNCTION  Mig_Get_Fault_Action_Id(
   mx_unique_key_ IN VARCHAR2) RETURN NUMBER
IS
   
  CURSOR get_fault_action_id IS
   SELECT fault_action_id
   FROM av_hist_fault_action_tab
   WHERE mx_unique_key = mx_unique_key_;
   
   fault_action_id_ NUMBER;
BEGIN
   
   OPEN get_fault_action_id;
   FETCH get_fault_action_id INTO fault_action_id_;
   CLOSE get_fault_action_id;
   
   IF fault_action_id_ IS NULL THEN
      fault_action_id_ := av_hist_fault_act_seq.nextval;
   END IF;
   
   RETURN fault_action_id_;   
   
END Mig_Get_Fault_Action_Id;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')      
      FROM  av_hist_fault_action_tab
      WHERE mx_unique_key = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;


PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   av_hist_fault_unique_key_   av_hist_fault_tab.fault_barcode%TYPE;
   fault_barcode_              av_hist_fault_action_tab.fault_barcode%TYPE;

   CURSOR check_hist_fault_record_availbility IS
      SELECT fault_barcode
      FROM   av_hist_fault_tab
      WHERE  fault_barcode = av_hist_fault_unique_key_;
      
BEGIN
   -- Check whether the historic fault is available in Av_Hist_Fault
   IF Client_SYS.Item_Exist('HIST_FAULT_UNIQUE_KEY', attr_) THEN
      av_hist_fault_unique_key_ := Client_SYS.Get_Item_Value('HIST_FAULT_UNIQUE_KEY', attr_);

      IF av_hist_fault_unique_key_ IS NOT NULL THEN
         OPEN  check_hist_fault_record_availbility;
         FETCH check_hist_fault_record_availbility INTO fault_barcode_;
         CLOSE check_hist_fault_record_availbility;
         
         IF fault_barcode_ IS NULL THEN
            Error_SYS.Appl_General(lu_name_, 'HISTFAULTSYNCERR: Could not find the indicated Historical Fault :P1', av_hist_fault_unique_key_);
         END IF;
         
         Client_SYS.Add_To_Attr('FAULT_BARCODE', fault_barcode_, attr_);
      END IF;
      attr_:= Client_SYS.Remove_Attr('HIST_FAULT_UNIQUE_KEY',  attr_);
   END IF;
   
END Pre_Sync_Action;

@UncheckedAccess
FUNCTION Get_Latest_Correct_Fault_Act (
   fault_barcode_ IN NUMBER) RETURN VARCHAR2
IS
   action_description_    AV_HIST_FAULT_ACTION_TAB.action_description%TYPE;
   CURSOR get_latest_action IS
      SELECT action_description
      FROM   AV_HIST_FAULT_ACTION_TAB t
      WHERE  t.action_date  = ( SELECT MAX(a.action_date)
                                FROM   AV_HIST_FAULT_ACTION_TAB a      
                                WHERE  a.fault_barcode = fault_barcode_)
      AND    t.fault_barcode = fault_barcode_;
BEGIN
   OPEN  get_latest_action;
   FETCH get_latest_action INTO action_description_;
   IF (get_latest_action%NOTFOUND) THEN
      action_description_ := '';
   END IF;
   CLOSE get_latest_action;
   RETURN action_description_;
END Get_Latest_Correct_Fault_Act;
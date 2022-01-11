-----------------------------------------------------------------------------
--
--  Logical unit: AvHistPlanningExecTask
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200915  themlk  DISCOP2020R1-123, New, Remove, Get_Objects_By_Keys, Get_Component_Change_Id
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New(
   newrec_ IN OUT NOCOPY av_hist_planning_exec_task_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New;

PROCEDURE Remove (
   remrec_         IN OUT NOCOPY av_hist_planning_exec_task_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
BEGIN
   Remove___(remrec_, lock_mode_wait_);
END Remove;

FUNCTION Get_Object_By_Keys(
   pt_barcode_ IN VARCHAR2,
   et_barcode_ IN VARCHAR2 ) RETURN av_hist_planning_exec_task_tab%ROWTYPE
IS
BEGIN
   RETURN Get_Object_By_Keys___(pt_barcode_, et_barcode_);
END Get_Object_By_Keys;

PROCEDURE Get_Id_Version_By_Mx_Uniq_Key(
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   mx_unique_key_ IN  VARCHAR2 ) 
IS  
   CURSOR get_key IS
   SELECT rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')     
   FROM av_hist_planning_exec_task_tab
   WHERE pt_barcode||':'||et_barcode = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
END Get_Id_Version_By_Mx_Uniq_Key;

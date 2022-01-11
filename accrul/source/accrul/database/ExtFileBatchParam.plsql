-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileBatchParam
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  090224  Jeguse Bug 80038, Corrected
--  090605  THPELK Bug 82609 - Added UNDEFINE section and the missing statements for VIEW1.
--  100423  SaFalk Modified REF for file_template_id in EXT_FILE_BATCH_PARAM
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Param_Number (
   schedule_id_ IN NUMBER ) RETURN NUMBER
IS
   dummy_     NUMBER;
   CURSOR get_num IS
      SELECT value
      FROM   batch_schedule_par
      WHERE  schedule_id = schedule_id_;
BEGIN
   OPEN  get_num;
   FETCH get_num INTO dummy_;
   CLOSE get_num;
   RETURN dummy_;
END Get_Param_Number;


PROCEDURE New_Batch_Param (
   ext_file_batch_param_ OUT NUMBER,
   parameter_string_     IN  VARCHAR2 )
IS
   CURSOR nextseq IS
      SELECT Ext_File_Batch_Param_Seq.NEXTVAL
      FROM   dual;
   CURSOR oldrec IS
      SELECT a.ext_file_batch_param 
      FROM   ext_file_batch_param_tab a 
      WHERE NOT EXISTS 
        (SELECT 1 
         FROM   Batch_Schedule_pub        bsp, 
                Batch_Schedule_Method_pub bsmp, 
                Batch_Schedule_Par_pub    par 
         WHERE  bsp.schedule_method_id = bsmp.schedule_method_id 
         AND    par.schedule_id        = bsp.schedule_id 
         AND    bsmp.method_name       = 'EXTERNAL_FILE_UTILITY_API.EXECUTE_BATCH_PROCESS2' 
         AND    par.value              = TO_CHAR(a.ext_file_batch_param)); 
   dummy1_     VARCHAR2(30);
   dummy2_     VARCHAR2(30);
   user_       VARCHAR2(30);
   dummyn_     NUMBER;
BEGIN
   --Remove old parameters that don't have a batchjob
   OPEN oldrec;
   LOOP
      FETCH oldrec INTO dummyn_;
      EXIT WHEN oldrec%NOTFOUND;
      DELETE
      FROM   EXT_FILE_BATCH_PARAM_TAB
      WHERE  ext_file_batch_param = dummyn_; 
   END LOOP;
   CLOSE oldrec;
   OPEN  nextseq;
   FETCH nextseq INTO ext_file_batch_param_;
   CLOSE nextseq;
   Message_SYS.Get_Attribute(parameter_string_, 'FILE_TYPE', dummy1_);
   Message_SYS.Get_Attribute(parameter_string_, 'FILE_TEMPLATE_ID', dummy2_);
   user_ := Fnd_Session_API.Get_Fnd_User;
   INSERT
      INTO ext_file_batch_param_tab (
         ext_file_batch_param,
         user_id,
         param_string,
         last_used,
         file_type,
         file_template_id,
         rowversion)
      VALUES (
         ext_file_batch_param_,
         user_,
         parameter_string_,
         SYSDATE,
         dummy1_,
         dummy2_,
         SYSDATE);
END New_Batch_Param;


PROCEDURE Update_Batch_Param (
   ext_file_batch_param_ IN NUMBER )
IS
BEGIN
   UPDATE EXT_FILE_BATCH_PARAM_TAB
      SET last_used = SYSDATE
   WHERE  ext_file_batch_param = ext_file_batch_param_;
END Update_Batch_Param;


PROCEDURE Remove_Param (
   ext_file_batch_param_ IN NUMBER )
IS
BEGIN
   DELETE 
   FROM   EXT_FILE_BATCH_PARAM_TAB
   WHERE  ext_file_batch_param = ext_file_batch_param_;
END Remove_Param;


PROCEDURE Update_Param_String (
   ext_file_batch_param_ IN VARCHAR2,
   parameter_string_     IN VARCHAR2)
IS
BEGIN
   UPDATE EXT_FILE_BATCH_PARAM_TAB
      SET param_string = parameter_string_
   WHERE  ext_file_batch_param = ext_file_batch_param_;
END Update_Param_String;


@UncheckedAccess
PROCEDURE Get_Batch_Param_Seq_Number (
   ext_file_batch_param_ OUT NUMBER,
   schedule_id_          IN  NUMBER )
IS
   CURSOR get_num IS
      SELECT value
      FROM   batch_schedule_par
      WHERE  schedule_id = schedule_id_;
BEGIN
   OPEN  get_num;
   FETCH get_num INTO ext_file_batch_param_;
   CLOSE get_num;
END Get_Batch_Param_Seq_Number;




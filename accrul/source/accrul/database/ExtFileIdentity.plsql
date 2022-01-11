-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileIdentity
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021011  PPerse Create
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Check_Exist_Control_Identity (
   identity_ IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN(Check_Exist___ (identity_));
END Check_Exist_Control_Identity;


PROCEDURE Insert_Identity (
   newrec_     IN OUT Ext_File_Identity_Tab%ROWTYPE )
IS
   ext_file_load_rec_    Ext_File_Load_API.Public_Rec;
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Identity_Tab
      WHERE  identity     = newrec_.identity
      AND    load_file_id = newrec_.load_file_id;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      ext_file_load_rec_ := Ext_File_Load_API.Get ( newrec_.load_file_id );
      newrec_.rowversion := sysdate;
      INSERT
         INTO ext_file_identity_tab (
            identity,
            load_file_id,
            load_date,
            file_name,
            user_id,
            parameter_string,
            file_template_id,
            file_type,
            rowversion)
         VALUES (
            newrec_.identity,
            newrec_.load_file_id,
            NVL(newrec_.load_date,ext_file_load_rec_.load_date),
            NVL(newrec_.file_name,ext_file_load_rec_.file_name),
            NVL(newrec_.user_id,ext_file_load_rec_.user_id),
            NVL(newrec_.parameter_string,ext_file_load_rec_.parameter_string),
            ext_file_load_rec_.file_template_id,
            ext_file_load_rec_.file_type,
            newrec_.rowversion);
   END IF;
   CLOSE exist_control;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert_Identity;



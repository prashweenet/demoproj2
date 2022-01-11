-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileLog
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT EXT_FILE_LOG_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Ext_File_Trans_API.Get_Count_Row_State ( newrec_.load_file_id,
                                            newrec_.seq_no );
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Delete_File_Log (
   load_file_id_         IN     NUMBER )
IS
BEGIN
   DELETE
   FROM   Ext_File_Log_Tab
   WHERE  load_file_id = load_file_id_;
   Ext_File_Log_Detail_API.Delete_File_Log ( load_file_id_ );
END Delete_File_Log;


@UncheckedAccess
FUNCTION Get_Next_Seq_No (
   load_file_id_ IN NUMBER ) RETURN NUMBER
IS
   temp_ EXT_FILE_LOG_TAB.seq_no%TYPE;
   CURSOR get_attr IS
      SELECT NVL(MAX(seq_no),0) + 1
      FROM EXT_FILE_LOG_TAB
      WHERE load_file_id = load_file_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Next_Seq_No;





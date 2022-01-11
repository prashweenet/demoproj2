-----------------------------------------------------------------------------
--
--  Logical unit: AuditSourceColumn
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date      Sign    History
--  ------    ------  ---------------------------------------------------------
--  11-03-14  PRatlk  PBFI-5898, Changes in Basic Data Insertion methods.
--  16-12-02  Nudilk  Merged Bug 125759.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Lu_Data_Rec (
   insrec_        IN AUDIT_SOURCE_COLUMN_TAB%ROWTYPE)
IS
   dummy_      VARCHAR2(1);
   newrec_     audit_source_column_tab%ROWTYPE;

   CURSOR Exist IS
      SELECT 'X'
      FROM AUDIT_SOURCE_COLUMN_TAB
      WHERE audit_source  = insrec_.audit_source
      AND   source_column = insrec_.source_column;
BEGIN
   newrec_        := insrec_;
   newrec_.rowkey := NVL(newrec_.rowkey, sys_guid());
   
   OPEN Exist;
   FETCH Exist INTO dummy_;
   IF (Exist%NOTFOUND) THEN
      INSERT
      INTO audit_source_column_tab
      VALUES newrec_;
   ELSE      
      UPDATE audit_source_column_tab
      SET selection_date_title = newrec_.selection_date_title
      WHERE audit_source       = newrec_.audit_source
      AND   source_column      = newrec_.source_column;
   END IF;
   CLOSE Exist;
   
   -- Remark: Only update the attribute that is supposed to be translated, in this case description
   -- Always use the key of the LU in the Where statement.
   Basic_Data_Translation_API.Insert_Prog_Translation(module_, lu_name_, newrec_.audit_source || '^' || newrec_.source_column || '^DESCRIPTION', newrec_.selection_date_title);
   
END Insert_Lu_Data_Rec;


@UncheckedAccess
FUNCTION Get_Selection_Date_Title (
   audit_source_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ AUDIT_SOURCE_COLUMN_TAB.selection_date_title%TYPE;
   CURSOR get_attr IS
      SELECT selection_date_title
      FROM   AUDIT_SOURCE_COLUMN
      WHERE  audit_source = audit_source_
        AND  selection_date_db = 'TRUE';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Selection_Date_Title;









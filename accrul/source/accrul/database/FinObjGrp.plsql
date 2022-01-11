-----------------------------------------------------------------------------
--
--  Logical unit: FinObjGrp
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

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   insrec_        IN FIN_OBJ_GRP_TAB%ROWTYPE)
IS
   dummy_      VARCHAR2(1);
   CURSOR Exist IS
      SELECT 'X'
      FROM FIN_OBJ_GRP_TAB
      WHERE object_group_id = insrec_.object_group_id;
BEGIN
   OPEN Exist;
      FETCH Exist INTO dummy_;
      IF (Exist%NOTFOUND) THEN
         INSERT
         INTO FIN_OBJ_GRP_TAB
         VALUES insrec_;
         Basic_Data_Translation_API.Insert_Prog_Translation(insrec_.module, insrec_.lu, insrec_.object_group_id, insrec_.description);
      ELSE
         Basic_Data_Translation_API.Insert_Prog_Translation(insrec_.module, insrec_.lu, insrec_.object_group_id, insrec_.description);
   -- Remark: Only update the attribute that is supposed to be translated, in this case description
   -- Always use the key of the LU in the Where statement.
         UPDATE FIN_OBJ_GRP_TAB
            SET description = insrec_.description,
                module = insrec_.module,
                lu = insrec_.lu
            WHERE object_group_id = insrec_.object_group_id;
      END IF;
      CLOSE Exist;
END Insert_Lu_Data_Rec__;
   

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


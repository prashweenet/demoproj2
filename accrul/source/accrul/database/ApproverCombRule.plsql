-----------------------------------------------------------------------------
--
--  Logical unit: ApproverCombRule
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
PROCEDURE Raise_Record_Not_Exist___ (
   company_             IN VARCHAR2,
   combination_rule_id_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_General(lu_name_,'APPROVERCOMBRULEEXISTS: The Approver Combination Rule does not exist.');
   super(company_, combination_rule_id_);
END Raise_Record_Not_Exist___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


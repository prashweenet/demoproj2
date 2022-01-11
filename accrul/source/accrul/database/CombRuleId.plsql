-----------------------------------------------------------------------------
--
--  Logical unit: CombRuleId
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  081106  Nirplk Created to correct Bug 77483
--  131030  Umdolk PBFI-1910, Refactoring
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Next_Rule_Id (
   next_id_ OUT NUMBER,
   company_ IN VARCHAR2 )
IS
   next_rule_id_  NUMBER; 
   CURSOR  next_value IS
      SELECT  comb_rule_id
      FROM    COMB_RULE_ID_TAB
      WHERE   company = company_
      FOR UPDATE;

BEGIN
   OPEN  next_value;
   FETCH next_value INTO next_rule_id_;

   IF (next_value%NOTFOUND) THEN
      next_rule_id_ := 1;

      INSERT INTO COMB_RULE_ID_TAB (company,comb_rule_id, rowversion) 
      VALUES (company_, next_rule_id_, SYSDATE);

   ELSE
      next_rule_id_ := next_rule_id_ + 1; 

      UPDATE   COMB_RULE_ID_TAB
      SET      comb_rule_id = next_rule_id_,
               rowversion   = SYSDATE
      WHERE    company      = company_ ;
     
   END IF;
   CLOSE    next_value;
   next_id_ := next_rule_id_;

END Get_Next_Rule_Id;



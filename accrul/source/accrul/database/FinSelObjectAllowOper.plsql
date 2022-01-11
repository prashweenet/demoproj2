-----------------------------------------------------------------------------
--
--  Logical unit: FinSelObjectAllowOper
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
   insrec_        IN FIN_SEL_OBJECT_ALLOW_OPER_TAB%ROWTYPE)
IS
   newrec_     FIN_SEL_OBJECT_ALLOW_OPER_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN
   newrec_ := insrec_;
   IF (NOT Check_Exist___(newrec_.selection_object_id, newrec_.selection_operator)) THEN
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);

      INSERT
         INTO fin_sel_object_allow_oper_tab (
            selection_object_id,
            selection_operator,
            rowversion)
         VALUES (
            newrec_.selection_object_id,
            newrec_.selection_operator,
            newrec_.rowversion);
   ELSE
      UPDATE fin_sel_object_allow_oper_tab
         SET selection_object_id = newrec_.selection_object_id,
             selection_operator = newrec_.selection_operator,
             rowversion = newrec_.rowversion
         WHERE selection_object_id = newrec_.selection_object_id
         AND    selection_operator = newrec_.selection_operator;
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


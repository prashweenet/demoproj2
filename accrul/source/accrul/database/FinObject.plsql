-----------------------------------------------------------------------------
--
--  Logical unit: FinObject
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
   insrec_        IN FIN_OBJECT_TAB%ROWTYPE)
IS
   oldrec_     FIN_OBJECT_TAB%ROWTYPE;
   newrec_     FIN_OBJECT_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      VARCHAR2(200);
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN
   newrec_ := insrec_;
   IF (NOT Check_Exist___(newrec_.object_id)) THEN
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(newrec_.object_id);
      newrec_ := oldrec_;      
      attr_ := Pack___(insrec_);            
      Unpack___(newrec_, indrec_, attr_);      
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);    
      Check_Update___(oldrec_, newrec_, indrec_, attr_);         
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


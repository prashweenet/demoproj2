-----------------------------------------------------------------------------
--
--  Logical unit: FooterConnectionMaster
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

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Insert_Lu_Data_Rec
--   Interface to add reports that are ready to be used with the
--   Document Footer concept
PROCEDURE Insert_Lu_Data_Rec (
   insrec_        IN FOOTER_CONNECTION_MASTER_TAB%ROWTYPE)
IS
   oldrec_     FOOTER_CONNECTION_MASTER_TAB%ROWTYPE;
   newrec_     FOOTER_CONNECTION_MASTER_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      VARCHAR2(30);
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   IF (NOT Check_Exist___(insrec_.report_id)) THEN
      newrec_ := insrec_;
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(insrec_.report_id);
      newrec_ := oldrec_;
      attr_ := Pack___(insrec_);
      Unpack___(newrec_, indrec_, attr_);
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Insert_Lu_Data_Rec;



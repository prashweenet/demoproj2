-----------------------------------------------------------------------------
--
--  Logical unit: SystemFooterField
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131104  PRatlk  PBFI-2098, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     system_footer_field_tab%ROWTYPE,
   newrec_ IN OUT system_footer_field_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
   Assert_SYS.Assert_Is_Package_Method(newrec_.package_method);
END Check_Common___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Insert_Lu_Data_Rec
--   Interface to add system defined footer field used by the
--   Document Footer concept
PROCEDURE Insert_Lu_Data_Rec (
   insrec_        IN SYSTEM_FOOTER_FIELD_TAB%ROWTYPE)
IS
   oldrec_     SYSTEM_FOOTER_FIELD_TAB%ROWTYPE;
   newrec_     SYSTEM_FOOTER_FIELD_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      VARCHAR2(30);
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   IF (NOT Check_Exist___(insrec_.footer_field_id)) THEN
      newrec_ := insrec_;
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(insrec_.footer_field_id);
      newrec_ := oldrec_;
      attr_ := Pack___(insrec_);
      Unpack___(newrec_, indrec_, attr_);
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Insert_Lu_Data_Rec;



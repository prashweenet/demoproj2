-----------------------------------------------------------------------------
--
--  Logical unit: AuditSource
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  121030  SALIDE  EDEL-1944, Added internal_ledger
--  131023  PRatlk  CAHOOK-2823, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     audit_source_tab%ROWTYPE,
   newrec_ IN OUT audit_source_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.internal_ledger IS NULL) THEN
      newrec_.internal_ledger := Fnd_Boolean_API.DB_FALSE;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Lu_Data_Rec (
   insrec_        IN AUDIT_SOURCE_TAB%ROWTYPE)
IS
   oldrec_     AUDIT_SOURCE_TAB%ROWTYPE;
   newrec_     AUDIT_SOURCE_TAB%ROWTYPE;
   attr_       VARCHAR2(32000);
   objid_      VARCHAR2(30);
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   IF (NOT Check_Exist___(insrec_.audit_source)) THEN
      newrec_ := insrec_;
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);

      Basic_Data_Translation_API.Insert_Prog_Translation(module_,
                                                         lu_name_,
                                                         newrec_.audit_source,
                                                         newrec_.description);
   ELSE
      oldrec_ := Lock_By_Keys___(insrec_.audit_source);
      newrec_ := oldrec_;
      attr_ := Pack___(insrec_);
      Unpack___(newrec_, indrec_, attr_);

      IF (newrec_.internal_ledger IS NULL) THEN
         newrec_.internal_ledger := Fnd_Boolean_API.DB_FALSE;
      END IF;

      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);

      Basic_Data_Translation_API.Insert_Prog_Translation(module_,
                                                         lu_name_,
                                                         newrec_.audit_source,
                                                         newrec_.description);
   END IF;
END Insert_Lu_Data_Rec;



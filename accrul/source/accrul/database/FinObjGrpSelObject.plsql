-----------------------------------------------------------------------------
--
--  Logical unit: FinObjGrpSelObject
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

PROCEDURE Validate_Report_Column___(
   newrec_  IN FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE)
IS
   CURSOR get_reports IS
      SELECT object_id
      FROM   Fin_Obj_Grp_Object F
      WHERE  object_group_id = newrec_.object_group_id;
BEGIN
   IF (newrec_.report_column IS NOT NULL) THEN
      FOR rec_ IN get_reports LOOP
         IF (Fin_Object_API.Get_Object_Type_Db(rec_.object_id) = 'REPORT') THEN
            Assert_SYS.Assert_Is_View_Column(rec_.object_id, newrec_.report_column);
         END IF;
      END LOOP;
   END IF;
END Validate_Report_Column___;


PROCEDURE Validate_Update_Rec___(
   oldrec_              IN FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE,
   newrec_              IN FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE)
IS
BEGIN 
   IF (NVL(oldrec_.report_column, '#$#$#$') != NVL(newrec_.report_column, '#$#$#$')) THEN
      Validate_Report_Column___(newrec_);
   END IF;
END Validate_Update_Rec___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT fin_obj_grp_sel_object_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   Validate_Report_Column___(newrec_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     fin_obj_grp_sel_object_tab%ROWTYPE,
   newrec_ IN OUT fin_obj_grp_sel_object_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   -- Performing the validations inside the Validate_Update_Rec___ method.
   Validate_Update_Rec___(oldrec_, newrec_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   insrec_        IN FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE)
IS
   oldrec_     FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE;
   newrec_     FIN_OBJ_GRP_SEL_OBJECT_TAB%ROWTYPE;
   attr_       VARCHAR2(100);
   objid_      VARCHAR2(30);
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   newrec_ := insrec_;
   IF (NOT Check_Exist___(newrec_.object_group_id, newrec_.selection_object_id)) THEN
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(newrec_.object_group_id, newrec_.selection_object_id);      
      attr_ := Pack___(insrec_);      
      newrec_ := oldrec_;      
      Unpack___(newrec_, indrec_, attr_);
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTemplateControl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  040329  Gepelk  2004 SP1 Merge.
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  131030  PRatlk  PBFI-1862, Refactored code according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'CONDITION',       Ext_Condition_API.Decode('2'),       attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_FILE_TEMPLATE_CONTROL_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Template_API.Get_System_Defined (remrec_.file_template_id) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file id !');
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_template_control_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_control_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (Ext_File_Template_API.Get_System_Defined (newrec_.file_template_id) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file id !');
   END IF;
   IF (newrec_.file_direction = '2' AND
       newrec_.destination_column IS NULL) THEN
      Error_SYS.Record_General(lu_name_, 'DESTNOTNULL: Destination Column have to be specified for output controls !');
   END IF;
   IF (newrec_.file_direction = '1' AND
       newrec_.column_no IS NULL AND
       newrec_.start_position IS NULL) THEN
      Error_SYS.Record_General(lu_name_, 'COLPOSNOTNULL: Column No or Position have to be specified for input controls !');
   END IF;
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Copy_File_Control (
   file_template_id_      IN  VARCHAR2,
   from_file_template_id_ IN  VARCHAR2 )
IS
   newrec_                    Ext_File_Template_Control_Tab%ROWTYPE;
   CURSOR detail_ IS
      SELECT *
      FROM   Ext_File_Template_Control_Tab D
      WHERE  D.file_template_id = from_file_template_id_;
BEGIN
   FOR rec_ IN detail_ LOOP
      newrec_                  := rec_;
      newrec_.file_template_id := file_template_id_;
      newrec_.rowversion       := SYSDATE;
      Insert_Record ( newrec_ );
   END LOOP;
END Copy_File_Control;


FUNCTION Check_Any_Control (
   file_template_id_ IN VARCHAR2,
   file_direction_   IN VARCHAR2,
   record_type_id_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Control_Tab
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_
      AND    record_type_id   = record_type_id_ ;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Any_Control;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Template_Control_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Template_Control_Tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   newrecx_.rowkey := NULL;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END Insert_Record;


PROCEDURE Remove_Template (
   file_template_id_  IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM EXT_FILE_TEMPLATE_CONTROL_TAB
   WHERE file_template_id = file_template_id_;
END Remove_Template;



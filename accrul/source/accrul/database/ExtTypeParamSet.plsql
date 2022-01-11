-----------------------------------------------------------------------------
--
--  Logical unit: ExtTypeParamSet
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020920  PPer  Created
--  061123  Samwlk LCS Merge 60740.
--  080108  Jeguse Bug 69856, Added method Exist_Cntrl
--  091216  HimRlk Reverse engineering correction, Removed procedure Remove_File_Type.
--  091216         Added REF to ExtFileType in view comments of column file_type.
--  131101  PRatlk PBFI-1957, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   file_type_      VARCHAR2(20);
   set_id_default_ VARCHAR2(5);
BEGIN
   file_type_ := Client_SYS.Get_Item_Value ( 'FILE_TYPE',attr_ );
   Check_Default__ ( file_type_,
                     NULL,
                     set_id_default_,
                     'PREPARE' );
   super(attr_);
   Client_SYS.Add_To_Attr( 'SET_ID_DEFAULT', set_id_default_, attr_);
   Client_SYS.Add_To_Attr( 'SYSTEM_DEFINED', 'FALSE',         attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT EXT_TYPE_PARAM_SET_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   Check_Default__ ( newrec_.file_type,
                     newrec_.set_id,
                     newrec_.set_id_default,
                     'INSERT' );
   IF newrec_.system_defined IS NULL THEN
      newrec_.system_defined := 'FALSE';
   END IF;
   super(objid_, objversion_, newrec_, attr_);
   
   IF (newrec_.set_id_default = 'TRUE') THEN
      Update_Default_Set_Id ( newrec_.file_type,
                              newrec_.set_id );
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     EXT_TYPE_PARAM_SET_TAB%ROWTYPE,
   newrec_     IN OUT EXT_TYPE_PARAM_SET_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   Check_Default__ ( newrec_.file_type,
                     newrec_.set_id,
                     newrec_.set_id_default,
                     'UPDATE' );
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   IF (newrec_.set_id_default = 'TRUE') THEN
      Update_Default_Set_Id ( newrec_.file_type,
                              newrec_.set_id );
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_TYPE_PARAM_SET_TAB%ROWTYPE )
IS
   set_id_default_ VARCHAR2(5);
BEGIN
   set_id_default_ := remrec_.set_id_default;
   Check_Default__ ( remrec_.file_type,
                     remrec_.set_id,
                     set_id_default_,
                     'DELETE' );
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_TYPE_PARAM_SET_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Ext_Type_Param_Per_Set_API.Remove_Param_Set ( remrec_.file_type,
                                                 remrec_.set_id );
END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_type_param_set_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF newrec_.system_defined IS NULL THEN
      newrec_.system_defined := 'FALSE';
   END IF;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Default__ (
   file_type_      IN     VARCHAR2,
   set_id_         IN     VARCHAR2,
   set_id_default_ IN OUT VARCHAR2,
   operation_      IN     VARCHAR2 )
IS
   dummy_             NUMBER;
   def_set_id_old_ VARCHAR2(20);
   set_id_defaultx_         VARCHAR2(5);
   CURSOR exist_control IS
     SELECT 1
     FROM   Ext_Type_Param_Set_Tab
     WHERE  file_type = file_type_;
BEGIN
   set_id_defaultx_ := set_id_default_;
   IF (operation_ = 'PREPARE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%FOUND) THEN
         set_id_default_ := 'FALSE';
      ELSE
         set_id_default_ := 'TRUE';
      END IF;
      CLOSE exist_control;
   ELSIF (operation_ = 'DELETE' AND set_id_defaultx_ = 'TRUE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%FOUND) THEN
         FETCH exist_control INTO dummy_;
         IF (exist_control%FOUND) THEN
            CLOSE exist_control;
            Error_SYS.Appl_General( lu_name_, 'REMDEFERR: It is not allowed to remove a default set id');
         END IF;
      END IF;
      CLOSE exist_control;
   ELSIF (operation_ = 'INSERT' AND set_id_defaultx_ = 'FALSE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%NOTFOUND) THEN
         set_id_default_ := 'TRUE'; -- Always set the first set_id to default = TRUE
      END IF;
      CLOSE exist_control;
   ELSE
      IF (set_id_defaultx_ = 'FALSE') THEN
         def_set_id_old_ := Get_Default_Set_Id ( file_type_ );
         IF (def_set_id_old_ IS NULL) THEN
            set_id_defaultx_ := 'TRUE';
         END IF;
         IF (def_set_id_old_ = set_id_) THEN
            set_id_default_ := 'TRUE';
         END IF;
      END IF;
      IF (set_id_defaultx_ = 'TRUE') THEN
         UPDATE Ext_Type_Param_Set_Tab
           SET    set_id_default = DECODE(set_id,set_id_,'TRUE','FALSE')
         WHERE  file_type = file_type_;
      END IF;
   END IF;
END Check_Default__;


PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_        IN EXT_TYPE_PARAM_SET_TAB%ROWTYPE)
IS
   rec_              EXT_TYPE_PARAM_SET_TAB%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.file_type, rec_.set_id)) THEN
      INSERT
         INTO ext_type_param_set_tab (
            file_type,
            set_id,
            description,
            set_id_default,
            system_defined,
            rowversion)
         VALUES (
            newrec_.file_type,
            newrec_.set_id,
            newrec_.description,
            newrec_.set_id_default,
            'TRUE',
            newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.set_id,
                                                          rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.set_id,
                                                          rec_.description);
      UPDATE EXT_TYPE_PARAM_SET_TAB
         SET description = rec_.description
      WHERE  file_type = rec_.file_type
      AND    set_id    = rec_.set_id;
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Check_Any_Exist (
   file_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_TYPE_PARAM_SET_TAB
      WHERE file_type = file_type_ ;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Any_Exist;


@UncheckedAccess
FUNCTION Get_Default_Set_Id (
   file_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_TYPE_PARAM_SET_TAB.set_id%TYPE;
   CURSOR get_attr IS
      SELECT set_id
      FROM   EXT_TYPE_PARAM_SET_TAB
      WHERE  file_type = file_type_
      AND    set_id_default = 'TRUE';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Default_Set_Id;




PROCEDURE Insert_Record (
   newrec_     IN EXT_TYPE_PARAM_SET_TAB%ROWTYPE )
IS
   newrecx_       EXT_TYPE_PARAM_SET_TAB%ROWTYPE;
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


PROCEDURE Update_Default_Set_Id (
   file_type_ IN VARCHAR2,
   set_id_    IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TYPE_PARAM_SET_TAB
      SET set_id_default = 'FALSE'
   WHERE file_type = file_type_
   AND   set_id    != set_id_;
END Update_Default_Set_Id;


PROCEDURE Exist_Cntrl (
   file_type_ IN VARCHAR2,
   set_id_    IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(file_type_, set_id_)) THEN
      Error_SYS.Appl_General( lu_name_, 'PARSETNOTEXIST: Parameter Set Id does not exist');
   END IF;
END Exist_Cntrl;


@UncheckedAccess
FUNCTION Check_Exist (
   file_type_ IN VARCHAR2,
   set_id_    IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (NOT Check_Exist___(file_type_, set_id_)) THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
END Check_Exist;





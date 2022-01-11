-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTypeRec
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse   Created
--  090717  ErFelk   Bug 83174, Replaced constant DUPFIRSTLAST with CHKFIRSTLAST in Check_First_Last_Set.
--  100427  SaFalk   Changed key order in EXT_FILE_TYPE_REC.
--  100807  Mawelk  Bug 92305 Fixed. Changes to  Insert___()
--  131030  PRatlk   PBFI-1913, Refactored code according to the new template
--  200630  CKumlk   Bug 154570, Added a warning when there are differences between view and the base view.
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
   Client_SYS.Add_To_Attr( 'FIRST_IN_RECORD_SET', 'TRUE', attr_);
   Client_SYS.Add_To_Attr( 'LAST_IN_RECORD_SET', 'TRUE', attr_);
   Client_SYS.Add_To_Attr( 'MANDATORY_RECORD', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_FILE_TYPE_REC_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Type_API.Get_System_Defined (remrec_.file_type) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file type !');
   END IF;
   super(objid_, remrec_);
END Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_type_rec_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_rec_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   base_view_        VARCHAR2(30);
   view_diff_exist_  VARCHAR2(5):= 'FALSE';
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.parent_record_type IS NOT NULL) THEN
      Parent_Exist(newrec_.file_type,
                   newrec_.parent_record_type);
   END IF;   
   IF (Ext_File_Type_API.Get_System_Defined(newrec_.file_type) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file type !');
   END IF;
   Check_First_Last_Set(newrec_.file_type,
                        newrec_.record_type_id,
                        newrec_.record_set_id,
                        newrec_.first_in_record_set,
                        newrec_.last_in_record_set );
   IF (newrec_.view_name IS NOT NULL) THEN
      Finance_Lib_API.Is_View_Available(newrec_.view_name);
   END IF;
   IF (newrec_.input_package IS NOT NULL) THEN
      Finance_Lib_API.Is_Package_Available(newrec_.input_package);
   END IF;   
   IF (newrec_.view_name IS NOT NULL) THEN
      External_File_Utility_API.Check_View_Col_Diff(view_diff_exist_, base_view_, newrec_.view_name);
      IF (view_diff_exist_ = 'TRUE') THEN
         Client_SYS.Add_Warning(lu_name_, 'WARNVIEWDIFF: The view :P1 does not match with the base view of entity :P2. It could lead to errors when loading external files.', newrec_.view_name, base_view_);
      END IF;
   END IF;
END Check_Common___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_   IN ext_file_type_rec_tab%ROWTYPE)
IS
   rec_   ext_file_type_rec_tab%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.file_type, rec_.record_type_id)) THEN
      INSERT INTO ext_file_type_rec_tab (
         file_type,
         record_type_id,
         record_set_id,
         first_in_record_set,
         last_in_record_set,
         mandatory_record,
         description,
         parent_record_type,
         view_name,
         input_package,          
         rowversion)
      VALUES (
         newrec_.file_type,
         newrec_.record_type_id,
         newrec_.record_set_id,
         newrec_.first_in_record_set,
         newrec_.last_in_record_set,
         newrec_.mandatory_record,
         newrec_.description,
         newrec_.parent_record_type,
         newrec_.view_name,
         newrec_.input_package,          
         newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.record_type_id,
                                                          rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.record_type_id,
                                                          rec_.description);
      UPDATE ext_file_type_rec_tab
         SET description = rec_.description
      WHERE  file_type      = rec_.file_type
      AND    record_type_id = rec_.record_type_id;         
   END IF;
END Insert_Lu_Data_Rec__;   


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Group_Exist (
   file_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ext_file_type_rec_tab
      WHERE file_type = file_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Group_Exist;

@UncheckedAccess
FUNCTION Check_If_Parent (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ext_file_type_rec_tab
      WHERE  file_type          = file_type_
      AND    parent_record_type = record_type_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_If_Parent;

FUNCTION Get_Parent_Record_Types (
   file_type_          IN VARCHAR2,
   parent_record_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   parent_record_types_ VARCHAR2(100);
   parent_record_typex_ VARCHAR2(100);
   temp_                ext_file_type_rec_tab.parent_record_type%TYPE;
   x_record_type_id_    VARCHAR2(20);
   CURSOR get_attr IS
      SELECT parent_record_type
      FROM   ext_file_type_rec_tab
      WHERE  file_type      = file_type_
      AND    record_type_id = x_record_type_id_;
BEGIN
   IF (NVL(parent_record_type_,' ') = ' ') THEN
      parent_record_types_ := ' ';
      RETURN parent_record_types_;
   END IF;
   parent_record_types_ := parent_record_type_;
   x_record_type_id_ := parent_record_type_;
   LOOP
      OPEN get_attr;
      FETCH get_attr INTO temp_;
      IF (get_attr%NOTFOUND) THEN
         CLOSE get_attr;
         EXIT;
      END IF;
      CLOSE get_attr;
      IF (NVL(temp_,' ') = ' ') THEN
         EXIT;
      END IF;
      parent_record_typex_ := parent_record_types_;
      parent_record_types_ := temp_ || ';' || parent_record_typex_;
      x_record_type_id_ := temp_;
   END LOOP;
   RETURN parent_record_types_;
END Get_Parent_Record_Types;


PROCEDURE Update_View_Name (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2,
   view_name_      IN VARCHAR2,
   input_package_  IN VARCHAR2 )
IS
BEGIN
   UPDATE ext_file_type_rec_tab
   SET    view_name      = view_name_,
          input_package  = input_package_
   WHERE  file_type      = file_type_
   AND    record_type_id = record_type_id_;
END Update_View_Name;


PROCEDURE Remove_File_Type (
   file_type_  IN VARCHAR2 ) 
IS
BEGIN
   DELETE
   FROM ext_file_type_rec_tab
   WHERE file_type = file_type_;
END Remove_File_Type;


PROCEDURE Parent_Exist (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(file_type_, record_type_id_)) THEN
      Error_SYS.Record_General('ExtFileTypeRec', 'PRECTNOTEXIST: Parent Record Type does not exist');
   END IF;
END Parent_Exist;


PROCEDURE Insert_Record (
   newrec_     IN ext_file_type_rec_tab%ROWTYPE )
IS
   newrecx_       ext_file_type_rec_tab%ROWTYPE;
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


PROCEDURE Check_First_Last_Set (
   file_type_           IN VARCHAR2,
   record_type_id_      IN VARCHAR2,
   record_set_id_       IN VARCHAR2,
   first_in_record_set_ IN VARCHAR2,
   last_in_record_set_  IN VARCHAR2 ) 
IS
   CURSOR get_attr IS
      SELECT *
      FROM   ext_file_type_rec_tab
      WHERE  file_type      = file_type_
      AND    record_set_id  = record_set_id_
      AND    record_type_id != record_type_id_;
BEGIN
   FOR rec_ IN get_attr LOOP
      IF (rec_.first_in_record_set = 'TRUE' AND rec_.last_in_record_set = 'TRUE') THEN
         Error_SYS.Record_General('ExtFileTypeRec', 'DUPFIRSTLAST: Other record type is already defined as First and Last for this record set');
      END IF;
      IF (first_in_record_set_ = 'TRUE' AND last_in_record_set_ = 'TRUE') THEN
         Error_SYS.Record_General('ExtFileTypeRec', 'CHKFIRSTLAST: First and Last can not be set because other record type exist for this record set');
      END IF;
      IF (NVL(first_in_record_set_,'FALSE') = 'TRUE' OR
          NVL(last_in_record_set_,'FALSE') = 'TRUE') THEN
         IF (first_in_record_set_ = 'TRUE') THEN
            IF (first_in_record_set_ = rec_.first_in_record_set) THEN
               Error_SYS.Record_General('ExtFileTypeRec', 'DUPFIRSTSET: First in record set already defined for this record set');
            END IF;
         ELSIF (last_in_record_set_ = 'TRUE') THEN
            IF (last_in_record_set_ = rec_.last_in_record_set) THEN
               Error_SYS.Record_General('ExtFileTypeRec', 'DUPLASTSET: Last in record set already defined for this record set');
            END IF;
         END IF;
      END IF;
   END LOOP;
END Check_First_Last_Set;



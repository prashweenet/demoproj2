-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTemplate
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  040329  Gepelk  2004 SP1 Merge.
--  040804  Jeguse  IID FIJP335. Added column date_nls_calendar and functions for this column.
--  040910  Jeguse  IID FIJP335. Added view ext_file_template_lov_cupay
--  060106  Sacalk  LCS Merge 54724, Modified FUNCTION Get_Backup_File_Name. 
--  090122  Jeguse  Bug 79498, Increased length of variables
--  090605  THPELK  Bug 82609 - Added UNDEFINE statements for VIEW6.
--  090717  ErFelk  Bug 83174, Replaced constant EXUSEDTEMP with EXUSEDTEMPFL and EXUSEDTEMP 
--  090717          with EXUSEDTEMPCD in Check_Delete___.
--  100801  Mawelk  Bug 92155 Fixed. Added a method Exist_Valid_Template()
--  100807  Mawelk  Bug 92305 Fixed. Changes to  Insert___()
--  130304  AjPelk  Bug 107649, Merged , added a new field remove_end_separator.
--  131029  PRatlk  PBFI-715, Refactoring code according to the new template
--  150612  AjPelk  Bug 122969, Merge , windows sign , '\' has replaced with a parameter , server_path_separator_
--                  so that we can change the sign according to the OS system such as UNIX.
--  170504  Savmlk  STRFI-5698  LCS Merge(Bug 135223).
--  200904  Jadulk FISPRING20-6697, added Remove_Template_Per_Module
--  201015  Jadulk FISPRING20-7814, updated Remove_Template_Per_Module.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   separator_id_        Ext_File_Template_Tab.separator_id%TYPE;
   decimal_symbol_      Ext_File_Template_Tab.decimal_symbol%TYPE;
   date_format_         Ext_File_Template_Tab.date_format%TYPE;
BEGIN
   separator_id_   := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_SEPARATOR_ID');
   decimal_symbol_ := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DECIMAL_SYMBOL');
   date_format_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DATE_FORMAT');
   super(attr_);
   Client_SYS.Add_To_Attr( 'SEPARATED',         'TRUE',          attr_);
   Client_SYS.Add_To_Attr( 'SYSTEM_DEFINED',    'FALSE',         attr_);
   Client_SYS.Add_To_Attr( 'ACTIVE_DEFINITION', 'FALSE',         attr_);
   Client_SYS.Add_To_Attr( 'VALID_DEFINITION',  'FALSE',         attr_);
   Client_SYS.Add_To_Attr( 'SEPARATOR_ID',      separator_id_,   attr_);
   Client_SYS.Add_To_Attr( 'DECIMAL_SYMBOL',    decimal_symbol_, attr_);
   Client_SYS.Add_To_Attr( 'DATE_FORMAT',       date_format_,    attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_FILE_TEMPLATE_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Load_API.File_Template_Used (remrec_.file_template_id) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXUSEDTEMPFL: Not allowed to remove file template because it is used on a file load');
   END IF;
   IF (Ext_File_Company_Default_API.File_Template_Used (remrec_.file_template_id) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXUSEDTEMPCD: Not allowed to remove file template, beacuse it is used on a company default');
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_FILE_TEMPLATE_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Basic_Data_Translation_API.Remove_Basic_Data_Translation( 'ACCRUL',
                                                             lu_name_,
                                                             remrec_.file_template_id);
END Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_template_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.file_format IS NULL) THEN
      IF (newrec_.separated = 'TRUE') THEN
         newrec_.file_format := 'SEP';
      ELSE
         newrec_.file_format := 'FIX';
      END IF;
   END IF;
   IF (newrec_.file_format = 'SEP') THEN
      newrec_.separated := 'TRUE';
   ELSE
      newrec_.separated := 'FALSE';
   END IF;
END Check_Common___;



@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_template_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (newrec_.valid_definition IS NULL) THEN
      newrec_.valid_definition := 'FALSE';
   END IF;     
   IF (newrec_.system_defined IS NULL) THEN
      newrec_.system_defined := 'FALSE';
   END IF;  
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_        IN EXT_FILE_TEMPLATE_TAB%ROWTYPE)
IS
   rec_              EXT_FILE_TEMPLATE_TAB%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (rec_.file_format IS NULL) THEN
      IF (rec_.separated = 'TRUE') THEN
         rec_.file_format := 'SEP';
      ELSE
         rec_.file_format := 'FIX';
      END IF;
   END IF;
   IF (rec_.file_format = 'SEP') THEN
      rec_.separated := 'TRUE';
   ELSE
      rec_.separated := 'FALSE';
   END IF;
   IF (Ext_File_Load_API.File_Template_Used (rec_.file_template_id) ) THEN
      rec_.active_definition := 'TRUE';
   END IF;
   IF (Ext_File_Company_Default_API.File_Template_Used (rec_.file_template_id) ) THEN
      rec_.active_definition := 'TRUE';
   END IF;
   IF (NOT Check_Exist___(rec_.file_template_id)) THEN
      INSERT INTO ext_file_template_tab (
         file_template_id,
         system_defined,
         description,
         active_definition,
         valid_definition,
         separated,
         decimal_symbol,
         date_format,
         date_nls_calendar,
         denominator,
         separator_id,
         text_qualifier,
         file_type,
         file_format,
         rowversion)
      VALUES (
         rec_.file_template_id,
         rec_.system_defined,
         rec_.description,
         rec_.active_definition,
         rec_.valid_definition,
         rec_.separated,
         rec_.decimal_symbol,
         rec_.date_format,
         rec_.date_nls_calendar,
         rec_.denominator,
         rec_.separator_id,
         rec_.text_qualifier,
         rec_.file_type,
         rec_.file_format,
         rec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_template_id,
                                                          rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_template_id,
                                                          rec_.description);
      UPDATE EXT_FILE_TEMPLATE_TAB
         SET description = rec_.description
      WHERE  file_template_id = rec_.file_template_id;
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Create_Xml (
   file_template_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_TAB.file_format%TYPE;
BEGIN
   temp_ := Ext_File_Format_API.Encode(Get_File_Format (file_template_id_));
   IF (temp_ = 'XML') THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Create_Xml;


PROCEDURE Get_Ext_File_Head (
   ext_file_rec_     OUT External_File_Utility_API.ExtFileRec,
   file_template_id_ IN  VARCHAR2,
   file_direction_   IN  VARCHAR2 )
IS
   separator_id_         VARCHAR2(10);
   CURSOR head_ IS
      SELECT t.file_type,
             t.description,
             t.separated,
             t.separator_id,
             t.decimal_symbol,
             t.denominator,
             t.date_format,
             d.log_skipped_lines,
             d.log_invalid_lines,
             d.allow_record_set_repeat,
             d.allow_one_record_set_only,
             d.abort_immediatly,
             d.skip_all_blanks,
             d.skip_initial_blanks,
             d.number_out_fill_value,
             d.overwrite_file,
             d.name_option,
             d.create_header,
             t.text_qualifier,
             t.date_nls_calendar,
             t.file_format,
             d.api_to_call_unp_before,
             d.api_to_call_unp_after,
             d.remove_end_separator
      FROM   ext_file_template_tab     t,
             ext_file_template_dir_tab d
      WHERE  t.file_template_id = file_template_id_
      AND    d.file_template_id = t.file_template_id
      AND    d.file_direction   = file_direction_;
BEGIN
   OPEN  head_;
   FETCH head_ INTO ext_file_rec_.file_type,
                    ext_file_rec_.description,
                    ext_file_rec_.separated,
                    separator_id_,
                    ext_file_rec_.decimal_symbol,
                    ext_file_rec_.denominator,
                    ext_file_rec_.date_format,
                    ext_file_rec_.log_skipped_lines,
                    ext_file_rec_.log_invalid_lines,
                    ext_file_rec_.allow_record_set_repeat,
                    ext_file_rec_.allow_one_record_set_only,
                    ext_file_rec_.abort_immediatly,
                    ext_file_rec_.skip_all_blanks,
                    ext_file_rec_.skip_initial_blanks,
                    ext_file_rec_.number_out_fill_value,
                    ext_file_rec_.overwrite_file,
                    ext_file_rec_.ext_file_name_option,
                    ext_file_rec_.create_header,
                    ext_file_rec_.text_qualifier,
                    ext_file_rec_.date_nls_calendar,
                    ext_file_rec_.file_format,
                    ext_file_rec_.api_to_call_unp_before,
                    ext_file_rec_.api_to_call_unp_after,
                    ext_file_rec_.remove_end_separator;
   CLOSE head_;
   ext_file_rec_.file_template_id := file_template_id_;
   IF (ext_file_rec_.separated = 'TRUE') THEN
      Ext_File_Separator_API.Exist ( separator_id_ );
      ext_file_rec_.field_separator := Ext_File_Separator_API.Get_Separator ( separator_id_ );
      IF (ext_file_rec_.field_separator IS NULL) THEN
         Error_SYS.Appl_General( lu_name_, 'EMPTYSEP: Separator is empty' );
      END IF;
   END IF;
END Get_Ext_File_Head;


PROCEDURE Already_Exist (
   file_template_id_ IN VARCHAR2 )
IS
BEGIN
   IF (Check_Exist___(file_template_id_)) THEN
      Error_SYS.Appl_General( lu_name_, 'ALREADYEXIST: File Template Already Exist' );
   END IF;
END Already_Exist;


@UncheckedAccess
FUNCTION Check_Usable_File_Type (
   file_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_        NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Tab T
      WHERE  T.file_type         = file_type_
      AND    T.valid_definition  = 'TRUE'
      AND    T.active_definition = 'TRUE'
      AND EXISTS
         (SELECT 1
          FROM   Ext_File_Template_Dir_Tab D
          WHERE  D.file_template_id = T.file_template_id);
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Usable_File_Type;


@UncheckedAccess
FUNCTION Count_Usable_File_Template (
   file_type_ IN VARCHAR2 ) RETURN NUMBER
IS
   dummy_        NUMBER;
   CURSOR exist_control IS
      SELECT COUNT(*)
      FROM   Ext_File_Template_Tab T
      WHERE  T.file_type         = file_type_
      AND    T.valid_definition  = 'TRUE'
      AND    T.active_definition = 'TRUE'
      AND EXISTS
         (SELECT 1
          FROM   Ext_File_Template_Dir_Tab D
          WHERE  D.file_template_id = T.file_template_id);
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN dummy_;
   END IF;
   CLOSE exist_control;
   RETURN 0;
END Count_Usable_File_Template;


PROCEDURE Exist_Type (
   file_type_        IN VARCHAR2,
   file_template_id_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TEMPLATE_TAB
      WHERE  file_template_id = file_template_id_
      AND    file_type        = file_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
   CLOSE exist_control;
END Exist_Type;


PROCEDURE Exist_Valid (
   file_template_id_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TEMPLATE_TAB
      WHERE file_template_id = file_template_id_
      AND   valid_definition = 'TRUE';
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
   CLOSE exist_control;
END Exist_Valid;


PROCEDURE Exist_Valid_Template (
   file_type_        IN VARCHAR2,
   file_template_id_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TEMPLATE_TAB
      WHERE file_template_id = file_template_id_
      AND   file_type        = file_type_
      AND   valid_definition = 'TRUE';
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      Error_Sys.Record_General('ExtFileTemplate','EXTVALTEMPLATE: :P1 file template is not connected :P2 file type.',file_template_id_, file_type_ );
   END IF;
   CLOSE exist_control;
END Exist_Valid_Template;


FUNCTION File_Type_Used (
   file_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TEMPLATE_TAB
      WHERE file_type = file_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END File_Type_Used;


FUNCTION Get_Backup_File_Name (
   load_file_id_  IN NUMBER,
   server_client_ IN VARCHAR2 DEFAULT 'C' ) RETURN VARCHAR2
IS
   file_type_              VARCHAR2(30);
   file_id_                VARCHAR2(30);
   backup_file_name_       VARCHAR2(2000);
   file_name_              VARCHAR2(2000);
   backup_file_path_       VARCHAR2(2000);
   c_backup_file_path_     VARCHAR2(2000);
   s_backup_file_path_     VARCHAR2(2000);
   last_slash_             NUMBER;
   last_dot_               NUMBER;
   server_path_separator_  VARCHAR2(1);

   CURSOR get_attr IS
      SELECT l.file_type,
             l.file_template_id,
             l.file_name,
             f.backup_file_path,
             f.backup_file_path_server
      FROM   Ext_File_Load_Tab         l,
             Ext_File_Template_Dir_Tab f
      WHERE  l.load_file_id     = load_file_id_
      AND    f.file_template_id = l.file_template_id
      AND    f.file_direction   = '1';
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO file_type_,
                       file_id_,
                       file_name_,
                       c_backup_file_path_,
                       s_backup_file_path_;
   CLOSE get_attr;
   Trace_SYS.Message ('server_client_ : '||server_client_);
   IF (server_client_ = 'S') THEN
      backup_file_path_ := s_backup_file_path_;
   ELSE
      backup_file_path_ := c_backup_file_path_;
   END IF;
   IF (backup_file_path_ IS NULL) THEN
      IF (server_client_ = 'S') THEN
         backup_file_path_ := Accrul_Attribute_API.Get_Attribute_Value('UTL_FILE_DIR_BACKUP');
      END IF;
      IF (backup_file_path_ IS NULL) THEN
         RETURN NULL;
      END IF;
   END IF;
   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   IF (SUBSTR(backup_file_path_,LENGTH(backup_file_path_),1) != server_path_separator_) THEN
      backup_file_path_ := backup_file_path_ || server_path_separator_;
   END IF;
   last_slash_ := INSTR(file_name_,server_path_separator_,-1);
   IF (last_slash_ = 0) THEN
      backup_file_name_ := backup_file_path_ || file_name_;
   ELSE
      backup_file_name_ := backup_file_path_ || SUBSTR(file_name_,INSTR(file_name_,server_path_separator_,-1)+1);
   END IF;
   last_dot_   := INSTR(backup_file_name_,'.',-1);
   last_slash_ := INSTR(backup_file_name_,server_path_separator_,-1);
   IF last_dot_ > last_slash_ THEN
     backup_file_name_ := SUBSTR(backup_file_name_,1,last_dot_-1) || '_'||TO_CHAR(load_file_id_)||'.bak';
   ELSE
     backup_file_name_ := backup_file_name_ || '_'||TO_CHAR(load_file_id_)||'.bak'; 
   END IF;  
   IF NVL(LENGTH(backup_file_name_),0) > 259 THEN
      Error_SYS.Appl_General(lu_name_,'BACKUP_FAILED: Backup File Creation Failed. The length of Back Up File Path should be less than 260 characters.');
   END IF;
   RETURN backup_file_name_;
END Get_Backup_File_Name;


@UncheckedAccess
FUNCTION Get_Default_File_Template_Id (
   file_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_TAB.file_template_id%TYPE;
   CURSOR get_attr IS
      SELECT file_template_id
      FROM EXT_FILE_TEMPLATE_TAB
      WHERE file_type         = file_type_
      AND   valid_definition  = 'TRUE'
      AND   active_definition = 'TRUE'
      ORDER BY DECODE(system_defined,'TRUE',0,1),
               file_template_id;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   IF (get_attr%NOTFOUND) THEN
      CLOSE get_attr;
      RETURN NULL;
   END IF;
   CLOSE get_attr;
   RETURN temp_;
END Get_Default_File_Template_Id;


@UncheckedAccess
FUNCTION Get_File_Template_Id (
   file_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_TAB.file_template_id%TYPE;
   CURSOR get_attr IS
      SELECT file_template_id
      FROM EXT_FILE_TEMPLATE_TAB
      WHERE file_type = file_type_;
BEGIN
   FOR rec_ IN get_attr LOOP
      IF (temp_ IS NULL) THEN
         temp_ := rec_.file_template_id;
      ELSE
         temp_ := NULL;
         EXIT;
      END IF;
   END LOOP;
   RETURN temp_;
END Get_File_Template_Id;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Template_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Template_Tab%ROWTYPE;
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
   FROM   Ext_File_Template_Tab
   WHERE  file_template_id = file_template_id_;
   Ext_File_Template_Control_API.Remove_Template  ( file_template_id_ );
   Ext_File_Template_Dir_API.Remove_Template      ( file_template_id_ );
   Ext_File_Template_Detail_API.Remove_Template   ( file_template_id_ );
   Ext_File_Templ_Det_Func_API.Remove_Template    ( file_template_id_ );
   Basic_Data_Translation_API.Remove_Basic_Data_Translation( 'ACCRUL',
                                                             lu_name_,
                                                             file_template_id_);
END Remove_Template;


PROCEDURE Update_Valid_Definition (
   info_             IN OUT VARCHAR2,
   file_template_id_ IN VARCHAR2,
   show_error_       IN VARCHAR2 DEFAULT 'TRUE' )
IS
   file_type_             VARCHAR2(30);
   error_type_            VARCHAR2(20);
   old_valid_definition_  VARCHAR2(5);
   new_valid_definition_  VARCHAR2(5);
   new_active_definition_ VARCHAR2(5);
   err_msg_               VARCHAR2(2000); 
BEGIN
   file_type_             := Ext_File_Template_API.Get_File_Type ( file_template_id_ );
   new_active_definition_ := Ext_File_Template_API.Get_Active_Definition ( file_template_id_ );
   old_valid_definition_  := Ext_File_Template_API.Get_Valid_Definition ( file_template_id_ );
   External_File_Utility_API.Check_Valid_Definition ( new_valid_definition_,
                                                      error_type_,
                                                      file_type_,
                                                      file_template_id_ );
   new_active_definition_ := Ext_File_Template_API.Get_Active_Definition ( file_template_id_ );
   IF (new_valid_definition_ != old_valid_definition_) THEN
      IF (new_valid_definition_ = 'FALSE') THEN
         new_active_definition_ := 'FALSE';
      END IF;
      UPDATE Ext_File_Template_Tab
         SET valid_definition  = new_valid_definition_,
             active_definition = NVL(new_active_definition_,active_definition)
      WHERE  file_template_id = file_template_id_;
   END IF;
   IF (show_error_ = 'TRUE') THEN
      IF    (error_type_ = 'SepError1') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL1: Start position specified for a separated file');
      ELSIF (error_type_ = 'SepError2') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL2: Column no specified for a not separated file');
      ELSIF (error_type_ = 'MissMandRectype') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL3: Mandatory record type on file type is missing on file definition');
      ELSIF (error_type_ = 'NoControlsMult') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL4: No controls specified when using more than one record type');
      ELSIF (error_type_ = 'NoDetails') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL5: There are no details specified');
      ELSIF (error_type_ = 'NoDirection') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'EXFNOVAL6: There is no direction information specified');
      ELSIF (new_valid_definition_ = 'TRUE') THEN
         err_msg_ := Language_SYS.Translate_Constant(lu_name_,'VALID: File Definition is valid');
      END IF;
      Client_SYS.Clear_Info;
      Client_SYS.Add_Info(lu_name_, err_msg_);
      info_ := Client_SYS.Get_All_Info;
      info_ := err_msg_;      
   END IF;
END Update_Valid_Definition;


PROCEDURE Remove_Template_Per_Module (
   module_        IN VARCHAR2 )
IS
   CURSOR get_file_templates IS
      SELECT t.file_template_id
      FROM   ext_file_template_tab t, ext_file_type_tab y
      WHERE  t.system_defined = 'TRUE'
      AND    t.file_type = y.file_type
      AND    y.component = UPPER(module_)
      AND    y.system_defined = 'TRUE';
BEGIN
   FOR template_rec IN get_file_templates LOOP      
      Remove_Template(template_rec.file_template_id);
   END LOOP;
END Remove_Template_Per_Module;



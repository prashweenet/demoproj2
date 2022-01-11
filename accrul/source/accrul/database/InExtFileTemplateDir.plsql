-----------------------------------------------------------------------------
--
--  Logical unit: InExtFileTemplateDir
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  061002  Samwlk  LCS Merge 60713, Pass new parameter in File_Template_Used Function Call.
--  100910  Jeguse  Bug 92463 Corrected.
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  130823  Shedlk Bug 111220, Corrected END statements to match the corresponding procedure nam
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   temp_                VARCHAR2(2000);
   file_path_           VARCHAR2(200);
   backup_file_path_    VARCHAR2(200);
   remove_days_         NUMBER;
   load_file_type_list_ Ext_File_Template_Dir_Tab.load_file_type_list%TYPE;
   file_template_id_    VARCHAR2(30);
   file_type_           VARCHAR2(30);
   api_to_call_         VARCHAR2(100);
   attr_temp_           VARCHAR2(4000);
BEGIN
   attr_temp_ :=attr_;
   super(attr_);
   attr_ :=attr_temp_;
   file_template_id_    := Client_SYS.Get_Item_Value ( 'FILE_TEMPLATE_ID',
                                                       attr_ );
   file_type_           := Ext_File_Template_API.Get_File_Type ( file_template_id_ );
   api_to_call_         := Ext_File_Type_API.Get_Api_To_Call_Input ( file_type_ );
   load_file_type_list_ := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_FILE_TYPE_LIST');
   file_path_           := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_INPUT_PATH');
   backup_file_path_    := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_BACKUP_PATH');
   temp_                := Accrul_Attribute_API.Get_Attribute_Value('EXT_REMOVE_DAYS_IN');
   IF (temp_ = 'NULL') THEN
      remove_days_      := NULL;
   ELSE
      remove_days_      := temp_;
   END IF;
   Ext_File_Template_Dir_API.New__(temp_, temp_, temp_, attr_, 'PREPARE');
   Client_SYS.Add_To_Attr ( 'FILE_DIRECTION',            File_Direction_API.Decode('1'), attr_);
   Client_SYS.Add_To_Attr ( 'ABORT_IMMEDIATLY',          'FALSE',                        attr_);
   Client_SYS.Add_To_Attr ( 'ALLOW_RECORD_SET_REPEAT',   'FALSE',                        attr_); 
   Client_SYS.Add_To_Attr ( 'LOG_INVALID_LINES',         'TRUE',                         attr_);
   Client_SYS.Add_To_Attr ( 'LOG_SKIPPED_LINES',         'TRUE',                         attr_);
   Client_SYS.Add_To_Attr ( 'ALLOW_ONE_RECORD_SET_ONLY', 'FALSE',                        attr_);
   Client_SYS.Add_To_Attr ( 'SKIP_ALL_BLANKS',           'TRUE',                         attr_);
   Client_SYS.Add_To_Attr ( 'SKIP_INITIAL_BLANKS',       'FALSE',                        attr_);
   Client_SYS.Add_To_Attr ( 'LOAD_FILE_TYPE_LIST',       load_file_type_list_,           attr_);
   Client_SYS.Add_To_Attr ( 'FILE_PATH',                 file_path_,                     attr_);
   Client_SYS.Add_To_Attr ( 'BACKUP_FILE_PATH',          backup_file_path_,              attr_);
   Client_SYS.Add_To_Attr ( 'REMOVE_DAYS',               remove_days_,                   attr_);
   Client_SYS.Add_To_Attr ( 'REMOVE_COMPLETE',           'FALSE',                        attr_);
   Client_SYS.Add_To_Attr ( 'API_TO_CALL',               api_to_call_,                   attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_FILE_TEMPLATE_DIR_TAB%ROWTYPE )
IS
BEGIN
    
   IF (Ext_File_Load_API.File_Template_Used (remrec_.file_template_id,1)) THEN
      Error_SYS.Appl_General( lu_name_, 'EXLOADTEMP: Not allowed to remove input file definition because it is used on a file load');
   END IF;
       
   IF (Ext_File_Company_Default_API.File_Template_Used (remrec_.file_template_id) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXCOMPTEMP: Not allowed to remove input file definition because it is used on a company default');
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);   
BEGIN
   attr_ :=Client_SYS.Remove_Attr('FILE_TYPE',attr_);
   IF In_Ext_File_Template_Dir_API.Check_Rec_Exist(newrec_.file_template_id) = 'TRUE' THEN
      Error_SYS.Appl_General( lu_name_, 'RECEXISTS: Input File Direction is already defined');
   END IF;
     
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_file_template_dir_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_    VARCHAR2(30);
   value_   VARCHAR2(4000);
BEGIN
   attr_ :=Client_SYS.Remove_Attr('FILE_TYPE',attr_);
   IF Ext_File_Template_API.Get_System_Defined(oldrec_.file_template_id) = 'TRUE' THEN
      Validate_SYS.Item_Update(lu_name_, 'LOAD_FILE_TYPE_LIST', indrec_.load_file_type_list);
      Validate_SYS.Item_Update(lu_name_, 'ALLOW_RECORD_SET_REPEAT', indrec_.allow_record_set_repeat);
      Validate_SYS.Item_Update(lu_name_, 'ALLOW_ONE_RECORD_SET_ONLY', indrec_.allow_one_record_set_only);
      Validate_SYS.Item_Update(lu_name_, 'SKIP_ALL_BLANKS', indrec_.skip_all_blanks);
      Validate_SYS.Item_Update(lu_name_, 'SKIP_INITIAL_BLANKS', indrec_.skip_initial_blanks);
   END IF;
   Validate_SYS.Item_Update(lu_name_, 'API_TO_CALL', indrec_.api_to_call);
   Validate_SYS.Item_Update(lu_name_, 'API_TO_CALL_UNP_BEFORE', indrec_.api_to_call_unp_before);
   Validate_SYS.Item_Update(lu_name_, 'API_TO_CALL_UNP_AFTER', indrec_.api_to_call_unp_after);      
   super(oldrec_, newrec_, indrec_, attr_);    
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_template_dir_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF newrec_.character_set IS NOT NULL THEN
      Database_SYS.Validate_File_Encoding(newrec_.character_set);
   END IF;   
   IF (NVL(LENGTH(newrec_.file_name),0) + NVL(LENGTH(newrec_.file_path),0)) > 200 OR
      (NVL(LENGTH(newrec_.file_name),0) + NVL(LENGTH(newrec_.backup_file_path),0)) > 200 THEN
      Error_SYS.Appl_General( lu_name_, 'MAXLENGTH: Maximum length allowed for File Name including File Path is 200 characters');
   END IF;

   IF newrec_.api_to_call IS NOT NULL AND indrec_.api_to_call THEN
      Validate_Method___(newrec_.api_to_call);
   END IF;
   IF newrec_.api_to_call_unp_before IS NOT NULL AND indrec_.api_to_call_unp_before THEN
      Validate_Method___(newrec_.api_to_call_unp_before);
   END IF;
   IF newrec_.api_to_call_unp_after IS NOT NULL AND indrec_.api_to_call_unp_after THEN
      Validate_Method___(newrec_.api_to_call_unp_after);
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);   
END Check_Common___;

PROCEDURE Validate_Method___ (
   method_ IN VARCHAR2)
IS   
BEGIN
   IF (method_ IS NOT NULL )THEN 
      Finance_Lib_API.Is_Method_Available(method_);
   END IF;   
END Validate_Method___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Rec_Exist (
   file_template_id_ IN  VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Ext_File_Template_Dir_API.Check_Rec_Exist ( file_template_id_,
                                                      '1' );
END Check_Rec_Exist;


@UncheckedAccess
FUNCTION Get_Log_Skipped_Lines_Db (
   file_template_id_    IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.log_skipped_lines;
END Get_Log_Skipped_Lines_Db;


@UncheckedAccess
FUNCTION Get_Log_Invalid_Lines_Db (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.log_invalid_lines;
END Get_Log_Invalid_Lines_Db;


@UncheckedAccess
FUNCTION Get_File_Path_Server_Db (
   file_template_id_ IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.file_path_server;
END Get_File_Path_Server_Db;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Template_Dir_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Template_Dir_Tab%ROWTYPE;
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


PROCEDURE Copy_File_Defintion (
   file_template_id_      IN  VARCHAR2,
   from_file_template_id_ IN  VARCHAR2 )
IS
   newrec_                    Ext_File_Template_Dir_Tab%ROWTYPE;
   CURSOR get_template IS
      SELECT *
      FROM   Ext_File_Template_Dir_Tab D
      WHERE  D.file_template_id = from_file_template_id_
      AND    rowtype LIKE '%InExtFileTemplateDir';
BEGIN
   OPEN  get_template;
   FETCH get_template INTO newrec_;
   IF (get_template%FOUND) THEN
      newrec_.file_template_id := file_template_id_;
      Insert_Record ( newrec_ );
   END IF;
   CLOSE get_template;
END Copy_File_Defintion;


@UncheckedAccess
FUNCTION Get_File_Path_Db (
   file_template_id_ IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.file_path;
END Get_File_Path_Db;


@UncheckedAccess
FUNCTION Get_Backup_File_Path_Server_Db (
   file_template_id_ IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.backup_file_path_server;
END Get_Backup_File_Path_Server_Db;


@UncheckedAccess
FUNCTION Get_Skip_All_Blanks_Db (
   file_template_id_    IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.skip_all_blanks;
END Get_Skip_All_Blanks_Db;


@UncheckedAccess
FUNCTION Get_Character_Set_Db (
   file_template_id_    IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get(file_template_id_,
                file_direction_db_);
   RETURN temp_.character_set;
END Get_Character_Set_Db;

@UncheckedAccess
FUNCTION Get_Skip_Initial_Blanks_Db (
   file_template_id_    IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.skip_initial_blanks;
END Get_Skip_Initial_Blanks_Db;


@UncheckedAccess
FUNCTION Get_Allow_Record_Set_Repeat_Db (
   file_template_id_ IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.allow_record_set_repeat;
END Get_Allow_Record_Set_Repeat_Db;


@UncheckedAccess
FUNCTION Get_Allow_One_Rec_Set_Only_Db (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.allow_one_record_set_only;
END Get_Allow_One_Rec_Set_Only_Db;


@UncheckedAccess
FUNCTION Get_Abort_Immediatly_Db (
   file_template_id_    IN VARCHAR2,
   file_direction_db_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.abort_immediatly;
END Get_Abort_Immediatly_Db;


@UncheckedAccess
FUNCTION Get_Load_File_Type_List_Db (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN NVL(temp_.load_file_type_list,'*^*');
END Get_Load_File_Type_List_Db;


@UncheckedAccess
FUNCTION Get_File_Name_Db (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Public_Rec;
BEGIN
   temp_ := Get ( file_template_id_, file_direction_db_ );
   RETURN temp_.file_name;
END Get_File_Name_Db;




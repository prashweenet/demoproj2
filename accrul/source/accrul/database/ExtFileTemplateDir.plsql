-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTemplateDir
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  080922  Jeguse  Bug 77126, Added new method Get_Xml_Layout_Id
--  090116  Jeguse  Bug 79498, Increased length of file_name
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110629  Sacalk  FIDEAGLE-293, Merged Bug 97504 . 
--  130823  Shedlk  Bug 111220, Corrected END statements to match the corresponding procedure name
--  131123  MeAlLK  PBFI-2017, Refactored code
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_template_dir_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF newrec_.character_set IS NOT NULL THEN
      Database_SYS.Validate_File_Encoding(newrec_.character_set);
   END IF;
END Check_Common___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Rec_Exist (
   file_template_id_ IN  VARCHAR2,
   file_direction_   IN  VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE file_template_id = file_template_id_
      AND   file_direction   = file_direction_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Rec_Exist;


@UncheckedAccess
FUNCTION Get_Api_To_Call_Unp_Before (
   file_template_id_ IN VARCHAR2,
   file_direction_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.api_to_call_unp_before%TYPE;
   CURSOR get_attr IS
      SELECT api_to_call_unp_before
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Api_To_Call_Unp_Before;


@UncheckedAccess
FUNCTION Get_Api_To_Call_Unp_After (
   file_template_id_ IN VARCHAR2,
   file_direction_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.api_to_call_unp_after%TYPE;
   CURSOR get_attr IS
      SELECT api_to_call_unp_after
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Api_To_Call_Unp_After;


@UncheckedAccess
FUNCTION Get_Remove_Days (
   file_template_id_ IN VARCHAR2,
   file_direction_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.remove_days%TYPE;
   CURSOR get_attr IS
      SELECT remove_days
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Remove_Days;


@UncheckedAccess
FUNCTION Get_File_Direction_Db (
   file_template_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.file_direction%TYPE;
   CURSOR get_attr IS
      SELECT file_direction
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_ 
      ORDER BY DECODE(file_direction,'2',0,1);
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_File_Direction_Db;


@UncheckedAccess
FUNCTION Get_File_Direction (
   file_template_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.file_direction%TYPE;
   CURSOR get_attr IS
      SELECT file_direction
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_ ;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN substr(File_Direction_API.Decode(temp_),1,200);
END Get_File_Direction;


@UncheckedAccess
FUNCTION Get_Multi_Direction (
   file_template_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   count_               NUMBER;
   CURSOR get_attr IS
      SELECT NVL(COUNT(*),0)
      FROM   EXT_FILE_TEMPLATE_DIR_TAB
      WHERE  file_template_id = file_template_id_ ;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO count_;
   CLOSE get_attr;
   IF (count_ = 0) THEN
      RETURN 'NONE';
   ELSIF (count_ = 1) THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
END Get_Multi_Direction;

@UncheckedAccess
PROCEDURE Get_Direction_Info (
   file_template_id_      IN     VARCHAR2,
   description_           IN OUT VARCHAR2,
   multi_direction_       IN OUT VARCHAR2,
   api_to_call_           IN OUT VARCHAR2,
   view_name_             IN OUT VARCHAR2,
   form_name_             IN OUT VARCHAR2,
   target_default_method_ IN OUT VARCHAR2 ) 
IS
   CURSOR get_attr IS
      SELECT NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ExtFileTemplate', 'ExtFileTemplateDir', file_template_id_ ),100)),t.description)
                                       description,
             d.api_to_call             api_to_call,
             y.view_name               view_name, 
             y.form_name               form_name, 
             y.target_default_method   target_default_method
      FROM   Ext_File_Template_Dir_Tab d,
             Ext_File_Template_Tab     t,
             Ext_File_Type_Tab         y
      WHERE  t.file_template_id = file_template_id_ 
      AND    d.file_template_id = t.file_template_id
      AND    y.file_type        = t.file_type;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO description_,
                       api_to_call_,
                       view_name_,
                       form_name_,
                       target_default_method_;
   CLOSE get_attr;
   multi_direction_ := Get_Multi_Direction ( file_template_id_ );
   IF (multi_direction_ = 'NONE') THEN
      Error_SYS.Appl_General( lu_name_, 'NODIRECTION: There is no direction specified on file template' );
   END IF;
END Get_Direction_Info;


@UncheckedAccess
FUNCTION Get_File_Name (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.file_name%TYPE;
   CURSOR get_attr IS
      SELECT file_name
      FROM   Ext_File_Template_Dir_Tab 
      WHERE  file_template_id = file_template_id_ 
      AND    file_direction = file_direction_db_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_File_Name;


@UncheckedAccess
FUNCTION Get_File_Path_Name (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2,
   client_server_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   file_name_path_        VARCHAR2(2000);
   file_name_             EXT_FILE_TEMPLATE_DIR_TAB.file_name%TYPE;
   file_path_             EXT_FILE_TEMPLATE_DIR_TAB.file_path%TYPE;
   file_path_server_      EXT_FILE_TEMPLATE_DIR_TAB.file_path_server%TYPE;
   
   server_path_separator_ VARCHAR2(1);
      
   CURSOR get_attr IS
      SELECT file_name,
             file_path,
             file_path_server
      FROM   Ext_File_Template_Dir_Tab 
      WHERE  file_template_id = file_template_id_ 
      AND    file_direction = file_direction_db_;
BEGIN
   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   OPEN  get_attr;
   FETCH get_attr INTO file_name_,
                       file_path_,
                       file_path_server_;
   CLOSE get_attr;
   IF (file_path_ IS NOT NULL) THEN
      IF (SUBSTR(file_path_,-1) != '\') THEN
         file_path_ := file_path_ || '\';
      END IF;
   END IF;
   IF (file_path_server_ IS NOT NULL) THEN
      IF (SUBSTR(file_path_server_,-1) != server_path_separator_) THEN
         file_path_server_ := file_path_server_ || server_path_separator_;
      END IF;
   END IF;
   IF (NVL(client_server_,'C') = 'C') THEN
      file_name_path_ := file_path_ || file_name_;
   ELSE
      file_name_path_ := file_path_server_ || file_name_;
   END IF;
   RETURN file_name_path_;
END Get_File_Path_Name;


@UncheckedAccess
FUNCTION Get_Xml_Layout_Id (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TEMPLATE_DIR_TAB.xml_layout_id%TYPE;
   CURSOR get_attr IS
      SELECT xml_layout_id
      FROM   Ext_File_Template_Dir_Tab 
      WHERE  file_template_id = file_template_id_ 
      AND    file_direction = file_direction_db_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Xml_Layout_Id;


PROCEDURE Remove_Template (
   file_template_id_  IN VARCHAR2 ) 
IS
BEGIN
   DELETE
   FROM EXT_FILE_TEMPLATE_DIR_TAB
   WHERE file_template_id = file_template_id_;
END Remove_Template;




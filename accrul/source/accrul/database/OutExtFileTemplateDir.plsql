-----------------------------------------------------------------------------
--
--  Logical unit: OutExtFileTemplateDir
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  061002  Samwlk  LCS Merge 60713, Pass new parameter in File_Template_Used Function Call.
--  080922  Jeguse  Bug 77126 corrected.
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  130304  AjPelk  Bug 107649, Merged bug , added a new pub field remove_end_separator.
--  130823  Shedlk  Bug 111220, Corrected END statements to match the corresponding procedure nam
--  170227  Savmlk  STRFI-5087, LCS Bug 134423 merged.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------
PROCEDURE Get_Id_Version_By_Keys__ (
   objid_             IN OUT NOCOPY VARCHAR2,
   objversion_        IN OUT NOCOPY VARCHAR2,
   file_template_id_  IN            VARCHAR2,
   file_direction_db_ IN            VARCHAR2)
IS
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, file_template_id_, file_direction_db_);
END Get_Id_Version_By_Keys__;

PROCEDURE Remove_Xml_Style_Sheet__ (
   file_template_id_  IN VARCHAR2,
   file_direction_db_ IN VARCHAR2  )
IS
   rec_        ext_file_template_dir_tab%ROWTYPE;
   rowid_      VARCHAR2(200); 
   objversion_ VARCHAR2(200);
BEGIN
   Get_Id_Version_By_Keys___(rowid_, objversion_, file_template_id_, file_direction_db_);
   rec_ := Lock_By_Id___(rowid_, objversion_);
   UPDATE ext_file_template_dir_tab
   SET xml_style_sheet = NULL,
       rowversion = SYSDATE
   WHERE rowid = rowid_;
END Remove_Xml_Style_Sheet__;

@Override
PROCEDURE Write_Xml_Style_Sheet__ (
   objversion_ IN OUT VARCHAR2,
   rowid_      IN     ROWID,
   lob_loc_    IN     BLOB )
IS
   temp_ CLOB;
BEGIN
   temp_ := External_File_Utility_API.Blob_To_Clob__(lob_loc_);
   SELECT XMLTRANSFORM(XMLTYPE.CREATEXML(temp_), NULL).getclobval()
   INTO temp_
   FROM DUAL;
   super(objversion_, rowid_, lob_loc_);
END Write_Xml_Style_Sheet__;

PROCEDURE Update_Style_Sheet_Name__(
   file_template_id_  IN VARCHAR2,
   file_name_         IN VARCHAR2)
IS
   rec_   ext_file_template_dir_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(file_template_id_,'2');
   rec_.xml_style_sheet_name := file_name_;
   Modify___(rec_);
END Update_Style_Sheet_Name__;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   temp_             VARCHAR2(2000);
   file_path_        VARCHAR2(200);
   remove_days_      NUMBER;
   file_template_id_ VARCHAR2(30);
   file_type_        VARCHAR2(30);
   api_to_call_      VARCHAR2(100);
   attr_temp_        VARCHAR2(2000);
BEGIN
   attr_temp_ := attr_;
   super(attr_);
   attr_ := attr_temp_;
   file_template_id_    := Client_SYS.Get_Item_Value ( 'FILE_TEMPLATE_ID',attr_ );
   file_type_           := Ext_File_Template_API.Get_File_Type ( file_template_id_ );
   api_to_call_         := Ext_File_Type_API.Get_Api_To_Call_Output ( file_type_ );
   file_path_        := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_OUTPUT_PATH');
   temp_             := Accrul_Attribute_API.Get_Attribute_Value('EXT_REMOVE_DAYS_OUT');
   IF (temp_ = 'NULL') THEN
      remove_days_   := NULL;
   ELSE
      remove_days_   := temp_;
   END IF;
   Ext_File_Template_Dir_API.New__(temp_, temp_, temp_, attr_, 'PREPARE');
   Client_SYS.Add_To_Attr ( 'FILE_DIRECTION',  File_Direction_API.Decode('2'),       attr_);
   Client_SYS.Add_To_Attr ( 'NAME_OPTION',     Ext_File_Name_Option_API.Decode('1'), attr_);
   Client_SYS.Add_To_Attr ( 'OVERWRITE_FILE',  'TRUE',                               attr_);
   Client_SYS.Add_To_Attr ( 'CREATE_HEADER',   'FALSE',                              attr_);
   Client_SYS.Add_To_Attr ( 'FILE_PATH',       file_path_,                           attr_);
   Client_SYS.Add_To_Attr ( 'REMOVE_DAYS',     remove_days_,                         attr_);
   Client_SYS.Add_To_Attr ( 'REMOVE_COMPLETE', 'FALSE',                              attr_);
   Client_SYS.Add_To_Attr ( 'API_TO_CALL',     api_to_call_,                         attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN ext_file_template_dir_tab%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Load_API.File_Template_Used (remrec_.file_template_id,2) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXLOADTEMP: Not allowed to remove output file definition because it is used on a file load');
   END IF;
   
   IF (Ext_File_Company_Default_API.File_Template_Used (remrec_.file_template_id) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXCOMPTEMP: Not allowed to remove output file definition beacuse it is used on a company default');
   END IF;
   super(remrec_);
END Check_Delete___;



@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_template_dir_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (NVL(LENGTH(newrec_.file_name),0) + NVL(LENGTH(newrec_.file_path),0)) > 200 THEN
      Error_SYS.Appl_General( lu_name_, 'MAXLENGTH: Maximum length allowed for File Name including File Path is 200 characters');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   IF newrec_.character_set IS NOT NULL THEN
      Database_SYS.Validate_File_Encoding(newrec_.character_set);
   END IF;
   IF newrec_.xml_layout_id IS NOT NULL THEN
      Ext_File_Xml_Layout_API.Exist(newrec_.xml_layout_id);
   END IF;
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT NOCOPY ext_file_template_dir_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF Out_Ext_File_Template_Dir_API.Check_Rec_Exist(newrec_.file_template_id) = 'TRUE' THEN
      Error_SYS.Appl_General( lu_name_, 'RECEXISTS: Output File Direction is already defined');
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
BEGIN
   IF Ext_File_Template_API.Get_System_Defined(oldrec_.file_template_id) = 'TRUE' THEN
      Validate_SYS.Item_Update(lu_name_, 'NAME_OPTION', indrec_.name_option);
      Validate_SYS.Item_Update(lu_name_, 'NUMBER_OUT_FILL_VALUE', indrec_.number_out_fill_value);
      Validate_SYS.Item_Update(lu_name_, 'OVERWRITE_FILE', indrec_.overwrite_file);
      Validate_SYS.Item_Update(lu_name_, 'CREATE_HEADER', indrec_.create_header);
      Validate_SYS.Item_Update(lu_name_, 'CREATE_XML_FILE', indrec_.create_xml_file);
      Validate_SYS.Item_Update(lu_name_, 'XML_STYLE_SHEET_NAME', indrec_.xml_style_sheet_name);
   END IF;
   Validate_SYS.Item_Update(lu_name_, 'API_TO_CALL', indrec_.api_to_call);
   super(oldrec_, newrec_, indrec_, attr_);   
END Check_Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Rec_Exist (
   file_template_id_ IN  VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Ext_File_Template_Dir_API.Check_Rec_Exist ( file_template_id_,
                                                      '2' );
END Check_Rec_Exist;


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
      AND    rowtype LIKE '%OutExtFileTemplateDir';
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



-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  ?????? ????    Created
--  021023  PPerse Merged External Files
--  040726  anpelk FIPR338B Added column system_bound 
--  091216  HimRlk Reverse engineering correction, Removed method call to Ext_Type_Param_Set_API.Remove_File_Type in 
--  091216         method Remove_File_Type() and Delete().
--  100807  Mawelk  Bug 92305 Fixed. Changes to  Insert___(
--  140324  Umdolk PBFI-6208, added new rowkey value in Insert_Record.
--  200904  Jadulk FISPRING20-6697, added Remove_File_Type_Per_Module
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
   Client_SYS.Add_To_Attr( 'SYSTEM_DEFINED', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_FILE_TYPE_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Load_API.File_Type_Used (remrec_.file_type) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXUSEDLOAD: Not allowed to remove file type, because it is used on a file load');
   END IF;
   IF (Ext_File_Template_API.File_Type_Used (remrec_.file_type) ) THEN
      Error_SYS.Appl_General( lu_name_, 'EXUSEDTEMP: Not allowed to remove file type, because it is used on a file template');
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_FILE_TYPE_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Ext_File_Type_Rec_API.Remove_File_Type ( remrec_.file_type );
   Ext_File_Type_Rec_Column_API.Remove_File_Type ( remrec_.file_type );
   Ext_File_Type_Param_API.Remove_File_Type ( remrec_.file_type );
   Ext_Type_Param_Per_Set_API.Remove_File_Type ( remrec_.file_type );
                                                          
END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   newrec_.system_defined := 'FALSE';
   newrec_.system_bound := 'FALSE';
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_type_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.component IS NOT NULL) AND (indrec_.component) AND (Validate_SYS.Is_Changed(oldrec_.component, newrec_.component)) THEN
      Module_API.Exist(newrec_.component);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_        IN EXT_FILE_TYPE_TAB%ROWTYPE)
IS
   rec_              EXT_FILE_TYPE_TAB%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.file_type)) THEN
      INSERT INTO ext_file_type_tab (
         file_type,
         description,
         component,
         system_defined,
         system_bound,
         target_default_method,                  
         view_name,
         form_name,
         input_package,          
         api_to_call_input,
         api_to_call_output,
         input_projection_action,
         output_projection_action,
         rowversion)
      VALUES (
         newrec_.file_type,
         newrec_.description,
         newrec_.component,
         newrec_.system_defined,
         newrec_.system_bound,
         newrec_.target_default_method,          
         newrec_.view_name,
         newrec_.form_name,
         newrec_.input_package,          
         newrec_.api_to_call_input,
         newrec_.api_to_call_output,
         newrec_.input_projection_action,
         newrec_.output_projection_action,
         newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation('ACCRUL', 
                                                         lu_name_, 
                                                         rec_.file_type,
                                                         rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation('ACCRUL', 
                                                         lu_name_, 
                                                         rec_.file_type,
                                                         rec_.description);            
      UPDATE EXT_FILE_TYPE_TAB
         SET description = rec_.description
      WHERE  file_type = rec_.file_type;         
   END IF;
END Insert_Lu_Data_Rec__;   


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Update_View_Name(
   file_type_     IN VARCHAR2,
   view_name_     IN VARCHAR2,
   input_package_ IN VARCHAR2)
IS
BEGIN
   UPDATE ext_file_type_tab
   SET view_name     = view_name_,
       input_package = input_package_
   WHERE file_type = file_type_;
END Update_View_Name;


PROCEDURE Remove_File_Type(
   file_type_  IN VARCHAR2)
IS
BEGIN
   DELETE
   FROM   EXT_FILE_TYPE_TAB
   WHERE  file_type = file_type_;
   Ext_File_Type_Rec_API.Remove_File_Type        ( file_type_ );
   Ext_File_Type_Rec_Column_API.Remove_File_Type ( file_type_ );
   Ext_File_Type_Param_API.Remove_File_Type      ( file_type_ );
   Ext_Type_Param_Per_Set_API.Remove_File_Type   ( file_type_ );
END Remove_File_Type;


PROCEDURE Already_Exist(
   file_type_ IN VARCHAR2)
IS
BEGIN
   IF (Check_Exist___(file_type_)) THEN
      Error_SYS.Appl_General( lu_name_, 'ALREADYEXIST: File Type Already Exist' );
   END IF;
END Already_Exist;


PROCEDURE Insert_Record(
   newrec_     IN Ext_File_Type_Tab%ROWTYPE)
IS
   newrecx_       Ext_File_Type_Tab%ROWTYPE;
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


PROCEDURE Remove_File_Type_Per_Module (
   module_        IN VARCHAR2 )
IS
   CURSOR get_file_types IS
      SELECT file_type
      FROM   ext_file_type_tab
      WHERE  component = UPPER(module_)
      AND   system_defined = 'TRUE';
BEGIN
   FOR file_type_rec IN get_file_types LOOP      
      Remove_File_Type(file_type_rec.file_type);
   END LOOP;
END Remove_File_Type_Per_Module;




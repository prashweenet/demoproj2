-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTypeParam
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020920  PPer  Created
--  100807  Mawelk  Bug 92305 Fixed. Changes to  Insert___()
--  131107  PRatlk PBFI-1872, Refactored according to the new template
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
   Client_SYS.Add_To_Attr( 'BROWSABLE_FIELD', 'FALSE', attr_);
   Client_SYS.Add_To_Attr( 'DATA_TYPE', Exty_Data_Type_API.Decode('1'), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_type_param_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (newrec_.data_type IS NULL) THEN
      newrec_.data_type := '1';
   END IF;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_file_type_param_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_param_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (newrec_.data_type IS NULL) THEN
      newrec_.data_type := '1';
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_type_param_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_param_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.validate_method IS NOT NULL) THEN
      Finance_Lib_API.Is_Method_Available(newrec_.validate_method);
   END IF;
   IF (newrec_.lov_view IS NOT NULL) THEN
      Finance_Lib_API.Is_View_Available(newrec_.lov_view);
   END IF;
   IF (newrec_.enumerate_method IS NOT NULL) THEN
      Finance_Lib_API.Is_Method_Available(newrec_.enumerate_method);
   END IF;   
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_   IN ext_file_type_param_tab%ROWTYPE)
IS
   rec_   ext_file_type_param_tab%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.file_type, rec_.param_no)) THEN
      INSERT INTO ext_file_type_param_tab (
         file_type,
         param_no,
         param_id,
         description,
         lov_view,
         enumerate_method,
         validate_method,
         browsable_field,
         help_text,
         data_type,
         rowversion)
      VALUES (
         newrec_.file_type,
         newrec_.param_no,
         newrec_.param_id,
         newrec_.description,
         newrec_.lov_view,
         newrec_.enumerate_method,
         newrec_.validate_method,
         newrec_.browsable_field,
         newrec_.help_text,
         newrec_.data_type,
         newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.param_no,
                                                          rec_.description);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.param_no || '^' || 'HELP',
                                                          rec_.help_text);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.param_no,
                                                          rec_.description);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.file_type || '^' || rec_.param_no || '^' || 'HELP',
                                                          rec_.help_text);
      UPDATE ext_file_type_param_tab
         SET description = rec_.description,
             help_text   = rec_.help_text
      WHERE  file_type = rec_.file_type
      AND    param_no  = rec_.param_no;         
   END IF;
END Insert_Lu_Data_Rec__;   


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Record(
   newrec_   IN ext_file_type_param_tab%ROWTYPE)
IS
   newrecx_       ext_file_type_param_tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   newrecx_.rowkey := NULL;
   Insert___ (objid_,
              objversion_,
              newrecx_,
              attr_);
END Insert_Record;


PROCEDURE Remove_File_Type(
   file_type_  IN VARCHAR2) 
IS
BEGIN
   DELETE
   FROM ext_file_type_param_tab
   WHERE file_type = file_type_;
END Remove_File_Type;


@UncheckedAccess
FUNCTION Get_Validate_Method (
   file_type_ IN VARCHAR2,
   param_id_  IN VARCHAR2) RETURN VARCHAR2
IS
   temp_   ext_file_type_param_tab.validate_method%TYPE;
   CURSOR get_attr IS
      SELECT REPLACE(REPLACE(validate_method,'(','<'),')','>')
      FROM   ext_file_type_param_tab
      WHERE  file_type = file_type_
      AND    param_id  = param_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Validate_Method;

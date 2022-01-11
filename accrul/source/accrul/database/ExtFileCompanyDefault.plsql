-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileCompanyDefault
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  090605  THPELK   Bug 82609 - Added missing statements for VIEWPCT in UNDEFINE section.
--  100730  MAWELK   Bug 92155 Fixed. Changes to Unpack_Check_Insert___(
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
   Client_SYS.Add_To_Attr( 'USER_ID',       '*',    attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_company_default_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
    
   IF (newrec_.user_id IS NULL) THEN
      newrec_.user_id := '*';
   END IF;
   Ext_File_Template_API.Exist_Valid(newrec_.file_template_id);
   -- Validations moved from the while loop END
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

@Override 
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_company_default_tab%ROWTYPE,
   newrec_ IN OUT ext_file_company_default_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.file_type IS NOT NULL AND newrec_.file_template_id IS NOT NULL AND indrec_.file_template_id) THEN
      Ext_File_Template_API.Exist_Valid_Template(newrec_.file_type, newrec_.file_template_id);
   END IF;
   IF (newrec_.file_type IS NOT NULL AND newrec_.set_id  IS NOT NULL AND indrec_.set_id) THEN
      Ext_Type_Param_Per_Set_API.Exist_Valid_Set_Id(newrec_.file_type, newrec_.set_id);
   END IF;
END Check_Common___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION File_Template_Used (
   file_template_id_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_COMPANY_DEFAULT_TAB
      WHERE file_template_id = file_template_id_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END File_Template_Used;

@UncheckedAccess
FUNCTION Get_File_Type (
   file_type_ IN VARCHAR2,
   company_   IN VARCHAR2,
   user_id_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_COMPANY_DEFAULT_TAB.file_type%TYPE;
   CURSOR get_attr IS
      SELECT file_type
      FROM   EXT_FILE_COMPANY_DEFAULT_TAB
      WHERE  file_type = file_type_
      AND    company   = company_
      AND    user_id   = user_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_File_Type;


@UncheckedAccess
FUNCTION Get_Set_Id_All (
   file_type_ IN VARCHAR2,
   company_   IN VARCHAR2,
   user_id_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_COMPANY_DEFAULT_TAB.set_id%TYPE;
   CURSOR get_attr IS
      SELECT set_id
      FROM   EXT_FILE_COMPANY_DEFAULT_TAB
      WHERE  file_type = file_type_
      AND    company   = NVL(company_,company)
      AND    (user_id  = user_id_
         OR   user_id  = '*')
      ORDER BY DECODE(user_id,'*',1,0);
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Set_Id_All;


@UncheckedAccess
FUNCTION Get_File_Template_Id_All (
   file_type_ IN VARCHAR2,
   company_   IN VARCHAR2,
   user_id_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_COMPANY_DEFAULT_TAB.file_template_id%TYPE;
   CURSOR get_attr IS
      SELECT file_template_id
      FROM   EXT_FILE_COMPANY_DEFAULT_TAB
      WHERE  file_type = file_type_
      AND    company   = company_
      AND    (user_id  = user_id_
         OR   user_id  = '*')
      ORDER BY DECODE(user_id,'*',1,0);
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_File_Template_Id_All;




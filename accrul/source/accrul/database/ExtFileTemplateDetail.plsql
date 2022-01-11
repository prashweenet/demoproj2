-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTemplateDetail
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  040329  Gepelk  2004 SP1 Merge.
--  050714  Hecolk  LCS Merge 50272, Added new Function Get_Text_Column_No
--  050825  Jeguse  Removed Get_Text_Column_No ((functionality is handled by max_length on template details)
--  081002  Jeguse  Bug 77126, Added new views
--  090605  THPELK  Bug 82609 - Added UNDEFINE section and the missing statements for VIEWTREC, VIEWTCOL.
--  121126  MeAlLK  DANU-122, Parallel currency implementation - Added new function Check_Exis
--  131217  Lamalk  PBFI-3747, Modified function 'Copy_File_Function'. Cleared the attribute string to prevent buffer overflow errors.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Convert_String_Evaluate___ (
   file_template_id_ IN VARCHAR2,
   row_no_           IN NUMBER,
   evaluate_         IN VARCHAR2 )
IS
   new_function_        VARCHAR2(50);
   newrecx_             Ext_File_Templ_Det_Func_Tab%ROWTYPE;
BEGIN
   CASE 
      WHEN evaluate_ = '1' THEN
         new_function_ := 'CURRENT_BASE_CURRENCY';
      WHEN evaluate_ = '2' THEN
         new_function_ := 'CURRENT_USER';
      WHEN evaluate_ = '3' THEN
         new_function_ := 'CURRENT_COMPANY';
      WHEN evaluate_ = '4' THEN
         new_function_ := 'CURRENT_DATE_TIME';
      ELSE
         new_function_ := NULL;
   END CASE;
   newrecx_.file_template_id  := file_template_id_;
   newrecx_.row_no            := row_no_;
   newrecx_.function_no       := 1;
   newrecx_.main_function     := new_function_;
   newrecx_.function_argument := NULL;
   newrecx_.rowversion        := SYSDATE;
   Ext_File_Templ_Det_Func_API.Insert_Record (newrecx_);
END Convert_String_Evaluate___;


PROCEDURE Convert_Default_Value___ (
   file_template_id_ IN VARCHAR2,
   row_no_           IN NUMBER,
   default_value_    IN VARCHAR2 )
IS
   newrecx_             Ext_File_Templ_Det_Func_Tab%ROWTYPE;
BEGIN
   newrecx_.file_template_id  := file_template_id_;
   newrecx_.row_no            := row_no_;
   newrecx_.function_no       := 1;
   newrecx_.main_function     := 'SET_DEFAULT_VALUE';
   newrecx_.function_argument := default_value_;
   newrecx_.rowversion        := SYSDATE;
   Ext_File_Templ_Det_Func_API.Insert_Record (newrecx_);
END Convert_Default_Value___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   file_template_id_ VARCHAR2(30);
   file_type_        VARCHAR2(30);
BEGIN
   file_template_id_ := Client_SYS.Get_Item_Value ( 'FILE_TEMPLATE_ID',
                                                    attr_ );
   file_type_        := Ext_File_Template_API.Get_File_Type ( file_template_id_ );
   super(attr_);
   Client_SYS.Add_To_Attr( 'FILE_TYPE', file_type_, attr_ );
   Client_SYS.Add_To_Attr( 'CONTROL_COLUMN', 'FALSE', attr_ );
   Client_SYS.Add_To_Attr( 'HIDE_COLUMN', 'FALSE', attr_ );
END Prepare_Insert___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_template_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_            VARCHAR2(30);
   value_           VARCHAR2(2000);
   default_value_   VARCHAR2(200);
   string_evaluate_ VARCHAR2(1);
BEGIN

   IF(Client_SYS.Item_Exist('DEFAULT_VALUE',attr_)) THEN
      default_value_ := Client_SYS.Cut_Item_Value('DEFAULT_VALUE',attr_);
   END IF;
   IF(Client_SYS.Item_Exist('STRING_EVALUATE_DB',attr_)) THEN
      string_evaluate_ := Client_SYS.Cut_Item_Value('STRING_EVALUATE_DB',attr_);
   END IF;
   IF (newrec_.row_no IS NULL) THEN
      newrec_.row_no := Get_Next_Row_No ( newrec_.file_template_id );
      Client_SYS.Add_To_Attr( 'ROW_NO', newrec_.row_no, attr_ );
   END IF;   
   super(newrec_, indrec_, attr_);  --
   IF ( default_value_ IS NOT NULL ) THEN
      Convert_Default_Value___(newrec_.file_template_id,
                               newrec_.row_no,
                               default_value_);
   ELSIF ( NVL(string_evaluate_,'0') != '0' ) THEN
      Convert_String_Evaluate___(newrec_.file_template_id,
                                 newrec_.row_no,
                                 string_evaluate_);
   END IF;
   --
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_file_template_detail_tab%ROWTYPE,
   newrec_ IN OUT ext_file_template_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
       -- These columns has to be here (compatibility) start
   IF(Client_SYS.Item_Exist('DEFAULT_VALUE',attr_)) THEN
      attr_ := Client_SYS.Remove_Attr('DEFAULT_VALUE',attr_);
   END IF;
   IF(Client_SYS.Item_Exist('STRING_EVALUATE_DB',attr_)) THEN
      attr_ := Client_SYS.Remove_Attr('STRING_EVALUATE_DB',attr_);
       -- These columns has to be here (compatibility) end
   END IF; 
   super(oldrec_, newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Check_Detail_Exist (
   file_template_id_ IN  VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Detail_Exist;


FUNCTION Check_Detail_Exist (
   file_template_id_   IN  VARCHAR2,
   record_type_id_     IN  VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Detail_Tab
      WHERE file_template_id = file_template_id_
      AND   record_type_id   = record_type_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Detail_Exist;


FUNCTION Check_Multi_Record_Type (
   file_template_id_   IN  VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT COUNT(DISTINCT record_type_id)
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      dummy_ := 0;
   END IF;
   CLOSE exist_control;
   IF (dummy_ > 1) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Multi_Record_Type;


PROCEDURE Copy_File_Defintion (
   file_template_id_      IN  VARCHAR2,
   from_file_template_id_ IN  VARCHAR2 )
IS
   newrecx_                   Ext_File_Template_Detail_Tab%ROWTYPE;
   objid_                     VARCHAR2(2000);
   objversion_                VARCHAR2(2000);
   attr_                      VARCHAR2(4000);
   CURSOR detail_ IS
      SELECT *
      FROM   Ext_File_Template_Detail_Tab D
      WHERE  D.file_template_id = from_file_template_id_;
BEGIN
   IF (Check_Detail_Exist ( file_template_id_ ) = 'TRUE') THEN
      Error_SYS.Appl_General( lu_name_, 'FIDCROWS: File definition already contain details, copy is not allowed' );
   ELSE 
      FOR rec_ IN detail_ LOOP
         newrecx_.file_template_id  := file_template_id_;
         newrecx_.row_no            := rec_.row_no;
         newrecx_.record_type_id    := rec_.record_type_id;
         newrecx_.file_type         := rec_.file_type;
         newrecx_.column_id         := rec_.column_id;
         newrecx_.column_no         := rec_.column_no;
         newrecx_.start_position    := rec_.start_position;
         newrecx_.end_position      := rec_.end_position;
         newrecx_.date_format       := rec_.date_format;
         newrecx_.denominator       := rec_.denominator;
         newrecx_.control_column    := rec_.control_column;
         newrecx_.hide_column       := rec_.hide_column;
         newrecx_.column_sort       := rec_.column_sort;
         newrecx_.max_length        := rec_.max_length;
         newrecx_.rowversion        := SYSDATE;
         Insert___ ( objid_,
                     objversion_,
                     newrecx_,
                     attr_ );
         Client_SYS.Clear_Attr(attr_);
      END LOOP;
   END IF;
END Copy_File_Defintion;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Template_Detail_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Template_Detail_Tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   IF (newrecx_.control_column IS NULL) THEN
      newrecx_.control_column := 'FALSE';
   END IF;
   IF (newrecx_.hide_column IS NULL) THEN
      newrecx_.hide_column := 'FALSE';
   END IF;
   newrecx_.rowkey := NULL;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END Insert_Record;


FUNCTION Display_Detail_Function (
   file_template_id_ IN VARCHAR2,
   row_no_           IN NUMBER ) RETURN VARCHAR2
IS
   count_               NUMBER         := 0;
   return_value_        VARCHAR2(2000);
   main_function_       VARCHAR2(30);
   function_argument_   VARCHAR2(2000) := NULL;
   CURSOR get_count IS
      SELECT count(*)
      FROM   ext_file_templ_det_func_tab
      WHERE  file_template_id = file_template_id_
      AND    row_no           = row_no_;
   CURSOR get_details IS
      SELECT main_function, 
             function_argument
      FROM   ext_file_templ_det_func_tab
      WHERE  file_template_id = file_template_id_
      AND    row_no           = row_no_
      ORDER BY function_no;
BEGIN
   OPEN  get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
   IF ( count_ = 0 ) THEN
      return_value_ := NULL;
   ELSE
      IF ( count_ > 1 ) THEN
         return_value_ := '* ';
      END IF;
      OPEN  get_details;
      FETCH get_details INTO main_function_, 
                             function_argument_;
      CLOSE get_details;
      return_value_ := return_value_ || main_function_ || ' : ' || function_argument_;
   END IF;
   RETURN return_value_;
END Display_Detail_Function;


PROCEDURE Remove_Template (
   file_template_id_  IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM EXT_FILE_TEMPLATE_DETAIL_TAB
   WHERE file_template_id = file_template_id_;
END Remove_Template;


@UncheckedAccess
FUNCTION Get_Next_Row_No (
   file_template_id_ IN  VARCHAR2 ) RETURN NUMBER
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT MAX(row_no)
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      dummy_ := NVL(dummy_,0) + 1;
   ELSE
      dummy_ := 1;
   END IF;
   CLOSE exist_control;
   RETURN(dummy_);
END Get_Next_Row_No;


@UncheckedAccess
FUNCTION Check_Exist (
   file_template_id_ IN VARCHAR2,
   row_no_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(file_template_id_, row_no_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist;




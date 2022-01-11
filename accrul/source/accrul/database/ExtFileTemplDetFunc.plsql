-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTemplDetFunc
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  070123  Gadalk  LCS Merge 60420.
--  130902  MAWELK  Bug 111219 Fixed
--  131217  Lamalk  PBFI-3747, Modified function 'Copy_File_Function'. Cleared the attribute string to prevent buffer overflow errors.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_templ_det_func_tab%ROWTYPE,
   newrec_ IN OUT ext_file_templ_det_func_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   templ_det_rec_ External_File_Utility_API.ft_m_det_rec;
BEGIN
   attr_:= Client_SYS.Remove_Attr('FILE_TYPE',attr_);
   super(oldrec_, newrec_, indrec_, attr_);
   templ_det_rec_.load_file_id := 0;
   Ext_File_Argument_Handler_API.Validate_Fkn_Synthax(newrec_.main_function,
                                                      newrec_.function_argument,
                                                      templ_det_rec_);
END Check_Common___;




-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Copy_File_Function (
   file_template_id_      IN  VARCHAR2,
   from_file_template_id_ IN  VARCHAR2 )
IS
   newrecx_                   ext_file_templ_det_func_tab%ROWTYPE;
   objid_                     VARCHAR2(2000);
   objversion_                VARCHAR2(2000);
   attr_                      VARCHAR2(2000);
   CURSOR detail_ IS
      SELECT *
      FROM   ext_file_templ_det_func_tab D
      WHERE  D.file_template_id = from_file_template_id_;
BEGIN
   FOR rec_ IN detail_ LOOP 
      newrecx_.file_template_id  := file_template_id_;
      newrecx_.row_no            := rec_.row_no;
      newrecx_.function_no       := rec_.function_no;
      newrecx_.function_argument := rec_.function_argument;
      newrecx_.main_function     := rec_.main_function;
      newrecx_.rowversion        := SYSDATE;
      Insert___ ( objid_,
                  objversion_,
                  newrecx_,
                  attr_ );
      Client_SYS.Clear_Attr(attr_);
   END LOOP;
END Copy_File_Function;


PROCEDURE Copy_File_Col_Function (
   file_template_id_    IN VARCHAR2,
   record_type_id_      IN VARCHAR2,
   column_id_           IN VARCHAR2,
   from_record_type_id_ IN VARCHAR2,
   from_column_id_      IN VARCHAR2 )
IS
   from_row_no_            NUMBER;
   to_row_no_              NUMBER;
   newrecx_                ext_file_templ_det_func_tab%ROWTYPE;
   objid_                  VARCHAR2(2000);
   objversion_             VARCHAR2(2000);
   attr_                   VARCHAR2(2000);

   CURSOR get_row_no (record_type_id_ IN VARCHAR2) IS
      SELECT row_no
      FROM   ext_file_template_detail_tab
      WHERE  file_template_id = file_template_id_
      AND    record_type_id   = record_type_id_ ;
      
   CURSOR detail_ IS
      SELECT *
      FROM   ext_file_templ_det_func_tab D
      WHERE  D.file_template_id = file_template_id_
      AND    D.row_no           = from_row_no_;
BEGIN
   OPEN  get_row_no (from_record_type_id_);
   FETCH get_row_no INTO from_row_no_;
   CLOSE get_row_no;
   OPEN  get_row_no (record_type_id_);
   FETCH get_row_no INTO to_row_no_;
   CLOSE get_row_no;
   --
   FOR rec_ IN detail_ LOOP 
      newrecx_.file_template_id  := file_template_id_;
      newrecx_.row_no            := to_row_no_;
      newrecx_.function_no       := rec_.function_no;
      newrecx_.function_argument := rec_.function_argument;
      newrecx_.main_function     := rec_.main_function;
      newrecx_.rowversion        := SYSDATE;
      Insert___ ( objid_,
                  objversion_,
                  newrecx_,
                  attr_ );
      Client_SYS.Clear_Attr(attr_);
   END LOOP;
END Copy_File_Col_Function;


PROCEDURE Remove_Template (
   file_template_id_  IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM EXT_FILE_TEMPL_DET_FUNC_TAB
   WHERE file_template_id = file_template_id_;
END Remove_Template;


PROCEDURE Remove_Template_Row (
   file_template_id_  IN VARCHAR2,
   row_no_            IN NUMBER )
IS
BEGIN
   DELETE
   FROM EXT_FILE_TEMPL_DET_FUNC_TAB
   WHERE file_template_id = file_template_id_
   AND   row_no           = row_no_;
END Remove_Template_Row;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Templ_Det_Func_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Templ_Det_Func_Tab%ROWTYPE;
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




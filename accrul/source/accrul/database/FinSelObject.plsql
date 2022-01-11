-----------------------------------------------------------------------------
--
--  Logical unit: FinSelObject
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

separator_  CONSTANT VARCHAR2(1)  := Client_SYS.field_separator_;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Lov_Ref___(
   newrec_              IN FIN_SEL_OBJECT_TAB%ROWTYPE)
IS
   view_       VARCHAR2(30);
   index_      NUMBER := 0;
   index2_     NUMBER := 0;
   col_list_   VARCHAR2(200);
   col_name_   VARCHAR2(30);
BEGIN
   -- Validate LoV Reference attribute except for dynamic sources.
   IF ( (newrec_.lov_reference IS NOT NULL) AND (newrec_.dynamic_lov_dependency = 'FALSE') ) THEN
      index_ := Instr(newrec_.lov_reference, '(');
      IF (index_ > 0) THEN
         -- Extract the view
         view_ := Substr(newrec_.lov_reference, 1, index_-1);
         index2_ := Instr(newrec_.lov_reference, ')');
         IF (index2_ > 0) THEN
            col_list_ := LTRIM(RTRIM(Substr(newrec_.lov_reference, index_+1, index2_ - (index_+1)) ));
         ELSE
            -- IF a left parentheses exist then a right parentheses must exist.
            Error_SYS.Appl_General(lu_name_, 'ERRFORMAT: Incorrect format on field LOV_REFERENCE: :P1', newrec_.lov_reference);
         END IF;

         Assert_SYS.Assert_Is_View(view_);

         index_ := Instr(col_list_, ',');
         WHILE (index_ > 0) LOOP
            col_name_ := LTRIM(RTRIM(Substr(col_list_, 1, index_-1)));
            Assert_SYS.Assert_Is_View_Column(view_, col_name_);

            col_list_ := LTRIM(RTRIM(Substr(col_list_, index_)));
            index_ := Instr(col_list_, ',');
         END LOOP;
         -- any values left in the col_list_, should be a column.
         IF (col_list_ IS NOT NULL) THEN
            Assert_SYS.Assert_Is_View_Column(view_, col_list_);
         END IF;
      ELSE
         view_ := LTRIM(RTRIM(newrec_.lov_reference));
         Assert_SYS.Assert_Is_View(view_);
      END IF;
      IF (newrec_.object_col_id IS NOT NULL) THEN
         Assert_SYS.Assert_Is_View_Column(view_, newrec_.object_col_id);
      END IF;
      IF (newrec_.object_col_desc IS NOT NULL) THEN
         Assert_SYS.Assert_Is_View_Column(view_, newrec_.object_col_desc);
      END IF;
   END IF;
END Validate_Lov_Ref___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('DYNAMIC_LOV_DEPENDENCY', Fnd_Boolean_API.Decode('FALSE'), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT FIN_SEL_OBJECT_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   -- Code parts will use company translation support, no need to call BDT
   IF (newrec_.is_code_part = 'FALSE') THEN
      Basic_Data_Translation_API.Insert_Basic_Data_Translation(newrec_.module,
                                                               newrec_.lu,
                                                               newrec_.selection_object_id,
                                                               NULL,
                                                               newrec_.description);
   END IF;
   Fin_Selection_Templ_Util_API.Register_Sel_Object_To_Form_(newrec_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     FIN_SEL_OBJECT_TAB%ROWTYPE,
   newrec_     IN OUT FIN_SEL_OBJECT_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   IF (newrec_.is_code_part = 'FALSE') THEN
      Basic_Data_Translation_API.Insert_Basic_Data_Translation(newrec_.module,
                                                               newrec_.lu,
                                                               newrec_.selection_object_id,
                                                               NULL,
                                                               newrec_.description,
                                                               oldrec_.description);
   END IF;
   Fin_Selection_Templ_Util_API.Register_Sel_Object_To_Form_(newrec_);
END Update___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN FIN_SEL_OBJECT_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   IF (remrec_.is_code_part = 'FALSE') THEN
      Basic_Data_Translation_API.Remove_Basic_Data_Translation(remrec_.module,
                                                               remrec_.lu,
                                                               remrec_.selection_object_id);
   END IF;                                                                
END Delete___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     fin_sel_object_tab%ROWTYPE,
   newrec_ IN OUT fin_sel_object_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
   Validate_Lov_Ref___(newrec_);
END Check_Common___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   insrec_        IN FIN_SEL_OBJECT_TAB%ROWTYPE)
IS
   oldrec_     FIN_SEL_OBJECT_TAB%ROWTYPE;
   newrec_     FIN_SEL_OBJECT_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      VARCHAR2(30);
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN
   IF (NOT Check_Exist___(insrec_.selection_object_id)) THEN
      newrec_ := insrec_;
      indrec_ := Get_Indicator_Rec___(newrec_);      
      Check_Insert___(newrec_, indrec_, attr_);
      
      IF (newrec_.is_code_part = 'FALSE') THEN
         Basic_Data_Translation_API.Insert_Prog_Translation( newrec_.module,
                                                             newrec_.lu,
                                                             newrec_.selection_object_id,
                                                             newrec_.description);
      END IF;
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(insrec_.selection_object_id);
      newrec_ := oldrec_;
      attr_ := Pack___(insrec_);
      Unpack___(newrec_, indrec_, attr_);
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);

      IF (newrec_.is_code_part = 'FALSE') THEN
         Basic_Data_Translation_API.Insert_Prog_Translation(newrec_.module,
                                                            newrec_.lu,
                                                            newrec_.selection_object_id,
                                                            newrec_.description);
      END IF;
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Insert_Lu_Data_Rec__;


@UncheckedAccess
FUNCTION Get_Comp_Sel_Obj_Desc__ (
   company_             IN VARCHAR2,
   selection_object_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ FIN_SEL_OBJECT.description%TYPE;
   CURSOR get_attr IS
      SELECT description
      FROM FIN_SEL_OBJECT_COMPANY
      WHERE company = company_
      AND   selection_object_id = selection_object_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Comp_Sel_Obj_Desc__;


@UncheckedAccess
FUNCTION Get_Selection_Object_Data__ (
   selection_object_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   public_rec_    Public_rec;
BEGIN
   public_rec_ := Get(selection_object_id_);
   RETURN public_rec_.data_type || '^' || public_rec_.lov_reference || '^' || public_rec_.zoom_window || 
      '^' || public_rec_.zoom_window_col_key || '^' || public_rec_.zoom_window_parent_col_key || 
      '^' || public_rec_.object_col_id || '^' || '^' || public_rec_.object_col_desc || '^' || public_rec_.manual_input;
END Get_Selection_Object_Data__;


@UncheckedAccess
FUNCTION Is_Valid_Object__ (
   company_             IN VARCHAR2,
   selection_object_id_ IN VARCHAR2,
   is_code_part_        IN VARCHAR2,
   code_part_           IN VARCHAR2 ) RETURN VARCHAR2
IS
   pos_           NUMBER;
   blocked_       VARCHAR2(50);
   proj_codepart_ VARCHAR2(1);
BEGIN
   IF (is_code_part_ = 'TRUE' AND code_part_ != 'CODE_A') OR selection_object_id_ = 'PROJ_ACTIVITY_SEQ_NO' THEN
      blocked_ := Accounting_Code_Parts_API.Get_Blocked_Code_Parts(company_);
      IF code_part_ = 'CODE_B' THEN
         pos_ := 1;
      ELSIF code_part_ = 'CODE_C' THEN
         pos_ := 2;
      ELSIF code_part_ = 'CODE_D' THEN
         pos_ := 3;
      ELSIF code_part_ = 'CODE_E' THEN
         pos_ := 4;
      ELSIF code_part_ = 'CODE_F' THEN
         pos_ := 5;
      ELSIF code_part_ = 'CODE_G' THEN
         pos_ := 6;
      ELSIF code_part_ = 'CODE_H' THEN
         pos_ := 7;
      ELSIF code_part_ = 'CODE_I' THEN
         pos_ := 8;
      ELSIF code_part_ = 'CODE_J' THEN
         pos_ := 9;
      ELSIF selection_object_id_ = 'PROJ_ACTIVITY_SEQ_NO' THEN
         proj_codepart_ := Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_, 'PRACC');
         IF proj_codepart_ = 'B' THEN
            pos_ := 1;
         ELSIF proj_codepart_ = 'C' THEN
            pos_ := 2;
         ELSIF proj_codepart_ = 'D' THEN
            pos_ := 3;
         ELSIF proj_codepart_ = 'E' THEN
            pos_ := 4;
         ELSIF proj_codepart_ = 'F' THEN
            pos_ := 5;
         ELSIF proj_codepart_ = 'G' THEN
            pos_ := 6;
         ELSIF proj_codepart_ = 'H' THEN
            pos_ := 7;
         ELSIF proj_codepart_ = 'I' THEN
            pos_ := 8;
         ELSIF proj_codepart_ = 'J' THEN
            pos_ := 9;
         END IF;
      END IF;

      IF (substr(blocked_,pos_,1) = 'Y') THEN
         RETURN 'TRUE';
      ELSE
         RETURN 'FALSE';
      END IF;
   ELSE
      RETURN 'TRUE';
   END IF;
END Is_Valid_Object__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@Override
@UncheckedAccess
FUNCTION Get_Description (
   selection_object_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ FIN_SEL_OBJECT_TAB.description%TYPE;
  
   CURSOR get_view_desc IS 
      SELECT description
      FROM    FIN_SEL_OBJECT
      WHERE selection_object_id = selection_object_id_;
BEGIN
   OPEN get_view_desc;
   FETCH get_view_desc INTO temp_;
   CLOSE get_view_desc;
   IF (temp_ IS NOT NULL) THEN
      RETURN temp_;
   END IF;   
   RETURN super(selection_object_id_);
END Get_Description;


@UncheckedAccess
FUNCTION Get_Description (
   company_             IN VARCHAR2,
   selection_object_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ FIN_SEL_OBJECT.description%TYPE;
   CURSOR get_attr IS
      SELECT description
      FROM FIN_SEL_OBJECT_COMPANY
      WHERE company = company_
        AND selection_object_id = selection_object_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Description;


@UncheckedAccess
FUNCTION Encode_Object (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   description_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_   FIN_SEL_OBJECT_TAB.selection_object_id%TYPE;

   CURSOR get_object IS
      SELECT selection_object_id
      FROM FIN_SEL_OBJECT_COMPANY
      WHERE company = company_
      AND object_group_id = object_group_id_
      AND description = description_;
BEGIN
   OPEN  get_object;
   FETCH get_object INTO temp_;
   CLOSE get_object;
   RETURN temp_;
END Encode_Object;


@UncheckedAccess
FUNCTION Decode_Object(
   company_             IN VARCHAR2,
   object_group_id_     IN VARCHAR2,
   selection_object_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ fin_sel_object.description%TYPE;
   CURSOR get_attr IS
      SELECT description
      FROM   fin_sel_object_company
      WHERE  company = company_
      AND    object_group_id = object_group_id_
      AND    selection_object_id = selection_object_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Decode_Object;


@UncheckedAccess
PROCEDURE Enumerate(
   client_values_   OUT VARCHAR2,
   company_         IN VARCHAR2,
   object_group_id_ IN VARCHAR2)
IS
   CURSOR get_object IS
      SELECT *
      FROM   fin_sel_object_company
      WHERE  company         = company_
      AND    object_group_id = object_group_id_
      ORDER BY sort_order;
BEGIN
   FOR rec_ IN get_object LOOP
      IF Is_Valid_Object__ (company_, rec_.selection_object_id, rec_.is_code_part, rec_.code_part) = 'TRUE' THEN
         client_values_ := client_values_ || rec_.description || separator_;
      END IF;
   END LOOP;
END Enumerate;


PROCEDURE Validate_Selection_Object(
   company_             IN VARCHAR2,
   selection_object_id_ IN VARCHAR2)
IS
   sorec_   Public_Rec;
BEGIN
   Fin_Sel_Object_API.Exist(selection_object_id_);
   sorec_ := Get(selection_object_id_);
   IF Fin_Sel_Object_API.Is_Valid_Object__(company_, selection_object_id_, sorec_.is_code_part, sorec_.code_part) = 'FALSE' THEN
      Error_SYS.Record_General(lu_name_, 'NOTVALIDSO: Selection Object :P1 is not allowed for company :P2', selection_object_id_, company_);
   END IF;
END Validate_Selection_Object;

FUNCTION Get_Sel_Obj_Value_Description(
   selection_object_id_   IN VARCHAR2,
   value_                 IN VARCHAR2,
   company_               IN VARCHAR2) RETURN VARCHAR2
IS
   use_company_      VARCHAR2(5) := 'FALSE';
   stmt_             VARCHAR2(2000);
   description_      VARCHAR2(4000);
   lov_reference_    fin_sel_object_tab.lov_reference%TYPE;
   column_id_        fin_sel_object_tab.object_col_id%TYPE;
   column_desc_      fin_sel_object_tab.object_col_desc%TYPE;   
   TYPE RecordType   IS REF CURSOR;
   cur_              RecordType;
BEGIN   
   lov_reference_    := Fin_Sel_Object_API.Get_Lov_Reference(selection_object_id_);
   column_id_        := Fin_Sel_Object_API.Get_Object_Col_Id(selection_object_id_);
   column_desc_      := NVL(Fin_Sel_Object_API.Get_Object_Col_Desc (selection_object_id_), column_id_);
   IF (INSTR(lov_reference_, '(COMPANY)') > 0) THEN
      lov_reference_ := SUBSTR(lov_reference_, 0, INSTR(lov_reference_, '(COMPANY)') - 1);
      use_company_   := 'TRUE';
   END IF;

   stmt_ := '  WITH bind_variables AS (
                  SELECT :company               AS company_value,
                         :value                 AS value
                  FROM DUAL )
               SELECT ' || column_desc_ || ' FROM ' || lov_reference_ || ', bind_variables';      
   IF (use_company_ = 'TRUE') THEN
      stmt_ := stmt_ || ' WHERE COMPANY = company_value AND ' || column_id_ ||  ' = value';
   ELSE
      stmt_ := stmt_ || ' WHERE ' || column_id_ || ' = value';
   END IF;

   @ApproveDynamicStatement(2019-05-21,samllk)
   OPEN cur_ FOR stmt_ USING company_, value_;
   LOOP
      FETCH cur_ INTO description_;
      EXIT WHEN cur_%NOTFOUND;
   END LOOP;
   CLOSE cur_;
   RETURN description_;   
END Get_Sel_Obj_Value_Description;

FUNCTION Get_Sel_Obj_Value_Status (
   selection_object_id_ IN VARCHAR2,
   value_               IN VARCHAR2,
   company_             IN VARCHAR2)  RETURN VARCHAR2
IS
   description_   VARCHAR2(200); 
   status_        VARCHAR2(100);
BEGIN
   description_ := Get_Sel_Obj_Value_Description(selection_object_id_, value_, company_); 
   IF (description_ IS NOT NULL) THEN
      status_ := Language_SYS.Translate_Constant(lu_name_, 'EXIST: Exist');
   ELSE
      status_ := Language_SYS.Translate_Constant(lu_name_, 'NOEXIST: Not exist');
   END IF;
   RETURN status_;   
END Get_Sel_Obj_Value_Status;

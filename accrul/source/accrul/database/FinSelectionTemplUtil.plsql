-----------------------------------------------------------------------------
--
--  Logical unit: FinSelectionTemplUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  101129  OVJOSE   Created
--  110126  Umdolk   EAPM-13570, Corrected upgrade errors.
--  110528  THPELK   EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110725  SALIDE   EDEL-62. Modified Set_Bind_Variable()
--  120201  SALIDE   SFI-2062. Modified Parse_Parameter() with NUMBER parameter
--  120530  MACHLK   Bug 102933. Possibilty to include installments stamped with direct debiting 
--  121023  WAUDLK   Bug 106065, Added assert safe comment and changed the Get_Sel_Object_Values to add bind variable.
--    121204   Maaylk   PEPA-183, Removed global variable
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

date_format_ CONSTANT VARCHAR2(20) := 'YYYY-MM-DD';
TYPE arr_varchar IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
TYPE bind_rec IS RECORD
   (bind_name           VARCHAR2(2000),
    bind_value          arr_varchar );
TYPE arr_bind IS TABLE OF bind_rec INDEX BY VARCHAR2(100);
TYPE obj_sel_rec IS RECORD
   (selection           VARCHAR2(32000),
    bind_variable       VARCHAR2(32000),
    bind_value          arr_varchar );
TYPE arr_selection IS TABLE OF obj_sel_rec INDEX BY VARCHAR2(100);
TYPE templ_rec IS RECORD
   (selection_object    VARCHAR2(100),
    operator_db         VARCHAR2(20),
    operator            VARCHAR2(200),
    from_value          VARCHAR2(2000),
    to_value            VARCHAR2(2000),
    from_value_date     DATE,
    to_value_date       DATE);
TYPE templ_rec_tab IS TABLE OF templ_rec INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Parse_Parameter___ (
   column_    IN VARCHAR2,
   parameter_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   from_       NUMBER;
   to_         NUMBER;
   pos_        NUMBER;
   pos1_       NUMBER;
   value_      VARCHAR2(500);
   from_value_ VARCHAR2(500);
   to_value_   VARCHAR2(500);
   parm_list_  VARCHAR2(32000);
   valid_      VARCHAR2(5);
BEGIN
   IF (parameter_ IS NULL) THEN
      RETURN ('TRUE');
   ELSE
      parm_list_ := parameter_ || ';';
   END IF;
   from_ := 1;
   to_ := instr(parm_list_, ';', from_);
   valid_ := 'FALSE';
   WHILE (to_ > 0) LOOP
      value_ := ltrim(rtrim(substr(parm_list_, from_, to_ - from_)));
      pos_  := instr(value_, '!..');
      pos1_ := instr(value_, '..');
      IF (pos_ > 0) THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            RETURN ('ERROR');
         ELSE
            from_value_ := substr(value_, 1, pos_ - 1);
            to_value_ := substr(value_, pos_ + 3);
            IF (from_value_ <= to_value_) THEN
               IF (column_ NOT BETWEEN from_value_ AND to_value_) THEN
                  RETURN ('TRUE');
               END IF;
            ELSE
               IF (column_ NOT BETWEEN to_value_ AND from_value_) THEN
                  RETURN ('TRUE');
               END IF;
            END IF;
         END IF;
      ELSIF (pos1_ > 0) THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            RETURN ('ERROR');
         ELSE
            from_value_ := substr(value_, 1, pos1_ - 1);
            to_value_ := substr(value_, pos1_ + 2);
            IF (from_value_ <= to_value_) THEN
               IF (column_ BETWEEN from_value_ AND to_value_) THEN
                  RETURN ('TRUE');
               END IF;
            ELSE
               IF (column_ BETWEEN to_value_ AND from_value_) THEN
                  RETURN ('TRUE');
               END IF;
            END IF;
         END IF;
      ELSIF (substr(value_, 1, 2) = '<=') THEN
         IF (column_ <= ltrim(substr(value_,3))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 2) = '>=') THEN
         IF (column_ >= ltrim(substr(value_,3))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 2) = '!=') THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            IF (column_ LIKE ltrim(substr(value_,3))) THEN
               RETURN ('FALSE');
            END IF;
         ELSE
            IF (column_ = ltrim(substr(value_,3))) THEN
               RETURN ('FALSE');
            END IF;
         END IF;
         valid_ := 'TRUE';
      ELSIF (substr(value_, 1, 1) = '<') THEN
         IF (column_ < ltrim(substr(value_,2))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 1) = '>') THEN
         IF (column_ > ltrim(substr(value_,2))) THEN
            RETURN ('TRUE');
         END IF;
      ELSE
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            IF (column_ LIKE value_) THEN
               RETURN ('TRUE');
            END IF;
         ELSE
            IF (column_ = value_) THEN
               RETURN ('TRUE');
            END IF;
         END IF;
      END IF;
      from_ := to_ + 1;
      to_ := instr(parm_list_, ';', from_);
   END LOOP;
   RETURN valid_;
EXCEPTION
   WHEN OTHERS THEN
      RETURN ('ERROR');
END Parse_Parameter___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Register_Sel_Object_To_Form_ (
   rec_        IN    FIN_SEL_OBJECT_TAB%ROWTYPE)
IS
   lov_view_         VARCHAR2(30);
   index_            NUMBER;
BEGIN

   IF (rec_.lov_reference IS NOT NULL) THEN
      index_ := Instr(rec_.lov_reference, '(');
      IF (index_ > 0 ) THEN
         lov_view_ := Substr(rec_.lov_reference, 1, index_-1);
      ELSE
         lov_view_ := rec_.lov_reference;
      END IF;
      -- Register the lov views to these different forms in the application
      -- to be able to give the user access to the view in the client.
      Pres_Object_Util_API.New_Pres_Object_Sec('globalACCRUL',
                                               lov_view_,
                                               'VIEW',
                                               '5',      --LOV View
                                               'Manual');

      Pres_Object_Util_API.New_Pres_Object_Sec('dlgSelectionIncludeExclude',
                                               lov_view_,
                                               'VIEW',
                                               '4',      -- VIEW
                                               'Manual');

      Pres_Object_Util_API.New_Pres_Object_Sec('dlgSelectionInclExclAdv',
                                               lov_view_,
                                               'VIEW',
                                               '4',      -- VIEW
                                               'Manual');
   END IF;
END Register_Sel_Object_To_Form_;

@Deprecated
PROCEDURE Register_Rep_Sel_Data_ (
   rec_        IN    fin_obj_grp_sel_object_tab%ROWTYPE)
IS
   lov_view_         VARCHAR2(30);
   index_            NUMBER;
   pub_rec_          Fin_Sel_Object_API.Public_Rec;

   CURSOR get_objects IS
      SELECT object_id
      FROM Fin_Obj_Grp_Object
      WHERE object_group_id = rec_.object_group_id;
BEGIN

   pub_rec_ := Fin_Sel_Object_API.Get(rec_.selection_object_id);

   IF (pub_rec_.lov_reference IS NOT NULL) THEN
      index_ := Instr(pub_rec_.lov_reference, '(');
      IF (index_ > 0 ) THEN
         lov_view_ := Substr(pub_rec_.lov_reference, 1, index_-1);
      ELSE
         lov_view_ := pub_rec_.lov_reference;
      END IF;
      FOR objrec_ IN get_objects LOOP
         IF Fin_Object_API.Get_Object_Type_Db(objrec_.object_id) = 'REPORT' THEN
            Pres_Object_Util_API.New_Pres_Object_Sec('rep'||objrec_.object_id,
                                                     lov_view_,
                                                     'VIEW',
                                                     '5',
                                                     'Manual');
         END IF;
      END LOOP;
   END IF;
END Register_Rep_Sel_Data_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Codeparts_Ok (
   codestring_          IN VARCHAR2,
   code_part_selection_ IN arr_selection ) RETURN BOOLEAN
IS
   code_part_         VARCHAR2(30);
   code_part_value_   VARCHAR2(20);
BEGIN
   FOR i_ IN 65..74  LOOP
      IF (i_ = 75) THEN
         code_part_ := 'PROJECT_ACTIVITY_ID';
         $IF Component_Invoic_SYS.INSTALLED $THEN
            code_part_value_ := Invoice_Code_String_API.Decode(codestring_, code_part_);
         $END
      ELSE
         code_part_       := CHR(i_);
         $IF Component_Invoic_SYS.INSTALLED $THEN
            code_part_value_ := Invoice_Code_String_API.Decode(codestring_, code_part_);
         $END
         code_part_       := 'CODE_' || code_part_;
      END IF;

      IF code_part_selection_(code_part_).selection IS NOT NULL THEN
         IF (code_part_value_ IS NULL) THEN
            RETURN FALSE;
         END IF;
         IF (Fin_Selection_Templ_Util_API.Parse_Parameter( code_part_value_, 
                                                         code_part_selection_(code_part_).selection) = 'FALSE') THEN 
            RETURN FALSE; 
         END IF; 
      END IF;
   END LOOP;    
   RETURN TRUE;
END Codeparts_Ok;



-- Parse_Parameter
--   Compare the single value against Selection Object values
--   e.g. Parses_Parameters('CUST01', 'CUST03;CUST04')
@UncheckedAccess
FUNCTION Parse_Parameter (
   column_    IN VARCHAR2,
   parameter_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Parse_Parameter___(column_, parameter_);
END Parse_Parameter;



-- Parse_Parameter
--   Compare the single value against Selection Object values
--   e.g. Parses_Parameters('CUST01', 'CUST03;CUST04')
@UncheckedAccess
FUNCTION Parse_Parameter (
   column_    IN NUMBER,
   parameter_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   from_       NUMBER;
   to_         NUMBER;
   pos_        NUMBER;
   pos1_       NUMBER;
   value_      VARCHAR2(500);
   from_value_ VARCHAR2(500);
   to_value_   VARCHAR2(500);
   parm_list_  VARCHAR2(32000);
   valid_      VARCHAR2(5);
BEGIN
   IF (parameter_ IS NULL) THEN
      RETURN ('TRUE');
   ELSE
      parm_list_ := parameter_ || ';';
   END IF;
   from_ := 1;
   to_ := instr(parm_list_, ';', from_);
   valid_ := 'FALSE';
   WHILE (to_ > 0) LOOP
      value_ := ltrim(rtrim(substr(parm_list_, from_, to_ - from_)));
      pos_  := instr(value_, '!..');
      pos1_ := instr(value_, '..');
      IF (pos_ > 0) THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            RETURN ('ERROR');
         ELSE
            from_value_ := substr(value_, 1, pos_ - 1);
            to_value_ := substr(value_, pos_ + 3);
            IF (to_number(from_value_) <= to_number(to_value_)) THEN
               IF (column_ NOT BETWEEN to_number(from_value_) AND to_number(to_value_)) THEN
                  RETURN ('TRUE');
               END IF;
            ELSE
               IF (column_ NOT BETWEEN to_number(to_value_) AND to_number(from_value_)) THEN
                  RETURN ('TRUE');
               END IF;
            END IF;
         END IF;
      ELSIF (pos1_ > 0) THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            RETURN ('ERROR');
         ELSE
            from_value_ := substr(value_, 1, pos1_ - 1);
            to_value_ := substr(value_, pos1_ + 2);
            IF (to_number(from_value_) <= to_number(to_value_)) THEN
               IF (column_ BETWEEN to_number(from_value_) AND to_number(to_value_)) THEN
                  RETURN ('TRUE');
               END IF;
            ELSE
               IF (column_ BETWEEN to_number(to_value_) AND to_number(from_value_)) THEN
                  RETURN ('TRUE');
               END IF;
            END IF;
         END IF;
      ELSIF (substr(value_, 1, 2) = '<=') THEN
         IF (column_ <= to_number(ltrim(substr(value_,3)))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 2) = '>=') THEN
         IF (column_ >= to_number(ltrim(substr(value_,3)))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 2) = '!=') THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            IF (column_ LIKE ltrim(substr(value_,3))) THEN
               RETURN ('FALSE');
            END IF;
         ELSE
            IF (column_ = to_number(ltrim(substr(value_,3)))) THEN
               RETURN ('FALSE');
            END IF;
         END IF;
         valid_ := 'TRUE';
      ELSIF (substr(value_, 1, 1) = '<') THEN
         IF (column_ < to_number(ltrim(substr(value_,2)))) THEN
            RETURN ('TRUE');
         END IF;
      ELSIF (substr(value_, 1, 1) = '>') THEN
         IF (column_ > to_number(ltrim(substr(value_,2)))) THEN
            RETURN ('TRUE');
         END IF;
      ELSE
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            IF (column_ LIKE value_) THEN
               RETURN ('TRUE');
            END IF;
         ELSE
            IF (column_ = to_number(value_)) THEN
               RETURN ('TRUE');
            END IF;
         END IF;
      END IF;
      from_ := to_ + 1;
      to_ := instr(parm_list_, ';', from_);
   END LOOP;
   RETURN valid_;
END Parse_Parameter;



-- Parse_Parameter
--   Compare the single value against Selection Object values
--   e.g. Parses_Parameters('CUST01', 'CUST03;CUST04')
@UncheckedAccess
FUNCTION Parse_Parameter (
   column_    IN DATE,
   parameter_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN Parse_Parameter___(to_char(column_,date_format_), parameter_);
END Parse_Parameter;



-- Parse_Parameters
--   Compare the multiple values against Selection Object values
--   e.g. Parses_Parameters('CUST01;CUST02;CUST03', 'CUST03;CUST04')
@UncheckedAccess
FUNCTION Parse_Parameters (
   columns_   IN VARCHAR2,
   parameter_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   from_       NUMBER;
   to_         NUMBER;
   value_      VARCHAR2(100);
   value_list_ VARCHAR2(2000);
BEGIN
   value_list_ := columns_ || ';';
   from_ := 1;
   to_ := instr(value_list_, ';', from_);
   WHILE (to_ > 0) LOOP
      value_ := ltrim(rtrim(substr(value_list_, from_, to_ - from_)));
      IF Parse_Parameter(value_, parameter_) = 'TRUE' THEN
         RETURN 'TRUE';
      END IF;
      from_ := to_ + 1;
      to_ := instr(value_list_, ';', from_);
   END LOOP;
   RETURN 'FALSE';
END Parse_Parameters;



@UncheckedAccess
FUNCTION Get_Sel_Object_Values (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_     IN NUMBER,
   sel_object_id_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   stmt_             VARCHAR2(2000);
   where_            VARCHAR2(2000);
   value_            VARCHAR2(2000);
   view_             VARCHAR2(100);
   obj_value_        VARCHAR2(100);
   company_def_      BOOLEAN;
   TYPE RecordType   IS REF CURSOR;
   get_obj_          RecordType;

   CURSOR get_sel_obj IS
      SELECT *
        FROM fin_sel_object_tab
       WHERE selection_object_id = sel_object_id_;
   selobj_rec_ get_sel_obj%ROWTYPE;

   CURSOR get_advanced IS
      SELECT *
        FROM fin_object_selection_tab
       WHERE company             = company_
         AND object_group_id     = object_group_id_
         AND object_id           = object_id_
         AND selection_id        = selection_id_
         AND selection_object_id = sel_object_id_;

   CURSOR get_values(item_id_ NUMBER) IS
      SELECT *
        FROM fin_obj_selection_values_tab
       WHERE company         = company_
         AND object_group_id = object_group_id_
         AND object_id       = object_id_
         AND selection_id    = selection_id_
         AND item_id         = item_id_;
BEGIN
   OPEN  get_sel_obj;
   FETCH get_sel_obj INTO selobj_rec_;
   CLOSE get_sel_obj;

   company_def_ := FALSE;
   view_  := selobj_rec_.lov_reference;
   IF instr(view_, '(') != 0 THEN
      view_ := substr(view_, 1, instr(view_, '(')-1);
      company_def_ := TRUE;
   END IF;

   stmt_ := 'SELECT ' || selobj_rec_.object_col_id || ' FROM ' || view_;
   
   value_ := NULL;
   FOR advsel_ IN get_advanced LOOP
      IF advsel_.operator = 'EQUAL' THEN
         IF (advsel_.value_from IS NOT NULL) THEN
            value_ := value_ || advsel_.value_from || ';';
         END IF;
      ELSIF advsel_.operator = 'INCL' THEN
         FOR val_ IN get_values(advsel_.item_id) LOOP
            value_ := value_ || val_.value || ';';
         END LOOP;
      ELSE
         IF advsel_.operator = 'BETWEEN' THEN
            where_ := selobj_rec_.object_col_id || ' BETWEEN ''' || advsel_.value_from || ''' AND ''' || advsel_.value_to || '''';
         ELSIF advsel_.operator = 'NOTBETWEEN' THEN
            where_ := selobj_rec_.object_col_id || ' NOT BETWEEN ''' || advsel_.value_from || ''' AND ''' || advsel_.value_to || '''';
         ELSIF advsel_.operator = 'LESS' THEN
            where_ := selobj_rec_.object_col_id || ' < ''' || advsel_.value_from || '''';
         ELSIF advsel_.operator = 'LESS_EQUAL' THEN
            where_ := selobj_rec_.object_col_id || ' <= ''' || advsel_.value_from || '''';
         ELSIF advsel_.operator = 'GREATER' THEN
            where_ := selobj_rec_.object_col_id || ' > ''' || advsel_.value_from || '''';
         ELSIF advsel_.operator = 'GREATER_EQUAL' THEN
            where_ := selobj_rec_.object_col_id || ' >= ''' || advsel_.value_from || '''';
         ELSIF advsel_.operator = 'NOTEQUAL' THEN
            IF (advsel_.value_from IS NOT NULL) THEN
               where_ := selobj_rec_.object_col_id || ' != ''' || advsel_.value_from || '''';
            END IF;
         ELSIF advsel_.operator = 'EXCL' THEN
            where_ := selobj_rec_.object_col_id || ' NOT IN (''#''';
            FOR val_ IN get_values(advsel_.item_id) LOOP
               where_ := where_ || ',''' || val_.value || '''';
            END LOOP;
            where_ := where_ || ')';
         END IF;
         
         IF company_def_ THEN
            where_ :=  ' COMPANY = :company_' || ' AND ' || where_;
         END IF;
         
         IF (company_def_)THEN
            @ApproveDynamicStatement(2012-10-23,waudlk)
            OPEN  get_obj_ FOR stmt_ || ' WHERE  ' || where_ USING company_;
         ELSE
            @ApproveDynamicStatement(2012-10-23,waudlk)
            OPEN  get_obj_ FOR stmt_ || ' WHERE  ' || where_;
         END IF;
           
         LOOP
            FETCH get_obj_ INTO obj_value_;
            EXIT WHEN get_obj_%NOTFOUND;
            value_ := value_ || obj_value_ || ';';
         END LOOP;
      END IF;
   END LOOP;
   RETURN value_;
END Get_Sel_Object_Values;



PROCEDURE Get_Object_Template_Detail (
   obj_selection_    OUT arr_selection,
   template_rec_     OUT templ_rec_tab,
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_      IN NUMBER )
IS
   code_part_           VARCHAR2(6);
   right_side_          VARCHAR2(32000);
   value_from_          VARCHAR2(2000);
   value_to_            VARCHAR2(2000);
   delim_               VARCHAR2(1);
   delim1_              VARCHAR2(1);
   sel_object_id_       VARCHAR2(100);
   bind_name_           VARCHAR2(2000);
   bind_value_          arr_varchar;
   tag_                 VARCHAR2(200);
   ctr_                 NUMBER;
   i_                   NUMBER;
   fin_sel_object_rec_   Fin_Sel_Object_API.Public_Rec;

   CURSOR get_obj IS
      SELECT selection_object_id
        FROM fin_obj_grp_sel_object_tab
       WHERE object_group_id = object_group_id_;

   CURSOR get_advanced IS
      SELECT *
        FROM fin_object_selection_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_;

   CURSOR get_values(item_id_ NUMBER) IS
      SELECT *
        FROM fin_obj_selection_values_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_
         AND item_id = item_id_;
BEGIN
   FOR obj_ IN get_obj LOOP
      fin_sel_object_rec_ := Fin_Sel_Object_API.Get(obj_.selection_object_id);
      IF fin_sel_object_rec_.is_code_part = 'FALSE' THEN
         obj_selection_(obj_.selection_object_id).selection := NULL;
      ELSE
         code_part_ := fin_sel_object_rec_.code_part;
         obj_selection_(code_part_).selection := NULL;
      END IF;
   END LOOP;
   
   ctr_      := 0;

   FOR advsel_ IN get_advanced LOOP
      value_from_ := NULL;
      value_to_   := NULL;
      right_side_ := NULL;
      bind_name_  := NULL;
      
      fin_sel_object_rec_ := Fin_Sel_Object_API.Get(advsel_.selection_object_id);
      IF fin_sel_object_rec_.is_code_part = 'FALSE' THEN
         sel_object_id_ := advsel_.selection_object_id;
      ELSE
         code_part_ := fin_sel_object_rec_.code_part;
         sel_object_id_ := code_part_;
      END IF;
      
      IF obj_selection_(sel_object_id_).selection IS NULL THEN
         i_ := 0;
         bind_value_.DELETE;
      ELSE
         i_ := obj_selection_(sel_object_id_).bind_value.COUNT;
         bind_value_ := obj_selection_(sel_object_id_).bind_value;
      END IF;
      
      IF advsel_.value_from_date IS NOT NULL THEN
         value_from_ := to_char(advsel_.value_from_date, Fin_Selection_Templ_Util_API.date_format_);
      ELSE
         value_from_ := advsel_.value_from;
      END IF;
      IF advsel_.value_to_date IS NOT NULL THEN
         value_to_ := to_char(advsel_.value_to_date, Fin_Selection_Templ_Util_API.date_format_);
      ELSE
         value_to_ := advsel_.value_to;
      END IF;

      tag_ := sel_object_id_ || i_;
      IF value_from_ IS NOT NULL THEN
         IF advsel_.operator = 'EQUAL' THEN
            right_side_ := value_from_;
            IF INSTR(value_from_, '%') > 0 OR INSTR(value_from_, '_') > 0 THEN
               bind_name_ := 'LIKE :' || sel_object_id_ || i_;
            ELSE
               bind_name_ := '= :' || sel_object_id_ || i_;
            END IF;
            bind_value_(i_) := value_from_;
         ELSIF advsel_.operator = 'NOTEQUAL' THEN
            right_side_ := '!= ' || value_from_;
            IF INSTR(value_from_, '%') > 0 OR INSTR(value_from_, '_') > 0 THEN
               bind_name_ := 'NOT LIKE :' || sel_object_id_ || i_;
            ELSE
               bind_name_ := '!= :' || sel_object_id_ || i_;
            END IF;
            bind_value_(i_) := value_from_;
         ELSIF advsel_.operator = 'BETWEEN' THEN
            right_side_ := value_from_ || '..' || value_to_;
            bind_name_ := 'BETWEEN :' || sel_object_id_ || i_ || ' AND :' || sel_object_id_ || TO_CHAR(i_+1);
            bind_value_(i_) := value_from_;
            bind_value_(i_+1) := value_to_;
         ELSIF advsel_.operator = 'NOTBETWEEN' THEN
            right_side_ := value_from_ || '!..' || value_to_;
            bind_name_ := 'NOT BETWEEN :' || sel_object_id_ || i_ || ' AND :' || sel_object_id_ || TO_CHAR(i_+1);
            bind_value_(i_) := value_from_;
            bind_value_(i_+1) := value_to_;
         ELSIF advsel_.operator = 'LESS' THEN
            right_side_ := '<' || value_from_;
            bind_name_ := '< :' || sel_object_id_ || i_;
            bind_value_(i_) := value_from_;
         ELSIF advsel_.operator = 'LESS_EQUAL' THEN
            right_side_ := '<=' || value_from_;
            bind_name_ := '<= :' || sel_object_id_ || i_;
            bind_value_(i_) := value_from_;
         ELSIF advsel_.operator = 'GREATER' THEN
            right_side_ := '>' || value_from_;
            bind_name_ := '> :' || sel_object_id_ || i_;
            bind_value_(i_) := value_from_;
         ELSIF advsel_.operator = 'GREATER_EQUAL' THEN
            right_side_ := '>=' || value_from_;
            bind_name_ := '>= :' || sel_object_id_ || i_;
            bind_value_(i_) := value_from_;
         END IF;
      ELSE
         IF advsel_.operator IN ('INCL','EXCL') THEN
            delim1_ := '';
            delim_  := '';
            FOR val_ IN get_values(advsel_.item_id) LOOP
               IF advsel_.operator = 'INCL' THEN
                  right_side_ := right_side_ || delim_ || val_.value;
               ELSIF advsel_.operator = 'EXCL' THEN
                  right_side_ := right_side_ || delim_ || '!=' || val_.value;
               END IF;
               IF bind_name_ IS NULL THEN
                  bind_name_ := 'IN (:' || sel_object_id_ || i_;
               ELSE
                  bind_name_ := bind_name_ || ',:' || sel_object_id_ || i_;
               END IF;
               value_from_ := value_from_ || delim1_ || val_.value;
               bind_value_(i_) := val_.value;
               i_ := i_ + 1;
               delim1_ := ',';
               delim_  := ';';
            END LOOP;
   
            IF bind_name_ IS NOT NULL THEN
               bind_name_ := bind_name_ || ')';
            END IF;
            IF advsel_.operator = 'EXCL' THEN
               bind_name_ := 'NOT ' || bind_name_;
            END IF;
         END IF;
      END IF;

      IF value_from_ IS NOT NULL THEN
         bind_name_ := bind_name_ || ' ';
         IF obj_selection_(sel_object_id_).selection IS NULL THEN
            obj_selection_(sel_object_id_).selection := right_side_;
            obj_selection_(sel_object_id_).bind_variable := 'SQL_COL ' || bind_name_;
         ELSE
            obj_selection_(sel_object_id_).selection := obj_selection_(sel_object_id_).selection || ';' || right_side_;
            obj_selection_(sel_object_id_).bind_variable := obj_selection_(sel_object_id_).bind_variable ||
                                                            'AND SQL_COL ' || bind_name_;
         END IF;
      END IF;

      obj_selection_(sel_object_id_).bind_value := bind_value_;

      IF value_from_ IS NOT NULL THEN
         template_rec_(ctr_).selection_object := fin_sel_object_rec_.description;
         template_rec_(ctr_).operator_db      := advsel_.operator;
         template_rec_(ctr_).operator         := Fin_Sel_Object_Operator_API.Decode(advsel_.operator);
         template_rec_(ctr_).from_value       := value_from_;
         template_rec_(ctr_).to_value         := value_to_;
         template_rec_(ctr_).from_value_date  := advsel_.value_from_date;
         template_rec_(ctr_).to_value_date    := advsel_.value_to_date;
         ctr_ := ctr_ + 1;
      END IF;
   END LOOP;
END Get_Object_Template_Detail;


PROCEDURE Set_Bind_Variable(
   cursor_        IN OUT NUMBER,
   sel_object_id_ IN VARCHAR2,
   bind_value_    IN arr_varchar )
IS
   data_type_ VARCHAR2(20);
BEGIN
   data_type_ := Fin_Sel_Object_API.Get_Data_Type_Db(sel_object_id_);
   FOR i IN bind_value_.FIRST..bind_value_.LAST LOOP
      trace_sys.message(sel_object_id_ || i || '--> ' || bind_value_(i));
      IF data_type_ = 'DATE' THEN
         DBMS_SQL.BIND_VARIABLE(cursor_, sel_object_id_ || i, to_date(bind_value_(i),date_format_));
      ELSE
         DBMS_SQL.BIND_VARIABLE(cursor_, sel_object_id_ || i, bind_value_(i));
      END IF;
   END LOOP;
END Set_Bind_Variable;




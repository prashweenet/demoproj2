-----------------------------------------------------------------------------
--
--  Logical unit: FinObjectSelection
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  101027  SALIDE RAVEN-1085, Created.
--  110528  THPELK EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110729  Sacalk  FIDEAGLE-198, Fixed errors in Dictionary Test
--  120316  Waudlk  EASTRTM-2636, Changed the Fin_Sel_Obj_Templ_API.Exist(company_, object_group_id_, template_id_) to Check_Template_Exists
--  140709  Nudilk  PRFI-1012, Merged Bug 117695, Modified code in Copy_Selection_Template. 
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Get_Next_Id___ (
   rec_ IN  FIN_OBJECT_SELECTION_TAB%ROWTYPE ) RETURN NUMBER
IS
   id_              NUMBER;
   CURSOR getid IS
      SELECT MAX( item_id )
      FROM   FIN_OBJECT_SELECTION_TAB
      WHERE  company = rec_.company
      AND    object_group_id = rec_.object_group_id
      AND    object_id = rec_.object_id
      AND    selection_id = rec_.selection_id;
BEGIN
   OPEN getid;
   FETCH getid INTO id_;
   CLOSE getid;
   RETURN( NVL(id_ + 1, 0) );
END Get_Next_Id___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('MANUAL_INPUT','FALSE',attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT FIN_OBJECT_SELECTION_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   Client_SYS.Add_To_Attr('ITEM_ID', newrec_.item_id, attr_);
   super(objid_, objversion_, newrec_, attr_);
END Insert___;

@Override
PROCEDURE Unpack___ (
   newrec_   IN OUT fin_object_selection_tab%ROWTYPE,
   indrec_   IN OUT Indicator_Rec,
   attr_     IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(newrec_, indrec_, attr_);
   --Add post-processing code here
   IF (newrec_.manual_input IS NULL) THEN
      newrec_.manual_input := 'FALSE';
      indrec_.manual_input := TRUE;
   END IF;
   IF (newrec_.item_id IS NULL) THEN
      newrec_.item_id := 0;
   END IF;   
END Unpack___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     fin_object_selection_tab%ROWTYPE,
   newrec_ IN OUT fin_object_selection_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   data_type_ VARCHAR2(20);
   CURSOR get_object_data_type IS 
      SELECT data_type_db
      FROM   fin_sel_object
      WHERE  selection_object_id = newrec_.selection_object_id;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   -- Validate that the operator is allowed to use for the selection object
   Fin_Sel_Object_Allow_Oper_API.Exist_Db(newrec_.selection_object_id, newrec_.operator);   
   IF (newrec_.value_from IS NOT NULL OR newrec_.value_to IS NOT NULL) THEN
      OPEN  get_object_data_type;
      FETCH get_object_data_type INTO data_type_;
      CLOSE get_object_data_type;
   END IF;      
   IF (newrec_.operator != 'BETWEEN' AND newrec_.operator != 'NOTBETWEEN') THEN
      IF(newrec_.value_to IS NOT NULL) THEN
         Error_SYS.Record_General(lu_name_, 'TOVALINVALID: To Value cannot contain a value when selection operator is not ''Between'' or ''Not Between''');
      END IF;
   END IF;
   IF (newrec_.operator ='INCL' OR newrec_.operator = 'EXCL') THEN
      IF(newrec_.value_from IS NOT NULL) THEN
         Error_SYS.Record_General(lu_name_, 'FROMVALINVALID: From Value cannot contain a value when selection operator is either ''Incl Specific Values'' or ''Excl Specific Values''');
      END IF;
   END IF;
   IF (data_type_ = 'DATE')THEN
      IF (newrec_.value_from IS NOT NULL) THEN
         newrec_.value_from:= Is_Valid_Date_Format___(newrec_.value_from, Client_SYS.trunc_date_format_);
         newrec_.value_from_date := to_date(newrec_.value_from, Client_SYS.trunc_date_format_);
      END IF;
      IF (newrec_.value_to IS NOT NULL) THEN
         newrec_.value_to := Is_Valid_Date_Format___(newrec_.value_to, Client_SYS.trunc_date_format_);
         newrec_.value_to_date := to_date(newrec_.value_to, Client_SYS.trunc_date_format_);
      END IF;
   ELSIF (data_type_ = 'NUMBER') THEN
      IF (newrec_.value_from IS NOT NULL) THEN
         newrec_.value_from := Is_Valid_Number___(newrec_.value_from);
      END IF;
      IF (newrec_.value_to IS NOT NULL) THEN
         newrec_.value_to := Is_Valid_Number___(newrec_.value_to);
      END IF;
   END IF;   
   IF newrec_.value_from_number IS NOT NULL THEN
      newrec_.value_from := TO_CHAR(newrec_.value_from_number);
   END IF;
   IF newrec_.value_to_number IS NOT NULL THEN
      newrec_.value_to := TO_CHAR(newrec_.value_to_number);
   END IF;   
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT fin_object_selection_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   
   newrec_.item_id := Get_Next_Id___(newrec_);   
   Fin_Sel_Object_API.Validate_Selection_Object(newrec_.company, newrec_.selection_object_id);
END Check_Insert___;

FUNCTION Is_Valid_Date_Format___ (
   date_str_    VARCHAR2,
   date_format_ VARCHAR2) RETURN VARCHAR2
IS
BEGIN   
   RETURN TO_CHAR(TO_DATE(date_str_, date_format_), date_format_);   
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDDATEFORMAT: The date format should be in '':P1''',date_format_);
END Is_Valid_Date_Format___;

FUNCTION Is_Valid_Number___ (
   num_str_   VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN TO_CHAR(TO_NUMBER(num_str_));
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDNUMVER:  Invalid Number.');
END Is_Valid_Number___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Save_Temp_Selection__ (
   attr_       IN OUT VARCHAR2,
   action_     IN VARCHAR2 )
IS
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(2000);
   company_          fin_object_selection_tab.company%TYPE;
   object_group_id_  fin_object_selection_tab.object_group_id%TYPE;
   object_id_        fin_object_selection_tab.object_id%TYPE;
   selection_id_     fin_object_selection_tab.selection_id%TYPE;
   item_id_          fin_object_selection_tab.item_id%TYPE;
   newrec_           fin_object_selection_tab%ROWTYPE;
   oldrec_           fin_object_selection_tab%ROWTYPE;
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
   newattr_          VARCHAR2(2000);
   indrec_           Indicator_Rec;
BEGIN
   company_          := Client_SYS.Get_Item_Value('COMPANY', attr_);
   object_group_id_  := Client_SYS.Get_Item_Value('OBJECT_GROUP_ID', attr_);
   object_id_        := Client_SYS.Get_Item_Value('OBJECT_ID', attr_);
   selection_id_     := Client_SYS.Get_Item_Value_To_Number('SELECTION_ID', attr_, lu_name_);
   item_id_          := Client_SYS.Get_Item_Value_To_Number('ITEM_ID', attr_, lu_name_);
   IF action_ = 'MODIFY' THEN
      IF Check_Exist___ (company_, object_group_id_, object_id_, selection_id_, item_id_) THEN
         oldrec_ := Lock_By_Keys___(company_, object_group_id_, object_id_, selection_id_, item_id_);
         newrec_ := oldrec_;
         newattr_ := NULL;
         ptr_ := NULL;
         WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
            IF (name_ NOT IN ('COMPANY','OBJECT_GROUP_ID','OBJECT_ID','SELECTION_ID','ITEM_ID','SELECTION_OBJECT_ID')) THEN
               Client_SYS.Add_To_Attr(name_, value_, newattr_);
            END IF;
         END LOOP;         
         Unpack___(newrec_, indrec_, newattr_);
         Check_Update___(oldrec_, newrec_, indrec_, newattr_);
         Update___(objid_, oldrec_, newrec_, newattr_, objversion_, TRUE);
      ELSE
         newattr_ := attr_;
         Unpack___(newrec_, indrec_, newattr_);
         Check_Insert___(newrec_, indrec_, newattr_);
         Insert___(objid_, objversion_, newrec_, newattr_);
         attr_ := NULL;
         Client_SYS.Add_To_Attr( 'ITEM_ID', newrec_.item_id, attr_);
         Client_SYS.Add_To_Attr( 'OBJID', objid_, attr_);
         Client_SYS.Add_To_Attr( 'OBJVERSION', objversion_, attr_);
      END IF;
   ELSE
      Get_Id_Version_By_Keys___ (objid_, objversion_, company_, object_group_id_, object_id_, selection_id_, item_id_);
      oldrec_ := Lock_By_Id___(objid_, objversion_);
      Delete___(objid_, oldrec_);
   END IF;
END Save_Temp_Selection__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

@UncheckedAccess
FUNCTION Get_Next_Object_Id_ RETURN NUMBER
IS
   id_   NUMBER;
   CURSOR getid IS
      SELECT fin_selection_object_id_seq.NEXTVAL
      FROM   dual;
BEGIN
   OPEN getid;
   FETCH getid INTO id_;
   CLOSE getid;
   RETURN id_;
END Get_Next_Object_Id_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Copy_Selection_Template (
   selection_id_     IN OUT NUMBER,
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   template_id_      IN VARCHAR2 )
IS
BEGIN
   IF nvl(selection_id_, 0) != 0 THEN
      DELETE FROM fin_object_selection_tab
         WHERE company = company_
           AND object_group_id = object_group_id_
           AND object_id = object_id_
           AND selection_id = selection_id_;

      DELETE FROM fin_obj_selection_values_tab
         WHERE company = company_
           AND object_group_id = object_group_id_
           AND object_id = object_id_
           AND selection_id = selection_id_;
   END IF;

   IF template_id_ IS NOT NULL THEN
      Fin_Sel_Obj_Templ_API.Check_Template_Exists(company_, object_group_id_, template_id_);

      selection_id_ := FIN_OBJECT_SELECTION_API.Get_Next_Object_Id_;

      INSERT 
         INTO fin_object_selection_tab (
            company,
            object_group_id,
            object_id,
            selection_id,
            item_id,
            selection_object_id,
            operator,
            value_from,
            value_to,
            value_from_number,
            value_to_number,
            value_from_date,
            value_to_date,
            value_exist,
            manual_input,
            rowversion)
         SELECT
            company,
            object_group_id,
            object_id_,
            selection_id_,
            item_id,
            selection_object_id,
            selection_operator,
            value_from,
            value_to,
            DECODE (Fin_Sel_Object_API.Get_Data_Type_Db(selection_object_id), 'NUMBER', value_from, NULL),
            DECODE (Fin_Sel_Object_API.Get_Data_Type_Db(selection_object_id), 'NUMBER', value_to,   NULL), 
            value_from_date,
            value_to_date,
            value_exist,
            manual_input,
            SYSDATE
         FROM fin_sel_obj_templ_det_tab
         WHERE company = company_
           AND object_group_id = object_group_id_
           AND template_id = template_id_;
   
      Fin_Obj_Selection_Values_API.Copy_Selection_Templ_Values (company_, object_group_id_, object_id_, selection_id_, template_id_);
   ELSE
      selection_id_ := 0;
   END IF;
END Copy_Selection_Template;


PROCEDURE Create_Selection_Template (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_     IN NUMBER,
   template_attr_    IN VARCHAR2 )
IS
   attr_             VARCHAR2(2000);
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(2000);
   template_id_      VARCHAR2(20);
   incl_values_      VARCHAR2(5);
   item_id_          NUMBER;

   CURSOR get_detail IS
      SELECT *
        FROM fin_object_selection_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_;

   CURSOR get_values IS
      SELECT *
        FROM fin_obj_selection_values_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_
         AND item_id = item_id_;
BEGIN
   attr_ := NULL;
   Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);

   ptr_  := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(template_attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'INCLUDE_VALUES') THEN
         incl_values_ := value_;
      ELSIF (name_ = 'TEMPLATE_ID') THEN
         template_id_ := value_;
         Client_SYS.Add_To_Attr(name_, value_, attr_);
      ELSE
         Client_SYS.Add_To_Attr(name_, value_, attr_);
      END IF;
   END LOOP;

   Fin_Sel_Obj_Templ_API.Create_Template (attr_);

   FOR det_ IN get_detail LOOP
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);
      Client_SYS.Add_To_Attr('TEMPLATE_ID', template_id_, attr_);
      Client_SYS.Add_To_Attr('ITEM_ID', det_.item_id, attr_);
      Client_SYS.Add_To_Attr('SELECTION_OBJECT_ID', det_.selection_object_id, attr_);
      Client_SYS.Add_To_Attr('SELECTION_OPERATOR_DB', det_.operator, attr_);
      IF incl_values_ = 'TRUE' THEN
         Client_SYS.Add_To_Attr('VALUE_FROM', det_.value_from, attr_);
         Client_SYS.Add_To_Attr('VALUE_TO', det_.value_to, attr_);
         Client_SYS.Add_To_Attr('VALUE_FROM_DATE', det_.value_from_date, attr_);
         Client_SYS.Add_To_Attr('VALUE_TO_DATE', det_.value_to_date, attr_);
         Client_SYS.Add_To_Attr('VALUE_EXIST', det_.value_exist, attr_);
      END IF;
      IF (det_.operator IN ('INCL','EXCL')) THEN
         Client_SYS.Add_To_Attr('MANUAL_INPUT_DB', 'TRUE', attr_);
      ELSE
         Client_SYS.Add_To_Attr('MANUAL_INPUT_DB', det_.manual_input, attr_);
      END IF;
      Fin_Sel_Obj_Templ_Det_API.Create_Template_Detail (attr_);

      IF det_.operator IN ('INCL','EXCL') AND incl_values_ = 'TRUE' THEN
         item_id_ := det_.item_id;
         FOR val_ IN get_values LOOP
            Client_SYS.Clear_Attr(attr_);
            Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
            Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);
            Client_SYS.Add_To_Attr('TEMPLATE_ID', template_id_, attr_);
            Client_SYS.Add_To_Attr('ITEM_ID', det_.item_id, attr_);
            Client_SYS.Add_To_Attr('VALUE', val_.value, attr_);
            Fin_Sel_Templ_Values_API.Create_Template_Values (attr_);
         END LOOP;
      END IF;
   END LOOP;
END Create_Selection_Template;


PROCEDURE Delete_Object_Selection (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_      IN NUMBER )
IS
BEGIN
   DELETE FROM fin_object_selection_tab
      WHERE company = company_
        AND object_group_id = object_group_id_
        AND object_id = object_id_
        AND selection_id = selection_id_;

   DELETE FROM fin_obj_selection_values_tab
      WHERE company = company_
        AND object_group_id = object_group_id_
        AND object_id = object_id_
        AND selection_id = selection_id_;
END Delete_Object_Selection;



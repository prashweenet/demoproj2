-----------------------------------------------------------------------------
--
--  Logical unit: AccountingAttributeValue
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  990707  SaCh    Modified with respect to new templates.
--  011127  KaGa    Call ID 26070 - Changed attribute_value size to 100 in VIEW
--  070124  ovjose  Move LU to Accrul.
--  071024  DIFELK  Bug 68597 corrected. Increased variable size.
--  090605  THPELK  Bug 82609 - Added missing UNDEFINE statement for VIEWPCT
--  131028  Umdolk  PBFI-885, Refactoring.
--  181823  Nudilk  Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__. 
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated
FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_attribute_value_tab%ROWTYPE,
   newrec_ IN OUT accounting_attribute_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN accounting_attribute_value_tab%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   attribute_list_      IN  VARCHAR2,
   attribute_value_list_ IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   log_id_              IN  NUMBER,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE accounting_attribute_value IS TABLE OF accounting_attribute_value_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                          NUMBER;
   ptr1_                         NUMBER;
   ptr2_                         NUMBER;
   i_                            NUMBER;
   update_method_                VARCHAR2(20);
   value_                        VARCHAR2(2000);
   target_company_               accounting_attribute_tab.company%TYPE;
   ref_accounting_attribute_val_ accounting_attribute_value;
   ref_attr_                     attr;
   attr_value_                   VARCHAR2(32000) := NULL;
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attribute_list_) LOOP
      ref_accounting_attribute_val_(i_).attribute := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attribute_value_list_) LOOP
      ref_accounting_attribute_val_(i_).attribute_value := value_;
      i_ := i_ + 1;
   END LOOP;   
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_accounting_attribute_val_.FIRST..ref_accounting_attribute_val_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_accounting_attribute_val_(j_).attribute,
                                 ref_accounting_attribute_val_(j_).attribute_value,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_  IN VARCHAR2,
   target_company_  IN VARCHAR2,
   attribute_       IN VARCHAR2,
   attribute_value_ IN VARCHAR2,
   update_method_   IN VARCHAR2,
   log_id_          IN NUMBER,
   attr_            IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              accounting_attribute_value_tab%ROWTYPE;
   target_rec_              accounting_attribute_value_tab%ROWTYPE;
   old_target_rec_          accounting_attribute_value_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);   
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, attribute_, attribute_value_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, attribute_, attribute_value_);
   log_key_ := attribute_ || '^' || attribute_value_;
   IF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source creates a new record which does not exist in the target company
      New___(target_rec_);
      log_detail_status_ := 'CREATED';
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'UPDATE_ALL') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user wants to update the entire record in the target
      target_rec_.rowkey := old_target_rec_.rowkey;
      Modify___(target_rec_);
      log_detail_status_ := 'MODIFIED';    
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NOT NULL) THEN
      -- Source removes a record, the same record is removed in the target company
      Remove___(old_target_rec_);      
      log_detail_status_ := 'REMOVED';      
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source removes a record, the same record does not exist in the target company to be removed
      Raise_Record_Not_Exist___(target_company_, attribute_, attribute_value_);
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'NO_UPDATE') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user does not wan to update records in the target
      Raise_Record_Exist___(target_rec_);
   END IF; 
   IF (Company_Basic_Data_Window_API.Check_Copy_From_Source_Company(target_company_,source_company_, lu_name_)) THEN
      IF log_detail_status_ IN ('CREATED','MODIFIED') THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      ELSIF log_detail_status_ = 'REMOVED' THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                  NUMBER;
   name_                 VARCHAR2(200);
   value_                VARCHAR2(32000);
   source_company_       VARCHAR2(100);
   target_company_list_  VARCHAR2(32000);
   attribute_list_       VARCHAR2(32000);
   attribute_value_list_ VARCHAR2(32000);
   update_method_list_   VARCHAR2(32000);
   copy_type_            VARCHAR2(100);
   attr1_                VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         source_company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'ATTRIBUTE_LIST') THEN
         attribute_list_ := value_;
      ELSIF (name_ = 'ATTRIBUTE_VALUE_LIST') THEN
         attribute_value_list_ := value_;         
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(source_company_,
                      target_company_list_,
                      attribute_list_,
                      attribute_value_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_       IN  VARCHAR2,
   target_company_list_  IN  VARCHAR2,
   attribute_list_       IN  VARCHAR2,
   attribute_value_list_ IN VARCHAR2,
   update_method_list_   IN  VARCHAR2,
   copy_type_            IN  VARCHAR2,
   attr_                 IN  VARCHAR2 DEFAULT NULL)
IS
   ptr_                          NUMBER;
   ptr1_                         NUMBER;
   ptr2_                         NUMBER;
   i_                            NUMBER;
   update_method_                VARCHAR2(20);
   value_                        VARCHAR2(2000);
   target_company_               accounting_attribute_value_tab.company%TYPE;
   TYPE accounting_attribute_value IS TABLE OF accounting_attribute_value_tab%ROWTYPE 
                                 INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                                 INDEX BY BINARY_INTEGER;
   ref_accounting_attribute_val_ accounting_attribute_value;
   ref_attr_                     attr;
   log_id_                       NUMBER;
   attr_value_                   VARCHAR2(32000) := NULL;   
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attribute_list_) LOOP
      ref_accounting_attribute_val_(i_).attribute := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attribute_value_list_) LOOP
      ref_accounting_attribute_val_(i_).attribute_value := value_;
      i_ := i_ + 1;
   END LOOP;   
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   IF (target_company_list_ IS NOT NULL) THEN
     Copy_Basic_Data_Log_API.Create_New_Record(log_id_, source_company_, copy_type_,lu_name_);
   END IF;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_accounting_attribute_val_.FIRST..ref_accounting_attribute_val_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_accounting_attribute_val_(j_).attribute,
                                 ref_accounting_attribute_val_(j_).attribute_value,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Update_Status(log_id_);
   END IF;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Desc (
   company_         IN VARCHAR2,
   attribute_       IN VARCHAR2,
   attribute_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   reference_       ACCOUNTING_ATTRIBUTE_VALUE_TAB.description%TYPE;

   CURSOR get_desc is
      SELECT  description
      FROM    ACCOUNTING_ATTRIBUTE_VALUE_TAB
      WHERE   company         = company_
      AND     attribute       = attribute_
      AND     attribute_value = attribute_value_;

BEGIN
   OPEN  get_desc;
   FETCH get_desc into reference_;
   IF ( get_desc%NOTFOUND ) THEN
      CLOSE get_desc;
      reference_ := null;
   END IF;
   
   RETURN reference_;
END Get_Desc;


PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   attribute_list_         VARCHAR2(2000);
   attribute_value_list_   VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Accounting_Attribute_Value_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'ATTRIBUTE_LIST') THEN
            attribute_list_ := value_;
         ELSIF (name_ = 'ATTRIBUTE_VALUE_LIST') THEN
            attribute_value_list_ := value_;         
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  attribute_list_,
                                  attribute_value_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

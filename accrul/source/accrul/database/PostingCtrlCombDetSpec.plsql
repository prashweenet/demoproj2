-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlCombDetSpec
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  050606  reanpl  Created for FIAD376 - Actual Costing
--  060619  iswalk  removed allowed_default_.
--  070321  shsalk  LCS Merge 63645,Corrected.Added method Account_Exist
--  070912  Shsalk  B148647 Made an error message more descriptive.
--  111020  ovjose  Added no_code_part_valu
--  140409  THPELK PBFI-4377, LCS Merge (Bug 113342).
--  151007  chiblk  STRFI-200, New__ changed to New___ in Insert_Post_Ctrl_Comb_Det_Spec
--  180821  Nudilk  Bug 143596, Corrected.
--  181823  Nudilk  Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
--  200701  Tkavlk  Bug 154601, Added Remove_company

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Row___ (
   newrec_ IN POSTING_CTRL_COMB_DET_SPEC_TAB%ROWTYPE )
IS
   description_   VARCHAR2(200);
   module_        VARCHAR2(20);
   ledg_flag_     VARCHAR2(1);
   tax_flag_      VARCHAR2(1);
BEGIN
   IF (newrec_.code_part = 'A' AND newrec_.no_code_part_value = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 
                               'NOCODEPVALALLOWED: Not allowed to use :P1 for Code Part :P2', 
                               Get_Column_Trans___('NO_CODE_PART_VALUE'),
                               Accounting_Code_Parts_API.Get_Name(newrec_.company, newrec_.code_part));      
   END IF;

   IF (newrec_.code_part_value IS NOT NULL AND newrec_.no_code_part_value = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 
                               'CODEANDNOCODEPVAL: Not allowed to set a code part value and use :P1',
                               Get_Column_Trans___('NO_CODE_PART_VALUE'));
   END IF;

   Posting_Ctrl_Posting_Type_API.Get_Posting_Type_Attri_ ( description_, module_, ledg_flag_, tax_flag_, newrec_.posting_type );
   IF (Accounting_Code_Part_Value_API.Is_Budget_Code_Part(newrec_.company, newrec_.code_part, newrec_.code_part_value)) THEN
      IF(newrec_.code_part ='A') THEN
         Account_API.Exist(newrec_.company, newrec_.code_part_value);  
         Error_SYS.Record_General(lu_name_, 'BUDACCNT: :P1 is a budget account and not valid for posting type :P2', newrec_.code_part_value, newrec_.posting_type);
      ELSE
         Error_SYS.Record_General(lu_name_, 'BUDCODEPART: :P1 is a Budget/Planning Only code part value and cannot be used in Posting Control.', newrec_.code_part_value);
      END IF;
   END IF;
   IF (newrec_.code_part = 'A') THEN            
      IF (ledg_flag_ = 'Y') THEN
         IF (NOT Account_API.Is_Ledger_Account( newrec_.company, newrec_.code_part_value )) THEN
            Error_SYS.Record_General(lu_name_, 'CMBSPECNOLEDGACCNT: :P1 is no ledger account and not valid for posting type :P2', newrec_.code_part_value,newrec_.posting_type);
         END IF;
      ELSIF (tax_flag_ = 'Y') THEN
         IF (NOT Account_API.Is_Tax_Account( newrec_.company, newrec_.code_part_value )) THEN
            Error_SYS.Record_General(lu_name_, 'CMBSPECNOTAXACCNT: Account :P1 is no tax account and not valid for posting type :P2', newrec_.code_part_value,newrec_.posting_type);
         END IF;
      ELSIF (Account_API.Is_Stat_Account(newrec_.company, newrec_.code_part_value )) = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'CMBSPECSTATACC: :P1 is a statistical account and not valid for posting type :P2', newrec_.code_part_value,newrec_.posting_type);
      END IF;
   ELSE
      IF (newrec_.no_code_part_value = 'FALSE') THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.code_part_value);
      END IF;   
   END IF;
END Validate_Row___;


FUNCTION Get_Column_Trans___
   (item_      IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   -- Should not use the protected method in Language_SYS but until a public method the protected method is used.
   RETURN Language_SYS.Translate_Item_Prompt_(lu_name_, Upper(item_));
END Get_Column_Trans___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('NO_CODE_PART_VALUE_DB', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT posting_ctrl_comb_det_spec_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_          VARCHAR2(30);
   value_         VARCHAR2(4000);
   internal_id_   NUMBER;   
BEGIN
   indrec_.valid_from := FALSE;
   IF (newrec_.no_code_part_value IS NULL) THEN
      newrec_.no_code_part_value := 'FALSE';
      indrec_.no_code_part_value := TRUE;
   END IF; 
   
   super(newrec_, indrec_, attr_);
   
   IF (newrec_.no_code_part_value = 'FALSE') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'CODE_PART_VALUE', newrec_.code_part_value);
   END IF;

   IF (newrec_.spec_control_type1_value = '%' AND newrec_.spec_control_type2_value = '%') THEN
      Error_SYS.Appl_General( lu_name_, 'POSTCMBDETSPEC01: Value % is not allowed for both control types at the same time.');
   END IF;

   IF newrec_.spec_control_type1_value != '%' THEN
      IF (newrec_.spec_control_type1 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id
         -- that should be saved.
         newrec_.spec_control_type1_value := Income_Type_API.Get_Internal_Income_Type(newrec_.spec_control_type1_value,
                                                                                      Company_Finance_API.Get_Currency_Code(newrec_.company),
                                                                                      Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.spec_control_type1 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.spec_control_type1_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.spec_control_type1_value := internal_id_;
         $ELSE
            NULL;
         $END
      END IF;

      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.spec_control_type1_value, newrec_.spec_control_type1, newrec_.spec_module1, newrec_.posting_type );
   END IF;

   IF (newrec_.spec_control_type2_value != '%') THEN
      IF (newrec_.spec_control_type2 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id
         -- that should be saved.
         newrec_.spec_control_type2_value := Income_Type_API.Get_Internal_Income_Type(newrec_.spec_control_type2_value,
                                                                                      Company_Finance_API.Get_Currency_Code(newrec_.company),
                                                                                      Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.spec_control_type2 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.spec_control_type2_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.spec_control_type2_value := internal_id_;
         $ELSE
            NULL;
         $END
      END IF;

      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.spec_control_type2_value, newrec_.spec_control_type2, newrec_.spec_module2, newrec_.posting_type );
   END IF;

   Validate_Row___ (newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     posting_ctrl_comb_det_spec_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_comb_det_spec_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   indrec_.valid_from   := FALSE;
   IF (newrec_.no_code_part_value IS NULL) THEN
      newrec_.no_code_part_value := 'FALSE';
      indrec_.no_code_part_value := TRUE;
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);

   IF (newrec_.no_code_part_value = 'FALSE') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'CODE_PART_VALUE', newrec_.code_part_value);
   END IF;

   Validate_Row___ (newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

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
   oldrec_ IN     posting_ctrl_comb_det_spec_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_comb_det_spec_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (App_Context_SYS.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN posting_ctrl_comb_det_spec_tab%ROWTYPE )
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
   source_company_              IN  VARCHAR2,
   target_company_list_         IN  VARCHAR2,
   code_part_list_              IN  VARCHAR2,
   posting_type_list_           IN  VARCHAR2,
   pc_valid_from_list_          IN  VARCHAR2,  
   control_type_value_list_     IN  VARCHAR2,  
   valid_from_list_              IN  VARCHAR2,  
   spec_comb_control_type_list_ IN  VARCHAR2,
   spec_ctrl_type_1_value_list_ IN  VARCHAR2,
   spec_ctrl_type_2_value_list_ IN  VARCHAR2,
   update_method_list_          IN  VARCHAR2,
   log_id_                      IN  NUMBER,
   attr_                        IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_control IS TABLE OF posting_ctrl_comb_det_spec_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         posting_ctrl_comb_det_spec_tab.company%TYPE;
   ref_posting_control_    posting_control;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;   
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_list_) LOOP
      ref_posting_control_(i_).code_part := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_posting_control_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pc_valid_from_list_) LOOP
      ref_posting_control_(i_).pc_valid_from := Client_SYS.Attr_Value_To_Date(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_value_list_) LOOP
      ref_posting_control_(i_).control_type_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, valid_from_list_) LOOP
      ref_posting_control_(i_).valid_from := Client_SYS.Attr_Value_To_Date(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_comb_control_type_list_) LOOP
      ref_posting_control_(i_).spec_comb_control_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_ctrl_type_1_value_list_) LOOP
      ref_posting_control_(i_).spec_control_type1_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_ctrl_type_2_value_list_) LOOP
      ref_posting_control_(i_).spec_control_type2_value := value_;
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
         FOR j_ IN ref_posting_control_.FIRST..ref_posting_control_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_posting_control_(j_).code_part,
                                 ref_posting_control_(j_).pc_valid_from,
                                 ref_posting_control_(j_).posting_type,                                
                                 ref_posting_control_(j_).control_type_value,
                                 ref_posting_control_(j_).valid_from, 
                                 ref_posting_control_(j_).spec_comb_control_type,
                                 ref_posting_control_(j_).spec_control_type1_value,
                                 ref_posting_control_(j_).spec_control_type2_value,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_         IN VARCHAR2,
   target_company_         IN VARCHAR2,
   code_part_              IN VARCHAR2,
   pc_valid_from_          IN DATE,   
   posting_type_           IN VARCHAR2,
   control_type_value_     IN VARCHAR2,
   valid_from_             IN DATE,
   spec_comb_control_type_ IN VARCHAR2,
   spec_ctrl_type_1_value_ IN VARCHAR2,
   spec_ctrl_type_2_value_ IN VARCHAR2,
   update_method_          IN VARCHAR2,
   log_id_                 IN NUMBER,
   attr_                   IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              posting_ctrl_comb_det_spec_tab%ROWTYPE;
   target_rec_              posting_ctrl_comb_det_spec_tab%ROWTYPE;
   old_target_rec_          posting_ctrl_comb_det_spec_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, 
                                        code_part_, 
                                        pc_valid_from_,                                         
                                        posting_type_, 
                                        control_type_value_, 
                                        valid_from_,
                                        spec_comb_control_type_,
                                        spec_ctrl_type_1_value_,
                                        spec_ctrl_type_2_value_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, 
                                            code_part_, 
                                            pc_valid_from_,                                         
                                            posting_type_, 
                                            control_type_value_, 
                                            valid_from_,
                                            spec_comb_control_type_,
                                            spec_ctrl_type_1_value_,
                                            spec_ctrl_type_2_value_);
   log_key_ := code_part_ ||'^'|| pc_valid_from_ ||'^'|| posting_type_ ||'^'|| control_type_value_|| '^'|| valid_from_ ||'^'||spec_comb_control_type_
               ||'^'|| spec_ctrl_type_1_value_ ||'^'|| spec_ctrl_type_2_value_;

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
      Raise_Record_Not_Exist___(target_company_,
                                code_part_, 
                                pc_valid_from_,                                         
                                posting_type_, 
                                control_type_value_, 
                                valid_from_,
                                spec_comb_control_type_,
                                spec_ctrl_type_1_value_,
                                spec_ctrl_type_2_value_);      
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
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);     
END Copy_To_Companies__;
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Update_Valid_From_ (
   company_            IN VARCHAR2,
   posting_type_       IN VARCHAR2,
   code_part_          IN VARCHAR2,
   pc_valid_from_      IN DATE,
   control_type_value_ IN VARCHAR2,
   valid_from_         IN DATE,
   new_valid_from_     IN DATE )
IS
   CURSOR get_row_for_update IS
      SELECT *
      FROM   POSTING_CTRL_COMB_DET_SPEC_TAB
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      AND   control_type_value = control_type_value_
      AND   valid_from = valid_from_
      FOR UPDATE NOWAIT;
BEGIN
   FOR rec_ IN get_row_for_update LOOP
      UPDATE POSTING_CTRL_COMB_DET_SPEC_TAB
         SET valid_from = new_valid_from_
      WHERE CURRENT OF get_row_for_update;
   END LOOP;
END Update_Valid_From_;


PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                         NUMBER;
   name_                        VARCHAR2(200);
   value_                       VARCHAR2(32000);
   source_company_              VARCHAR2(100);
   target_company_list_         VARCHAR2(32000);
   code_part_list_              VARCHAR2(32000);
   posting_type_list_           VARCHAR2(32000);
   pc_valid_from_list_          VARCHAR2(32000);
   control_type_value_list_     VARCHAR2(32000);
   valid_from_list_             VARCHAR2(32000);
   spec_comb_control_type_list_ VARCHAR2(32000);
   spec_ctrl_type_1_value_list_ VARCHAR2(32000);
   spec_ctrl_type_2_value_list_ VARCHAR2(32000);
   update_method_list_          VARCHAR2(32000);
   copy_type_                   VARCHAR2(100);
   attr1_                       VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         source_company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'CODE_PART_LIST') THEN
         code_part_list_ := value_;
      ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
         posting_type_list_ := value_;
      ELSIF (name_ = 'PC_VALID_FROM_LIST') THEN
         pc_valid_from_list_ := value_; 
      ELSIF (name_ = 'CONTROL_TYPE_VALUE_LIST') THEN
         control_type_value_list_ := value_;  
      ELSIF (name_ = 'VALID_FROM_LIST') THEN
         valid_from_list_ := value_;  
      ELSIF (name_ = 'SPEC_COMB_CONTROL_TYPE_LIST') THEN
         spec_comb_control_type_list_ := value_;  
      ELSIF (name_ = 'SPEC_CTRL_TYPE_1_VALUE_LIST') THEN
         spec_ctrl_type_1_value_list_ := value_;  
      ELSIF (name_ = 'SPEC_CTRL_TYPE_2_VALUE_LIST') THEN
         spec_ctrl_type_2_value_list_ := value_;           
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
                      code_part_list_,
                      pc_valid_from_list_,
                      posting_type_list_,
                      control_type_value_list_,
                      valid_from_list_,
                      spec_comb_control_type_list_,
                      spec_ctrl_type_1_value_list_,
                      spec_ctrl_type_2_value_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_              IN VARCHAR2,
   target_company_list_         IN VARCHAR2,
   code_part_list_              IN VARCHAR2,
   pc_valid_from_list_          IN VARCHAR2,   
   posting_type_list_           IN VARCHAR2,
   control_type_value_list_     IN VARCHAR2,
   valid_from_list_             IN VARCHAR2,
   spec_comb_control_type_list_ IN VARCHAR2,
   spec_ctrl_type_1_value_list_ IN VARCHAR2,
   spec_ctrl_type_2_value_list_ IN VARCHAR2,
   update_method_list_          IN VARCHAR2,
   copy_type_                   IN VARCHAR2,
   attr_                        IN VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_ctrl_comb_det_spec IS TABLE OF posting_ctrl_comb_det_spec_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                                 
   ptr_                            NUMBER;
   ptr1_                           NUMBER;
   ptr2_                           NUMBER;
   i_                              NUMBER;
   update_method_                  VARCHAR2(20);
   value_                          VARCHAR2(2000);
   target_company_                 posting_ctrl_comb_det_spec_tab.company%TYPE;
   ref_post_ctrl_comb_det_spec_    posting_ctrl_comb_det_spec;
   ref_attr_                       attr;
   log_id_                         NUMBER;
   attr_value_                     VARCHAR2(32000) := NULL;   
BEGIN
   ptr_  := NULL;
   ptr2_ := NULL;
   ptr1_ := NULL;
   i_    := 0;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).code_part := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pc_valid_from_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).pc_valid_from := Client_SYS.Attr_Value_To_Date(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).posting_type := value_;
      i_ := i_ + 1; 
   END LOOP;
  
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_value_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).control_type_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, valid_from_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).valid_from := Client_SYS.Attr_Value_To_Date(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_comb_control_type_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).spec_comb_control_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_ctrl_type_1_value_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).spec_control_type1_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, spec_ctrl_type_2_value_list_) LOOP
      ref_post_ctrl_comb_det_spec_(i_).spec_control_type2_value := value_;
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
         FOR j_ IN ref_post_ctrl_comb_det_spec_.FIRST..ref_post_ctrl_comb_det_spec_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_post_ctrl_comb_det_spec_(j_).code_part,
                                 ref_post_ctrl_comb_det_spec_(j_).pc_valid_from,                                 
                                 ref_post_ctrl_comb_det_spec_(j_).posting_type,
                                 ref_post_ctrl_comb_det_spec_(j_).control_type_value,
                                 ref_post_ctrl_comb_det_spec_(j_).valid_from,
                                 ref_post_ctrl_comb_det_spec_(j_).spec_comb_control_type,
                                 ref_post_ctrl_comb_det_spec_(j_).spec_control_type1_value,
                                 ref_post_ctrl_comb_det_spec_(j_).spec_control_type2_value,                                 
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

PROCEDURE Insert_Post_Ctrl_Comb_Det_Spec (
   company_                   IN VARCHAR2,
   posting_type_              IN VARCHAR2,
   code_part_                 IN VARCHAR2,
   pc_valid_from_             IN DATE,
   control_type_value_        IN VARCHAR2,
   valid_from_                IN DATE,
   spec_comb_control_type_    IN VARCHAR2,
   spec_control_type1_        IN VARCHAR2,
   spec_control_type1_value_  IN VARCHAR2,
   spec_module1_              IN VARCHAR2,
   spec_control_type2_        IN VARCHAR2,
   spec_control_type2_value_  IN VARCHAR2,
   spec_module2_              IN VARCHAR2,
   code_part_value_           IN VARCHAR2,
   no_code_part_value_db_     IN VARCHAR2 DEFAULT 'FALSE' )
IS
   newrec_                 posting_ctrl_comb_det_spec_tab%ROWTYPE;
   tmp_pc_valid_from_      DATE;
   dummy_                  NUMBER;

   CURSOR get_posting IS
      SELECT 1
      FROM   POSTING_CTRL_COMB_DET_SPEC_TAB
      WHERE company = company_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      AND   posting_type = posting_type_
      AND   control_type_value = control_type_value_
      AND   valid_from = valid_from_
      AND   spec_comb_control_type = spec_comb_control_type_
      AND   spec_control_type1_value = spec_control_type1_value_
      AND   spec_control_type2_value = spec_control_type2_value_;
      
   CURSOR check_master IS
      SELECT 1
      FROM   POSTING_CTRL_DETAIL_TAB
      WHERE  company            = company_
      AND    posting_type       = posting_type_
      AND    code_part          = code_part_
      AND    pc_valid_from      = tmp_pc_valid_from_
      AND    control_type_value = control_type_value_
      AND    valid_from         = valid_from_;
BEGIN

   tmp_pc_valid_from_ := nvl(pc_valid_from_, Company_Finance_API.Get_Valid_From(company_));
   
   -- don't insert details if master doesn't exist
   OPEN  check_master;
   FETCH check_master INTO dummy_;
   IF check_master%notfound THEN
      CLOSE check_master;
      RETURN;
   ELSE
      CLOSE check_master;
   END IF;

   IF (Company_Finance_API.Is_User_Authorized(company_ )) THEN
      OPEN get_posting;
      FETCH get_posting INTO dummy_;
      IF get_posting%found THEN
         CLOSE get_posting;
      ELSE
         CLOSE get_posting;      
         newrec_.company                  := company_;
         newrec_.posting_type             := posting_type_;
         newrec_.code_part                := code_part_;
         newrec_.pc_valid_from            := trunc(tmp_pc_valid_from_);
         newrec_.control_type_value       := control_type_value_;
         newrec_.valid_from               := valid_from_;
         newrec_.spec_comb_control_type   := spec_comb_control_type_;
         newrec_.spec_control_type1       := spec_control_type1_;
         newrec_.spec_control_type1_value := spec_control_type1_value_;
         newrec_.spec_module1             := spec_module1_;
         newrec_.spec_control_type2       := spec_control_type2_;
         newrec_.spec_control_type2_value := spec_control_type2_value_;
         newrec_.spec_module2             := spec_module2_;
         newrec_.code_part_value          := code_part_value_;
         newrec_.no_code_part_value       := no_code_part_value_db_;

         New___(newrec_);
      END IF;
   END IF;
   
END Insert_Post_Ctrl_Comb_Det_Spec;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Account_Exist (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 )
IS
   postings_   NUMBER;
   CURSOR check_account IS
      SELECT 1
        FROM POSTING_CTRL_COMB_DET_SPEC_TAB
       WHERE company         = company_ 
         AND code_part       = 'A'
         AND code_part_value = account_;
BEGIN
   OPEN check_account;
   FETCH check_account INTO postings_;
   IF (check_account%FOUND) THEN
      CLOSE check_account;
      Error_SYS.Record_General('PostingCtrlCombDetSpec', 'ACCNTEXISTS: The account :P1 exists in posting control ', account_);
   END IF;
   CLOSE check_account;
END Account_Exist;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Remove_Post_Ctrl_Comb_Det_Spec(
   company_                  IN VARCHAR2,
   code_part_                IN VARCHAR2,
   pc_valid_from_            IN DATE,
   posting_type_             IN VARCHAR2,
   control_type_value_       IN VARCHAR2,
   valid_from_               IN DATE,
   spec_comb_control_type_   IN VARCHAR2,
   spec_control_type1_value_ IN VARCHAR2,
   spec_control_type2_value_ IN VARCHAR2)
IS
   dummy_info_ VARCHAR2(2000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   Get_Id_Version_By_Keys___(objid_,
                             objversion_,
                             company_,
                             code_part_,
                             pc_valid_from_,
                             posting_type_,
                             control_type_value_,
                             valid_from_,
                             spec_comb_control_type_,
                             spec_control_type1_value_,
                             spec_control_type2_value_);
      Remove__(dummy_info_,
               objid_,
               objversion_,
               'DO');
END Remove_Post_Ctrl_Comb_Det_Spec;

PROCEDURE New_Rec(
   newrec_     IN OUT Posting_Ctrl_Comb_Det_Spec_Tab%ROWTYPE)
IS
BEGIN
   New___(newrec_);
END New_Rec;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                          NUMBER;
   name_                         VARCHAR2(200);
   value_                        VARCHAR2(32000);
   source_company_               VARCHAR2(100);
   code_part_list_               VARCHAR2(2000);
   posting_type_list_            VARCHAR2(2000);
   pc_valid_from_list_           VARCHAR2(2000);
   control_type_value_list_      VARCHAR2(2000);
   valid_from_list_              VARCHAR2(2000);
   spec_comb_control_type_list_  VARCHAR2(2000);
   spec_ctrl_type_1_value_list_  VARCHAR2(2000);
   spec_ctrl_type_2_value_list_  VARCHAR2(2000);
   target_company_list_          VARCHAR2(2000);
   update_method_list_           VARCHAR2(2000);
   attr1_                        VARCHAR2(32000);
   run_in_background_attr_       VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Posting_Ctrl_Comb_Det_Spec_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'CODE_PART_LIST') THEN
            code_part_list_ := value_;
         ELSIF (name_ = 'PC_VALID_FROM_LIST') THEN
            pc_valid_from_list_ := value_; 
         ELSIF (name_ = 'POSTING_TYPE_LIST') THEN
            posting_type_list_ := value_;
         ELSIF (name_ = 'CONTROL_TYPE_VALUE_LIST') THEN
            control_type_value_list_ := value_; 
         ELSIF (name_ = 'VALID_FROM_LIST') THEN
            valid_from_list_ := value_; 
         ELSIF (name_ = 'SPEC_COMB_CONTROL_TYPE_LIST') THEN
            spec_comb_control_type_list_ := value_;
         ELSIF (name_ = 'SPEC_CTRL_TYPE_1_VALUE_LIST') THEN
            spec_ctrl_type_1_value_list_ := value_; 
         ELSIF (name_ = 'SPEC_CTRL_TYPE_2_VALUE_LIST') THEN
            spec_ctrl_type_2_value_list_ := value_; 
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  code_part_list_,
                                  posting_type_list_,
                                  pc_valid_from_list_,
                                  control_type_value_list_,
                                  valid_from_list_,
                                  spec_comb_control_type_list_,
                                  spec_ctrl_type_1_value_list_,
                                  spec_ctrl_type_2_value_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_        IN VARCHAR2)
IS
BEGIN
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN  
      DELETE 
         FROM POSTING_CTRL_COMB_DET_SPEC_TAB
         WHERE company = company_; 
   END IF;      
END Remove_Company;

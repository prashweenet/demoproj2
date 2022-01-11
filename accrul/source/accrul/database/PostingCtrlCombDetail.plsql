-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlCombDetail
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000214  SaCh  Created.
--  000330  SaCh  Corrected Bug # 70483.
--  000403  SaCh  Added procedure Delete_Comb_Detail in order to correct bug # 70491.
--  000705  LeKa  A521: Added tax_flag.
--  000804  SaCh  Corrected Call # 73806
--  000914  HiMu  Added General_SYS.Init_Method
--  001016  Bren  Added 2 description fields...
--  001024  LiSv  Call #50936 Corrected. Added parameter to Posting_Ctrl_Detail_API.Validate_Control_Type_Value__.
--  020828  Rora  Bug 31910 corrected (removed columns CONTROL_TYPE1_DESCRIPTION and CONTROL_TYPE2_DESCRIPTION; on 
--                 client replaced with procedure call).
--  021227  Hecolk SP3 Merge. Bug 32500 and Bug 32453 are Merged.  
--  030106  dagalk SP3 Merge. Bug 31910 recorrected ..  
--  030227  mgutse Bug 94305. New key in LU IncomeType. 
--  030305  mgutse Bug 94305. New key in LU Type1099.
--  030804  Nimalk SP4 Merge 
--  050523  reanpl FIAD376 Actual Costing - added pc_valid_from column, removed valid_until
--  060308  Thpelk Call Id 136469 Removed the setting the SYSDATE to the VALID_FROM in Prepare_Insert___
--                 and added validation to the VALID_FROM when saving. 
--  060925  THAYLK LCS Merge Bug 59300, Added functions Is_Led_Account_Used and Is_Tax_Account_Used
--  070320  Shsalk  LCS Merge 63645, Corrected.Added validation for the statistical account in unpack_check_insert
--                  and unpack_check_update.
--  071203  Maselk Bug 67620 Corrected. Modified the view comments of POSTING_CTRL_COMB_DETAIL.
--  100108  HimRlk Reverse engineering correction, Changed code_part in to a parent key and added REF to PostingCtrl in view comments.
--  100423  SaFalk Modified REF for pc_valid_from in POSTING_CTRL_COMB_DETAIL.
--  111020  ovjose Added no_code_part_value
--  120514  SALIDE EDEL-698, Added VIEW_AUDI
--  140409  THPELK PBFI-4377, LCS Merge (Bug 113342).
--  181823  Nudilk Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
--  200213  Snuwlk Bug 152362, Corrected.
--  200213  Snuwlk Bug 152408, Corrected.
--  200325  Chwtlk Bug 152941, Introduced new function Get_Control_Type_Value.
--  200331  Chwtlk Bug 153095, Added UncheckedAccess to Get_Control_Type_Value.
--  200401  Snuwlk Bug 153124, Corrected.
--  200701  Tkavlk  Bug 154601, Added Remove_company

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

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
   --Client_SYS.Add_To_Attr('VALID_FROM', sysdate, attr_);
   Client_SYS.Add_To_Attr('NO_CODE_PART_VALUE_DB', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT posting_ctrl_comb_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_          VARCHAR2(30);
   value_         VARCHAR2(4000);   
   internal_id_   NUMBER;   
BEGIN
   indrec_.pc_valid_from := FALSE;
   IF (newrec_.no_code_part_value IS NULL) THEN
      newrec_.no_code_part_value := 'FALSE';
      indrec_.no_code_part_value := TRUE;
   END IF;
   
   IF (newrec_.comb_module IS NULL) THEN
      newrec_.comb_module := Posting_Ctrl_Posting_Type_API.Get_Module(newrec_.posting_type);
   END IF;
   
   super(newrec_, indrec_, attr_);

   Posting_Ctrl_API.Exist(newrec_.company, newrec_.code_part, newrec_.posting_type, newrec_.pc_valid_from);
   IF (newrec_.code_part_value IS NOT NULL) THEN
      Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.code_part_value);
   END IF;
   
   
   IF (newrec_.no_code_part_value = 'FALSE') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'CODE_PART_VALUE', newrec_.code_part_value);
   END IF;

   Validate_Record___(newrec_);
   
   IF newrec_.control_type1_value != '%' THEN
      IF (newrec_.control_type1 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id 
         -- that should be saved.  
         newrec_.control_type1_value := Income_Type_API.Get_Internal_Income_Type(newrec_.control_type1_value,
                                                                                Company_Finance_API.Get_Currency_Code(newrec_.company),
                                                                                Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.control_type1 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save 
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.control_type1_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.control_type1_value := internal_id_;
         $ELSE
            NULL;
         $END
      END IF;      
      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.control_type1_value, 
                                                            newrec_.control_type1, newrec_.module1, newrec_.posting_type );
   END IF;

   IF (newrec_.control_type2_value != '%') THEN
      IF (newrec_.control_type2 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id 
         -- that should be saved.  
         newrec_.control_type2_value := Income_Type_API.Get_Internal_Income_Type(newrec_.control_type2_value,
                                                                                Company_Finance_API.Get_Currency_Code(newrec_.company),
                                                                                Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.control_type2 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save 
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.control_type2_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.control_type2_value := internal_id_;
         $ELSE
            NULL;
         $END
      END IF;
      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.control_type2_value, 
                                                               newrec_.control_type2, newrec_.module2, newrec_.posting_type );
   END IF;

   IF (newrec_.code_part IS NULL) AND (newrec_.code_part_name IS NOT NULL) THEN
      Accounting_Code_Parts_API.Get_Code_Part(newrec_.code_part, newrec_.company, newrec_.code_part_name);
   END IF;
   
   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

PROCEDURE Validate_Code_Part_Value___(
   newrec_     IN posting_ctrl_comb_detail_tab%ROWTYPE )
IS
   ledg_flag_     VARCHAR2(1);
   module_        VARCHAR2(10);
   description_   VARCHAR2(200);
   tax_flag_      VARCHAR2(1); 
BEGIN
   Posting_Ctrl_Posting_Type_API.Get_Posting_Type_Attri_ ( description_, module_, ledg_flag_, tax_flag_, newrec_.posting_type ); 
   IF (newrec_.code_part_value IS NOT NULL) THEN
      IF (Accounting_Code_Part_Value_API.Is_Budget_Code_Part(newrec_.company, newrec_.code_part, newrec_.code_part_value)) THEN
         IF(newrec_.code_part ='A') THEN
            Error_SYS.Record_General(lu_name_, 'BUDACCNT: :P1 is a budget account and not valid for posting type :P2', newrec_.code_part_value, newrec_.posting_type);
         ELSE
            Error_SYS.Record_General(lu_name_, 'BUDCODEPART: :P1 is a Budget/Planning Only code part value and cannot be used in Posting Control.', newrec_.code_part_value);
         END IF;
      END IF;   
      IF (newrec_.code_part = 'A') THEN      
         IF ( ledg_flag_ = 'Y' ) THEN
            IF (NOT Account_API.Is_Ledger_Account( newrec_.company, newrec_.code_part_value )) THEN
               Error_SYS.Record_General(lu_name_, 'NOLEDGACCNT: :P1 is no ledger account', newrec_.code_part_value);
            END IF;
         END IF;
         IF ( tax_flag_ = 'Y' ) THEN         
            IF (NOT Account_API.Is_Tax_Account( newrec_.company, newrec_.code_part_value )) THEN
               Error_SYS.Record_General(lu_name_, 'NOTAXACCNT: :P1 is no tax account', newrec_.code_part_value);
            END IF;
         END IF;   
         IF (Account_API.Is_Stat_Account(newrec_.company, newrec_.code_part_value ) = 'TRUE') THEN
             Error_SYS.Record_General(lu_name_, 'STATACC: :P1 is a statistical account', newrec_.code_part_value);
         END IF;
      END IF;
   END IF;
END Validate_Code_Part_Value___;   


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     posting_ctrl_comb_detail_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_comb_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_        VARCHAR2(30);
   value_       VARCHAR2(4000);   
   internal_id_ NUMBER;
BEGIN
   IF (newrec_.comb_module IS NULL) THEN
      newrec_.comb_module := Posting_Ctrl_Posting_Type_API.Get_Module(newrec_.posting_type);
      indrec_.comb_module := TRUE;
   END IF;

   IF (newrec_.no_code_part_value IS NULL) THEN
      newrec_.no_code_part_value := 'FALSE';
      indrec_.no_code_part_value := TRUE;
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'CONTROL_TYPE1', newrec_.control_type1);
   Error_SYS.Check_Not_Null(lu_name_, 'CONTROL_TYPE2', newrec_.control_type2);
   
   IF newrec_.control_type2_value != '%' THEN
      IF (newrec_.control_type2 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id 
         -- that should be saved.  
         newrec_.control_type2_value := Income_Type_API.Get_Internal_Income_Type(value_,
                                                                                 Company_Finance_API.Get_Currency_Code(newrec_.company),
                                                                                 Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.control_type2 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save 
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.control_type2_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.control_type2_value := internal_id_;
         $ELSE
            NULL;
         $END         
      END IF;
   END IF;
   
   IF newrec_.control_type1_value != '%' THEN
      IF (newrec_.control_type1 = 'IC7') THEN
         -- Control type IC7, Income Type, needs currency code and country_code to get the internal id 
         -- that should be saved.  
         newrec_.control_type1_value := Income_Type_API.Get_Internal_Income_Type(value_,
         Company_Finance_API.Get_Currency_Code(newrec_.company),
         Company_API.Get_Country_Db(newrec_.company));
      ELSIF (newrec_.control_type1 = 'IC8') THEN
         -- Control type IC8, Irs1099_Type_Id, needs country_code to get the internal id to save 
         $IF Component_Invoic_SYS.INSTALLED $THEN
            internal_id_ := Type1099_API.Get_Internal_Type1099(newrec_.control_type1_value, Company_API.Get_Country_Db(newrec_.company)); 
            newrec_.control_type1_value := internal_id_;
         $ELSE
            NULL;
         $END         
      END IF;
   END IF;   
         
   IF (newrec_.no_code_part_value = 'FALSE') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'CODE_PART_VALUE', newrec_.code_part_value);
   END IF;
   
   IF (newrec_.code_part_value IS NOT NULL) THEN   
      Accounting_Code_Part_Value_API.Exist(newrec_.company, newrec_.code_part, newrec_.code_part_value);
   END IF;
   
   Validate_Record___(newrec_);   

   IF (newrec_.control_type1_value != '%') THEN      
      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.control_type1_value, 
                                                               newrec_.control_type1, newrec_.module1, newrec_.posting_type );
   END IF;

   IF (newrec_.control_type2_value != '%') THEN
      Posting_Ctrl_Detail_API.Validate_Control_Type_Value__(newrec_.company, newrec_.control_type2_value, 
                                                               newrec_.control_type2, newrec_.module2, newrec_.posting_type );
   END IF;

   IF (newrec_.code_part IS NULL) AND (newrec_.code_part_name IS NOT NULL) THEN
      Accounting_Code_Parts_API.Get_Code_Part(newrec_.code_part, newrec_.company, newrec_.code_part_name);
   END IF;
   Validate_Code_Part_Value___(newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

PROCEDURE Validate_Record___(
   newrec_ IN posting_ctrl_comb_detail_tab%ROWTYPE )
IS
   com_cont_rec_ comb_control_type_tab%ROWTYPE;
BEGIN       

   Comb_Control_Type_API.Get_Control_Type1_Type2(com_cont_rec_.control_type1, com_cont_rec_.control_type2, newrec_.company, newrec_.posting_type, newrec_.comb_control_type);
   
   IF(com_cont_rec_.control_type1 IS NULL OR com_cont_rec_.control_type2 IS NULL OR newrec_.control_type1 != com_cont_rec_.control_type1 OR newrec_.control_type2 != com_cont_rec_.control_type2) THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDCCTYPE: The value you have entered for [COMB_CONTROL_TYPE] is invalid.');
   END IF;
   
   IF (newrec_.comb_module != Posting_Ctrl_Posting_Type_API.Get_Module(newrec_.posting_type)) THEN 
      Error_SYS.Record_General(lu_name_, 'INVALIDCMODULE: The value you have entered for [COM_MODULE] is invalid.');
   END IF;
   
   
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

   IF Trunc(newrec_.valid_from) < trunc(newrec_.pc_valid_from) THEN
      Error_SYS.Record_General(lu_name_, 'POSTCMBDETVALFROM: Detail Valid From date should be equal or grater than parent Valid From date.');
   END IF;

   IF newrec_.control_type1_value = '%' AND newrec_.control_type2_value = '%' THEN
      Error_SYS.Appl_General( lu_name_, 'POSTCMBDET01: Value % is not allowed for both control types at the same time.');
   END IF;
END Validate_Record___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     posting_ctrl_comb_detail_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_comb_detail_tab%ROWTYPE,
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
   remrec_ IN posting_ctrl_comb_detail_tab%ROWTYPE )
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
   source_company_            IN  VARCHAR2,
   target_company_list_       IN  VARCHAR2,
   code_part_list_            IN  VARCHAR2,
   posting_type_list_         IN  VARCHAR2,
   pc_valid_from_list_        IN  VARCHAR2,  
   comb_control_type_list_    IN  VARCHAR2,  
   control_type_1_list_       IN  VARCHAR2,  
   control_type_1_value_list_ IN  VARCHAR2,  
   control_type_2_list_       IN  VARCHAR2,  
   control_type_2_value_list_ IN  VARCHAR2,  
   valid_from_list_           IN  VARCHAR2,  
   update_method_list_        IN  VARCHAR2,
   log_id_                    IN  NUMBER,
   attr_                      IN  VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_control IS TABLE OF posting_ctrl_comb_detail_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         posting_ctrl_comb_detail_tab.company%TYPE;
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
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, comb_control_type_list_) LOOP
      ref_posting_control_(i_).comb_control_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_1_list_) LOOP
      ref_posting_control_(i_).control_type1 := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_1_value_list_) LOOP
      ref_posting_control_(i_).control_type1_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_2_list_) LOOP
      ref_posting_control_(i_).control_type2 := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_2_value_list_) LOOP
      ref_posting_control_(i_).control_type2_value := value_;
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
                                 ref_posting_control_(j_).posting_type,                            
                                 ref_posting_control_(j_).pc_valid_from,
                                 ref_posting_control_(j_).code_part,
                                 ref_posting_control_(j_).comb_control_type,
                                 ref_posting_control_(j_).control_type1,
                                 ref_posting_control_(j_).control_type1_value,
                                 ref_posting_control_(j_).control_type2,
                                 ref_posting_control_(j_).control_type2_value,
                                 ref_posting_control_(j_).valid_from,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
   
PROCEDURE Copy_To_Companies__ (
   source_company_       IN VARCHAR2,
   target_company_       IN VARCHAR2,
   posting_type_         IN VARCHAR2,   
   pc_valid_from_        IN DATE,   
   code_part_            IN VARCHAR2,
   comb_control_type_    IN VARCHAR2,
   control_type_1_       IN VARCHAR2,
   control_type_1_value_ IN VARCHAR2,
   control_type_2_       IN VARCHAR2,
   control_type_2_value_ IN VARCHAR2,   
   valid_from_           IN DATE,
   update_method_        IN VARCHAR2,
   log_id_               IN NUMBER,
   attr_                 IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              posting_ctrl_comb_detail_tab%ROWTYPE;
   target_rec_              posting_ctrl_comb_detail_tab%ROWTYPE;
   old_target_rec_          posting_ctrl_comb_detail_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, 
                                        posting_type_, 
                                        pc_valid_from_, 
                                        code_part_, 
                                        comb_control_type_, 
                                        control_type_1_, 
                                        control_type_1_value_, 
                                        control_type_2_,
                                        control_type_2_value_,
                                        valid_from_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, 
                                            posting_type_, 
                                            pc_valid_from_, 
                                            code_part_, 
                                            comb_control_type_, 
                                            control_type_1_, 
                                            control_type_1_value_, 
                                            control_type_2_,
                                            control_type_2_value_,
                                            valid_from_);
   log_key_ := posting_type_ || '^' || TO_CHAR(pc_valid_from_) || '^' || code_part_ || '^' || comb_control_type_ || '^' || control_type_1_ || '^' ||
               control_type_1_value_ || '^' || control_type_2_ || '^' || control_type_2_value_ || '^' || TO_CHAR(valid_from_);
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
                                posting_type_, 
                                pc_valid_from_, 
                                code_part_, 
                                comb_control_type_, 
                                control_type_1_, 
                                control_type_1_value_, 
                                control_type_2_,
                                control_type_2_value_,
                                valid_from_);
      
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

PROCEDURE Update_Pc_Valid_From_(
   company_            IN VARCHAR2,
   posting_type_       IN VARCHAR2,
   code_part_          IN VARCHAR2,
   pc_valid_from_      IN DATE,
   new_pc_valid_from_  IN DATE)
IS
   CURSOR get_row_for_update IS
      SELECT *
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE company = company_
      AND   posting_type = posting_type_
      AND   code_part = code_part_
      AND   pc_valid_from = pc_valid_from_
      FOR UPDATE NOWAIT;
BEGIN
   FOR rec_ IN get_row_for_update LOOP
      UPDATE POSTING_CTRL_COMB_DETAIL_TAB
         SET pc_valid_from = new_pc_valid_from_
      WHERE CURRENT OF get_row_for_update;
   END LOOP;
END Update_Pc_Valid_From_;


-- Get_Code_Part_Value_Ex_
--   The method returns the code_part_value as well as the flag no_code_part_value (which if TRUE defines that code_part_value is allowed and should be null)
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Code_Part_Value_Ex_ (
   code_part_value_     OUT VARCHAR2,
   no_code_part_value_  OUT VARCHAR2,
   company_             IN VARCHAR2,
   comb_module_         IN VARCHAR2,
   posting_type_        IN VARCHAR2,
   code_part_           IN VARCHAR2,
   date_                IN DATE,
   comb_control_type_   IN VARCHAR2,
   control_type_attr_   IN VARCHAR2 )

IS
   control_type1_       VARCHAR2(10);
   control_type2_       VARCHAR2(10);
   control_type1_value_ VARCHAR2(100);
   control_type2_value_ VARCHAR2(100);
   ptr_                 NUMBER;
   name_                VARCHAR2(100);
   value_               VARCHAR2(2000);
   
   CURSOR codepartvalue IS
      SELECT code_part_value, no_code_part_value
        FROM POSTING_CTRL_COMB_DETAIL_TAB
       WHERE company             = company_
         AND comb_module         = comb_module_
         AND posting_type        = posting_type_
         AND comb_control_type   = comb_control_type_
         AND code_part           = code_part_
         AND control_type1       = control_type1_
         AND control_type2       = control_type2_
         AND control_type1_value = control_type1_value_
         AND control_type2_value = control_type2_value_
         AND valid_from =  (SELECT MAX(valid_from)
                            FROM  POSTING_CTRL_COMB_DETAIL_TAB
                            WHERE company            = company_
                              AND comb_module         = comb_module_
                              AND posting_type        = posting_type_
                              AND comb_control_type   = comb_control_type_
                              AND code_part           = code_part_
                              AND control_type1       = control_type1_
                              AND control_type2       = control_type2_
                              AND control_type1_value = control_type1_value_
                              AND control_type2_value = control_type2_value_
                              AND valid_from        <= date_);
BEGIN
   Comb_Control_Type_API.Get_Control_Type1_Type2(control_type1_, control_type2_,
                                          company_, posting_type_, comb_control_type_);
   WHILE (Client_SYS.Get_Next_From_Attr(control_type_attr_, ptr_, name_, value_)) LOOP
      IF (name_ = control_type1_ ) THEN
         control_type1_value_ := value_;
      ELSIF (name_ = control_type2_ ) THEN
         control_type2_value_ := value_;
      END IF;
   END LOOP;
   OPEN codepartvalue;
   FETCH codepartvalue INTO code_part_value_, no_code_part_value_;
   CLOSE codepartvalue;
END Get_Code_Part_Value_Ex_;


PROCEDURE Copy_To_Companies_(
   attr_ IN  VARCHAR2)
IS
   ptr_                       NUMBER;
   name_                      VARCHAR2(200);
   value_                     VARCHAR2(32000);
   source_company_            VARCHAR2(100);
   target_company_list_       VARCHAR2(32000);
   code_part_list_            VARCHAR2(32000);
   posting_type_list_         VARCHAR2(32000);
   pc_valid_from_list_        VARCHAR2(32000);
   comb_control_type_list_    VARCHAR2(32000);
   control_type_1_list_       VARCHAR2(32000);
   control_type_1_value_list_ VARCHAR2(32000);
   control_type_2_list_       VARCHAR2(32000);
   control_type_2_value_list_ VARCHAR2(32000);
   valid_from_list_           VARCHAR2(32000);
   update_method_list_        VARCHAR2(32000);
   copy_type_                 VARCHAR2(100);
   attr1_                     VARCHAR2(32000);
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
      ELSIF (name_ = 'COMB_CONTROL_TYPE_LIST') THEN
         comb_control_type_list_ := value_;
      ELSIF (name_ = 'CONTROL_TYPE_1_LIST') THEN
         control_type_1_list_ := value_;
      ELSIF (name_ = 'CONTROL_TYPE_1_VALUE_LIST') THEN
         control_type_1_value_list_ := value_;
      ELSIF (name_ = 'CONTROL_TYPE_2_LIST') THEN
         control_type_2_list_ := value_;
      ELSIF (name_ = 'CONTROL_TYPE_2_VALUE_LIST') THEN
         control_type_2_value_list_ := value_;           
      ELSIF (name_ = 'VALID_FROM_LIST') THEN
         valid_from_list_ := value_;                    
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
                      posting_type_list_,
                      pc_valid_from_list_,                      
                      code_part_list_,
                      comb_control_type_list_,
                      control_type_1_list_,
                      control_type_1_value_list_,
                      control_type_2_list_,
                      control_type_2_value_list_,                      
                      valid_from_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_            IN VARCHAR2,
   target_company_list_       IN VARCHAR2,
   posting_type_list_         IN VARCHAR2,
   pc_valid_from_list_        IN VARCHAR2,   
   code_part_list_            IN VARCHAR2,
   comb_control_type_list_    IN VARCHAR2,
   control_type_1_list_       IN VARCHAR2,
   control_type_1_value_list_ IN VARCHAR2,
   control_type_2_list_       IN VARCHAR2,
   control_type_2_value_list_ IN VARCHAR2,                      
   valid_from_list_           IN VARCHAR2,   
   update_method_list_        IN VARCHAR2,
   copy_type_                 IN VARCHAR2,
   attr_                      IN VARCHAR2 DEFAULT NULL)
IS
   TYPE posting_ctrl_comb_detail IS TABLE OF posting_ctrl_comb_detail_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                          NUMBER;
   ptr1_                         NUMBER;
   ptr2_                         NUMBER;
   i_                            NUMBER;
   update_method_                VARCHAR2(20);
   value_                        VARCHAR2(2000);
   target_company_               posting_ctrl_comb_detail_tab.company%TYPE;
   ref_posting_ctrl_comb_detail_ posting_ctrl_comb_detail;
   ref_attr_                     attr;
   log_id_                       NUMBER;
   attr_value_                   VARCHAR2(32000) := NULL;   
BEGIN
   ptr1_ := NULL;
   ptr2_ := NULL;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).code_part := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_type_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).posting_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pc_valid_from_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).pc_valid_from := Client_SYS.Attr_Value_To_Date(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, comb_control_type_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).comb_control_type := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_1_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).control_type1 := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_1_value_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).control_type1_value := value_;
      i_ := i_ + 1;
   END LOOP;   
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_2_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).control_type2 := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, control_type_2_value_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).control_type2_value := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, valid_from_list_) LOOP
      ref_posting_ctrl_comb_detail_(i_).valid_from := Client_SYS.Attr_Value_To_Date(value_);
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
         FOR j_ IN ref_posting_ctrl_comb_detail_.FIRST..ref_posting_ctrl_comb_detail_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_posting_ctrl_comb_detail_(j_).posting_type,
                                 ref_posting_ctrl_comb_detail_(j_).pc_valid_from,                                 
                                 ref_posting_ctrl_comb_detail_(j_).code_part,
                                 ref_posting_ctrl_comb_detail_(j_).comb_control_type,
                                 ref_posting_ctrl_comb_detail_(j_).control_type1,
                                 ref_posting_ctrl_comb_detail_(j_).control_type1_value,
                                 ref_posting_ctrl_comb_detail_(j_).control_type2,
                                 ref_posting_ctrl_comb_detail_(j_).control_type2_value,
                                 ref_posting_ctrl_comb_detail_(j_).valid_from,
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

PROCEDURE Get_Code_Part (
   company_      IN VARCHAR2,
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2)
IS
   codestring_rec_    VARCHAR2(200);
BEGIN
   Posting_Ctrl_API.Get_Code_Part( codestring_rec_, company_, posting_type_, control_type_, module_ );
END Get_Code_Part;


@UncheckedAccess
FUNCTION Get_Control_Type(
   company_           IN VARCHAR2,
   posting_type_      IN VARCHAR2,
   comb_control_type_ IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ POSTING_CTRL_COMB_DETAIL_TAB.comb_control_type%TYPE;
   CURSOR get_attr IS
      SELECT comb_control_type
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = comb_control_type_;
BEGIN
   OPEN   get_attr;
   FETCH  get_attr INTO temp_;
   CLOSE  get_attr;
   RETURN temp_;
END Get_Control_Type;


-- Get_Code_Part_Value
--   The method returns the code_part_value for the posting ctrl combination details
--   If there are controls on the returned value (code_part_value) then consider to use Get_Code_Part_Value_Ex_ which also returns the flag no_code_part_value
PROCEDURE Get_Code_Part_Value(
   code_part_value_     OUT VARCHAR2,
   company_             IN VARCHAR2,
   comb_module_         IN VARCHAR2,
   posting_type_        IN VARCHAR2,
   code_part_           IN VARCHAR2,
   date_                IN DATE,
   comb_control_type_   IN VARCHAR2,
   control_type_attr_   IN VARCHAR2)
IS
   no_code_part_value_  VARCHAR2(5);
BEGIN
   Get_Code_Part_Value_Ex_(code_part_value_, 
                           no_code_part_value_,
                           company_, 
                           comb_module_,
                           posting_type_, 
                           code_part_, 
                           date_,
                           comb_control_type_, 
                           control_type_attr_);
END Get_Code_Part_Value;


@UncheckedAccess
FUNCTION Is_Control_Type_Cct(
   company_       IN VARCHAR2,
   posting_type_  IN VARCHAR2,
   control_type_  IN VARCHAR2) RETURN BOOLEAN
IS
   dummy_   VARCHAR2(10);
   CURSOR checkcct IS
      SELECT 1 
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_Type = control_type_;
BEGIN
   OPEN  checkcct;
   FETCH checkcct INTO dummy_;
   IF (checkcct%FOUND) THEN      
      CLOSE  checkcct;
      RETURN TRUE;
   END IF;
   CLOSE checkcct;
   RETURN FALSE;
END Is_Control_Type_Cct;


PROCEDURE Get_Control_Types (
   control_type1_       OUT VARCHAR2,
   control_type2_       OUT VARCHAR2,
   company_             IN  VARCHAR2,
   posting_type_        IN  VARCHAR2,
   comb_control_type_   IN  VARCHAR2)
IS
   control_type_1_   VARCHAR2(10);
   control_type_2_   VARCHAR2(10);

   CURSOR getctrltypes IS
      SELECT control_type1, control_type2
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE  company           = company_
      AND    posting_type      = posting_type_
      AND    comb_control_type = comb_control_type_;
BEGIN
   OPEN  getctrltypes;
   FETCH getctrltypes INTO control_type_1_, control_type_2_;
   CLOSE getctrltypes;
   IF getctrltypes%NOTFOUND THEN
      Error_SYS.Record_General(lu_name_, 'NOCCT: Combination control type :P1 does not exist', comb_control_type_);
   END IF;
END Get_Control_Types;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Delete_Comb_Detail(
   info_          OUT VARCHAR2,
   company_       IN  VARCHAR2,
   posting_type_  IN  VARCHAR2,
   code_part_     IN  VARCHAR2,
   pc_valid_from_ IN  DATE)
IS
   objid_        VARCHAR2(200);
   objversion_   VARCHAR2(2000);      
   CURSOR getcombinfo IS
      SELECT rowid, ltrim(lpad(to_char(rowversion,'YYYYMMDDHH24MISS'),2000))
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE  company       = company_
      AND    posting_type  = posting_type_
      AND    code_part     = code_part_
      AND    pc_valid_from = pc_valid_from_;      
BEGIN
   OPEN getcombinfo;
   WHILE (TRUE) LOOP
      FETCH getcombinfo INTO objid_, objversion_;
      EXIT WHEN getcombinfo%NOTFOUND;
      Remove__ ( info_, objid_, objversion_, 'DO' );
   END LOOP;
   CLOSE getcombinfo;
END Delete_Comb_Detail;   


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_Posting_Ctrl_Comb_Det(
   company_               IN VARCHAR2,
   posting_type_          IN VARCHAR2,
   pc_valid_from_         IN DATE,
   comb_control_type_     IN VARCHAR2,
   control_type1_         IN VARCHAR2,
   control_type1_value_   IN VARCHAR2,
   control_type2_         IN VARCHAR2,
   control_type2_value_   IN VARCHAR2,
   comb_module_           IN VARCHAR2,
   module1_               IN VARCHAR2,
   module2_               IN VARCHAR2,
   code_part_             IN VARCHAR2,
   code_part_value_       IN VARCHAR2,
   valid_from_            IN DATE,
   no_code_part_value_db_ IN VARCHAR2 DEFAULT 'FALSE')
IS
   objid_              VARCHAR2(100);
   attr_               VARCHAR2(2000);
   info_               VARCHAR2(2000);
   objversion_         VARCHAR2(2000);
   tmp_pc_valid_from_  DATE;
   dummy_              NUMBER;

   CURSOR get_posting IS
      SELECT 1
      FROM   POSTING_CTRL_COMB_DETAIL_TAB
      WHERE  company = company_
      AND    posting_type = posting_type_
      AND    pc_valid_from = tmp_pc_valid_from_
      AND    comb_control_type = comb_control_type_
      AND    control_type1 = control_type1_
      AND    control_type1_value = control_type1_value_
      AND    control_type2 = control_type2_
      AND    control_type2_value = control_type2_value_
      AND    code_part = code_part_
      AND    valid_from = valid_from_;
BEGIN
   tmp_pc_valid_from_ := Nvl(pc_valid_from_, Company_Finance_API.Get_Valid_From(company_));

   -- don't insert details if master doesn't exist
   BEGIN
      Posting_Ctrl_API.Exist(company_, code_part_, posting_type_, tmp_pc_valid_from_);
   EXCEPTION
      WHEN OTHERS THEN RETURN;
   END;

   OPEN get_posting;
   FETCH get_posting INTO dummy_;
   IF get_posting%found THEN
      CLOSE get_posting;
   ELSE
      CLOSE get_posting;
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr( 'POSTING_TYPE', posting_type_, attr_);
      Client_SYS.Add_To_Attr( 'PC_VALID_FROM', pc_valid_from_, attr_);
      Client_SYS.Add_To_Attr( 'COMB_CONTROL_TYPE', comb_control_type_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE1', control_type1_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE1_VALUE', control_type1_value_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE2', control_type2_, attr_);
      Client_SYS.Add_To_Attr( 'CONTROL_TYPE2_VALUE', control_type2_value_, attr_);            
      Client_SYS.Add_To_Attr( 'COMB_MODULE', comb_module_, attr_);
      Client_SYS.Add_To_Attr( 'MODULE1', module1_, attr_);
      Client_SYS.Add_To_Attr( 'MODULE2', module2_, attr_);
      Client_SYS.Add_To_Attr( 'CODE_PART', code_part_, attr_);
      Client_SYS.Add_To_Attr( 'CODE_PART_NAME', Accounting_Code_Parts_API.Get_Name(company_, code_part_), attr_);
      Client_SYS.Add_To_Attr( 'CODE_PART_VALUE', code_part_value_, attr_);
      Client_SYS.Add_To_Attr( 'VALID_FROM', valid_from_, attr_);
      Client_SYS.Add_To_Attr( 'NO_CODE_PART_VALUE_DB', no_code_part_value_db_, attr_);
      Posting_Ctrl_Comb_Detail_API.New__ ( info_, objid_, objversion_, attr_, 'DO' );
   END IF;
END Insert_Posting_Ctrl_Comb_Det;


@UncheckedAccess
FUNCTION Is_Led_Account_Used(
   company_ IN VARCHAR2,
   account_ IN VARCHAR2) RETURN VARCHAR2
IS
   ledger_account_is_used_   NUMBER;
   CURSOR check_ledger_used IS
      SELECT 1 
      FROM   posting_ctrl_comb_detail_tab pccdt, posting_ctrl_posting_type_tab pcpt
      WHERE  code_part         = 'A' 
      AND    code_part_value   = account_
      AND    company           = company_
      AND    pcpt.ledg_flag    = 'Y'
      AND    pcpt.posting_type = pccdt.posting_type;
BEGIN      
   OPEN check_ledger_used;
   FETCH check_ledger_used INTO ledger_account_is_used_;
   IF (check_ledger_used%FOUND) THEN
      CLOSE check_ledger_used;  
      RETURN 'TRUE';
   END IF;
   CLOSE check_ledger_used;  
   RETURN 'FALSE';
END Is_Led_Account_Used;


@UncheckedAccess
FUNCTION Is_Tax_Account_Used(
   company_ IN VARCHAR2,
   account_ IN VARCHAR2) RETURN VARCHAR2
IS
   tax_account_is_used_   NUMBER;
   CURSOR check_tax_used IS
      SELECT 1 
      FROM   posting_ctrl_comb_detail_tab pccdt, posting_ctrl_posting_type_tab pcpt
      WHERE  code_part         = 'A' 
      AND    code_part_value   = account_
      AND    company           = company_
      AND    pcpt.tax_flag    = 'Y'
      AND    pcpt.posting_type = pccdt.posting_type;
BEGIN      
   OPEN check_tax_used;
   FETCH check_tax_used INTO tax_account_is_used_;
   IF (check_tax_used%FOUND) THEN
      CLOSE check_tax_used;  
      RETURN 'TRUE';
   END IF;
   CLOSE check_tax_used;  
   RETURN 'FALSE';
END Is_Tax_Account_Used;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Account_Exist(
   company_ IN VARCHAR2,
   account_ IN VARCHAR2)
IS
   postings_   NUMBER;
   CURSOR check_account IS
      SELECT 1
        FROM POSTING_CTRL_COMB_DETAIL_TAB
       WHERE company         = company_
         AND code_part       = 'A'
         AND code_part_value = account_;
BEGIN
   OPEN check_account;
   FETCH check_account INTO postings_;
   IF (check_account%FOUND) THEN
      CLOSE check_account;
      Error_SYS.Record_General('PostingCtrlCombDetail', 'ACCNTEXISTS: The account :P1 exists in posting control ', account_);
   END IF;
   CLOSE check_account;
END Account_Exist;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Remove_Posting_Ctrl_Comb_Det(
   company_             IN VARCHAR2,
   posting_type_        IN VARCHAR2,
   pc_valid_from_       IN DATE,
   code_part_           IN VARCHAR2,
   comb_control_type_   IN VARCHAR2,
   control_type1_       IN VARCHAR2,
   control_type1_value_ IN VARCHAR2,
   control_type2_       IN VARCHAR2,
   control_type2_value_ IN VARCHAR2,
   valid_from_          IN DATE)
IS
   dummy_info_ VARCHAR2(2000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   Get_Id_Version_By_Keys___(objid_,
                             objversion_,
                             company_,
                             posting_type_,
                             pc_valid_from_,
                             code_part_,
                             comb_control_type_,
                             control_type1_,
                             control_type1_value_,
                             control_type2_,
                             control_type2_value_,
                             valid_from_); 
 
   Remove__(dummy_info_,
            objid_,
            objversion_,
            'DO');
END Remove_Posting_Ctrl_Comb_Det;

PROCEDURE Copy_To_Companies_For_Svc(
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                        NUMBER;
   name_                       VARCHAR2(200);
   value_                      VARCHAR2(32000);
   source_company_             VARCHAR2(100);
   code_part_list_             VARCHAR2(2000);
   posting_type_list_          VARCHAR2(2000);
   pc_valid_from_list_         VARCHAR2(2000); 
   comb_control_type_list_     VARCHAR2(2000);
   control_type_1_list_        VARCHAR2(2000);
   control_type_1_value_list_  VARCHAR2(2000);
   control_type_2_list_        VARCHAR2(2000);
   control_type_2_value_list_  VARCHAR2(2000);
   valid_from_list_            VARCHAR2(2000);
   target_company_list_        VARCHAR2(2000);
   update_method_list_         VARCHAR2(2000);
   attr1_                      VARCHAR2(32000);
   run_in_background_attr_     VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Posting_Ctrl_Comb_Detail_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
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
         ELSIF (name_ = 'COMB_CONTROL_TYPE_LIST') THEN
            comb_control_type_list_ := value_;
         ELSIF (name_ = 'CONTROL_TYPE_1_LIST') THEN
            control_type_1_list_ := value_;
         ELSIF (name_ = 'CONTROL_TYPE_1_VALUE_LIST') THEN
            control_type_1_value_list_ := value_; 
         ELSIF (name_ = 'CONTROL_TYPE_2_LIST') THEN
            control_type_2_list_ := value_;
         ELSIF (name_ = 'CONTROL_TYPE_2_VALUE_LIST') THEN
            control_type_2_value_list_ := value_;
         ELSIF (name_ = 'VALID_FROM_LIST') THEN
            valid_from_list_ := value_; 
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
                                   comb_control_type_list_,
                                   control_type_1_list_,
                                   control_type_1_value_list_,
                                   control_type_2_list_,
                                   control_type_2_value_list_,
                                   valid_from_list_,
                                   update_method_list_,
                                   log_id_,
                                   attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

@UncheckedAccess
FUNCTION Get_Control_Type_Value(
   control_type_       IN   VARCHAR2,
   control_type_value_ IN   VARCHAR2) RETURN VARCHAR2
IS
   control_type_value_tmp_   VARCHAR2(100);
BEGIN
   IF (control_type_ = 'IC7') THEN
      control_type_value_tmp_ := Income_Type_API.Get_Income_Type_Id(control_type_value_);
   ELSIF (control_type_ = 'IC8') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         control_type_value_tmp_ := Type1099_API.Get_Irs1099_Type_Id(control_type_value_);
      $ELSE
         control_type_value_tmp_ := NULL;
      $END
   ELSE
      control_type_value_tmp_ := control_type_value_;
   END IF;
   RETURN control_type_value_tmp_;
END Get_Control_Type_Value;   

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_        IN VARCHAR2)
IS
BEGIN 
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN 
      DELETE 
         FROM POSTING_CTRL_COMB_DETAIL_TAB
         WHERE company = company_;
   END IF;      
END Remove_Company;

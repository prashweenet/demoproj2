-----------------------------------------------------------------------------
--
--  Logical unit: VoucherTemplateRow
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  980429  BREN  Created.
--  990720  UMA   Modified with respect to new template.
--  000308  SaCh  Corrected Bug # 33882
--  000309  Uma   Closed dynamic cursors in the Exceptions.
--  000414  SaCh  Added RAISE to exceptions.
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  010221  ToOs  Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010508  JeGu  Bug #21705 Implementation New Dummyinterface
--                Changed Insert__ RETURNING rowid INTO objid_
--  010719  SUMALK Bug 22932 Fixed.(Removed Dynamic Sql and added Execute Immediate).
--  020312  DIFELK Bug# 19026 Corrected. Included project_activity _id in INSERT INTO voucher_template_row_tab.
--  020807  SUMALK Bug 31078 Fixed.
--  040908  AjPelk B117440 A default null param has been added into Validate_Account_Pseudo__
--  090505  Nirplk Bug 79803, Corrected, checked for blocked code parts in Unpack_Check_Update___
--  090810  LaPrlk Bug 79846, Removed the precisions defined for NUMBER type variables.
--  100407  Jaralk Bug 89831, Corrected,Modified in Insert_Table_Without_Amount_ in order to insert 0 
--                 to debit credit entries when creating a templatefrom a voucher excluding amounts
--  111018  Shdilk   SFI-135, Conditional compilation.
--  120606  Clstlk Bug 102101,Modified Unpack_Check_Insert___(),Unpack_Check_Update___() to add validations for Project Activity Id.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121210  Maaylk  PEPA-183, Removed global variables
--  131104  Umdolk PBFI-2126, Refactoring
--  140411  Nirylk PBFI-5614, Added deliv_type_id column and new method Get_Delivery_Type_Description
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE currency_roundings IS RECORD
(         
   currency_rounding_   CURRENCY_CODE_TAB.currency_rounding%TYPE         
);

TYPE curr_rnd IS TABLE OF currency_roundings INDEX BY VARCHAR2(30); 

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     voucher_template_row_tab%ROWTYPE,
   newrec_ IN OUT voucher_template_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   tax_types_event_   VARCHAR2(10) := 'RESTRICTED';
   conversion_factor_   NUMBER;
   currency_rate_       NUMBER;
   inverted_            VARCHAR2(5);
   currency_amount_     NUMBER;
   amount_              NUMBER;
   currency_rounding_   NUMBER;
   currency_rate_type_  Voucher_Row_Tab.currency_type%TYPE;
   base_currency_code_  voucher_template_row_tab.currency_code%TYPE;
   valid_from_          DATE;
   valid_until_         DATE;
   
   CURSOR get_valid_period IS
      SELECT valid_from, valid_until 
      FROM   voucher_template_tab
      WHERE  company   = newrec_.company   
      AND    template  = newrec_.template;
BEGIN   
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'CURRENCY_CODE', newrec_.currency_code);
   IF (indrec_.optional_code AND newrec_.optional_code IS NOT NULL) THEN
      Tax_Handling_Util_API.Validate_Tax_On_Trans(newrec_.company, tax_types_event_, newrec_.optional_code, 'FALSE', NULL, sysdate);
   END IF;
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', newrec_.account);
   IF newrec_.debit_currency_amount IS NOT NULL AND newrec_.credit_currency_amount IS NOT NULL THEN
      Error_SYS.Record_General(lu_name_, 'BOTHCREDITDEBITUSED: Both Debit Amount and Credit Amount fields cannot have values.');
   END IF;

   OPEN get_valid_period;
   FETCH get_valid_period INTO valid_from_, valid_until_;
   CLOSE get_valid_period; 

      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.account, 'A', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_b, 'B', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_c, 'C', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_d, 'D', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_e, 'E', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_f, 'F', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_g, 'G', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_h, 'H', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_i, 'I', valid_from_, valid_until_);
      Accounting_Codestr_API.Validate_Codepart(newrec_.voucher_company , newrec_.code_j, 'J', valid_from_, valid_until_);

   base_currency_code_ := Company_Finance_API.Get_Currency_Code(newrec_.voucher_company);
   currency_rate_type_ := Currency_Type_API.Get_Default_Type( newrec_.voucher_company);

   Currency_Rate_API.Fetch_Currency_Rate_Base( conversion_factor_, currency_rate_, inverted_,  newrec_.voucher_company, newrec_.currency_code, base_currency_code_ , currency_rate_type_, sysdate, 'DUMMY' );

   IF (indrec_.debit_currency_amount OR indrec_.credit_currency_amount OR indrec_.currency_amount) THEN
      IF (newrec_.debit_currency_amount IS NOT NULL ) THEN
         currency_amount_ := newrec_.debit_currency_amount;
      ELSIF (newrec_.credit_currency_amount IS NOT NULL) THEN
         currency_amount_ := newrec_.credit_currency_amount;      
      END IF;
      currency_rounding_ := Currency_Code_API.Get_Currency_Rounding(newrec_.voucher_company, base_currency_code_);
      amount_ := Currency_Amount_API.Calculate_Accounting_Amount (currency_amount_, currency_rate_,conversion_factor_, inverted_ , currency_rounding_);

      IF (currency_amount_ IS NOT NULL ) THEN
         IF (newrec_.debit_currency_amount IS NOT NULL ) THEN
            newrec_.debit_amount := amount_;
            newrec_.credit_amount := NULL;
            newrec_.amount := NVL(newrec_.debit_amount,0) - NVL(newrec_.credit_amount,0);            
         ELSIF (newrec_.credit_currency_amount IS NOT NULL) THEN
            newrec_.debit_amount := NULL;
            newrec_.credit_amount := amount_;            
            newrec_.amount := NVL(newrec_.debit_amount,0) - NVL(newrec_.credit_amount,0);
         END IF;
      END IF;      
   END IF;         
END Check_Common___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT VOUCHER_TEMPLATE_ROW_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   base_curr_rounding_     NUMBER;
   trans_curr_rounding_    NUMBER;
   debit_currency_amount_  NUMBER;
   credit_currency_amount_ NUMBER;
   currency_amount_        NUMBER;
   debit_amount_           NUMBER;
   credit_amount_          NUMBER;
   amount_                 NUMBER;
BEGIN
   base_curr_rounding_  := CURRENCY_CODE_API.Get_currency_rounding(newrec_.voucher_company, Currency_Code_API.Get_Currency_Code(newrec_.voucher_company));
   trans_curr_rounding_ := CURRENCY_CODE_API.Get_currency_rounding(newrec_.voucher_company, newrec_.currency_code);
   
   debit_currency_amount_  := newrec_.debit_currency_amount;
   credit_currency_amount_ := newrec_.credit_currency_amount;
   currency_amount_ := newrec_.currency_amount;
   debit_amount_    := newrec_.debit_amount;
   credit_amount_   := newrec_.credit_amount;
   amount_          := newrec_.amount;
   newrec_.debit_currency_amount  := ROUND(newrec_.debit_currency_amount, trans_curr_rounding_);
   newrec_.credit_currency_amount := ROUND(newrec_.credit_currency_amount, trans_curr_rounding_);
   newrec_.currency_amount := ROUND(newrec_.currency_amount, trans_curr_rounding_);
   newrec_.debit_amount    := ROUND(newrec_.debit_amount, base_curr_rounding_);
   newrec_.credit_amount   := ROUND(newrec_.credit_amount, base_curr_rounding_);
   newrec_.amount   := ROUND(newrec_.amount, base_curr_rounding_);
        
    
   super(objid_, objversion_, newrec_, attr_);
   newrec_.debit_currency_amount  := debit_currency_amount_;
   newrec_.credit_currency_amount := credit_currency_amount_ ;
   newrec_.currency_amount := currency_amount_;
   newrec_.debit_amount    := debit_amount_;
   newrec_.credit_amount   := credit_amount_;
   newrec_.amount          := amount_;
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     VOUCHER_TEMPLATE_ROW_TAB%ROWTYPE,
   newrec_     IN OUT VOUCHER_TEMPLATE_ROW_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   base_curr_rounding_     NUMBER;
   trans_curr_rounding_    NUMBER;   
   debit_currency_amount_  NUMBER;
   credit_currency_amount_ NUMBER;
   currency_amount_        NUMBER;
   debit_amount_           NUMBER;
   credit_amount_          NUMBER;
   amount_                 NUMBER;
BEGIN
   base_curr_rounding_  := CURRENCY_CODE_API.Get_currency_rounding(newrec_.voucher_company, Currency_Code_API.Get_Currency_Code(newrec_.voucher_company));
   trans_curr_rounding_ := CURRENCY_CODE_API.Get_currency_rounding(newrec_.voucher_company, newrec_.currency_code);
   
   debit_currency_amount_  := newrec_.debit_currency_amount;
   credit_currency_amount_ := newrec_.credit_currency_amount;
   currency_amount_ := newrec_.currency_amount;
   debit_amount_    := newrec_.debit_amount;
   credit_amount_   := newrec_.credit_amount;
   amount_          := newrec_.amount;
   
   newrec_.debit_currency_amount  := ROUND(newrec_.debit_currency_amount, trans_curr_rounding_);
   newrec_.credit_currency_amount := ROUND(newrec_.credit_currency_amount, trans_curr_rounding_);
   newrec_.currency_amount := ROUND(newrec_.currency_amount, trans_curr_rounding_);
   newrec_.debit_amount    := ROUND(newrec_.debit_amount, base_curr_rounding_);
   newrec_.credit_amount   := ROUND(newrec_.credit_amount, base_curr_rounding_);
   newrec_.amount   := ROUND(newrec_.amount, base_curr_rounding_);
         
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   newrec_.debit_currency_amount  := debit_currency_amount_;
   newrec_.credit_currency_amount := credit_currency_amount_ ;
   newrec_.currency_amount := currency_amount_;
   newrec_.debit_amount    := debit_amount_;
   newrec_.credit_amount   := credit_amount_;
   newrec_.amount          := amount_;
END Update___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_template_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                   VARCHAR2(30);
   value_                  VARCHAR2(4000);
   is_project_code_part_   VARCHAR2(1);
   is_proj_ext_created_    VARCHAR2(5);
   dummy_codepart_value_   VARCHAR2(20);
   dummy_project_id_       VARCHAR2(20);
   project_origin_         VARCHAR2(30);
   
 CURSOR get_row_no IS
   SELECT  NVL(MAX(row_no)+1,1)
   FROM   VOUCHER_TEMPLATE_ROW_TAB
   WHERE  Company  = newrec_.Company
   AND    Template = newrec_.template;


BEGIN
   newrec_.row_no := 0;
   super(newrec_, indrec_, attr_);
   is_project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(newrec_.voucher_company, 'PRACC');

   IF (is_project_code_part_ = 'B') THEN
      dummy_codepart_value_ := newrec_.code_b;
   ELSIF (is_project_code_part_ = 'C') THEN
      dummy_codepart_value_ := newrec_.code_c;
   ELSIF (is_project_code_part_ = 'D') THEN
      dummy_codepart_value_ := newrec_.code_d;
   ELSIF (is_project_code_part_ = 'E') THEN
      dummy_codepart_value_ := newrec_.code_e;
   ELSIF (is_project_code_part_ = 'F') THEN
      dummy_codepart_value_ := newrec_.code_f;
   ELSIF (is_project_code_part_ = 'G') THEN
      dummy_codepart_value_ := newrec_.code_g;
   ELSIF (is_project_code_part_ = 'H') THEN
      dummy_codepart_value_ := newrec_.code_h;
   ELSIF (is_project_code_part_ = 'I') THEN
      dummy_codepart_value_ := newrec_.code_i;
   ELSIF (is_project_code_part_ = 'J') THEN
      dummy_codepart_value_ := newrec_.code_j;
   END IF;

   dummy_project_id_ := dummy_codepart_value_;

   IF NOT (newrec_.project_activity_id = -123456 ) THEN
      IF newrec_.project_activity_id IS NOT NULL AND dummy_codepart_value_ IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'NOPROJSPECIFIED: A Project must be specified in order for Project Activity Id to have a value');
      END IF;
   END IF;

   $IF Component_Genled_SYS.INSTALLED $THEN
      IF dummy_codepart_value_ IS NOT NULL THEN
            is_proj_ext_created_ := Accounting_Project_Api.Get_Externally_Created ( newrec_.voucher_company, 
                                                                                    dummy_codepart_value_);
      END IF;
      project_origin_:=  ACCOUNTING_PROJECT_API.Get_Project_Origin_Db( newrec_.voucher_company , dummy_codepart_value_);
   $END

   IF (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NULL) THEN
      IF NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.voucher_company, newrec_.account), 'FALSE') = 'FALSE' THEN 
         Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Project Activity Id must have a value for Project :P1', dummy_codepart_value_);
      END IF;

   -- The project_activity_id is assigned a value -123456 during project completion
   ELSIF newrec_.project_activity_id = -123456 THEN
      newrec_.project_activity_id := NULL;
   END IF;

   IF (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NOT NULL) AND (newrec_.project_activity_id > 0 ) 
   AND  NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.voucher_company, newrec_.account), 'FALSE') = 'TRUE' THEN
      Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', newrec_.account);
   END IF;
   
   IF (project_origin_ = 'PROJECT') THEN 
      IF newrec_.project_activity_id IS NOT NULL THEN
         $IF Component_Proj_SYS.INSTALLED $THEN
            Activity_API.Exist(newrec_.project_activity_id);
            dummy_codepart_value_ := substr(Activity_API.Get_Project_Id(newrec_.project_activity_id),1,20);
         $ELSE
            NULL;
         $END
      END IF;

      IF (dummy_project_id_ <> dummy_codepart_value_) THEN
         Error_SYS.Record_General(lu_name_, 'ACTIVITYIDNOTVALID: Invalid Project Activity Id for Project :P1', dummy_project_id_);
      END IF;
   END IF;
   IF newrec_.currency_amount IS NULL THEN
      newrec_.currency_amount := 0;
      newrec_.debit_currency_amount := 0;
   END IF;

   IF newrec_.amount IS NULL THEN
      newrec_.amount := 0;
      newrec_.debit_amount := 0;
   END IF;

--The Row number increases automatically........................

   OPEN get_row_no;
   FETCH get_row_no INTO  newrec_.row_no;
   CLOSE get_row_no; 

   Client_SYS.add_To_Attr('ROW_NO', newrec_.row_no,attr_);

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);        
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_template_row_tab%ROWTYPE,
   newrec_ IN OUT voucher_template_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                   VARCHAR2(30);
   value_                  VARCHAR2(4000);
   is_project_code_part_   VARCHAR2(1);
   is_proj_ext_created_    VARCHAR2(5);
   dummy_codepart_value_   VARCHAR2(20);
   dummy_project_id_       VARCHAR2(20);
   req_rec_       Accounting_Codestr_API.CodestrRec;
   project_origin_         VARCHAR2(30);

BEGIN   
      super(oldrec_, newrec_, indrec_, attr_);

	
   req_rec_ := Account_API.Get_Required_Code_Parts(newrec_.voucher_company, newrec_.account);
   IF req_rec_.code_b = 'S' THEN
      newrec_.code_b := NULL;
   END IF;
   IF req_rec_.code_c = 'S' THEN
      newrec_.code_c := NULL;
   END IF;
   IF req_rec_.code_d = 'S' THEN
      newrec_.code_d := NULL;
   END IF;
   IF req_rec_.code_e = 'S' THEN
      newrec_.code_e := NULL;
   END IF;
   IF req_rec_.code_f = 'S' THEN
      newrec_.code_f := NULL;
   END IF;
   IF req_rec_.code_g = 'S' THEN
      newrec_.code_g := NULL;
   END IF;
   IF req_rec_.code_h = 'S' THEN
      newrec_.code_h := NULL;
   END IF;
   IF req_rec_.code_i = 'S' THEN
      newrec_.code_i := NULL;
   END IF;
   IF req_rec_.code_j = 'S' THEN
      newrec_.code_j := NULL;
   END IF;

--Codepart Validation...........................................
   CHECK_BLOCKED_(newrec_.voucher_company, newrec_.account, newrec_.code_b, newrec_.code_c, newrec_.code_d, newrec_.code_e, newrec_.code_f, newrec_.code_g, newrec_.code_h, newrec_.code_i, newrec_.code_j);

   is_project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(newrec_.voucher_company, 'PRACC');

   IF (is_project_code_part_ = 'B') THEN
      dummy_codepart_value_ := newrec_.code_b;
   ELSIF (is_project_code_part_ = 'C') THEN
      dummy_codepart_value_ := newrec_.code_c;
   ELSIF (is_project_code_part_ = 'D') THEN
      dummy_codepart_value_ := newrec_.code_d;
   ELSIF (is_project_code_part_ = 'E') THEN
      dummy_codepart_value_ := newrec_.code_e;
   ELSIF (is_project_code_part_ = 'F') THEN
      dummy_codepart_value_ := newrec_.code_f;
   ELSIF (is_project_code_part_ = 'G') THEN
      dummy_codepart_value_ := newrec_.code_g;
   ELSIF (is_project_code_part_ = 'H') THEN
      dummy_codepart_value_ := newrec_.code_h;
   ELSIF (is_project_code_part_ = 'I') THEN
      dummy_codepart_value_ := newrec_.code_i;
   ELSIF (is_project_code_part_ = 'J') THEN
      dummy_codepart_value_ := newrec_.code_j;
   END IF;

   dummy_project_id_ := dummy_codepart_value_;

   IF newrec_.project_activity_id IS NOT NULL AND dummy_codepart_value_ IS NULL THEN
      Error_SYS.Appl_General(lu_name_, 'NOPROJSPECIFIED: A Project must be specified in order for Project Activity Id to have a value');
   END IF;

   $IF Component_Genled_SYS.INSTALLED $THEN
     is_proj_ext_created_ := Accounting_Project_Api.Get_Externally_Created ( newrec_.voucher_company, 
                                                                             dummy_codepart_value_);
     project_origin_:=  ACCOUNTING_PROJECT_API.Get_Project_Origin_Db( newrec_.voucher_company , dummy_codepart_value_);
   $END

   IF (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NULL) THEN
      IF NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.voucher_company, newrec_.account), 'FALSE') = 'FALSE' THEN
          Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Project Activity Id must have a value for Project :P1', dummy_codepart_value_);
      END IF;
   END IF;

   IF (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NOT NULL) AND (newrec_.project_activity_id > 0 ) 
      AND  NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.voucher_company, newrec_.account), 'FALSE') = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', newrec_.account);
   END IF;
   IF (project_origin_ = 'PROJECT') THEN 
      IF newrec_.project_activity_id IS NOT NULL THEN
         $IF Component_Proj_SYS.INSTALLED $THEN
            Activity_API.Exist(newrec_.project_activity_id);
            dummy_codepart_value_ := substr(Activity_API.Get_Project_Id(newrec_.project_activity_id),1,20);
         $ELSE
            NULL;
         $END
      END IF;

      IF (dummy_project_id_ <> dummy_codepart_value_) THEN
         Error_SYS.Record_General(lu_name_, 'ACTIVITYIDNOTVALID: Invalid Project Activity Id for Project :P1', dummy_project_id_);
      END IF;
  END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

   
PROCEDURE Insert_Table___ (
   newrec_          IN OUT VOUCHER_ROW%ROWTYPE,
   curr_rnd_        IN OUT curr_rnd,
   company_         IN VARCHAR2,
   template_        IN VARCHAR2,
   row_no_          IN NUMBER,
   include_amount_  IN VARCHAR2,
   amount_methord_  IN VARCHAR2)
IS
   base_curr_rounding_  NUMBER;
   trans_curr_rounding_ NUMBER;
   currency_debet_amount_ NUMBER;
   currency_credit_amount_ NUMBER;
   debet_amount_ NUMBER;
   credit_amount_ NUMBER;
   
   key_ VARCHAR2(30);
   base_curr_code_ VARCHAR2(3);
   
BEGIN
   IF include_amount_ != 'TRUE' THEN
      base_curr_rounding_ := 0;
      trans_curr_rounding_ := 0;
      newrec_.currency_amount := 0;
      newrec_.amount := 0;
      currency_debet_amount_:=  CASE 
                                WHEN newrec_.currency_debet_amount IS NOT NULL THEN  0
                                WHEN newrec_.currency_debet_amount IS NULL     THEN  NULL
                                END;

      currency_credit_amount_:= CASE 
                                WHEN newrec_.currency_credit_amount IS NOT NULL THEN  0
                                WHEN newrec_.currency_credit_amount IS NULL     THEN  NULL
                                END;

      debet_amount_:=  CASE 
                       WHEN newrec_.debet_amount IS NOT NULL THEN  0
                       WHEN newrec_.debet_amount IS NULL     THEN  NULL
                       END;

      credit_amount_:= CASE 
                       WHEN newrec_.credit_amount IS NOT NULL THEN  0
                       WHEN newrec_.credit_amount IS NULL     THEN  NULL
                       END; 

   ELSE
      base_curr_code_ := Currency_Code_API.Get_Currency_Code(newrec_.company);
      key_ := newrec_.company || '^' || base_curr_code_;

      IF ( curr_rnd_.exists(key_) )THEN               
         base_curr_rounding_ := curr_rnd_(key_).currency_rounding_ ;
      ELSE
         base_curr_rounding_ := CURRENCY_CODE_API.Get_currency_rounding(newrec_.company, base_curr_code_);
         curr_rnd_(key_).currency_rounding_ := base_curr_rounding_;
      END IF;
      key_ := newrec_.company || '^' || newrec_.currency_code;
      IF ( curr_rnd_.exists(key_) )THEN               
         trans_curr_rounding_ := curr_rnd_(key_).currency_rounding_ ;
      ELSE
         trans_curr_rounding_ := CURRENCY_CODE_API.Get_currency_rounding(newrec_.company, newrec_.currency_code);
         curr_rnd_(key_).currency_rounding_ := trans_curr_rounding_;
      END IF;

      IF ( amount_methord_ = 'GROSS') THEN
         IF (NVL(newrec_.debet_amount,0)!= 0) THEN 
            newrec_.debet_amount := newrec_.debet_amount + newrec_.tax_amount; 
            newrec_.currency_debet_amount := newrec_.currency_debet_amount + newrec_.currency_tax_amount; 
         ELSE
            newrec_.credit_amount := newrec_.credit_amount - newrec_.tax_amount;
            newrec_.currency_credit_amount := newrec_.currency_credit_amount - newrec_.currency_tax_amount;     
         END IF;
      END IF;
      currency_debet_amount_ := newrec_.currency_debet_amount;
      currency_credit_amount_ := newrec_.currency_credit_amount;
      debet_amount_ := newrec_.debet_amount;
      credit_amount_ := newrec_.credit_amount;
   END IF;
   INSERT
      INTO voucher_template_row_tab (
         company,
         template,
         row_no,
         account,
         code_b,
         code_c,
         code_d,
         code_e,
         code_f,
         code_g,
         code_h,
         code_i,
         code_j,
         process_code,
         currency_code,
         debit_currency_amount,
         credit_currency_amount,
         currency_amount,
         currency_rate,
         debit_amount,
         credit_amount,
         amount,
         quantity,
         text,
         optional_code,
         trans_code,
         project_activity_id,
         deliv_type_id,
         voucher_company,
         rowversion)
      VALUES (
         company_,
         template_,
         row_no_,
         newrec_.account,
         newrec_.code_b,
         newrec_.code_c,
         newrec_.code_d,
         newrec_.code_e,
         newrec_.code_f,
         newrec_.code_g,
         newrec_.code_h,
         newrec_.code_i,
         newrec_.code_j,
         newrec_.process_code,
         newrec_.currency_code,
         ROUND(currency_debet_amount_ ,trans_curr_rounding_ ),
         ROUND(currency_credit_amount_ , trans_curr_rounding_),
         ROUND(newrec_.currency_amount,trans_curr_rounding_),
         newrec_.currency_rate,
         ROUND(debet_amount_ ,base_curr_rounding_),
         ROUND(credit_amount_ , base_curr_rounding_),
         ROUND(newrec_.amount, base_curr_rounding_),
         newrec_.quantity,
         newrec_.text,
         newrec_.optional_code,
         newrec_.trans_code,
         newrec_.project_activity_id, 
         newrec_.deliv_type_id,
         newrec_.company,
         sysdate);
END Insert_Table___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@UncheckedAccess
FUNCTION Get_Correction__ (
   amount_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   IF (amount_ >= 0) THEN
      RETURN('N');
   ELSE
      RETURN('Y');
   END IF;
END Get_Correction__;




@UncheckedAccess
FUNCTION Get_Correction__ (
   company_  IN VARCHAR2,
   template_ IN VARCHAR2,
   amount_   IN NUMBER) RETURN VARCHAR2
IS
   CURSOR get_correction IS 
      SELECT correction 
        FROM Voucher_Template_Tab
       WHERE company   = company_
         AND template = template_ ;

   correction_ VARCHAR2(2);
BEGIN
   IF (NVL(amount_,0) > 0) THEN
      RETURN('N');
   ELSIF (NVL(amount_,0) = 0) THEN
      OPEN get_correction;
      FETCH get_correction INTO correction_ ;
      IF get_correction%FOUND THEN
        CLOSE get_correction;
        RETURN NVL(correction_,'N');
      ELSE
         CLOSE get_correction;
         RETURN 'N';
      END IF;  
   ELSE
      RETURN 'Y';
   END IF;
END Get_Correction__;




@UncheckedAccess
FUNCTION Calculate_Rate__ (
   company_         IN VARCHAR2,
   currency_code_   IN VARCHAR2,
   amount_          IN NUMBER,
   currency_amount_ IN NUMBER,
   conv_factor_     IN NUMBER ) RETURN NUMBER
IS
BEGIN
   IF (nvl(currency_amount_, 0) = 0) THEN
      RETURN(0);
   END IF;
   RETURN(abs(round((amount_/currency_amount_)*conv_factor_, nvl(Currency_Code_API.Get_No_Of_Decimals_In_Rate(company_, currency_code_ ), 0))));
END Calculate_Rate__;




PROCEDURE Validate_Account_Pseudo__ (
   req_string_          OUT VARCHAR2,
   req_string_complete_ IN OUT VARCHAR2,
   company_             IN VARCHAR2,
   account_             IN VARCHAR2,
   voucher_date_        IN DATE,
   client_user_         IN VARCHAR2 DEFAULT NULL )
IS
    vou_date_ DATE;
BEGIN
   Account_Api.Exist_Account_And_Pseudo(company_, account_);
   Account_Api.Get_Required_Code_Part_Pseudo(req_string_,  company_, account_);
   IF Pseudo_Codes_Api.Exist_Pseudo(company_, account_) THEN
      Pseudo_Codes_API.Get_Complete_Pseudo(req_string_complete_, company_, account_,client_user_);
   ELSE
   IF voucher_date_ IS NULL THEN
      vou_date_ := SYSDATE;
   ELSE
      vou_date_ :=  voucher_date_;
   END IF;
      Accounting_Codestr_API.Complete_Codestring(req_string_complete_, company_, NULL, voucher_date_, 'A');
      IF (NOT Account_Api.Validate_Accnt(company_, account_, vou_date_ )) THEN
         Error_SYS.Record_General('VoucherTemplateRow','ACCNT_NOT_VALID: Account number :P1 not valid for date interval',account_);
      END IF;
   END IF;
END Validate_Account_Pseudo__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Insert_Table_ (
   company_         IN VARCHAR2,
   template_        IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   include_amount_  IN VARCHAR2,
   multi_company_   IN VARCHAR2)
IS
   newrec_              VOUCHER_ROW%ROWTYPE;
   row_no_              NUMBER;
   amount_methord_      voucher_tab.amount_method%TYPE;
   curr_rnd_            curr_rnd; 

   CURSOR Rows_ IS
      SELECT * FROM Voucher_Row
      WHERE Company = company_
      AND   Accounting_Year = accounting_year_
      AND   voucher_type = voucher_type_
      AND   voucher_no = voucher_no_
      AND   trans_code = 'MANUAL'
      ORDER BY row_no;
      
   CURSOR Mc_Rows_ IS              
      SELECT * FROM Voucher_Row
      WHERE multi_company_id = company_
      AND   multi_company_acc_year = accounting_year_
      AND   multi_company_voucher_type = voucher_type_
      AND   multi_company_voucher_no = voucher_no_
      AND   trans_code = 'MANUAL'
      ORDER BY multi_company_row_no;
      
BEGIN
   row_no_ := 0;
   IF include_amount_ = 'TRUE' THEN
      amount_methord_ := Voucher_API.Get_Amount_Method_Db( company_,
                                                           accounting_year_,
                                                           voucher_type_,
                                                           voucher_no_ );
   END IF;
   IF multi_company_ = 'TRUE' THEN
      OPEN Mc_Rows_;
      LOOP
         FETCH Mc_Rows_ INTO newrec_;
         EXIT WHEN Mc_Rows_%NOTFOUND;
         row_no_ := row_no_ + 1;
         Insert_Table___(newrec_, curr_rnd_, company_, template_, row_no_, include_amount_, amount_methord_);
      END LOOP;
      CLOSE Mc_Rows_ ;
   ELSE
      OPEN Rows_;
      LOOP
         FETCH Rows_ INTO newrec_;
         EXIT WHEN Rows_%NOTFOUND; 
         row_no_ := row_no_ + 1;
         Insert_Table___(newrec_, curr_rnd_, company_, template_, row_no_, include_amount_, amount_methord_);
      END LOOP;
      CLOSE Rows_ ;
   END IF;
   IF row_no_ = 0 THEN
      Error_SYS.Record_General(lu_name_, 'NOREC: The template was not created since the voucher :P1 has no manually created rows', voucher_no_);
   END IF;
END Insert_Table_;


PROCEDURE Check_Blocked_ (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2,
   code_b_ IN VARCHAR2,
   code_c_ IN VARCHAR2,
   code_d_ IN VARCHAR2,
   code_e_ IN VARCHAR2,
   code_f_ IN VARCHAR2,
   code_g_ IN VARCHAR2,
   code_h_ IN VARCHAR2,
   code_i_ IN VARCHAR2,
   code_j_ IN VARCHAR2 )
IS
   ptr_                 NUMBER;
   name_                VARCHAR2(30);
   value_               VARCHAR2(2000);
   required_str_        VARCHAR2(2000);
   required_b_          VARCHAR2(1);
   required_c_          VARCHAR2(1);
   required_d_          VARCHAR2(1);
   required_e_          VARCHAR2(1);
   required_f_          VARCHAR2(1);
   required_g_          VARCHAR2(1);
   required_h_          VARCHAR2(1);
   required_i_          VARCHAR2(1);
   required_j_          VARCHAR2(1);
   code_part_name_      VARCHAR2(100);
   code_part_acc_name_  VARCHAR2(100);
BEGIN
   Accounting_Code_Part_A_API.Get_Required_Code_Part(required_str_, company_, account_);
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(required_str_, ptr_, name_, value_)) LOOP
      IF (name_ = 'CODE_B') THEN
         required_b_ := value_;
      ELSIF (name_ = 'CODE_C') THEN
         required_c_ := value_;
      ELSIF (name_ = 'CODE_D') THEN
         required_d_ := value_;
      ELSIF (name_ = 'CODE_E') THEN
         required_e_ := value_;
      ELSIF (name_ = 'CODE_F') THEN
         required_f_ := value_;
      ELSIF (name_ = 'CODE_G') THEN
         required_g_ := value_;
      ELSIF (name_ = 'CODE_H') THEN
         required_h_ := value_;
      ELSIF (name_ = 'CODE_I') THEN
         required_i_ := value_;
      ELSIF (name_ = 'CODE_J') THEN
         required_j_ := value_;
      END IF;
   END LOOP;
   code_part_acc_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'A');
   IF required_b_ = 'S' THEN
      IF code_b_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'B');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF code_c_ = 'S' THEN
      IF code_c_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'C');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_d_ = 'S' THEN
      IF code_d_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'D');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_e_ = 'S' THEN
      IF code_e_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'E');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_f_ = 'S' THEN
      IF code_f_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'F');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_g_ = 'S' THEN
      IF code_g_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'G');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_h_ = 'S' THEN
      IF code_h_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'H');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_i_ = 'S' THEN
      IF code_i_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'I');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
   IF required_j_ = 'S' THEN
      IF code_j_ IS NOT NULL THEN
         code_part_name_ := Accounting_Code_Parts_API.Get_Name(company_, 'J');
         Error_SYS.Record_General(lu_name_, 'ISBLOCK: :P2 is blocked for :P3 :P1', account_, code_part_name_, code_part_acc_name_);
      END IF;
   END IF;
END Check_Blocked_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Max_Row_No (
   company_  IN VARCHAR2,
   template_ IN VARCHAR2 ) RETURN NUMBER
IS
   row_no_   VOUCHER_TEMPLATE_ROW_TAB.row_no%TYPE;
   CURSOR get_max_row_no_ IS
      SELECT NVL(max(row_no), 0)
      FROM  VOUCHER_TEMPLATE_ROW_TAB
      WHERE  company = company_
      AND  template = template_;
BEGIN
   OPEN get_max_row_no_;
   FETCH get_max_row_no_ INTO row_no_;
   CLOSE get_max_row_no_;
   RETURN(row_no_);
END Get_Max_Row_No;


PROCEDURE Get_Delivery_Type_Description(
   ret_ OUT VARCHAR2,
   company_ IN VARCHAR2,
   deliv_type_id_ IN VARCHAR2 )
IS 
BEGIN
   ret_ := Voucher_Row_API.Get_Delivery_Type_Description(company_,
                                                         deliv_type_id_);
END Get_Delivery_Type_Description;


PROCEDURE Is_Multi_Company (
   company_  IN VARCHAR2,
   template_ IN VARCHAR2 )
IS
   exists_  NUMBER;
   CURSOR is_multi_company_ IS
      SELECT 1
      FROM  VOUCHER_TEMPLATE_ROW_TAB
      WHERE  company = company_
      AND  template = template_
      AND  voucher_company != company_;
BEGIN
   exists_ := 0;
   OPEN is_multi_company_;
   FETCH is_multi_company_ INTO exists_;
   CLOSE is_multi_company_;
   IF exists_ = 1 THEN
      Error_Sys.Appl_General(lu_name_, 'ACCRULVTMCUP: You cannot change the type of the template from multi company to single company as the template includes multi company voucher lines.');
   END IF;
END Is_Multi_Company;

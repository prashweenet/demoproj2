-----------------------------------------------------------------------------
--
--  Logical unit: ExtTransactions
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970128  MaGu   Created
--  970411  MaGu   Changed proc. New_Transaction. Inserting rowstate col. and
--                  removed uppercase calls from insert values.
--  970520  MiJo   Fixed bug 97-0015. Replaced Posting_Combination with Codestring_Comb.
--  970808  SLKO   Converted to Foundation 1.2.2d
--  970706  DavJ   Added currency_debet_amount, currency_credit_amount,
--                  debet_amount,credit_amount in VIEW
--  970717  DavJ   Added currency_debet_amount, currency_credit_amount, debet_amount,
--                  credit_amount in Proc. Unpack_Check_Insert & Unpack_Check_update
--                  and Proc. Insert & Update, Proc. New_Transaction, Proc. Get_Transaction
--  970919  SLKO   Added labels (NOTLOADSTAT,NOTRECERR) to Client_SYS.Add_Info
--                  in Unpack_Check_Update___.
--  980407  ANDJ   Bug # 6017 fixed.
--  980424  LALI   Modified state declarations
--  981026  Bren   Added Third_Currency_Debet_Amount,Third_Currency_Credit_Amount,
--                  to Unpack_Check_Insert and Update.
--  000124  Upul   Added Procedure Validate_Load_Id - Ext Transaction Wizard.
--  000309  Uma    Closed dynamic cursors in Exceptions.
--  000414  SaCh   Added RAISE to exceptions.
--  000912  HiMu   Added General_SYS.Init_Method
--  001005  prtilk BUG # 15677  Checked General_SYS.Init_Method 
--  010219  Uma    Corrected Bug# 20066.
--  010221  JeGu   Bug # 20169: Removed handling of posting_combination_id 
--  010221  ToOs   Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010301  JeGu   Bug # 20361 Changed Where-statements cursors for performance reasons
--  010404  JeGu   Bug # 20361 Added procedure Check_Found
--  010508  JeGu   Bug #21705 Implementation New Dummyinterface
--                 Changed Insert__ RETURNING rowid INTO objid_
--  010530  JeGu   Misc Performance and Quality
--  011018  Uma    Corrected Bug# 25589.
--  020524  Hecolk Bug 28600, Merged   
--  020606  JeGu   Bug 30817, made some performance improvements
--  021002  Nimalk Removed usage of the view Company_Finance_Auth in EXT_TRANSACTIONS view 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021011  PPerse Merged External Files
--  030107  Nimalk Removed usage of the view Company_Finance_Auth and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins 
--  030805  prdilk SP4 Merge.
--  040329  Gepelk 2004 SP1 Merge.
--  040805  Jeguse Bug 44702 Merged, Added transfer of load_file_id and row_no to ExtTransRec, Added exception handling in New_Transaction
--  041129  nsillk Bug 46790,Merged.Changed the name of Update_Error to Clear_All_Error
--  050623  Samwlk Bug 51751 Merged.
--  060209  Samwlk Bug 55422,Merged.
--  060310  Samwlk Bug 55726, Merged.
--  070330  Kagalk LCS Merge 58728.
--  080225  Jeguse Bug 71809 Corrected.
--  080924  AjPelk Bug 71024 Corrected.
--  090309  AjPelk Bug 71024 Corrected.
--  090605  THPELK Bug 82609 - Modified the UNDEFINE statement for VIEW2.
--  090630  AJPELK Bug 83899 Corrected.
--  090804  AjPelk Bug 84373 Corrected.
--  090819  Nsillk Bug 84885 Corrected.Added currency_rate to the table , methods and views.  
--  091023  AjPelk EAST-149 , Added missing view comments.
--  100106  Umdolk Added new state template.
--  100722  Jaralk Bug 91425 Corrected.Added condition to check if the project origine of externaly created project is job type.
--  100722  Jaralk Bug 92104 Corrected.Correctly updated the currency_amounts and currency_debet_amounts 
--                after doing a modification in external Vouchers window
--  100722  Jaralk Bug 92104 Corrected in unpack_check_update___ 
--  101011  AjPelk Bug 92374 Corrected.
--  110701  Sacalk FIDEAGLE-891, Bug 97339 Corected.
--  111004  AJPELK EASTTWO-15655, Bug 98827 merged.
--  111018  Shdilk SFI-135, Conditional compilation.
--  111213  Clstlk SFI-784, LCS bug 99676, Added method Update_Project_Error().
--  120418  Clstlk EASTRTM-8916, LCS Merge (Bug 101936).
--  120621  Raablk Bug 102564 Corrected.Added PROCEDURE Check_Exist_Function_Group_Q().
--  120627  THPELK Bug 97225, Corrected in Auto_Tax_Calculation_Done().
--  120820  Sacalk EDEL-1403, Added Columns to support automation of Add investment in FA 
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk PEPA-183, Removed global variables
--  121123  Janblk DANU-122, Parallel currency implementation  
--  130628  Shedlk Bug 110830, Added code part description columns to EXT_TRANSACTIONS_NEW view
--  130807  Shedlk Bug 111720, Added column comments for Code Part Description columns in EXT_TRANSACTIONS_NEW view.
--  131126  MEAlLK PBFI-2026, Refactoring code according to new standards
--  140408  Nirylk PBFI-5614, Added deliv_type_id to ExtTransRec, Added deliv_type_id column, Modified New_Transaction()  
--  140526  Hecolk PBFI-7184, Modified PROCEDURE New_Transaction to Nullify Trans_code if it is not EXTERNAL 
--  141217  DipeLK PRFI-4042,Tax Base is NULL on the Tax Posting of a voucher created through external file
--  150128  AjPelk PRFI-4489, Lcs merge Bug 120401, Added new field CURRENCY_RATE_TYPE
--  151118  chiblk STRFI-607 changed the hard code values of ext_voucher_diff.
--  160525  Savmlk STRFI-1809, Lcs merge Bug 128663,Added new method Update_Errors().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE ExtTransRec IS RECORD (
    company                      VARCHAR2(20),
    load_id                      VARCHAR2(20),
    user_id                      VARCHAR2(20),
    record_no                    NUMBER,
    load_group_item              VARCHAR2(50), 
    load_error                   VARCHAR2(2000),
    transaction_date             DATE,
    load_type                    VARCHAR2(20),
    voucher_type                 VARCHAR2(3),
    voucher_no                   NUMBER,
    accounting_year              NUMBER,
    codestring_rec               Accounting_Codestr_API.CodestrRec,
    currency_debet_amount        NUMBER,
    currency_credit_amount       NUMBER,
    currency_amount              NUMBER,        -- to Support old version
    debet_amount                 NUMBER,
    credit_amount                NUMBER,
    amount                       NUMBER,        -- to Support old version
    currency_code                VARCHAR2(3),
    quantity                     NUMBER,
    process_code                 VARCHAR2(10),
    optional_code                VARCHAR2(20),
    tax_percentage               NUMBER,
    text                         VARCHAR2(200),
    party_type                   VARCHAR2(20),
    party_type_id                VARCHAR2(20),
    reference_number             VARCHAR2(50),
    reference_serie              VARCHAR2(50),
    trans_code                   VARCHAR2(100),
    third_currency_debit_amount  NUMBER,
    third_currency_credit_amount NUMBER,
    Project_Activity_Id          NUMBER,
    ext_vouch_date               VARCHAR2(1),
    ext_group_item               VARCHAR2(1),
    load_date                    DATE,   
    tax_direction                VARCHAR2(20),  
    tax_amount                   NUMBER,        
    currency_tax_amount          NUMBER,        
    tax_base_amount              NUMBER,        
    currency_tax_base_amount     NUMBER,        
    load_file_id                 NUMBER,
    row_no                       NUMBER,
    user_group                   user_group_member_finance_tab.user_group%type,
    correction                   Ext_Parameters_Tab.correction%TYPE,
    currency_rate                NUMBER,
    modify_codestr_cmpl          VARCHAR2(5),
    event_date                   DATE,
    retroactive_date             DATE,
    transaction_reason           VARCHAR2(20),
    third_currency_amount  NUMBER,
    third_currency_tax_amount  NUMBER,
    third_curr_tax_base_amount  NUMBER,
    deliv_type_id                ext_transactions_tab.deliv_type_id%TYPE,
    currency_rate_type           VARCHAR2(10),
    parallel_curr_rate_type      VARCHAR2(10),
    tax_transaction              VARCHAR2(5));
    
TYPE rec_identity IS RECORD
      (record_no          NUMBER,
      err_msg             VARCHAR2(2000)
      );
      
TYPE identity_rec IS TABLE OF rec_identity
      INDEX BY BINARY_INTEGER;


-------------------- PRIVATE DECLARATIONS -----------------------------------

state_separator_   CONSTANT VARCHAR2(1)   := Client_SYS.field_separator_;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Get_Next_Record_No___ (
   record_no_  OUT NUMBER,
   company_    IN  VARCHAR2,
   load_id_    IN  VARCHAR2 )
IS
   rec_no_ NUMBER;
   CURSOR getnextrecno IS
      SELECT MAX(record_no)
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
   OPEN getnextrecno;
   FETCH getnextrecno INTO rec_no_;
   CLOSE getnextrecno;
   IF (rec_no_ IS NULL) THEN
      rec_no_ := 1;
   ELSE
      rec_no_ := rec_no_ + 1;
   END IF;
   record_no_ := rec_no_;
END Get_Next_Record_No___;


FUNCTION Transaction_Loaded___ (
   rec_  IN     EXT_TRANSACTIONS_TAB%ROWTYPE ) RETURN BOOLEAN
IS
BEGIN
   RETURN TRUE;
END Transaction_Loaded___;


PROCEDURE Removed_Unused_Codeprts___ (
   codestr_rec_ IN OUT Accounting_Codestr_API.CodestrRec,
   company_     IN     VARCHAR2 )
IS
BEGIN
   IF codestr_rec_.code_b IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'B') = 'FALSE' THEN
         codestr_rec_.code_b := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_c IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'C') = 'FALSE' THEN
         codestr_rec_.code_c := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_d IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'D') = 'FALSE' THEN
         codestr_rec_.code_d := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_e IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'E') = 'FALSE' THEN
         codestr_rec_.code_e := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_f IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'F') = 'FALSE' THEN
         codestr_rec_.code_f := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_g IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'G') = 'FALSE' THEN
         codestr_rec_.code_g := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_h IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'H') = 'FALSE' THEN
         codestr_rec_.code_h := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_i IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'I') = 'FALSE' THEN
         codestr_rec_.code_i := NULL;
      END IF;
   END IF;
   IF codestr_rec_.code_j IS NOT NULL THEN
      IF Accounting_Code_Parts_API.Is_Code_Used(company_,'J') = 'FALSE' THEN
         codestr_rec_.code_j := NULL;
      END IF;
   END IF;
END Removed_Unused_Codeprts___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('MODIFY_CODESTR_CMPL', 'FALSE' , attr_); 
   Client_SYS.Add_To_Attr('CORRECTION', 'FALSE' , attr_); 
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT EXT_TRANSACTIONS_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   base_curr_rounding_  NUMBER;
   trans_curr_rounding_ NUMBER;
   third_curr_rounding_ NUMBER;
   ext_group_item_      VARCHAR2(1); 
BEGIN
   
   base_curr_rounding_  := Currency_Code_API.Get_currency_rounding(newrec_.company, Currency_Code_API.Get_Currency_Code(newrec_.company));
   trans_curr_rounding_ := Currency_Code_API.Get_currency_rounding(newrec_.company, newrec_.currency_code);
   third_curr_rounding_ := Currency_Code_API.Get_currency_rounding(newrec_.company,  Company_Finance_Api.Get_Parallel_Acc_Currency(newrec_.company, Voucher_Api.Get_Voucher_Date(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no)));
   Ext_Parameters_API.Get_Ext_Group_Item (ext_group_item_,
                                          newrec_.company, 
                                          newrec_.load_type );
   IF (ext_group_item_ = '1') THEN
      newrec_.load_group_item := to_char(newrec_.voucher_no);
   ELSIF (ext_group_item_ = '3') THEN
      newrec_.load_group_item := to_char(trunc(newrec_.transaction_date));
   ELSIF (ext_group_item_ = '4') THEN
      newrec_.load_group_item := newrec_.reference_number;
   END IF;
   IF (newrec_.load_group_item IS NULL) THEN
      newrec_.load_group_item := '?';
   END IF;

   newrec_.transaction_date             := TRUNC(newrec_.transaction_date);
   newrec_.currency_debet_amount        := ROUND(newrec_.currency_debet_amount, trans_curr_rounding_);
   newrec_.currency_credit_amount       := ROUND(newrec_.currency_credit_amount, trans_curr_rounding_);
   newrec_.debet_amount                 := ROUND(newrec_.debet_amount, base_curr_rounding_);
   newrec_.credit_amount                := ROUND(newrec_.credit_amount, base_curr_rounding_);
   newrec_.third_currency_debit_amount  := ROUND(newrec_.third_currency_debit_amount, third_curr_rounding_);
   newrec_.third_currency_credit_amount := ROUND(newrec_.third_currency_credit_amount, third_curr_rounding_);
   newrec_.tax_amount                   := ROUND(newrec_.tax_amount, base_curr_rounding_);
   newrec_.currency_tax_amount          := ROUND(newrec_.currency_tax_amount, trans_curr_rounding_);
   newrec_.tax_base_amount              := ROUND(newrec_.tax_base_amount, base_curr_rounding_);
   newrec_.currency_tax_base_amount     := ROUND(newrec_.currency_tax_base_amount, trans_curr_rounding_);   
   super(objid_, objversion_, newrec_, attr_);
   Client_SYS.Add_To_Attr('RECORD_NO', newrec_.record_no, attr_);
   Client_SYS.Add_To_Attr('OBJSTATE', 'Loaded', attr_);
   Client_SYS.Add_To_Attr('EXT_ALTER_TRANS', Ext_Transactions_API.Get_Alter_Trans(newrec_.company, newrec_.load_id), attr_);
   Client_SYS.Add_To_Attr('CORRECTION', newrec_.correction, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     EXT_TRANSACTIONS_TAB%ROWTYPE,
   newrec_     IN OUT EXT_TRANSACTIONS_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   base_curr_rounding_  NUMBER;
   trans_curr_rounding_ NUMBER;
   third_curr_rounding_ NUMBER;
BEGIN
   base_curr_rounding_                  := Currency_Code_API.Get_currency_rounding(newrec_.company, Currency_Code_API.Get_Currency_Code(newrec_.company));
   trans_curr_rounding_                 := Currency_Code_API.Get_currency_rounding(newrec_.company, newrec_.currency_code);
   third_curr_rounding_                 := Currency_Code_API.Get_currency_rounding(newrec_.company,  Company_Finance_Api.Get_Parallel_Acc_Currency(newrec_.company, Voucher_Api.Get_Voucher_Date(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no)));
   newrec_.currency_debet_amount        := ROUND(newrec_.currency_debet_amount, trans_curr_rounding_);
   newrec_.currency_credit_amount       := ROUND(newrec_.currency_credit_amount, trans_curr_rounding_);
   newrec_.debet_amount                 := ROUND(newrec_.debet_amount, base_curr_rounding_);
   newrec_.credit_amount                := ROUND(newrec_.credit_amount, base_curr_rounding_);
   newrec_.transaction_date             := TRUNC(newrec_.transaction_date);
   newrec_.third_currency_debit_amount  := ROUND(newrec_.third_currency_debit_amount, third_curr_rounding_);
   newrec_.third_currency_credit_amount := ROUND(newrec_.third_currency_credit_amount, third_curr_rounding_);
   newrec_.tax_amount                   := ROUND(newrec_.tax_amount, base_curr_rounding_);
   newrec_.currency_tax_amount          := ROUND(newrec_.currency_tax_amount, trans_curr_rounding_);
   newrec_.tax_base_amount              := ROUND(newrec_.tax_base_amount, base_curr_rounding_);
   newrec_.currency_tax_base_amount     := ROUND(newrec_.currency_tax_base_amount, trans_curr_rounding_);   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_TRANSACTIONS_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_Transactions_API.Get_Alter_Trans(remrec_.company, remrec_.load_id) <> 'TRUE') THEN
      Error_SYS.Record_General('ExtTransactions', 'ALTERTRANS: Alter Transation flag is not set for the record');
   END IF;
   IF (remrec_.rowstate = 'Checked') THEN
      Error_SYS.Record_General('ExtTransactions', 'CANNOTDELCHECK: Record having status Check cannot delete');
   END IF;
   super(remrec_);
END Check_Delete___;


-- Check_Exist___
--   Check if a specific LU-instance already exist in the database.
FUNCTION Check_Exist___ (
   company_   IN VARCHAR2,
   load_id_   IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_transactions_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                    VARCHAR2(30);
   value_                   VARCHAR2(2000);
   numrec_                  NUMBER;
   cannotinsexp             EXCEPTION;
   is_project_code_part_    VARCHAR2(1);
   is_proj_ext_created_     VARCHAR2(5);
   dummy_codepart_value_    VARCHAR2(20);
   ext_voucher_diff_        VARCHAR2(10);  
   loaded_                  NUMBER := 0; 
   ext_alter_trans_         VARCHAR2(100);
   amount_                  NUMBER;
   currency_amount_         NUMBER;
   third_currency_amount_   NUMBER;
   
   CURSOR checkloaded IS
      SELECT 1
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company  = newrec_.company
      AND    load_id  = newrec_.load_id
      AND    rowstate = 'Loaded'; 

BEGIN
   --DipeLk Remove VOUCHER_DATE from attr_
   IF (newrec_.correction IS NULL) THEN
      newrec_.correction := 'FALSE';
   END IF;
   attr_ := Client_SYS.Remove_Attr('VOUCHER_DATE',attr_);
   Get_Next_Record_No___ ( newrec_.record_no ,
                           newrec_.company,
                           newrec_.load_id );
   super(newrec_, indrec_, attr_);
   
   amount_ := nvl(newrec_.debet_amount,-newrec_.credit_amount);
   IF ( nvl(newrec_.debet_amount,0)=0 AND nvl(newrec_.credit_amount,0)=0 ) THEN
      IF ( amount_ > 0 ) THEN
          newrec_.debet_amount := amount_;
      ELSE
          newrec_.credit_amount := -amount_;
      END IF;
   END IF;
   
   currency_amount_ := nvl(newrec_.currency_debet_amount,-newrec_.currency_credit_amount);
   IF (nvl(newrec_.currency_debet_amount,0)=0 AND nvl(newrec_.currency_credit_amount,0)=0) THEN
      IF ( currency_amount_ > 0 ) THEN
          newrec_.currency_debet_amount := currency_amount_;
      ELSE
          newrec_.currency_credit_amount := -currency_amount_;
      END IF;
   END IF;
   
   third_currency_amount_ := nvl(newrec_.third_currency_debit_amount,-newrec_.third_currency_credit_amount);
   IF ( nvl(newrec_.third_currency_debit_amount,0)=0 AND nvl(newrec_.third_currency_credit_amount,0)=0 ) THEN
      IF third_currency_amount_ != 0  THEN
         IF ( newrec_.third_currency_amount > 0 ) THEN
            newrec_.third_currency_debit_amount := third_currency_amount_;
         ELSE
            newrec_.third_currency_credit_amount:= -third_currency_amount_;
         END IF;
      END IF;
   END IF;
 
   IF newrec_.optional_code IS NOT NULL AND newrec_.tax_direction IS NOT NULL AND
      newrec_.tax_amount IS NOT NULL AND newrec_.currency_tax_amount IS NOT NULL THEN   
   
      -- Considering only Net Amounts for Tax Base Amounts
      IF amount_ IS NOT NULL THEN
         newrec_.tax_base_amount  := amount_;
      ELSE
         IF newrec_.debet_amount IS NOT NULL THEN 
            newrec_.tax_base_amount := newrec_.debet_amount; 
         ELSIF newrec_.credit_amount IS NOT NULL THEN 
            newrec_.tax_base_amount := -newrec_.credit_amount;
         END IF;
         
         IF currency_amount_ IS NOT NULL THEN 
             newrec_.currency_tax_base_amount  := currency_amount_; 
         END IF;
      
         IF newrec_.currency_debet_amount IS NOT NULL THEN 
            newrec_.currency_tax_base_amount := newrec_.currency_debet_amount; 
         ELSIF newrec_.currency_credit_amount IS NOT NULL THEN 
            newrec_.currency_tax_base_amount :=  -newrec_.currency_credit_amount;
         END IF;
      END IF;
      -- Considering only Net Amounts for Third Currency Tax Base Amounts
      IF third_currency_amount_ IS NOT NULL THEN
          newrec_.third_curr_tax_base_amount  := newrec_.third_currency_amount;
      ELSE
        IF newrec_.third_currency_debit_amount IS NOT NULL THEN
           newrec_.third_curr_tax_base_amount := newrec_.third_currency_debit_amount;
        ELSIF newrec_.third_currency_credit_amount IS NOT NULL THEN
           newrec_.third_curr_tax_base_amount := -newrec_.third_currency_credit_amount;
        END IF;
      END IF;
   END IF;    

   IF (newrec_.load_id IS NOT NULL) THEN
      -- check if there are record
      Check_Found( numrec_, 
                   newrec_.company, 
                   newrec_.load_id, 
                   'Updated' ); 
                   

      OPEN checkloaded;
      FETCH checkloaded INTO loaded_;
      CLOSE checkloaded;
      
      IF ( newrec_.user_id IS NULL ) THEN
         Ext_Load_Info_API.Get_Load_User (newrec_.user_id,
                                          newrec_.company,
                                          newrec_.load_id);
      END IF;

      IF (newrec_.load_type IS NULL) THEN
         newrec_.load_type := Ext_Load_Info_API.Get_Load_Type (newrec_.company,
                                                               newrec_.load_id);
      END IF;  


      IF newrec_.voucher_type IS NOT NULL THEN
         Ext_Parameters_API.Get_Ext_Voucher_Diff ( ext_voucher_diff_,
                                                   newrec_.company,
                                                   newrec_.load_type );
      END IF; 
      IF (numrec_ > 0) THEN
         Error_SYS.Record_General('ExtTransactions', 'CANNOT_INS_UPDATE: You cannot insert record for load id :P1 which have status Updated.', newrec_.load_id);
      END IF;

      IF (ext_voucher_diff_  = 'Y') THEN   
         IF (loaded_ = 0) THEN
            Error_SYS.Record_General('ExtTransactions', 'CANNOT_INS: You cannot insert record for load id :P1 as Voucher Differences set Allowed.', newrec_.load_id);
         END IF;
      END IF;

      ext_alter_trans_ := Ext_Transactions_API.Get_Alter_Trans (newrec_.company,newrec_.load_id);

      IF (ext_alter_trans_ != 'TRUE') THEN
         RAISE cannotinsexp;
      END IF;
   END IF; 
   
   IF (newrec_.transaction_date IS NULL)THEN
      Error_SYS.Appl_General(lu_name_, 'TRANSACDATENULL: Transaction Date is empty.');
   END IF;
   IF (newrec_.currency_code IS NULL OR (newrec_.currency_amount IS NOT NULL AND newrec_.transaction_date IS NOT NULL ))THEN
      Error_SYS.Appl_General(lu_name_, 'CURRENCYCODENULL: No Currency Code selected.');
   END IF; 

   IF (newrec_.optional_code IS NOT NULL AND newrec_.tax_direction IS NULL)THEN
      Error_SYS.Appl_General(lu_name_, 'TAXDIRECTIONNULL: Tax Direction must not be empty.');
   END IF;      
   
   is_project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(newrec_.company, 'PRACC');

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

   $IF Component_Genled_SYS.INSTALLED $THEN
     is_proj_ext_created_ := Accounting_Project_Api.Get_Externally_Created ( newrec_.company, 
                                                                             dummy_codepart_value_);
   $END
   
   IF (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NULL) THEN
          Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Project Activity Id must have a value for Project :P1', dummy_codepart_value_);
   END IF;
   
   IF newrec_.project_activity_id IS NOT NULL THEN
      $IF Component_Proj_SYS.INSTALLED $THEN
         Activity_api.Exist(newrec_.project_activity_id);
      $ELSE
         NULL;
      $END
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
   WHEN cannotinsexp THEN
      Error_SYS.Record_General(lu_name_, 'CANNTINSR: You cannot insert record for load id :P1', newrec_.load_id);
END Check_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_transactions_tab%ROWTYPE,
   newrec_ IN OUT ext_transactions_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   conversion_factor_    NUMBER;
   currency_rate_        NUMBER;
   inverted_             VARCHAR2(5);
   company_rec_          Company_Finance_API.Public_Rec;   
BEGIN
   IF (newrec_.optional_code IS NULL) THEN 
      indrec_.tax_direction := FALSE;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);    
   IF (oldrec_.currency_code != newrec_.currency_code ) THEN
      company_rec_ := Company_Finance_API.Get(newrec_.Company);
      Currency_Rate_API.Fetch_Currency_Rate_Base(  conversion_factor_, 
                                                   currency_rate_, 
                                                   inverted_,  
                                                   newrec_.company, 
                                                   newrec_.currency_code, 
                                                   company_rec_.currency_code , 
                                                   NVL(newrec_.currency_rate_type, Currency_Type_API.Get_Default_Type(newrec_.company)), 
                                                   SYSDATE, 
                                                   'DUMMY' );
   END IF;   
END Check_Common___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_transactions_tab%ROWTYPE,
   newrec_ IN OUT ext_transactions_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   err_msg_                 VARCHAR2(2000);
   transaction_rec_         ExtTransRec;
   name_                    VARCHAR2(30);
   value_                   VARCHAR2(2000);
   cannotupdatexp           EXCEPTION;
   is_project_code_part_    VARCHAR2(1);
   is_proj_ext_created_     VARCHAR2(5);
   dummy_codepart_value_    VARCHAR2(20);
   project_origin_          VARCHAR2(50);
   currency_code_           ext_transactions_tab.Currency_Code%TYPE;
   amount_                  NUMBER;
   currency_amount_         NUMBER;
   third_currency_amount_   NUMBER;   
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.transaction_date IS NULL)THEN
      Error_SYS.Appl_General(lu_name_, 'TRANSACDATENULL: Transaction Date is empty.');
   END IF;
   IF (newrec_.currency_code IS NULL OR (newrec_.currency_amount IS NOT NULL AND newrec_.transaction_date IS NOT NULL ))THEN
      Error_SYS.Appl_General(lu_name_, 'CURRENCYCODENULL: No Currency Code selected.');
   END IF;
   IF (newrec_.optional_code IS NOT NULL AND newrec_.tax_direction IS NULL)THEN
      Error_SYS.Appl_General(lu_name_, 'TAXDIRECTIONNULL: Tax Direction must not be empty.');
   END IF;   
   $IF Component_Fixass_SYS.INSTALLED $THEN
       IF( newrec_.transaction_reason  IS NOT NULL) THEN
          Transaction_Reason_API.Acquisition_Reason_Checked(newrec_.company,newrec_.transaction_reason);
       END IF;
   $END 
   Client_SYS.Add_To_Attr('LOAD_ERROR', newrec_.load_error, attr_);   
   amount_ := nvl(newrec_.debet_amount,-newrec_.credit_amount);
   IF ( nvl(newrec_.debet_amount,0)=0 AND nvl(newrec_.credit_amount,0)=0 ) THEN
      IF newrec_.amount != 0  THEN
         IF ( newrec_.amount > 0 ) THEN
            newrec_.debet_amount := amount_;
         ELSE
            newrec_.credit_amount:= -amount_;
         END IF;
      END IF;
   END IF;   
   currency_amount_ := nvl(newrec_.currency_debet_amount,-newrec_.currency_credit_amount);
   IF (nvl(newrec_.currency_debet_amount,0)=0 AND nvl(newrec_.currency_credit_amount,0)=0) THEN
      IF newrec_.currency_amount != 0 THEN
         IF ( newrec_.currency_amount > 0 ) THEN
            newrec_.currency_debet_amount := currency_amount_;
         ELSE
            newrec_.currency_credit_amount:= -currency_amount_;
         END IF;
      END IF;
   END IF;      
   
   third_currency_amount_ := nvl(newrec_.third_currency_debit_amount,-newrec_.third_currency_credit_amount);
   IF ( nvl(newrec_.third_currency_debit_amount,0)=0 AND nvl(newrec_.third_currency_credit_amount,0)=0 ) THEN
      IF newrec_.third_currency_amount != 0  THEN
         IF ( newrec_.third_currency_amount > 0 ) THEN
            newrec_.third_currency_debit_amount := third_currency_amount_;
         ELSE
            newrec_.third_currency_credit_amount:= -third_currency_amount_;
         END IF;
      END IF;
   END IF;
 

   IF newrec_.optional_code IS NOT NULL AND newrec_.tax_direction IS NOT NULL AND
      newrec_.tax_amount IS NOT NULL AND newrec_.currency_tax_amount IS NOT NULL THEN   
   
   -- Considering only Net Amounts for Tax Base Amounts
      IF amount_ IS NOT NULL THEN 
         newrec_.tax_base_amount  := amount_;    
      END IF;
      
      -- Considering only Net Amounts for Currency Tax Base Amounts
      IF currency_amount_ IS NOT NULL THEN 
          newrec_.currency_tax_base_amount  := currency_amount_; 
      ELSE
        IF newrec_.debet_amount IS NOT NULL THEN 
         newrec_.tax_base_amount := newrec_.debet_amount; 
        ELSIF newrec_.credit_amount IS NOT NULL THEN 
            newrec_.tax_base_amount := -newrec_.credit_amount; 
        END IF;
        IF newrec_.currency_debet_amount IS NOT NULL THEN 
            newrec_.currency_tax_base_amount := newrec_.currency_debet_amount; 
        ELSIF newrec_.currency_credit_amount IS NOT NULL THEN 
            newrec_.currency_tax_base_amount :=  -newrec_.currency_credit_amount;
        END IF; 
      END IF;
      -- Considering only Net Amounts for Third Currency Tax Base Amounts
      IF third_currency_amount_ IS NOT NULL THEN
          newrec_.third_curr_tax_base_amount  := newrec_.third_currency_amount;
      ELSE
        IF newrec_.third_currency_debit_amount IS NOT NULL THEN
         newrec_.third_curr_tax_base_amount := newrec_.third_currency_debit_amount;
        ELSIF newrec_.third_currency_credit_amount IS NOT NULL THEN
            newrec_.third_curr_tax_base_amount := -newrec_.third_currency_credit_amount;
        END IF;
      END IF;
   END IF;

   IF (newrec_.rowstate != 'Loaded') OR ((newrec_.load_error IS NULL ) AND (nvl(Ext_Transactions_API.Get_Alter_Trans(newrec_.company, newrec_.load_id),' ') != 'TRUE')) THEN
      RAISE cannotupdatexp;
   END IF;

   Company_Finance_api.Get_Accounting_Currency(currency_code_, newrec_.company);
  
   IF (newrec_.currency_code = currency_code_ AND newrec_.currency_amount IS NULL) THEN 
      currency_amount_                := amount_;
      IF (newrec_.debet_amount IS NOT NULL) THEN
         newrec_.currency_debet_amount  := newrec_.debet_amount;
      ELSIF (newrec_.credit_amount IS NOT NULL) THEN
         newrec_.currency_credit_amount := newrec_.credit_amount;
      END IF;
   END IF;

   transaction_rec_.company                 := newrec_.company;
   transaction_rec_.load_id                 := newrec_.load_id;
   transaction_rec_.record_no               := newrec_.record_no;
   transaction_rec_.load_group_item         := newrec_.load_group_item;
   transaction_rec_.load_error              := newrec_.load_error;
   transaction_rec_.transaction_date        := newrec_.transaction_date;
   transaction_rec_.voucher_type            := newrec_.voucher_type;
   transaction_rec_.voucher_no              := newrec_.voucher_no;
   transaction_rec_.accounting_year         := newrec_.accounting_year;
   transaction_rec_.codestring_rec.code_a   := newrec_.account;
   transaction_rec_.codestring_rec.code_b   := newrec_.code_b;
   transaction_rec_.codestring_rec.code_c   := newrec_.code_c;
   transaction_rec_.codestring_rec.code_d   := newrec_.code_d;
   transaction_rec_.codestring_rec.code_e   := newrec_.code_e;
   transaction_rec_.codestring_rec.code_f   := newrec_.code_f;
   transaction_rec_.codestring_rec.code_g   := newrec_.code_g;
   transaction_rec_.codestring_rec.code_h   := newrec_.code_h;
   transaction_rec_.codestring_rec.code_i   := newrec_.code_i;
   transaction_rec_.codestring_rec.code_j   := newrec_.code_j;
   transaction_rec_.currency_debet_amount   := newrec_.currency_debet_amount;
   transaction_rec_.currency_credit_amount  := newrec_.currency_credit_amount;
   transaction_rec_.currency_amount         := currency_amount_;         
   transaction_rec_.debet_amount            := newrec_.debet_amount;
   transaction_rec_.credit_amount           := newrec_.credit_amount;
   transaction_rec_.amount                  := amount_;                           
   transaction_rec_.currency_code           := newrec_.currency_code;
   transaction_rec_.quantity                := newrec_.quantity;
   transaction_rec_.process_code            := newrec_.process_code;
   transaction_rec_.optional_code           := newrec_.optional_code;
   transaction_rec_.text                    := newrec_.text;
   transaction_rec_.party_type              := newrec_.party_type;
   transaction_rec_.party_type_id           := newrec_.party_type_id;
   transaction_rec_.reference_number        := newrec_.reference_number;
   transaction_rec_.reference_serie         := newrec_.reference_serie;
   transaction_rec_.trans_code              := newrec_.trans_code;
   transaction_rec_.project_activity_id     := newrec_.project_activity_id; 
   transaction_rec_.tax_direction           := newrec_.tax_direction;
   transaction_rec_.tax_amount              := newrec_.tax_amount;
   transaction_rec_.currency_tax_amount     := newrec_.currency_tax_amount;
   transaction_rec_.tax_base_amount         := newrec_.tax_base_amount;
   transaction_rec_.currency_tax_base_amount:= newrec_.currency_tax_base_amount;
   transaction_rec_.user_group              := newrec_.user_group;
   transaction_rec_.user_id                 := newrec_.user_id;
   transaction_rec_.third_currency_amount   := third_currency_amount_;
   transaction_rec_.third_currency_tax_amount := newrec_.third_currency_tax_amount;
   transaction_rec_.third_curr_tax_base_amount:= newrec_.third_curr_tax_base_amount;
   transaction_rec_.modify_codestr_cmpl     := 'TRUE';
   Ext_Check_API.Check_Transaction( err_msg_, 
                                    transaction_rec_ );
   newrec_.load_error := err_msg_;

   is_project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(newrec_.company, 'PRACC');

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

   $IF Component_Genled_SYS.INSTALLED $THEN
      is_proj_ext_created_ := Accounting_Project_Api.Get_Externally_Created ( newrec_.company, 
                                                                              dummy_codepart_value_);
      IF (dummy_codepart_value_ IS NOT NULL) THEN
         project_origin_:= Accounting_Project_API.Get_Project_Origin_Db( newrec_.company , dummy_codepart_value_ );
      END IF;
   $ELSE
      IF (dummy_codepart_value_ IS NOT NULL) THEN
         project_origin_ := NULL;
      END IF;
   $END

   
   IF (project_origin_ = 'PROJECT') AND (is_proj_ext_created_ = 'Y') AND (newrec_.project_activity_id IS NULL) THEN
      
      IF NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'FALSE' THEN    
         Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Project Activity Id must have a value for Project :P1', dummy_codepart_value_);
      END IF;
   ELSIF (project_origin_ = 'PROJECT') AND (newrec_.project_activity_id IS NOT NULL) AND (newrec_.project_activity_id > 0 ) AND
      NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', newrec_.account);
   END IF;   
   
   IF (newrec_.project_activity_id IS NOT NULL) THEN
      $IF Component_Proj_SYS.INSTALLED $THEN
         Activity_api.Exist(newrec_.project_activity_id);
      $ELSE
         NULL;
      $END
   END IF;

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
   WHEN cannotupdatexp THEN
      Client_SYS.Clear_Attr(attr_);
      IF (nvl(oldrec_.load_group_item, ' ') != nvl(newrec_.load_group_item, ' ')) THEN
         Client_SYS.Add_To_Attr('LOAD_GROUP_ITEM', oldrec_.load_group_item, attr_);
      END IF;
      IF ((oldrec_.transaction_date IS NULL AND newrec_.transaction_date IS NOT NULL) OR
          (oldrec_.transaction_date IS NOT NULL AND newrec_.transaction_date IS NULL) OR
          (oldrec_.transaction_date!= newrec_.transaction_date)) THEN
         Client_SYS.Add_To_Attr('TRANSACTION_DATE', oldrec_.transaction_date, attr_);
      END IF;
      IF (nvl(oldrec_.voucher_type, ' ') != nvl(newrec_.voucher_type, ' ')) THEN
         Client_SYS.Add_To_Attr('VOUCHER_TYPE', oldrec_.voucher_type, attr_);
      END IF;
      IF (nvl(oldrec_.voucher_no, 0) != nvl(newrec_.voucher_no, 0)) THEN
         Client_SYS.Add_To_Attr('VOUCHER_NO', oldrec_.voucher_no, attr_);
      END IF;
      IF (nvl(oldrec_.accounting_year, 0) != nvl(newrec_.accounting_year, 0)) THEN
         Client_SYS.Add_To_Attr('ACCOUNTING_YEAR', oldrec_.accounting_year, attr_);
      END IF;
      IF (nvl(oldrec_.account, ' ') != nvl(newrec_.account, ' ')) THEN
         Client_SYS.Add_To_Attr('ACCOUNT', oldrec_.account, attr_);
         Client_SYS.Add_To_Attr('DEMAND_STRING', Ext_Transactions_API.Get_Demand_String_(oldrec_.company, oldrec_.account), attr_);
      END IF;
      IF (nvl(oldrec_.code_b, ' ') != nvl(newrec_.code_b, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_B', oldrec_.code_b, attr_);
      END IF;
      IF (nvl(oldrec_.code_c, ' ') != nvl(newrec_.code_c, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_C', oldrec_.code_c, attr_);
      END IF;
      IF (nvl(oldrec_.code_d, ' ') != nvl(newrec_.code_d, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_D', oldrec_.code_d, attr_);
      END IF;
      IF (nvl(oldrec_.code_e, ' ') != nvl(newrec_.code_e, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_E', oldrec_.code_e, attr_);
      END IF;
      IF (nvl(oldrec_.code_f, ' ') != nvl(newrec_.code_f, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_F', oldrec_.code_f, attr_);
      END IF;
      IF (nvl(oldrec_.code_g, ' ') != nvl(newrec_.code_g, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_G', oldrec_.code_g, attr_);
      END IF;
      IF (nvl(oldrec_.code_h, ' ') != nvl(newrec_.code_h, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_H', oldrec_.code_h, attr_);
      END IF;
      IF (nvl(oldrec_.code_i, ' ') != nvl(newrec_.code_i, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_I', oldrec_.code_i, attr_);
      END IF;
      IF (nvl(oldrec_.code_j, ' ') != nvl(newrec_.code_j, ' ')) THEN
         Client_SYS.Add_To_Attr('CODE_J', oldrec_.code_j, attr_);
      END IF;

      IF (nvl(oldrec_.currency_debet_amount, 0) != nvl(newrec_.currency_debet_amount, 0)) THEN
         Client_SYS.Add_To_Attr('CURRENCY_DEBET_AMOUNT', oldrec_.currency_debet_amount, attr_);
      END IF;
      IF (nvl(oldrec_.currency_credit_amount, 0) != nvl(newrec_.currency_credit_amount, 0)) THEN
         Client_SYS.Add_To_Attr('CURRENCY_CREDIT_AMOUNT', oldrec_.currency_credit_amount, attr_);
      END IF;
      IF (nvl(oldrec_.currency_amount, 0) != nvl(newrec_.currency_amount, 0)) THEN   -- to support old version
         Client_SYS.Add_To_Attr('CURRENCY_AMOUNT', oldrec_.currency_amount, attr_);
      END IF;
      IF (nvl(oldrec_.debet_amount, 0) != nvl(newrec_.debet_amount, 0)) THEN
         Client_SYS.Add_To_Attr('DEBET_AMOUNT', oldrec_.debet_amount, attr_);
      END IF;
      IF (nvl(oldrec_.credit_amount, 0) != nvl(newrec_.credit_amount, 0)) THEN
         Client_SYS.Add_To_Attr('CREDIT_AMOUNT', oldrec_.credit_amount, attr_);
      END IF;
      IF (nvl(oldrec_.amount, 0) != nvl(newrec_.amount, 0)) THEN                    -- to support old version
         Client_SYS.Add_To_Attr('AMOUNT', oldrec_.amount, attr_);
      END IF;

      IF (nvl(oldrec_.currency_code, ' ') != nvl(newrec_.currency_code, ' ')) THEN
         Client_SYS.Add_To_Attr('CURRENCY_CODE', oldrec_.currency_code, attr_);
      END IF;
      IF (nvl(oldrec_.quantity, 0) != nvl(newrec_.quantity, 0)) THEN
         Client_SYS.Add_To_Attr('QUANTITY', oldrec_.quantity, attr_);
      END IF;
      IF (nvl(oldrec_.process_code, ' ') != nvl(newrec_.process_code, ' ')) THEN
         Client_SYS.Add_To_Attr('PROCESS_CODE', oldrec_.process_code, attr_);
      END IF;
      IF (nvl(oldrec_.optional_code, ' ') != nvl(newrec_.optional_code, ' ')) THEN
         Client_SYS.Add_To_Attr('OPTIONAL_CODE', oldrec_.optional_code, attr_);
      END IF;
      IF (nvl(oldrec_.text, ' ') != nvl(newrec_.text, ' ')) THEN
         Client_SYS.Add_To_Attr('TEXT', oldrec_.text, attr_);
      END IF;
      IF (nvl(oldrec_.party_type, ' ') != nvl(newrec_.party_type, ' ')) THEN
         Client_SYS.Add_To_Attr('PARTY_TYPE', oldrec_.party_type, attr_);
      END IF;
      IF (nvl(oldrec_.party_type_id, ' ') != nvl(newrec_.party_type_id, ' ')) THEN
         Client_SYS.Add_To_Attr('PARTY_TYPE_ID', oldrec_.party_type_id, attr_);
      END IF;
      IF (nvl(oldrec_.reference_number, ' ') != nvl(newrec_.reference_number, ' ')) THEN
         Client_SYS.Add_To_Attr('REFERENCE_NUMBER', oldrec_.reference_number, attr_);
      END IF;
      IF (nvl(oldrec_.reference_serie, ' ') != nvl(newrec_.reference_serie, ' ')) THEN
         Client_SYS.Add_To_Attr('REFERENCE_SERIE', oldrec_.reference_serie, attr_);
      END IF;
      IF (nvl(oldrec_.trans_code, ' ') != nvl(newrec_.trans_code, ' ')) THEN
         Client_SYS.Add_To_Attr('TRANS_CODE', oldrec_.trans_code, attr_);
      END IF;
      IF (nvl(oldrec_.tax_direction, ' ') != nvl(newrec_.tax_direction, ' ')) THEN  
         Client_SYS.Add_To_Attr('TAX_DIRECTION', oldrec_.tax_direction, attr_);
      END IF;
      IF (nvl(oldrec_.tax_amount, 0) != nvl(newrec_.tax_amount, 0)) THEN   
         Client_SYS.Add_To_Attr('TAX_AMOUNT', oldrec_.tax_amount, attr_);
      END IF;
      IF (nvl(oldrec_.currency_tax_amount, 0) != nvl(newrec_.currency_tax_amount, 0)) THEN   
         Client_SYS.Add_To_Attr('CURRENCY_TAX_AMOUNT', oldrec_.currency_tax_amount, attr_);
      END IF;
      IF (nvl(oldrec_.third_currency_tax_amount, 0) != nvl(newrec_.third_currency_tax_amount, 0)) THEN   
         Client_SYS.Add_To_Attr('THIRD_CURRENCY_TAX_AMOUNT', oldrec_.third_currency_tax_amount, attr_);
      END IF;
      IF (nvl(oldrec_.user_group, 0) != nvl(newrec_.user_group, 0)) THEN
         Client_SYS.Add_To_Attr('USER_GROUP', oldrec_.user_group, attr_);
      END IF;
      IF (nvl(oldrec_.user_id, 0) != nvl(newrec_.user_id, 0)) THEN
         Client_SYS.Add_To_Attr('USER_ID', oldrec_.user_id, attr_);
      END IF;
      
      newrec_ := oldrec_;
      IF (newrec_.rowstate != 'Loaded') THEN
         Client_SYS.Add_Info(lu_name_,'NOTLOADSTAT: You can only change record with status Loaded.');
      ELSE
         Client_SYS.Add_Info(lu_name_,'NOTRECERR: You cannot change the record without an error.');
      END IF;
END Check_Update___;

PROCEDURE Check_Account_Ref___ (
   newrec_ IN OUT ext_transactions_tab%ROWTYPE )
IS
BEGIN
   Account_API.Exist_Account_And_Pseudo(newrec_.company, newrec_.account);
END;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

FUNCTION Get_Ext_Complete_Code_Str__ (
   company_         IN VARCHAR2,
   load_id_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   use_codestr_compl_ VARCHAR2(5);
   return_val_        VARCHAR2(400);
   req_code_str_      VARCHAR2(2000);
   req_id_            VARCHAR2(10);
   account_in_attr_   VARCHAR2(100);
BEGIN
   use_codestr_compl_:= Ext_Parameters_API.Get_Use_Codestr_Compl(company_,
                                                                 Ext_Load_Info_API.Get_Load_Type (company_,
                                                                                                  load_id_ ));
   IF use_codestr_compl_ = 'TRUE' THEN
      return_val_:= Accounting_Codestr_Compl_API.Get_Complete_CodeString(company_,
                                                                         code_part_,
                                                                         code_part_value_);
      account_in_attr_ := Client_SYS.Get_Item_Value('ACCOUNT',return_val_);
      IF ((code_part_ = 'A' AND  code_part_value_  IS NOT NULL)
          OR account_in_attr_ IS NOT NULL )THEN
          IF code_part_ != 'A' THEN
            Account_API.Get_Required_Code_Part(req_code_str_,
                                               company_,
                                               account_in_attr_);
          ELSE
            Account_API.Get_Required_Code_Part( req_code_str_,
                                                company_,
                                                code_part_value_);
          END IF;

         FOR i_ IN 2..10 LOOP
            req_id_    := Client_SYS.Get_Item_Value('CODE_'||CHR(64+i_), req_code_str_);
            IF req_id_ = 'S' THEN
               return_val_ := Client_SYS.Remove_Attr('CODE_'||CHR(64+i_), return_val_); 
            END IF;
         END LOOP;
      END IF;                                                                   
   ELSE
      return_val_:= NULL;
   END IF;
   RETURN return_val_;
END Get_Ext_Complete_Code_Str__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

@UncheckedAccess
FUNCTION Get_Demand_String_ (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   i_             NUMBER;
   demand_string_ VARCHAR2(100);
   code_part_     VARCHAR2(1);
BEGIN
   demand_string_ := '';
   i_ := 1;
   WHILE ( i_<=9 ) LOOP
      IF (i_=1 ) THEN
         code_part_ := 'B';
      ELSIF (i_=2) THEN
         code_part_ := 'C';
      ELSIF (i_=3) THEN
         code_part_ := 'D';
      ELSIF (i_=4) THEN
         code_part_ := 'E';
      ELSIF (i_=5) THEN
         code_part_ := 'F';
      ELSIF (i_=6) THEN
         code_part_ := 'G';
      ELSIF (i_=7) THEN
         code_part_ := 'H';
      ELSIF (i_=8) THEN
         code_part_ := 'I';
      ELSIF (i_=9) THEN
         code_part_ := 'J';
      END IF;
      demand_string_ := demand_string_ || to_char(i_) || Accounting_Code_Part_A_API.Get_Code_Part_Demand(company_, account_, code_part_);
      i_ := i_ + 1;
   END LOOP;
   RETURN(demand_string_);
END Get_Demand_String_;


@UncheckedAccess
FUNCTION Get_Accounting_Period_ (
   company_      IN VARCHAR2,
   voucher_date_ IN DATE ) RETURN NUMBER
IS
   acc_period_ NUMBER;
BEGIN
   acc_period_ := Accounting_Period_API.Get_Accounting_Period (company_, 
                                                               voucher_date_);
   RETURN acc_period_;
END Get_Accounting_Period_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE New_Transaction (
   company_         IN     VARCHAR2,
   load_id_         IN     VARCHAR2,
   transaction_rec_ IN OUT ExtTransRec )
IS
   rec_no_                 NUMBER;
   date_param_             VARCHAR2(100);
   voucher_date_           DATE;
   ext_group_item_         VARCHAR2(1); 
   err_mess_               VARCHAR2(2000);
   third_currency_code_     VARCHAR2(3);
BEGIN
   third_currency_code_ := Currency_Code_API.Get_Parallel_Acc_Currency (company_);
   IF (transaction_rec_.ext_vouch_date IS NOT NULL) THEN
      date_param_ := transaction_rec_.ext_vouch_date;
   ELSE
      Ext_Parameters_API.Get_Ext_Voucher_Date (date_param_, 
                                               company_, 
                                               transaction_rec_.load_type);
   END IF;
   IF (date_param_ = 1) THEN
      IF (transaction_rec_.load_date IS NOT NULL) THEN
         voucher_date_ := transaction_rec_.load_date;
      ELSE
         Ext_Load_Info_Api.Get_Load_Load_Date (voucher_date_, 
                                               company_, 
                                               load_id_);
      END IF;
   ELSE
      voucher_date_ := transaction_rec_.transaction_date;
   END IF;
   

   Get_Next_Record_No___ ( rec_no_,
                           company_,
                           load_id_ );
   
   IF ( nvl(transaction_rec_.debet_amount,0)=0 AND nvl(transaction_rec_.credit_amount,0)=0 ) THEN   
      IF (NVL(transaction_rec_.amount, 0) >= 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.amount, 0) < 0 AND transaction_rec_.correction = 'TRUE') THEN
         transaction_rec_.debet_amount  := transaction_rec_.amount;
         transaction_rec_.credit_amount := NULL;
      ELSIF (NVL(transaction_rec_.amount, 0) >= 0 AND transaction_rec_.correction = 'TRUE') OR (NVL(transaction_rec_.amount, 0) < 0 AND transaction_rec_.correction = 'FALSE') THEN
         transaction_rec_.credit_amount := -transaction_rec_.amount;
         transaction_rec_.debet_amount  := NULL;
      END IF;
   END IF;
   IF ( nvl(transaction_rec_.currency_debet_amount,0)=0 AND nvl(transaction_rec_.currency_credit_amount,0)=0 ) THEN 
      IF (NVL(transaction_rec_.currency_amount, 0) >= 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.currency_amount, 0) < 0 AND transaction_rec_.correction = 'TRUE') THEN
         transaction_rec_.currency_debet_amount  := transaction_rec_.currency_amount;
         transaction_rec_.currency_credit_amount := NULL;
      ELSIF (NVL(transaction_rec_.currency_amount, 0) >= 0 AND transaction_rec_.correction = 'TRUE') OR (NVL(transaction_rec_.currency_amount, 0) < 0 AND transaction_rec_.correction = 'FALSE') THEN
         transaction_rec_.currency_credit_amount := -transaction_rec_.currency_amount;
         transaction_rec_.currency_debet_amount  := NULL;
      END IF;
   END IF;
   IF (transaction_rec_.ext_group_item IS NOT NULL) THEN
      ext_group_item_ := transaction_rec_.ext_group_item;
   ELSE
      Ext_Parameters_API.Get_Ext_Group_Item (ext_group_item_,
                                             company_, 
                                             transaction_rec_.load_type );
   END IF;
   IF (ext_group_item_ = '1') THEN
      transaction_rec_.load_group_item := transaction_rec_.voucher_type || TO_CHAR(transaction_rec_.voucher_no);
   ELSIF (ext_group_item_ = '3') THEN
      transaction_rec_.load_group_item := TO_CHAR(trunc(transaction_rec_.transaction_date));
   ELSIF (ext_group_item_ = '4') THEN
      transaction_rec_.load_group_item := transaction_rec_.reference_number;
   END IF;
   IF (transaction_rec_.load_group_item IS NULL) THEN
      transaction_rec_.load_group_item := '?';
   END IF;
 
   IF (NVL(transaction_rec_.credit_amount,0)< 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.credit_amount,0) > 0 AND transaction_rec_.correction = 'TRUE') THEN
      transaction_rec_.amount := transaction_rec_.credit_amount;
      transaction_rec_.credit_amount := -transaction_rec_.credit_amount;
   END IF;
   IF (NVL(transaction_rec_.debet_amount,0)< 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.debet_amount,0) > 0 AND transaction_rec_.correction = 'TRUE') THEN
      transaction_rec_.amount := -transaction_rec_.debet_amount;
      transaction_rec_.debet_amount := -transaction_rec_.debet_amount;
   END IF;
   
   IF (NVL(transaction_rec_.currency_credit_amount,0)< 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.currency_credit_amount,0) > 0 AND transaction_rec_.correction = 'TRUE') THEN
      transaction_rec_.currency_amount := transaction_rec_.currency_credit_amount;
      transaction_rec_.currency_credit_amount := -transaction_rec_.currency_credit_amount;
   END IF;
   IF (NVL(transaction_rec_.currency_debet_amount,0)< 0 AND transaction_rec_.correction = 'FALSE') OR (NVL(transaction_rec_.currency_debet_amount,0) > 0 AND transaction_rec_.correction = 'TRUE')THEN
      transaction_rec_.currency_amount := -transaction_rec_.currency_debet_amount;
      transaction_rec_.currency_debet_amount := -transaction_rec_.currency_debet_amount;
   END IF;

   -- As amount is from nvl(debet_amount,-credit_amount) in Ext_Transaction view.   
   IF (transaction_rec_.debet_amount = 0) AND NVL(transaction_rec_.credit_amount,0)!=0  THEN
      transaction_rec_.debet_amount := NULL;
   END IF;   
   IF (transaction_rec_.credit_amount = 0) AND NVL(transaction_rec_.debet_amount,0)!=0 THEN
      transaction_rec_.credit_amount := NULL;
   END IF;
    
   -- As currency_amount is from nvl(currency_debet_amount,-currency_credit_amount) in Ext_Transaction view.   
   IF (transaction_rec_.currency_debet_amount = 0) AND NVL(transaction_rec_.currency_credit_amount,0) !=0 THEN
      transaction_rec_.currency_debet_amount := NULL;
   END IF;   
   IF (transaction_rec_.currency_credit_amount = 0) AND NVL(transaction_rec_.currency_debet_amount,0) !=0 THEN
      transaction_rec_.currency_credit_amount := NULL;
   END IF; 
 
-- Modified amount,currency_amount,tax_amount,currency_tax_amount,tax_base_amount
-- and currency_tax_base_amount  to be checked not null.  

   IF transaction_rec_.optional_code IS NOT NULL AND transaction_rec_.tax_direction IS NOT NULL AND
      transaction_rec_.tax_amount IS NOT NULL AND transaction_rec_.currency_tax_amount IS NOT NULL THEN   
      IF (transaction_rec_.third_currency_tax_amount IS NOT NULL OR (transaction_rec_.third_currency_tax_amount IS NULL AND third_currency_code_ IS NULL))THEN
         IF (transaction_rec_.tax_base_amount IS NULL) THEN
            IF transaction_rec_.amount IS NOT NULL THEN
            transaction_rec_.tax_base_amount  := transaction_rec_.amount;
            ELSE
               IF transaction_rec_.debet_amount IS NOT NULL THEN 
                  transaction_rec_.tax_base_amount := transaction_rec_.debet_amount; 
               ELSIF transaction_rec_.credit_amount IS NOT NULL THEN 
                  transaction_rec_.tax_base_amount := -transaction_rec_.credit_amount; 
               END IF;    
            END IF;
         END IF;
         IF (transaction_rec_.currency_tax_base_amount IS NULL) THEN
            -- Considering only Net Amounts for Currency Tax Base Amounts
            IF transaction_rec_.currency_amount IS NOT NULL THEN
               transaction_rec_.currency_tax_base_amount  := transaction_rec_.currency_amount;
            ELSE
               IF transaction_rec_.currency_debet_amount IS NOT NULL THEN 
                  transaction_rec_.currency_tax_base_amount := transaction_rec_.currency_debet_amount; 
               ELSIF transaction_rec_.credit_amount IS NOT NULL THEN 
                  transaction_rec_.currency_tax_base_amount :=  -transaction_rec_.currency_credit_amount;
               END IF;       
            END IF;
         END IF;
         IF (transaction_rec_.third_curr_tax_base_amount IS NULL) THEN
            IF transaction_rec_.third_currency_amount IS NOT NULL THEN
               transaction_rec_.third_curr_tax_base_amount  := transaction_rec_.third_currency_amount;
            ELSE
               IF transaction_rec_.third_currency_debit_amount IS NOT NULL THEN 
                  transaction_rec_.third_curr_tax_base_amount := transaction_rec_.third_currency_debit_amount; 
               ELSIF transaction_rec_.third_currency_credit_amount IS NOT NULL THEN 
                  transaction_rec_.third_curr_tax_base_amount :=  -transaction_rec_.third_currency_credit_amount;
               END IF; 
            END IF;
         END IF;
      END IF;
   END IF;
   
   IF (transaction_rec_.user_group IS NULL) THEN
      transaction_rec_.user_group := User_Group_Member_Finance_Api.Get_Default_Group(transaction_rec_.company, 
                                                                                     transaction_rec_.user_id);  
   END IF;
   transaction_rec_.record_no := rec_no_;

   BEGIN
      IF transaction_rec_.correction = 'ECRD' OR transaction_rec_.correction = 'EDEB' OR transaction_rec_.correction = 'EAMT' THEN
         transaction_rec_.correction := 'FALSE';
      END IF;
      
      IF (transaction_rec_.trans_code IS NOT NULL) AND (transaction_rec_.trans_code != 'EXTERNAL') THEN
         IF Voucher_Type_Detail_API.Get_Function_Group(transaction_rec_.company, transaction_rec_.voucher_type) IN ('M', 'K', 'Q') THEN
            transaction_rec_.trans_code := NULL;
         END IF;   
      END IF;
      
      Removed_Unused_Codeprts___ (transaction_rec_.codestring_rec,
                                  transaction_rec_.company);
      transaction_rec_.modify_codestr_cmpl := 'FALSE';

      IF (transaction_rec_.correction IS NULL) THEN
         transaction_rec_.correction := 'FALSE';
      END IF;

      INSERT
         INTO EXT_TRANSACTIONS_TAB (
            company,
            load_id,
            record_no,
            load_group_item,
            transaction_date,
            voucher_no,
            accounting_year,
            voucher_type,
            currency_debet_amount,
            currency_credit_amount,
            debet_amount,
            credit_amount,
            third_currency_debit_amount,
            third_currency_credit_amount,
            third_currency_amount,
            third_currency_tax_amount,
            currency_code,
            quantity,
            process_code,
            optional_code,
            tax_percentage,
            project_activity_id,
            text,
            party_type,
            party_type_id,
            reference_number,
            reference_serie,
            trans_code,
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
            tax_direction,
            tax_amount,
            currency_tax_amount,
            tax_base_amount,
            currency_tax_base_amount,
            user_group,
            user_id,
            correction,
            load_type,
            currency_rate,
            modify_codestr_cmpl,
            event_date,
            retroactive_date,
            transaction_reason,
            third_curr_tax_base_amount,
            deliv_type_id,
            currency_rate_type,
            parallel_curr_rate_type,
            rowversion,
            rowstate )
         VALUES (
            company_,
            load_id_,
            transaction_rec_.record_no,
            transaction_rec_.load_group_item,
            transaction_rec_.transaction_date,
            transaction_rec_.voucher_no,
            transaction_rec_.accounting_year,
            transaction_rec_.voucher_type,
            transaction_rec_.currency_debet_amount,
            transaction_rec_.currency_credit_amount,
            transaction_rec_.debet_amount,
            transaction_rec_.credit_amount,
            transaction_rec_.third_currency_debit_amount,
            transaction_rec_.third_currency_credit_amount,
            transaction_rec_.third_currency_amount,
            transaction_rec_.third_currency_tax_amount,
            transaction_rec_.currency_code,
            transaction_rec_.quantity,
            transaction_rec_.process_code,
            transaction_rec_.optional_code,
            transaction_rec_.tax_percentage,
            transaction_rec_.project_activity_id,
            transaction_rec_.text,
            transaction_rec_.party_type,
            transaction_rec_.party_type_id,
            transaction_rec_.reference_number,
            transaction_rec_.reference_serie,
            transaction_rec_.trans_code,
            transaction_rec_.codestring_rec.code_a,
            transaction_rec_.codestring_rec.code_b,
            transaction_rec_.codestring_rec.code_c,
            transaction_rec_.codestring_rec.code_d,
            transaction_rec_.codestring_rec.code_e,
            transaction_rec_.codestring_rec.code_f,
            transaction_rec_.codestring_rec.code_g,
            transaction_rec_.codestring_rec.code_h,
            transaction_rec_.codestring_rec.code_i,
            transaction_rec_.codestring_rec.code_j,
            transaction_rec_.tax_direction,
            transaction_rec_.tax_amount,
            transaction_rec_.currency_tax_amount,
            transaction_rec_.tax_base_amount,
            transaction_rec_.currency_tax_base_amount,
            transaction_rec_.user_group,
            transaction_rec_.user_id,
            transaction_rec_.correction,
            transaction_rec_.load_type,
            transaction_rec_.currency_rate,
            transaction_rec_.modify_codestr_cmpl,
            transaction_rec_.event_date,
            transaction_rec_.retroactive_date,
            transaction_rec_.transaction_reason,
            transaction_rec_.third_curr_tax_base_amount,
            transaction_rec_.deliv_type_id,
            transaction_rec_.currency_rate_type,
            transaction_rec_.parallel_curr_rate_type,
            sysdate,
            'Loaded' );
   EXCEPTION
      WHEN OTHERS THEN
         err_mess_ := SQLERRM;
         Ext_File_Trans_API.Update_Row_State (transaction_rec_.load_file_id,
                                              transaction_rec_.row_no,
                                              '5',
                                              err_mess_);
   END;
END New_Transaction;


PROCEDURE Update_Transaction (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET load_error = NULL,
          rowstate   = 'Updated'
   WHERE  company = company_
   AND    load_id = load_id_
   AND    rowstate = 'Checked';    
END Update_Transaction;


PROCEDURE Update_Transaction (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2,
   rowstate_from_  IN VARCHAR2,
   rowstate_to_    IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET   rowstate = rowstate_to_
   WHERE  company = company_
   AND    load_id = load_id_
   AND    rowstate = rowstate_from_;
END Update_Transaction;


PROCEDURE Update_Transaction (
   company_           IN VARCHAR2,
   load_id_           IN VARCHAR2,
   group_by_item_     IN VARCHAR2,
   group_by_value_    IN VARCHAR2,
   voucher_no_        IN NUMBER,
   voucher_date_      IN DATE,
   accounting_year_   IN NUMBER )
IS
   CURSOR get_trans_date IS
      SELECT transaction_date
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company = company_
      AND    load_id = load_id_
      AND    load_group_item = group_by_value_
      FOR UPDATE;              
BEGIN
   FOR rec_ IN get_trans_date LOOP
      IF (rec_.transaction_date IS NULL) THEN
         UPDATE EXT_TRANSACTIONS_TAB
         SET voucher_no       = voucher_no_,
             transaction_date = voucher_date_,  
             accounting_year  = accounting_year_
         WHERE CURRENT OF get_trans_date;
      ELSE
         UPDATE EXT_TRANSACTIONS_TAB
         SET voucher_no      = voucher_no_,
             accounting_year = accounting_year_
         WHERE CURRENT OF get_trans_date;
      END IF;
   END LOOP;
END Update_Transaction;


PROCEDURE Update_Transaction (
   company_           IN VARCHAR2,
   load_id_           IN VARCHAR2,
   load_group_item_   IN VARCHAR2,
   voucher_no_        IN NUMBER,
   voucher_date_      IN DATE,
   accounting_year_   IN NUMBER,
   rowstate_          IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
   SET load_error = NULL,
       voucher_no       = voucher_no_,
       accounting_year  = accounting_year_,
       transaction_date = DECODE(transaction_date,NULL,voucher_date_,transaction_date),
       rowstate         = DECODE(rowstate_,NULL,rowstate,rowstate_)
   WHERE company         = company_
   AND   load_id         = load_id_
   AND   load_group_item = load_group_item_;
END Update_Transaction;


PROCEDURE Update_Transaction (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2,
   group_by_value_ IN VARCHAR2,
   group_by_item_  IN VARCHAR2,
   rowstate_       IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET load_error = null,
          rowstate   = rowstate_
   WHERE  company         = company_
   AND    load_id         = load_id_
   AND    load_group_item = group_by_value_;
END Update_Transaction;


PROCEDURE Validate_Load_Id (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_TRANSACTIONS
      WHERE  company = company_
      AND    load_id = load_id_;
BEGIN
--  IF the load Id exists an error msg will be given
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
         Error_SYS.Record_General('ExtTransactions', 'VALIDATELOADID: Load Id  :P1 exists.', load_id_);
   END IF;
   CLOSE exist_control;
END Validate_Load_Id;


PROCEDURE Update_Load_Error (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2,
   group_by_value_ IN VARCHAR2,
   group_by_item_  IN VARCHAR2,
   load_error_     IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET load_error = load_error_
   WHERE  company         = company_
   AND    load_id         = load_id_
   AND    load_group_item = group_by_value_;
END  Update_Load_Error;


PROCEDURE Update_Load_Error (
   company_    IN VARCHAR2,
   load_id_    IN VARCHAR2,
   record_no_  IN NUMBER,
   load_error_ IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET   load_error = load_error_
   WHERE  company   = company_
   AND    load_id   = load_id_
   AND    record_no = record_no_;
END  Update_Load_Error;


PROCEDURE Update_Project_Error (
   company_             IN VARCHAR2,
   load_id_             IN VARCHAR2,
   project_activity_id_ IN NUMBER,
   load_error_          IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET load_error          = load_error_
   WHERE  company             = company_
   AND    load_id             = load_id_
   AND    project_activity_id = project_activity_id_;
END  Update_Project_Error;


PROCEDURE Clear_All_Error (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2 )
IS
BEGIN
   IF( Exist_Error(company_, load_id_) = 'TRUE') THEN
      UPDATE EXT_TRANSACTIONS_TAB
         SET load_error = NULL
      WHERE  company = company_
      AND    load_id = load_id_
      AND    load_error IS NOT NULL;
   END IF;
   -- check for the update exception,
END Clear_All_Error;


@UncheckedAccess
FUNCTION Exist_Error (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR existerror IS
      SELECT 1
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company    = company_
      AND    load_id    = load_id_
      AND    load_error IS NOT NULL;
BEGIN
   dummy_ := 0;
   OPEN  existerror;
   FETCH existerror INTO dummy_;
   CLOSE existerror;
   IF (dummy_ = 1) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Exist_Error;


PROCEDURE Get_Transaction (
   transaction_rec_   OUT ExtTransRec,
   company_           IN VARCHAR2,
   load_id_           IN VARCHAR2,
   rec_no_            IN NUMBER,
   ext_group_by_item_ IN VARCHAR2,
   group_by_value_    IN VARCHAR2 )
IS
   dummy_         NUMBER;
   record_no_     NUMBER;
   group_by_item_ VARCHAR2(1);
   err_msg_       VARCHAR2(2000);
   next_group_    VARCHAR2(10);
   CURSOR getcount IS
      SELECT 1
      FROM   EXT_TRANSACTIONS
      WHERE company         = company_
      AND   load_id         = load_id_
      AND   load_group_item IS NULL
      AND   objstate        = 'Loaded';
   CURSOR getloadgroupitem IS
      SELECT company,
             load_id,
             record_no,
             load_group_item,
             load_error,
             transaction_date,
             voucher_type,
             voucher_no,
             accounting_year,
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
             currency_debet_amount,
             currency_credit_amount,
             currency_amount,             -- to support old version
             debet_amount,
             credit_amount,
             amount,                      -- to support old version
             currency_code,
             quantity,
             process_code,
             optional_code,
             project_activity_id,
             text,
             party_type,
             party_type_id,
             reference_number,
             reference_serie,
             trans_code
      FROM   EXT_TRANSACTIONS
      WHERE  company = company_
      AND    load_id = load_id_
      AND    objstate = 'Loaded'
      AND    record_no > record_no_
      AND    (((next_group_ = 'FALSE') AND ((load_group_item > nvl(group_by_value_, ' ')) OR (load_group_item = group_by_value_)) )
        OR    ((next_group_ = 'TRUE')  AND  (load_group_item > group_by_value_)))
      ORDER BY load_group_item, record_no;
BEGIN
   group_by_item_ := ext_group_by_item_;
   -- default setting of group_by_item_
   IF (group_by_item_ IS NULL) THEN
      group_by_item_ := '1';
   END IF;

   -- checking for null value in group by column and giving error message
   OPEN getcount;
   FETCH getcount INTO dummy_;
   IF (getcount%FOUND) THEN
      IF (group_by_item_='1') THEN
         err_msg_ := 'VOU_NOT_NULL: Voucher no. should not be null for company :P1, load id :P2';
      ELSIF (group_by_item_='2') THEN
         err_msg_ := 'LOAD_GROUP_ITEM_NOT_NULL: Load group item should not be null for company :P1, load id :P2';
      ELSIF (group_by_item_='3') THEN
         err_msg_ := 'TRANS_DATE_NOT_NULL: Transaction date should not be null for company :P1, load id :P2';
      ELSIF (group_by_item_='4') THEN
         err_msg_ := 'REF_NO_NOT_NULL: Reference number should not be null for company :P1, load id :P2';
      END IF;
      Error_SYS.Record_General(lu_name_, err_msg_, company_, load_id_);
   END IF;
   CLOSE getcount;
   IF (group_by_value_ IS NULL) THEN
      record_no_ := 0;
   ELSE
      record_no_ := rec_no_;
   END IF;
   next_group_ := 'FALSE';

   LOOP
      OPEN getloadgroupitem;
      FETCH getloadgroupitem
         INTO transaction_rec_.company,
              transaction_rec_.load_id,
              transaction_rec_.record_no,
              transaction_rec_.load_group_item,
              transaction_rec_.load_error,
              transaction_rec_.transaction_date,
              transaction_rec_.voucher_type,
              transaction_rec_.voucher_no,
              transaction_rec_.accounting_year,
              transaction_rec_.codestring_rec.code_a,
              transaction_rec_.codestring_rec.code_b,
              transaction_rec_.codestring_rec.code_c,
              transaction_rec_.codestring_rec.code_d,
              transaction_rec_.codestring_rec.code_e,
              transaction_rec_.codestring_rec.code_f,
              transaction_rec_.codestring_rec.code_g,
              transaction_rec_.codestring_rec.code_h,
              transaction_rec_.codestring_rec.code_i,
              transaction_rec_.codestring_rec.code_j,
              transaction_rec_.currency_debet_amount,
              transaction_rec_.currency_credit_amount,
              transaction_rec_.currency_amount,      -- to support old version
              transaction_rec_.debet_amount,
              transaction_rec_.credit_amount,
              transaction_rec_.amount,               -- to support old version
              transaction_rec_.currency_code,
              transaction_rec_.quantity,
              transaction_rec_.process_code,
              transaction_rec_.optional_code,
              transaction_rec_.project_activity_id,
              transaction_rec_.text,
              transaction_rec_.party_type,
              transaction_rec_.party_type_id,
              transaction_rec_.reference_number,
              transaction_rec_.reference_serie,
              transaction_rec_.trans_code;
      CLOSE getloadgroupitem;

      IF (transaction_rec_.record_no IS NOT NULL) OR (next_group_ = 'TRUE') THEN
         EXIT;
      END IF;

      IF (transaction_rec_.record_no IS NULL) THEN -- it means no more recs for the present value are present
           -- in place of here check on group_by_value_ to be NOT NULL can be added in the SQL statement
         IF (group_by_value_ IS NOT NULL) THEN
            next_group_ := 'TRUE';
            record_no_ := 0;
         END IF;
      END IF;
   END LOOP;
END Get_Transaction;


PROCEDURE Get_Count (
   numrec_   OUT NUMBER,
   company_  IN  VARCHAR2,
   load_id_  IN  VARCHAR2,
   rowstate_ IN  VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR getcount IS
      SELECT COUNT(*)
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    rowstate = rowstate_;
BEGIN
   OPEN getcount;
   FETCH getcount INTO dummy_;
   CLOSE getcount;
   IF (dummy_ IS NULL) THEN
      numrec_ := 0;
   ELSE
      numrec_ := dummy_;
   END IF;
END Get_Count;


PROCEDURE Check_Found (
   numrec_   OUT NUMBER,
   company_  IN  VARCHAR2,
   load_id_  IN  VARCHAR2,
   rowstate_ IN  VARCHAR2 )
IS
   CURSOR checkfound IS
      SELECT 1
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    rowstate = rowstate_;
BEGIN
   OPEN checkfound;
   FETCH checkfound INTO numrec_;
   IF (checkfound%NOTFOUND) THEN
      numrec_ := 0;
   END IF;
   CLOSE checkfound;
END Check_Found;


PROCEDURE Check_Other_Found (
   numrec_   OUT NUMBER,
   company_  IN  VARCHAR2,
   load_id_  IN  VARCHAR2,
   rowstate_ IN  VARCHAR2 )
IS
   CURSOR checkfound IS
      SELECT 1
      FROM   EXT_TRANSACTIONS_TAB
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    rowstate != rowstate_;
BEGIN
   OPEN checkfound;
   FETCH checkfound INTO numrec_;
   IF (checkfound%NOTFOUND) THEN
      numrec_ := 0;
   END IF;
   CLOSE checkfound;
END Check_Other_Found;


PROCEDURE Validate_Code_String (
   codestr_rec_      IN OUT Accounting_Codestr_API.CodestrRec,
   company_          IN VARCHAR2,
   user_group_       IN VARCHAR2,
   voucher_date_     IN DATE )
IS
BEGIN
   -- validating the code string
   Accounting_Codestr_API.Validate_Codestring ( codestr_rec_,
                                                company_,
                                                voucher_date_,
                                                user_group_ );
END Validate_Code_String;

PROCEDURE Apply_File_Pseudo (
   codestring_rec_      IN OUT Accounting_Codestr_API.CodestrRec,
   tax_direction_       OUT VARCHAR2, 
   company_             IN VARCHAR2,
   load_id_             IN VARCHAR2,
   record_no_           IN NUMBER)
IS
   attr_             VARCHAR2(2000);
   codestring_attr_  VARCHAR2(2000);
   oldrec_           ext_transactions_tab%ROWTYPE;
   newrec_           ext_transactions_tab%ROWTYPE;
   temprec_          ext_transactions_tab%ROWTYPE;
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
   indrec_           Indicator_Rec;
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(2000);
   err_value_        VARCHAR2(2000);
   msg_              VARCHAR2(2000);
   pseudo_confllict_ BOOLEAN;
   tax_type_         VARCHAR2(100);
   log_act_type_db_  VARCHAR2(10);   
   tax_rec_          Statutory_Fee_API.Public_Rec;     
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, company_, load_id_, record_no_);
   oldrec_ := Lock_By_Keys___(company_, load_id_, record_no_);
   newrec_ := oldrec_;                            
   Pseudo_Codes_API.Get_Complete_Pseudo(codestring_attr_, newrec_.company, newrec_.account);
   WHILE (Client_SYS.Get_Next_From_Attr(codestring_attr_, ptr_, name_, value_)) LOOP
      CASE name_
      WHEN ('ACCOUNT') THEN    
            newrec_.account := value_;
            codestring_rec_.code_a := newrec_.account;
         WHEN ('CODE_B') THEN
            IF (newrec_.code_b IS NOT NULL AND (newrec_.code_b != value_)) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_b;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_b := value_;
               codestring_rec_.code_b := newrec_.code_b;
            END IF;
         WHEN ('CODE_C') THEN
            IF (newrec_.code_c IS NOT NULL AND newrec_.code_c != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_c;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_c := value_;
               codestring_rec_.code_c := newrec_.code_c;
            END IF;
         WHEN ('CODE_D') THEN
            IF (newrec_.code_d IS NOT NULL AND newrec_.code_d != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_d;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_d := value_;
               codestring_rec_.code_d := newrec_.code_d;
            END IF;
         WHEN ('CODE_E') THEN
            IF (newrec_.code_e IS NOT NULL AND newrec_.code_e != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_e;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_e := value_;
               codestring_rec_.code_e := newrec_.code_e;
            END IF;
         WHEN ('CODE_F') THEN
            IF (newrec_.code_f IS NOT NULL AND newrec_.code_f != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_f;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_f := value_;
               codestring_rec_.code_f := newrec_.code_f;
            END IF;
         WHEN ('CODE_G') THEN
            IF (newrec_.code_g IS NOT NULL AND newrec_.code_g != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_g;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_g := value_;
               codestring_rec_.code_g := newrec_.code_g;
            END IF;
         WHEN ('CODE_H') THEN
            IF (newrec_.code_h IS NOT NULL AND newrec_.code_h != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_h;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_h := value_;
               codestring_rec_.code_h := newrec_.code_h;
            END IF;
         WHEN ('CODE_I') THEN
            IF (newrec_.code_i IS NOT NULL AND newrec_.code_i != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_i;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_i := value_;
               codestring_rec_.code_i := newrec_.code_i;
            END IF;
         WHEN ('CODE_J') THEN
            IF (newrec_.code_j IS NOT NULL AND newrec_.code_j != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.code_j;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.code_j := value_;
               codestring_rec_.code_j := newrec_.code_j;
            END IF;
         WHEN ('PROJECT_ACTIVITY_ID') THEN
            IF (newrec_.project_activity_id IS NOT NULL AND newrec_.project_activity_id != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.project_activity_id;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.project_activity_id := value_;
               codestring_rec_.project_activity_id := newrec_.project_activity_id;
            END IF;
         WHEN ('QUANTITY') THEN
            IF (newrec_.quantity IS NOT NULL AND newrec_.quantity != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.quantity;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.quantity := value_;
               codestring_rec_.quantity := newrec_.quantity;
            END IF;
         WHEN ('PROCESS_CODE') THEN
            IF (newrec_.process_code IS NOT NULL AND newrec_.process_code != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.process_code;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.process_code := value_;
               codestring_rec_.process_code := newrec_.process_code;
            END IF;
         WHEN ('TEXT') THEN
            IF (newrec_.text IS NOT NULL AND newrec_.text != value_) THEN
               pseudo_confllict_ := TRUE;
               err_value_ := newrec_.text;
               EXIT;
            END IF;
            IF (value_ IS NOT NULL) THEN
               newrec_.text := value_;
               codestring_rec_.text := newrec_.text;
            END IF;
         ELSE
            Client_SYS.Add_To_Attr(name_, value_, msg_);
         END CASE;
      END LOOP;
      IF (newrec_.optional_code IS NOT NULL AND newrec_.account IS NOT NULL) THEN
         tax_rec_  := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(newrec_.company, newrec_.optional_code, sysdate, 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
         tax_type_ := tax_rec_.fee_type;
         IF (tax_type_ IN (Fee_Type_API.DB_NO_TAX)) THEN
            newrec_.tax_direction := tax_type_;
         ELSE
            IF (newrec_.tax_direction IS NOT NULL) THEN
               newrec_.tax_direction := Tax_Direction_API.Encode(newrec_.tax_direction);
            ELSE
               log_act_type_db_ := Account_API.Get_Logical_Account_Type_Db(newrec_.company, newrec_.account);
               IF (log_act_type_db_ IN ('A', 'C')) THEN
                  -- Assign 'Tax Received'
                  newrec_.tax_direction := Tax_Direction_API.Get_Db_Value(0);
               ELSIF (log_act_type_db_ IN ('L', 'R', 'S', 'O')) THEN
                  -- Assign 'Tax Disbursed'
                  newrec_.tax_direction := Tax_Direction_API.Get_Db_Value(1);
               END IF;
            END IF;
         END IF;
      END IF;  
      tax_direction_ := newrec_.tax_direction;  
      IF (pseudo_confllict_) THEN
         Error_SYS.Appl_General(lu_name_, 'PSEUDO_MISMATCH: The value :P1 defined for :P2 conflicts with the Pseudo Code value.', err_value_, name_ );
      ELSE
         indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
         Client_SYS.Clear_Attr(attr_);
         temprec_ := newrec_;
         Check_Update___(oldrec_, temprec_, indrec_, attr_);
         -- Note: Calling Update___() will cause some methods to be called cyclically, thus bringing about
         --       performance issues.
         UPDATE ext_transactions_tab
         SET    row   = newrec_
         WHERE  ROWID = objid_;
      END IF;
END Apply_File_Pseudo;

@UncheckedAccess
FUNCTION Get_Alter_Trans (
   company_         IN  VARCHAR2,
   load_id_         IN  VARCHAR2 ) RETURN VARCHAR2
IS
   load_type_       VARCHAR2(20);
   ext_alter_trans_ VARCHAR2(5);
BEGIN
	load_type_       := Ext_Load_Info_API.Get_Load_Type ( company_,
                                                         load_id_ );
   ext_alter_trans_ := Ext_Parameters_API.Get_Ext_Alter_Trans ( company_,
                                                                load_type_ );
   RETURN ext_alter_trans_;
END Get_Alter_Trans;


PROCEDURE Update_Error (
   company_         IN VARCHAR2,
   load_id_         IN VARCHAR2,
   load_group_item_ IN VARCHAR2,
   load_error_      IN VARCHAR2,
   rowstate_        IN VARCHAR2 DEFAULT NULL,
   record_no_       IN NUMBER   DEFAULT NULL )  
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
   SET    load_error = DECODE(record_no, record_no_, load_error_, load_error),
          rowstate   = NVL(rowstate_,rowstate_)
   WHERE  company         = company_
   AND    load_id         = load_id_
   AND    load_group_item = load_group_item_ ;
END Update_Error;


PROCEDURE Update_Error (
   objid_      IN VARCHAR2,
   load_error_ IN VARCHAR2,
   rowstate_   IN VARCHAR2 DEFAULT NULL )  
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
   SET    load_error = load_error_,
          rowstate   = NVL(rowstate_,rowstate_)
   WHERE  ROWID = objid_ ;
END Update_Error;


PROCEDURE Update_Error2 (
   company_         IN VARCHAR2,
   load_id_         IN VARCHAR2,
   load_group_item_  IN VARCHAR2,
   record_no_ IN NUMBER,
   load_error_      IN VARCHAR2,
   rowstate_        IN VARCHAR2 DEFAULT NULL )  
IS
BEGIN
   Update_Error ( company_,load_id_,load_group_item_,NULL,'Loaded' ); 
                                                
   UPDATE EXT_TRANSACTIONS_TAB
   SET    load_error = load_error_,
          rowstate   = NVL(rowstate_,rowstate_)
   WHERE  company         = company_
   AND    load_id         = load_id_
   AND    record_no = record_no_ ;
END Update_Error2;


PROCEDURE Update_Errors (
   company_         IN VARCHAR2,
   load_id_         IN VARCHAR2,
   load_group_item_ IN VARCHAR2,
   identity_rec_    IN OUT  Ext_Transactions_API.identity_rec,
   rowstate_        IN VARCHAR2 DEFAULT NULL )  
IS
   row_no_             NUMBER;
BEGIN
   Update_Error ( company_,load_id_,load_group_item_,NULL,'Loaded' ); 
   
   FOR i IN identity_rec_.FIRST..identity_rec_.LAST LOOP
      
      IF  INSTR(identity_rec_(i).err_msg,'ExtCreate.VOUISLEDGER')>0 THEN
         row_no_ := TO_NUMBER(SUBSTR(identity_rec_(i).err_msg,-3,3));
         identity_rec_(i).err_msg := SUBSTR(identity_rec_(i).err_msg,1,LENGTH (identity_rec_(i).err_msg)-3);
         
         UPDATE EXT_TRANSACTIONS_TAB
         SET    load_error = identity_rec_(i).err_msg ,
                rowstate   = NVL(rowstate_,rowstate_)
         WHERE  company         = company_
         AND    load_id         = load_id_
         AND    record_no = row_no_;
      ELSE
         UPDATE EXT_TRANSACTIONS_TAB
         SET    load_error = identity_rec_(i).err_msg ,
                rowstate   = NVL(rowstate_,rowstate_)
         WHERE  company         = company_
         AND    load_id         = load_id_
         AND    record_no = identity_rec_(i).record_no;
      END IF;
   END LOOP;
END Update_Errors;


PROCEDURE Update_State (
   company_         IN VARCHAR2,
   load_id_         IN VARCHAR2,
   load_group_item_ IN VARCHAR2,
   rowstate_        IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET rowstate   = rowstate_
   WHERE  company         = company_
   AND    load_id         = load_id_
   AND    load_group_item = load_group_item_;
END Update_State;


PROCEDURE Check_Condition (
   result_         OUT VARCHAR2,
   user_id_prv_    OUT VARCHAR2,
   user_group_prv_ OUT VARCHAR2,
   user_id_        OUT VARCHAR2,
   user_group_     OUT VARCHAR2,
   company_        IN  VARCHAR2,
   load_id_        IN  VARCHAR2 )
IS
   record_       EXT_TRANSACTIONS_TAB%ROWTYPE;
   record_valid_ VARCHAR2(5);
BEGIN
   user_id_    := Fnd_Session_API.Get_Fnd_User;
   user_group_ := User_Group_Member_Finance_API.Get_Default_Group (company_,
                                                                   user_id_ );
   record_     := Get_Object_By_Keys___ ( company_ ,
                                    load_id_ ,
                                    1);
   user_id_prv_   := record_.user_id; 
   user_group_prv_:= record_.user_group;
   IF user_group_prv_ IS NULL THEN
      result_ :='TRUE';
   ELSIF user_id_ != user_id_prv_ THEN
      Validate_User_Data (record_valid_, 
                          company_ , 
                          user_id_ , 
                          user_group_prv_);
      IF record_valid_ = 'FALSE' THEN
         result_ := 'TRUE';
      END IF;
   ELSE
      result_ :='FALSE';
   END IF;
END Check_Condition;    


PROCEDURE Validate_User_Data (
   result_     OUT VARCHAR2,
   company_    IN  VARCHAR2,
   user_id_    IN  VARCHAR2,
   user_group_ IN  VARCHAR2 )
IS
BEGIN
   User_Group_Member_Finance_API.Exist (company_,
                                        user_group_ ,
                                        user_id_     );

   result_ := 'TRUE';
EXCEPTION
   WHEN OTHERS THEN
      result_ := 'FALSE';
END Validate_User_Data;   

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_New_User_Data (
   company_        IN VARCHAR2,
   load_id_        IN VARCHAR2,
   user_id_        IN VARCHAR2,
   user_group_     IN VARCHAR2,
   user_id_prv_    IN VARCHAR2,
   user_group_prv_ IN VARCHAR2 )
IS
   user_group_prv_temp_ EXT_TRANSACTIONS_TAB.user_group%TYPE;
   CURSOR get_records IS 
      SELECT record_no  
      FROM EXT_TRANSACTIONS_TAB
      WHERE company = company_
      AND load_id   = load_id_;
BEGIN
   user_group_prv_temp_ := user_group_prv_;
   IF user_group_prv_temp_ IS NULL THEN
      user_group_prv_temp_ := '@#$';
   END IF;
   IF user_id_ != user_id_prv_ OR user_group_ != user_group_prv_temp_ THEN
      -- update the header
      IF user_id_ != user_id_prv_ THEN
         UPDATE ext_load_info_tab
         SET   userid  = user_id_
         WHERE company = company_
         AND   load_id = load_id_;
      END IF;
      -- update child 
      IF user_id_ != user_id_prv_ AND user_group_ = user_group_prv_temp_ THEN
         FOR records IN get_records LOOP
            UPDATE EXT_TRANSACTIONS_TAB
            SET user_id    = user_id_ 
            WHERE company  = company_
            AND  load_id   = load_id_
            AND  record_no = records.record_no;
         END LOOP;
      ELSIF user_group_ != user_group_prv_temp_ AND user_id_ = user_id_prv_ THEN
         FOR records IN get_records LOOP
            UPDATE EXT_TRANSACTIONS_TAB
            SET user_group = user_group_
            WHERE company  = company_
            AND  load_id   = load_id_
            AND  record_no = records.record_no;
         END LOOP;
      ELSE
         FOR records IN get_records LOOP
            UPDATE EXT_TRANSACTIONS_TAB
            SET user_id    = user_id_, 
                user_group = user_group_
            WHERE company  = company_
            AND  load_id   = load_id_
            AND  record_no = records.record_no;
         END LOOP;
      END IF;
   END IF;
END Update_New_User_Data;


@UncheckedAccess
FUNCTION Get_Voucher_Date (
   company_          IN VARCHAR2,
   load_id_          IN VARCHAR2,
   transaction_date_ IN DATE ) RETURN DATE
IS
   load_date_           DATE;
   load_type_           VARCHAR2(20);
   ext_voucher_date_    VARCHAR2(1);
   CURSOR Get_Ext_Param IS
      SELECT ext_voucher_date
      FROM   Ext_Parameters_Tab
      WHERE  company   = company_
      AND    load_type = load_type_;
   CURSOR Get_Load_Date IS
      SELECT load_date
      FROM   Ext_Load_Info_Tab
      WHERE  company   = company_
      AND    load_id   = load_id_;
BEGIN
   load_type_  := Ext_Load_Info_API.Get_Load_Type(company_,load_id_);
   OPEN  Get_Ext_Param;
   FETCH Get_Ext_Param INTO ext_voucher_date_;
   CLOSE Get_Ext_Param;
   IF (ext_voucher_date_ = '2') THEN
      RETURN transaction_date_;
   END IF;
   OPEN  Get_Load_Date;
   FETCH Get_Load_Date INTO load_date_;
   CLOSE Get_Load_Date;
   RETURN load_date_;
END Get_Voucher_Date;

--This method is used in Aurena Month end process lobby navigations
FUNCTION Fetch_Voucher_Year_Period (
   company_          IN VARCHAR2,
   load_id_          IN VARCHAR2,
   transaction_date_ IN DATE,
   type_             IN VARCHAR2) RETURN VARCHAR2
IS
   voucher_date_   DATE := NULL;
BEGIN
   voucher_date_ := Get_Voucher_Date(company_, load_id_, transaction_date_);
   IF(type_ = 'YEAR') THEN
      RETURN TO_CHAR(Accounting_Period_API.Get_Accounting_Year(company_, voucher_date_));
   ELSE
      RETURN  Accounting_Period_API.Get_Year_Period_Str(company_, voucher_date_);
   END IF;
   RETURN NULL;
END Fetch_Voucher_Year_Period;

--This method is used in Aurena Month end process lobby navigations
FUNCTION Fetch_Valid_Values (
   company_      IN VARCHAR2,
   load_id_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2) RETURN VARCHAR2
IS     
   valid_load_info_      BOOLEAN := FALSE;
   valid_vou_type_info_  BOOLEAN := FALSE;
   temp_                 NUMBER;
   CURSOR get_ext_load_info IS
      SELECT 1
      FROM   ext_load_info
      WHERE  company = company_
      AND    load_id = load_id_
      AND    ext_load_state IN ('1', '3', '4', '5', '6');   
   CURSOR get_voucher_type_info IS
      SELECT 1
      FROM   voucher_type 
      WHERE  company = company_
      AND    voucher_type = voucher_type_
      AND    ledger_id IN ('00', '*');   
BEGIN   
   OPEN  get_ext_load_info;
   FETCH get_ext_load_info INTO temp_;
   IF (get_ext_load_info%NOTFOUND) THEN
      valid_load_info_  := TRUE;
   ELSE
      valid_load_info_ := FALSE;
   END IF;
   CLOSE get_ext_load_info;

   OPEN  get_voucher_type_info;
   FETCH get_voucher_type_info INTO temp_;
   IF (get_voucher_type_info%FOUND) THEN
      valid_vou_type_info_  := TRUE;
   ELSE
      valid_vou_type_info_ := FALSE;
   END IF;
   CLOSE get_voucher_type_info;

   IF(valid_load_info_ AND valid_vou_type_info_ ) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
   RETURN NULL;
END Fetch_Valid_Values;

PROCEDURE Update_Codestr (
   company_      IN VARCHAR2,
   load_id_      IN VARCHAR2,
   record_no_    IN NUMBER,
   codestr_rec_  IN Accounting_Codestr_API.CodestrRec)
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET account = codestr_rec_.code_a,
          code_b  = codestr_rec_.code_b,
          code_c  = codestr_rec_.code_c,
          code_d  = codestr_rec_.code_d,
          code_e  = codestr_rec_.code_e,
          code_f  = codestr_rec_.code_f,
          code_g  = codestr_rec_.code_g,
          code_h  = codestr_rec_.code_h,
          code_i  = codestr_rec_.code_i,
          code_j  = codestr_rec_.code_j,
          process_code = codestr_rec_.process_code
   WHERE company  = company_
   AND   load_id  = load_id_
   AND   record_no= record_no_; 
END Update_Codestr;


@UncheckedAccess
FUNCTION Get_Modify_Codestr_Cmpl (
   company_   IN VARCHAR2,
   load_id_   IN VARCHAR2,
   record_no_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ EXT_TRANSACTIONS_TAB.modify_codestr_cmpl%TYPE;
   CURSOR get_attr IS
      SELECT modify_codestr_cmpl
      FROM EXT_TRANSACTIONS_TAB
      WHERE company   = company_
      AND   load_id   = load_id_
      AND   record_no = record_no_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Modify_Codestr_Cmpl;


PROCEDURE Update_Modify_Codestr_Cmpl (
   company_             IN VARCHAR2,
   load_id_             IN VARCHAR2,
   record_no_           IN NUMBER,
   modify_codestr_cmpl_ IN VARCHAR2 )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET modify_codestr_cmpl = modify_codestr_cmpl_
   WHERE company   = company_
   AND   load_id   = load_id_
   AND   record_no = record_no_;
END Update_Modify_Codestr_Cmpl;


PROCEDURE Update_Tax_Calc_Info (
   company_                  IN VARCHAR2,
   load_id_                  IN VARCHAR2,
   record_no_                IN NUMBER,
   optional_code_            IN VARCHAR2,
   tax_direction_            IN VARCHAR2,
   currency_tax_amount_      IN NUMBER,
   tax_amount_               IN NUMBER,
   tax_base_amount_          IN NUMBER,
   currency_tax_base_amount_ IN NUMBER,
   third_curr_tax_amount_    IN NUMBER,
   third_curr_tax_base_amount_ IN NUMBER )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET optional_code            = optional_code_,
          tax_direction            = tax_direction_,
          currency_tax_amount      = currency_tax_amount_,
          tax_amount               = tax_amount_,
          tax_base_amount          = tax_base_amount_,
          currency_tax_base_amount = currency_tax_base_amount_,
          third_currency_tax_amount  = third_curr_tax_amount_,
          third_curr_tax_base_amount = third_curr_tax_base_amount_
   WHERE company   = company_
   AND   load_id   = load_id_
   AND   record_no = record_no_;
END Update_Tax_Calc_Info;


PROCEDURE Update_Tax_Calc_Info (
   transaction_rec_tmp_ ExtTransRec )
IS
BEGIN
   UPDATE EXT_TRANSACTIONS_TAB
      SET optional_code            = transaction_rec_tmp_.optional_code,
          tax_direction            = transaction_rec_tmp_.tax_direction,
          currency_tax_amount      = transaction_rec_tmp_.currency_tax_amount,
          tax_amount               = transaction_rec_tmp_.tax_amount,
          tax_base_amount          = transaction_rec_tmp_.tax_base_amount,
          currency_tax_base_amount = transaction_rec_tmp_.currency_tax_base_amount,
          amount                   = transaction_rec_tmp_.amount,
          currency_amount          = transaction_rec_tmp_.currency_amount,
          credit_amount            = transaction_rec_tmp_.credit_amount,
          debet_amount             = transaction_rec_tmp_.debet_amount,
          currency_debet_amount    = transaction_rec_tmp_.currency_debet_amount,
          currency_credit_amount   = transaction_rec_tmp_.currency_credit_amount
   WHERE company   = transaction_rec_tmp_.company
   AND   load_id   = transaction_rec_tmp_.load_id
   AND   record_no = transaction_rec_tmp_.record_no;
END Update_Tax_Calc_Info;


PROCEDURE Auto_Tax_Calculation_Prepare (
   transaction_rec_ IN OUT ExtTransRec )
IS
   load_info_rec_     Ext_Load_Info_API.Public_Rec;
   auto_tax_calc_     Ext_Parameters_Tab.auto_tax_calc%TYPE;
   def_amount_method_ company_finance_tab.def_amount_method%TYPE;
BEGIN
   def_amount_method_:= Company_Finance_API.Get_Def_Amount_Method_Db (transaction_rec_.company);
   load_info_rec_    := Ext_Load_Info_API.Get(transaction_rec_.company,
                                              transaction_rec_.load_id);
   transaction_rec_.load_date := load_info_rec_.load_date;
   IF load_info_rec_.load_type IS NULL THEN
      auto_tax_calc_ := Ext_Parameters_API.Get_Auto_Tax_Calc_Db(transaction_rec_.company,
                                                             transaction_rec_.voucher_type);
   ELSE
      auto_tax_calc_ := Ext_Parameters_API.Get_Auto_Tax_Calc_Db(transaction_rec_.company,
                                                             load_info_rec_.load_type);
   END IF;
   transaction_rec_.optional_code       := NULL;
   transaction_rec_.tax_direction       := NULL;
   transaction_rec_.tax_amount          := NULL;
   transaction_rec_.currency_tax_amount := NULL;
   transaction_rec_.third_currency_tax_amount := NULL;
   Auto_Tax_Calculation_Done(transaction_rec_ ,
                             auto_tax_calc_ ,
                             def_amount_method_);
END Auto_Tax_Calculation_Prepare;


PROCEDURE Auto_Tax_Calculation_Done (
   transaction_rec_   IN OUT ExtTransRec,
   auto_tax_calc_     IN     VARCHAR2,
   def_amount_method_ IN     VARCHAR2 )
IS
   rounding_                     NUMBER;
   currency_rounding_            NUMBER;
   tax_type_                     statutory_fee_tab.fee_type%TYPE;
   tax_rec_                      Statutory_Fee_API.Public_Rec;
   function_group_               VOUCHER_TYPE_DETAIL_TAB.function_group%TYPE;
   total_tax_amount_             NUMBER;
   total_currency_tax_amount_    NUMBER;
   currency_non_ded_tax_amount_  NUMBER;
   non_ded_tax_amount_           NUMBER;
   currency_tax_amount_          NUMBER;
   tax_amount_                   NUMBER;
   dummy_                        NUMBER;
   amount_changed_               VARCHAR2(5) := 'FALSE';
   check_deductible_             VARCHAR2(5):= 'FALSE';
BEGIN
   IF (auto_tax_calc_ = 'Y') THEN
      function_group_ := Voucher_Type_Detail_API.Get_Function_Group(transaction_rec_.company,
                                                                    transaction_rec_.voucher_type);
      IF (function_group_ IN ('M','K','Q')) THEN 
         check_deductible_ := 'TRUE';
      END IF;
      
      IF transaction_rec_.optional_code IS NULL THEN
         Tax_Handling_Util_API.Fetch_Default_Tax_Code_On_Acc(transaction_rec_.optional_code,
                                                             transaction_rec_.tax_direction,
                                                             tax_type_,
                                                             dummy_,
                                                             transaction_rec_.company,
                                                             transaction_rec_.codestring_rec.code_a,
                                                             transaction_rec_.transaction_date);
      END IF;
      IF (transaction_rec_.optional_code IS NOT NULL AND transaction_rec_.tax_amount IS NULL AND transaction_rec_.currency_tax_amount IS NULL) THEN
         tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(transaction_rec_.company, transaction_rec_.optional_code, transaction_rec_.transaction_date, 'TRUE', 'TRUE', 'FETCH_IF_VALID');
         IF ( function_group_ IN ('M', 'K','Q') AND tax_rec_.fee_type = Fee_Type_API.DB_TAX)THEN
            -- to avoid deductible tax calculations
            check_deductible_ := 'TRUE';
         ELSE
            check_deductible_ := 'FALSE';
         END IF;         
         
         IF (NVL(tax_rec_.fee_rate,0) != 0) THEN
            currency_rounding_ := Currency_Code_API.Get_Currency_Rounding(transaction_rec_.company,
                                                                          transaction_rec_.currency_code);
            rounding_          := Currency_Code_API.Get_Currency_Rounding(transaction_rec_.company,
                                                                 Currency_Code_API.Get_Currency_Code(transaction_rec_.company));
            
            IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
               Tax_Handling_Accrul_Util_API.Calculate_Tax_Amounts(total_currency_tax_amount_,
                                                                  currency_tax_amount_,
                                                                  currency_non_ded_tax_amount_,
                                                                  transaction_rec_.company,
                                                                  transaction_rec_.currency_code,
                                                                  transaction_rec_.optional_code,
                                                                  tax_rec_.fee_rate,
                                                                  'TRUE',
                                                                  transaction_rec_.currency_amount,
                                                                  def_amount_method_,
                                                                  currency_rounding_,
                                                                  NULL,
                                                                  transaction_rec_.transaction_date);
               Tax_Handling_Accrul_Util_API.Calculate_Tax_Amounts(total_tax_amount_,
                                                                  tax_amount_,
                                                                  non_ded_tax_amount_,
                                                                  transaction_rec_.company,
                                                                  transaction_rec_.currency_code,
                                                                  transaction_rec_.optional_code,
                                                                  tax_rec_.fee_rate,
                                                                  'TRUE',
                                                                  transaction_rec_.amount,
                                                                  def_amount_method_,
                                                                  rounding_,
                                                                  NULL,
                                                                  transaction_rec_.transaction_date);
               Tax_Handling_Accrul_Util_API.Calc_Para_Curr_Tax_Amount(transaction_rec_.third_currency_tax_amount,
                                                                      dummy_,
                                                                      dummy_,
                                                                      transaction_rec_.company,
                                                                      def_amount_method_,
                                                                      transaction_rec_.optional_code,
                                                                      tax_rec_.fee_rate,
                                                                      'TRUE',
                                                                      'FALSE',
                                                                      transaction_rec_.third_currency_amount,
                                                                      NULL,
                                                                      NULL,
                                                                      transaction_rec_.transaction_date);
               IF (def_amount_method_ = 'GROSS') THEN
                  IF (tax_rec_.deductible != 100 AND check_deductible_ = 'TRUE')  THEN
                     transaction_rec_.currency_tax_amount := currency_tax_amount_;
                     transaction_rec_.tax_amount          := tax_amount_;
                  ELSE
                     transaction_rec_.currency_tax_amount := total_currency_tax_amount_;
                     transaction_rec_.tax_amount          := total_tax_amount_;
                  END IF;                
               ELSE
                  IF (tax_rec_.deductible != 100 AND check_deductible_ = 'TRUE')  THEN
                     transaction_rec_.currency_tax_amount := currency_tax_amount_;
                     transaction_rec_.tax_amount          := tax_amount_;
                     transaction_rec_.currency_amount     := ROUND(transaction_rec_.currency_amount + currency_non_ded_tax_amount_, currency_rounding_);
                     transaction_rec_.amount              := ROUND(transaction_rec_.amount + non_ded_tax_amount_, rounding_);
                     amount_changed_ := 'TRUE';
                     IF (transaction_rec_.debet_amount IS NOT NULL ) THEN
                        transaction_rec_.debet_amount := transaction_rec_.amount;                           
                     ELSIF (transaction_rec_.credit_amount IS NOT NULL ) THEN
                        transaction_rec_.credit_amount := transaction_rec_.amount*-1;
                     END IF;                        
                     IF (transaction_rec_.currency_debet_amount IS NOT NULL ) THEN
                        transaction_rec_.currency_debet_amount := transaction_rec_.currency_amount;
                     ELSIF (transaction_rec_.currency_credit_amount IS NOT NULL ) THEN
                        transaction_rec_.currency_credit_amount := transaction_rec_.currency_amount*-1;
                     END IF;
                  ELSE
                     transaction_rec_.currency_tax_amount   := total_currency_tax_amount_;
                     transaction_rec_.tax_amount            := total_tax_amount_;
					   END IF;                  
               END IF;
            ELSE
               Tax_Handling_Accrul_Util_API.Calculate_Calc_Tax_Amounts(transaction_rec_.currency_tax_amount,
                                                                       transaction_rec_.tax_amount,
                                                                       transaction_rec_.third_currency_tax_amount,
                                                                       transaction_rec_.currency_amount,
                                                                       transaction_rec_.currency_amount,
                                                                       transaction_rec_.amount,
                                                                       transaction_rec_.amount,
                                                                       transaction_rec_.third_currency_amount,
                                                                       transaction_rec_.third_currency_amount,
                                                                       transaction_rec_.company,
                                                                       transaction_rec_.currency_code,
                                                                       transaction_rec_.optional_code,
                                                                       'FALSE',
                                                                       tax_rec_.fee_rate,
                                                                       transaction_rec_.transaction_date);               
            END IF;
         ELSIF (tax_rec_.fee_rate = 0) THEN
            transaction_rec_.currency_tax_amount := 0;
            transaction_rec_.tax_amount          := 0;
            transaction_rec_.third_currency_tax_amount := 0;
         END IF;
         IF transaction_rec_.amount IS NOT NULL THEN
            transaction_rec_.tax_base_amount  := transaction_rec_.amount;
         ELSE
            IF transaction_rec_.debet_amount IS NOT NULL THEN
               transaction_rec_.tax_base_amount := transaction_rec_.debet_amount;
            ELSIF transaction_rec_.credit_amount IS NOT NULL THEN
               transaction_rec_.tax_base_amount := -transaction_rec_.credit_amount;
            END IF;
         END IF;
         -- Considering only Net Amounts for Currency Tax Base Amounts
         IF transaction_rec_.currency_amount IS NOT NULL THEN
            transaction_rec_.currency_tax_base_amount  := transaction_rec_.currency_amount;
         ELSE
            IF transaction_rec_.currency_debet_amount IS NOT NULL THEN
               transaction_rec_.currency_tax_base_amount := transaction_rec_.currency_debet_amount;
            ELSIF transaction_rec_.credit_amount IS NOT NULL THEN
               transaction_rec_.currency_tax_base_amount :=  -transaction_rec_.currency_credit_amount;
            END IF;
         END IF;
         IF (amount_changed_ = 'TRUE') THEN
            transaction_rec_.tax_base_amount := transaction_rec_.tax_base_amount - non_ded_tax_amount_;
            transaction_rec_.currency_tax_base_amount := transaction_rec_.currency_tax_base_amount - currency_non_ded_tax_amount_;
         END IF;
         -- Considering only Net Amounts for Parallel Currency Tax Base Amounts
         IF transaction_rec_.third_currency_amount IS NOT NULL THEN
            transaction_rec_.third_curr_tax_base_amount  := transaction_rec_.third_currency_amount;
         ELSE
            IF transaction_rec_.third_currency_debit_amount IS NOT NULL THEN
               transaction_rec_.third_curr_tax_base_amount := transaction_rec_.third_currency_debit_amount;
            ELSIF transaction_rec_.third_currency_credit_amount IS NOT NULL THEN
               transaction_rec_.third_curr_tax_base_amount :=  -transaction_rec_.third_currency_credit_amount;
            END IF;
         END IF;
      END IF;
   END IF;
END Auto_Tax_Calculation_Done;


@UncheckedAccess
FUNCTION Check_Exist_Function_Group_Q (
   company_    IN  VARCHAR2,
   load_id_    IN  VARCHAR2 ) RETURN VARCHAR2
IS
   function_group_      voucher_type_detail_tab.function_group%TYPE;
   previous_vou_type_   voucher_type_detail_tab.voucher_type%TYPE ;
   functional_group_q_exist_   VARCHAR2(5);

   CURSOR voucher_type IS
      SELECT DISTINCT(voucher_type)
      FROM   ext_transactions_tab
      WHERE  company       = company_
      AND    load_id       = load_id_
      AND    optional_code IS NOT NULL 
      AND    tax_amount IS NOT NULL;
BEGIN
   FOR rec_ IN voucher_type LOOP
      IF (NVL(previous_vou_type_ , ' ') != rec_.voucher_type) THEN
         function_group_ := Voucher_Type_Detail_Api.Get_Function_Group( company_, rec_.voucher_type );
         previous_vou_type_ := rec_.voucher_type;
      END IF;
      IF (function_group_ = 'Q') THEN
         functional_group_q_exist_ := 'TRUE';
         EXIT;
      END IF;
      functional_group_q_exist_ := 'FALSE';
   END LOOP;
   RETURN functional_group_q_exist_;
END Check_Exist_Function_Group_Q;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_   IN VARCHAR2,
   load_id_   IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, load_id_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist;

FUNCTION Is_Proj_Activity_Id_Enable(
   company_ IN VARCHAR2,
   account_ IN VARCHAR2,
   code_b_  IN VARCHAR2,
   code_c_  IN VARCHAR2,
   code_d_  IN VARCHAR2,
   code_e_  IN VARCHAR2,
   code_f_  IN VARCHAR2,
   code_g_  IN VARCHAR2,
   code_h_  IN VARCHAR2,
   code_i_  IN VARCHAR2,
   code_j_  IN VARCHAR2) RETURN VARCHAR2
IS
   project_origin_   VARCHAR2(20);
   is_enable_        VARCHAR2(5);
   project_id_       VARCHAR2(20);
BEGIN
   $IF (Component_Genled_SYS.INSTALLED) $THEN
      project_id_:= Accounting_Codestr_API.Get_Value_For_Code_Part_Func(company_, account_, code_b_, code_c_, code_d_, code_e_, code_f_, code_g_, code_h_, code_i_, code_j_, 'PRACC');
      IF (project_id_ IS NOT NULL) THEN
         project_origin_:= Accounting_Project_API.Get_Project_Origin_Db(company_, project_id_);
         IF (project_origin_ = 'PROJECT') THEN
            is_enable_ := 'TRUE';
         ELSE 
            is_enable_ := 'FALSE';
         END IF;
      ELSE
         RETURN 'FALSE';
      END IF;         
   $ELSE
      is_enable_ := 'TRUE';
   $END
   RETURN is_enable_;   
END Is_Proj_Activity_Id_Enable;


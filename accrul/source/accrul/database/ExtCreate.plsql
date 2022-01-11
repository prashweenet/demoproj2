-----------------------------------------------------------------------------
--
--  Logical unit: ExtCreate
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970128  MaGu   Created
--  970414  MaGu   Corrected setting of voucher_group in New_Voucher proc.
--  970807  SLKO   Converted to Foundation 1.2.2d
--  970820  DavJ   Split Currencty_Amount to Currency_Debet_Amount & Currency_Credit_Amount
--                  And Column  Amount to Debet_Amount & Credit_Amount
--                  in Procedure Process_Voucher_Rows
--  971022  MiJo   Modified Optional_Code to 20.
--  010301  JeGu   Bug #20361 Changed Where-statements cursors for performance reasons
--  010405  JeGu   Bug #20361 changed from Get_Count to Check_Found
--  010427  JeGu   Bug #21600 Performance
--  010530  JeGu   Misc Performance and Quality
--  010904  JeGu   Bug #24125 Commit in flow and some other changes
--  020312  RAKO   Corrected Bug# 27384.
--  020603  Hecolk Bug 28982, Merged
--  020619  Uma    Corrected Bug# 30153. Handled errors that occurs during voucher creations.
--  020824  Hadilk Corrected bug 30853
--  021011  PPerse Merged External Files
--- 030801  prdilk SP4 Merge.
--  030822  LoKrLK Patch Merge (37672)
--  030827  LoKrLK Patch Merge (36207)
--  040323  Gepelk 2004 SP1
--  050315  AjPelk Bug 122679, Size of voucher_group_ in Create_Voucher has changed.
--  051118  WAPELK  Merged the Bug 52783. Correct the user group variable's width.
--  060126  Samwlk LCS Bug 54682, Merged.
--  060727  DHSELK Modified to_date() function to work with Persian Calander.
--  061025  GaDaLK LCS 59910 Merged.
--  072007  Kagalk LCS Merge 62180, Added new if condition to check optional_code is not null in Process_Voucher_Rows__
--  080421  Makrlk Bug 69890 Corrected.
--  080909  AjPelk Bug 71024 Corrected.
--  090521  AsHelk Bug 80225, Adding Transaction Statement Approved Annotation.
--  090716  AjPelk Bug 84194, Corrected.
--  090807  Nsillk Bug 84885, Corrected. Modified in method Process_Voucher_Rows__
--  110530  THPELK EASTONE-21700: LCS Merge (Bug 97213) Corrected.
--  111213  Clstlk SFI-784: LCS Merge (bug 99676),Corrected.
--  120627  Thpelk Bug 97225 Corrected in Process_Voucher_Rows__() and Create_Voucher().
--  120711  THPELK Bug 103653 Corrected in Process_Voucher_Rows__().
--  120821  Sacalk EDEL-1403, Added Columns to support Automation of Add investment in FA 
--  120824  Sacalk EDEL-1357, Modified in Process_Voucher_Rows__ 
--  121123  Thpelk Bug 106680 - Modified Conditional compilation to use single component package.
--  130823  Shedlk Bug 111220, Corrected END statements to match the corresponding procedure name
--  121123  Janblk DANU-122, Parallel currency implementation
--  131111  Lamalk PBFI-1999, Removed some unnecessary  comments in procedure 'Process_Voucher_Rows__'
--  140308  Nirylk PBFI-5614, Modified Process_Voucher_Rows__()
--  141202  Mawelk PRFI-3865. Modify Process_Voucher_Rows__)
--  150128  AjPelk PRFI-4489, Lcs merge Bug 120401, Added the new field CURRENCY_RATE_TYPE
--  150427  Chwtlk Bug 121638, Modified Process_Voucher_Rows__ to make auto_tax_vou_entry value TRUE for the Tax transaction
--  150601  Chwtlk Bug 121638, Modified Process_Voucher_Rows__.
--  160107  Maaylk STRFI-849, Bug 126290, Stopped taking the currency_rate and conv_factor from Currency_Rate_API. instead it will be calculated in voucher_util_pub_API.
--  160108  AjPelk STRFI-694, LCS merged 125052 , re-write both methods Delete_Extvouchers__
--  160525  Savmlk STRFI-1809, Lcs merge Bug 128663,Added new method Process_Voucher_Rows_By_Item__() and modified Process_Voucher_Rows__() and Create_Voucher() methods.
--  160718  Maaylk STRFI-2058, Bug 129671, Called Tax_Direction_API.Encode() to set the tax_direction
--  170102  Chwtlk STRFI-4392, Merged LCS Bug 133423, Modified Process_Voucher_Rows_By_Item__.
--  170317  Chwtlk STRFI-5391, Merged LCS Bug 134848, Modified Process_Voucher_Rows__.
--  170911  Savmlk STRFI-9766, Merged LCS Bug 137504, Modified Process_Voucher_Rows_By_Item__.
--  190226  Nudilk Bug 147060, Corrected.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE CharSmallTabType        IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
TYPE CharBigTabType          IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
PROCEDURE Calcualte_Rates___(
   voucher_row_rec_           IN OUT Voucher_Util_Pub_API.PublicRowRec,
   company_                   IN VARCHAR2,  
   voucher_date_              IN DATE,
   acc_currency_              IN VARCHAR2,
   third_currency_code_       IN VARCHAR2,
   calculate_rate_            IN BOOLEAN,
   calcualte_third_curr_rate_ IN BOOLEAN)
IS
BEGIN
   IF calculate_rate_ THEN 
      voucher_row_rec_.currency_rate := Currency_Amount_API.Calculate_Currency_Rate( company_, 
                                                                                     voucher_row_rec_.currency_code, 
                                                                                     voucher_row_rec_.amount, 
                                                                                     voucher_row_rec_.currency_amount,
                                                                                     acc_currency_);
   END IF;
   IF calcualte_third_curr_rate_ THEN
      voucher_row_rec_.parallel_curr_rate := Currency_Amount_API.Calculate_Parallel_Curr_Rate( company_, 
                                                                                               voucher_date_, 
                                                                                               voucher_row_rec_.amount, 
                                                                                               voucher_row_rec_.currency_amount, 
                                                                                               voucher_row_rec_.third_currency_amount, 
                                                                                               acc_currency_, 
                                                                                               voucher_row_rec_.currency_code,
                                                                                               third_currency_code_);
   END IF;
END Calcualte_Rates___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------




PROCEDURE Process_Voucher_Rows__ (
   identity_rec_        OUT   Ext_Transactions_API.identity_rec,
   company_             IN     VARCHAR2,
   load_id_             IN     VARCHAR2,
   voucher_type_        IN     VARCHAR2,
   accounting_year_     IN     NUMBER,
   voucher_no_          IN     NUMBER,
   voucher_id_          IN     VARCHAR2,
   transfer_id_         IN     VARCHAR2,
   correction_          IN     VARCHAR2,    
   group_by_item_       IN     VARCHAR2,
   group_by_value_      IN     VARCHAR2,
   base_currency_code_  IN     VARCHAR2,
   base_curr_rounding_  IN     NUMBER,      
   is_base_emu_         IN     VARCHAR2,    
   third_currency_code_ IN     VARCHAR2,
   third_curr_rounding_ IN     NUMBER,      
   is_third_emu_        IN     VARCHAR2,    
   trans_currency_code_ IN OUT VARCHAR2,    
   trans_curr_rounding_ IN OUT NUMBER,      
   tem_valcode_         IN     VARCHAR2,    
   fa_code_part_        IN     VARCHAR2,
   project_code_part_   IN     VARCHAR2,
   function_group_      IN     VARCHAR2 DEFAULT NULL)    
   
IS 
   ext_rec_                Ext_Voucher_Row_Tab%ROWTYPE;
   arr_index_                   NUMBER;
   record_no_     NUMBER;
   err_msg_      VARCHAR2(2000);
   
   CURSOR getrec IS
      SELECT *
      FROM   Ext_Voucher_Row_Tab
      WHERE  company         = company_
      AND    load_id         = load_id_
      AND    load_group_item = group_by_value_
      ORDER BY row_no;
   
BEGIN
   arr_index_      := 0;
   OPEN getrec;
   LOOP
      FETCH getrec into ext_rec_; 
      EXIT WHEN getrec%NOTFOUND;
      Process_Voucher_Rows_By_Item__(  record_no_,
                                       err_msg_,
                                       company_,
                                       load_id_ ,
                                       voucher_type_,
                                       accounting_year_,
                                       voucher_no_ ,
                                       voucher_id_,
                                       transfer_id_,
                                       correction_ ,    
                                       group_by_item_ ,
                                       group_by_value_,
                                       base_currency_code_,
                                       base_curr_rounding_,      
                                       is_base_emu_ ,    
                                       third_currency_code_,
                                       third_curr_rounding_ ,      
                                       is_third_emu_,    
                                       trans_currency_code_ ,    
                                       trans_curr_rounding_ ,      
                                       tem_valcode_,    
                                       fa_code_part_ ,
                                       project_code_part_,
                                       function_group_ ,
                                       ext_rec_ );

      IF err_msg_ IS NOT NULL THEN                                       
         identity_rec_(arr_index_).record_no            := record_no_;
         identity_rec_(arr_index_).err_msg             := err_msg_;         

         arr_index_ := arr_index_ + 1;
      END IF; 
   END LOOP;
   CLOSE getrec;
END Process_Voucher_Rows__; 

PROCEDURE Process_Voucher_Rows_By_Item__ (
   record_no_           OUT    NUMBER,
   err_msg_             OUT    VARCHAR2,
   company_             IN     VARCHAR2,
   load_id_             IN     VARCHAR2,
   voucher_type_        IN     VARCHAR2,
   accounting_year_     IN     NUMBER,
   voucher_no_          IN     NUMBER,
   voucher_id_          IN     VARCHAR2,
   transfer_id_         IN     VARCHAR2,
   correction_          IN     VARCHAR2,    
   group_by_item_       IN     VARCHAR2,
   group_by_value_      IN     VARCHAR2,
   base_currency_code_  IN     VARCHAR2,
   base_curr_rounding_  IN     NUMBER,      
   is_base_emu_         IN     VARCHAR2,    
   third_currency_code_ IN     VARCHAR2,
   third_curr_rounding_ IN     NUMBER,      
   is_third_emu_        IN     VARCHAR2,    
   trans_currency_code_ IN OUT VARCHAR2,    
   trans_curr_rounding_ IN OUT NUMBER,      
   tem_valcode_         IN     VARCHAR2,    
   fa_code_part_        IN     VARCHAR2,
   project_code_part_   IN     VARCHAR2,
   function_group_      IN     VARCHAR2 DEFAULT NULL,
   ext_rec_             IN     Ext_Voucher_Row_Tab%ROWTYPE)  
   
IS
   
   codestring_rec_               Accounting_Codestr_Api.CodestrRec;
   voucher_row_rec_              Voucher_Util_Pub_API.PublicRowRec;
   amount_                       NUMBER;
   curr_amount_                  NUMBER;
   third_curr_amt_               NUMBER;
   temp_row_                     NUMBER;
   load_id_prv_                  ext_parameters_tab.load_type%TYPE; 
   load_type_                    ext_parameters_tab.load_type%TYPE;
   correction_new2_              VARCHAR2(1);
   check_deductible_             VARCHAR2(5):= 'FALSE';
   tax_type_                     VARCHAR2(40);
   def_amount_method_            VARCHAR2(5) := Company_Finance_API.Get_Def_Amount_Method_Db (company_);
   third_curr_inverted_          VARCHAR2(5);
   old_parallel_curr_rate_type_  VARCHAR2(10);
   currency_type_                VARCHAR2(100);
   object_id_                    VARCHAR2(20);
   fictive_voucher_no_           NUMBER;
   voucher_no_tmp_               NUMBER;
   tax_percentage_               NUMBER;
   add_investment_attr_          VARCHAR2(3000);
   currency_tax_amount_          NUMBER;
   tax_amount_                   NUMBER;
   parallel_curr_tax_amount_     NUMBER;
   calculate_rate_               BOOLEAN := FALSE;
   calculate_third_curr_rate_    BOOLEAN := FALSE;
   tax_code_rec_                 Statutory_Fee_API.Public_Rec;
   ext_parameters_rec_           Ext_Parameters_API.Public_Rec;
BEGIN   
   record_no_ := ext_rec_.Record_No;
   voucher_row_rec_.reference_row_no := ext_rec_.reference_row_no;
   voucher_row_rec_.currency_rate := ext_rec_.Currency_Rate;
   
   codestring_rec_.code_a := ext_rec_.Account;
   codestring_rec_.code_b := ext_rec_.Code_b;
   codestring_rec_.code_c := ext_rec_.Code_c;
   codestring_rec_.code_d := ext_rec_.Code_d;
   codestring_rec_.code_e := ext_rec_.Code_e;
   codestring_rec_.code_f := ext_rec_.Code_f;
   codestring_rec_.code_g := ext_rec_.Code_g;
   codestring_rec_.code_h := ext_rec_.Code_h;
   codestring_rec_.code_i := ext_rec_.Code_i;
   codestring_rec_.code_j := ext_rec_.Code_j;
           
   voucher_row_rec_.codestring_rec               := codestring_rec_;
   amount_         := (NVL(ext_rec_.debet_amount,0) - NVL(ext_rec_.credit_amount,0));
   curr_amount_    := (NVL(ext_rec_.currency_debet_amount,0) - NVL(ext_rec_.currency_credit_amount,0));
      
   third_curr_amt_        := (NVL(ext_rec_.third_currency_debit_amount,0) - NVL(ext_rec_.third_currency_credit_amount,0));
   --voucher_row_rec_.third_currency_tax_amount    := third_currency_tax_amount_;
      
   temp_row_ := ext_rec_.row_no;
   IF (NVL(ext_rec_.tax_transaction,'FALSE') = 'FALSE') THEN
      IF (ACCOUNT_API.Is_Ledger_Account(company_,ext_rec_.Account) )THEN  
      
         IF (VOUCHER_TYPE_DETAIL_API.Get_Function_Group(company_,voucher_type_) != 'Q') THEN  
                       Error_SYS.Record_General(lu_name_,'VOUISLEDGER: Ledger Account :P1 is only permitted for Vouchers with Function Group Q:P2',
                                               ext_rec_.Account,LPAD(temp_row_,3,0));
         END IF;
      END IF;
   END IF;
         
   voucher_row_rec_.amount := abs(amount_);
   voucher_row_rec_.currency_amount := abs(curr_amount_);
   voucher_row_rec_.third_currency_amount := abs(third_curr_amt_);
         
   IF ( amount_ >= 0) THEN
      voucher_row_rec_.debit  := TRUE;
   ELSE
      voucher_row_rec_.debit  := FALSE;
   END IF;
   
   -- When currency amount is NULL of 0 below logic will decide whether its a debit or credit line, this logic will be executed only when parallel currency amounts are having values.
   IF ((ext_rec_.third_currency_credit_amount IS NOT NULL) OR (ext_rec_.third_currency_debit_amount IS NOT NULL)) THEN  
      IF ((voucher_row_rec_.debit IS NULL) OR (amount_ = 0))THEN
         IF ( NVL(amount_,0) = 0 AND third_curr_amt_ >= 0) THEN
            voucher_row_rec_.debit  := TRUE;
         ELSE
            voucher_row_rec_.debit  := FALSE;
         END IF;
      END IF;
   END IF;
         
   IF ext_rec_.trans_code = 'AP9' THEN
      IF  NVL(ext_rec_.third_currency_debit_amount,0)> 0 THEN 
         voucher_row_rec_.third_debit  := TRUE;
      ELSE
         voucher_row_rec_.third_debit  := FALSE;  
      END IF;
   END IF;      
            
   IF ( load_id_prv_ IS NULL OR load_id_prv_ != load_id_ ) THEN
      load_type_            := Ext_Load_Info_API.Get_Load_Type (company_, load_id_);
      ext_parameters_rec_   := Ext_Parameters_API.Get(company_, load_type_);
   END IF;
   load_id_prv_ := load_id_;

   IF ext_parameters_rec_.correction= 'TRUE' THEN
      correction_new2_:= ext_rec_.corrected;
   ELSE
      -- still the else part takes the value correction_ 
      correction_new2_:= correction_;
   END IF;
   IF (NVL(correction_new2_,'N') = 'N') THEN
      voucher_row_rec_.amount := abs(amount_);
      voucher_row_rec_.currency_amount := abs(curr_amount_);
      voucher_row_rec_.third_currency_amount := abs(third_curr_amt_);
      --IF (currency_code_ = third_currency_code_) THEN
      --   third_curr_amt_ := curr_amount_;
      --   voucher_row_rec_.third_currency_amount := abs(third_curr_amt_);
      --ELSE
      --   voucher_row_rec_.third_currency_amount := NULL;
       -- Note: If the transaction currency is different from the third currency then
      --END IF;
   ELSE
      voucher_row_rec_.debit  := NOT (voucher_row_rec_.debit );
      voucher_row_rec_.amount := -abs(amount_);
      voucher_row_rec_.currency_amount := -abs(curr_amount_);

      voucher_row_rec_.third_currency_amount := -abs(third_curr_amt_);
      --IF (currency_code_ = third_currency_code_) THEN
      --   third_curr_amt_ := curr_amount_;
      --   voucher_row_rec_.third_currency_amount := -abs(third_curr_amt_);
      --ELSE
      --   voucher_row_rec_.third_currency_amount := NULL;
      -- Note: If the transaction currency is different from the third currency then
      --END IF;
   END IF;
   voucher_row_rec_.currency_code                := ext_rec_.currency_code;
   voucher_row_rec_.quantity                     := ext_rec_.quantity;
   voucher_row_rec_.process_code                 := ext_rec_.process_code;
   voucher_row_rec_.deliv_type_id                := ext_rec_.deliv_type_id;
   voucher_row_rec_.optional_code                := ext_rec_.optional_code;
   voucher_row_rec_.project_activity_id          := ext_rec_.project_activity_id;
   voucher_row_rec_.text                         := ext_rec_.text;
   voucher_row_rec_.party_type                   := ext_rec_.party_type;
   voucher_row_rec_.party_type_id                := ext_rec_.party_type_id;
   voucher_row_rec_.reference_number             := ext_rec_.reference_number;
   voucher_row_rec_.reference_serie              := ext_rec_.reference_serie;
   voucher_row_rec_.trans_code                   := ext_rec_.trans_code;
   voucher_row_rec_.corrected                    := correction_new2_;
--Specification[10/7/98] : Validation Level In Check External Voucher
   voucher_row_rec_.ext_validate_codestr         := tem_valcode_;
   voucher_row_rec_.tax_direction := ext_rec_.tax_direction;
   voucher_row_rec_.tax_amount := ext_rec_.tax_amount;
   voucher_row_rec_.currency_tax_amount := ext_rec_.currency_tax_amount;
   voucher_row_rec_.tax_base_dom := ext_rec_.tax_base_amount;
   voucher_row_rec_.tax_base_curr := ext_rec_.currency_tax_base_amount; 
   voucher_row_rec_.third_currency_tax_amount  := ext_rec_.third_currency_tax_amount;
   voucher_row_rec_.third_curr_tax_base_amount := ext_rec_.third_curr_tax_base_amount;
   -- To make auto_tax_vou_entry TRUE only for the Tax transaction
   IF (ext_rec_.optional_code IS NOT NULL) AND (NVL(ext_rec_.tax_base_amount,0) !=0 AND NVL(ext_rec_.currency_tax_base_amount,0) !=0 OR NVL(ext_rec_.third_curr_tax_base_amount,0) !=0) THEN
      voucher_row_rec_.auto_tax_vou_entry := 'TRUE';
   ELSE
      voucher_row_rec_.auto_tax_vou_entry := 'EXT';
   END IF;
   -- Misc performance
   IF (trans_currency_code_ = 'XXX' OR
       trans_currency_code_ != ext_rec_.currency_code) THEN
      trans_curr_rounding_ := Currency_Code_API.Get_currency_rounding (company_,
                                                                       ext_rec_.currency_code);
      trans_currency_code_ := ext_rec_.currency_code;
   END IF;

   IF (function_group_ IN ('M', 'K')) THEN
     check_deductible_ := 'TRUE';
   END IF;
   
   IF (voucher_row_rec_.optional_code IS NOT NULL) THEN
      tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, voucher_row_rec_.optional_code, SYSDATE, 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
      tax_type_     := tax_code_rec_.fee_type;
   ELSE
      Tax_Handling_Util_API.Fetch_Default_Tax_Code_On_Acc(voucher_row_rec_.optional_code,
                                                          voucher_row_rec_.tax_direction,
                                                          tax_type_,
                                                          tax_percentage_,
                                                          company_,
                                                          voucher_row_rec_.codestring_rec.code_a,
                                                          NVL(ext_rec_.transaction_date, sysdate));
      voucher_row_rec_.tax_direction := Tax_Direction_API.Encode(voucher_row_rec_.tax_direction);
   END IF;
   
   IF (tax_type_ IS NOT NULL AND tax_type_ NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
      IF (def_amount_method_ = 'GROSS' AND
         NVL(voucher_row_rec_.tax_amount,0) != 0 ) THEN
         IF (ext_rec_.debet_amount != 0) THEN
            voucher_row_rec_.currency_amount  := ext_rec_.currency_debet_amount - voucher_row_rec_.currency_tax_amount;
            voucher_row_rec_.amount           := ext_rec_.debet_amount - voucher_row_rec_.tax_amount;
            voucher_row_rec_.third_currency_amount           := ext_rec_.third_currency_debit_amount - voucher_row_rec_.third_currency_tax_amount;
         ELSE
            voucher_row_rec_.currency_amount  := ext_rec_.currency_credit_amount + voucher_row_rec_.currency_tax_amount;
            voucher_row_rec_.amount           := ext_rec_.credit_amount + voucher_row_rec_.tax_amount;
            voucher_row_rec_.third_currency_amount  := ext_rec_.third_currency_credit_amount + voucher_row_rec_.third_currency_tax_amount;
         END IF;
      ELSIF (def_amount_method_ = 'GROSS') THEN
         IF voucher_row_rec_.trans_code = 'AP2' OR voucher_row_rec_.trans_code = 'AP1' THEN
            IF ext_rec_.debet_amount!=0 THEN
               voucher_row_rec_.tax_base_dom  := (voucher_row_rec_.tax_base_dom - ext_rec_.debet_amount);
               voucher_row_rec_.tax_base_curr := (voucher_row_rec_.tax_base_curr - ext_rec_.currency_debet_amount);
               voucher_row_rec_.third_curr_tax_base_amount := (voucher_row_rec_.third_curr_tax_base_amount - ext_rec_.third_currency_debit_amount);
            ELSE
               voucher_row_rec_.tax_base_dom  := voucher_row_rec_.tax_base_dom + ext_rec_.credit_amount;
               voucher_row_rec_.tax_base_curr := voucher_row_rec_.tax_base_curr + ext_rec_.currency_credit_amount;
               voucher_row_rec_.third_curr_tax_base_amount  := voucher_row_rec_.third_curr_tax_base_amount + ext_rec_.third_currency_credit_amount;
            END IF;
         END IF;
      END IF;
   END IF;
   
   IF voucher_row_rec_.third_currency_amount IS NULL THEN
      IF (ext_rec_.currency_code = third_currency_code_) THEN
         voucher_row_rec_.third_currency_amount := voucher_row_rec_.currency_amount;
      ELSE
         voucher_row_rec_.third_currency_amount := NULL;
         -- Note: If the transaction currency is different from the third currency then
      END IF;
   END IF;   

   voucher_row_rec_.currency_rate_type            := ext_rec_.currency_rate_type;
   voucher_row_rec_.parallel_curr_rate_type       := ext_rec_.parallel_curr_rate_type;

   IF ext_rec_.trans_code = 'AP9' AND voucher_row_rec_.third_currency_amount IS NOT NULL THEN
      Currency_Rate_API.Get_Parallel_Currency_Rate(voucher_row_rec_.parallel_curr_rate, 
                                                   voucher_row_rec_.parallel_curr_conv_factor,
                                                   third_curr_inverted_,
                                                   company_, 
                                                   voucher_row_rec_.currency_code, 
                                                   sysdate,
                                                   ext_rec_.parallel_curr_rate_type);         
   END IF;
   IF voucher_row_rec_.currency_rate IS NULL AND ext_rec_.transaction_date IS NOT NULL THEN 
      Currency_Rate_API.Get_Currency_Rate_Defaults(currency_type_,
                                                   voucher_row_rec_.conversion_factor,
                                                   voucher_row_rec_.currency_rate,
                                                   company_,
                                                   voucher_row_rec_.currency_code, 
                                                   ext_rec_.transaction_date);
   END IF;

   IF ((voucher_row_rec_.parallel_curr_rate IS NULL) OR (old_parallel_curr_rate_type_ != ext_rec_.parallel_curr_rate_type))THEN
      Currency_Rate_API.Get_Parallel_Currency_Rate(voucher_row_rec_.parallel_curr_rate, 
                                                   voucher_row_rec_.parallel_curr_conv_factor,
                                                   third_curr_inverted_,
                                                   company_, 
                                                   voucher_row_rec_.currency_code, 
                                                   ext_rec_.transaction_date,
                                                   ext_rec_.parallel_curr_rate_type);         
   END IF;
   -- Calculate rates from amount when calcualte_rate_param_ is used.
   IF NVL(ext_parameters_rec_.calculate_rate, 'FALSE') = 'TRUE' THEN
      IF voucher_row_rec_.amount IS NOT NULL AND voucher_row_rec_.amount IS NOT NULL THEN
         IF voucher_row_rec_.currency_code != base_currency_code_ THEN
            calculate_rate_ := TRUE;
         END IF;                 
         IF third_currency_code_ IS NOT NULL AND voucher_row_rec_.third_currency_amount IS NOT NULL THEN
            calculate_third_curr_rate_ := TRUE;
         END IF;
         IF calculate_rate_ OR calculate_third_curr_rate_ THEN 
            Calcualte_Rates___(voucher_row_rec_, 
                               company_, 
                               ext_rec_.transaction_date, 
                               base_currency_code_, 
                               third_currency_code_, 
                               calculate_rate_, 
                               calculate_third_curr_rate_);
         END IF; 
      END IF;
   END IF;
   
   old_parallel_curr_rate_type_ := ext_rec_.parallel_curr_rate_type;  
   Voucher_Util_Pub_API.Create_Voucher_Rows(transfer_id_,
                                            voucher_row_rec_,
                                            base_currency_code_,
                                            is_base_emu_,
                                            is_third_emu_);
   fictive_voucher_no_ := Voucher_Util_Pub_API.Get_Fictive_Voucher_No(transfer_id_);
   voucher_no_tmp_ := NVL(voucher_no_, fictive_voucher_no_);                                          
   IF voucher_row_rec_.trans_code IN ('AP1', 'AP2', 'AP3', 'AP4') THEN
      IF (ext_rec_.currency_credit_amount IS NOT NULL) THEN
         currency_tax_amount_      := ext_rec_.currency_credit_amount * -1;
      ELSE
         currency_tax_amount_      := ext_rec_.currency_debet_amount;
      END IF;
      IF (ext_rec_.credit_amount IS NOT NULL) THEN
         tax_amount_      := ext_rec_.credit_amount * -1;
      ELSE
         tax_amount_      := ext_rec_.debet_amount;
      END IF;
      IF (ext_rec_.third_currency_credit_amount IS NOT NULL) THEN
         parallel_curr_tax_amount_      := ext_rec_.third_currency_credit_amount * -1;
      ELSE
         parallel_curr_tax_amount_      := ext_rec_.third_currency_debit_amount;
      END IF;
      
      Tax_Handling_Accrul_Util_API.Create_Source_Tax_Item(ext_rec_.company,
                                                          Tax_Source_API.DB_MANUAL_VOUCHER,
                                                          TO_CHAR(accounting_year_),
                                                          voucher_type_,
                                                          TO_CHAR(voucher_no_tmp_),
                                                          TO_CHAR(ext_rec_.reference_row_no),
                                                          '*',
                                                          voucher_row_rec_.optional_code,
                                                          voucher_row_rec_.currency_code,
                                                          currency_tax_amount_,
                                                          ext_rec_.tax_percentage,
                                                          tax_amount_,
                                                          parallel_curr_tax_amount_,
                                                          voucher_row_rec_.tax_base_curr,
                                                          voucher_row_rec_.tax_base_dom,
                                                          voucher_row_rec_.third_curr_tax_base_amount,
                                                          ext_rec_.transaction_date);
   END IF;
   $IF Component_Fixass_SYS.INSTALLED $THEN
      IF (Acquisition_Account_Api.Is_Acquisition_Account(company_, codestring_rec_.code_a ) ) THEN 
         IF (fa_code_part_ = 'B') THEN 
            object_id_ := ext_rec_.code_b;
         ELSIF (fa_code_part_ = 'C') THEN 
            object_id_ := ext_rec_.code_c;
         ELSIF (fa_code_part_ = 'D') THEN 
            object_id_ := ext_rec_.code_d;
         ELSIF (fa_code_part_ = 'E') THEN 
            object_id_ := ext_rec_.code_e;
         ELSIF (fa_code_part_ = 'F') THEN 
            object_id_ := ext_rec_.code_f;
         ELSIF (fa_code_part_ = 'G') THEN 
            object_id_ := ext_rec_.code_g;
         ELSIF (fa_code_part_ = 'H') THEN 
            object_id_ := ext_rec_.code_h; 
         ELSIF (fa_code_part_ = 'I') THEN 
            object_id_ := ext_rec_.code_i;
         ELSIF (fa_code_part_ = 'J') THEN 
            object_id_ := ext_rec_.code_j;
         END IF ;

         IF ( object_id_ IS NOT NULL AND function_group_ NOT IN ('Q') )THEN 
            -- Creating add_investment_attr_ ---- 
            Client_SYS.Clear_Attr(add_investment_attr_);
            Client_Sys.Add_To_Attr('COMPANY', company_, add_investment_attr_ );
            Client_Sys.Add_To_Attr('SOURCE_REF', 'VOUCHER', add_investment_attr_ );
            Client_Sys.Add_To_Attr('KEYREF1', voucher_no_tmp_, add_investment_attr_ );
            Client_Sys.Add_To_Attr('KEYREF2', voucher_type_, add_investment_attr_ );
            Client_Sys.Add_To_Attr('KEYREF3', accounting_year_, add_investment_attr_ );
            Client_Sys.Add_To_Attr('KEYREF4', ext_rec_.row_no, add_investment_attr_ );
            Client_Sys.Add_To_Attr('KEYREF5', '*', add_investment_attr_ );
            Client_Sys.Add_To_Attr('OBJECT_ID', object_id_, add_investment_attr_ );
            Client_Sys.Add_To_Attr('EVENT_DATE', ext_rec_.event_date, add_investment_attr_ );
            Client_Sys.Add_To_Attr('RETROACTIVE_DATE', ext_rec_.retroactive_date, add_investment_attr_ );
            Client_Sys.Add_To_Attr('ACQUISITION_REASON', ext_rec_.transaction_reason, add_investment_attr_ );      
            Client_Sys.Add_To_Attr('ACQ_ACCOUNT', ext_rec_.Account, add_investment_attr_ );      
            Client_Sys.Add_To_Attr('AMOUNT', NVL( ext_rec_.debet_amount,ext_rec_.credit_amount), add_investment_attr_ );

            Add_Investment_Info_Api.New_Item(add_investment_attr_, 'DO');
         END IF;
      END IF ;
   $END
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
END Process_Voucher_Rows_By_Item__;


PROCEDURE Delete_Extvouchers__ (
   company_            IN VARCHAR2,
   load_id_            IN VARCHAR2,
   load_group_item_    IN VARCHAR2 )
IS
   dummy_              NUMBER;
   CURSOR check_head IS
      SELECT 1 
        FROM ext_voucher_tab
       WHERE company         = company_
         AND load_id         = load_id_
         AND load_group_item = load_group_item_;

   CURSOR check_rows IS
      SELECT 1 
        FROM ext_voucher_row_tab
       WHERE company         = company_
         AND load_id         = load_id_
         AND load_group_item = load_group_item_; 
BEGIN      
   OPEN check_head;
   FETCH check_head INTO dummy_;
   IF (check_head%FOUND) THEN
      DELETE
        FROM  ext_voucher_tab
       WHERE  company         = company_
         AND  load_id         = load_id_
         AND  load_group_item = load_group_item_;
   END IF;
   CLOSE check_head;

   OPEN check_rows;
   FETCH check_rows INTO dummy_;
   IF (check_rows%FOUND) THEN
      DELETE
        FROM  ext_voucher_row_tab
       WHERE  company         = company_
         AND  load_id         = load_id_
         AND  load_group_item = load_group_item_;
   END IF;
   CLOSE check_rows;
END Delete_Extvouchers__;

PROCEDURE Delete_Extvouchers__ (
   company_            IN VARCHAR2,
   load_id_            IN VARCHAR2 )
IS
   dummy_              NUMBER;
   CURSOR check_head IS
      SELECT 1 
       FROM  ext_voucher_tab
       WHERE company         = company_
         AND load_id         = load_id_;

   CURSOR check_rows IS
      SELECT 1 
       FROM  ext_voucher_row_tab
       WHERE company         = company_
         AND load_id         = load_id_;
BEGIN
   OPEN check_head;
   FETCH check_head INTO dummy_;
   IF (check_head%FOUND) THEN
      DELETE
      FROM   Ext_Voucher_Tab
      WHERE  company         = company_
      AND    load_id         = load_id_;
   END IF;
   CLOSE check_head;
   
   OPEN check_rows;
   FETCH check_rows INTO dummy_;
   IF (check_rows%FOUND) THEN
      DELETE
      FROM   Ext_Voucher_Row_Tab
      WHERE  company         = company_
      AND    load_id         = load_id_;
   END IF;
   CLOSE check_rows;
END Delete_Extvouchers__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Voucher (
   info_    OUT VARCHAR2,
   company_ IN  VARCHAR2,
   load_id_ IN  VARCHAR2 )
IS
   
   err_msg_              VARCHAR2(2000);
   obj_conn_err_msg_     VARCHAR2(2000);
   translate_            VARCHAR2(2000);
   transfer_id_          VARCHAR2(200);
   reference_number_     VARCHAR2(50);
   user_                 VARCHAR2(30);
   voucher_id_           VARCHAR2(30);
   load_group_item_      VARCHAR2(30);
   user_name_            VARCHAR2(30);
   group_by_value_       VARCHAR2(30);
   load_type_            VARCHAR2(20);   
   tem_valcode_          VARCHAR2(15);
   ledger_id_            VARCHAR2(10);
   voucher_group_        VARCHAR2(10); 
   rowstate_             VARCHAR2(10) := 'Updated';   
   vou_type_all_ledger_  VARCHAR2(5);
   param_correction_     VARCHAR2(5);
   is_base_emu_          VARCHAR2(5);
   is_third_emu_         VARCHAR2(5);
   allow_partial_create_ VARCHAR2(5);
   ok_to_create_         VARCHAR2(5);
   voucher_ok_           VARCHAR2(5);
   voucher_type_         VARCHAR2(3);
   third_currency_code_  VARCHAR2(3);
   trans_currency_code_  VARCHAR2(3) := 'XXX';   
   voucher_type_old_     VARCHAR2(3) := 'XXX';
   ext_vouch_extern_     VARCHAR2(1);
   automatic_            VARCHAR2(1);
   ext_group_by_item_    VARCHAR2(1);
   project_code_part_    VARCHAR2(1);
   fa_code_part_         VARCHAR2(1);
   ext_load_state_       VARCHAR2(1);
   correction_           VARCHAR2(1);       -- to support old version
   
   acc_year_             NUMBER;
   acc_period_           NUMBER;
   voucher_no_           NUMBER;
   actual_voucher_no_    NUMBER;
   fictive_voucher_no_   NUMBER;
   accounting_year_      NUMBER;
   accounting_period_    NUMBER;
   dummy_                NUMBER;
   base_curr_rounding_   NUMBER;
   third_curr_rounding_  NUMBER;
   trans_curr_rounding_  NUMBER;
   err_prj_actv_id_      NUMBER;
   found_loaded_         NUMBER := 0;
   found_checked_        NUMBER := 0;
   found_updated_        NUMBER := 0;
   r_i_                  NUMBER := 0;
   r_i_max_              NUMBER := 0;
   
   
   transaction_date_     DATE;
   voucher_date_         DATE;
   voucher_date_old_     DATE := Database_SYS.last_calendar_date_;
   
   
   user_group_           user_group_member_finance_tab.user_group%type;
   user_group_old_       user_group_member_finance_tab.user_group%type := 'XXX';
   user_group_def_       user_group_member_finance_tab.user_group%type;
   function_group_       voucher_type_detail_tab.function_group%TYPE;
   
   key_rec_              Voucher_Util_Pub_API.PublicKeyRec;
   
   rowid_tab_            Ext_Create_API.CharSmallTabType;
   rowstate_tab_         Ext_Create_API.CharSmallTabType;
   load_error_tab_       Ext_Create_API.CharBigTabType;
   load_group_tab_       Ext_Create_API.CharSmallTabType;   
   identity_rec_         Ext_Transactions_API.identity_rec;
   voucher_type_rec_     Voucher_Type_API.Public_Rec;
   company_finance_rec_  Company_Finance_Api.Public_Rec;
   
   checked_not_exist_    EXCEPTION;
   not_all_checked_      EXCEPTION;
   user_group_not_exist_ EXCEPTION;
   obj_conn_error_       EXCEPTION;

   CURSOR GetLoadInfo IS
      SELECT voucher_type,
             load_type
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
   CURSOR GetExtParam IS
      SELECT ext_group_item,
             ext_voucher_no_alloc,
             validate_code_string,
             correction
      FROM   Ext_Parameters_Tab
      WHERE  company   = company_
      AND    load_type = load_type_;
   CURSOR getrecgrpitm IS
      SELECT accounting_year,
             voucher_no,
             load_group_item,
             transaction_date,
             reference_number,
             voucher_type,
             voucher_date,
             user_group,
             accounting_period,
             userid
      FROM   Ext_Voucher_Tab
      WHERE  company = company_
      AND    load_id = load_id_
      ORDER BY load_group_item;

   CURSOR getrollrec IS
      SELECT ROWID,
             rowstate,
             load_error,
             load_group_item
      FROM   Ext_Transactions_Tab
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    rowstate = 'Loaded';
BEGIN
-- Misc Performance
   IF (Company_API.Get_Template_Company (company_) = 'TRUE') THEN
      Error_SYS.Appl_General(lu_name_, 'TEMPLATECOMP: Company :P1 is a Template Company and cannot create vouchers', company_);
   END IF;
   user_name_           := User_Finance_API.User_Id;
   user_group_def_      := User_Group_Member_Finance_Api.Get_Default_Group (company_,
                                                                            user_name_);

   company_finance_rec_ := Company_Finance_Api.Get(company_);
   base_curr_rounding_  := Currency_Code_API.Get_currency_rounding (company_,
                                                                    company_finance_rec_.currency_code);
   project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function (company_,
                                                                          'PRACC');
   fa_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function (company_,
                                                                     'FAACC');
   OPEN  GetLoadInfo;
   FETCH GetLoadInfo INTO voucher_type_,
                          load_type_;
   IF (GetLoadInfo%NOTFOUND) THEN
      Error_SYS.Record_General ( lu_name_, 'EXTLOADNOTEXIST: External load id :P1 does not exist', load_id_ );
   END IF;
   CLOSE GetLoadInfo;
   OPEN  GetExtParam;
   FETCH GetExtParam INTO ext_group_by_item_,
                          ext_vouch_extern_,
                          tem_valcode_,
                          param_correction_;
   IF (GetExtParam%NOTFOUND) THEN
      Error_SYS.Record_General ( lu_name_, 'EXTPARNOTEXIST: External interface parameters does not exist for company :P1, load type :P2', company_, load_type_ );
   END IF;
   CLOSE GetExtParam;

   allow_partial_create_ := Ext_Parameters_API.Get_Allow_Partial_Create ( company_,
                                                                          load_type_ );
   IF (NVL(allow_partial_create_,'FALSE') = 'TRUE') THEN
      Ext_Transactions_API.Check_Found ( dummy_,
                                         company_,
                                         load_id_,
                                         'Checked' );
      IF (dummy_ != 0) THEN
         ok_to_create_ := 'TRUE';
      ELSE
         ok_to_create_ := 'FALSE';
         RAISE checked_not_exist_;
      END IF;
   ELSE
      Ext_Transactions_API.Check_Other_Found ( dummy_,
                                               company_,
                                               load_id_,
                                               'Checked' );
      IF (dummy_ = 0) THEN
         ok_to_create_ := 'TRUE';
      ELSE
         ok_to_create_ := 'FALSE';
         RAISE not_all_checked_;
      END IF;
   END IF;
   -- get the voucher type from the ext_voucher_tab in order to get exact voucher type
   tem_valcode_ := Validate_Code_String_API.Encode (tem_valcode_);

-- group transactions by grouping criteria
   @ApproveTransactionStatement(2009-05-25,ashelk)
   SAVEPOINT Create_Start;
   OPEN getrecgrpitm;
   LOOP
      FETCH getrecgrpitm
         INTO acc_year_,
              voucher_no_,
              load_group_item_,
              transaction_date_,
              reference_number_,
              voucher_type_,
              voucher_date_,
              user_group_,
              acc_period_,
              user_;
      EXIT WHEN getrecgrpitm%NOTFOUND;
      group_by_value_ := load_group_item_;

      IF (ext_vouch_extern_ = '2') THEN  -- set voucher no., when created
         actual_voucher_no_ := NULL;
      ELSE
         actual_voucher_no_ := voucher_no_;
      END IF;

-- Misc performance (some gets moved to here and just performed when new user_group)
      IF (user_group_ IS NULL) THEN
         user_group_ := user_group_def_;
      END IF;
      IF ((user_group_old_ = 'XXX') OR
          (user_group_old_ != user_group_)) THEN
         IF (User_Group_Member_Finance_API.Is_User_Member_Of_Group( company_,
                                                                    user_name_,
                                                                    user_group_) = 'TRUE') THEN
            user_group_old_ := user_group_;
         ELSE
            RAISE user_group_not_exist_;
         END IF;
      END IF;

      voucher_id_ := NULL;
      transfer_id_ := nvl(transfer_id_, '0' );  -- to be verified
-- Misc performance (some gets moved to here and just performed when new voucher_date)
      IF ((voucher_date_old_ = Database_SYS.last_calendar_date_) OR
          (voucher_date_old_ != voucher_date_)) THEN
         -- Bug Id 122608 Begin
         ledger_id_ := voucher_type_API.Get_Ledger_Id(company_,voucher_type_);
         IF (ledger_id_='00' OR ledger_id_='**'  ) THEN
            User_Group_Period_Api.Get_And_Validate_Period( accounting_year_,
                                                        accounting_period_,
                                                        company_,
                                                        user_group_,
                                                        voucher_date_ );
         ELSE
            User_Group_Period_Api.Get_And_Validate_Period( accounting_year_,
                                                        accounting_period_,
                                                        company_,
                                                        user_group_,
                                                        voucher_date_,
                                                        ledger_id_);
         END IF;
      -- -- Bug Id 122608 End   
         is_base_emu_      := Currency_Code_Api.Get_Valid_Emu (company_,
                                                               company_finance_rec_.currency_code,
                                                               voucher_date_);
         third_currency_code_ := company_finance_rec_.parallel_acc_currency;
         IF (third_currency_code_ IS NOT NULL) THEN
            IF (third_currency_code_ = company_finance_rec_.currency_code) THEN
               third_curr_rounding_ := base_curr_rounding_;
            ELSE
               third_curr_rounding_ := Currency_Code_API.Get_currency_rounding (company_,
                                                                                third_currency_code_);
            END IF;
            is_third_emu_           := Currency_Code_Api.Get_Valid_Emu (company_,
                                                                        third_currency_code_,
                                                                        voucher_date_);
         ELSE
            is_third_emu_           := 'FALSE';
         END IF;
         voucher_date_old_ := voucher_date_;
      END IF;
-- Misc performance (some gets moved to here and just performed when new voucher_type)
      IF ((voucher_type_old_ = 'XXX') OR
          (voucher_type_old_ != voucher_type_)) THEN
         Voucher_Type_API.Exist (company_,
                                 voucher_type_);
         
         voucher_group_       := Voucher_Type_API.Get_Voucher_Group (company_,
                                                                     voucher_type_);
         voucher_type_rec_    := Voucher_Type_API.Get(company_, voucher_type_);                                                            
         ledger_id_           := voucher_type_rec_.ledger_id;
         automatic_           := NVL(voucher_type_rec_.automatic_allot, 'N');
         Voucher_Type_User_Group_API.Validate_Voucher_Type (company_,
                                                            voucher_type_,
                                                            voucher_group_,
                                                            accounting_year_,
                                                            user_group_);
         vou_type_all_ledger_ := Voucher_Type_API.Is_Vou_Type_All_Ledger (company_,
                                                                          voucher_type_);
         voucher_type_old_    := voucher_type_;
      END IF;

      IF (NVL(param_correction_,'N')='TRUE') THEN
         correction_ := 'Y';
      ELSE
         correction_ := 'N';
      END IF;
      
      @ApproveTransactionStatement(2009-05-25,ashelk)
      SAVEPOINT Ext_Create_Voucher;

      fictive_voucher_no_  :=  actual_voucher_no_;
      function_group_      :=  Voucher_Type_Detail_API.Get_Function_Group(company_, 
                                                                          voucher_type_);
      IF (function_group_ = 'M' OR function_group_ = 'K' OR function_group_ = 'Q') THEN
         IF ('ApproveOnly' = Authorize_Level_API.Encode(Voucher_Type_User_Group_API.Get_Authorize_Level(company_,
                                                                                                        accounting_year_,
                                                                                                        user_group_,
                                                                                                        voucher_type_))) THEN
            Error_SYS.Record_General( lu_name_ ,'APPROVEONLY: Users included in a user group with Approve Only authorization level are not allowed to enter or modify vouchers.');
         END IF;
      END IF;

      Voucher_API.New_Ext_Voucher ( voucher_type_,
                                    fictive_voucher_no_,
                                    transfer_id_,
                                    accounting_year_,
                                    accounting_period_,
                                    company_,
                                    --transfer_id_,
                                    voucher_date_,
                                    voucher_group_,
                                    user_group_,
                                    correction_,
                                    automatic_,
                                    ledger_id_,
                                    user_name_,
                                    vou_type_all_ledger_ );
      voucher_ok_ := 'TRUE';
      err_msg_ := NULL;
      Process_Voucher_Rows__ ( identity_rec_,  
                               company_,
                               load_id_,
                               voucher_type_,
                               acc_year_,
                               fictive_voucher_no_,
                               voucher_id_,
                               transfer_id_,
                               correction_,            -- to support old version
                               ext_group_by_item_,
                               group_by_value_,
                               company_finance_rec_.currency_code,    
                               base_curr_rounding_,    --
                               is_base_emu_,           --
                               third_currency_code_,
                               third_curr_rounding_,   -- Misc perf
                               is_third_emu_,          --
                               trans_currency_code_,   --
                               trans_curr_rounding_,   --
                               tem_valcode_,           --
                               fa_code_part_,          
                               project_code_part_,
                               function_group_ );   --
      IF (identity_rec_.count > 0) THEN
         voucher_ok_ := 'FALSE';
         info_ := Client_SYS.Get_All_Info;
         @ApproveTransactionStatement(2009-05-25,ashelk)
         ROLLBACK TO Ext_Create_Voucher;
         Ext_Transactions_API.Update_Errors ( company_,
                                              load_id_,
                                              load_group_item_,
                                              identity_rec_,
                                              'Loaded' ); 
         Delete_ExtVouchers__(company_, load_id_, load_group_item_);
      END IF;
      IF (voucher_ok_ = 'TRUE') THEN
         Voucher_Util_Pub_API.Complete_Voucher (key_rec_ ,
                                                transfer_id_ );
                                                
         obj_conn_err_msg_ := NULL;
         Voucher_Util_Pub_API.Create_Object_Connections(obj_conn_err_msg_          ,
                                                        err_prj_actv_id_           ,
                                                        key_rec_.company           ,
                                                        key_rec_.voucher_type      ,
                                                        key_rec_.accounting_year   ,
                                                        key_rec_.voucher_no         );
         IF ( obj_conn_err_msg_ IS NOT NULL ) THEN
            err_msg_ := obj_conn_err_msg_;
            RAISE obj_conn_error_;
         END IF;
      
         Ext_Transactions_API.Update_Transaction ( company_,
                                                   load_id_,
                                                   group_by_value_,
                                                   key_rec_.voucher_no,
                                                   voucher_date_,
                                                   acc_year_,
                                                   rowstate_ );
         Delete_ExtVouchers__ ( company_,    -- JeGu Misc Performance
                                load_id_,
                                group_by_value_ );
         
         -- NOTE: 
         -- commit should be done only when allow_partial_create_ is true. otherwise cannot rollback the transaction.        
         IF allow_partial_create_ = 'TRUE' THEN
            -- This commit should be here.
            -- This is to release the lock on voucher number series after each voucher
            -- is created.
            @ApproveTransactionStatement(2009-05-25,ashelk)
            COMMIT;
         END IF;
      END IF;


   END LOOP;

   CLOSE getrecgrpitm;

   Ext_Transactions_API.Update_Transaction ( company_,
                                             load_id_ );
   Delete_ExtVouchers__ ( company_,   -- JeGu Misc Performance
                          load_id_ );

   Ext_Transactions_API.Check_Found ( found_loaded_,
                                      company_,
                                      load_id_,
                                      'Loaded' );
   Ext_Transactions_API.Check_Found ( found_checked_,
                                      company_,
                                      load_id_,
                                      'Checked' );
   Ext_Transactions_API.Check_Found ( found_updated_,
                                      company_,
                                      load_id_,
                                      'Updated' );
   IF (allow_partial_create_ = 'FALSE' AND
       found_updated_ = 1 AND
       (found_checked_ = 1 OR found_loaded_ = 1)) THEN
      err_msg_ := 'PARTNOTTALL: It is not allowed to partly update Load ID :P1 ';
      translate_  := Language_SYS.Translate_Constant(lu_name_,'PARTNOTTALL: It is not allowed to partly update Load ID :P1 ');
      IF (found_updated_ = 1 ) THEN
         ext_load_state_ := '4';
      ELSE
         ext_load_state_ := '1';
      END IF;
      FOR roll_rec_ IN getrollrec LOOP
         r_i_                   := r_i_ + 1;
         rowid_tab_ (r_i_)      := roll_rec_.ROWID;
         load_error_tab_ (r_i_) := roll_rec_.load_error;
         rowstate_tab_   (r_i_) := roll_rec_.rowstate;
         load_group_tab_ (r_i_) := roll_rec_.load_group_item;
      END LOOP;
      r_i_max_                 := r_i_;
      r_i_                     := 0;
      @ApproveTransactionStatement(2009-05-25,ashelk)
      ROLLBACK TO Create_Start;
      LOOP
         r_i_                  := r_i_ + 1;
         IF (r_i_ > r_i_max_) THEN
            EXIT;
         END IF;
         Ext_Transactions_API.Update_Error ( rowid_tab_ (r_i_),
                                             load_error_tab_ (r_i_),
                                             rowstate_tab_   (r_i_) );
         IF (rowstate_tab_   (r_i_) != 'Checked') THEN
            Delete_ExtVouchers__(company_, load_id_, load_group_tab_ (r_i_));
         END IF;
      END LOOP;
   ELSE
      ext_load_state_ := '1';
      IF (found_updated_ = 1 AND
          found_checked_ = 0 AND
          found_loaded_  = 0 ) THEN
         ext_load_state_ := '5';
         err_msg_ := 'ALLCREATE: Load ID :P1 is updated to hold table';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'ALLCREATE: Load ID :P1 is updated to hold table');
      END IF;
      IF (found_updated_ = 1 AND
          found_checked_ = 1 AND
          found_loaded_  = 0 ) THEN
         ext_load_state_ := '6';
         err_msg_ := 'PARTCREATE: Load ID :P1 is partly updated to hold table';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'PARTCREATE: Load ID :P1 is partly updated to hold table');
      END IF;
      IF (found_updated_ = 1 AND
          found_checked_ = 0 AND
          found_loaded_  = 1 ) THEN
         ext_load_state_ := '6';
         err_msg_ := 'PARTCREATE: Load ID :P1 is partly updated to hold table';
      END IF;
      IF (found_updated_ = 0 AND
          found_checked_ = 1 AND
          found_loaded_  = 1 ) THEN
         ext_load_state_ := '4';
         err_msg_ := 'NOCREATE: Load ID :P1 has not been updated to hold table';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'NOCREATE: Load ID :P1 has not been updated to hold table');
      END IF;
      IF (found_updated_ = 0 AND
          found_checked_ = 0 AND
          found_loaded_  = 1 ) THEN
         ext_load_state_ := '1';
         err_msg_ := 'NOCREATE: Load ID :P1 has not been updated to hold table';
      END IF;
   END IF;

   Ext_Load_Info_API.Update_Ext_Load_State ( company_,
                                             load_id_,
                                             ext_load_state_ );
   --err_msg_ := 'NOERRINCREATE: Load id :P1 is updated to hold table';
   Client_SYS.Clear_Info;
   Client_SYS.Add_Info (lu_name_, err_msg_, load_id_);
   info_ := Client_SYS.Get_All_Info;
   Trace_SYS.Message ('Create_Voucher info_ : '||info_);
EXCEPTION
   WHEN not_all_checked_ THEN
      info_ := Language_SYS.Translate_Constant(lu_name_,'NOTALLCHKD: Vouchers cannot be created in company :P1. Load with identity :P2 contains transactions that are not checked', NULL, company_, load_id_);
      err_msg_ := info_;
      Client_SYS.Clear_Info;
      Client_SYS.Add_Info(lu_name_, err_msg_, load_id_);
      info_ := Client_SYS.Get_All_Info;
   WHEN checked_not_exist_ THEN
      info_ := Language_SYS.Translate_Constant(lu_name_,'CHKNOTEXIST: There are no checked vouchers in Load ID :P1', NULL, load_id_);
      err_msg_ := info_;
      Client_SYS.Clear_Info;
      Client_SYS.Add_Info(lu_name_, err_msg_, load_id_);
      info_ := Client_SYS.Get_All_Info;
   WHEN user_group_not_exist_ THEN
      Error_SYS.Record_General(lu_name_, 'NOUSERCON: The user :P1 is not connected to user group :P2 .', user_name_, user_group_);
   WHEN obj_conn_error_ THEN
      External_File_Utility_API.Error_Text_Only(err_msg_);
      Client_SYS.Add_Info(lu_name_, 'ERROINCREAT: Error(s) occurred when creating voucher(s). Load ID :P1 is rolled back to staus Loaded. ', load_id_);
      info_ := Client_SYS.Get_All_Info;
      @ApproveTransactionStatement(2012-08-29,umdolk)
      ROLLBACK TO Ext_Create_Voucher;
      Ext_Transactions_API.Update_Project_Error(company_,
                                                load_id_,
                                                err_prj_actv_id_,
                                                err_msg_ );
      Ext_Transactions_API.Update_Transaction ( company_,
                                                load_id_,
                                                'Checked',
                                                'Loaded' );
      Ext_Load_Info_API.Update_Ext_Load_State ( company_,
                                                load_id_,
                                                '4' );
      Delete_ExtVouchers__(company_, load_id_);
   WHEN OTHERS THEN
      err_msg_ := SQLERRM;
      External_File_Utility_API.Error_Text_Only(err_msg_);
      Client_SYS.Add_Info(lu_name_, 'ERROINCREAT: Error(s) occurred when creating voucher(s). Load ID :P1 is rolled back to staus Loaded. ', load_id_);
      info_ := Client_SYS.Get_All_Info;
      @ApproveTransactionStatement(2009-05-25,ashelk)
      ROLLBACK TO Ext_Create_Voucher;
      Ext_Transactions_API.Update_Load_Error ( company_,
                                               load_id_,
                                               load_group_item_,
                                               NULL,
                                               err_msg_ );
      -- If an error occurs when creating vouchers the status is rooled back to 'Loaded'
      Ext_Transactions_API.Update_Transaction ( company_,
                                                load_id_,
                                                'Checked',
                                                'Loaded' );
      Ext_Load_Info_API.Update_Ext_Load_State ( company_,
                                                load_id_,
                                                '4' );

      Delete_ExtVouchers__(company_, load_id_);

END Create_Voucher;




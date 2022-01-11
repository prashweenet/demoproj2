-----------------------------------------------------------------------------
--
--  Logical unit: TaxHandlingAccrulUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  161011  Hiralk  Created for Homerun project
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- IMPLEMENTATION METHODS FOR CALCULATIONS ----------------

-- This method can be used to get tax curr amounts and tax dom amounts 
-- depending by passing the curr amount or dom amount as the tax_base_amount_
PROCEDURE Calculate_Tax_Amount___ (
   total_tax_amount_      OUT NUMBER,
   tax_amount_            OUT NUMBER,
   non_ded_tax_amount_    OUT NUMBER,
   line_amount_rec_       IN  tax_handling_util_api.line_amount_rec,
   trans_curr_rec_        IN  tax_handling_util_api.trans_curr_rec,
   company_               IN  VARCHAR2,
   tax_code_              IN  VARCHAR2,
   tax_percentage_        IN  NUMBER,
   deductible_factor_     IN  NUMBER,
   transaction_date_      IN  DATE )
IS
   tax_info_table_         Tax_Handling_Util_API.tax_information_table;
   line_amount_rec_tmp_    Tax_Handling_Util_API.line_amount_rec;
BEGIN
   Tax_Handling_Util_API.Add_Tax_Code_Info(tax_info_table_, company_, NULL, tax_code_, NULL, NULL, 'FETCH_IF_VALID', tax_percentage_, transaction_date_);
   tax_info_table_(1).deductible_factor := deductible_factor_;
   line_amount_rec_tmp_ := line_amount_rec_;
   Tax_Handling_Util_API.Calc_Tax_Curr_Amounts(tax_info_table_, line_amount_rec_tmp_, company_, trans_curr_rec_);
   total_tax_amount_    := tax_info_table_(1).total_tax_curr_amount;
   tax_amount_          := tax_info_table_(1).tax_curr_amount;
   non_ded_tax_amount_  := tax_info_table_(1).non_ded_tax_curr_amount;     
END Calculate_Tax_Amount___;


PROCEDURE Set_Tax_Calc_Base_Info___ (
   tax_calc_base_percent_     OUT NUMBER,
   tax_calc_base_amount_      OUT NUMBER,
   tax_percentage_            IN  NUMBER,
   line_amount_rec_           IN  Tax_Handling_Util_API.line_amount_rec )
IS   
BEGIN
   IF (line_amount_rec_.calc_base = 'GROSS_BASE') THEN
      tax_calc_base_percent_ := tax_percentage_;
      -- Note: In GROSS_BASE if line total tax curr amount is entered, it should be used to calculate tax amounts.
      tax_calc_base_amount_  := NVL(line_amount_rec_.tax_calc_base_amount, (line_amount_rec_.line_gross_curr_amount * tax_calc_base_percent_) / (100 + tax_calc_base_percent_));
   ELSIF (line_amount_rec_.calc_base = 'NET_BASE') THEN
      tax_calc_base_percent_    := 100;
      tax_calc_base_amount_     := line_amount_rec_.line_net_curr_amount;     
   END IF; 
END Set_Tax_Calc_Base_Info___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-------------------- PUBLIC METHODS FOR FETCHING TAX RELATED INFO -----------

PROCEDURE Fetch_Validate_Tax_Code_On_Acc (
   tax_percentage_     OUT    NUMBER,
   tax_direction_      OUT    VARCHAR2,
   tax_type_db_        OUT    VARCHAR2,
   company_            IN     VARCHAR2,
   account_            IN     VARCHAR2,
   tax_code_           IN     VARCHAR2 )
IS
   tax_direction_db_           VARCHAR2(20);
   tax_rec_                    Statutory_Fee_API.Public_Rec;
BEGIN
   tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, sysdate, 'FALSE', 'FALSE', 'FETCH_IF_VALID');
   tax_type_db_ := tax_rec_.fee_type;
   tax_percentage_ := tax_rec_.fee_rate;
   Tax_Handling_Util_API.Validate_Tax_Code_On_Acc(company_, tax_code_, account_);
   Tax_Handling_Util_API.Fetch_Default_Tax_Direction(tax_direction_, tax_direction_db_, company_, account_, tax_code_);                                           
END Fetch_Validate_Tax_Code_On_Acc;

-------------------- PUBLIC METHODS FOR CALCULATIONS ------------------------

PROCEDURE Calc_Para_Curr_Tax_Amount (
   total_para_curr_tax_amount_      OUT NUMBER,
   para_curr_tax_amount_            OUT NUMBER,
   non_ded_para_curr_tax_amount_    OUT NUMBER,
   company_                         IN  VARCHAR2,
   amount_method_                   IN  VARCHAR2,
   tax_code_                        IN  VARCHAR2,
   tax_percentage_                  IN  NUMBER,
   consider_deduct_percentage_      IN  VARCHAR2,
   consider_calctax_percentage_     IN  VARCHAR2,
   parallel_curr_tax_base_amount_   IN  NUMBER,
   curr_rounding_                   IN  NUMBER,
   tax_round_method_                IN  VARCHAR2,
   transaction_date_                IN  DATE )
IS
   para_rounding_              NUMBER;
   tax_calc_base_percentage_   NUMBER;
   para_tax_base_              NUMBER;
   deductible_factor_          NUMBER;
   line_amount_rec_            Tax_Handling_Util_API.line_amount_rec;
   tax_rec_                    Statutory_Fee_API.Public_Rec;
   calc_base_                  VARCHAR2(10);
   rounding_method_            VARCHAR2(20);
BEGIN
   IF (amount_method_ = Def_Amount_Method_API.DB_NET) THEN
      calc_base_ := 'NET_BASE';
   ELSE
      calc_base_ := 'GROSS_BASE';
   END IF;
   tax_rec_         := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, transaction_date_, consider_calctax_percentage_, Fnd_Boolean_API.DB_TRUE, 'FETCH_IF_VALID');
   IF (consider_deduct_percentage_ = Fnd_Boolean_API.DB_FALSE) THEN
      deductible_factor_ := 1;
   ELSE
      deductible_factor_ := tax_rec_.deductible / 100;
   END IF;
   rounding_method_ := NVL(tax_round_method_, Tax_Handling_Util_API.Get_Tax_Rounding_Method_Db(company_, NULL, NULL, NULL));
   line_amount_rec_ := Tax_Handling_Util_API.Create_Line_Amount_Rec(parallel_curr_tax_base_amount_, parallel_curr_tax_base_amount_, NULL, calc_base_, Fnd_Boolean_API.DB_FALSE, NULL);
   Set_Tax_Calc_Base_Info___(tax_calc_base_percentage_, para_tax_base_, NVL(tax_percentage_, tax_rec_.fee_rate), line_amount_rec_);
   para_rounding_ := NVL(curr_rounding_, Currency_Code_API.Get_Currency_Rounding(company_, Currency_Code_API.Get_Parallel_Acc_Currency(company_)));
   total_para_curr_tax_amount_   := Currency_Amount_API.Round_Amount(rounding_method_, (para_tax_base_ * NVL(tax_percentage_, tax_rec_.fee_rate) / tax_calc_base_percentage_), para_rounding_);
   para_curr_tax_amount_         := Currency_Amount_API.Round_Amount(rounding_method_, (total_para_curr_tax_amount_ * deductible_factor_), para_rounding_);
   non_ded_para_curr_tax_amount_ := total_para_curr_tax_amount_ - para_curr_tax_amount_;   
END Calc_Para_Curr_Tax_Amount;


PROCEDURE Calculate_Calc_Tax_Amounts (
   currency_tax_amount_          OUT  NUMBER,
   tax_amount_                   OUT  NUMBER,
   parallel_curr_tax_amount_     OUT  NUMBER,
   currency_credit_amount_       IN   NUMBER,
   currency_debit_amount_        IN   NUMBER,
   credit_amount_                IN   NUMBER,
   debit_amount_                 IN   NUMBER,
   parallel_curr_credit_amount_  IN   NUMBER,
   parallel_curr_debit_amount_   IN   NUMBER,
   company_                      IN   VARCHAR2,
   currency_                     IN   VARCHAR2,
   tax_code_                     IN   VARCHAR2,
   consider_calctax_percentage_  IN   VARCHAR2,
   tax_percentage_               IN   NUMBER,
   transaction_date_             IN   DATE )
IS
   dummy_                            NUMBER;
   currency_tax_base_amount_         NUMBER;
   tax_base_amount_                  NUMBER;
   parallel_curr_tax_base_amount_    NUMBER;
   trans_curr_rec_                   Tax_Handling_Util_API.trans_curr_rec;
   line_amount_rec_                  Tax_Handling_Util_API.line_amount_rec;
BEGIN
   -- Calculate the tax amounts for the caluculated tax
   IF (tax_percentage_ = 0) THEN
      currency_tax_amount_       := 0;
      tax_amount_                := 0;
      parallel_curr_tax_amount_  := 0;
   ELSE
      IF (debit_amount_ IS NOT NULL) THEN
         currency_tax_base_amount_      := currency_debit_amount_;
         tax_base_amount_               := debit_amount_;
         parallel_curr_tax_base_amount_ := parallel_curr_debit_amount_;
      ELSIF (credit_amount_ IS NOT NULL) THEN
         currency_tax_base_amount_      := -1 * currency_credit_amount_;
         tax_base_amount_               := -1 * credit_amount_;
         parallel_curr_tax_base_amount_ := -1 * parallel_curr_credit_amount_;
      END IF;
      trans_curr_rec_  := Tax_Handling_Util_API.Create_Trans_Curr_Rec(company_, NULL, NULL, currency_, NULL, NULL, NULL, NULL);
      line_amount_rec_ := Tax_Handling_Util_API.Create_Line_Amount_Rec(currency_tax_base_amount_, currency_tax_base_amount_, NULL, 'NET_BASE', Fnd_Boolean_API.DB_FALSE, NULL);
      -- Calculate the tax curr amount
      Calculate_Tax_Amount___(currency_tax_amount_,
                              dummy_,
                              dummy_,
                              line_amount_rec_,
                              trans_curr_rec_,
                              company_,
                              tax_code_,
                              tax_percentage_,
                              1,
                              transaction_date_);
      line_amount_rec_ := Tax_Handling_Util_API.Create_Line_Amount_Rec(tax_base_amount_, tax_base_amount_, NULL, 'NET_BASE', Fnd_Boolean_API.DB_FALSE, NULL);                             
      -- Calculate the tax amount in acc curr
      Calculate_Tax_Amount___(tax_amount_,
                              dummy_,
                              dummy_,
                              line_amount_rec_,
                              trans_curr_rec_,
                              company_,
                              tax_code_,
                              tax_percentage_,
                              1,
                              transaction_date_);
      IF (parallel_curr_tax_base_amount_ IS NOT NULL) THEN
         Calc_Para_Curr_Tax_Amount(parallel_curr_tax_amount_, dummy_, dummy_, company_, Def_Amount_Method_API.DB_NET, tax_code_, NULL, Fnd_Boolean_API.DB_FALSE, consider_calctax_percentage_, parallel_curr_tax_base_amount_, NULL, NULL, transaction_date_);
      END IF;
   END IF;
END Calculate_Calc_Tax_Amounts;


PROCEDURE Calculate_Tax_Amounts (
   total_tax_amount_            OUT NUMBER,
   tax_amount_                  OUT NUMBER,
   non_ded_tax_amount_          OUT NUMBER,
   company_                     IN  VARCHAR2,
   currency_                    IN  VARCHAR2,
   tax_code_                    IN  VARCHAR2,
   tax_percentage_              IN  NUMBER,
   consider_deduct_percentage_  IN  VARCHAR2,
   tax_base_amount_             IN  NUMBER,
   amount_method_               IN  VARCHAR2,
   curr_rounding_               IN  NUMBER,
   tax_round_method_            IN  VARCHAR2,
   transaction_date_            IN  DATE )
IS
   trans_curr_rec_       Tax_Handling_Util_API.trans_curr_rec;
   line_amount_rec_      Tax_Handling_Util_API.line_amount_rec;
   tax_rec_              Statutory_Fee_API.Public_Rec;
   calc_base_            VARCHAR2(10);
   deductible_factor_    NUMBER;
BEGIN
   IF (amount_method_ = Def_Amount_Method_API.DB_NET) THEN
      calc_base_ := 'NET_BASE';
   ELSE
      calc_base_ := 'GROSS_BASE';
   END IF;
   tax_rec_         := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, transaction_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_TRUE, 'FETCH_IF_VALID');
   IF (consider_deduct_percentage_ = Fnd_Boolean_API.DB_FALSE) THEN
      deductible_factor_ := 1;
   ELSE
      deductible_factor_ := tax_rec_.deductible / 100;
   END IF;
   trans_curr_rec_  := Tax_Handling_Util_API.Create_Trans_Curr_Rec(company_, NULL, NULL, currency_, NULL, NULL, tax_round_method_, curr_rounding_);
   line_amount_rec_ := Tax_Handling_Util_API.Create_Line_Amount_Rec(tax_base_amount_, tax_base_amount_, NULL, calc_base_, Fnd_Boolean_API.DB_FALSE, NULL);
   Calculate_Tax_Amount___(total_tax_amount_,
                           tax_amount_,
                           non_ded_tax_amount_,
                           line_amount_rec_,
                           trans_curr_rec_,
                           company_,
                           tax_code_,
                           tax_percentage_,
                           deductible_factor_,
                           transaction_date_);   
END Calculate_Tax_Amounts;

-------------------- PUBLIC METHODS FOR VALIDATIONS -------------------------

PROCEDURE Validate_Tax_Code (
   company_    IN VARCHAR2,
   tax_code_   IN VARCHAR2 )
IS
   tax_type_db_  statutory_fee_tab.fee_type%TYPE;
BEGIN
   tax_type_db_ := Statutory_Fee_API.Get_Fee_Type_Db(company_, tax_code_);
   IF (tax_type_db_ NOT IN (Fee_Type_API.DB_TAX, Fee_Type_API.DB_CALCULATED_TAX, Fee_Type_API.DB_NO_TAX)) THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDFEETYPE: The tax code entered is incorrect. You can only use tax codes with tax type Tax, Calculated Tax, and No Tax.');
   END IF;
END Validate_Tax_Code;

-------------------- PUBLIC METHODS FOR COMMON LOGIC ------------------------

PROCEDURE Check_Max_Overwrite_Level (
   company_                   IN  VARCHAR2,
   currency_                  IN  VARCHAR2,
   tax_code_                  IN  VARCHAR2,
   tax_percentage_            IN  NUMBER,
   amount_method_             IN  VARCHAR2,
   tax_calc_base_amount_      IN  NUMBER,
   new_tax_amount_            IN  NUMBER,
   deductible_factor_         IN  NUMBER,
   tax_rec_                   IN  Statutory_Fee_API.Public_Rec,
   transaction_date_          IN  DATE )
IS
   trans_curr_rec_        Tax_Handling_Util_API.trans_curr_rec;
   line_amount_rec_       Tax_Handling_Util_API.line_amount_rec;
   calc_base_             VARCHAR2(10);
   calculated_tax_amount_ NUMBER;
   dummy_                 NUMBER; 
   acc_curr_rounding_     NUMBER;   
BEGIN
   IF (amount_method_ IN (Def_Amount_Method_API.DB_GROSS)) THEN
      calc_base_ := 'GROSS_BASE';
   ELSIF (amount_method_ IN (Def_Amount_Method_API.DB_NET)) THEN
      calc_base_ := 'NET_BASE';
   END IF;
   trans_curr_rec_  := Tax_Handling_Util_API.Create_Trans_Curr_Rec(company_, NULL, NULL, currency_, NULL, NULL, NULL, NULL);
   line_amount_rec_ := Tax_Handling_Util_API.Create_Line_Amount_Rec(tax_calc_base_amount_, tax_calc_base_amount_, NULL, calc_base_, Fnd_Boolean_API.DB_FALSE, NULL);
   
   -- Calculate the tax amount in acc curr
   Calculate_Tax_Amount___(dummy_,
                           calculated_tax_amount_,
                           dummy_,
                           line_amount_rec_,
                           trans_curr_rec_,
                           company_,
                           tax_code_,
                           NVL(tax_percentage_, tax_rec_.fee_rate),
                           deductible_factor_,
                           transaction_date_);
   acc_curr_rounding_ := Currency_Code_API.Get_Currency_Rounding(company_, Company_Finance_API.Get_Currency_Code(company_));
   Tax_Handling_Util_API.Validate_Max_Overwrite_Level(company_, tax_code_, calculated_tax_amount_, new_tax_amount_, acc_curr_rounding_); 
END Check_Max_Overwrite_Level;
 

PROCEDURE Create_Source_Tax_Item (
   company_                    IN VARCHAR2,
   source_ref_type_            IN VARCHAR2,
   source_ref1_                IN VARCHAR2,
   source_ref2_                IN VARCHAR2,
   source_ref3_                IN VARCHAR2,
   source_ref4_                IN VARCHAR2,
   source_ref5_                IN VARCHAR2,
   tax_code_                   IN VARCHAR2,
   currency_                   IN VARCHAR2,
   currency_tax_amount_        IN NUMBER,
   in_tax_percentage_          IN NUMBER,
   tax_amount_                 IN NUMBER,
   parallel_curr_tax_amount_   IN NUMBER,
   currency_tax_base_amount_   IN NUMBER,
   tax_base_amount_            IN NUMBER,
   third_curr_tax_base_amount_ IN NUMBER,
   transaction_date_           IN DATE )
IS
   sourcetaxrec_                  source_tax_item_tab%ROWTYPE;
   tax_rec_                       Statutory_Fee_API.Public_Rec;
   curr_tax_amount_               NUMBER;
   dom_tax_amount_                NUMBER;
   third_tax_amount_              NUMBER;
   currency_non_ded_tax_amount_   NUMBER;
   non_ded_tax_amount_            NUMBER;
   para_curr_non_ded_tax_amount_  NUMBER;
   dummy_                         NUMBER;
   total_tax_                     NUMBER;
   tax_percentage_                NUMBER;
   amount_method_                 VARCHAR2(5);
BEGIN
   tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(company_, tax_code_, transaction_date_, Fnd_Boolean_API.DB_FALSE, Fnd_Boolean_API.DB_FALSE, 'FETCH_AND_VALIDATE');
   tax_percentage_ := NVL(in_tax_percentage_, tax_rec_.fee_rate);
   IF (tax_rec_.fee_type = Fee_Type_API.DB_CALCULATED_TAX) THEN
      curr_tax_amount_              := 0;
      dom_tax_amount_               := 0;
      third_tax_amount_             := 0;
      currency_non_ded_tax_amount_  := 0;
      non_ded_tax_amount_           := 0;
      para_curr_non_ded_tax_amount_ := 0;
   ELSE
      amount_method_:= Voucher_API.Get_Amount_Method_Db(company_, to_number(source_ref1_), source_ref2_, to_number(source_ref3_));
      curr_tax_amount_     := currency_tax_amount_;
      dom_tax_amount_      := tax_amount_;
      third_tax_amount_    := parallel_curr_tax_amount_;
      IF (amount_method_ = Def_Amount_Method_API.DB_GROSS) THEN
         currency_non_ded_tax_amount_  := 0;
         non_ded_tax_amount_           := 0;
         para_curr_non_ded_tax_amount_ := 0;
      ELSE
         Calculate_Tax_Amounts(total_tax_,
                               dummy_,
                               dummy_,
                               company_,
                               currency_,
                               tax_code_,
                               tax_percentage_,
                               Fnd_Boolean_API.DB_FALSE,
                               currency_tax_base_amount_,
                               amount_method_,
                               NULL,
                               NULL,
                               transaction_date_);
         currency_non_ded_tax_amount_ := total_tax_ - currency_tax_amount_;
         Calculate_Tax_Amounts(total_tax_,
                               dummy_,
                               dummy_,
                               company_,
                               currency_,
                               tax_code_,
                               tax_percentage_,
                               Fnd_Boolean_API.DB_FALSE,
                               tax_base_amount_,
                               amount_method_,
                               NULL,
                               NULL,
                               transaction_date_);
         non_ded_tax_amount_ := total_tax_ - tax_amount_;
         Calc_Para_Curr_Tax_Amount(total_tax_,
                                   dummy_,
                                   dummy_,
                                   company_,
                                   amount_method_,
                                   tax_code_,
                                   tax_percentage_,
                                   Fnd_Boolean_API.DB_FALSE,
                                   Fnd_Boolean_API.DB_FALSE,
                                   third_curr_tax_base_amount_,
                                   NULL,
                                   NULL,
                                   transaction_date_);
         para_curr_non_ded_tax_amount_ := total_tax_ - parallel_curr_tax_amount_;
      END IF;
   END IF;
   Source_Tax_Item_API.Assign_Param_To_Record(sourcetaxrec_,
                                              company_,
                                              source_ref_type_,
                                              source_ref1_,
                                              source_ref2_,
                                              source_ref3_,
                                              source_ref4_,
                                              source_ref5_,
                                              tax_code_,
                                              NULL,      -- tax_calc_structure_id_
                                              NULL,      -- tax_calc_structure_item_id_
                                              Fnd_Boolean_API.DB_FALSE,
                                              1,
                                              tax_percentage_,
                                              curr_tax_amount_,
                                              dom_tax_amount_,
                                              third_tax_amount_,
                                              currency_non_ded_tax_amount_,
                                              non_ded_tax_amount_,
                                              para_curr_non_ded_tax_amount_,
                                              currency_tax_base_amount_,
                                              tax_base_amount_,
                                              third_curr_tax_base_amount_,
                                              NULL);
   
   Source_Tax_Item_Accrul_API.New(sourcetaxrec_);
END Create_Source_Tax_Item;


PROCEDURE Reverse_Tax_Item (
   from_company_               IN  VARCHAR2,
   from_source_ref_type_       IN  VARCHAR2,
   from_source_ref1_           IN  VARCHAR2,
   from_source_ref2_           IN  VARCHAR2,
   from_source_ref3_           IN  VARCHAR2,
   from_source_ref4_           IN  VARCHAR2,
   from_source_ref5_           IN  VARCHAR2,
   to_company_                 IN  VARCHAR2,
   to_source_ref_type_         IN  VARCHAR2,
   to_source_ref1_             IN  VARCHAR2,
   to_source_ref2_             IN  VARCHAR2,
   to_source_ref3_             IN  VARCHAR2,
   to_source_ref4_             IN  VARCHAR2,
   to_source_ref5_             IN  VARCHAR2 )
IS
   tax_rec_              Source_Tax_Item_API.source_public_rec;
   newrec_               source_tax_item_tab%ROWTYPE; 
BEGIN
   tax_rec_  := Source_Tax_Item_API.Get_Tax_Item(from_company_, from_source_ref_type_, from_source_ref1_, from_source_ref2_, from_source_ref3_, from_source_ref4_, from_source_ref5_, 1);
   -- Create tax line from source
   tax_rec_.company                    := to_company_;
   tax_rec_.tax_item_id                := 1;  
   tax_rec_.source_ref_type            := to_source_ref_type_;
   tax_rec_.source_ref1                := to_source_ref1_;
   tax_rec_.source_ref2                := to_source_ref2_;
   tax_rec_.source_ref3                := to_source_ref3_;
   tax_rec_.source_ref4                := to_source_ref4_;
   tax_rec_.source_ref5                := to_source_ref5_;
   tax_rec_.tax_curr_amount            := -tax_rec_.tax_curr_amount;
   tax_rec_.tax_dom_amount             := -tax_rec_.tax_dom_amount;
   tax_rec_.tax_parallel_amount        := -tax_rec_.tax_parallel_amount;
   tax_rec_.tax_base_curr_amount       := -tax_rec_.tax_base_curr_amount;
   tax_rec_.tax_base_dom_amount        := -tax_rec_.tax_base_dom_amount;
   tax_rec_.tax_base_parallel_amount   := -tax_rec_.tax_base_parallel_amount;
   Source_Tax_Item_API.Assign_Pubrec_To_Record(newrec_, tax_rec_);
   Source_Tax_Item_Accrul_API.New(newrec_);   
END Reverse_Tax_Item;

-------------------- LU  NEW METHODS -------------------------------------

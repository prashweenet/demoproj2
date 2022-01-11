-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyAmountPub
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000118  SaCh  Created.
--  081103  Nudilk Bug 78160,Modified Get_Rate()
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Rate (
   company_    IN VARCHAR2,
   curr_code_  IN VARCHAR2,
   curr_type_  IN VARCHAR2,
   trans_date_ IN DATE ) RETURN NUMBER
IS   
BEGIN
   RETURN Currency_Rate_API.Get_Currency_Rate(company_, curr_code_, curr_type_, trans_date_);   
END Get_Rate;


@UncheckedAccess
FUNCTION Calc_Base_Amount (
   company_         IN VARCHAR2,
   trans_curr_code_ IN VARCHAR2,
   trans_amount_    IN NUMBER,
   trans_date_      IN DATE ) RETURN NUMBER
IS
   division_factor_         NUMBER;
   amt_                     NUMBER;
   conv_factor_             NUMBER;
   currency_rounding_       NUMBER;
   divisor_                 NUMBER;
   currency_type_           VARCHAR2(10);
   currency_rate_           NUMBER;
   amount_                  NUMBER;
BEGIN
   division_factor_   := Currency_Code_API.Get_Conversion_Factor(company_, trans_curr_code_);
   currency_type_     := Currency_Type_API.Get_Default_Type(company_);
   currency_rate_     := Currency_Amount_Pub_API.Get_Rate(company_, trans_curr_code_, currency_type_, trans_date_);
   conv_factor_       := Currency_Code_API.Get_Conversion_Factor(company_, trans_curr_code_);
   currency_rounding_ := Currency_Code_API.Get_Currency_Rounding(company_, trans_curr_code_);
   IF (division_factor_ IS NOT NULL) THEN
      divisor_ := division_factor_;
   ELSE
      divisor_ := conv_factor_;
   END IF;
   amt_    := trans_amount_ * (currency_rate_ / divisor_);
   amount_ := round(amt_, currency_rounding_);
   RETURN amount_;
END Calc_Base_Amount;


@UncheckedAccess
FUNCTION Calc_Trans_Amount (
   company_         IN VARCHAR2,
   trans_curr_code_ IN VARCHAR2,
   base_amount_     IN NUMBER,
   trans_date_      IN DATE ) RETURN NUMBER
IS
   base_curr_code_  VARCHAR2(3);
BEGIN
   base_curr_code_ := Currency_Code_API.Get_Currency_Code(company_);
   RETURN Currency_Amount_API.Calc_Trans_Amount(company_, base_curr_code_, base_amount_, trans_curr_code_, trans_date_);
END Calc_Trans_Amount;





-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyTypeBasicData
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131116  Umdolk  Refactoring.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('USE_TAX_RATES','FALSE',attr_);
END Prepare_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     currency_type_basic_data_tab%ROWTYPE,
   newrec_ IN OUT currency_type_basic_data_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2)
IS
   emu_currency_            VARCHAR2(6);
   ref_currency_code_       VARCHAR2(3);
   company_currency_code_   VARCHAR2(3);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF ( newrec_.use_tax_rates = 'TRUE') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'TAX_SELL', newrec_.tax_sell);
      Error_SYS.Check_Not_Null(lu_name_, 'TAX_BUY', newrec_.tax_buy);
   END IF;
   company_currency_code_ := Company_Finance_API.Get_Currency_Code(newrec_.company);
   emu_currency_ := Currency_Code_API.Get_Emu(newrec_.company, company_currency_code_);

   IF (indrec_.buy) THEN 
      ref_currency_code_ := Currency_Type_API.Get_Ref_Currency_Code(newrec_.company, newrec_.buy);
      IF (newrec_.buy IS NOT NULL AND emu_currency_ != 'TRUE' AND ref_currency_code_ != 'EUR' AND ref_currency_code_ != company_currency_code_) THEN
         Client_SYS.Add_Info(lu_name_, 'CURRENCYTYPEMSGBUY: Buy currency rate type must have accounting currency as reference currency.');    
      END IF;   
   END IF;  
   IF (indrec_.tax_buy) THEN 
      ref_currency_code_ := Currency_Type_API.Get_Ref_Currency_Code(newrec_.company, newrec_.tax_buy);
      IF (newrec_.tax_buy IS NOT NULL AND emu_currency_ != 'TRUE' AND ref_currency_code_ != 'EUR' AND ref_currency_code_ != company_currency_code_) THEN
         Client_SYS.Add_Info(lu_name_, 'CURRENCYTYPEMSGTAXBUY: Tax Buy currency rate type must have accounting currency as reference currency.');    
      END IF;   
   END IF; 
   IF (indrec_.tax_sell) THEN 
      ref_currency_code_ := Currency_Type_API.Get_Ref_Currency_Code(newrec_.company, newrec_.tax_sell);
      IF (newrec_.tax_sell IS NOT NULL AND emu_currency_ != 'TRUE' AND ref_currency_code_ != 'EUR' AND ref_currency_code_ != company_currency_code_) THEN
         Client_SYS.Add_Info(lu_name_, 'CURRENCYTYPEMSGTAXSELL: Tax Sell currency rate type must have accounting currency as reference currency.');    
      END IF;   
   END IF; 
   IF (indrec_.sell) THEN 
      ref_currency_code_ := Currency_Type_API.Get_Ref_Currency_Code(newrec_.company, newrec_.sell);
      IF (newrec_.sell IS NOT NULL AND emu_currency_ != 'TRUE' AND ref_currency_code_ != 'EUR' AND ref_currency_code_ != company_currency_code_) THEN
         Client_SYS.Add_Info(lu_name_, 'CURRENCYTYPEMSGSELL: Sell currency rate type must have accounting currency as reference currency.');    
      END IF;   
   END IF;   
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT currency_type_basic_data_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.use_tax_rates IS NULL) THEN
      newrec_.use_tax_rates := 'FALSE';
   END IF;
   super(newrec_, indrec_, attr_);   
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


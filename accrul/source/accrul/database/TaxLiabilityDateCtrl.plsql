-----------------------------------------------------------------------------
--
--  Logical unit: TaxLiabilityDateCtrl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  060908  Hawalk  FIPL602A, Created. This LU takes over tax liability date controls from LU TaxLedgerParameter. Includes some additional
--  060908          functionality which is tax code specific.
--  060920  Lokrlk  Added Company Template Support
--  090605  THPELK  Bug 82609 - Added UNDEFINE section and the missing statements for VIEWPCT.
--  120514  SALIDE  EDEL-698, Added VIEW_AUDI
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_liability_date_ctrl_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
   company_flag_               BOOLEAN := FALSE;
   sup_liability_date_flag_    BOOLEAN := FALSE;
   sup_liability_date_db_flag_ BOOLEAN := FALSE;
   cus_liability_date_flag_    BOOLEAN := FALSE;
   cus_liability_date_db_flag_ BOOLEAN := FALSE;
   pay_liability_date_flag_    BOOLEAN := FALSE;
   pay_liability_date_db_flag_ BOOLEAN := FALSE;

   
BEGIN
   company_flag_               := Client_SYS.Item_Exist('COMPANY',attr_);
   sup_liability_date_flag_    := Client_SYS.Item_Exist('SUPPLIER_LIABILITY_DATE',attr_);
   sup_liability_date_db_flag_ := Client_SYS.Item_Exist('SUPPLIER_LIABILITY_DATE_DB',attr_);
   cus_liability_date_flag_    := Client_SYS.Item_Exist('CUSTOMER_LIABILITY_DATE',attr_);
   cus_liability_date_db_flag_ := Client_SYS.Item_Exist('CUSTOMER_LIABILITY_DATE_DB',attr_);
   pay_liability_date_flag_    := Client_SYS.Item_Exist('PAYMENTS_LIABILITY_DATE',attr_);
   pay_liability_date_db_flag_ := Client_SYS.Item_Exist('PAYMENTS_LIABILITY_DATE_DB',attr_);  

   newrec_.customer_liability_date  := NVL(newrec_.customer_liability_date, 'VOUCHERDATE');  
   newrec_.payments_liability_date  := NVL(newrec_.payments_liability_date, 'VOUCHERDATE');
   newrec_.supplier_liability_date  := NVL(newrec_.supplier_liability_date, 'VOUCHERDATE');

   super(newrec_, indrec_, attr_);
   
   Company_Finance_API.Exist(newrec_.company);
   IF NOT (sup_liability_date_flag_ ) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.supplier_liability_date);
   END IF;

   IF NOT (sup_liability_date_db_flag_ ) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.supplier_liability_date);
   END IF;

   IF NOT (cus_liability_date_flag_ ) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_liability_date);
   END IF;

   IF NOT (cus_liability_date_db_flag_ ) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.customer_liability_date);
   END IF;

   IF NOT (pay_liability_date_flag_ IS NOT NULL) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.payments_liability_date);
   END IF;

   IF NOT (pay_liability_date_db_flag_ IS NOT NULL) THEN
      Tax_Liability_Date_API.Exist_Db(newrec_.payments_liability_date);
   END IF;   
   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


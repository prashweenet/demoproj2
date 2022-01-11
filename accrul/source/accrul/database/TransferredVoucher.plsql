-----------------------------------------------------------------------------
--
--  Logical unit: TransferredVoucher
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  280905   Mawelk   Fixed bug id 84647 Added a method Get_Voucher_Date()
--  210510   Kagalk   EAFH-2939, Removed field ACCRUL_ID
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Voucher_Date (
   company_ IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_ IN VARCHAR2,
   voucher_no_ IN NUMBER ) RETURN DATE
IS
   temp_ TRANSFERRED_VOUCHER_TAB.voucher_date%TYPE;
   CURSOR get_attr IS
      SELECT voucher_date
      FROM   TRANSFERRED_VOUCHER_TAB
      WHERE  company = company_
      AND    accounting_year = accounting_year_
      AND    voucher_type = voucher_type_
      AND    voucher_no = voucher_no_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Voucher_Date;





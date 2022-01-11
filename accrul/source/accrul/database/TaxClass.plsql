-----------------------------------------------------------------------------
--
--  Logical unit: TaxClass
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  101110  jofise   Created.
--  101116  jofise   DF-514, Added code to handle translations in Insert___ and Update___.
--  101229  MiKulk   Added method Get_Valid_Fee_Code
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Get_Valid_Fee_Code
--   This method will retrive the fee code valid for the given date
@UncheckedAccess
FUNCTION Get_Valid_Fee_Code(
   company_             IN VARCHAR2,
   tax_class_id_        IN VARCHAR2,
   delivery_country_db_ IN VARCHAR2,
   tax_liability_       IN VARCHAR2,
   valid_from_          IN VARCHAR2) RETURN VARCHAR2
IS
   fee_code_   TAX_CODES_PER_TAX_CLASS_TAB.fee_code%TYPE;
   max_valid_from_date_ DATE;
         

   CURSOR get_max_valid_from IS
      SELECT MAX(valid_from)
      FROM   TAX_CODES_PER_TAX_CLASS_TAB
      WHERE  company = company_
      AND    tax_class_id = tax_class_id_
      AND    country_code = delivery_country_db_
      AND    tax_liability = tax_liability_
      AND    valid_from <= valid_from_;

BEGIN
   OPEN get_max_valid_from;
   FETCH get_max_valid_from INTO max_valid_from_date_;
   CLOSE get_max_valid_from;

   fee_code_ := Tax_Codes_Per_Tax_Class_API.Get_Fee_Code(company_, tax_class_id_, 
                                                         ISO_Country_API.Decode(delivery_country_db_),
                                                         tax_liability_, max_valid_from_date_);
   RETURN fee_code_;

END Get_Valid_Fee_Code;





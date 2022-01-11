-----------------------------------------------------------------------------
--
--  Logical unit: TaxCodeTexts
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  030711  Risrlk   Modified Import___, Copy___, and Make_Company methods and
--                   Added Import_Copy___, Calc_New_Date___, Modify_Key_Date___ and Crecomp_Inser___ methods.
--  021203  Ravilk   Created.
--
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  040803  sachlk   LCS Merge: Bug 41629.
--  060314  ovjose   Since date is part of key, make sure to use date mask towards 
--                   company translation interface
--  070802  Marulk   LCS Patch Merge 65158. Changes in Import_Copy___(). 
--                   Changed a condition that checked NVL(,) to IS NOT NULL
--  100308  Nsillk   EAFH-2160 , Modified method Import_Copy
--  100831  ovjose   Removed Modify_Key_Date___ and Calc_New_Date___. Date handling changed.
--  110324  Umdolk   EAPM-16108, Corrected errors in create company in Import___.
--  131114  Lamalk   PBFI-1938, Refactored code according to new accounting standards
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE table_rec     IS TABLE OF TAX_CODE_TEXTS_TAB%ROWTYPE INDEX BY BINARY_INTEGER;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_until_      accrul_attribute_tab.attribute_value%TYPE; 
   -- gelr:it_tax_reports, begin
   company_          VARCHAR2(20):= Client_SYS.Get_Item_Value('COMPANY', attr_ );
   -- gelr:it_tax_reports, end
BEGIN
   super(attr_);
   valid_until_ := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');
   Client_SYS.Add_To_Attr('VALID_UNTIL', TO_DATE(valid_until_, 'YYYYMMDD'), attr_);
   Client_SYS.Add_To_Attr('VALID_FROM', SYSDATE, attr_);
   -- gelr:it_tax_reports, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(company_, 'IT_TAX_REPORTS') = Fnd_Boolean_API.DB_FALSE) THEN
      Client_SYS.Add_To_Attr('EXC_FROM_SPESOMETRO_DEC', 'FALSE', attr_);
   END IF;
   -- gelr:it_tax_reports, end
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_code_texts_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_       VARCHAR2(30);
   value_      VARCHAR2(2000);
   CURSOR get_date_ranges IS
      SELECT valid_from ,valid_until
      FROM   tax_code_texts_tab
      WHERE  company  = newrec_.company
      AND    fee_code = newrec_.fee_code;
BEGIN
   super(newrec_, indrec_, attr_);
   -- trunc the dates 
   newrec_.valid_from := Trunc(newrec_.valid_from);
   newrec_.valid_until := Trunc(newrec_.valid_until);
   FOR get_date_range_rec_ IN get_date_ranges LOOP
      IF (newrec_.valid_from >= get_date_range_rec_.valid_from) AND  (newrec_.valid_from <= get_date_range_rec_.valid_until) THEN
         Error_SYS.Record_General(lu_name_, 'WRONGDATERANGE: Date ranges overlap');
      END IF;
      IF (newrec_.valid_from <= get_date_range_rec_.valid_from) AND (newrec_.valid_until >= get_date_range_rec_.valid_from) THEN
         Error_SYS.Record_General(lu_name_, 'WRONGDATERANGE: Date ranges overlap');
      END IF;
   END LOOP;
   IF (newrec_.valid_from >  newrec_.valid_until) THEN
      Error_SYS.Record_General(lu_name_, 'WRONGDATE: Valid until must be greater than valid from');
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@Override
@UncheckedAccess
FUNCTION Get_Tax_Code_Text (
   company_ IN VARCHAR2,
   fee_code_ IN VARCHAR2,
   valid_from_ IN DATE,
   valid_until_ IN DATE ) RETURN VARCHAR2
IS
   temp_ tax_code_texts_tab.tax_code_text%TYPE;
   CURSOR get_attr IS
      SELECT tax_code_text
      FROM   tax_code_texts_tab
      WHERE  company  = company_
      AND    fee_code = fee_code_
      AND    valid_from_ BETWEEN valid_from AND valid_until;   
BEGIN
   temp_ := super(company_, fee_code_, valid_from_, valid_until_);
   IF (temp_ IS NOT NULL) THEN
      RETURN temp_;
   ELSE
      OPEN  get_attr;
      FETCH get_attr INTO temp_;
      CLOSE get_attr;      
   END IF;
   RETURN temp_;
END Get_Tax_Code_Text;


-- gelr:it_tax_reports, begin
FUNCTION Get_Natureof_Operation (
   company_     IN VARCHAR2,
   fee_code_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ tax_code_texts_tab.natureof_operation%TYPE;
   CURSOR get_natureof_operation IS
      SELECT natureof_operation
      FROM   tax_code_texts_tab
      WHERE  company = company_
      AND    fee_code = fee_code_;
BEGIN
   OPEN get_natureof_operation;
   FETCH get_natureof_operation INTO temp_;
   CLOSE get_natureof_operation;
   RETURN Nature_Of_Operation_API.Decode(temp_);
END Get_Natureof_Operation;
-- gelr:it_tax_reports, end


-- gelr:it_tax_reports, begin
FUNCTION Get_Exclude_From_Specemetro (
   company_     IN VARCHAR2,
   fee_code_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ tax_code_texts_tab.exc_from_spesometro_dec%TYPE;
   CURSOR get_exclude_from_specemetro IS
      SELECT exc_from_spesometro_dec
      FROM   tax_code_texts_tab
      WHERE  company = company_
      AND    fee_code = fee_code_;
BEGIN
   OPEN get_exclude_from_specemetro;
   FETCH get_exclude_from_specemetro INTO temp_;
   CLOSE get_exclude_from_specemetro;
   RETURN temp_;
END Get_Exclude_From_Specemetro;
-- gelr:it_tax_reports, end

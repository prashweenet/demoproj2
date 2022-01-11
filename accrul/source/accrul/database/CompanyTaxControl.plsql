-----------------------------------------------------------------------------
--
--  Logical unit: CompanyTaxControl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151208  MalLlk  FINHR-419, Created.
--  200625  NiDalk  SCXTEND-4438, Modified Check_Common___ validate fetch_tax_on_line_entry for AVALARA sales tax.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------   

PROCEDURE Check_Tax_Liability_Ref___ (
   newrec_ IN OUT company_tax_control_tab%ROWTYPE )
IS
   country_db_ VARCHAR2(2);
BEGIN
   country_db_ := Company_API.Get_Country_Db(newrec_.company);
   Tax_Liability_API.Check_Tax_Liability(newrec_.tax_liability, country_db_);   
END Check_Tax_Liability_Ref___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     company_tax_control_tab%ROWTYPE,
   newrec_ IN OUT company_tax_control_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN 
   IF (newrec_.external_tax_cal_method != 'NOT_USED') THEN 
      IF (newrec_.ar_req_tax_object_level = 'TRUE' OR newrec_.ar_req_tax_addr_level = 'TRUE' OR newrec_.ar_req_tax_trans_level = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_, 'INVALIDCOMBINATION: You are not allowed to combine validations for Object Level, Address Level or Transaction Level on General tab with :P1 on External Tax System tab.', External_Tax_Calc_Method_API.Decode(newrec_.external_tax_cal_method));    
      END IF;
   END IF;
   IF (newrec_.external_tax_cal_method = External_Tax_Calc_Method_API.DB_AVALARA_SALES_TAX) THEN 
      IF (newrec_.fetch_tax_on_line_entry = 'FALSE' AND newrec_.refresh_tax_on_co_release = 'FALSE') THEN 
         Error_SYS.Record_General(lu_name_, 'REFRESTAXONCORELEASEFALSE: When "Automatic Fetch of Tax Information at Part/Charge Line Entry" is not selected it is required to select "Refresh Tax Information at Release of Customer Order".', External_Tax_Calc_Method_API.Decode(newrec_.external_tax_cal_method));
      END IF;
   END IF;
   Validate_Tax_Code___(newrec_, indrec_);   
   super(oldrec_, newrec_, indrec_, attr_);
   IF (indrec_.ar_req_tax_object_level) THEN 
      IF (newrec_.ar_req_tax_object_level = 'TRUE') THEN
         newrec_.ar_req_tax_trans_level := 'TRUE';
      END IF;   
   END IF; 
   IF (indrec_.ar_req_tax_addr_level) THEN 
      IF (newrec_.ar_req_tax_addr_level = 'TRUE') THEN
         newrec_.ar_req_tax_trans_level := 'TRUE';
      END IF;   
   END IF;
   IF (indrec_.ar_req_tax_trans_level) THEN 
      IF (newrec_.ar_req_tax_trans_level = 'FALSE') THEN
         Client_SYS.Add_Warning(lu_name_, 'TRANSLEVELVALIDATE: Unchecking this check box will turn off the validation that tax code is mandatory on transaction level. This will have an impact in reporting and follow-up.');    
      END IF;
   END IF;  
   IF (indrec_.ap_req_tax_trans_level) THEN 
      IF (newrec_.ap_req_tax_trans_level = 'FALSE') THEN
         Client_SYS.Add_Warning(lu_name_, 'TRANSLEVELVALIDATE: Unchecking this check box will turn off the validation that tax code is mandatory on transaction level. This will have an impact in reporting and follow-up.');    
      END IF;
   END IF;
   IF (indrec_.update_tax_percent) THEN 
      IF (newrec_.update_tax_percent = 'TRUE') THEN
         Client_SYS.Add_Warning(lu_name_, 'ALLOWUPDATETAXPERCENTAGE: This will enable the possibility of modifying tax percentage (%) of tax codes already used in the application. '||
                                'Modifying tax % would be required to update the existing tax information in preliminary invoices/documents and prices on the basic data such as sales parts, supplier for purchase parts etc. '||
                                'It could also affect some tax reconciliation reports.');    
      END IF;
   END IF;
END Check_Common___;


PROCEDURE Validate_Tax_Code___ (
   newrec_ IN OUT company_tax_control_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec )
IS
   tax_types_event_  VARCHAR2(20):= 'RESTRICTED';
   taxable_event_    VARCHAR2(20):= 'ALL';
   valid_date_       DATE;
BEGIN
   valid_date_ := App_Context_SYS.Find_Date_Value('CreateCompany_Valid_From', SYSDATE);
   IF (newrec_.tax_code_city IS NOT NULL AND indrec_.tax_code_city) THEN 
      Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, tax_types_event_, newrec_.tax_code_city, taxable_event_, valid_date_);   
   END IF;
   IF (newrec_.tax_code_state IS NOT NULL AND indrec_.tax_code_state) THEN 
      Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, tax_types_event_, newrec_.tax_code_state, taxable_event_, valid_date_);
   END IF;
   IF (newrec_.tax_code_county IS NOT NULL AND indrec_.tax_code_county) THEN 
      Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, tax_types_event_, newrec_.tax_code_county, taxable_event_, valid_date_);
   END IF;
   IF (newrec_.tax_code_district IS NOT NULL AND indrec_.tax_code_district) THEN 
      Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, tax_types_event_, newrec_.tax_code_district, taxable_event_, valid_date_);
   END IF;
END Validate_Tax_Code___;  

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
   
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Default_Tax_Codes (
   tax_code_city_     OUT VARCHAR2,
   tax_code_state_    OUT VARCHAR2,
   tax_code_county_   OUT VARCHAR2,
   tax_code_district_ OUT VARCHAR2,
   company_           IN  VARCHAR2 )
IS
   CURSOR get_attr IS
      SELECT tax_code_city, tax_code_state, tax_code_county, tax_code_district
      FROM   company_tax_control_tab
      WHERE  company = company_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO tax_code_city_, tax_code_state_, tax_code_county_, tax_code_district_;
   CLOSE get_attr;
END Get_Default_Tax_Codes;


-- Method that fetches tax code validations
-- Input parameters:
-- tax_validation_type_: CUSTOMER_TAX, SUPPLIER_TAX
-- tax_valiation_level_: OBJECT, ADDRESS, TRANSACTION
FUNCTION Get_Tax_Code_Validation (
   company_              IN VARCHAR2,
   tax_validation_type_  IN VARCHAR2,
   tax_valiation_level_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   rec_                   Public_Rec;
   tax_code_validation_   VARCHAR2(20);
BEGIN
   rec_ := Get(company_);
   IF (tax_validation_type_ = 'CUSTOMER_TAX') THEN
      IF (tax_valiation_level_ = 'OBJECT') THEN
          tax_code_validation_ := rec_.ar_req_tax_object_level;
      ELSIF (tax_valiation_level_ = 'ADDRESS') THEN
         tax_code_validation_ := rec_.ar_req_tax_addr_level;
      ELSIF (tax_valiation_level_ = 'TRANSACTION') THEN
         tax_code_validation_ := rec_.ar_req_tax_trans_level;
      END IF;
   ELSIF (tax_validation_type_ = 'SUPPLIER_TAX') THEN
      IF (tax_valiation_level_ = 'OBJECT') THEN
          tax_code_validation_ := rec_.ap_req_tax_object_level;
      ELSIF (tax_valiation_level_ = 'TRANSACTION') THEN
         tax_code_validation_ := rec_.ap_req_tax_trans_level;
      END IF;
   END IF;
   RETURN tax_code_validation_;
END Get_Tax_Code_Validation;



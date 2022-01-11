-----------------------------------------------------------------------------
--
--  Logical unit: VoucherTemplate
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  980429  BREN  Created.
--  990707  HIMM  Modified withrespect to template changes
--  000119  Uma   Global Date Definition.
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  070514  Chsalk  LCS Merge 64448; Added conversion_factor to view.
--  131029  Umdolk PBFI-1332, Corrected model file errors.
--  131101  Umdolk PBFI-2125, Refactoring
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_until_      Accrul_Attribute_Tab.attribute_value%TYPE;
BEGIN
   valid_until_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');
   
   super(attr_);
   Client_SYS.Add_To_Attr('VALID_FROM', SYSDATE, attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL',trunc(to_date(valid_until_, 'YYYYMMDD')), attr_);
   Client_SYS.Add_To_Attr('MULTI_COMPANY_DB', Fnd_Boolean_API.Get_Db_Value(0) , attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     voucher_template_tab%ROWTYPE,
   newrec_ IN OUT voucher_template_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.correction IS NULL) THEN
      newrec_.correction := 'N';
   END IF;   
   IF (newrec_.multi_company IS NULL) THEN
      newrec_.multi_company := Fnd_Boolean_API.Get_Db_Value(0);
   END IF;
   IF (newrec_.multi_company = 'FALSE') THEN
      Voucher_Template_Row_API.Is_Multi_Company(newrec_.company,newrec_.template);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);   
   IF newrec_.valid_from > newrec_.valid_until THEN
      Error_SYS.Record_General(lu_name_, 'INVALDATE: Valid from is greater than valid until');
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_template_tab%ROWTYPE,
   newrec_ IN OUT voucher_template_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   IF newrec_.multi_company = 'FALSE' THEN
      Voucher_Template_Row_API.Is_Multi_Company(oldrec_.company, oldrec_.template);
   END IF;
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

@UncheckedAccess
FUNCTION Template_Check_ (
   company_ IN VARCHAR2,
   template_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF CHECK_EXIST___(company_, template_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Template_Check_;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_Table_ (
   company_         IN VARCHAR2,
   template_        IN VARCHAR2,
   description_     IN VARCHAR2,
   valid_from_      IN DATE,
   valid_until_     IN DATE,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   include_amount_  IN VARCHAR2,
   multi_company_   IN VARCHAR2 DEFAULT 'FALSE')
IS
BEGIN
   IF template_ IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'TEMMAN: Template must have a value');
   END IF;
   IF description_ IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'DECMAN: Description must have a value');
   END IF;
   IF valid_from_ IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'VFMAN: Valid From must have a value');
   END IF;
   IF valid_until_ IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'VUMAN: Valid Until must have a value');
   END IF;
   IF(valid_from_> valid_until_) THEN
      Error_SYS.Record_General(lu_name_, 'ERRORDATEMISMATCH: Valid From is greater than Valid Until');
   END IF;    
   IF (Voucher_Template_API.Template_Check_(company_,template_) = 'TRUE') THEN         
      Error_SYS.Record_General(lu_name_, 'ERRORTEMPEXIST: Template already Exists');
   END IF;        
   
   -- Add template header to the table
   INSERT
      INTO voucher_template_tab (
         company,
         template,
         description,
         valid_from,
         valid_until,
         multi_company,
         rowversion)
      VALUES (
         company_,
         template_,
         description_,
         valid_from_,
         valid_until_,
         multi_company_,
         sysdate);
   -- Add template rows to the table
   Voucher_Template_Row_API.Insert_Table_(company_, template_,accounting_year_,voucher_type_,voucher_no_,include_amount_,multi_company_);
END Insert_Table_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Correction (
   company_ IN VARCHAR2,
   template_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ voucher_template_tab.correction%TYPE;
BEGIN
   IF (company_ IS NULL OR template_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT correction
      INTO  temp_
      FROM  voucher_template_tab
      WHERE company = company_
      AND   template = template_;
   RETURN temp_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(company_, template_, 'Get_Correction');
END Get_Correction;

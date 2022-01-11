-----------------------------------------------------------------------------
--
--  Logical unit: TaxCodesPerTaxClass
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  101116  Elarse  Changed column fee_code.
--  101117  Elarse  Additional modifications to columns, views and functions.
--  101122  Elarse  Modified some error handling in Unpack_Check_Insert___().
--  101124  Elarse  Changes due to a change of CountryCode to LOOKUP type.
--  101126  Elarse  Added new label text for view column country code.
--  101202  Elarse  Added public view TAX_CODES_PER_TAX_CLASS_PUB.
--  101222  Elarse  Moved TAX_CODES_PER_TAX_CLASS_PUB to specification.
--  110516  Mohrlk  EASTONE-19543, Modified Unpack_Check_Insert___()
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT tax_codes_per_tax_class_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN   
   super(newrec_, crecomp_rec_, pub_rec_);
    newrec_.valid_from := crecomp_rec_.valid_from;
END Import_Assign___;

PROCEDURE Check_Company_Country_Ref___ (
   newrec_ IN OUT tax_codes_per_tax_class_tab%ROWTYPE )
IS
BEGIN
   Tax_Liability_API.Check_Tax_Liability(newrec_.tax_liability, newrec_.country_code);
END Check_Company_Country_Ref___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     tax_codes_per_tax_class_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY tax_codes_per_tax_class_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2)
IS   
BEGIN
   Gen_Pre_Check_Common___(newrec_);   
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_codes_per_tax_class_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   value_         VARCHAR2(4000);
   name_          VARCHAR2(30);
BEGIN
   super(newrec_, indrec_, attr_);
   IF (Tax_Liability_API.Get_Tax_Liability_Type_Db(newrec_.tax_liability,newrec_.country_code) = 'EXM') THEN
      Error_SYS.Appl_General(lu_name_,'INVALIDLIABILITYTYPE: Tax Liability must be Taxable');   
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;
   
PROCEDURE Gen_Pre_Check_Common___ (
   newrec_ IN OUT NOCOPY tax_codes_per_tax_class_tab%ROWTYPE )
IS
   tax_types_event_  VARCHAR2(20):= 'RESTRICTED';
   taxable_event_    VARCHAR2(20):= 'ALL';
BEGIN
   Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, tax_types_event_, newrec_.fee_code, taxable_event_, newrec_.valid_from);       
END Gen_Pre_Check_Common___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


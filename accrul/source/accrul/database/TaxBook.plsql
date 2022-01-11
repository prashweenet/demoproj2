-----------------------------------------------------------------------------
--
--  Logical unit: TaxBook
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021101  risrlk created IID - ITFI101E
--  021111  Jakalk Salsa-IIDITFI101E - Added New LOV view TAX_BOOK_LOV.
--                                   - Added New method Get_Tax_Ref_Desc.
--  021114  risrlk SALSA IID ITFI101E - Taxled_Connection_V120_api was used instead of tax_series_api
--  021115  risrlk SALSA IID ITFI101E - Added Validate_Delete function.
--  021116  Raablk SALSA IID ITFI101E.Added Function Check_Exist and Valid_Book_Id.
--  021119  Jakalk SALSA IID ITFI101E.Added Procedure Tax_Book_Ref_Exist.
--  021120  RAABLK SALSA IID - ITFI101E.Changed  Function Check_Exist.
--  021127  risrlk SALSA B91912. Corrected.
--  021127  RAABLK B91909 - Corrected . Modified  function Check_Exist.
--  021127  Jakalk B91908 - Corrected . Modified Tax_Book_Ref_Exist.
--  030326  risrlk RDFI140NF - Changed Db values
--  030505  risrlk corrected db_value change errors.
--  030911  Shsalk Added import___, copy___, export___ and Make_Company methods.
--  031219  Hecolk IID FIPR407A2, Added Cursor cur_fee_code in PROCEDURE Save_All
--  031219  Hecolk IID FIPR407A2, Added Cursor cur_fee_code in PROCEDURE Validate_Update
--  040623  anpelk FIPR338A2: Unicode Changes.
--  051013  Chprlk Added code to include all tax codes when creating a 
--  051013         company from another company in copy___ method.
--  070719  Paralk B146838 Call Enterp_Comp_Connect_V160_API.Get_Attribute_Translation() in VIEW 
--  080421  NiFelk Bug 73180, Corrected in Save_All.
--  111017  Shdilk SFI-127, Conditional compilation.
--  111019  Umdolk SFI-149, Conditional compilation.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  131104  PRatlk PBFI-2101, Refactoring according to the new template
--  180510  Kgamlk Bug 140923, Merged App9 correction, Allowed inserting a Withholding tax code to a tax book of tax direction Disbursed, 
--  180510         Triggered an error if only tax direction Received tax book with Tax code All available when Withholding tax code entered.
--  180725  Waudlk Bug 142410, Removed validations for WHT tax codes.
--  191030  Kagalk GESPRING20-1261, Added changes for tax_book_and_numbering.
--  200701  Tkavlk  Bug 154601, Added Remove_Company
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT TAX_BOOK_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   IF (newrec_.tax_book_base_values = 'ALL' AND newrec_.tax_book_base = 'TAX_CODE') THEN
      Save_All(newrec_.company, newrec_.Tax_Book_Id);
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN TAX_BOOK_TAB%ROWTYPE )
IS
BEGIN
   IF Validate_Delete(remrec_.company, remrec_.tax_book_id) = 'FALSE' THEN
      Error_SYS.Appl_General(lu_name_, 'VIOLBOOKDEL: Cannot Delete Tax Book.Tax Book Id exists in tax transaction or used by a supplier or customer ');
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);   
   IF (newrec_.tax_book_base = 'TAX_CODE') THEN
      IF Validate_Insert(newrec_.company, newrec_.tax_book_base, newrec_.tax_book_base_values, newrec_.tax_direction_sp) = 'FALSE' THEN
         Error_SYS.Appl_General(lu_name_,'VIOLTAX: Tax Code can only be defined once for each tax direction');
      END IF;               
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     tax_book_tab%ROWTYPE,
   newrec_ IN OUT tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                VARCHAR2(30);
   value_               VARCHAR2(4000);
   exist_base_values_   VARCHAR2(20);
   exist_tax_direction_ VARCHAR2(200);
   -- gelr:tax_book_and_numbering, begin
   dummy_               NUMBER;
   show_error_          BOOLEAN := FALSE;
   field_name_          VARCHAR2(50);
   
   CURSOR get_invoice_types IS
      SELECT 1
      FROM   invoice_types_per_tax_book_tab t
      WHERE  t.company     = newrec_.company
      AND    t.tax_book_id = newrec_.tax_book_id;
      
   CURSOR get_invoice_series IS
      SELECT 1
      FROM   inv_series_per_tax_book_tab t
      WHERE  t.company     = newrec_.company
      AND    t.tax_book_id = newrec_.tax_book_id;   
      
   CURSOR get_tax_codes IS
      SELECT 1
      FROM   tax_code_per_tax_book_tab t
      WHERE  t.company     = newrec_.company
      AND    t.tax_book_id = newrec_.tax_book_id;  
   -- gelr:tax_book_and_numbering, end
   
BEGIN
   exist_base_values_ := Get_Tax_Book_Base_Values_Db(newrec_.Company, newrec_.tax_book_id);
   exist_tax_direction_ := Get_Tax_Direction_Sp_Db(newrec_.Company, newrec_.tax_book_id);
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.tax_book_base = 'TAX_CODE') THEN
      IF (exist_base_values_ != newrec_.tax_book_base_values) OR (exist_tax_direction_ != newrec_.tax_direction_sp) THEN
         IF Validate_Update(newrec_.company, newrec_.tax_book_id, newrec_.tax_book_base, newrec_.tax_book_base_values, newrec_.tax_direction_sp) = 'FALSE' THEN
            Error_SYS.Appl_General(lu_name_,'VIOLTAX: Tax Code can only be defined once for each tax direction');
         END IF;
      END IF;      
   END IF;
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'TAX_BOOK_AND_NUMBERING') = Fnd_Boolean_API.DB_TRUE) THEN
      IF (indrec_.tax_direction_sp) THEN 
         show_error_ := TRUE;
         field_name_ := 'Tax Direction';
      ELSIF (indrec_.tax_book_base) THEN 
         show_error_ := TRUE;
         field_name_ := 'Tax Book Base';      
      ELSIF (indrec_.tax_book_base_values) THEN 
         show_error_ := TRUE;
         field_name_ := 'Tax Book Base Values';
      END IF;
      
      IF (show_error_) THEN
         OPEN get_invoice_types;
         FETCH get_invoice_types INTO dummy_;
         IF get_invoice_types%FOUND THEN
            CLOSE get_invoice_types;
            Error_SYS.Record_General(lu_name_, 'CANNOTCHANGEDIR: Cannot change :P1 after defining Invoice Types.', field_name_);
         END IF;
         CLOSE get_invoice_types;

         OPEN get_invoice_series;
         FETCH get_invoice_series INTO dummy_;
         IF get_invoice_series%FOUND THEN
            CLOSE get_invoice_series;
            Error_SYS.Record_General(lu_name_, 'CANNOTCHANGEDIRIVSR: Cannot change :P1 after defining Invoice Series.', field_name_);
         END IF;
         CLOSE get_invoice_series;      

         OPEN get_tax_codes;
         FETCH get_tax_codes INTO dummy_;
         IF get_tax_codes%FOUND THEN
            CLOSE get_tax_codes;
            Error_SYS.Record_General(lu_name_, 'CANNOTCHANGEDIRTC: Cannot change :P1 after defining Tax Codes.', field_name_);
         END IF;
         CLOSE get_tax_codes;        
      END IF;
   END IF;
   -- gelr:tax_book_and_numbering, end   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     tax_book_tab%ROWTYPE,
   newrec_ IN OUT tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   -- gelr:tax_book_and_numbering, begin
   dummy_               NUMBER;
   
   CURSOR chk_book_base IS
      SELECT 1
      FROM   tax_book_tab
      WHERE  company               = newrec_.company
      AND    tax_direction_sp      = newrec_.tax_direction_sp
      AND    tax_book_base         = newrec_.tax_book_base
      AND    (tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL OR 
             (tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED AND newrec_.tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL))
      AND    tax_book_id          != newrec_.tax_book_id;
   -- gelr:tax_book_and_numbering, end
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'TAX_BOOK_AND_NUMBERING') = Fnd_Boolean_API.DB_TRUE) THEN      
      IF ((newrec_.tax_direction_sp = Tax_Direction_Sp_API.DB_DISBURSED_RECEIVED) AND ((newrec_.tax_book_base = Tax_Book_Base_API.DB_INVOICE_TYPE) OR (newrec_.tax_book_base = Tax_Book_Base_API.DB_INVOICE_SERIES))) THEN
         Error_SYS.Record_General(lu_name_, 'INVALIDTXBOOKINVTYPE: Tax Book with Tax Direction :P1 may not be connected to Tax Book Base :P2', Tax_Direction_Sp_API.Decode(newrec_.tax_direction_sp), Tax_Book_Base_API.Decode(newrec_.tax_book_base));
      END IF;
      
      IF (newrec_.tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL) THEN
         -- TaxBookBaseValues: All
         OPEN chk_book_base;
         FETCH chk_book_base INTO dummy_;
         IF (chk_book_base%FOUND) THEN
            CLOSE chk_book_base;
            Error_SYS.Record_General(lu_name_, 'TAXDIRTAXBOOKEXIST: A Tax Book defined for the same Tax Direction and Tax Book Base Values already exists.');
         END IF;
         CLOSE chk_book_base;
      ELSIF (newrec_.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED) THEN
         -- TaxBookBaseValues: Restricted
         OPEN chk_book_base;
         FETCH chk_book_base INTO dummy_;
         IF (chk_book_base%FOUND) THEN
            IF newrec_.tax_book_base = Tax_Book_Base_API.DB_TAX_CODE THEN
               -- TaxBookBase: Tax Code
               CLOSE chk_book_base;
               Error_SYS.Record_General(lu_name_, 'TAXCODEEXIST: A Tax Book with All Tax Codes already exists.');
            ELSIF newrec_.tax_book_base = Tax_Book_Base_API.DB_INVOICE_TYPE THEN
               -- TaxBookBase: Invoice Type
               CLOSE chk_book_base;
               Error_SYS.Record_General(lu_name_, 'INVTYPEEXIST: A Tax Book with All Invoice Types already exists.');
            END IF;   
         END IF;
         CLOSE chk_book_base;
      END IF;
   END IF;
   -- gelr:tax_book_and_numbering, end
END Check_Common___;


-- gelr:tax_book_and_numbering, begin
-- Get_Tax_Book_For_Tax_Code___
--    This method will return the tax book for the given tax code and direction
--    Used for TAX_BOOK_AND_NUMBERING localization functionality
FUNCTION Get_Tax_Book_For_Tax_Code___ (
   company_   IN VARCHAR2,
   vat_code_  IN VARCHAR2,
   direction_ IN VARCHAR2) RETURN VARCHAR2
IS
   tax_book_id_   tax_book_tab.tax_book_id%TYPE;
   
   CURSOR get_restricted_tax_book IS
      SELECT tb.tax_book_id
      FROM   tax_book_tab tb, tax_code_per_tax_book_tab tctb
      WHERE  tb.company              = tctb.company
      AND    tb.tax_book_id          = tctb.tax_book_id
      AND    tctb.company            = company_
      AND    tctb.fee_code           = vat_code_
      AND   (tb.tax_direction_sp     = direction_ OR tb.tax_direction_sp = Tax_Direction_Sp_API.DB_DISBURSED_RECEIVED)
      AND    tb.tax_book_base        = Tax_Book_Base_API.DB_TAX_CODE
      AND    tb.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED;
   
   CURSOR get_all_tax_book IS
      SELECT tax_book_id
      FROM   tax_book_tab
      WHERE  company              = company_
      AND   (tax_direction_sp     = direction_ OR tax_direction_sp = Tax_Direction_Sp_API.DB_DISBURSED_RECEIVED)
      AND    tax_book_base        = Tax_Book_Base_API.DB_TAX_CODE
      AND    tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL;       
BEGIN   
   -- Fetch restricted tax book with the tax code
    OPEN get_restricted_tax_book;
    FETCH get_restricted_tax_book INTO  tax_book_id_;
    CLOSE get_restricted_tax_book;
    IF (tax_book_id_ IS NULL) THEN
       -- Fetch tax book with All tax codes
       OPEN get_all_tax_book;
       FETCH get_all_tax_book INTO tax_book_id_;
       CLOSE get_all_tax_book;
    END IF;
    RETURN tax_book_id_;      
END Get_Tax_Book_For_Tax_Code___;

-- Get_Tax_Book_For_Inv_Type___
--    This method will return the tax book for the given invoice type, party type and direction
--    Used for TAX_BOOK_AND_NUMBERING localization functionality
FUNCTION Get_Tax_Book_For_Inv_Type___ (
   company_      IN VARCHAR2,
   party_type_   IN VARCHAR2,
   invoice_type_ IN VARCHAR2,
   direction_    IN VARCHAR2) RETURN VARCHAR2
IS
   tax_book_id_   tax_book_tab.tax_book_id%TYPE;
   
   CURSOR get_restricted_invoice_type IS
      SELECT tb.tax_book_id
      FROM   tax_book_tab tb, invoice_types_per_tax_book_tab ittb
      WHERE  tb.company              = ittb.company
      AND    tb.tax_book_id          = ittb.tax_book_id
      AND    ittb.company            = company_
      AND    ittb.party_type         = party_type_
      AND    ittb.type_id            = invoice_type_
      AND    tb.tax_direction_sp     = direction_
      AND    tb.tax_book_base        = Tax_Book_Base_API.DB_INVOICE_TYPE
      AND    tb.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED;
   
   CURSOR get_all_invoice_type IS
      SELECT tax_book_id
      FROM   tax_book_tab
      WHERE  company              = company_
      AND    tax_direction_sp     = direction_
      AND    tax_book_base        = Tax_Book_Base_API.DB_INVOICE_TYPE
      AND    tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL;   
BEGIN
   -- Fetch restricted tax book with the tax code
   OPEN get_restricted_invoice_type;
   FETCH get_restricted_invoice_type INTO  tax_book_id_;
   CLOSE get_restricted_invoice_type;
   IF (tax_book_id_ IS NULL) THEN
      -- Fetch tax book with All tax codes
      OPEN get_all_invoice_type;
      FETCH get_all_invoice_type INTO tax_book_id_;
      CLOSE get_all_invoice_type;
   END IF;
   RETURN tax_book_id_;
END Get_Tax_Book_For_Inv_Type___;

-- Note: Use the next Get_Tax_Book_For_Inv_Series___ method instead
@Deprecated
FUNCTION Get_Tax_Book_For_Inv_Series___ (
   company_       IN VARCHAR2,
   party_type_    IN VARCHAR2,
   invoice_type_  IN VARCHAR2,
   inv_series_id_ IN VARCHAR2,
   direction_     IN VARCHAR2) RETURN VARCHAR2
IS
   tax_book_id_   tax_book_tab.tax_book_id%TYPE;
   series_id_     inv_series_per_tax_book_tab.series_id%TYPE;
   
   CURSOR get_restricted_invoice_series IS
      SELECT tb.tax_book_id
      FROM   tax_book_tab tb, inv_series_per_tax_book_tab ittb
      WHERE  tb.company              = ittb.company
      AND    tb.tax_book_id          = ittb.tax_book_id
      AND    ittb.company            = company_
      AND    ittb.series_id          = series_id_
      AND    tb.tax_direction_sp     = direction_
      AND    tb.tax_book_base        = Tax_Book_Base_API.DB_INVOICE_SERIES
      AND    tb.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED;
   
   CURSOR get_all_invoice_series IS
      SELECT tax_book_id
      FROM   tax_book_tab
      WHERE  company              = company_
      AND    tax_direction_sp     = direction_
      AND    tax_book_base        = Tax_Book_Base_API.DB_INVOICE_SERIES
      AND    tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL;   
BEGIN
   series_id_ := inv_series_id_;
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (invoice_type_ = Company_Def_Invoice_Type_API.Get_Def_Instant_Inv_Type(company_)) THEN
         series_id_ := Invoice_Type_API.Get_Series_Id(company_, Party_Type_API.Decode(party_type_), invoice_type_);
      END IF;
   $END
   -- Fetch restricted tax book with the tax code
   OPEN get_restricted_invoice_series;
   FETCH get_restricted_invoice_series INTO  tax_book_id_;
   CLOSE get_restricted_invoice_series;
   IF (tax_book_id_ IS NULL) THEN
      -- Fetch tax book with All tax codes
      OPEN get_all_invoice_series;
      FETCH get_all_invoice_series INTO tax_book_id_;
      CLOSE get_all_invoice_series;
   END IF;
   RETURN tax_book_id_;
END Get_Tax_Book_For_Inv_Series___;


-- Get_Tax_Book_For_Inv_Series___
--    This method will return the tax book for the given invoice series and direction
--    Used for TAX_BOOK_AND_NUMBERING localization functionality
FUNCTION Get_Tax_Book_For_Inv_Series___ (
   company_       IN VARCHAR2,   
   inv_series_id_ IN VARCHAR2,
   direction_     IN VARCHAR2) RETURN VARCHAR2
IS
   tax_book_id_   tax_book_tab.tax_book_id%TYPE;
   
   CURSOR get_restricted_invoice_series IS
      SELECT tb.tax_book_id
      FROM   tax_book_tab tb, inv_series_per_tax_book_tab ittb
      WHERE  tb.company              = ittb.company
      AND    tb.tax_book_id          = ittb.tax_book_id
      AND    ittb.company            = company_
      AND    ittb.series_id          = inv_series_id_
      AND    tb.tax_direction_sp     = direction_
      AND    tb.tax_book_base        = Tax_Book_Base_API.DB_INVOICE_SERIES
      AND    tb.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED;
   
   CURSOR get_all_invoice_series IS
      SELECT tax_book_id
      FROM   tax_book_tab
      WHERE  company              = company_
      AND    tax_direction_sp     = direction_
      AND    tax_book_base        = Tax_Book_Base_API.DB_INVOICE_SERIES
      AND    tax_book_base_values = Tax_Book_Base_Values_API.DB_ALL;   
BEGIN
   -- Fetch restricted tax book with the tax code
   OPEN get_restricted_invoice_series;
   FETCH get_restricted_invoice_series INTO  tax_book_id_;
   CLOSE get_restricted_invoice_series;
   IF (tax_book_id_ IS NULL) THEN
      -- Fetch tax book with All tax codes
      OPEN get_all_invoice_series;
      FETCH get_all_invoice_series INTO tax_book_id_;
      CLOSE get_all_invoice_series;
   END IF;
   RETURN tax_book_id_;
END Get_Tax_Book_For_Inv_Series___;


-- Get_Tax_Book_Info___
--    This method will return the valid tax book, tax series and tax series no
--    Used for TAX_BOOK_AND_NUMBERING localization functionality
PROCEDURE Get_Tax_Book_Info___ (
   tax_book_id_      OUT VARCHAR2,
   tax_series_id_    OUT VARCHAR2,
   tax_series_no_    OUT NUMBER,   
   company_          IN  VARCHAR2,
   fee_code_         IN  VARCHAR2,
   tax_trans_date_   IN  DATE,   
   party_type_       IN  VARCHAR2,
   invoice_type_     IN  VARCHAR2,
   direction_        IN  VARCHAR2,
   inv_series_id_    IN  VARCHAR2,   
   invoice_id_       IN  NUMBER,    
   ref_item_id_      IN  NUMBER )
IS
BEGIN
   -- Fetch the applicable tax book
   tax_book_id_ := Get_Tax_Book_For_Tax_Code___(company_, fee_code_, direction_);
   IF (tax_book_id_ IS NULL) THEN
      tax_book_id_ := Get_Tax_Book_For_Inv_Type___(company_, party_type_, invoice_type_, direction_);
   END IF;
   IF (tax_book_id_ IS NULL) THEN
      tax_book_id_ := Get_Tax_Book_For_Inv_Series___(company_, inv_series_id_, direction_);
   END IF;

   -- Fetch the applicable tax series
   IF (tax_book_id_ IS NOT NULL) THEN
      tax_series_id_ := Get_Tax_Series_Id(company_, tax_book_id_);
      IF (tax_series_id_ IS NULL) THEN
         Error_SYS.Record_General(lu_name_, 'NOTAXSERIES: Tax Book does not have a Tax Series.');
      END IF;
   END IF;
   -- Fetch the next tax series no
   $IF Component_Taxled_SYS.INSTALLED $THEN
      IF (ref_item_id_ IS NULL) THEN         
         tax_series_no_ := Tax_Number_Series_API.Get_Next_Number(company_, tax_series_id_, tax_trans_date_);         
      ELSE 
         $IF Component_Invoic_SYS.INSTALLED $THEN
            IF (Tax_Book_API.Exists(company_, tax_book_id_)) THEN
               tax_series_no_ := Invoice_Item_API.Get_Tax_Series_No(company_, invoice_id_, ref_item_id_);               
            END IF;   
         $ELSE 
            NULL;
         $END
      END IF;      
   $END

   IF (tax_series_no_ IS NULL) THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDTAXBOOK: Tax code :P1 does not exist in a valid Tax Book.', fee_code_);
   END IF;
END Get_Tax_Book_Info___;


FUNCTION Get_Tax_Book_Series_Id___ (
   def_tax_book_     IN VARCHAR2,
   company_          IN VARCHAR2,   
   party_type_       IN VARCHAR2,
   invoice_type_     IN VARCHAR2,
   fee_code_         IN VARCHAR2,
   inv_series_id_    IN VARCHAR2,
   direction_        IN VARCHAR2 ) RETURN VARCHAR2
IS
   tax_book_id_     tax_book_tab.tax_book_id%TYPE;
   tax_series_id_   tax_book_tab.tax_series_id%TYPE;
BEGIN
   IF (def_tax_book_ IS NOT NULL) THEN
      -- Fetch the applicable tax book
      tax_book_id_ := Get_Tax_Book_For_Tax_Code___(company_, fee_code_, direction_);
      IF (tax_book_id_ IS NULL) THEN
         tax_book_id_ := Get_Tax_Book_For_Inv_Type___(company_, party_type_, invoice_type_, direction_);
      END IF;
      IF (tax_book_id_ IS NULL) THEN
         tax_book_id_ := Get_Tax_Book_For_Inv_Series___(company_, inv_series_id_, direction_);
      END IF;

      -- Fetch the applicable tax series
      IF (tax_book_id_ IS NOT NULL) THEN
         tax_series_id_ := Get_Tax_Series_Id(company_, tax_book_id_);
         IF (tax_series_id_ IS NULL) THEN
            Error_SYS.Record_General(lu_name_, 'NOTAXSERIES: Tax Book does not have a Tax Series.');
         END IF;
      END IF;
   END IF;
   RETURN tax_series_id_;
END Get_Tax_Book_Series_Id___;
-- gelr:tax_book_and_numbering, end

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Validate_Insert (
   company_              IN VARCHAR2,   
   tax_book_base_        IN VARCHAR2,
   tax_book_base_values_ IN VARCHAR2,
   tax_direction_sp_     IN VARCHAR2 ) RETURN VARCHAR2
IS

   CURSOR cur_rd_type(company_ VARCHAR2, tax_direction_ VARCHAR2, tax_book_base_values_ VARCHAR2) IS
      SELECT count(*)
        FROM Tax_Book_Tab
       WHERE Company = company_
         AND tax_book_base = tax_book_base_
         AND tax_book_base_values = tax_book_base_values_
         AND (Tax_Direction_Sp = 'DISBURSEDRECEIVED'
          OR Tax_Direction_Sp = tax_direction_);

   CURSOR cur_rdb_type(company_ VARCHAR2, tax_book_base_values_ VARCHAR2) IS
      SELECT count(*)
        FROM Tax_Book_Tab
       WHERE Company = company_
         AND tax_book_base = tax_book_base_
         AND tax_book_base_values = tax_book_base_values_
         AND (Tax_Direction_Sp = 'DISBURSEDRECEIVED'
          OR Tax_Direction_Sp = 'RECEIVED'
          OR Tax_Direction_Sp = 'DISBURSED');

   no_of_taxcode_ NUMBER := 0;
   false_         VARCHAR2(10):= 'FALSE';
   true_          VARCHAR2(10):= 'TRUE';

BEGIN
   IF tax_book_base_values_ = 'ALL' THEN
      IF (tax_direction_sp_ = 'RECEIVED') OR (tax_direction_sp_ = 'DISBURSED') THEN
         OPEN cur_rd_type(company_, tax_direction_sp_, 'ALL');
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
         no_of_taxcode_ := 0;
         OPEN cur_rd_type(company_, tax_direction_sp_, 'RESTRICTED');
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      ELSIF tax_direction_sp_ = 'DISBURSEDRECEIVED' THEN
         OPEN cur_rdb_type(company_, 'ALL');
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
         no_of_taxcode_ := 0;
         OPEN cur_rdb_type(company_, 'RESTRICTED');
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      END IF;
   ELSIF tax_book_base_values_ ='RESTRICTED' THEN
      IF (tax_direction_sp_ = 'RECEIVED') OR (tax_direction_sp_ = 'DISBURSED') THEN
         OPEN cur_rd_type(company_, tax_direction_sp_, 'ALL');
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      ELSIF tax_direction_sp_ = 'DISBURSEDRECEIVED' THEN
         OPEN cur_rdb_type(company_, 'ALL');
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      END IF;
   END IF;

   RETURN true_;

END Validate_Insert;


FUNCTION Validate_Update (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2,
   tax_book_base_        IN VARCHAR2,
   tax_book_base_values_ IN VARCHAR2,
   tax_direction_sp_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR cur_rd_type(company_ VARCHAR2, tax_direction_ VARCHAR2, tax_book_base_values_ VARCHAR2, tax_book_id_ VARCHAR2) IS
      SELECT count(*)
        FROM Tax_Book_Tab
       WHERE Company = company_
         AND tax_book_base = tax_book_base_
         AND tax_book_base_values = tax_book_base_values_
         AND Tax_Book_Id != tax_book_id_
         AND (Tax_Direction_Sp = 'DISBURSEDRECEIVED'
          OR Tax_Direction_Sp = tax_direction_);

   CURSOR cur_rdb_type(company_ VARCHAR2, tax_book_base_values_ VARCHAR2, tax_book_id_ VARCHAR2) IS
      SELECT count(*)
        FROM Tax_Book_Tab
        WHERE Company = company_
          AND tax_book_base = tax_book_base_
          AND tax_book_base_values = tax_book_base_values_
          AND Tax_Book_Id != tax_book_id_
          AND (Tax_Direction_Sp = 'DISBURSEDRECEIVED'
           OR Tax_Direction_Sp = 'RECEIVED'
           OR Tax_Direction_Sp = 'DISBURSED');

   CURSOR cur_fee_code(company_ VARCHAR2, tax_book_id_ VARCHAR2) IS
      SELECT fee_code
      FROM  Tax_code_per_tax_book_tab
      WHERE company = company_
      AND   tax_book_id = tax_book_id_;

   no_of_taxcode_       NUMBER:= 0;
   false_               VARCHAR2(10):= 'FALSE';
   true_                VARCHAR2(10):= 'TRUE';
   exist_base_values_   VARCHAR2(20);

BEGIN
   IF tax_book_base_values_ = 'ALL' THEN
      IF (tax_direction_sp_ = 'RECEIVED') OR (tax_direction_sp_ = 'DISBURSED') THEN
         OPEN cur_rd_type(company_, tax_direction_sp_, 'ALL', tax_book_id_);
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
         no_of_taxcode_ := 0;
         OPEN cur_rd_type(company_, tax_direction_sp_, 'RESTRICTED', tax_book_id_);
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      ELSIF tax_direction_sp_ = 'DISBURSEDRECEIVED' THEN
         OPEN cur_rdb_type(company_, 'ALL', tax_book_id_);
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
         no_of_taxcode_ := 0;
         OPEN cur_rdb_type(company_, 'RESTRICTED', tax_book_id_);
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      END IF;
   ELSIF tax_book_base_values_ ='RESTRICTED' THEN
      IF (tax_direction_sp_ = 'RECEIVED') OR (tax_direction_sp_ = 'DISBURSED') THEN
         OPEN cur_rd_type(company_, tax_direction_sp_, 'ALL', tax_book_id_);
         FETCH cur_rd_type INTO no_of_taxcode_;
         CLOSE cur_rd_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      ELSIF tax_direction_sp_ = 'DISBURSEDRECEIVED' THEN
         OPEN cur_rdb_type(company_, 'ALL', tax_book_id_);
         FETCH cur_rdb_type INTO no_of_taxcode_;
         CLOSE cur_rdb_type;
         IF no_of_taxcode_ > 0 THEN
            RETURN false_;
         END IF;
      END IF;
   END IF;
   exist_base_values_ := Tax_Book_API.Get_Tax_Book_Base_Values_Db(company_, tax_book_id_);
   IF exist_base_values_ = 'RESTRICTED' AND tax_book_base_values_ = 'RESTRICTED' THEN
      FOR cur_rec IN cur_fee_code(company_, tax_book_id_) LOOP
         IF Tax_code_per_tax_book_API.Validate_Insert(company_, cur_rec.fee_code, tax_book_base_values_, tax_direction_sp_) = 'FALSE' THEN
            RETURN false_;
         END IF;
      END LOOP;
   END IF;
   IF exist_base_values_ = 'RESTRICTED' AND tax_book_base_values_ = 'ALL' THEN
      Tax_code_per_tax_book_API.Remove_Rec(company_, tax_book_id_);
      Save_All(company_, tax_book_id_);
   ELSIF exist_base_values_ = 'ALL' AND tax_book_base_values_ = 'RESTRICTED' THEN
      Tax_code_per_tax_book_API.Remove_Rec(company_, tax_book_id_);
   END IF;
   RETURN true_;
END Validate_Update;


FUNCTION Validate_Delete (
   company_     IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   $IF Component_Taxled_SYS.INSTALLED $THEN
       IF (Tax_Ledger_Item_API.Check_Book_Exist(company_, tax_book_id_) = 'TRUE') THEN
          RETURN 'FALSE';
       END IF;
   $ELSIF Component_Invoic_SYS.INSTALLED $THEN      
       IF (Identity_Invoice_Info_API.Check_Book_Sup(company_, tax_book_id_) = 'TRUE') THEN
           RETURN 'FALSE';
       ELSIF (Customer_Delivery_Tax_Info_API.Check_Book_Cus(company_, tax_book_id_) = 'TRUE') THEN
           RETURN 'FALSE';  
       END IF;
   $END
   RETURN 'TRUE'; 
END Validate_Delete;

@UncheckedAccess
FUNCTION Check_Restricted (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR cur_rest_rec(company_ VARCHAR2) IS
      SELECT tax_book_id
      FROM Tax_book_tab
      WHERE company = company_
      AND tax_book_base_values = 'RESTRICTED';

   false_ VARCHAR2(10) := 'FALSE';
   true_  VARCHAR2(10) := 'TRUE';
BEGIN
   FOR cur_rec IN cur_rest_rec(company_) LOOP
      IF Tax_code_per_tax_book_API.check_exists(company_, cur_rec.tax_book_id) = 'FALSE' THEN
         RETURN false_;
      END IF;
   END LOOP;
   RETURN true_;
END Check_Restricted;

FUNCTION Check_Exist (
   company_          IN VARCHAR2,
   tax_book_id_      IN VARCHAR2,
   tax_direction_sp_ IN VARCHAR2 ) RETURN BOOLEAN
IS
dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
        FROM   TAX_BOOK_TAB
       WHERE company = company_
         AND   tax_book_id = tax_book_id_
         AND   (tax_direction_sp = tax_direction_sp_ OR tax_direction_sp = 'DISBURSEDRECEIVED');
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      RETURN(FALSE);
   END IF;
   CLOSE exist_control;
   RETURN(TRUE);
END Check_Exist;


FUNCTION Exists_Str (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(company_, tax_book_id_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Exists_Str;


@UncheckedAccess
FUNCTION Get_Structure_Id (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ TAX_BOOK_LOV.tax_struct_id%TYPE;
   CURSOR get_attr IS
      SELECT tax_struct_id
      FROM TAX_BOOK_LOV
      WHERE company = company_
      AND  (tax_book_id = tax_book_id_ OR node_id = tax_book_id_);
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Structure_Id;




@UncheckedAccess
FUNCTION Get_Tax_Ref_Desc (
   company_          IN VARCHAR2,
   tax_book_id_      IN VARCHAR2,
   tax_structure_id_ IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
   temp_ TAX_BOOK_LOV.description%TYPE;
   node_temp_  TAX_BOOK_LOV.node_description%TYPE;
   
   CURSOR get_attr IS
      SELECT description
      FROM TAX_BOOK_LOV
      WHERE company = company_
      AND   tax_book_id = tax_book_id_;
      
   CURSOR get_node_attr IS
      SELECT node_description
      FROM TAX_BOOK_LOV
      WHERE company = company_
      AND   node_id = tax_book_id_
      AND   tax_struct_id = tax_structure_id_;   
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   IF (temp_ IS NULL) THEN
      OPEN get_node_attr;
      FETCH get_node_attr INTO node_temp_;
      CLOSE get_node_attr;
      RETURN node_temp_;
   ELSE   
      RETURN temp_;
   END IF;
END Get_Tax_Ref_Desc;


PROCEDURE New_Fee_Code (
   company_ IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
   CURSOR cur_tax_book IS
      SELECT Tax_Book_Id
      FROM Tax_Book_Tab
      WHERE Company = company_
      AND tax_book_base_values = 'ALL';
      
   
BEGIN
   FOR cur_rec IN cur_tax_book LOOP
      Tax_Code_Per_Tax_Book_API.New_Rec(company_, cur_rec.Tax_Book_Id, fee_code_);
   END LOOP;
END New_Fee_Code;


PROCEDURE Save_All (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 )
IS
   CURSOR cur_fee_code_deduct(company_ VARCHAR2) IS
      SELECT fee_code, fee_type_db
      FROM statutory_fee
      WHERE company = company_;
BEGIN  
   FOR cur_rec IN cur_fee_code_deduct(company_) LOOP
      Tax_Code_Per_Tax_Book_API.New_Rec(company_, tax_book_id_, cur_rec.fee_code);
   END LOOP;
END Save_All;


PROCEDURE Tax_Book_Ref_Exist (
   company_       IN VARCHAR2,
   tax_book_id_   IN VARCHAR2,
   party_type_db_ IN VARCHAR2 )
IS

   CURSOR exist_tax_book_ref IS
      SELECT 1
        FROM TAX_BOOK_LOV
       WHERE company = company_
         AND (tax_book_id = tax_book_id_ OR node_id = tax_book_id_)
         AND (party_type_db = party_type_db_ OR party_type_db IS NULL);

   dummy_          NUMBER;
   party_type_     VARCHAR2(200);

BEGIN
   party_type_ := Party_Type_API.Decode (party_type_db_);
   OPEN  exist_tax_book_ref;
   FETCH exist_tax_book_ref INTO dummy_;
   IF (exist_tax_book_ref%NOTFOUND) THEN
      Error_SYS.Record_General(lu_name_,'TAXBOOKREFNOTEXIST: Tax Book :P1 does not exist or can not be connected to :P2', tax_book_id_, party_type_);
   END IF;
   CLOSE exist_tax_book_ref;
END Tax_Book_Ref_Exist;


-- gelr:tax_book_and_numbering, begin
-- Get_Tax_Book_Info
--    This method will return the valid tax book, tax series and tax series no
--    Used for TAX_BOOK_AND_NUMBERING localization functionality
PROCEDURE Get_Tax_Book_Info (
   tax_book_id_         OUT VARCHAR2,
   tax_series_id_       OUT VARCHAR2,
   tax_series_no_       OUT NUMBER,
   ip10_tax_book_id_    OUT VARCHAR2,
   ip10_tax_series_id_  OUT VARCHAR2,
   ip10_tax_series_no_  OUT NUMBER,
   company_             IN  VARCHAR2,
   fee_code_            IN  VARCHAR2,
   tax_trans_date_      IN  DATE,
   def_tax_book_        IN  VARCHAR2,
   party_type_          IN  VARCHAR2,
   invoice_type_        IN  VARCHAR2,
   direction_           IN  VARCHAR2,
   inv_series_id_       IN  VARCHAR2 DEFAULT NULL,   
   invoice_id_          IN  NUMBER   DEFAULT NULL,
   ref_item_id_         IN  NUMBER   DEFAULT NULL )
IS
   tax_rec_                 Statutory_Fee_API.Public_Rec;   
BEGIN
   IF (party_type_ IS NOT NULL AND def_tax_book_ IS NULL) THEN
      IF (direction_ = Tax_Direction_Sp_API.DB_DISBURSED) THEN
         Error_SYS.Record_General(lu_name_, 'NOCUSTAXBOOK: Customer does not have a default Tax Book.');
      ELSIF (direction_ = Tax_Direction_Sp_API.DB_RECEIVED) THEN
         Error_SYS.Record_General(lu_name_, 'NOSUPTAXBOOK: Supplier does not have a default Tax Book.');
      END IF;
   END IF;   

   Get_Tax_Book_Info___(tax_book_id_, tax_series_id_, tax_series_no_, company_, fee_code_, tax_trans_date_, party_type_, invoice_type_, direction_ , inv_series_id_, invoice_id_, ref_item_id_);
   
   tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec (company_, fee_code_, SYSDATE, 'FALSE', 'FALSE', 'FETCH_AND_VALIDATE');   
   IF (tax_rec_.fee_type = Fee_Type_API.DB_CALCULATED_TAX AND party_type_ = Party_Type_API.DB_SUPPLIER) THEN
      Get_Tax_Book_Info___(ip10_tax_book_id_, ip10_tax_series_id_, ip10_tax_series_no_, company_, fee_code_, tax_trans_date_, party_type_, invoice_type_, Tax_Direction_Sp_API.DB_DISBURSED, inv_series_id_, invoice_id_, ref_item_id_);
   END IF;            
END Get_Tax_Book_Info;

PROCEDURE Get_Applicable_Tax_Series_Id (
   tax_series_id_    OUT VARCHAR2,
   ip10_tax_series_id_ OUT VARCHAR2,
   company_          IN  VARCHAR2,
   identity_         IN  VARCHAR2,
   party_type_       IN  VARCHAR2,
   invoice_type_     IN  VARCHAR2,
   fee_code_         IN  VARCHAR2,
   inv_series_id_    IN  VARCHAR2 )
IS
   def_tax_book_    tax_book_tab.tax_book_id%TYPE;
   direction_       tax_book_tab.tax_direction_sp%TYPE;
   tax_rec_         Statutory_Fee_API.Public_Rec;   
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (party_type_ = Party_Type_API.DB_SUPPLIER) THEN
         def_tax_book_ := Identity_Invoice_Info_API.Get_Book_Id_Sup(company_, identity_);
         direction_    := Tax_Direction_Sp_API.DB_RECEIVED;
      ELSE
         def_tax_book_ := Customer_Delivery_Tax_Info_API.Get_Book_Id_Cus(company_, identity_);
         direction_    := Tax_Direction_Sp_API.DB_DISBURSED;
      END IF;
      tax_series_id_ := Get_Tax_Book_Series_Id___(def_tax_book_, company_, party_type_ , invoice_type_, fee_code_ , inv_series_id_, direction_);
      IF (party_type_ = Party_Type_API.DB_SUPPLIER) THEN
         tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec (company_, fee_code_, SYSDATE, 'FALSE', 'FALSE', 'FETCH_AND_VALIDATE');
         IF (tax_rec_.fee_type = Fee_Type_API.DB_CALCULATED_TAX) THEN
            ip10_tax_series_id_ := Get_Tax_Book_Series_Id___(def_tax_book_, company_, party_type_ , invoice_type_, fee_code_ , inv_series_id_, Tax_Direction_Sp_API.DB_DISBURSED);
         END IF;
      END IF;
   $ELSE
      NULL;
   $END
END Get_Applicable_Tax_Series_Id;
-- gelr:tax_book_and_numbering, end


-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_   IN VARCHAR2)
IS
BEGIN
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN 
      DELETE 
      FROM TAX_CODE_PER_TAX_BOOK_TAB
      WHERE company = company_; 
      DELETE 
      FROM TAX_BOOK_TAB
      WHERE company = company_;
   END IF;      
END Remove_Company;

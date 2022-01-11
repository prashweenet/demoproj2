-----------------------------------------------------------------------------
--
--  Logical unit: SupplierDeliveryTaxCode
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  161003  reanpl  FINHR-3451, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT supplier_delivery_tax_code_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, 'COMMON', newrec_.tax_code, 'ALL', SYSDATE);   
   IF (Supplier_Tax_Info_API.Get_Tax_Calc_Structure_Id(newrec_.supplier_id, newrec_.address_id, newrec_.company) IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_, 'SUPPTAXSTRTAXCODEEXIST: When specifying tax information for supplier you can either enter structure in Tax Calculation Structure field or one or more tax codes in Tax Code column. Please clear Tax Calculation Structure field or remove Tax Codes.');      
   END IF;
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Tax_Codes_Exist (
   supplier_id_       IN VARCHAR2,
   address_id_        IN VARCHAR2,
   company_           IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_  NUMBER;  
   CURSOR check_exist IS
      SELECT 1
      FROM   supplier_delivery_tax_code_tab
      WHERE  supplier_id = supplier_id_
      AND    address_id  = address_id_
      AND    company     = company_;
BEGIN
   OPEN check_exist;
   FETCH check_exist INTO dummy_;
   IF (check_exist%FOUND) THEN
      CLOSE check_exist;
      RETURN 'TRUE';
   END IF;   
   CLOSE check_exist;
   RETURN 'FALSE';
END Check_Tax_Codes_Exist;  


PROCEDURE Copy_Supplier (
   supplier_id_ IN VARCHAR2,
   new_id_      IN VARCHAR2,
   company_     IN VARCHAR2 )
IS
   oldrec_  supplier_delivery_tax_code_tab%ROWTYPE;
   newrec_  supplier_delivery_tax_code_tab%ROWTYPE;
   CURSOR get_attr IS
      SELECT *
      FROM   supplier_delivery_tax_code_tab
      WHERE  supplier_id = supplier_id_ 
      AND    company     = NVL(company_, company);
BEGIN
   FOR rec_ IN get_attr LOOP
      oldrec_ := Lock_By_Keys___(supplier_id_, rec_.address_id, rec_.company, rec_.tax_code);
      newrec_ := oldrec_;
      newrec_.supplier_id := new_id_;
      New___(newrec_);
   END LOOP;
END Copy_Supplier;


PROCEDURE Fetch_Tax_Codes_On_Supp_Addr (
   tax_info_table_         OUT Tax_Handling_Util_API.tax_information_table,
   tax_calc_structure_id_  OUT VARCHAR2,
   company_                IN  VARCHAR2,
   supplier_id_            IN  VARCHAR2,
   delivery_address_id_    IN  VARCHAR2 ) 
IS
   index_  NUMBER := 0;
   CURSOR get_supplier_tax_codes IS
      SELECT tax_code
      FROM   supplier_delivery_tax_code_tab
      WHERE  company     = company_
      AND    supplier_id = supplier_id_
      AND    address_id  = delivery_address_id_;     
BEGIN
   tax_calc_structure_id_ := Supplier_Tax_Info_API.Get_Tax_Calc_Structure_Id(supplier_id_, delivery_address_id_, company_);
   IF (tax_calc_structure_id_ IS NULL) THEN
      FOR rec_ IN get_supplier_tax_codes LOOP
         index_ := index_ + 1;
         tax_info_table_(index_).tax_code := rec_.tax_code;
      END LOOP;
   END IF;   
END Fetch_Tax_Codes_On_Supp_Addr;

-------------------- LU  NEW METHODS -------------------------------------

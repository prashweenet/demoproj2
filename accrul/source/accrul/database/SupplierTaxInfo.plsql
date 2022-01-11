-----------------------------------------------------------------------------
--
--  Logical unit: SupplierTaxInfo
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
PROCEDURE Check_Tax_Calc_Struct_Ref___ (
   newrec_ IN OUT NOCOPY supplier_tax_info_tab%ROWTYPE )
IS
BEGIN
   Tax_Calc_Structure_API.Validate_Tax_Structure_State(newrec_.company, newrec_.tax_calc_structure_id);
END Check_Tax_Calc_Struct_Ref___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   default_company_ VARCHAR2(20);
BEGIN
   
   super(attr_);
   Client_SYS.Add_To_Attr('USE_SUPP_ADDRESS_FOR_TAX_DB', 'TRUE', attr_);
   User_Finance_API.Get_Default_Company(default_company_); 
   Client_SYS.Add_To_Attr('COMPANY', default_company_, attr_);
END Prepare_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     supplier_tax_info_tab%ROWTYPE,
   newrec_ IN OUT supplier_tax_info_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Supplier_Info_Address_Type_API.Exist(newrec_.supplier_id, newrec_.address_id, Address_Type_Code_API.Decode('DELIVERY'));
   IF (newrec_.tax_calc_structure_id IS NOT NULL) THEN 
      IF (Supplier_Delivery_Tax_Code_API.Check_Tax_Codes_Exist(newrec_.supplier_id, newrec_.address_id, newrec_.company) = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_, 'SUPPTAXSTRTAXCODEEXIST: When specifying tax information for supplier you can either enter structure in Tax Calculation Structure field or one or more tax codes in Tax Code column. Please clear Tax Calculation Structure field or remove Tax Codes.');
      END IF;
      Tax_Structure_Item_API.Check_Valid_Tax_Structure(newrec_.company, newrec_.tax_calc_structure_id, SYSDATE);      
   END IF;   
END Check_Common___;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Copy_Supplier (
   supplier_id_ IN VARCHAR2,
   new_id_      IN VARCHAR2,
   company_     IN VARCHAR2 )
IS
   oldrec_  supplier_tax_info_tab%ROWTYPE;
   newrec_  supplier_tax_info_tab%ROWTYPE;
   CURSOR get_attr IS
      SELECT *
      FROM   supplier_tax_info_tab
      WHERE  supplier_id = supplier_id_ 
      AND    company     = NVL(company_, company);
BEGIN
   IF (Supplier_Info_General_API.Get_One_Time_Db(supplier_id_) = 'FALSE') THEN      
      FOR rec_ IN get_attr LOOP
         oldrec_ := Lock_By_Keys___(supplier_id_, rec_.address_id, rec_.company);
         newrec_ := oldrec_;
         newrec_.supplier_id := new_id_;
         New___(newrec_);      
      END LOOP;
      Supplier_Delivery_Tax_Code_API.Copy_Supplier(supplier_id_, new_id_, company_);
   END IF;
END Copy_Supplier;


@UncheckedAccess
FUNCTION Tax_Calc_Structure_Used (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_   NUMBER := 0;
   CURSOR check_exist IS
      SELECT 1
      FROM   supplier_tax_info_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_;
BEGIN
   OPEN  check_exist;
   FETCH check_exist INTO dummy_;
   IF (check_exist%FOUND) THEN      
      CLOSE check_exist;
      RETURN TRUE;
   ELSE
      CLOSE check_exist;
      RETURN FALSE;
   END IF;
END Tax_Calc_Structure_Used;

-------------------- LU  NEW METHODS -------------------------------------

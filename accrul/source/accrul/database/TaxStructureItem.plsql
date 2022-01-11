-----------------------------------------------------------------------------
--
--  Logical unit: TaxStructureItem
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  160714  reanpl  FINHR-2559, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------
         
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN tax_structure_item_tab%ROWTYPE )
IS
   pub_rec_    Tax_Calc_Structure_API.Public_Rec;   
BEGIN
   pub_rec_ := Tax_Calc_Structure_API.Get(remrec_.company, remrec_.tax_calc_structure_id);
   IF (pub_rec_.rowstate != 'Preliminary') THEN
      Error_SYS.Appl_General(lu_name_,'TAXSTRITEMCHECKDEL: It is only allowed to delete items in status Preliminary.');
   END IF;   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('INCL_PRICE_IN_TAX_BASE_DB', 'TRUE', attr_);   
END Prepare_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     tax_structure_item_tab%ROWTYPE,
   newrec_ IN OUT tax_structure_item_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (indrec_.calculation_order) THEN
      IF (newrec_.calculation_order <= 0) THEN
         Error_SYS.Record_General(lu_name_, 'WRONGCALCORDER: Calculation Order must be positive.');       
      END IF;         
   END IF;   
   IF (indrec_.tax_code) THEN
      Tax_Handling_Util_API.Validate_Tax_In_Structure(newrec_.company, newrec_.tax_code, SYSDATE);
   END IF;
   -- gelr: extend_tax_code_and_tax_struct, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'EXTEND_TAX_CODE_AND_TAX_STRUCT') = 'TRUE' AND newrec_.mark_up <= -100) THEN
      Error_SYS.Appl_General(lu_name_, 'INVALMARKUP: The markup value must be greater than -100.');
   END IF;
   -- gelr: extend_tax_code_and_tax_struct, end
END Check_Common___;


@Override
PROCEDURE Insert___(
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT tax_structure_item_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Validate_Tax_Structure(newrec_.company, newrec_.tax_calc_structure_id);
END Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------         

-- To perform cascade delete when whole Tax Structure is deleted
PROCEDURE Delete_Tax_Calc_Structure__ (
   company_               IN VARCHAR2,
   tax_calc_structure_id_ IN VARCHAR2 )
IS
   CURSOR get_item IS
      SELECT objid, objversion
      FROM   tax_structure_item
      WHERE  company = company_ 
      AND    tax_calc_structure_id = tax_calc_structure_id_;
   info_       VARCHAR2(2000);
BEGIN
   Tax_Structure_Item_Ref_API.Delete_Tax_Calc_Structure_(company_, tax_calc_structure_id_);
   FOR rec_ IN get_item LOOP
      Remove__(info_, rec_.objid, rec_.objversion, 'DO');
   END LOOP;
END Delete_Tax_Calc_Structure__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
         
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Validate_Tax_Structure (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2 )
IS
   item_id_                 VARCHAR2(20);  
   incl_price_in_tax_base_  VARCHAR2(20);
   calculation_order_       NUMBER;
   CURSOR check_first_record IS
      SELECT incl_price_in_tax_base
      FROM   tax_structure_item_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_
      ORDER BY calculation_order ASC;   
   CURSOR check_calc_order_unique IS
      SELECT calculation_order
      FROM   tax_structure_item_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_
      GROUP BY calculation_order 
      HAVING COUNT(*) > 1;
   CURSOR check_calc_order_ref IS
      SELECT i1.item_id, i1.calculation_order
      FROM   tax_structure_item_tab     i1,
             tax_structure_item_ref_tab ir,
             tax_structure_item_tab     i2       
      WHERE  i1.company                = company_
      AND    i1.tax_calc_structure_id  = tax_calc_structure_id_
      AND    i1.company                = ir.company
      AND    i1.tax_calc_structure_id  = ir.tax_calc_structure_id
      AND    i1.item_id                = ir.item_id
      AND    ir.company                = i2.company
      AND    ir.tax_calc_structure_id  = i2.tax_calc_structure_id
      AND    ir.item_id_ref            = i2.item_id         
      AND    i1.calculation_order     <= i2.calculation_order;   
BEGIN   
   OPEN check_calc_order_unique;
   FETCH check_calc_order_unique INTO calculation_order_;
   IF (check_calc_order_unique%FOUND) THEN
      CLOSE check_calc_order_unique;
      Error_SYS.Record_General(lu_name_, 'NONUNIQUECALCORDER: Calculation Order must be unique within Tax Calculation Structure.');       
   END IF;   
   CLOSE check_calc_order_unique;   
   OPEN check_first_record;
   FETCH check_first_record INTO incl_price_in_tax_base_;
   IF (check_first_record%FOUND) THEN
      IF (incl_price_in_tax_base_ = 'FALSE') THEN         
         CLOSE check_first_record;
         Error_SYS.Record_General(lu_name_, 'FIRSTRECORDBASEREQ: Include Price in Tax Base is required for the item with the smallest calculation order in the Tax Calculation Structure.');
      END IF;
   END IF;   
   CLOSE check_first_record;
   OPEN check_calc_order_ref;
   FETCH check_calc_order_ref INTO item_id_, calculation_order_;
   IF (check_calc_order_ref%FOUND) THEN
      CLOSE check_calc_order_ref;
      Error_SYS.Record_General(lu_name_, 'WRONGREFCALCORDER: All Structure Item References for Structure Item :P1 must have calculation order lower than :P2.', item_id_, calculation_order_);
   END IF;   
   CLOSE check_calc_order_ref;   
END Validate_Tax_Structure;  


PROCEDURE Validate_Tax_Struct_Activate (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2 )
IS
   CURSOR check_empty IS
      SELECT 1
      FROM   tax_structure_item_tab
      WHERE  company   = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_;
   CURSOR check_item_ref IS
      SELECT 1
      FROM   tax_structure_item_tab i
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_
      AND    incl_price_in_tax_base = 'FALSE'
      AND    NOT EXISTS (SELECT * FROM tax_structure_item_ref_tab ir
                         WHERE  i.company                = ir.company
                         AND    i.tax_calc_structure_id  = ir.tax_calc_structure_id
                         AND    i.item_id                = ir.item_id);   
   dummy_   NUMBER := 0;                         
BEGIN
   OPEN  check_empty;
   FETCH check_empty INTO dummy_;
   IF (check_empty%NOTFOUND) THEN
      CLOSE check_empty;
      Error_SYS.Record_General(lu_name_, 'TAXCALCSTREMPTY: At least one Structure Item must be defined.');
   ELSE   
      CLOSE check_empty;
   END IF;
   OPEN  check_item_ref;
   FETCH check_item_ref INTO dummy_;
   IF (check_item_ref%FOUND) THEN
      CLOSE check_item_ref;
      Error_SYS.Record_General(lu_name_, 'NOBASEFORTAXSTRITEM: Each Structure Item must have a base for calculation.');
   END IF;   
   CLOSE check_item_ref;   
END Validate_Tax_Struct_Activate;


PROCEDURE Check_Valid_Tax_Structure (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2,
   date_                   IN DATE )
IS
   tax_code_               VARCHAR2(20);
   CURSOR check_not_valid IS
      SELECT i.tax_code
      FROM   tax_structure_item_tab i, statutory_fee_tab sf
      WHERE  i.company   = company_
      AND    i.tax_calc_structure_id = tax_calc_structure_id_
      AND    sf.company  = i.company
      AND    sf.fee_code = i.tax_code
      AND   (TRUNC(date_) < sf.valid_from OR TRUNC(date_) > sf.valid_until);
BEGIN
   OPEN  check_not_valid;
   FETCH check_not_valid INTO tax_code_;
   IF (check_not_valid%FOUND) THEN
      CLOSE check_not_valid;
      Error_SYS.Record_General(lu_name_, 'TAXSTRINVTAXCODE: Tax Calculation Structure :P1 has invalid Tax Code :P2.', tax_calc_structure_id_, tax_code_);
   ELSE   
      CLOSE check_not_valid;
   END IF;
END Check_Valid_Tax_Structure;


@UncheckedAccess
FUNCTION Get_Tax_Structure_Items (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2 ) RETURN Tax_Handling_Util_API.tax_information_table
IS
   tax_info_table_   Tax_Handling_Util_API.tax_information_table;  
   index_            NUMBER := 0;
   CURSOR get_record IS
      SELECT item_id, tax_code
      FROM   tax_structure_item_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_
      ORDER BY calculation_order;
BEGIN
   FOR rec_ IN get_record LOOP
      index_ := index_ + 1;
      tax_info_table_(index_).tax_code := rec_.tax_code;          
      tax_info_table_(index_).tax_calc_structure_item_id := rec_.item_id;
   END LOOP;
   RETURN tax_info_table_;
END Get_Tax_Structure_Items;


-- gelr: extend_tax_code_and_tax_struct, begin
-- This method returns the Brazil tax calculation specific tax percentage for the tax codes with Tax in Tax Base selected.
@UncheckedAccess
FUNCTION Get_Br_Tax_Percentage (
   company_                 IN  VARCHAR2,
   tax_calc_structure_id_   IN  VARCHAR2 ) RETURN NUMBER
IS
   br_tax_percentage_      NUMBER;
   CURSOR total_tax_in_tax_base_rate IS
      SELECT SUM(t.fee_rate) 
      FROM   statutory_fee_tab t
      WHERE  t.company = company_
      AND    t.tax_in_tax_base = 'TRUE'
      AND    t.fee_code IN (SELECT a.tax_code 
                            FROM   tax_structure_item_tab a
                            WHERE  a.company = company_ 
                            AND    a.tax_calc_structure_id = tax_calc_structure_id_);
BEGIN   
   OPEN total_tax_in_tax_base_rate;
   FETCH total_tax_in_tax_base_rate INTO br_tax_percentage_;
   CLOSE total_tax_in_tax_base_rate;
   RETURN NVL(br_tax_percentage_, 0);
END Get_Br_Tax_Percentage;
-- gelr: extend_tax_code_and_tax_struct, end

-------------------- LU  NEW METHODS -------------------------------------

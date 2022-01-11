-----------------------------------------------------------------------------
--
--  Logical unit: TaxStructureItemRef
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

TYPE tax_structure_item_ref_table IS TABLE OF tax_structure_item_ref_tab%ROWTYPE INDEX BY BINARY_INTEGER;
 
-------------------- PRIVATE DECLARATIONS -----------------------------------
 
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN tax_structure_item_ref_tab%ROWTYPE )
IS
   pub_rec_    Tax_Calc_Structure_API.Public_Rec;   
BEGIN
   pub_rec_ := Tax_Calc_Structure_API.Get(remrec_.company, remrec_.tax_calc_structure_id);
   IF (pub_rec_.rowstate != 'Preliminary') THEN
      Error_SYS.Appl_General(lu_name_,'TAXSTRITEMREFCHECKDEL: It is only allowed to delete items in status Preliminary.');
   END IF;   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_structure_item_ref_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   IF (newrec_.item_id = newrec_.item_id_ref) THEN
      Error_SYS.Record_General(lu_name_, 'WRONGSTRUCTITEMREF: Structure Item Ref must be different than Structure Item.');       
   END IF;   
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT tax_structure_item_ref_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS  
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Tax_Structure_Item_API.Validate_Tax_Structure(newrec_.company, newrec_.tax_calc_structure_id);
END Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Delete_Tax_Calc_Structure_ (
   company_               IN VARCHAR2,
   tax_calc_structure_id_ IN VARCHAR2 )
IS
   CURSOR get_item_ref IS
      SELECT objid, objversion
      FROM   tax_structure_item_ref
      WHERE  company = company_ 
      AND    tax_calc_structure_id = tax_calc_structure_id_;
   info_       VARCHAR2(2000);
BEGIN
   FOR rec_ IN get_item_ref LOOP
      Remove__(info_, rec_.objid, rec_.objversion, 'DO');
   END LOOP;
END Delete_Tax_Calc_Structure_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Tax_Code_Description (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2,
   item_id_ref_            IN VARCHAR2 ) RETURN VARCHAR2
IS  
BEGIN
   RETURN Statutory_Fee_API.Get_Description(company_, Tax_Structure_Item_API.Get_Tax_Code(company_, tax_calc_structure_id_, item_id_ref_));
END Get_Tax_Code_Description;


@UncheckedAccess
FUNCTION Get_Tax_Code_Rate (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2,
   item_id_ref_            IN VARCHAR2 ) RETURN NUMBER
IS  
BEGIN
   RETURN Statutory_Fee_API.Get_Fee_Rate(company_, Tax_Structure_Item_API.Get_Tax_Code(company_, tax_calc_structure_id_, item_id_ref_));
END Get_Tax_Code_Rate;


@UncheckedAccess
FUNCTION Get_Tax_Structure_Ref_Items (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2,
   item_id_                IN VARCHAR2 ) RETURN tax_structure_item_ref_table
IS
   temp_table_   tax_structure_item_ref_table;  
   CURSOR get_record IS
      SELECT *
      FROM   tax_structure_item_ref_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_
      AND    item_id               = item_id_;
BEGIN
   OPEN  get_record;
   FETCH get_record BULK COLLECT INTO temp_table_;
   CLOSE get_record;
   RETURN temp_table_;   
END Get_Tax_Structure_Ref_Items;


FUNCTION Get_Tax_Structure_Ref_Msg (
   company_                    IN     VARCHAR2,
   tax_calc_structure_id_      IN     VARCHAR2,
   item_id_                    IN     VARCHAR2 ) RETURN VARCHAR2
IS
   item_ref_msg_               VARCHAR2(2000);
   tax_struct_item_ref_table_  tax_structure_item_ref_table;
BEGIN           
   tax_struct_item_ref_table_ := Get_Tax_Structure_Ref_Items(company_, tax_calc_structure_id_, item_id_);
   IF (tax_struct_item_ref_table_.COUNT > 0) THEN
      item_ref_msg_ := Message_SYS.Construct('TAX_STRUCT_REF_ITEMS');
      FOR i IN 1 .. tax_struct_item_ref_table_.COUNT LOOP
         Message_SYS.Add_Attribute(item_ref_msg_, 'REF_ITEM', tax_struct_item_ref_table_(i).item_id_ref);
      END LOOP;        
   END IF;
   RETURN item_ref_msg_;
END Get_Tax_Structure_Ref_Msg;

-------------------- LU  NEW METHODS -------------------------------------

-----------------------------------------------------------------------------
--
--  Logical unit: TaxCalcStructure
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  170110  reanpl  FINHR-2559, Created.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------
 
-------------------- PRIVATE DECLARATIONS -----------------------------------
 
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN tax_calc_structure_tab%ROWTYPE )
IS
BEGIN
   IF (remrec_.rowstate != 'Preliminary') THEN
      Error_SYS.Appl_General(lu_name_, 'TAXCALCSTRCHECKDEL: It is only allowed to delete Tax Calcualtion Structure in status Preliminary.');
   END IF;   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Finite_State_Add_To_Attr___ (
   rec_  IN     tax_calc_structure_tab%ROWTYPE,
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(rec_, attr_);
   -- return DB column to be used on Client form
   Client_SYS.Add_To_Attr('OBJSTATE', rec_.rowstate, attr_);
END Finite_State_Add_To_Attr___;


@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN tax_calc_structure_tab%ROWTYPE )
IS   
BEGIN
   Error_SYS.Appl_General(lu_name_, 'TAXCALCSTRUCTALREADYEXIST:  Tax Calculation Structure already exist.');
   super(rec_);   
END Raise_Record_Exist___;


FUNCTION Active_Allowed___ (
   rec_  IN     tax_calc_structure_tab%ROWTYPE ) RETURN BOOLEAN
IS   
BEGIN
   Tax_Structure_Item_API.Validate_Tax_Struct_Activate(rec_.company, rec_.tax_calc_structure_id);
   RETURN TRUE;
END Active_Allowed___;


FUNCTION Obsolete_Allowed___ (
   rec_  IN     tax_calc_structure_tab%ROWTYPE ) RETURN BOOLEAN
IS   
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (Source_Tax_Item_Invoic_API.Check_Tax_Struct_In_Prel_Inv(rec_.company, rec_.tax_calc_structure_id) = 'TRUE') THEN
         Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTUSEDPRELINV: There are invoices in Preliminary status connected to this structure.');
      END IF;   
   $END
   RETURN TRUE;
END Obsolete_Allowed___;


FUNCTION Preliminary_Allowed___ (
   rec_  IN     tax_calc_structure_tab%ROWTYPE ) RETURN BOOLEAN
IS   
BEGIN
   IF (Source_Tax_Item_API.Tax_Calc_Structure_Used(rec_.company, rec_.tax_calc_structure_id)) THEN
      Error_SYS.Appl_General(lu_name_, 'TAXSTRUSEDTRANS: It is not allowed to change status to Preliminary since the Tax Calculation Structure is used in transactions.');
   END IF;
   IF (Company_Address_API.Tax_Calc_Structure_Used(rec_.company, rec_.tax_calc_structure_id)) THEN
      Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTUSEDCOMP: It is not allowed to change status to Preliminary since the Tax Calculation Structure is used in Company/Address/Tax Information.');      
   END IF;   
   IF (Supplier_Tax_Info_API.Tax_Calc_Structure_Used(rec_.company, rec_.tax_calc_structure_id)) THEN
      Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTUSEDSUPP: It is not allowed to change status to Preliminary since the Tax Calculation Structure is used in Supplier/Address/Delivery Tax Information.');      
   END IF;   
   $IF Component_Invoic_SYS.INSTALLED $THEN
      IF (Customer_Delivery_Tax_Info_API.Tax_Calc_Structure_Used(rec_.company, rec_.tax_calc_structure_id)) THEN
         Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTUSEDINV: It is not allowed to change status to Preliminary since the Tax Calculation Structure is used in Customer/Address/Delivery Tax Information.');
      END IF;   
   $END
   $IF Component_Proj_SYS.INSTALLED $THEN
      IF (Project_Address_API.Tax_Calc_Structure_Used(rec_.company, rec_.tax_calc_structure_id)) THEN
         Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTUSEDPROJ: It is not allowed to change status to Preliminary since the Tax Calculation Structure is used in Project/Address/Tax Information.');      
      END IF;   
   $END   
   RETURN TRUE;
END Preliminary_Allowed___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Validate_Tax_Structure_State (
   company_               IN VARCHAR2,
   tax_calc_structure_id_ IN VARCHAR2 )
IS
   rec_  tax_calc_structure_tab%ROWTYPE;
BEGIN
   rec_ := Get_Object_By_Keys___(company_, tax_calc_structure_id_);
   IF (rec_.company IS NULL) THEN
      Raise_Record_Not_Exist___(company_, tax_calc_structure_id_);
   ELSE
      IF (rec_.rowstate != 'Active') THEN
         Error_SYS.Appl_General(lu_name_, 'TAXSTRUCTNOTACTIVE: The Tax Calculation Structure :P1 has status :P2. Only Tax Calculation Structures in status Active are valid to use.', tax_calc_structure_id_, Finite_State_Decode__(rec_.rowstate));
      END IF;            
   END IF;   
END Validate_Tax_Structure_State;

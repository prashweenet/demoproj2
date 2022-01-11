-----------------------------------------------------------------------------
--
--  Logical unit: SourceTaxItemAccrul
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  161006  Hiralk  Created for HomeRun project
-----------------------------------------------------------------------------

layer Core;

---------------------- SOURCE REF column matching ---------------------------
-- DB_MANUAL_VOUCHER
--   source_ref_type = Tax_Source_API.DB_MANUAL_VOUCHER
--   source_ref1 => accounting_year
--   source_ref2 => voucher_type
--   source_ref3 => voucher_no
--   source_ref4 => row_no
--   source_ref5 => '*'
-------------------- PUBLIC DECLARATIONS ------------------------------------
 
-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE New (
   in_newrec_     IN source_tax_item_tab%ROWTYPE )
IS
   newrec_   source_tax_item_tab%ROWTYPE;
BEGIN      
   newrec_ := in_newrec_;  
   New___(newrec_);
END New;   

-------------------- PUBLIC METHODS FOR COMMON LOGIC ------------------------

PROCEDURE Remove_Tax_Items (
   company_          IN VARCHAR2,
   source_ref_type_  IN VARCHAR2,
   source_ref1_      IN VARCHAR2,
   source_ref2_      IN VARCHAR2,
   source_ref3_      IN VARCHAR2,
   source_ref4_      IN VARCHAR2,
   source_ref5_      IN VARCHAR2 )
IS
   tax_table_       Source_Tax_Item_API.source_tax_table;
   newrec_          source_tax_item_tab%ROWTYPE;
BEGIN      
   tax_table_ := Source_Tax_Item_API.Get_Tax_Items(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   FOR i IN 1 .. tax_table_.COUNT LOOP
      Source_Tax_Item_API.Assign_Pubrec_To_Record(newrec_, tax_table_(i));
      Remove___(newrec_);
   END LOOP;
END Remove_Tax_Items;


PROCEDURE Update_Voucher_No (
   company_          IN VARCHAR2,
   source_ref_type_  IN VARCHAR2,
   source_ref1_      IN VARCHAR2,
   source_ref2_      IN VARCHAR2,
   source_ref3_      IN VARCHAR2,
   source_ref4_      IN VARCHAR2,
   source_ref5_      IN VARCHAR2,
   new_voucher_no_   IN VARCHAR2 )
IS
BEGIN
   UPDATE source_tax_item_tab
   SET    source_ref3     = new_voucher_no_
   WHERE  company         = company_
   AND    source_ref_type = source_ref_type_
   AND    source_ref1     = source_ref1_
   AND    source_ref2     = source_ref2_                            
   AND    source_ref3     = source_ref3_
   AND    source_ref4     = NVL(source_ref4_, source_ref4)
   AND    source_ref5     = source_ref5_; 
END Update_Voucher_No;
   

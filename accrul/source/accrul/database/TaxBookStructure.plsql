-----------------------------------------------------------------------------
--
--  Logical unit: TaxBookStructure
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  281002  SHSALK SALSA-IID ITFI101E Created
--  060720  CHAULK LCS 154656-Modified Delete Method
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT TAX_BOOK_STRUCTURE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Tax_Book_Structure_Level_API.Create_Bottom_Level( newrec_.company, newrec_.structure_id);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     tax_book_structure_tab%ROWTYPE,
   newrec_ IN OUT tax_book_structure_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', newrec_.company);
   Error_SYS.Check_Not_Null(lu_name_, 'STRUCTURE_ID', newrec_.structure_id);

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

--This method is to be used by Aurena
PROCEDURE Create_New_Structure (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   description_  IN VARCHAR2)
IS
   newrec_          tax_book_structure_tab%ROWTYPE;
BEGIN
   newrec_.company      := company_;
   newrec_.structure_id := structure_id_;
   newrec_.description  := description_;
   New___(newrec_);
END Create_New_Structure;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN tax_book_structure_tab%ROWTYPE )
IS
BEGIN
   Tax_Book_Structure_Level_api.Delete_Bottom_Level__(remrec_.company, remrec_.structure_id);
   super(objid_, remrec_);
END Delete___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------



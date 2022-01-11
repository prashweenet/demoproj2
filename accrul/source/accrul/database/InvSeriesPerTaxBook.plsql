-----------------------------------------------------------------------------
--
--  Logical unit: InvSeriesPerTaxBook
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Purpose: gelr:tax_book_and_numbering
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  191030   Kagalk gelr: Added to support Global Extension Functionalities. 
--  191030   Kagalk GESPRING20-1261, Created for gelr:tax_book_and_numbering.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT inv_series_per_tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);   
   Validate_Insert___(newrec_);
END Check_Insert___;

-- Validate_Insert___
--    Same invoice series should not be used in other tax books with same direction
PROCEDURE Validate_Insert___ (
   newrec_ IN inv_series_per_tax_book_tab%ROWTYPE )
IS
   tax_direction_db_   tax_book_tab.tax_direction_sp%TYPE;
   dummy_              NUMBER;

   CURSOR get_tax_book is
      SELECT 1
      FROM tax_book_tab tb,
           inv_series_per_tax_book_tab istb
      WHERE tb.company              = istb.company
      AND   tb.tax_book_id          = istb.tax_book_id
      AND   tb.company              = newrec_.company
      AND   istb.series_id          = newrec_.series_id
      AND   tb.tax_direction_sp     = tax_direction_db_
      AND   tb.tax_book_base        = Tax_Book_Base_API.DB_INVOICE_SERIES
      AND   tb.tax_book_base_values = Tax_Book_Base_Values_API.DB_RESTRICTED;      
BEGIN
   tax_direction_db_ := Tax_Book_API.Get_Tax_Direction_Sp_Db(newrec_.company, newrec_.tax_book_id);

   OPEN get_tax_book;
   FETCH get_tax_book INTO dummy_;
   IF get_tax_book%FOUND THEN
      CLOSE get_tax_book;
      Error_SYS.Appl_General(lu_name_, 'INVSERIESALREADYUSED: Invoice Series :P1 is used in another Tax Book having same Tax Direction.', newrec_.series_id);
   END IF;
   CLOSE get_tax_book;
END Validate_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


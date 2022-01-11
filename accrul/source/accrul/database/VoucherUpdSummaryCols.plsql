-----------------------------------------------------------------------------
--
--  Logical unit: VoucherUpdSummaryCols
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------





-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Get_Column_Description (   
   column_id_     IN VARCHAR2) RETURN VARCHAR2
IS
   desc_    VARCHAR2(100);
BEGIN
   desc_ := Substr(Language_SYS.Lookup('Column', 'VOUCHER_ROW.'|| UPPER(column_id_), 'Prompt', Fnd_Session_API.Get_Language()),1,100);      
   IF (desc_ IS NULL) THEN
      desc_ := Get_Description(column_id_);
   END IF;   
   RETURN desc_;
END Get_Column_Description;

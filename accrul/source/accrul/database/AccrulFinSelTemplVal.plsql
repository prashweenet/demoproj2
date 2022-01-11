-----------------------------------------------------------------------------
--
--  Logical unit: AccrulFinSelTemplVal
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
PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS 
   
BEGIN
   Fin_Sel_Templ_Values_API.Make_Company_Gen( 'ACCRUL', lu_name_, 'ACCRUL_FIN_SEL_TEMPL_VAL_API', attr_ );
END Make_Company;  

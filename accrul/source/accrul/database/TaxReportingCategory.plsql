-----------------------------------------------------------------------------
--
--  Logical unit: TaxReportingCategory
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  100917  KiSalk Changed to Template version 2.5.
--  091109  Jofise Created.
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-------------------- PACKAGES FOR METHOD
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
PROCEDURE Enumerate_With_Null (
   client_values_ OUT VARCHAR2)
IS
   active_value_list_with_null_ VARCHAR2(2000);
BEGIN
   active_value_list_with_null_ := ' ^' || Domain_SYS.Get_Translated_Values(lu_name_);
   client_values_ := Domain_SYS.Enumerate_(active_value_list_with_null_);
END Enumerate_With_Null;



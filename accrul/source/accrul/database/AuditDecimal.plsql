-----------------------------------------------------------------------------
--
--  Logical unit: AuditDecimal
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
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
FUNCTION Get_Value (
   db_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF db_value_ = '0' THEN
      RETURN '.';
   ELSIF db_value_ = '1' THEN
      RETURN ',';
   ELSE
      RETURN NULL;
   END IF;
END Get_Value;





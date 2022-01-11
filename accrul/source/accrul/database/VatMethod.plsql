-----------------------------------------------------------------------------
--
--  Logical unit: VatMethod
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  141128  TAORSE  Added Enumerate_Cust_Db and Enumerate_Supp_Db
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
PROCEDURE Enumerate_Cust (
   client_values_ IN OUT VARCHAR2 )
IS
BEGIN
   Enumerate(client_values_);
END Enumerate_Cust;

PROCEDURE Enumerate_Cust_Db (
   db_values_ IN OUT VARCHAR2 )
IS
BEGIN
   Enumerate_Db(db_values_);
END Enumerate_Cust_Db;

@UncheckedAccess
PROCEDURE Enumerate_Supp (
   client_values_ IN OUT VARCHAR2 )
IS
BEGIN
   Enumerate(client_values_);
END Enumerate_Supp;

PROCEDURE Enumerate_Supp_Db (
   db_values_ IN OUT VARCHAR2 )
IS
BEGIN
   Enumerate_Db(db_values_);
END Enumerate_Supp_Db;
-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodePartFu
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
PROCEDURE Enumerate_Accounting_Code_Part (
   client_values_ OUT VARCHAR2)
IS
BEGIN
   Enumerate_Acc_Code_Part(client_values_);
END Enumerate_Accounting_Code_Part;

PROCEDURE Enumerate_Additional_Code_Part (
   client_values_ OUT VARCHAR2)
IS
BEGIN
   Enumerate_Add_Code_Part(client_values_); 
END Enumerate_Additional_Code_Part;

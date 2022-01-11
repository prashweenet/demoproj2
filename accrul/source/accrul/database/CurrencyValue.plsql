-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyValue
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

PROCEDURE Enumerate_No_User_Defined (
   client_values_ OUT VARCHAR2)
IS
BEGIN
   client_values_ := Decode(DB_ACCOUNTING_CURRENCY) ||Client_SYS.Field_Separator_|| Decode(DB_PARALLEL_CURRENCY) || Client_SYS.Field_Separator_;
END Enumerate_No_User_Defined;

PROCEDURE Enumerate_No_User_Defined_Db (
   db_values_ OUT VARCHAR2)
IS
BEGIN
   db_values_ := DB_ACCOUNTING_CURRENCY ||Client_SYS.Field_Separator_|| DB_PARALLEL_CURRENCY || Client_SYS.Field_Separator_;
END Enumerate_No_User_Defined_Db;

PROCEDURE Enum_Without_Userdefined (
   client_values_ OUT VARCHAR2)
IS
BEGIN
   client_values_ := Decode(DB_ACCOUNTING_CURRENCY) ||Client_SYS.Field_Separator_|| Decode(DB_PARALLEL_CURRENCY) || Client_SYS.Field_Separator_|| Decode(DB_BOTH_CURRENCIES) || Client_SYS.Field_Separator_;
END Enum_Without_Userdefined;

PROCEDURE Enum_Without_Userdefined_Db (
   db_values_ OUT VARCHAR2)
IS
BEGIN
   db_values_ := DB_ACCOUNTING_CURRENCY ||Client_SYS.Field_Separator_|| DB_PARALLEL_CURRENCY || Client_SYS.Field_Separator_|| DB_BOTH_CURRENCIES || Client_SYS.Field_Separator_;
END Enum_Without_Userdefined_Db;
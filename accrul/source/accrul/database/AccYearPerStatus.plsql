-----------------------------------------------------------------------------
--
--  Logical unit: AccYearPerStatus
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

PROCEDURE Enumerate_No_Finall_Close (
   client_values_ OUT VARCHAR2)
IS
BEGIN
   client_values_ := Decode(DB_OPEN) ||Client_SYS.Field_Separator_|| Decode(DB_CLOSED) || Client_SYS.Field_Separator_;
END Enumerate_No_Finall_Close;

PROCEDURE Enumerate_No_Finall_Close_Db (
   db_values_ OUT VARCHAR2)
IS
BEGIN
   db_values_ := DB_OPEN ||Client_SYS.Field_Separator_|| DB_CLOSED || Client_SYS.Field_Separator_;
END Enumerate_No_Finall_Close_Db;
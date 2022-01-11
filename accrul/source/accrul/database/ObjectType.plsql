-----------------------------------------------------------------------------
--
--  Logical unit: ObjectType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-- 
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Enumerate_Account_Group (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);
   
BEGIN
   client_list_:= Object_Type_API.Decode(DB_ACCOUNT_GROUP)||'^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Account_Group;


PROCEDURE Enumerate_Account_Type (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);

BEGIN
   client_list_:= Object_Type_API.Decode(DB_ACCOUNT_TYPE)||'^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Account_Type;


PROCEDURE Enumerate_Code_Elem (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);
   
BEGIN
   client_list_:= Object_Type_API.Decode(DB_CODEPART) || '^' || Object_Type_API.Decode(DB_STRUCTURE) || '^' || Object_Type_API.Decode(DB_STRUCTURE_NODE) || '^' || Object_Type_API.Decode(DB_STRUCTURE_LEVEL) || '^' || Object_Type_API.Decode(DB_ATTRIBUTE) || '^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Code_Elem;


PROCEDURE Enumerate_Cons_Account (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);
BEGIN
   client_list_:= Object_Type_API.Decode(DB_CONSOLIDATION_ACCNT)||'^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Cons_Account;


PROCEDURE Enumerate_Object_Type (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);
BEGIN
   client_list_:= Object_Type_API.Decode(DB_CODEPART)||'^'||Object_Type_API.Decode(DB_ACCOUNT_GROUP)||'^'||Object_Type_API.Decode(DB_CONSOLIDATION_ACCNT)||'^'||Object_Type_API.Decode(DB_ACCOUNT_TYPE)||'^'||Object_Type_API.Decode(DB_STRUCTURE) ||'^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Object_Type;

PROCEDURE Enumerate_Object_Type_Db (
   db_values_ OUT VARCHAR2)
IS
   db_list_ VARCHAR2(32000);
BEGIN
   db_list_ := DB_CODEPART||'^'||DB_ACCOUNT_GROUP||'^'||DB_CONSOLIDATION_ACCNT||'^'||DB_ACCOUNT_TYPE||'^'||DB_STRUCTURE ||'^';
   db_values_ := Domain_SYS.Enumerate_(db_list_);
END Enumerate_Object_Type_Db;

PROCEDURE Enumerate_Structure (
   client_values_ OUT VARCHAR2 )
IS
   client_list_  VARCHAR2(32000);
BEGIN
   client_list_:= Object_Type_API.Decode(DB_STRUCTURE)||'^'||Object_Type_API.Decode(DB_STRUCTURE_NODE) ||'^'||Object_Type_API.Decode(DB_STRUCTURE_LEVEL)||'^';
   client_values_ := Domain_SYS.Enumerate_( client_list_);
END Enumerate_Structure;

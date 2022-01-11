-----------------------------------------------------------------------------
--
--  Logical unit: CompanySecurity
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date       Sign    History
--  ------     ------   ---------------------------------------------------------
/*
Created to handle company related security in a common LU. Before removing unused methods check whether 
they are used by developer studio for company security.
*/
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Check_Basic (
   company_ IN VARCHAR2)
IS
BEGIN
    User_Finance_API.Exist_Current_User(company_);
END Check_Basic;   

PROCEDURE Check_Extended (
   company_ IN VARCHAR2)
IS
BEGIN
    Check_Basic(company_);
END Check_Extended;   

@UncheckedAccess
FUNCTION Is_Basic_Authorized (
   company_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    RETURN User_Finance_API.Is_User_Authorized(company_);
END Is_Basic_Authorized;   


@UncheckedAccess
FUNCTION Is_Extended_Authorized (
   company_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    RETURN Is_Basic_Authorized(company_);
END Is_Extended_Authorized;


@UncheckedAccess
FUNCTION Is_Basic_Allowed (
   company_ IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    RETURN User_Finance_API.Is_Allowed(company_);
END Is_Basic_Allowed;   


@UncheckedAccess
FUNCTION Is_Extended_Allowed (
   company_ IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    RETURN Is_Basic_Allowed(company_);
END Is_Extended_Allowed;


-----------------------------------------------------------------------------
--
--  Logical unit: AccountTaxCode
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000616  BmEk    Created
--  000704  BmEk    A527: Added Get_Default_Tax_Code and Check_Tax_Code
--  000808  BmEk    A522: Modified Check_Default___
--  000811  BmEk    A527: Modified Get_Default_Tax_Code and Check_Tax_Code
--  000925  BmEk    A522: Added CASCADE option on Account in view Account_Tax_Code
--  000927  BmEk    Call #49564: Corrected
--  001006  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  001012  BmEk    A527: Modified Get_Default_Tax_Code and Check_Tax_Code 
--  001017  BmEk    A522: Modified Check_Default___
--  021001  Nimalk  Removed usage of the view Company_Finance_Auth in ACCOUNT_TAX_CODE view 
--                      and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  031007  Shsalk  Modified Check_Tax_Code.
--  040302  Gepelk  2004 SP1 Merge.
--  070116  RUFELK  FIPL637A - Considered the 'O' logical account type where the 'S' logical account type was used.
--  070802  Marulk  LCS Patch Merge 65158. Added new methods to facilitate the addition of this LU to the Create Company concept 
--  070806  Marulk  LCS Patch Merge 65158. Small correction in a veiw-comment.
--  090506  Shdilk  Bug 82149, Added party_type_ parameter to Check_Tax_Code
--  090605  THPELK  Bug 82609 - Added missing UNDEFINE statements for VIEWPCT.
--  090713  ErFelk  Bug 83174, Changed the error message of constant TAXDEDUCT in Get_Default_Tax_Code.
--  090815  Shdilk  Bug 85057, modified Check_Tax_Code
--  110528  THPELK EASTONE-21645 Added missing General_SYS and PRAGMA.
--  120627  THPELK  Bug 97225, Added Default NULL parameter for Check_Tax_Code() and new method Get_Default_Tax_Code().
--  130902  THPELK  Bug 112154, Corrected QA script cleanup - Financials  Type Cursor usage in procedure / function
--  131023  UMDOLK  CAHOOK-2830, Refactoring
--  200103  THPELK  Bug 152017, Corrected in Check_Insert___().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Already_Exist___ (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   account_tax_code_tab
      WHERE  company = company_
      AND    account = account_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Already_Exist___;


PROCEDURE Check_Default___ (
   company_           IN VARCHAR2,
   account_           IN VARCHAR2,
   default_tax_code_  IN VARCHAR2 )
IS
   dummy_    VARCHAR2(5);

   CURSOR get_tax_default IS 
      SELECT default_tax_code
      FROM   account_tax_code_tab
      WHERE  company          = company_
      AND    account          = account_
      AND    default_tax_code = 'Y';
BEGIN
   IF (default_tax_code_ = 'Y') THEN
      OPEN get_tax_default;
      FETCH get_tax_default INTO dummy_;  
      IF (get_tax_default%FOUND) THEN
         UPDATE account_tax_code_tab
         SET default_tax_code = 'N'
         WHERE company = company_
         AND account = account_;
      END IF;
      CLOSE get_tax_default;
   END IF;
END Check_Default___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT account_tax_code_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   tax_handling_value_  VARCHAR2(100);
   valid_date_          DATE;
BEGIN   
   IF (indrec_.fee_code) THEN
      valid_date_ := App_Context_SYS.Find_Date_Value('CreateCompany_Valid_From', SYSDATE);
      Tax_Handling_Util_API.Validate_Tax_On_Basic_Data(newrec_.company, 'COMMON', newrec_.fee_code, 'ALL', valid_date_);
      indrec_.fee_code := FALSE;
   END IF;
   super(newrec_, indrec_, attr_);
   tax_handling_value_ := Account_API.Get_Tax_Handling_Value_Db(newrec_.company, newrec_.account);
   IF tax_handling_value_ IN ('ALL') THEN
      IF Already_Exist___ (newrec_.company, newrec_.account) THEN
         Error_SYS.Record_General(lu_name_, 'ALREADYEXIST: You are not allowed to save more than one Tax Code per Account when Tax Handling is set to :P1', Tax_Handling_Value_API.Decode(tax_handling_value_));
      END IF;
   END IF;
END Check_Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     account_tax_code_tab%ROWTYPE,
   newrec_     IN OUT account_tax_code_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   --Add pre-processing code here
   Check_Default___(newrec_.company, newrec_.account, newrec_.default_tax_code);
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   --Add post-processing code here
END Update___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Default_Tax_Code (
   company_           IN  VARCHAR2,
   account_           IN  VARCHAR2) RETURN VARCHAR2
IS
   tax_code_     VARCHAR2(20);
   CURSOR get_tax_code IS
      SELECT fee_code
      FROM   account_tax_code_tab
      WHERE  company = company_
      AND    account = account_
      AND    default_tax_code = 'Y';
BEGIN
   OPEN get_tax_code;
   FETCH get_tax_code INTO tax_code_;
   IF (get_tax_code%FOUND) THEN
      CLOSE get_tax_code;
      RETURN tax_code_;
   END IF;
   CLOSE get_tax_code;
   RETURN NULL;
END Get_Default_Tax_Code;

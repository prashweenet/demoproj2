-----------------------------------------------------------------------------
--
--  Logical unit: AccountProcessCode
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960327  MIJO  Created.
--  960611  ToRe  Validate_Process_Code is changed to a public method.
--  970626  SLKO  Converted to Foundation1 1.2.2d
--  980126  SLKO  Converted to Foundation1 2.0.0
--  980921  Bren  Master Slave Connection
--                Added Send_Process_Info___, Send_Process_Info_Delete___,
--                Send_Process_Info_Modify___, Receive_Process_Info___ .
--  981120  JPS   Changed the column size of process_code in view ACCOUNT_PROCESS_CODE
--                from 2 to 10. Corrected Bug # 6150.
--  990709  HIMM  Modified with respect to template changes
--  000908  HiMu  Added General_SYS.Init_Method
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  021001  Nimalk Removed usage of the view Company_Finance_Auth in ACCOUNT_PROCESS_CODE view
--                  and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021014  SAMBLK Aded new views ACCOUNT_PROCESS_CODE_ECT and ACCOUNT_PROCESS_CODE_PCT.
--  021014         Added procedures Make_Company, Copy___, Import___ and Export___.  
--  031217  Thsrlk FIPR300A1: Add translation supprt functionality
--  040723  Gawilk FIPR307A: Added view ACCOUNT_PROCESS_CODE_LOV
--  051019  Shsalk Removed the view ACCOUNT_PROCESS_CODE_LOV.
--  090605  THPELK Bug 82609 - Added missing UNDEFINE statements for VIEW_LOV.
--  091223  Pwewlk EAFH-1264 Removed obsolete view ACCOUNT_PROCESS_CODE_LOV
--  100123  Nsillk EAFH-2144 Modified methods Import and Copy
--  100401  Nsillk EAFH-2573 Added some validation in Copy__ metho
--  131108  Umdolk PBFI-894, Refactoring.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT accounting_process_code_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, pub_rec_);
   newrec_.valid_from := crecomp_rec_.valid_from;
END Import_Assign___;

@Override
PROCEDURE Copy_Assign___ (
   newrec_      IN OUT accounting_process_code_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   oldrec_      IN     accounting_process_code_tab%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, oldrec_);
   newrec_.valid_from   := crecomp_rec_.valid_from;
END Copy_Assign___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_from_   DATE;
   valid_until_  DATE;

BEGIN
   super(attr_);
   valid_from_  := sysdate;
   valid_until_ := LAST_DAY( TO_DATE( '12-01-' || TO_CHAR(sysdate, 'YYYY' ) , 'MM-DD-YYYY' ) ) ;

   Client_SYS.Add_To_Attr('VALID_FROM',  valid_from_  , attr_ ) ;
   Client_SYS.Add_To_Attr('VALID_UNTIL', valid_until_  , attr_ ) ;
END Prepare_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Validate_Process_Code (
   result_           OUT VARCHAR2,
   company_       IN     VARCHAR2,
   process_code_  IN     VARCHAR2,
   date_          IN     DATE )
IS
  ret_            BOOLEAN := FALSE;
BEGIN

   ret_ := Validate_Process_Code(company_,
                                 process_code_,
                                 date_);
   IF (ret_) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
      Error_SYS.Record_General('AccountProcessCode', 'INVALID_PROC: The process code is invalid or out of date');
   END IF;
END Validate_Process_Code;


FUNCTION Validate_Process_Code (
   company_       IN VARCHAR2,
   process_code_  IN VARCHAR2,
   date_          IN DATE ) RETURN BOOLEAN
IS
  exist_          NUMBER;
  CURSOR valid_process_code IS
      SELECT 1
      FROM   ACCOUNTING_PROCESS_CODE_TAB
      WHERE  company      = company_
      AND    process_code = process_code_
      AND    date_ BETWEEN valid_from AND valid_until;
BEGIN
   OPEN  valid_process_code;
   FETCH valid_process_code INTO exist_;
   IF (valid_process_code%FOUND) THEN
      CLOSE valid_process_code;
      RETURN(TRUE);
   ELSE
      CLOSE valid_process_code;
      RETURN(FALSE);
   END IF;
END Validate_Process_Code;


-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodePartA
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960402  MIJO  Created.
--  960521  PiBu  Change packing CODE in Get_Required_Code_Part from
--                REQ_CODE_B....  to CODE_B only
--  960625  ToRe  Function Validate_account must always return a value.
--  961104  YoHe  Added procedure Validate_Accnt_In_Client, try to made a good
--                perfomance
--  970102  ViGu  Added columns Ledg_Flag_Dbval and Curr_Balance_Dbval to the view
--  970128  YoHe  Change procedure name Validate_Accnt_In_Client became
--                Validate_Account__
--  970206  YoHe  Added function Get_Required_Code_Part
--  970226  AnDj  Removed columns Ledg_Flag Dbval and Curr_Balance_Dbval
--  970227  YoHe  Added req_text to req_string in procedure
--                Get_Required_Code_Part
--  970402  AnDj  Added Change_Account_Code_Parts
--  970625  PiCz  Added function Exist
--  970625  SLKO  Converted to Foundation 1.2.2d
--  970627  PICZ  Added Consolidation functions
--  970715  PICZ  Changed name of Get_Account_For_Consolidation; new name is
--                Calculate_Accnt_For_Cons
--  971008  DavJ  Added View1 ACCOUNTING_CODE_PART_A1
--  971107  JeLa  Removed validation on Account Type in Validate_Cons_Account___.
--  980107  PiCz  Added functions: Get_Accnt_Group, Get_Accnt_Type_Db and column
--                accnt_type_db
--  980202  MALR  Update of Default Data, added procedure ModifyDefData__.
--  980220  PICZ  Added Validate_Insert_Modify___
--  980225  PICZ  Fixed bug in Change_Account_Code_Parts
--  980317  PICZ  Fixed bug in ModifyDefData__
--  980320  PICZ  Added Is_Codepart_Blocked (bug 965)
--  980429  THUS  Added budget account column and added new view, view2 for 8.5.0.
--  980430  Bren  Added new VIEW3 for 8.5(Pseudo Codes) and added new methods
--                Exist_Account_And_Pseudo, Validate_Account_Pseudo,
--                Get_Required_Code_Part_Pseudo.

-- 980708   Kanchi Modified this file to redirect all functions calls to Account Lu ( codea.ap*)
--                 [ Moving Code Parts to individual LU:s ]
--                 Ex. Accounting_Code_Part_A Lu:    -->   Account Lu:
--                     Accounting_Code_Part_Value    -->   CodeB Lu:
-- 230200   Upul   Add column accnt_type to the view3
-- 140400   Himu   Add  valid_from ,valid_until to the view3
-- 001003   prtilk BUG # 15677  Checked General_SYS.Init_Method
-- 010219  ARMOLK   Bug # 15677 Add call to General_SYS.Init_Method
-- 010427  LiSv  Removed procedure Modifydefdata__.
-- 020206  MaNi    IID21003 Text_Field_Translation changed to Company_Translation
-- 020226  Mnisse  IID77149, Change LUname AccountCodePartA to Account for Translations
-- 021001  Nimalk  Removed usage of the view Company_Finance_Auth in ACCOUNTS_FOR_CONSOLIDATION view
--                 and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
-- 021031  ovjose  IID Glob06. Added column description to table.
-- 040621  Gepelk  IID FIPR307. Modified PS_CODE_ACCOUNTING_CODE_PART_A.
-- 040906  AjPelk  Call 117440 , A default null parameter has been added into Validate_Account_Pseudo__
-- 050201  nsillk  Merged Bug 42667.
-- 051024  Nsillk  Merge 42667 Correction,.Removed the views ACCOUNTS_FOR_CONSOLIDATION and
--                 BUDGET_ACCOUNTING_CODE_PART_A because not used in edge.
-- 051229  Nsillk  LCS Merge(54796/54798)
-- 060205  Nsillk  Changed the length of sort_value to 20.
-- 060727  DHSELK  Modified to_date() function to work with Persian Calander.
-- 090605  THPELK  Bug 82609 - Removed the aditional UNDEFINE statements for VIEW2 and VIEW_CONS.
-- 100423  SaFalk  Modified REF for code_part_value in ACCOUNTING_CODE_PART_A.
--  200904 Jadulk  FISPRING20-6695, Removed CONACC related obsolete component logic.
-- **************************************************************************************
-- ** DO NOT MODIFY ANY FUNCTION IN THIS FILE. DO ALL MODIFICATIONS IN THE ACCOUNT LU: **
--    THIS LU IS TO BE  REMOVED

--    ALL VIEWS ARE COPIED TO ACCOUNT LU,

--     ***  WHEN MODIFIYING VIEWS PLEASE REFLECT THE CHANGE IN BOTH FILES  ( Accounting_Code_Part_A Lu   AND     Account Lu )

--                Accounting_Code_Part_A Lu        Account Lu
--                --------------------------       -------------------------
--                ACCOUNTING_CODE_PART_A           ACCOUNT_CODE_A
--                ACCOUNTING_CODE_PART_A1          ACCOUNT_CODE_A1
--                BUDGET_ACCOUNTING_CODE_PART_A    ACCOUNT
--                PS_CODE_ACCOUNTING_CODE_PART_A   PS_CODE_ACCOUNT
--                ACCOUNTS_FOR_CONSOLIDATION       ACCOUNTS_CONSOLIDATION

--                     In all views in the account lu, Code_Part is removed and Code_Part_Value
--    is renamed to Account.
-- *************************************************************************************
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-- Check_Exist___
--   Check if a specific LU-instance already exist in the database.
FUNCTION Check_Exist___ (
   company_ IN VARCHAR2,
   accnt_   IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ACCOUNTING_CODE_PART_A
      WHERE  company = company_
      AND    code_part_value = accnt_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-- Lock__
--   Client-support to lock a specific instance of the logical unit.
@UncheckedAccess
PROCEDURE Lock__ (
   info_          OUT VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Lock__(info_, objid_, objversion_);

END Lock__;


-- New__
--   Client-support interface to create LU instances.
--   action_ = 'PREPARE'
--   Default values and handle of information to client.
--   The default values are set in procedure Prepare_Insert___.
--   action_ = 'CHECK'
--   Check all attributes before creating new object and handle of
--   information to client. The attribute list is unpacked, checked
--   and prepared (defaults) in procedure Unpack___ and Check_Insert___.
--   action_ = 'DO'
--   Creation of new instances of the logical unit and handle of
--   information to client. The attribute list is unpacked, checked
--   and prepared (defaults) in procedure Unpack___ and Check_Insert___
--   before calling procedure Insert___.
PROCEDURE New__ (
   info_          OUT VARCHAR2,
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.New__(info_, objid_, objversion_, attr_, action_);

END New__;


-- Modify__
--   Client-support interface to modify attributes for LU instances.
--   action_ = 'CHECK'
--   Check all attributes before modifying an existing object and
--   handle of information to client. The attribute list is unpacked,
--   checked and prepared(defaults) in procedure Unpack___ and Check_Update___.
--   action_ = 'DO'
--   Modification of an existing instance of the logical unit. The
--   procedure unpacks the attributes, checks all values before
--   procedure Update___ is called.
PROCEDURE Modify__ (
   info_          OUT VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Modify__(info_, objid_, objversion_, attr_, action_);

END Modify__;


-- Remove__
--   Client-support interface to remove LU instances.
--   action_ = 'CHECK'
--   Check whether a specific LU-instance may be removed or not.
--   The procedure fetches the complete record by calling procedure
--   Get_Record___. Then the check is made by calling procedure
PROCEDURE Remove__ (
   info_          OUT VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN     VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Remove__(info_, objid_, objversion_, action_);

END Remove__;


PROCEDURE Validate_Account__ (
   company_                 IN     VARCHAR2,
   code_part_               IN     VARCHAR2,
   code_part_value_         IN     VARCHAR2,
   voucher_date_            IN     DATE,
   req_string_                 OUT VARCHAR2,
   req_string_complete_     IN OUT VARCHAR2,
   ledger_accnt_               OUT NUMBER)
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Account__(company_, code_part_value_, voucher_date_, req_string_, req_string_complete_, ledger_accnt_);

END Validate_Account__;


PROCEDURE Validate_Account_Pseudo__ (
   company_                IN     VARCHAR2,
   code_part_              IN     VARCHAR2,
   code_part_value_        IN     VARCHAR2,
   voucher_date_           IN     DATE,
   req_string_                OUT VARCHAR2,
   req_string_complete_    IN OUT VARCHAR2,
   client_user_            IN VARCHAR2 DEFAULT NULL)
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Account_Pseudo__(company_,code_part_value_, voucher_date_, req_string_, req_string_complete_,client_user_);

END Validate_Account_Pseudo__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Validate_Req_Code_Part_ (
   company_            IN VARCHAR2,
   account_            IN VARCHAR2,
   req_code_part_      IN VARCHAR2,
   code_part_value_    IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Req_Code_Part_(company_, account_, req_code_part_ , code_part_value_);

END Validate_Req_Code_Part_;


FUNCTION Validate_Req_Account_ (
   codestring_rec_    IN Accounting_Codestr_API.CodestrRec,
   company_           IN VARCHAR2,
   voucher_date_      IN DATE ) RETURN BOOLEAN
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Validate_Req_Account_(codestring_rec_, company_, voucher_date_ );

END Validate_Req_Account_;


PROCEDURE Check_Delete_Group_ (
   exists_             OUT VARCHAR2,
   company_         IN     VARCHAR2,
   account_group_   IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Check_Delete_Group_(exists_ , company_, account_group_);

END Check_Delete_Group_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Exist(company_, code_part_value_);

END Exist;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2,
   accnt_   IN VARCHAR2 )
IS
   code_name_  VARCHAR2(10);
BEGIN
   IF (NOT Check_Exist___(company_, accnt_)) THEN
      code_name_ := ACCOUNTING_CODE_PARTS_API.GET_NAME(company_,'A');
      Error_SYS.Record_General(lu_name_, 'NOTEXIST: :P1 does not exist', code_name_);
   END IF;
END Exist;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
FUNCTION Exist (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Exist(company_, code_part_value_);

END Exist;


@UncheckedAccess
FUNCTION Get_Valid_From (
   company_          IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   code_part_        IN VARCHAR2 ) RETURN DATE
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Valid_From(company_, code_part_value_);

END Get_Valid_From;



@UncheckedAccess
FUNCTION Get_Valid_Until (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2,
   code_part_         IN VARCHAR2 ) RETURN DATE
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Valid_Until(company_, code_part_value_);

END Get_Valid_Until;



@UncheckedAccess
FUNCTION Get_Accounting_Text_Id (
   company_          IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   code_part_        IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN
   RETURN Account_API.Get_Accounting_Text_Id(company_, code_part_value_);
END Get_Accounting_Text_Id;


@UncheckedAccess
FUNCTION Get_Description (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2,
   code_part_         IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Description(company_, code_part_value_);

END Get_Description;



@UncheckedAccess
FUNCTION Get_Description (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2,
   code_part_         IN VARCHAR2,
   lang_code_         IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN Account_API.Get_Description(company_, code_part_value_);

END Get_Description;



PROCEDURE Get_Description (
  attribute_value_    IN OUT VARCHAR2,
  company_            IN     VARCHAR2,
  accnt_              IN     VARCHAR2 ) IS
 --
BEGIN
  attribute_value_ := Accounting_code_part_a_api.Get_Description( company_, accnt_ );
END Get_Description;


@UncheckedAccess
FUNCTION Get_Description (
   company_  IN VARCHAR2,
   accnt_    IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Description(company_, accnt_);

END Get_Description;



PROCEDURE Check_Delete_Allowed (
   company_         IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   code_part_       IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Check_Delete_Allowed(company_, code_part_value_);

END Check_Delete_Allowed;


PROCEDURE Validate_Code_Part (
   result_             OUT VARCHAR2,
   company_         IN     VARCHAR2,
   code_part_value_ IN     VARCHAR2,
   code_part_       IN     VARCHAR2,
   date_            IN     DATE )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Code_Part(result_, company_,code_part_value_, date_);

END Validate_Code_Part;


FUNCTION Validate_Code_Part (
   company_         IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   code_part_       IN VARCHAR2,
   date_            IN DATE ) RETURN BOOLEAN
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Validate_Code_Part(company_, code_part_value_, date_);

END Validate_Code_Part;


FUNCTION Exist_Code_Part_Value (
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Exist_Code_Part_Value(company_);

END Exist_Code_Part_Value;


PROCEDURE Check_Valid_From_To (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2,
   code_part_         IN VARCHAR2,
   valid_from_        IN DATE,
   valid_to_          IN DATE )
IS
BEGIN


-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Check_Valid_From_To(company_, code_part_value_, valid_from_, valid_to_);

END Check_Valid_From_To;


PROCEDURE New_Code_Part_Value (
   attr_  IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.New_Code_Part_Value(attr_);

END New_Code_Part_Value;


PROCEDURE Modify_Code_Part_Value (
   attr_  IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Modify_Code_Part_Value(attr_);

END Modify_Code_Part_Value;


PROCEDURE Remove_Code_Part_Value (
   attr_  IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Remove_Code_Part_Value(attr_);

END Remove_Code_Part_Value;


PROCEDURE Get_Curr_Balance (
  curr_balance_    IN OUT VARCHAR2,
  company_         IN     VARCHAR2,
  accnt_           IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Curr_Balance(curr_balance_, company_, accnt_);

END Get_Curr_Balance;


@UncheckedAccess
FUNCTION Get_Currency_Balance (
   company_           IN VARCHAR2,
   accnt_             IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Currency_Balance(company_, accnt_);

END Get_Currency_Balance;


PROCEDURE Get_Account_Info (
   description_            OUT VARCHAR2,
   alfasort_               OUT VARCHAR2,
   valid_from_             OUT DATE,
   valid_until_            OUT DATE,
   accounting_text_id_     OUT VARCHAR2,
   accnt_group_            OUT VARCHAR2,
   accnt_type_             OUT VARCHAR2,
   process_code_           OUT VARCHAR2,
   ledg_flag_              OUT VARCHAR2,
   curr_rate_              OUT NUMBER,
   curr_balance_           OUT VARCHAR2,
   conv_factor_            OUT NUMBER,
   text_                   OUT VARCHAR2,
   company_             IN     VARCHAR2,
   account_             IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Account_Info (description_, valid_from_, valid_until_, accounting_text_id_,
         accnt_group_, accnt_type_, process_code_, ledg_flag_,
         curr_rate_, curr_balance_, conv_factor_, text_, company_, account_ );

END Get_Account_Info;


PROCEDURE Change_Account_Code_Parts (
   count_        OUT NUMBER,
   attr_      IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Change_Account_Code_Parts(count_, attr_);

END Change_Account_Code_Parts;


@UncheckedAccess
FUNCTION Get_Code_Part_Demand (
   company_    IN VARCHAR2,
   account_    IN VARCHAR2,
   code_part_  IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Code_Part_Demand(company_, account_, code_part_);

END Get_Code_Part_Demand;



-- Is_Ledger_Account
--   Checks if the account is a Ledger account.
--   The function returns the boolean values TRUE or FALSE.
--   Exception if account doesn't exist
--   Is_Ledger_Account (2)
--   Checks if the account is a Ledger account.
--   The function returns the character values  'TRUE' or 'FALSE'.
--   Company Consolidation functions
PROCEDURE Is_Ledger_Account (
   result_          OUT VARCHAR2,
   company_      IN     VARCHAR2,
   accnt_        IN     VARCHAR2   )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Is_Ledger_Account(result_, company_, accnt_);

END Is_Ledger_Account;


-- Is_Ledger_Account
--   Checks if the account is a Ledger account.
--   The function returns the boolean values TRUE or FALSE.
--   Exception if account doesn't exist
--   Is_Ledger_Account (2)
--   Checks if the account is a Ledger account.
--   The function returns the character values  'TRUE' or 'FALSE'.
--   Company Consolidation functions
FUNCTION Is_Ledger_Account (
   company_     IN VARCHAR2,
   accnt_       IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Is_Ledger_Account(company_, accnt_);

END Is_Ledger_Account;


@UncheckedAccess
FUNCTION Is_Stat_Account (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Is_Stat_Account(company_, code_part_value_);

END Is_Stat_Account;



PROCEDURE Validate_Accnt (
   result_            OUT VARCHAR2,
   company_        IN     VARCHAR2,
   accnt_          IN     VARCHAR2,
   voucher_date_   IN     DATE     )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Accnt(result_, company_, accnt_, voucher_date_);

END Validate_Accnt;


FUNCTION Validate_Accnt (
   company_       IN VARCHAR2,
   accnt_         IN VARCHAR2,
   voucher_date_  IN DATE ) RETURN BOOLEAN
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Validate_accnt(company_, accnt_, voucher_date_);

END Validate_Accnt;


PROCEDURE Get_Required_Code_Part (
   req_string_         OUT VARCHAR2,
   company_         IN     VARCHAR2,
   accnt_           IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Required_Code_Part(req_string_, company_, accnt_);

END Get_Required_Code_Part;


@UncheckedAccess
FUNCTION Get_Required_Code_Part (
   company_        IN VARCHAR2,
   accnt_          IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Required_Code_Part(company_, accnt_);

END Get_Required_Code_Part;



PROCEDURE Get_Required_Code_Part (
   req_rec_      OUT Accounting_Codestr_API.CodestrRec,
   company_   IN     VARCHAR2,
   accnt_     IN     VARCHAR2)

IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Required_Code_Part(req_rec_, company_, accnt_);

END Get_Required_Code_Part;


PROCEDURE Get_Required_Code_Part (
   req_code_b_        OUT VARCHAR2,
   req_code_c_        OUT VARCHAR2,
   req_code_d_        OUT VARCHAR2,
   req_code_e_        OUT VARCHAR2,
   req_code_f_        OUT VARCHAR2,
   req_code_g_        OUT VARCHAR2,
   req_code_h_        OUT VARCHAR2,
   req_code_i_        OUT VARCHAR2,
   req_code_j_        OUT VARCHAR2,
   req_text_          OUT VARCHAR2,
   req_process_code_  OUT VARCHAR2,
   company_           IN  VARCHAR2,
   accnt_             IN  VARCHAR2 ) IS
   --
   CURSOR get_req IS
      SELECT req_code_b,
             req_code_c,
             req_code_d,
             req_code_e,
             req_code_f,
             req_code_g,
             req_code_h,
             req_code_i,
             req_code_j,
             req_text,
             req_process_code
      FROM   accounting_code_part_value_tab
       WHERE Company = company_
       AND   Code_part = 'A'
       AND   Code_part_value = accnt_;
   --
   noaccnt           EXCEPTION;
BEGIN
   OPEN get_req;
   FETCH get_req INTO req_code_b_,
                      req_code_c_,
                      req_code_d_,
                      req_code_e_,
                      req_code_f_,
                      req_code_g_,
                      req_code_h_,
                      req_code_i_,
                      req_code_j_,
                      req_text_,
                      req_process_code_;
    IF (get_req%NOTFOUND) THEN
       CLOSE get_req;
       RAISE noaccnt;
    END IF;
   CLOSE get_req;
 EXCEPTION
   WHEN noaccnt THEN
       Error_SYS.record_general(lu_name_, 'NOACCNTREQ: Account :P1 is missing in company :P2', accnt_, company_ );
END Get_Required_Code_Part;


PROCEDURE Get_Required_Code_Part_Pseudo (
   req_string_         OUT VARCHAR2,
   company_         IN     VARCHAR2,
   accnt_           IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Required_Code_Part_Pseudo(req_string_, company_, accnt_);

END Get_Required_Code_Part_Pseudo;


PROCEDURE Get_Process_Code (
  process_code_          OUT VARCHAR2,
  company_            IN     VARCHAR2,
  accnt_              IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Process_Code(process_code_, company_, accnt_);

END Get_Process_Code;


PROCEDURE Get_Accnt_Group (
   accnt_group_        OUT VARCHAR2,
  company_          IN     VARCHAR2,
  accnt_            IN     VARCHAR2 )
IS
BEGIN


-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Accnt_Group(accnt_group_, company_, accnt_);
END Get_Accnt_Group;


@UncheckedAccess
FUNCTION Get_Accnt_Group (
  company_   IN VARCHAR2,
  accnt_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Accnt_Group(company_, accnt_);

END Get_Accnt_Group;



PROCEDURE Get_Accnt_Type (
  accnt_type_          OUT VARCHAR2,
  company_          IN     VARCHAR2,
  accnt_            IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Get_Accnt_Type(accnt_type_, company_, accnt_);

END Get_Accnt_Type;


@UncheckedAccess
FUNCTION Get_Accnt_Type (
  company_   IN VARCHAR2,
  accnt_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Accnt_Type(company_, accnt_);
END Get_Accnt_Type;



@UncheckedAccess
FUNCTION Get_Accnt_Type_Db (
  company_   IN VARCHAR2,
  accnt_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Accnt_Type_Db(company_, accnt_);

END Get_Accnt_Type_Db;


FUNCTION Is_Codepart_Blocked (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Is_Codepart_Blocked(company_, code_part_);

END Is_Codepart_Blocked;


PROCEDURE Exist_Account_And_Pseudo (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Exist_Account_And_Pseudo(company_, code_part_value_);

END Exist_Account_And_Pseudo;


@UncheckedAccess
FUNCTION Get_Demand_String (
   company_      IN VARCHAR2,
   account_      IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Demand_String(company_, account_);

END Get_Demand_String;



PROCEDURE Validate_Account (
   demand_string_     OUT VARCHAR2,
   company_        IN     VARCHAR2,
   account_        IN     VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Validate_Account(demand_string_, company_, account_);

END Validate_Account;


@UncheckedAccess
FUNCTION Get_Quantity_Demand (
   company_           IN VARCHAR2,
   code_part_         IN VARCHAR2,
   code_part_value_   IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   RETURN ACCOUNT_API.Get_Quantity_Demand(company_, code_part_value_);

END Get_Quantity_Demand;



PROCEDURE Account_Exist (
  company_        IN VARCHAR2 ,
  accnt_type_     IN VARCHAR2)
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   ACCOUNT_API.Account_Exist(company_, accnt_type_);

END Account_Exist;


FUNCTION Code_Exists (
   company_      IN     VARCHAR2,
   accnt_        IN     VARCHAR2,
   voucher_date_ IN     DATE ) RETURN BOOLEAN 
IS
BEGIN
   IF accnt_ IS NOT NULL THEN
       IF Accounting_Code_Part_A_API.Validate_Accnt(company_, accnt_, voucher_date_) THEN
           RETURN TRUE;
       ELSE
           RETURN FALSE;
       END IF;
   END IF;
   RETURN FALSE;
END Code_Exists;




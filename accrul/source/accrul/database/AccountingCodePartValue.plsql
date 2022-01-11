-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodePartValue
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960404  MIJO  Created.
--  960528  ToRe  Validation of ac code part is only performed if not null in
--                function Validate_Code_Part.
--  970624  SLKO  Converted to Foundation1 1.2.2d
--  970627  PICZ  Added columns: CONS_COMPANY abd CONS_CODE_PART_VALUE;
--                procedure Validate_Cons_Value___;
--                Consolidation functions: Validate_Parent_Code_Part_Val  and
--                Clear_Parent_Code_Part_Val
--  970722  PICZ  Removed call to Validate_Cons_Value___ in Unpack_Check_Insert___;
--                Fixed uncorrect checks for cons_company and cons_code_part_value
--                Added method Calcul_Parent_Code_Part_Value
--  970901  PICZ  Added function Codepart_Exist_In_Cons_Company
--  970812  ANDJ  Fixed Bug 97-0033. Changed description_ to VARCHAR2(100).
--  971001  PICZ  Fixed bug in Get_Cons_Code_Part_Value
--  971103  PICZ  Fixed bug in Validate_Cons_Value___: veryfing aginst consolidation
--                code part and consolidation company
--  980107  SLKO  Converted to Foundation1 2.0.0
--  980123  PICZ  Added function: Code_Part_Value_Exist
--  980211  PICZ  Added Are_Changed_Values
--  980217  PICZ  Changed condition in Are_Changed_Values's cursor;
--                removed outputs
--  980225  PICZ  Added column CONS_CODE_PART
--  980325  PICZ  Changed Unpack_Check_Insert (bug 1315)
--  980811  Kanchi Added view Code_P_Value_For_Cons_Tmp for orrection bug #4975 Kanchi
--  980708  Kanchi Modified this file to redirect all functions calls to Code_* Lu ( code*.ap*)
--                 [ Moving Code Parts to individual LU:s ]
--                 Ex.  Accounting_Code_Part_Value    -->   CodeB Lu:
                                                      -->   CodeC Lu: etc
--  980916  Ruwan  Removed the Get_Description overloaded function(Bug ID:4973)
--  990416  Ruwan  Modified with respect to new template
--  010219  ARMOLK Bug # 15677 Add call to General_SYS.Init_Method
--  010221  ToOs   Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010410  JeGu   Bug #21018 Changed some functions/procedures wich are common to all codepart-LU's
--                 ** From now all this type of functions/procedures are put in this package **
--  010509  JeGu     Bug #21705 Implementation New Dummyinterface
--  010531  NiWi   #20510 - New veiw ACCOUNTING_CODEPART_VAL_FINREP is added (to used only in finrep)
--  010612  ARMOLK Bug # 15677 Add call to General_SYS.Init_Method
--  010922  Chablk Bug # 22010 fixed. Add a new column accnt_type to Accounting_Code_Part_value view
--  020207  MaNi   Company Translation support, replaced TextFielsTranslation.
--  020826  Rora  Bug# 32112 ,added new functiona called Check_Cons_Code_Part_Value.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in ACCOUNTING_CODE_PART_VALUE
--                   CODE_PART_VALUE_FOR_CONS and CODE_P_VALUE_FOR_CONS_TMP view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021211  ovjose Added the field description to LU.
--  021224  ISJALK SP3 merge, Bug 34188.
--  030618  Thsrlk   IIID DEFI159N - Add new view BUDGET_ACC_CODE_PART_VALUE
--  050201  nsillk   Merged Bug 42667.
--  051024  Nsillk  Removed views BUDGET_ACC_CODE_PART_VALUE and CODE_P_VALUE_FOR_CONS_TMP
--                  because they are not used anymore.
--  051229  Nsillk  LCS Merge (54796/54798).
--  050103  Nsillk  Added view BUDGET_ACC_CODE_PART_VALUE because it is used.
--  060215  Nsillk  Changed the size of sort_value to 20.
--  060727  DHSELK  Modified to_date() function to work with Persian Calander.
--  081022  MAKRLK  Bug 76650 corrected. Added new method Validate_Code_Part().
--  090605  THPELK  Bug 82609 - Removed the aditional UNDEFINE statement for VIEW_CONS_TMP.
--  091209  HimRlk  Reverse engineering, Added REF to AccountingCodeParts from column code_part in view comments
--  091209          in ACCOUNTING_CODE_PART_VALUE view.
--  110322  DIFELK  RAVEN-1930, modifications done to Check_Delete___ related code.
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110826  MAAYLK  FIDEAGLE-306 LCS Merge 95982, Moved method Validate_Cons_Value__(), Get_Code_Part_Function__() methods in other code part pkgs into this package
--  111018  Shdilk  SFI-135, Conditional compilation.
--  120514  SALIDE   EDEL-698, Added VIEW_AUDIT
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk  PEPA-183, Removed global variables
--  130816  Clstlk  Bug 111221, Corrected functions without RETURN statement in all code paths.
--  131101  Hiralk  PBFI-572, Removed obsolete lu NcfNorwegianTax.
--  131204  Janblk  PBFI-892, Refactoring in AccountingCodePartValue entity
--  131204  MEALLK  PBFI-1984, modified code in Get_Description.
--  131205  MEALLK  PBFI-1985, modifed code in Get_Description.
--  150810  Maaylk  Bug 123649, Added code to check if code_part exists in Code_part_value tab into Check_Delete___()
--  151228  PRatlk  FINGP-21, Merging of GroconCodepartValue with AccoutingCodepartValue.
--  171122  KhVeSE  STRSC-10938, Added methods Create_Data_Capture_Lov and Get_Column_Value_If_Unique for WADACO process
--  180108  KhVeSE  STRSC-10938, Removed parameter sql_where_expression_ from methods Create_Data_Capture_Lov and Get_Column_Value_If_Unique
--  181823  Nudilk  Bug 143758, Corrected.
--  190610  Nudilk  Bug 148662, Corrected.
--  200311  DaZase  SCXTEND-3803, Small change in Create_Data_Capture_Lov to change 1 param in call to Data_Capture_Session_Lov_API.New.
--  200922  Jadulk  FISPRING20-6695, Removed CONACC related obsolete component logic.
-- **************************************************************************************
-- ** DO NOT MODIFY ANY FUNCTION IN THIS FILE. DO ALL MODIFICATIONS IN THE CORRECT LU: **
--    IT WILL ONLY BE WITH COMMON FUNCS/PROCS WHICH ARE COMMON TO ALL THE LUs.
--    ALL VIEWS ARE COPIED TO CODE_* LU,
--     ***  WHEN MODIFIYING VIEWS PLEASE REFLECT THE CHANGE IN BOTH FILES  ( Accounting_Code_Part_Value   AND  Code_* Lu )
--    In all views in the Code_* lus, Code_Part is removed and Code_Part_Value
--    is renamed to Code_*.
--    ex.   Accounting_Code_Part_value          Code_B        Code_C      Code_D
--          ---------------------------------------------------------------------
--                 CODE_PART_VALUE              CODE_B        CODE_C      CODE_D
-- *************************************************************************************
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------
TYPE Public_Rec IS RECORD
  (company                        ACCOUNTING_CODE_PART_VALUE_TAB.company%TYPE,
   code_part_value                ACCOUNTING_CODE_PART_VALUE_TAB.code_part_value%TYPE,
   "rowid"                        rowid,
   rowversion                     ACCOUNTING_CODE_PART_VALUE_TAB.rowversion%TYPE,
   rowkey                         ACCOUNTING_CODE_PART_VALUE_TAB.rowkey%TYPE,
   rowtype                        ACCOUNTING_CODE_PART_VALUE_TAB.rowtype%TYPE,
   valid_from                     ACCOUNTING_CODE_PART_VALUE_TAB.valid_from%TYPE,
   valid_until                    ACCOUNTING_CODE_PART_VALUE_TAB.valid_until%TYPE,
   accounting_text_id             ACCOUNTING_CODE_PART_VALUE_TAB.accounting_text_id%TYPE);


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
PROCEDURE Raise_Too_Many_Rows___ (
   company_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   methodname_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Too_Many_Rows(Accounting_Code_Part_Value_API.lu_name_, NULL, methodname_);
END Raise_Too_Many_Rows___;

PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 )
IS   
BEGIN
   Error_SYS.Record_Not_Exist(Accounting_Code_Part_Value_API.lu_name_);
END Raise_Record_Not_Exist___;



FUNCTION Check_Exist___ (
   company_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
BEGIN
   SELECT 1
      INTO  dummy_
      FROM  accounting_code_part_value_tab
      WHERE company = company_
      AND   code_part_value = code_part_value_;
   RETURN TRUE;
EXCEPTION
   WHEN no_data_found THEN
      RETURN FALSE;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(company_, code_part_value_, 'Check_Exist___');
END Check_Exist___;


PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   company_        ACCOUNTING_CODE_PART_VALUE_TAB.company%TYPE;
BEGIN
   company_      := Client_SYS.Get_Item_Value( 'COMPANY', attr_ );
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr( 'VALID_FROM', SYSDATE, attr_);
   Client_SYS.Add_To_Attr( 'VALID_UNTIL', to_date('20991231', 'YYYYMMDD', 'NLS_CALENDAR=GREGORIAN'), attr_);
END Prepare_Insert___;


@SecurityCheck Company.UserExist(remrec_.company)
PROCEDURE Check_Delete___ (
   remrec_ IN ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE )
IS
   key_      VARCHAR2(2000);
   used_     VARCHAR2(5);
   function_ VARCHAR2(10);
BEGIN
   -- <<<Put your code here for all attribute checking before deleting object>>>
   function_ := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(remrec_.company, remrec_.code_part);  
   
   -- Check, if codepart value is used either in wait table or in general ledger ...
   used_ := Voucher_Row_API.Is_Code_Part_Value_Used(remrec_.company,
                                                    remrec_.code_part,
                                                    remrec_.code_part_value);
   IF (used_ = 'TRUE') THEN
      IF (function_ = 'FAACC') THEN
         Error_SYS.Record_General(lu_name_,
                                  'CHKDELFA_1: Object :P1 is used in wait table',
                                  remrec_.code_part_value);      
      ELSIF (function_ = 'PRACC') THEN
         Error_SYS.Record_General(lu_name_,
                                  'CHKDELPR_1: Project :P1 is used in wait table',
                                  remrec_.code_part_value);      
      ELSE
         Error_SYS.Record_General(lu_name_,
                                  'CHKDEL_1: Codepart value :P1 is used in wait table',
                                  remrec_.code_part_value);
      END IF;   
   END IF;

   $IF Component_Genled_SYS.INSTALLED $THEN
      Gen_Led_Voucher_Row_API.Is_Code_Part_Value_Used(remrec_.company,
                                                      remrec_.code_part,
                                                      remrec_.code_part_value);

      Budget_Year_Amount_API.Exist_Code_Part_Value(remrec_.company,
                                                   remrec_.code_part,
                                                   remrec_.code_part_value);
   $END
   $IF Component_Intled_SYS.INSTALLED $THEN
      Internal_Hold_Voucher_Row_API.Is_Code_Part_Value_Used(remrec_.company,
                                                            remrec_.code_part,
                                                            remrec_.code_part_value );
      
      Internal_Voucher_Row_API.Is_Code_Part_Value_Used(remrec_.company,
                                                       remrec_.code_part,
                                                       remrec_.code_part_value );
   $END
   IF NOT Accounting_Codestr_Compl_API.Check_Delete_Allowed_( remrec_.company, remrec_.code_part_value, remrec_.code_part) THEN
      IF (function_ = 'FAACC') THEN
         Error_SYS.Record_General(lu_name_,
                                  'OBEXISTINCOMPL: Delete not allowed. Object :P1 exist in codestring completion.',
                                  remrec_.code_part_value);      
      ELSIF (function_ = 'PRACC') THEN
         Error_SYS.Record_General(lu_name_,
                                  'PREXISTINCOMPL: Delete not allowed. Project :P1 exist in codestring completion.',
                                  remrec_.code_part_value);
      ELSE
         Error_SYS.Record_General(lu_name_,
                                  'CPEXISTINCOMPL: Delete not allowed. Codepart value :P1 exist in codestring completion.',
                                  remrec_.code_part_value);
      END IF;   
   END IF;   
   Check_Delete_Allowed2(remrec_.company, remrec_.code_part_value, remrec_.code_part, function_);

   key_ := remrec_.company||'^'||remrec_.code_part||'^'||remrec_.code_part_value||'^';
   Reference_SYS.Check_Restricted_Delete(lu_name_, key_);   
END Check_Delete___;



PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE )
IS
   key_ VARCHAR2(2000);
BEGIN
   key_ := remrec_.company||'^'||remrec_.code_part_value||'^';
   Reference_SYS.Do_Cascade_Delete(lu_name_, key_);
   DELETE
      FROM  accounting_code_part_value_tab
      WHERE rowid = objid_;

  Enterp_Comp_Connect_V170_API.Remove_Company_Attribute_Key( remrec_.company,
                                                              'ACCRUL',
                                                              Get_Lu_For_Code_Part__(remrec_.company, remrec_.code_part),
                                                              remrec_.code_part_value );       
END Delete___;


FUNCTION Check_Exist___ (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   accounting_code_part_value_tab
      WHERE  company = company_
      AND    code_part = code_part_
      AND    code_part_value = code_part_value_;
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

FUNCTION Get_Object_By_Keys___ (
   company_ IN VARCHAR2,
   code_part_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN accounting_code_part_value_tab%ROWTYPE
IS
   lu_rec_ accounting_code_part_value_tab%ROWTYPE;
   CURSOR getrec IS
      SELECT *
      FROM  accounting_code_part_value_tab
      WHERE company = company_
      AND   code_part = code_part_
      AND   code_part_value = code_part_value_;
BEGIN
   OPEN getrec;
   FETCH getrec INTO lu_rec_;
   CLOSE getrec;
   RETURN(lu_rec_);
END Get_Object_By_Keys___;

FUNCTION Get_Object_By_Id___ (
   objid_ IN VARCHAR2 ) RETURN accounting_code_part_value_tab%ROWTYPE
IS
   lu_rec_ accounting_code_part_value_tab%ROWTYPE;
   CURSOR getrec IS
      SELECT *
      FROM   accounting_code_part_value_tab
      WHERE  rowid = objid_;
BEGIN
   OPEN getrec;
   FETCH getrec INTO lu_rec_;
   IF (getrec%NOTFOUND) THEN
      Error_SYS.Record_Removed(lu_name_);
   END IF;
   CLOSE getrec;
   RETURN(lu_rec_);
END Get_Object_By_Id___;

FUNCTION Lock_By_Id___ (
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2 ) RETURN accounting_code_part_value_tab%ROWTYPE
IS
   row_changed EXCEPTION;
   row_deleted EXCEPTION;
   row_locked  EXCEPTION;
   PRAGMA      exception_init(row_locked, -0054);
   rec_        accounting_code_part_value_tab%ROWTYPE;
   dummy_      NUMBER;
   CURSOR lock_control IS
      SELECT *
      FROM   accounting_code_part_value_tab
      WHERE  rowid = objid_
      AND    ltrim(lpad(to_char(rowversion,'YYYYMMDDHH24MISS'),2000)) = objversion_
      FOR UPDATE NOWAIT;
   CURSOR exist_control IS
      SELECT 1
      FROM   accounting_code_part_value_tab
      WHERE  rowid = objid_;
BEGIN
   OPEN lock_control;
   FETCH lock_control INTO rec_;
   IF (lock_control%FOUND) THEN
      CLOSE lock_control;
      RETURN rec_;
   END IF;
   CLOSE lock_control;
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RAISE row_changed;
   ELSE
      CLOSE exist_control;
      RAISE row_deleted;
   END IF;
EXCEPTION
   WHEN row_locked THEN
      Error_SYS.Record_Locked(lu_name_);
   WHEN row_changed THEN
      Error_SYS.Record_Modified(lu_name_);
   WHEN row_deleted THEN
      Error_SYS.Record_Removed(lu_name_);
END Lock_By_Id___;

@UncheckedAccess
PROCEDURE Lock__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2 )
IS
   dummy_ accounting_code_part_value_tab%ROWTYPE;
BEGIN
   dummy_ := Lock_By_Id___(objid_, objversion_);
   info_ := Client_SYS.Get_All_Info;
END Lock__;

-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated
FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___;

PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_       IN VARCHAR2,
   target_company_list_  IN VARCHAR2,
   code_part_            IN VARCHAR2,
   code_part_value_list_ IN VARCHAR2,
   update_method_list_   IN VARCHAR2,
   log_id_               IN NUMBER,
   attr_                 IN VARCHAR2 DEFAULT NULL)
IS
   TYPE code_part_value IS TABLE OF accounting_code_part_value_tab.code_part_value%TYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                            
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         accounting_code_part_value_tab.company%TYPE;
   ref_code_part_value_    code_part_value;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr2_ := NULL;
   ptr1_ := NULL;
   i_    := 0;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_value_list_) LOOP
      ref_code_part_value_(i_):= value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_code_part_value_.FIRST..ref_code_part_value_.LAST LOOP 
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 code_part_,
                                 ref_code_part_value_(j_),      
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE New__ (
   info_       OUT    VARCHAR2,
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   code_part_      VARCHAR2(1);
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   code_part_ := Client_SYS.Get_Item_Value('CODE_PART', attr_);
   IF    (code_part_ = 'B') THEN
      Code_B_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.New__(info_, objid_, objversion_, attr_, action_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.New__(info_, objid_, objversion_, attr_, action_);
   END IF;
END New__;



PROCEDURE Modify__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   newrec_ ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE;
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   newrec_ := Get_Object_By_Id___(objid_);
   IF    (newrec_.code_part = 'B') THEN
      Code_B_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'C') THEN
      Code_C_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'D') THEN
      Code_D_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'E') THEN
      Code_E_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'F') THEN
      Code_F_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'G') THEN
      Code_G_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'H') THEN
      Code_H_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'I') THEN
      Code_I_API.Modify__(info_, objid_, objversion_, attr_, action_);
   ELSIF (newrec_.code_part = 'J') THEN
      Code_J_API.Modify__(info_, objid_, objversion_, attr_, action_);
   END IF;
END Modify__;



PROCEDURE Remove__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2,
   action_     IN  VARCHAR2 )
IS
   remrec_ ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE;
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   remrec_ := Get_Object_By_Id___(objid_);
   IF    (remrec_.code_part = 'B') THEN
      Code_B_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'C') THEN
      Code_C_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'D') THEN
      Code_D_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'E') THEN
      Code_E_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'F') THEN
      Code_F_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'G') THEN
      Code_G_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'H') THEN
      Code_H_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'I') THEN
      Code_I_API.Remove__(info_, objid_, objversion_, action_);
   ELSIF (remrec_.code_part = 'J') THEN
      Code_J_API.Remove__(info_, objid_, objversion_, action_);
   END IF;
END Remove__;


@UncheckedAccess
FUNCTION Get_Lu_For_Code_Part__ (
   company_ IN VARCHAR2,
   code_part_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_       Accounting_Code_Parts_API.Public_Rec;   
   lu_name_    VARCHAR2(30);
BEGIN
   temp_ := Accounting_Code_Parts_API.Get(company_, code_part_);   
   IF (temp_.code_part_function = 'FAACC') THEN
      lu_name_ := 'FaObject';
   ELSIF (temp_.code_part_function = 'PRACC') THEN
      lu_name_ := 'AccountingProject';      
   ELSE
      IF (code_part_ = 'A') THEN
         lu_name_ := 'Account';
      ELSE
         lu_name_ := 'Code'||code_part_;
      END IF;
   END IF;
   RETURN lu_name_;
END Get_Lu_For_Code_Part__;


@UncheckedAccess
FUNCTION Get_Code_Part_Function__(
   company_       IN VARCHAR2,
   code_part_     IN VARCHAR2) RETURN VARCHAR2
IS
   temp_       Accounting_Code_Parts_API.Public_Rec;
BEGIN
   temp_ := Accounting_Code_Parts_API.Get(company_, code_part_);
   IF temp_.code_part_function IS NULL THEN
      RETURN 'NULL';
   END IF;
   RETURN temp_.code_part_function;
END Get_Code_Part_Function__;


PROCEDURE Copy_To_Companies__ (
   source_company_  IN VARCHAR2,
   target_company_  IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   update_method_   IN VARCHAR2,
   log_id_          IN NUMBER,
   attr_            IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
   IF (code_part_ = 'A') THEN
      Account_API.Copy_To_Companies__(source_company_,
                                      target_company_,
                                      code_part_value_,
                                      update_method_,
                                      log_id_,
                                      attr_);
   END IF;
   IF (code_part_ = 'B') THEN
      Code_B_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);      
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.Copy_To_Companies__(source_company_,
                                     target_company_,
                                     code_part_value_,
                                     update_method_,
                                     log_id_,
                                     attr_);         
   END IF;
END Copy_To_Companies__;

PROCEDURE Check_Fa_Object_Or_Project__(
   company_   IN VARCHAR2,
   code_part_ IN VARCHAR2)
IS
   code_part_function_    accounting_code_part_tab.code_part_function%TYPE;
BEGIN
   code_part_function_ := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(company_,code_part_);
   IF (code_part_function_ = 'FAACC') THEN
      Error_SYS.Record_General(lu_name_,'FAACCCODEPARTCANNOTMODIFY: You cannot create, modify or delete a fixed asset object using this window. Use Object window in the Fixed Assets component instead.');
   END IF;
   IF (code_part_function_ = 'PRACC') THEN
      Error_SYS.Record_General(lu_name_,'PRACCCODEPARTCANNOTMODIFY: You cannot create, modify or delete a project using this window. Use Project window in the General Ledger component instead.');
   END IF;
END Check_Fa_Object_Or_Project__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                  NUMBER;
   name_                 VARCHAR2(200);
   value_                VARCHAR2(32000);
   source_company_       VARCHAR2(100);
   code_part_            VARCHAR2(1);
   code_part_value_list_ VARCHAR2(32000);
   target_company_list_  VARCHAR2(32000);
   update_method_list_   VARCHAR2(32000);
   copy_type_            VARCHAR2(100);
   attr1_                VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         source_company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'CODE_PART') THEN
         code_part_ := value_;         
      ELSIF (name_ = 'CODE_PART_VALUE_LIST') THEN
         code_part_value_list_ := value_;
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(source_company_,
                      target_company_list_,
                      code_part_,
                      code_part_value_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;


PROCEDURE Copy_To_Companies_ (
   source_company_       IN VARCHAR2,
   target_company_list_  IN VARCHAR2,
   code_part_            IN VARCHAR2,
   code_part_value_list_ IN VARCHAR2,
   update_method_list_   IN VARCHAR2,
   copy_type_            IN VARCHAR2,
   attr_                 IN VARCHAR2 DEFAULT NULL)
IS
   TYPE code_part_value IS TABLE OF accounting_code_part_value_tab.code_part_value%TYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                            
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         accounting_code_part_value_tab.company%TYPE;
   ref_code_part_value_    code_part_value;
   ref_attr_               attr;
   log_id_                 NUMBER;
   window_lu_name_         VARCHAR2(10);
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr2_ := NULL;
   ptr1_ := NULL;
   i_    := 0;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, code_part_value_list_) LOOP
      ref_code_part_value_(i_):= value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   IF (target_company_list_ IS NOT NULL) THEN
      window_lu_name_ := 'Code'||code_part_;
      Copy_Basic_Data_Log_API.Create_New_Record(log_id_, source_company_, copy_type_, Basic_Data_Window_API.Get_Window(window_lu_name_));
   END IF;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_code_part_value_.FIRST..ref_code_part_value_.LAST LOOP 
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 code_part_,
                                 ref_code_part_value_(j_),      
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Is_Budget_Code_Part (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2)RETURN BOOLEAN 
IS
   bud_code_part_ accounting_code_part_value_tab.code_part_value%TYPE;
   
   CURSOR get_bud_code_part IS
      SELECT code_part_value
      FROM   accounting_code_part_value_tab
      WHERE  company              = company_
      AND    code_part            = code_part_
      AND    code_part_value      = code_part_value_
      AND    NVL(bud_account,'N') = 'Y';   
BEGIN
   OPEN  get_bud_code_part;
   FETCH get_bud_code_part INTO bud_code_part_;
   IF (get_bud_code_part%FOUND) THEN
      CLOSE get_bud_code_part;
      RETURN TRUE;
   END IF;
  CLOSE get_bud_code_part;
  RETURN FALSE;
END Is_Budget_Code_Part;

PROCEDURE Validate_Budget_Value (
   rec_ IN accounting_code_part_value_tab%ROWTYPE )
IS
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      -- Check if CODE_B exist in Accounting_Balance
      IF (Accounting_Balance_API.Code_Part_Exist(rec_.company, rec_.code_part, rec_.code_part_value)) THEN
         Error_SYS.Record_General(lu_name_, 'CODEPARTEXISTS: The Code Part :P1 exist in general ledger and cannot be used', rec_.code_part_value);
      END IF;    
   $END
   
   -- Check if code part value exist in Holding Table
   IF (Voucher_Row_API.Code_Part_Exist(rec_.company, rec_.code_part, rec_.code_part_value)) THEN
      Error_SYS.Record_General(lu_name_, 'CODEBEXISTSVOUCHER: The code part :P1 exists in Hold Table', rec_.code_part_value);
   END IF;
   -- Check if code part value exist in Posting_Ctrl and Posting_Ctrl_Detail
   IF (Posting_Ctrl_API.Code_Part_Exist(rec_.company, rec_.code_part, rec_.code_part_value)) THEN
      Error_SYS.Record_General(lu_name_, 'CODEBPOSTEXISTS: The code part :P1 exists in posting control ', rec_.code_part_value);
   END IF;
END Validate_Budget_Value;

@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2, 
   code_part_value_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, code_part_value_)) THEN
      Raise_Record_Not_Exist___(company_, code_part_value_);
   END IF;
END Exist;


@UncheckedAccess
FUNCTION Exists (
   company_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN BOOLEAN
IS   
BEGIN
   RETURN Check_Exist___(company_, code_part_value_);
END Exists;

@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2,
   code_part_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 )
IS
BEGIN

-- Modifications 8.50 [ Move Codeparts ]
   IF    (code_part_ = 'A') THEN
      Accounting_Code_Part_A_API.Exist(company_,code_part_, code_part_value_);
   ELSIF (code_part_ = 'B') THEN
      Code_B_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'K') THEN
      Counter_Part_One_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'L') THEN
      Counter_Part_Two_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'M') THEN
      Currency_Code_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'N') THEN
      Code_N_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'O') THEN
      Code_O_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'P') THEN      
      Code_P_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'Q') THEN
      Code_Q_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'R') THEN
      Code_R_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'S') THEN
      Code_S_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'T') THEN
      Code_T_API.Exist(company_, code_part_value_);      
   END IF;
END Exist;

@UncheckedAccess
PROCEDURE Additional_Code_Part_Exist (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 )
IS
BEGIN
   IF (code_part_ = 'K') THEN
      Counter_Part_One_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'L') THEN
      Counter_Part_Two_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'N') THEN
      Code_N_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'O') THEN
      Code_O_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'P') THEN
      Code_P_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'Q') THEN
      Code_Q_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'R') THEN
      Code_R_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'S') THEN
      Code_S_API.Exist(company_, code_part_value_);
   ELSIF (code_part_ = 'T') THEN
      Code_T_API.Exist(company_, code_part_value_);   
   END IF;
END Additional_Code_Part_Exist;

@UncheckedAccess
FUNCTION Validate_Code_Part (
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2,
   budget_year_         IN NUMBER,
   period_              IN NUMBER,
   period_from_         IN NUMBER,
   period_to_           IN NUMBER,
   include_bud_account_ IN VARCHAR2 DEFAULT 'FALSE') RETURN BOOLEAN
IS
   date_from_   DATE;
   date_until_  DATE;

   from_date_range_from_  DATE;
   from_date_range_until_ DATE;
   to_date_range_from_    DATE;
   to_date_range_until_   DATE;
   min_period_            NUMBER;
   max_period_            NUMBER;
   bud_period_from_       NUMBER;
   bud_period_to_         NUMBER;
   dummy_                 VARCHAR2(1);

   CURSOR get_value IS
      SELECT 'X'
      FROM   accounting_code_part_value_tab
      WHERE  company         = company_
      AND    code_part       = code_part_
      AND    code_part_value = code_part_value_
      AND    (NVL(bud_account, 'N') = 'N' OR include_bud_account_ = 'TRUE')
      AND    (valid_from <= date_until_ AND valid_until >= date_from_);
BEGIN
   IF (code_part_value_ IS NOT NULL) THEN
      Accounting_Period_API.Get_Period_Date(date_from_,
                                            date_until_,
                                            company_,
                                            budget_year_,
                                            period_);

      bud_period_from_ := period_from_;
      bud_period_to_   := period_to_;

      IF (period_ IS NULL AND period_from_ IS NULL AND period_to_ IS NULL) THEN
         Accounting_Period_API.Get_Min_Max_Period(min_period_,
                                                  max_period_,
                                                  company_,
                                                  budget_year_);
         bud_period_from_ := min_period_;
         bud_period_to_   := max_period_;
      END IF;

      IF (period_ IS NULL) THEN
         Accounting_Period_API.Get_Period_Date (from_date_range_from_,
                                                from_date_range_until_,
                                                company_,
                                                budget_year_,
                                                bud_period_from_);

         Accounting_Period_API.Get_Period_Date (to_date_range_from_,
                                                to_date_range_until_,
                                                company_,
                                                budget_year_,
                                                bud_period_to_);

         date_until_ :=from_date_range_until_;
         date_from_  := to_date_range_from_;
      END IF;
      OPEN get_value;
      FETCH get_value INTO dummy_;
      IF (get_value%NOTFOUND) THEN
          CLOSE get_value;
          RETURN FALSE;
      ELSE
          CLOSE get_value;
         RETURN TRUE;
      END IF;
   END IF;
   RETURN TRUE;
END Validate_Code_Part;


PROCEDURE Validate_Code_Part (
   result_          OUT VARCHAR2,
   company_         IN  VARCHAR2,
   code_part_       IN  VARCHAR2,
   code_part_value_ IN  VARCHAR2,
   date_            IN  DATE )
IS
   dummy_      BOOLEAN;
BEGIN
   dummy_ := Validate_Code_Part(company_,
                                code_part_,
                                code_part_value_,
                                date_ );
   IF (dummy_) THEN
      result_ := 'TRUE' ;
   ELSE
      result_ := 'FALSE' ;
   END IF;
END  Validate_Code_Part;


@UncheckedAccess
FUNCTION Validate_Code_Part (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   date_             IN DATE,
   ignore_bud_account_  IN VARCHAR2 DEFAULT 'FALSE') RETURN BOOLEAN
IS
   tdate_   DATE := TRUNC(date_);
   dummy_   VARCHAR2(1);
   CURSOR get_value IS
     SELECT 'X'
     FROM   accounting_code_part_value_tab
     WHERE  company         = company_
     AND    code_part       = code_part_
     AND    code_part_value = code_part_value_
     AND    tdate_ BETWEEN valid_from AND valid_until
     AND    (NVL(bud_account, 'N') = 'N' OR ignore_bud_account_ = 'TRUE');
BEGIN
   IF (code_part_value_ IS NOT NULL) THEN
      OPEN get_value;
      FETCH get_value INTO dummy_;
      IF (get_value%NOTFOUND) THEN
         CLOSE get_value;
         RETURN FALSE;
      ELSE
         CLOSE get_value;
         RETURN TRUE;
      END IF;
   END IF;
   RETURN TRUE;
END Validate_Code_Part;


@UncheckedAccess
FUNCTION Validate_Code_Part (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   from_date_        IN DATE,
   untill_date_      IN DATE,
   ignore_bud_account_  IN VARCHAR2 DEFAULT 'FALSE') RETURN BOOLEAN
IS
   dummy_   VARCHAR2(1);
   CURSOR get_value IS
     SELECT 'X'
     FROM   accounting_code_part_value_tab
     WHERE  company         = company_
     AND    code_part       = code_part_
     AND    code_part_value = code_part_value_
     AND    (valid_from <= untill_date_
             AND valid_until >= from_date_)
     AND    (NVL(bud_account, 'N') = 'N' OR ignore_bud_account_ = 'TRUE');
BEGIN
   IF (code_part_value_ IS NOT NULL) THEN
      OPEN get_value;
      FETCH get_value INTO dummy_;
      IF (get_value%NOTFOUND) THEN
         CLOSE get_value;
         RETURN FALSE;
      ELSE
         CLOSE get_value;
         RETURN TRUE;
      END IF;
  END IF;
  RETURN TRUE;
END Validate_Code_Part;

@UncheckedAccess
FUNCTION Get_Description (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   lang_code_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
BEGIN
   -- Modifications 8.50 [ Move Codeparts ]
   IF    (code_part_ = 'A') THEN
      RETURN Account_API.Get_Description(company_, code_part_value_);
   ELSIF (code_part_ = 'B') THEN
      RETURN Code_B_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSIF (code_part_ = 'C') THEN
      RETURN Code_C_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSIF (code_part_ = 'D') THEN
      RETURN Code_D_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSIF (code_part_ = 'E') THEN
      RETURN Code_E_API.Get_Description(company_, code_part_value_);
   ELSIF (code_part_ = 'F') THEN
      RETURN Code_F_API.Get_Description(company_, code_part_value_);
   ELSIF (code_part_ = 'G') THEN
      RETURN Code_G_API.Get_Description(company_, code_part_value_);
   ELSIF (code_part_ = 'H') THEN
      RETURN Code_H_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSIF (code_part_ = 'I') THEN
      RETURN Code_I_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSIF (code_part_ = 'J') THEN
      RETURN Code_J_API.Get_Description(company_, code_part_value_, lang_code_);
   ELSE
      RETURN NULL;
   END IF;
END Get_Description;


@UncheckedAccess
FUNCTION Exist_Code_Part_Value (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_   VARCHAR2(1);
   CURSOR exist_value IS
     SELECT 'X'
     FROM   accounting_code_part_value_tab
     WHERE  company = company_
     AND    code_part = code_part_;
BEGIN
   OPEN exist_value;
   FETCH exist_value INTO dummy_;
   IF (exist_value%NOTFOUND) THEN
      CLOSE exist_value;
      RETURN FALSE;
   ELSE
      CLOSE exist_value;
      RETURN TRUE;
   END IF;
END Exist_Code_Part_Value;

FUNCTION Exist_Code_Part_Value2 (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
   IF Check_Exist___(company_, code_part_, code_part_value_) THEN
      RETURN(TRUE);
   END IF;
   RETURN(FALSE);
END Exist_Code_Part_Value2;


PROCEDURE Check_Valid_From_To (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   valid_from_       IN DATE,
   valid_to_         IN DATE )
IS
BEGIN
   IF (valid_from_ > valid_to_) THEN
      Error_SYS.Appl_General(lu_name_,'FROM_GT_TO: Valid from cannot be greater than valid to.');
   END IF;
END Check_Valid_From_To;


PROCEDURE New_Code_Part_Value (
   attr_ IN VARCHAR2 )
IS
   code_part_      VARCHAR2(1);
BEGIN
   -- Modifications 8.50 [ Move Codeparts ]
   code_part_ := Client_SYS.Get_Item_Value('CODE_PART', attr_);
   IF    (code_part_ = 'B') THEN
      Code_B_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'N') THEN
      Code_N_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'O') THEN
      Code_O_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'P') THEN
      Code_P_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'Q') THEN
      Code_Q_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'R') THEN
      Code_R_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'S') THEN
      Code_S_API.New_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'T') THEN
      Code_T_API.New_Code_Part_Value(attr_);
   END IF;
END New_Code_Part_Value;


PROCEDURE Modify_Code_Part_Value (
   attr_ IN VARCHAR2 )
IS
   code_part_      VARCHAR2(1);
BEGIN
   -- Modifications 8.50 [ Move Codeparts ]
   code_part_ := Client_SYS.Get_Item_Value('CODE_PART', attr_);
   IF    (code_part_ = 'A') THEN
      Account_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'B') THEN
      Code_B_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.Modify_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.Modify_Code_Part_Value(attr_);
   END IF;
END Modify_Code_Part_Value;


PROCEDURE Remove_Code_Part_Value (
   attr_ IN  VARCHAR2 )
IS
   code_part_      VARCHAR2(1);
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   code_part_ := Client_SYS.Get_Item_Value('CODE_PART', attr_);
   IF    (code_part_ = 'B') THEN
      Code_B_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.Remove_Code_Part_Value(attr_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.Remove_Code_Part_Value(attr_);
   END IF;
END Remove_Code_Part_Value;


@UncheckedAccess
FUNCTION Code_Part_Value_Exist (
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(company_, code_part_, code_part_value_) THEN
      RETURN ('TRUE');
   END IF;
   RETURN 'FALSE';
END Code_Part_Value_Exist;

@UncheckedAccess
PROCEDURE Code_Part_Value_Exist (
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2 )
IS
BEGIN
   IF (Code_Part_Value_Exist(company_, code_part_, code_part_value_) = 'FALSE') THEN
      Error_SYS.Record_Not_Exist(lu_name_,'NOTEXIST: "The :P2 code part value :P1 does not exists.',code_part_value_,Accounting_Code_Parts_API.Get_Name(company_, code_part_));
   END IF;   
END Code_Part_Value_Exist;


@UncheckedAccess
FUNCTION Generate_Sort_Value (
   code_part_value_ IN VARCHAR2) RETURN VARCHAR2
IS
   num_sort_value_  NUMBER;
   generated_value_ VARCHAR2(20);
BEGIN
   generated_value_ := code_part_value_;
   IF (code_part_value_ IS NOT NULL) THEN
      BEGIN
         num_sort_value_  := TO_NUMBER(code_part_value_);
         generated_value_ := LPAD(code_part_value_, 20, '0');
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   RETURN generated_value_;
END Generate_Sort_Value;


@UncheckedAccess
FUNCTION Are_Changed_Values (
   company_    IN VARCHAR2,
   date_from_  IN DATE,
   date_until_ IN DATE ) RETURN VARCHAR2
IS
   CURSOR get_changed_values IS
      SELECT code_part_value, valid_from, valid_until
      FROM   accounting_code_part_value_tab
      WHERE  company = company_
      AND    NVL(bud_account, 'N') = 'N';
BEGIN   
   IF (User_Finance_API.Is_User_Authorized(company_)) THEN
      FOR row_ IN get_changed_values LOOP
         IF (row_.valid_from > date_from_) THEN
            RETURN 'TRUE';
         END IF;
         IF (row_.valid_until < date_until_ AND row_.valid_until > date_from_) THEN
            RETURN 'TRUE';
         END IF;
      END LOOP;
      RETURN 'FALSE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Are_Changed_Values;


@UncheckedAccess
FUNCTION Get_Desc_For_Code_Part (
   company_ IN VARCHAR2,
   code_part_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 )  RETURN VARCHAR2
IS
   lu_name_ VARCHAR2(30);
   desc_    VARCHAR2(100);
   component_  VARCHAR2(30) :='ACCRUL';
   CURSOR get_desc IS
      SELECT description
      FROM accounting_code_part_value_tab
      WHERE company = company_
      AND code_part = code_part_
      AND code_part_value = code_part_value_;
BEGIN
   lu_name_ := Get_Lu_For_Code_Part__(company_, code_part_);
   IF (lu_name_ = 'FaObject') THEN
      component_ := 'FIXASS';
   ELSIF (lu_name_ = 'AccountingProject') THEN
      component_ := 'GENLED';
   END IF;
   desc_ := Substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,
                                                                        component_,
                                                                        lu_name_,
                                                                        code_part_value_ ),1,100);
   IF (desc_ IS NULL) THEN
      OPEN get_desc;
      FETCH get_desc INTO desc_;
      CLOSE get_desc;
   END IF;
   RETURN desc_;
END Get_Desc_For_Code_Part;


PROCEDURE Check_Delete_Allowed2 (
   company_         IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   code_part_       IN VARCHAR2,
   function_        IN VARCHAR2 DEFAULT NULL )
IS
   postctrlexist   EXCEPTION;
BEGIN
   IF Posting_Ctrl_API.Code_part_Exist(company_,code_part_,code_part_value_) THEN
      RAISE postctrlexist;
   END IF;
EXCEPTION
  WHEN postctrlexist THEN
      IF (function_ = 'FAACC') THEN
         Error_SYS.Appl_General(lu_name_,'EXISTCTRLFA: The object :P1 exists in the posting control and not allowed to delete.',
                                code_part_value_);      
      ELSIF (function_ = 'PRACC') THEN
         Error_SYS.Appl_General(lu_name_,'EXISTCTRLPR: The project :P1 exists in the posting control and not allowed to delete.',
                                code_part_value_);      
      ELSE
         Error_SYS.Appl_General(lu_name_,'EXISTCTRL: The code :P1 for code part :P2 is in the posting control and not allowed to delete.',
                                code_part_value_, code_part_);      
      END IF;  
END Check_Delete_Allowed2;


PROCEDURE Check_Delete_Allowed (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2 )
IS
BEGIN
-- Modifications 8.50 [ Move Codeparts ]
   IF    (code_part_ = 'A') THEN
      Account_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'B') THEN
      Code_B_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'C') THEN
      Code_C_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'D') THEN
      Code_D_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'E') THEN
      Code_E_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'F') THEN
      Code_F_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'G') THEN
      Code_G_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'H') THEN
      Code_H_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'I') THEN
      Code_I_API.Check_Delete_Allowed(company_, code_part_value_);
   ELSIF (code_part_ = 'J') THEN
      Code_J_API.Check_Delete_Allowed(company_, code_part_value_);
   END IF;
END Check_Delete_Allowed;


PROCEDURE Check_Delete (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2 )
IS
   remrec_            accounting_code_part_value_tab%ROWTYPE;
   copy_lu_name_      VARCHAR2(10);
BEGIN   
   copy_lu_name_ := 'Code'||code_part_;
   IF (App_Context_SYS.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(copy_lu_name_));
      END IF;
   END IF;    
   remrec_ := Get_Object_By_Keys___(company_, code_part_, code_part_value_);
   Check_Delete___(remrec_);
END Check_Delete;

PROCEDURE Exist_Code_Part (
   master_company_ IN VARCHAR2,
   code_part_      IN VARCHAR2,
   code_part_value_ IN VARCHAR2,
   internal_name_ IN VARCHAR2   )
IS
BEGIN
   IF NOT(Check_Exist___(master_company_, code_part_, code_part_value_)) THEN    
      Error_SYS.Record_Not_Exist(lu_name_, 'NOTEXIST: "The :P2 code part value :P1 does not exists.', code_part_value_, internal_name_);
   END IF;
END Exist_Code_Part;

@UncheckedAccess
FUNCTION Get_Valid_From (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN DATE
IS
   temp_ accounting_code_part_value_tab.valid_from%TYPE;
   CURSOR get_attr IS
      SELECT valid_from
      FROM   accounting_code_part_value_tab
      WHERE  company         = company_
      AND    code_part       = code_part_
      AND    code_part_value = code_part_value_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Valid_From;

@UncheckedAccess
FUNCTION Get_Valid_Until (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN DATE
IS

   temp_ accounting_code_part_value_tab.valid_until%TYPE;
   CURSOR get_attr IS
      SELECT valid_until
      FROM   accounting_code_part_value_tab
      WHERE  company         = company_
      AND    code_part       = code_part_
      AND    code_part_value = code_part_value_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Valid_Until;

@UncheckedAccess
FUNCTION Get_Accounting_Text_Id (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ accounting_code_part_value_tab.accounting_text_id%TYPE;
   CURSOR get_attr IS
      SELECT accounting_text_id
      FROM   accounting_code_part_value_tab
      WHERE  company         = company_
      AND    code_part       = code_part_
      AND    code_part_value = code_part_value_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Accounting_Text_Id;

@UncheckedAccess
FUNCTION Get (
   company_ IN VARCHAR2,
   code_part_ IN VARCHAR2,
   code_part_value_ IN VARCHAR2 ) RETURN Public_Rec
IS
   temp_ Public_Rec;
   CURSOR get_attr IS
      SELECT company, code_part_value,
             rowid, rowversion, rowkey, rowtype,
             valid_from, 
             valid_until, 
             accounting_text_id
      FROM accounting_code_part_value_tab
      WHERE company = company_
      AND   code_part = code_part_
      AND   code_part_value = code_part_value_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get;

PROCEDURE Add_Default_Values_Additional(
   attr_      IN OUT VARCHAR2,
   code_part_ IN     VARCHAR2)
IS
   valid_until_      Accrul_Attribute_Tab.attribute_value%TYPE;
BEGIN
   valid_until_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');   
   Client_SYS.Add_To_Attr('CODE_PART',code_part_, attr_ );
   Client_SYS.Add_To_Attr('VALID_FROM', TRUNC(SYSDATE), attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL',TRUNC(to_date(valid_until_, 'YYYYMMDD')), attr_);
END Add_Default_Values_Additional;

PROCEDURE Validate_Insert_Additional (
   rec_       IN accounting_code_part_value_tab%ROWTYPE)
IS
   accounting_code_parts_rec_ Accounting_Code_Parts_API.Public_Rec;
BEGIN
   accounting_code_parts_rec_ := Accounting_Code_Parts_API.Get(rec_.company, rec_.code_part);
   IF (Finance_Lib_API.Fin_Length(rec_.code_part_value) > accounting_code_parts_rec_.max_number_of_char) THEN
      Error_SYS.Record_General(lu_name_, 'TOOMANYCHARS: Too many characters in code part value');
   END IF;
   IF (accounting_code_parts_rec_.code_part_used = 'N') THEN
      Error_SYS.Record_General(lu_name_, 'ISNOTUSED: Code part :P1 is not used in define additional code parts', rec_.code_part);
   END IF;
   IF (INSTR(rec_.code_part_value, '^' ) > 0) THEN 
      Error_SYS.Record_General(lu_name_, 'INVALIDCHARVALUE: You have entered an invalid character in this field');
   END IF;
END Validate_Insert_Additional;

PROCEDURE Validate_Common_Additional (
   rec_       IN accounting_code_part_value_tab%ROWTYPE)
IS   
BEGIN
   IF (rec_.valid_from > rec_.valid_until) THEN
      Error_SYS.Appl_General(lu_name_,'DATESINVALID: Valid from cannot be greater than valid until.');
   END IF;   
END Validate_Common_Additional;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   code_part_              VARCHAR2(1);
   code_part_value_list_   VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Accounting_Code_Part_Value_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'CODE_PART') THEN
            code_part_ := value_;         
         ELSIF (name_ = 'CODE_PART_VALUE_LIST') THEN
            code_part_value_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                   target_company_list_,
                                   code_part_,
                                   code_part_value_list_,
                                   update_method_list_,
                                   log_id_,
                                   attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

PROCEDURE Check_Copy_Code_Part_Function (
   target_company_ IN VARCHAR2, 
   code_part_      IN VARCHAR2 )
IS
   code_part_function_ VARCHAR2(6);
BEGIN
   code_part_function_ := Accounting_Code_Parts_API.Get_Code_Part_Function_Db(target_company_, code_part_);   
   IF (code_part_function_ IN ('ELIM', 'FAACC', 'PRACC')) THEN
      Error_SYS.Record_General(lu_name_, 'ERRFUNC: Codepart values will not be synchronized because codepart :P1 is used as a code part function in company :P2', code_part_, target_company_);
   END IF;   
END Check_Copy_Code_Part_Function;


---------------------------------------------
-- WADACO Process Issue Inventory Part ------
---------------------------------------------
-- This method is used by DataCaptIssueInvPart
@ServerOnlyAccess
PROCEDURE Create_Data_Capture_Lov (
   company_                IN VARCHAR2,
   code_part_              IN VARCHAR2,
   capture_session_id_     IN NUMBER,
   column_name_            IN VARCHAR2,
   lov_type_db_            IN VARCHAR2 )
IS
   TYPE Get_Lov_Values     IS REF CURSOR;
   get_lov_values_         Get_Lov_Values;
   stmt_                   VARCHAR2(4000);
   TYPE Lov_Value_Tab      IS TABLE OF VARCHAR2(2000) INDEX BY PLS_INTEGER;
   lov_value_tab_          Lov_Value_Tab;
   lov_item_description_   VARCHAR2(200);
   $IF Component_Mpccom_SYS.INSTALLED $THEN
      session_rec_         Data_Capture_Common_Util_API.Session_Rec;
   $END
   lov_row_limitation_     NUMBER;
   exit_lov_               BOOLEAN := FALSE;
BEGIN
   $IF Component_Wadaco_SYS.INSTALLED AND Component_Mpccom_SYS.INSTALLED $THEN
      session_rec_ := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
      lov_row_limitation_ := Data_Capture_Config_API.Get_Lov_Row_Limitation(session_rec_.capture_process_id, session_rec_.capture_config_id);
    
      -- Extra column check to be sure we have no risk for sql injection into column_name_/data_item_id
      Assert_SYS.Assert_Is_Table_Column('ACCOUNTING_CODE_PART_VALUE_TAB', column_name_);

      IF (lov_type_db_  = Data_Capture_Config_Lov_API.DB_AUTO_PICK) THEN
         -- Don't use DISTINCT select for AUTO PICK
         stmt_ := 'SELECT ' || column_name_; 
      ELSE
         stmt_ := 'SELECT DISTINCT ' || column_name_;
      END IF;

      stmt_ := stmt_  || ' FROM ACCOUNTING_CODE_PART_VALUE_TAB
                           WHERE COMPANY = :company_ 
                           AND   CODE_PART = :code_part_ 
                           AND   TRUNC(SYSDATE) BETWEEN VALID_FROM AND VALID_UNTIL' ;

      stmt_ := stmt_ || ' ORDER BY ' || column_name_ || ' ASC';
   
      @ApproveDynamicStatement(2017-11-15,KHVESE)
      OPEN get_lov_values_ FOR stmt_ USING company_,
                                           code_part_;
         
      IF (lov_type_db_  = Data_Capture_Config_Lov_API.DB_AUTO_PICK) THEN
         -- Only 1 value for AUTO PICK
         FETCH get_lov_values_ INTO lov_value_tab_(1);
      ELSE
         FETCH get_lov_values_ BULK COLLECT INTO lov_value_tab_;
      END IF;
      CLOSE get_lov_values_;
      IF (lov_value_tab_.COUNT > 0) THEN
         FOR i IN lov_value_tab_.FIRST..lov_value_tab_.LAST LOOP
            -- Don't fetch details for AUTO PICK
            IF (lov_type_db_ != Data_Capture_Config_Lov_API.DB_AUTO_PICK) THEN              
               IF (column_name_ = 'CODE_PART_VALUE') THEN
               --Budget_Account_Flag_API.Decode(bud_account) budget_value,
                  lov_item_description_ := NVL(Get_Desc_For_Code_Part(company_,code_part_,lov_value_tab_(i)), Get_Description(company_,code_part_,lov_value_tab_(i)));
               END IF;
            END IF;
            
            Data_Capture_Session_Lov_API.New(exit_lov_              => exit_lov_,
                                             capture_session_id_    => capture_session_id_,
                                             lov_item_value_        => lov_value_tab_(i),
                                             lov_item_description_  => lov_item_description_,
                                             lov_row_limitation_    => lov_row_limitation_,    
                                             session_rec_           => session_rec_);
            EXIT WHEN exit_lov_;
         END LOOP;
      END IF;
   $ELSE
      NULL;
   $END
END Create_Data_Capture_Lov;


---------------------------------------------
-- WADACO Process Issue Inventory Part ------
---------------------------------------------
-- This method is used by DataCaptIssueInvPart
@ServerOnlyAccess
FUNCTION Get_Column_Value_If_Unique (
   no_unique_value_found_      OUT BOOLEAN,
   company_                    IN VARCHAR2,
   code_part_                  IN VARCHAR2,
   capture_session_id_         IN NUMBER,
   column_name_                IN VARCHAR2 ) RETURN VARCHAR2
IS
   TYPE Get_Column_Value IS REF CURSOR;
   get_column_values_             Get_Column_Value;
   stmt_                          VARCHAR2(4000);
   column_value_                  VARCHAR2(50);
   unique_column_value_           VARCHAR2(50);
   too_many_values_found_         BOOLEAN := FALSE;
BEGIN
   -- extra column check to be sure we have no risk for sql injection into column_name/data_item_id
   Assert_SYS.Assert_Is_Table_Column('ACCOUNTING_CODE_PART_VALUE_TAB', column_name_);

   -- using INVENTORY_PART_IN_STOCK_TOTAL instead of table since we like to fetch condition_code among other columns that dont exist in the table.
   stmt_ := ' SELECT ' || column_name_ || '
              FROM ACCOUNTING_CODE_PART_VALUE_TAB
              WHERE COMPANY = :company_ 
              AND   CODE_PART = :code_part_ 
              AND   TRUNC(SYSDATE) BETWEEN VALID_FROM AND VALID_UNTIL' ;

   @ApproveDynamicStatement(2017-11-15,KHVESE)
   OPEN get_column_values_ FOR stmt_ USING company_,
                                           code_part_;
   LOOP
      FETCH get_column_values_ INTO column_value_;
      EXIT WHEN get_column_values_%NOTFOUND;

      -- make sure NULL values are handled also
      IF (column_value_ IS NULL) THEN
         column_value_ := 'NULL';
      END IF;

      IF (unique_column_value_ IS NULL) THEN
         unique_column_value_ := column_value_;
      ELSIF (unique_column_value_ != column_value_) THEN
         too_many_values_found_ := TRUE; -- more then one unique value found
         unique_column_value_ := NULL;
         EXIT;
      END IF;
   END LOOP;
   CLOSE get_column_values_;

   -- If no values was found at all then set no_unique_value_found_ out-param to TRUE else set it to FALSE. 
   -- This to be able to see the why this method returned NULL so we can know if it was because no values 
   -- was found at all or if it was because to many values was found. This can be used in process utilities which
   -- fetch unique values from several data sources for a specific data item, so that utility can check if 
   -- there was a combined unique value from the data sources or not.
   IF (unique_column_value_ IS NULL AND NOT too_many_values_found_) THEN 
      no_unique_value_found_ := TRUE;    -- no records found
   ELSE
      no_unique_value_found_ := FALSE; -- either a unique value was found or too many values was found
   END IF;
   
   RETURN unique_column_value_;
END Get_Column_Value_If_Unique;

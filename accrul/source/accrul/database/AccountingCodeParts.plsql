-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodeParts
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960325  MIJO     Created.
--  970623  SLKO     Converted to Foundation 1.2.2d
--  970626  PICZ     Added company consolidation information; added
--                   Validate_Parent_Code_Part___; added consolidation function
--                   and procedures; added Check_Parent_Code_Parts__
--  970715  PICZ     Changed names: Get_Cons_Code_Part to Calculate_Parent_Code_Part
--                   and Check_Parent_Code_Parts__ to Check_Avl_Code_Part__
--  970814  PICZ     Fixed bug in Validate_Parent_Code_Part___
--  971006  ANDJ     Added check for entries in Accounting_Code_Part_Value when
--                   modifying code_part_function.
--  971016  PICZ     Added procedure Get_All_Parent_Code_Parts
--  971024  ANDJ     Made it possible to change desription although codestring
--                   is already used in db.
--  971208  PICZ     Fixed bug in Get_All_Parent_Code_Parts
--  980106  SLKO     Converted to Foundation1 2.0.0
--  980123  DAKA     VIEW_USED moved from API
--  980209  PICZ     Added Get_Codepart_Function_Db
--  980225  PICZ     Added Are_Mapped_Code_Parts
--  980320  PICZ     Fixed bug 965
--  980402  PICZ     Added Get_All_Code_Part_Names
--  980825  CHANNA   Fixed bug 5693
--  980921  Bren     Master Slave Connection
--                   Added Send_Acc_Codept_Info___, Send_Acc_Codept_Info_Delete___,
--                   Send_Acc_Codept_Info_Modify___, Receive_Acc_Codept_Info___ .
--  990319  JPS      Added function  Code_Part_Function_Used to check whether a
--                   codepart function is already in use. (Bug # 13507)
--  990416  Ruwan    Modified with respect to new template
--  991209  SaCh     Removed public method Get_Required_Codeparts which supported 7.3.1
--  991229  SaCh     Removed public procedure Validate_Codepart which supported 7.3.1
--  000105  SaCh     Added public methods Get_Required_Codeparts and Validate_Codepart.
--  000912  HiMu     Added General_SYS.Init_Method
--  001004  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  ovjose   For new Create Company concept added new view accounting_code_parts_pct and
--                   accounting_code_parts_ect. Added procedures Make_Company, Copy___, Import___ and Export___.
--  001214  SaCh     Corrected Bug # 18457.
--  010221  ToOs     Bug # 20177Added Globul Lu constans for check for transaction_sys calls
--  010226  ToOs     Bug # 20254 Added a check IF intled is installed
--  010508  JeGu     Bug #21705 Implementation New Dummyinterface
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010829  Raablk   Bug # 23786 .Commented Error Message 'INVALMAXNO'in Unpack_Check_Update___ and
--                   added this message in client .(tbwCodePart)
--  010904  Raablk   Bug # 23786 recorrected. And changed the Error Message to
--                   'Max number of characters must be between 1 and 10'
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020208  MaNi     Company Translation ( Enterp_Comp_Connect_V160_API )
--  020807  ovjose   Bug #29601 Corrected.
--  020826  Roralk   Bug# 32112 , Added new check to Unpack_Check_Update___.
--  020902  Chablk   Bug 28814 corrected. Modified function Get_Codepart_Function to able to get the
--                   code_part when Genled is not installed.
--  020905  Antrse   Bug # 32597. Removed correction of bug # 32112.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in ACCOUNTING_CODE_PARTS,ACCOUNTING_CODE_PARTS_USED2
--                   CODE_PARTS_FOR_CONSOLIDATION and ACCOUNTING_CODE_PARTS_USED view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021108  Gepelk   Added changes required by BEFI102E Currency Revaluation
--                   relating to LU RevalCodeParts in GENLED
--  021122  ovjose   Glob06. Added code_name to the table.
--  030731  prdilk   SP4 Merge.
--  040323  Gepelk   2004 SP1 Merge
--  040617  sachlk   FIPR338A2: Unicode Changes.
--  050307  shsalk   modified the method copy___ to not to copy the parent_code_part.
--  050701  Jeguse   Added method Get_Blocked_Code_Parts
--  061107  GaDaLK   LCS 59475, 60553 merged. ACCOUNTING_CODE_PARTS_ANALYSIS added by 59475 and removed by 60553.
--  070823  Naadlk   LCS Merge 67050 corrected. Modified error messages.
--  071228  MAKRLK   Bug 70203, Added the function Get_Code_Part_For_Logical().
--  080308  Kagalk   Bug 67316, Modified method Get_Blocked_Code_Parts to improve performance.
--  081001  Nirplk   Bug 76893, Corrected. Checked whether 'code used' before assigning a logical_code_part
--  081224  AsHelk   Bug 78011, Corrected.
--  090206  MAKRLK   TA786 Added new column base_for_pfe.
--  090213  MAKRLK   TA786 Added the function Get_Base_For_Followup_Element().
--  090213  MAKRLK   Modified the view ACCOUNTING_CODE_PARTS_PCT 
--  090306  MAKRLK   modified the methods Export___(), Import___() and Copy___()  
--  090612  Jaralk   Bug 83118, Corrected in Unpack_Check_Update___
--  090717  ErFelk   Bug 83174, Replaced constant CPUSEDINIL with CPUSEDINCR in Unpack_Check_Update___,
--  090717           replaced VAL_PCP_02 with VAL_PAR_03 in Validate_Parent_Code_Part and changed the message constant 
--  090717           in all similar messages in Validate_Codepart. 
--  090724  WAPELK   Bug Id 84476, Assign null to parent code parts when creating a new company/template 
--                   from consolidated company. Corrected in Import___ method.
--  090925  RUFELK   Bug 86079, Corrected in Unpack_Check_Insert___() and Unpack_Check_Update___().
--  100121  MAKRLK   TWIN PEAKS Merge.
--  100218  Jofise   Bug 87994, Added SORT=CODE_PART to the view comments.
--  100407  OVJOSE   Added Get_Code_Part_Function_Db and changed crecomp methods.
--  100914  Jaralk   Bug 92858  Added validation to reflected the modifications done in define code part window in codestring completion window
--  111017  Swralk   SFI-128, Added conditional compilation for the places that had called package FIXASS_CONNECTION_V871_API.
--  111019  Swralk   SFI-143, Added conditional compilation for the places that had called package INTLED_CONNECTION_V101_API.
--  120222  Mawelk   SFI-1421 Bug 97739, Added a method   Check_Exist()
--  120315  Sacalk   EASTRTM-4211, Changed the order of validations .
--  120319  Nasalk   EASTRTM-5034, Modified Check_Transactions_Exist__().
--  120420  Sacalk   EASTRTM-9903, Modified Check_Transactions_Exist__().
--  120514  SALIDE   EDEL-698, Added VIEW_AUDIT
--  120829  JuKoDE   EDEL-1532, Added General_SYS.Init_Method in Check_Transactions_Exist__()
--  121205  PRatlk   DANU-228, Added new view ACC_CP_USED_NO_ACNT_LOV.
--  121211  PRatlk   DANU-228, Added new method Get_Code_Part2 to bypass company user restrictions in consolidation.
--  130612  PRatlk   DANU-1120, Added new method Get_Description2 to bypass company user restrictions in consolidation.
--  121123  Thpelk   Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk   PEPA-183, Removed global variables
--  130306  THPELK   Bug 108320, Corrected in Get_Codepart_Function(). 
--  130307  Nirplk   Bug 108765, Corrected in Get_Acc_Code_Parts_Msg().
--  130617  NILILK   DANU-1287, Modified Unpack_Check_Update___().
--  130806  AmThLK   Bug 111347, Moved the code for setting the base_for_pfe flag from Insert___ to Import____
--  130920  MAWILK   BLACK-566, Replaced Component_Pcm_SYS.
--  131106  Umdolk   PBFI-888, Refactoring.
--  151229  Umdolk   FINGP-20, Merging additional code parts ( Code K - T).
--  160104  Nudilk   STRFI-818, Merged 125736.
--  171011  Savmlk   STRFI-10295, Mered LCS Bug 138088.
--- 200611  Gevelk   Bug 154408, Added condition to execute Val_Additional_Code_Parts when updating additional code parts only.
--  200703  Savmlk   Bug 154667, Added new procedure Code_Part_Exists.
--  200904  Jadulk   FISPRING20-6695, Removed CONACC related obsolete component logic.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Field___ (
   company_     IN VARCHAR2,
   field_       IN VARCHAR2,
   value_       IN VARCHAR2,
   codepart_    IN VARCHAR2 DEFAULT NULL )
IS
   value_func_       VARCHAR2(20);
BEGIN
   IF (field_ = 'CODE_PART_FUNCTION') THEN
      value_func_ := value_;
      IF value_func_ != 'NOFUNC' THEN
         $IF Component_Genled_SYS.INSTALLED $THEN
            NULL;
         $ELSE
            Error_SYS.appl_general(lu_name_,'INVALUE: Cannot enter a function if General Ledger is not installed');
         $END
      END IF;
      IF codepart_ = 'A' THEN
         IF value_func_ != 'NOFUNC' THEN
           Error_SYS.appl_general(lu_name_,'INVALCODEA: Cannot enter a function if code part is A',
                 value_);
         END IF;
      END IF;
   ELSIF (field_ = 'CODE_PART_USED') THEN
      value_func_ := value_;
      IF (Accounting_Code_Part_Value_API.Exist_Code_Part_Value(company_, codepart_)) AND
         value_func_ = 'N' THEN
           Error_SYS.appl_general(lu_name_,'CODEEXIST: Cannot close a code part that exist in basic data');
      END IF;
   END IF;
END Validate_Field___;


PROCEDURE Validate_Function___ (
   rec_   IN ACCOUNTING_CODE_PART_TAB%ROWTYPE )
IS
   result_a_      VARCHAR2(5);
   result_b_      VARCHAR2(5);
   result_c_      VARCHAR2(5);
   result_d_      VARCHAR2(5);
   result_e_      VARCHAR2(5);
   result_f_      VARCHAR2(5);
   result_g_      VARCHAR2(5);
   result_h_      VARCHAR2(5);
   result_i_      VARCHAR2(5);
   result_j_      VARCHAR2(5);
   old_rec_       ACCOUNTING_CODE_PART_TAB%ROWTYPE;
   attr_          VARCHAR2(2000);
BEGIN
   old_rec_ := Get_Object_By_Keys___ ( rec_.company, rec_.code_part );
   IF (rec_.code_part_function != old_rec_.code_part_function) THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('COMPANY', rec_.company, attr_);
         IF (rec_.code_part = 'A' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_a_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'B' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_b_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'C' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_c_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'D' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_d_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'E' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_e_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'F' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_f_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'G' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_g_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'H' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_h_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'I' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_i_in_gl_voucher_row(attr_);
         END IF;
         IF (rec_.code_part = 'J' ) THEN
            GEN_LED_VOUCHER_ROW_API.Postings_j_in_gl_voucher_row(attr_);
         END IF;
      $END
      IF (rec_.code_part = 'A' ) THEN
         Voucher_Row_API.Postings_a_in_voucher_row(result_a_,rec_.company);
      END IF;
      IF (rec_.code_part = 'B' ) THEN
         Voucher_Row_API.Postings_b_in_voucher_row(result_b_,rec_.company);
      END IF;
      IF (rec_.code_part = 'C' ) THEN
         Voucher_Row_API.Postings_c_in_voucher_row(result_c_,rec_.company);
      END IF;
      IF (rec_.code_part = 'D' ) THEN
         Voucher_Row_API.Postings_d_in_voucher_row(result_d_,rec_.company);
      END IF;
      IF (rec_.code_part = 'E' ) THEN
         Voucher_Row_API.Postings_e_in_voucher_row(result_e_,rec_.company);
      END IF;
      IF (rec_.code_part = 'F' ) THEN
         Voucher_Row_API.Postings_f_in_voucher_row(result_f_,rec_.company);
      END IF;
      IF (rec_.code_part = 'G' ) THEN
         Voucher_Row_API.Postings_g_in_voucher_row(result_g_,rec_.company);
      END IF;
      IF (rec_.code_part = 'H' ) THEN
         Voucher_Row_API.Postings_h_in_voucher_row(result_h_,rec_.company);
      END IF;
      IF (rec_.code_part = 'I' ) THEN
         Voucher_Row_API.Postings_i_in_voucher_row(result_i_,rec_.company);
      END IF;
      IF (rec_.code_part = 'J' ) THEN
         Voucher_Row_API.Postings_j_in_voucher_row(result_j_,rec_.company);
      END IF;
      IF (result_a_ = 'TRUE')  OR
         (result_b_ = 'TRUE')  OR
         (result_c_ = 'TRUE')  OR
         (result_d_ = 'TRUE')  OR
         (result_e_ = 'TRUE')  OR
         (result_f_ = 'TRUE')  OR
         (result_g_ = 'TRUE')  OR
         (result_h_ = 'TRUE')  OR
         (result_i_ = 'TRUE')  OR
         (result_j_ = 'TRUE')
      THEN
         Error_SYS.Record_General('AccountingCodeParts', 'POST_CUR: You cannot change the code part function if there are postings in the wait table for this code part');
      END IF;
   END IF;
END Validate_Function___;


PROCEDURE Validate_Logical_Code_Part___ (
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   logical_code_part_   IN VARCHAR2 )
IS
   temp_                   VARCHAR2(1);
   logical_code_part_db_   VARCHAR2(20);
   CURSOR used_once IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company            =  company_
      AND    logical_code_part  =  logical_code_part_db_
      AND    code_part         != code_part_;
   code_a_forbiden        EXCEPTION;
   to_many_uses           EXCEPTION;
BEGIN
   logical_code_part_db_ := Logical_Code_Part_API.Encode(logical_code_part_);
   IF (code_part_ = 'A' AND logical_code_part_db_ != 'NotUsed') THEN
      RAISE code_a_forbiden;
   ELSIF (logical_code_part_db_ != 'NotUsed') THEN
      -- check, if logical codepart is used only once
      OPEN  used_once;
      FETCH used_once INTO temp_;
      IF used_once%FOUND THEN
         CLOSE used_once;
         RAISE to_many_uses;
      END IF;
      CLOSE used_once;
   END IF;
EXCEPTION
   WHEN code_a_forbiden THEN
        Error_SYS.Record_General(lu_name_,
                                 'CODE_A_ERROR: Logical Code Part :P1 can not be connected to code part A',logical_code_part_);
   WHEN to_many_uses THEN
        Error_SYS.Record_General(lu_name_,
                                 'USED_MANY_ERROR: Logical Code Part :P1 can be used only once',logical_code_part_ );
END Validate_Logical_Code_Part___;


PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   newrec_      accounting_code_part_tab%ROWTYPE;
   empty_rec_   accounting_code_part_tab%ROWTYPE;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  accounting_code_part_tab src
      WHERE company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM  accounting_code_part_tab
                      WHERE company = crecomp_rec_.company
                      AND   code_part = src.code_part);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR oldrec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-08-27,difelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Copy_Assign___(newrec_, crecomp_rec_, oldrec_);
            Client_SYS.Clear_Attr(attr_);
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-08-27,difelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'Error', msg_);
         END;
      END LOOP;
      
      Currency_Code_API.Copy_Curr_Bal_Currency(crecomp_rec_);
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedWithErrors');
END Copy___;
   

PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  accounting_code_part_tab
      WHERE company = crecomp_rec_.company;
BEGIN
   FOR exprec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      Export_Assign___(pub_rec_, crecomp_rec_, exprec_);
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

   
PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_               VARCHAR2(2000);
   msg_                VARCHAR2(2000);
   i_                  NUMBER := 0;
   run_crecomp_        BOOLEAN := FALSE;
   record_inserted_    BOOLEAN := FALSE;   
   bfe_code_part_      ACCOUNTING_CODE_PART_TAB.code_part%TYPE;
   newrec_             ACCOUNTING_CODE_PART_TAB%ROWTYPE;
   empty_rec_          ACCOUNTING_CODE_PART_TAB%ROWTYPE;

   CURSOR get_data IS
      SELECT *
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu      = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM ACCOUNTING_CODE_PART_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND dest.code_part = src.c1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);

   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-04-04,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            attr_ := NULL;
            newrec_ := empty_rec_;
            App_Context_SYS.Set_Value('CREATE_COM_PARAM', 'TRUE');
            Import_Assign___ (newrec_, crecomp_rec_, rec_);
            IF( newrec_.base_for_pfe = 'TRUE') THEN 
               bfe_code_part_ := newrec_.code_part;               
            END IF;
            -- In case description is missing in template due to use of old template.
            IF ( newrec_.code_name IS NULL ) THEN
               newrec_.code_name := newrec_.code_part;
            END IF;
            Client_SYS.Clear_Attr(attr_);
            New___(newrec_);
            App_Context_SYS.Set_Value('CREATE_COM_PARAM', 'FALSE');
            record_inserted_ := TRUE;        
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-04-04,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'Error', msg_);
         END;
      END LOOP;
      
      Add_Curr_Bal_Currency___(crecomp_rec_);
      IF (record_inserted_ AND bfe_code_part_ IS NULL) THEN 
         newrec_              := Get_Object_By_Keys___(crecomp_rec_.company, 'A');
         newrec_.base_for_pfe := 'TRUE';
         Modify___(newrec_);
      END IF;
      
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODE_PARTS_API', 'CreatedWithErrors');
END Import___;

PROCEDURE Add_Curr_Bal_Currency___(
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec)
IS
   curr_code_attr_     VARCHAR2(2000);
   
   CURSOR get_curr_code IS
      SELECT * 
      FROM Curr_Bal_Currency_Codes
      WHERE template_id = crecomp_rec_.template_id;      
BEGIN
   Client_SYS.Add_To_Attr('COMPANY', crecomp_rec_.company, curr_code_attr_);
   Client_SYS.Add_To_Attr('CODE_PART', crecomp_rec_.curr_bal_code_part, curr_code_attr_);
   Client_SYS.Add_To_Attr('VALID_FROM', crecomp_rec_.valid_from, curr_code_attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL', Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO'), curr_code_attr_);
   
   FOR rec_ IN get_curr_code LOOP
      IF (Client_SYS.Item_Exist('CODE_PART_VALUE', curr_code_attr_)) THEN
         Client_SYS.Set_Item_Value('CODE_PART_VALUE', rec_.currency_code, curr_code_attr_);
         Client_SYS.Set_Item_Value('DESCRIPTION', rec_.description, curr_code_attr_);
      ELSE
         Client_SYS.Add_To_Attr('CODE_PART_VALUE', rec_.currency_code, curr_code_attr_);
         Client_SYS.Add_To_Attr('DESCRIPTION', rec_.description, curr_code_attr_);
      END IF;  
      
      Accounting_Code_Part_Value_API.New_Code_Part_Value(curr_code_attr_);
   END LOOP;
END Add_Curr_Bal_Currency___;

@Override
PROCEDURE Import_Assign___ (
   newrec_      IN OUT accounting_code_part_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   pub_rec_     IN     Create_Company_Template_Pub%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, pub_rec_);
   IF ((Company_API.Get_Master_Company_Db(newrec_.company) = 'FALSE') AND (newrec_.code_part IN ('K', 'L', 'M'))) THEN
      newrec_.code_part_used := 'N';       
      newrec_.code_part_mapping_exists := 'FALSE';
   END IF;
   IF (crecomp_rec_.curr_bal_code_part = newrec_.code_part) THEN
      newrec_.code_part_function := 'CURR';      
      newrec_.code_name          := crecomp_rec_.curr_bal_code_part_desc;
      newrec_.code_part_used     := 'Y';
   END IF;   
END Import_Assign___;
     
@Override
PROCEDURE Copy_Assign___ (
   newrec_      IN OUT accounting_code_part_tab%ROWTYPE,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   oldrec_      IN     accounting_code_part_tab%ROWTYPE )
IS
BEGIN
   super(newrec_, crecomp_rec_, oldrec_);
   IF ((Company_API.Get_Master_Company_Db(newrec_.company) = 'FALSE') AND (newrec_.code_part IN ('K', 'L', 'M'))) THEN
      newrec_.code_part_used := 'N';       
      newrec_.code_part_mapping_exists := 'FALSE';
   END IF;
   IF (crecomp_rec_.curr_bal_code_part = newrec_.code_part) THEN
      newrec_.code_part_function := 'CURR';
      newrec_.code_name          := crecomp_rec_.curr_bal_code_part_desc;
      newrec_.code_part_used     := 'Y';
   END IF;
END Copy_Assign___;

   
PROCEDURE Validate_Curr___ (
   company_     IN VARCHAR2,
   code_part_   IN VARCHAR2 )
IS
   CURSOR check_curr_bal_used IS
      SELECT 1   
		FROM   accounting_code_part_value_tab
		WHERE  company      = company_
		AND    curr_balance = 'Y';
   
	cur_bal_cnt_ NUMBER;
BEGIN
   OPEN  check_curr_bal_used;
   FETCH   check_curr_bal_used INTO cur_bal_cnt_;
      
   IF (check_curr_bal_used%FOUND) THEN
      CLOSE check_curr_bal_used;
      Error_SYS.Record_General('AccountingCodeParts', 'CODEPARTINUSE: Code Part :P1 is already in use.', code_part_);
   ELSE
      CLOSE check_curr_bal_used;
      NULL;
   END IF;

END Validate_Curr___;

PROCEDURE Val_Max_Number_Of_Char___(
   number_of_char_  IN NUMBER)
IS
BEGIN
   IF ( number_of_char_ < 1 OR number_of_char_ > 20 )THEN
      Error_SYS.Appl_General(lu_name_, 'INVALMAXNO: Max number of characters must be between 1 and 20');
   END IF;
END Val_Max_Number_Of_Char___;

  
PROCEDURE Val_Additional_Code_Parts___(
   newrec_         IN   ACCOUNTING_CODE_PART_TAB%ROWTYPE,
   indrec_         IN   Indicator_Rec,
   calling_method_ IN   VARCHAR2,
   oldrec_         IN   ACCOUNTING_CODE_PART_TAB%ROWTYPE DEFAULT NULL)
IS
   change_allowed_ BOOLEAN := FALSE;
BEGIN
   IF (calling_method_ = 'UPDATE') THEN
      IF (indrec_.code_part_used AND (Validate_SYS.Is_Changed(oldrec_.code_part_used, newrec_.code_part_used) OR oldrec_.code_part_used IS NULL)) THEN
         IF (newrec_.system_defined = 'TRUE') THEN
            IF(newrec_.code_part_used ='N') THEN
               Error_SYS.Appl_General(lu_name_, 'CODEPARTUSEDCHANGE: System defined code parts should always be used.');
            END IF;
         END IF;    
         IF (Accounting_Code_Part_Value_API.Exist_Code_Part_Value(newrec_.company, newrec_.code_part)) AND (newrec_.system_defined = 'FALSE') THEN
            Error_SYS.Record_General(lu_name_, 'CODEPARTINUSE: Code Part :P1 is already in use.', newrec_.code_part);
         END IF;
      END IF;   
      
      IF (Dictionary_SYS.Component_Is_Active('BUSPLN')) THEN
         change_allowed_ := TRUE;
      ELSE
         IF (Dictionary_SYS.Component_Is_Active('GROCON')) THEN
            IF (Company_API.Get_Master_Company_Db(newrec_.company) = 'TRUE') THEN
               change_allowed_ := TRUE;
            END IF;
         END IF;
      END IF;
      IF NOT (change_allowed_) THEN
         Error_SYS.Record_General(lu_name_, 'CHANGEALLOWED: Additional Code Parts cannot be changed in Define Code String when components GROCON and BUSPLN are not installed.');   
      END IF;
      
      $IF Component_Grocon_SYS.INSTALLED $THEN    
         IF (newrec_.code_part_mapping_exists = 'FALSE' AND 
             newrec_.code_part >= 'K' AND newrec_.code_part <= 'T' AND
          Rep_Code_Part_Map_API.Get_Rep_Code_Mappings_Exists(newrec_.company, newrec_.code_part)) THEN
         Error_SYS.Appl_General(lu_name_, 'UNSELECTMAP: You cannot unselect code part mapping for already mapped code parts.');
      END IF;  
      $END 
   END IF;
      
   IF (newrec_.code_part_used = 'N' AND newrec_.code_part_mapping_exists = 'TRUE') THEN
      Error_SYS.Appl_General(lu_name_, 'UNUSEDMAP: You cannot select code part mapping for unused code parts.');
   END IF;   
END Val_Additional_Code_Parts___;   

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     ACCOUNTING_CODE_PART_TAB%ROWTYPE,
   newrec_     IN OUT ACCOUNTING_CODE_PART_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   IF (newrec_.base_for_pfe = 'TRUE') THEN
      UPDATE accounting_code_part_tab
         SET base_for_pfe = 'FALSE',
             rowversion   = sysdate
         WHERE company      = newrec_.company
         AND   base_for_pfe = 'TRUE';   
   END IF;   

   IF (newrec_.code_part_used <> oldrec_.code_part_used) THEN
      IF (newrec_.code_part_used = 'Y') THEN          
         Accounting_Codestr_Co_Util_API.Insert_Code_Parts(newrec_.company, newrec_.code_part);        
      END IF;
      IF (newrec_.code_part_used = 'N') THEN
         Accounting_Codestr_Co_Util_API.Delete_Code_Parts(newrec_.company, newrec_.code_part);
      END IF;        
      $IF Component_Buspln_SYS.INSTALLED $THEN
         IF (newrec_.code_part_used = 'N') THEN  
            Code_String_Def_Comb_API.Remove_Code_Part_Usage(newrec_.company,
                                                            newrec_.code_part);
         ELSE
            Code_String_Def_Comb_API.Add_Code_Part_Usage(newrec_.company,
                                                         newrec_.code_part);
         END IF;
      $END

      $IF Component_Intled_SYS.INSTALLED $THEN
         Internal_Code_Parts_API.Remove_From_Il(newrec_.company,
                                                newrec_.code_part);
         IF (newrec_.code_part_used = 'Y') THEN
            Internal_Ledger_Util_Pub_API.Insert_Internal_Code_Parts(newrec_.company,
                                                                    newrec_.code_part);
         END IF;
      $END

      $IF Component_Genled_SYS.INSTALLED $THEN
         Reval_Code_Parts_API.Remove_From_Reval(newrec_.company,
                                                newrec_.code_part);                                       
         IF (newrec_.code_part_used = 'Y') THEN
            Reval_Code_Parts_API.Insert_Reval_Code_Parts(newrec_.company,
                                                         newrec_.code_part);
         END IF;
      $END
   END IF;        
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
        Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_code_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                VARCHAR2(30);
   value_               VARCHAR2(4000);
   value_code_used_     VARCHAR2(20);
   old_base_for_pfe_    VARCHAR2(1);
   old_base_name_       VARCHAR2(10);
   from_client_         VARCHAR2(5):= 'FALSE' ;
BEGIN    
   IF (Client_SYS.Item_Exist('FROM_CLIENT', attr_)) THEN
      from_client_ := Client_SYS.Cut_Item_Value('FROM_CLIENT', attr_) ;
   END IF;
   
   super(newrec_, indrec_, attr_);
     
   old_base_for_pfe_:= Get_Base_For_Followup_Element(newrec_.company);
   old_base_name_   := Get_Name(newrec_.company,old_base_for_pfe_);
   IF (indrec_.base_for_pfe OR indrec_.code_part_function) THEN
      IF ( newrec_.base_for_pfe = 'TRUE' AND newrec_.code_part_function != 'NOFUNC') THEN
          Error_SYS.appl_general(lu_name_,'CODEPTFUNCNOTBASE: Base for Project Cost/Revenue Elements can not have a code part function.');
      END IF;
   END IF;     
   
   IF ((indrec_.base_for_pfe) AND (from_client_ = 'FALSE') AND (newrec_.code_part BETWEEN 'A' AND 'J') ) THEN
      Check_Transactions_Exist__(newrec_.company,old_base_for_pfe_); 
   END IF;
   
   IF (INSTR(newrec_.code_name, '@') > 0) THEN
      Error_Sys.Record_General(lu_name_, 'INVALIDCHAR: The ''@'' sign is not allowed to be used inside a code part name.');
   END IF;
   Logical_Code_Part_API.Exist_Db(newrec_.logical_code_part);
   -- Validations moved from the attr loop End
   
   Val_Max_Number_Of_Char___(newrec_.max_number_of_char);
   Val_Additional_Code_Parts___(newrec_, indrec_, 'INSERT', NULL);
   
   value_code_used_ := newrec_.code_part_used;
   Validate_Field___(newrec_.company, 'CODE_PART_USED', value_code_used_, newrec_.code_part );
   IF (newrec_.code_part = 'A' AND value_code_used_ = 'N')THEN
      Error_Sys.Record_General( 'AccountingCodeParts','ACCMUST: Account must be used');
   END IF;

   IF ((newrec_.code_part_used = 'N') AND (newrec_.logical_code_part != 'NotUsed')) THEN
      Error_SYS.Record_General('AccountingCodeParts','CODEPTNOTUSED: A Logical Code Part can not be assigned to a code part that is not used.');
   END IF;

EXCEPTION
   WHEN value_error THEN
        Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     accounting_code_part_tab%ROWTYPE,
   newrec_ IN OUT accounting_code_part_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_             VARCHAR2(30);
   value_            VARCHAR2(4000);
   value_code_used_  VARCHAR2(20);
   allowed_          BOOLEAN := FALSE;
   old_base_for_pfe_  VARCHAR2(1);
   old_base_name_     VARCHAR2(10);
   from_client_       VARCHAR2(5) := 'FALSE' ;
BEGIN
   IF (indrec_.code_part_used AND (Validate_SYS.Is_Changed(oldrec_.code_part_used, newrec_.code_part_used))) THEN
      allowed_ := TRUE;
   END IF;
   IF (Client_SYS.Item_Exist('FROM_CLIENT', attr_)) THEN
      from_client_ := Client_SYS.Cut_Item_Value('FROM_CLIENT', attr_); 
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (indrec_.code_name) THEN
      IF (INSTR(newrec_.code_name, '@') > 0) THEN
         Error_Sys.Record_General(lu_name_, 'INVALIDCHAR: The ''@'' sign is not allowed to be used inside a code part name.');
      END IF;
   END IF;   
   
   IF (indrec_.code_part_function AND (Validate_SYS.Is_Changed(oldrec_.code_part_function, newrec_.code_part_function))) THEN
      IF (newrec_.code_part_function IS NOT NULL) THEN
         IF (Code_Part_Function_Used(newrec_.company, newrec_.code_part_function) AND newrec_.code_part_function != 'NOFUNC' AND newrec_.code_part_function != 'INTERN')  THEN
             newrec_.code_part_function := 'NOFUNC';
             Error_SYS.appl_general(lu_name_, 'CODEPARTFUNCUSED: This code part function is already in use.');
         END IF;
         IF ( newrec_.code_part_function = 'FAACC' ) THEN
            $IF Component_Fixass_SYS.INSTALLED $THEN
               Fa_Company_API.Exist ( newrec_.company );               
            $ELSE
               Error_SYS.appl_general(lu_name_, 'NOFIXASSINST: Fixed Assets has not been installed');
            $END
         END IF;
         IF ( newrec_.code_part_function = 'INTERN') THEN
            $IF Component_Intled_SYS.INSTALLED $THEN 
               NULL;
            $ELSE
               Error_SYS.Appl_General(lu_name_, 'NOINTLEDINST: Internal Ledger has not been installed');
            $END
         END IF;
         allowed_ := TRUE;
      END IF;
   END IF;  
   
   IF (indrec_.max_number_of_char) THEN
      Val_Max_Number_Of_Char___(newrec_.max_number_of_char);
   END IF;
   IF newrec_.code_part IN ('K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T') THEN
      Val_Additional_Code_Parts___(newrec_, indrec_, 'UPDATE', oldrec_);
   END IF;
   IF (indrec_.logical_code_part) THEN
      Validate_Logical_Code_Part___(newrec_.company,
                                    newrec_.code_part,
                                    newrec_.logical_code_part);
   END IF;
   
   IF ( (newrec_.code_part_used = 'N') AND (newrec_.code_part_function != 'NOFUNC') AND (newrec_.code_part BETWEEN 'A' AND 'J')) THEN
       Error_SYS.appl_general(lu_name_,'CODEPNOTUSED: A function cannot be assigned to a code part that is not used.');
   END IF;

   old_base_for_pfe_:= Get_Base_For_Followup_Element(newrec_.company);
   old_base_name_   := Get_Name(newrec_.company,old_base_for_pfe_);
   IF (indrec_.base_for_pfe OR indrec_.code_part_function) THEN
      IF ( newrec_.base_for_pfe = 'TRUE' AND newrec_.code_part_function != 'NOFUNC') THEN
         Error_SYS.appl_general(lu_name_,'CODEPTFUNCNOTBASE: Base for Project Cost/Revenue Elements can not have a code part function.');
      END IF;
   END IF;
   
   IF ((indrec_.base_for_pfe) AND (from_client_ = 'FALSE') AND (newrec_.code_part BETWEEN 'A' AND 'J')) THEN   
      Check_Transactions_Exist__(newrec_.company,old_base_for_pfe_);
   END IF;   
   
   IF ( allowed_ ) THEN
      allowed_ := FALSE;
      IF( newrec_.code_part_used IS NOT NULL )THEN
         value_code_used_ := newrec_.code_part_used;
         Validate_Field___( newrec_.company, 'CODE_PART_USED', value_code_used_, newrec_.code_part );
         IF( newrec_.code_part = 'A' AND value_code_used_ = 'N' )THEN
            Error_Sys.Record_General( 'AccountingCodeParts', 'ACCMUST: Account must be used');
         END IF;
      END IF;
      IF( newrec_.code_part_function IS NOT NULL )THEN

         IF ( Get_Codepart_Function_Db( newrec_.company, 'CURR') = newrec_.code_part) THEN
            Validate_Curr___ ( newrec_.company, newrec_.code_part );  
         END IF;

         Validate_Field___( newrec_.company, 'CODE_PART_FUNCTION', newrec_.code_part_function, newrec_.code_part );
         IF ( Accounting_Code_Part_Value_API.Exist_Code_Part_Value(newrec_.company,newrec_.code_part) AND newrec_.code_part_function != 'INTERN') THEN
            Error_SYS.Record_General('AccountingCodeParts', 'CODEPARTINUSE: Code Part :P1 is already in use.', newrec_.code_part);
         END IF;
      END IF;
   END IF;

   Validate_Function___( newrec_);

   IF ((newrec_.code_part_used = 'N') AND (newrec_.logical_code_part != 'NotUsed')) THEN
      Error_SYS.Record_General('AccountingCodeParts','CODEPTNOTUSED: A Logical Code Part can not be assigned to a code part that is not used.');
   END IF;

   IF (newrec_.code_part_used = 'N') THEN
      IF (Accounting_Code_Part_A_API.Is_Codepart_Blocked(newrec_.company,newrec_.code_part)='TRUE') THEN
         Error_SYS.Record_General( lu_name_,'NOTBLOCKED121: Code Part demands for Code Part :P1 must be blocked for all accounts. Change codepart demands in account types.',
                                   newrec_.code_part);
      END IF;
   END IF;
EXCEPTION
   WHEN value_error THEN
        Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Transactions_Exist__(
   company_           IN VARCHAR2,
   old_base_for_pfe_  IN VARCHAR2)
IS               
   min_date_             DATE;
   accounting_year_      NUMBER;
   accounting_period_    NUMBER;
   payment_type_         VARCHAR2(20);
   result_               VARCHAR2(5);
BEGIN
   min_date_ := Database_SYS.first_calendar_date_;
   accounting_year_ := Accounting_Period_API.Get_Accounting_Year(company_, SYSDATE);
   accounting_period_ := Accounting_Period_API.Get_Accounting_Period(company_,SYSDATE);

  IF (Ext_Load_Info_API.Check_Non_Created_ExtVou_Exist(company_,min_date_,SYSDATE) = 'TRUE') THEN
         Error_SYS.Record_General('AccountingCodeParts','EXTVOUEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are External Vouchers waiting to be created.');
  END IF;

  IF (Voucher_Row_API.Check_Exist_Vourow_with_Pfe(company_)) THEN
         Error_SYS.Record_General('AccountingCodeParts','PRJCONEXTINHOLDTB: There are vouchers in the hold table with a project activity sequence number. To change the base for project cost/revenue element, first update these vouchers to the General Ledger.');
  END IF;

  IF (Period_Allocation_API.Check_Allocation_Exist_Todate(company_,accounting_year_,accounting_period_) = 'TRUE') THEN
         Error_SYS.Record_General('AccountingCodeParts','PALOCEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are Not updated vouchers with period allocation.');
  END IF;

  $IF Component_Genled_SYS.INSTALLED $THEN
     IF (Currency_Revaluation_API.Check_Non_Posted_Reval_Todate(company_,accounting_year_,accounting_period_) = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','CRREVALEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as an unposted Currency Revaluation exists.');
     END IF;

     IF (Revenue_Recognition_API.All_Posted_Todate(company_,accounting_year_,accounting_period_) = 'FALSE') THEN
        Error_SYS.Record_General('AccountingCodeParts','REVRECGEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as an unposted Revenue Recognition exists.');
     END IF;
  $END

  $IF Component_Percos_SYS.INSTALLED $THEN
     IF (Cost_Allocation_Procedure_API.Non_Closed_Proc_Exist_Todate(company_,accounting_year_,accounting_period_) = 'TRUE' ) THEN
        Error_SYS.Record_General('AccountingCodeParts','COSALOCEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are unclosed Cost allocation procedure.');
     END IF;
  $END

  $IF Component_Mpccom_SYS.INSTALLED $THEN
     IF (Mpccom_Accounting_API.All_Postings_Transferred(company_,min_date_,SYSDATE) = 'FALSE' ) THEN
        Error_SYS.Record_General('AccountingCodeParts','MPCCOMTRANSEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-transferred Purchase and/or Inventory Transactions.');
     END IF;
  $END

  $IF Component_Wo_SYS.INSTALLED $THEN
     IF (Jt_Task_Transaction_API.All_Postings_Transferred(company_,min_date_,SYSDATE) = 'FALSE' ) THEN
        Error_SYS.Record_General('AccountingCodeParts','PCMTRANSEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-transferred PCM Transactions.');
     END IF;
  $END

  $IF Component_Prjrep_SYS.INSTALLED $THEN
     IF (Project_Trans_Posting_API.Prjrep_None_Trans_Post_Exist(company_,SYSDATE) = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','NTPRJTRANEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-transferred Project Transactions.');
     END IF;
  $END

  $IF Component_Invoic_SYS.INSTALLED $THEN
     Invoice_API.Post_Error_Invs_Exist(result_,company_,accounting_year_,accounting_period_,min_date_,SYSDATE);
     IF (result_ = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','ERRINVEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are Customer Invoices with posting errors.');
     END IF;

     IF (Ext_Inc_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_,accounting_year_,accounting_period_,min_date_,SYSDATE) = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','EXTSINVEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are External Supplier Invoices waiting to be created.');
     END IF;

     IF (Ext_Out_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_,accounting_year_,accounting_period_,min_date_,SYSDATE) = 'TRUE' ) THEN
        Error_SYS.Record_General('AccountingCodeParts','EXTCINVEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are External Customer Invoices waiting to be created.');
     END IF;
  $END

  $IF Component_Payled_SYS.INSTALLED $THEN
     Prel_Payment_Trans_Util_API.Check_Non_Approved_Paym_Exists(result_,payment_type_,company_,accounting_year_,accounting_period_,min_date_,SYSDATE);
     IF (result_ = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','NAPPPAYEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-approved Preliminary Payments transactions.');
     END IF;

     IF (Mixed_Payment_API.All_Approved_For_Period(company_,accounting_year_,accounting_period_,min_date_,SYSDATE) = 'FALSE') THEN
        Error_SYS.Record_General('AccountingCodeParts','NAMIXPAYEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-approved Mixed Payment transactions.');
     END IF;

     IF (Cash_Box_API.All_Approved_For_Period(company_,accounting_year_,accounting_period_,min_date_,SYSDATE) = 'FALSE') THEN
        Error_SYS.Record_General('AccountingCodeParts','NACABOXEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are non-approved Cash Box transactions.');
     END IF;

     IF (Ext_Payment_Head_API.Check_Non_Used_Pay_Exist(company_,accounting_year_,accounting_period_,min_date_,SYSDATE) = 'TRUE') THEN
        Error_SYS.Record_General('AccountingCodeParts','EXTAPYEXIST: It is not possible to change the Base for Project Cost/Revenue Element, as there are External Payments waiting to be created.');
     END IF; 
  $END
  -- Below code is purposely not alligned due to a problem in F1 scan tool.
   IF  (Cost_Element_To_Account_API.Exist_Cost_Elements(company_,old_base_for_pfe_)) THEN
     Error_SYS.Record_General('AccountingCodeParts',
                              'COSTELMEXISTFOCODE: There are project cost/revenue elements connected to code part :P1 in window Project Cost/Revenue Elements per Code Part Value. These connections must be removed before you can change the Base for Project Cost/Revenue Element. Before removing the existing project cost/revenue element connections, it is recommended to use the Copy Cost/Revenue Elements to Secondary Mapping function in the Secondary Project Cost/Revenue Element window to ensure accuracy of existing project cost/revenue. ' , Get_Base_For_Followup_Element(company_));
  END IF;
END Check_Transactions_Exist__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Description2 (
   company_   IN VARCHAR2,
   code_part_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_    VARCHAR2(200);
   CURSOR get_attr IS
      SELECT description
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company   = company_
      AND    code_part = code_part_;
BEGIN
      OPEN  get_attr;
      FETCH get_attr INTO temp_;
      CLOSE get_attr;
      temp_ := NVL(SUBSTR(Enterp_Comp_Connect_V170_API.Get_Company_Translation(
                                                   company_,
                                                   'ACCRUL',
                                                   'AccountingCodeParts',
                                                   code_part_||'^DESCRIPTION'),1,100), temp_);
   RETURN temp_;
END Get_Description2;


@UncheckedAccess
FUNCTION Is_Code_Used (
   company_      IN VARCHAR2,
   code_part_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR used_cur IS
      SELECT code_part_used
      FROM   accounting_code_part_tab
      WHERE  company   = company_
      AND    code_part = code_part_;
   dummy_    VARCHAR2(20);
BEGIN
   OPEN  used_cur;
   FETCH used_cur INTO dummy_;
   CLOSE used_cur;
   IF dummy_ = 'Y' THEN
      RETURN 'TRUE';
   ELSIF dummy_ = 'N' THEN
      RETURN 'FALSE';
   END IF;
   RETURN NULL;
END Is_Code_Used;


@UncheckedAccess
FUNCTION Is_Codepart_Function (
   company_       IN VARCHAR2,
   code_part_     IN VARCHAR2,
   function_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR func_cur IS
      SELECT code_part_function
      FROM   accounting_code_part_tab
      WHERE  company            = company_
      AND    code_part          = code_part_
      AND    code_part_function = function_;
   dummy_ VARCHAR2(20);
BEGIN
   OPEN  func_cur;
   FETCH func_cur INTO dummy_;
   IF (func_cur%NOTFOUND) THEN
      CLOSE  func_cur;
      RETURN 'FALSE';
   ELSE
      CLOSE func_cur;
   END IF;
   RETURN 'TRUE';
END Is_Codepart_Function;


@UncheckedAccess
PROCEDURE Get_Name (
  code_name_     OUT VARCHAR2,
  company_    IN     VARCHAR2,
  code_part_  IN     VARCHAR2 )
IS
BEGIN
   code_name_ := Get_Name(company_,
                          code_part_);
END Get_Name;


@UncheckedAccess
FUNCTION Get_Name (
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   name_       VARCHAR2(20);

   CURSOR get_code_name IS
      SELECT code_name
      FROM ACCOUNTING_CODE_PART_TAB
      WHERE company = company_
      AND code_part = code_part_;
BEGIN
   name_ := substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,
                                                                        'ACCRUL',
                                                                        'AccountingCodeParts',
                                                                        code_part_),1,20);
   IF (name_ IS NULL) THEN
      OPEN get_code_name;
      FETCH get_code_name INTO name_;
      CLOSE get_code_name;
   END IF;
   RETURN name_;
END Get_Name;


@UncheckedAccess
FUNCTION Encode (
   company_    IN VARCHAR2,
   code_name_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_code_part IS
     SELECT code_part
     FROM   ACCOUNTING_CODE_PARTS
     WHERE  company   = company_
     AND    code_name = code_name_;
   code_part_           VARCHAR2(1);
BEGIN
   OPEN   get_code_part;
   FETCH  get_code_part INTO code_part_;
   CLOSE  get_code_part;
   RETURN code_part_;
END Encode;


PROCEDURE Get_Max_Number_Of_Char (
   max_number_of_char_      OUT VARCHAR2,
   company_              IN     VARCHAR2,
   code_part_            IN     VARCHAR2 )
IS
   CURSOR max_cur IS
      SELECT max_number_of_char
      FROM   accounting_code_part_tab
      WHERE  company   = company_
      AND    code_part = code_part_;
BEGIN
   OPEN  max_cur;
   FETCH max_cur INTO max_number_of_char_;
   CLOSE max_cur;
END Get_Max_Number_Of_Char;


@UncheckedAccess
FUNCTION Get_Codepart_Function (
   company_        IN VARCHAR2,
   function_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_code_part IS
      SELECT code_part
      FROM   accounting_code_part_tab
      WHERE  company            = company_
      AND    code_part_function = function_;

   CURSOR get_code_part1 IS
      SELECT code_part
      FROM   accounting_code_part_tab
      WHERE  company           = company_
      AND    logical_code_part = 'Project';
   --
   dummy_            VARCHAR2(20);
   dummy_internal_   VARCHAR2(200) := NULL;
   --
BEGIN
   -- Refresh dictionary cache will truncate the dicationary_sys tables and will return null.Therefore Modified the IF condition 
   -- to use conditional compilation and added PRACC to the IF condition to avoid returning project codepart for any codepart function.
   $IF Component_Genled_SYS.INSTALLED $THEN
      OPEN  get_code_part;
      FETCH get_code_part INTO dummy_;
      WHILE ( get_code_part%FOUND) LOOP
         dummy_internal_ := dummy_internal_ || dummy_;
         FETCH get_code_part INTO dummy_;
      END LOOP;
      CLOSE get_code_part;
   $ELSE
      -- Added the IF condition ("PRACC") to return the code part with logical_code_part = 'Project' to have backward compatibility with bug 28814. 
      IF ( function_ = 'PRACC') THEN
         OPEN  get_code_part1;
         FETCH get_code_part1 INTO dummy_;
         WHILE ( get_code_part1%FOUND) LOOP
           dummy_internal_ := dummy_internal_ || dummy_;
           FETCH get_code_part1 INTO dummy_;
         END LOOP;
         CLOSE get_code_part1;
      END IF;
   $END
   RETURN dummy_internal_;
END Get_Codepart_Function;


PROCEDURE Get_Code_Part (
   code_part_    OUT VARCHAR2,
   company_   IN     VARCHAR2,
   code_name_ IN     VARCHAR2 )
IS
   CURSOR c1 IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PARTS_USED2
      WHERE  company   = company_
      AND    code_name = code_name_;
BEGIN
   OPEN  c1;
   FETCH c1 INTO code_part_;
   IF c1%NOTFOUND THEN
      Error_Sys.Record_General( 'AccountingCodeParts','INVALIDCODENAME: No CodePart Exists For The Entered Code Name');
   END IF;
   CLOSE c1;
END Get_Code_Part;

PROCEDURE Get_Valid_Code_Part (
   code_part_    OUT VARCHAR2,
   company_   IN     VARCHAR2,
   code_name_ IN     VARCHAR2 )
IS
   code_part_func_   VARCHAR2(20);  
   CURSOR c1 IS
      SELECT code_part,code_part_function_db
      FROM   accounting_code_parts_used
      WHERE  company   = company_
      AND    code_name = code_name_;
BEGIN
   OPEN  c1;
   FETCH c1 INTO code_part_,code_part_func_;
   IF c1%NOTFOUND THEN
      CLOSE c1;
      Error_Sys.Record_General( 'AccountingCodeParts','INVALIDCODENAME: No CodePart Exists For The Entered Code Name');
   END IF;
   CLOSE c1;
   IF(code_part_func_ = 'INTERN')THEN
      Error_Sys.Record_General( 'AccountingCodeParts','CODEPARTINT: Code part ' ||code_name_|| ' is only used for Internal Ledger.');
   END IF;
END Get_Valid_Code_Part;


PROCEDURE Get_Code_Part2 (
   code_part_    OUT VARCHAR2,
   company_   IN     VARCHAR2,
   code_name_ IN     VARCHAR2 )
IS
   CURSOR get_code_part IS
      SELECT code_part
      FROM   ACC_CODE_PARTS_GROCON_LOV
      WHERE  rep_ent_company   = company_
      AND    code_name         = code_name_;
BEGIN
   OPEN  get_code_part;
   FETCH get_code_part INTO code_part_;
   IF get_code_part%NOTFOUND THEN
      CLOSE get_code_part;
      Error_Sys.Record_General( 'AccountingCodeParts','INVACODEPARTNAME: No CodePart Exists For The Entered Code Name :P1' , code_name_ );
   ELSE
      CLOSE get_code_part;  
   END IF;
END Get_Code_Part2;

@UncheckedAccess
PROCEDURE Get_All_Code_Part_Names (
   code_part_a_name_     IN OUT VARCHAR2,
   code_part_b_name_     IN OUT VARCHAR2,
   code_part_c_name_     IN OUT VARCHAR2,
   code_part_d_name_     IN OUT VARCHAR2,
   code_part_e_name_     IN OUT VARCHAR2,
   code_part_f_name_     IN OUT VARCHAR2,
   code_part_g_name_     IN OUT VARCHAR2,
   code_part_h_name_     IN OUT VARCHAR2,
   code_part_i_name_     IN OUT VARCHAR2,
   code_part_j_name_     IN OUT VARCHAR2,
   company_              IN     VARCHAR2 )
IS
   CURSOR all_code_parts IS
      SELECT code_part, code_name
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company = company_
      AND    code_part BETWEEN 'A' AND 'J';
BEGIN
   FOR code_part_ IN all_code_parts LOOP
      IF (code_part_.code_part = 'A') THEN
         code_part_a_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'A'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'B') THEN
         code_part_b_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'B'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'C') THEN
         code_part_c_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'C'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'D') THEN
         code_part_d_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'D'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'E') THEN
         code_part_e_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'E'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'F') THEN
         code_part_f_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'F'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'G') THEN
         code_part_g_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'G'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'H') THEN
         code_part_h_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'H'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'I') THEN
         code_part_i_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'I'),1,20), code_part_.code_name);
      ELSIF (code_part_.code_part = 'J') THEN
         code_part_j_name_ := nvl(substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', 'J'),1,20), code_part_.code_name);
      ELSE  -- for Account
         NULL;
      END IF;
   END LOOP;
END Get_All_Code_Part_Names;


@UncheckedAccess
FUNCTION Get_Codepart_Function_Db (
   company_        IN VARCHAR2,
   function_db_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_code_part IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company            = company_
      AND    code_part_function = function_db_;
   code_part_                     VARCHAR2(1);
   internal_                      VARCHAR2(200);
BEGIN
   OPEN   get_code_part;
   FETCH  get_code_part INTO code_part_;
   WHILE ( get_code_part%FOUND ) LOOP
      internal_ := internal_ || code_part_;
      FETCH  get_code_part INTO code_part_;
   END LOOP;
   CLOSE  get_code_part;
   RETURN internal_;
END Get_Codepart_Function_Db;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Log_Code_Part (
   code_part_             OUT VARCHAR2,
   view_name_             OUT VARCHAR2,
   pkg_name_              OUT VARCHAR2,
   internal_name_         OUT VARCHAR2,
   company_            IN     VARCHAR2,
   logical_code_part_  IN     VARCHAR2 )
IS
   CURSOR c1 IS
      SELECT code_part, view_name, pkg_name, code_name
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company           = company_
      AND    logical_code_part = logical_code_part_;
   code_name_     VARCHAR2(20);
BEGIN
   IF logical_code_part_ = 'NotUsed' THEN
      Error_Sys.Record_General( 'AccountingCodeParts', 'INVLOGCODEPART: Logical Code Part cannot have the value :p1 ', logical_code_part_);
   END IF;
   OPEN  c1;
   FETCH c1 INTO code_part_, view_name_, pkg_name_, internal_name_;
   code_name_ := substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts', code_part_),1,20);
   IF (code_name_ IS NOT NULL) THEN
      internal_name_ := code_name_;
   END IF;
   IF c1%NOTFOUND THEN
      Error_Sys.Record_General( 'AccountingCodeParts', 'NOLOGCODEPART: No CodePart Exists for the Logical Code Part');
   END IF;
   CLOSE c1;
END Get_Log_Code_Part;


FUNCTION Code_Part_Function_Used (
   company_                 IN VARCHAR2,
   codepart_function_db_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR Is_Used ( codepart_function_db_ IN VARCHAR2 ) IS
      SELECT 1
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company = company_
      AND    code_part_function = codepart_function_db_ ;
   dummy_    NUMBER;
BEGIN
   IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      IF (codepart_function_db_ != 'INTERN') THEN
         OPEN  Is_Used (codepart_function_db_);
         FETCH Is_Used INTO dummy_ ;
         IF (Is_Used%FOUND) THEN
            CLOSE  Is_Used;
            RETURN TRUE;
         ELSE
            CLOSE  Is_Used;
            RETURN FALSE;
         END IF;
      ELSE
         RETURN TRUE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;
END Code_Part_Function_Used;


PROCEDURE Get_Required_Codeparts (
   req_code_b_          IN OUT VARCHAR2,
   req_code_c_          IN OUT VARCHAR2,
   req_code_d_          IN OUT VARCHAR2,
   req_code_e_          IN OUT VARCHAR2,
   req_code_f_          IN OUT VARCHAR2,
   req_code_g_          IN OUT VARCHAR2,
   req_code_h_          IN OUT VARCHAR2,
   req_code_i_          IN OUT VARCHAR2,
   req_code_j_          IN OUT VARCHAR2,
   company_             IN     VARCHAR2,
   accnt_               IN     VARCHAR2,
   voucher_date_        IN     DATE )
IS
   codepart_rec_ Accounting_Codestr_API.CodestrRec;
BEGIN
   Accounting_Code_Part_A_API.Get_Required_Code_Part ( codepart_rec_, company_, accnt_ );
   req_code_b_ := codepart_rec_.code_b;
   req_code_c_ := codepart_rec_.code_c;
   req_code_d_ := codepart_rec_.code_d;
   req_code_e_ := codepart_rec_.code_e;
   req_code_f_ := codepart_rec_.code_f;
   req_code_g_ := codepart_rec_.code_g;
   req_code_h_ := codepart_rec_.code_h;
   req_code_i_ := codepart_rec_.code_i;
   req_code_j_ := codepart_rec_.code_j;
END Get_Required_Codeparts;


PROCEDURE Validate_Codepart (
   company_        IN VARCHAR2,
   codevalue_      IN VARCHAR2,
   code_part_      IN VARCHAR2,
   voucher_date_   IN DATE )
IS
   no_code_part               EXCEPTION;
   code_part_value_not_found  EXCEPTION;
BEGIN
   -- A=65 J=74
   IF (ASCII(code_part_) BETWEEN 65 AND 74) THEN
      IF (NOT Accounting_Code_Part_Value_API.Validate_Code_Part(company_, code_part_, codevalue_, voucher_date_)) THEN
         RAISE code_part_value_not_found;
      END IF;
   ELSE
      RAISE no_code_part;
   END IF;
EXCEPTION
   WHEN code_part_value_not_found THEN
        Error_SYS.Appl_General(lu_name_,'MISSCODE: The value :P2 used for the code part :P1 is either missing, is a budget/planning code part value or has invalid time interval', 
                               Accounting_Code_Parts_API.Get_Name(company_,code_part_), codevalue_);   
   WHEN no_code_part THEN
        Error_SYS.appl_general(lu_name_,'INVCODEPART: Invalid code part :P1 is given.', code_part_ );
END Validate_Codepart;

@UncheckedAccess
FUNCTION Log_Code_Part_Used(
   company_             IN VARCHAR2,
   logical_code_part_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR Is_Log_Used IS
      SELECT DISTINCT(logical_code_part)
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company = company_
      AND    logical_code_part = logical_code_part_ ;
   dummy_    ACCOUNTING_CODE_PART_TAB.logical_code_part%TYPE;
BEGIN
  IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      OPEN  Is_Log_Used;
      FETCH Is_Log_Used INTO dummy_ ;
      IF (Is_Log_Used%FOUND) THEN
         CLOSE  Is_Log_Used;
         RETURN TRUE;
      ELSE
         CLOSE  Is_Log_Used;
         RETURN FALSE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;
END Log_Code_Part_Used;


@UncheckedAccess
PROCEDURE Get_Acc_Code_Parts_Msg (
   msg_        OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
   CURSOR get_code_parts IS
      SELECT code_name, code_part_used_db, code_part_function_db, logical_code_part_db
      FROM   ACCOUNTING_CODE_PARTS
      WHERE  company = company_
      AND    code_part BETWEEN 'A' AND 'J'
      ORDER BY code_part;
   i_    NUMBER;
BEGIN
   msg_ := Message_SYS.Construct('ACC_CODE_PARTS');
   i_   := 0;
   FOR rec_ IN get_code_parts LOOP
      i_ := i_ + 1;
      Message_SYS.Add_Attribute(msg_, 'CODE_PART_NAME', rec_.code_name);
      Message_SYS.Add_Attribute(msg_, 'CODE_PART_USED_DB', rec_.code_part_used_db);
      $IF Component_Genled_SYS.INSTALLED $THEN
         Message_SYS.Add_Attribute(msg_, 'CODE_PART_FUNCTION', rec_.code_part_function_db);
      $ELSE
         Message_SYS.Add_Attribute(msg_, 'CODE_PART_FUNCTION', rec_.logical_code_part_db);
      $END
   END LOOP;
   IF (i_ = 0) THEN
      msg_ := NULL;
   END IF;
END Get_Acc_Code_Parts_Msg;

@UncheckedAccess
PROCEDURE Get_Blocked_Code_Parts (
   blocked_code_parts_ IN OUT VARCHAR2,
   company_            IN     VARCHAR2 )
IS
   CURSOR get_code_part_used IS
      SELECT code_part_used
      FROM   ACCOUNTING_CODE_PART_TAB 
      WHERE  company    = company_
      AND    code_part BETWEEN 'B' AND 'J'      
      ORDER BY code_part;
BEGIN
   blocked_code_parts_ := NULL;
   FOR rec_ IN get_code_part_used LOOP
      blocked_code_parts_ := blocked_code_parts_ || rec_.code_part_used;      
   END LOOP;
END Get_Blocked_Code_Parts;


@UncheckedAccess
FUNCTION Get_Blocked_Code_Parts (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_code_part_used IS
      SELECT code_part_used
        FROM ACCOUNTING_CODE_PART_TAB 
       WHERE company    = company_
         AND code_part BETWEEN 'B' AND 'J'
       ORDER BY code_part;
   blocked_code_parts_ VARCHAR2(20);
BEGIN
   blocked_code_parts_ := NULL;
   FOR rec_ IN get_code_part_used LOOP
      blocked_code_parts_ := blocked_code_parts_ || rec_.code_part_used;      
   END LOOP;
   RETURN blocked_code_parts_;
END Get_Blocked_Code_Parts;


PROCEDURE Get_Code_Part_For_Logical(
   code_part_         OUT    VARCHAR2,
   company_           IN     VARCHAR2,
   logical_code_part_ IN     VARCHAR2 )
IS
BEGIN
   code_part_ := Get_Code_Part_For_Logical(company_,
                                           logical_code_part_);
END Get_Code_Part_For_Logical;

-- without company security
@UncheckedAccess
FUNCTION Get_Code_Part_For_Logical_Code(
   company_           IN     VARCHAR2,
   logical_code_part_ IN     VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_code_part IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company           = company_
      AND    logical_code_part = logical_code_part_;

   code_part_     VARCHAR2(10);
BEGIN
   IF logical_code_part_ <> 'NotUsed' THEN
      OPEN  get_code_part;
      FETCH get_code_part INTO code_part_;
      CLOSE get_code_part;
   END IF;   
   RETURN code_part_;
END Get_Code_Part_For_Logical_Code;

@UncheckedAccess
FUNCTION Get_Code_Part_For_Logical(
   company_           IN     VARCHAR2,
   logical_code_part_ IN     VARCHAR2 ) RETURN VARCHAR2
IS   
BEGIN
   RETURN Get_Code_Part_For_Logical_Code(company_, logical_code_part_);
END Get_Code_Part_For_Logical;

@UncheckedAccess
FUNCTION Get_Base_For_Followup_Element (
   company_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_base_for_pfe IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company      = company_
      AND    base_for_pfe = 'TRUE';
   code_part_  VARCHAR2(1); 
BEGIN
   OPEN get_base_for_pfe;
   FETCH get_base_for_pfe INTO code_part_;
   IF get_base_for_pfe%FOUND THEN
      CLOSE get_base_for_pfe; 
      RETURN code_part_;
   END IF;
   CLOSE get_base_for_pfe;
   RETURN NULL;
END Get_Base_For_Followup_Element;


@UncheckedAccess
FUNCTION Check_Base_for_Pfe_Exists (
   company_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE company      = company_
      AND   base_for_pfe = 'TRUE';
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Base_for_Pfe_Exists;

@UncheckedAccess
FUNCTION Check_Exist (
   company_     IN VARCHAR2,
   code_part_   IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(company_,code_part_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist;

-- UMDOLK NOTE: Change the references
@UncheckedAccess
PROCEDURE Get_Additional_Code_Parts_Msg (
   msg_               OUT   VARCHAR2,
   company_           IN    VARCHAR2 )
IS
   count_    NUMBER;
   
   CURSOR get_add_code_parts IS
      SELECT substr(nvl(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, 'ACCRUL', 'AccountingCodeParts',
             company_||'^'||code_part), code_name), 1, 20) code_name, 
             code_part_used, code_part_mapping_exists
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company = company_
      AND    code_part BETWEEN 'K' AND 'T'
      ORDER BY code_part;   
BEGIN
   msg_ := Message_SYS.Construct('ADDITIONAL_CODE_PARTS');
   count_   := 0;
   FOR rec_ IN get_add_code_parts LOOP
      count_ := count_ + 1;
      Message_SYS.Add_Attribute(msg_, 'CODE_PART_NAME', rec_.code_name);
      Message_SYS.Add_Attribute(msg_, 'CODE_PART_USED', rec_.code_part_used);
      Message_SYS.Add_Attribute(msg_, 'CODE_PART_MAPPING_EXISTS', rec_.code_part_mapping_exists);      
   END LOOP;
   IF (count_ = 0) THEN
      msg_ := NULL;
   END IF;
END Get_Additional_Code_Parts_Msg;

PROCEDURE Get_Code_Part_All (
   code_part_    OUT VARCHAR2,
   company_   IN     VARCHAR2,
   code_name_ IN     VARCHAR2 )
IS
   CURSOR get_code_part IS
      SELECT code_part
      FROM   ALL_CODE_PARTS
      WHERE  company    = company_
      AND    code_name  = code_name_
      AND    code_part  NOT IN ('A', 'K', 'L', 'M')
      AND    code_part_used_db = 'Y';
BEGIN
   OPEN  get_code_part;
   FETCH get_code_part INTO code_part_;
   IF (get_code_part%NOTFOUND) THEN
      CLOSE get_code_part;
      Error_Sys.Record_General( lu_name_,'INVACODEPARTNAME: No CodePart Exists For The Entered Code Name :P1' , code_name_ );
   ELSE
      CLOSE get_code_part;  
   END IF;
END Get_Code_Part_All;

-- UMDOLK NOTE: Remove this by directly calling the method
@UncheckedAccess
FUNCTION Get_Codepart_All_Description (
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN                 
   RETURN Get_Description2(company_, code_part_);         
END Get_Codepart_All_Description;

-- UMDOLK NOTE: Remove this by directly calling the method
@UncheckedAccess
FUNCTION Get_Codename_All (
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN                 
   RETURN Get_Name(company_, code_part_);   
END Get_Codename_All;

PROCEDURE Code_Part_Exists (
   code_part_ IN     VARCHAR2 )
IS
   temp_ NUMBER; 
   
   CURSOR get_code_part IS
      SELECT 1
      FROM  ACCOUNTING_CODE_PART_TAB 
      WHERE  code_part = code_part_
      AND    code_part  NOT IN ('A', 'K', 'L', 'M');
BEGIN
   OPEN  get_code_part;
   FETCH get_code_part INTO temp_;
   IF (get_code_part%NOTFOUND) THEN
      CLOSE get_code_part;
      Error_Sys.Record_General( lu_name_,'INVACODEPARTNAME: No CodePart Exists For The Entered Code Name :P1' , code_part_ );
   ELSE
      CLOSE get_code_part;  
   END IF;
END Code_Part_Exists;

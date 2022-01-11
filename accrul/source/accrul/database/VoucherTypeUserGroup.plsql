-----------------------------------------------------------------------------
--
--  Logical unit: VoucherTypeUserGroup
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960415  PEJON    Created
--  960911  MiJo     Add new view to support project group = P for ready report
--                   project.
--  960912  PEJON    Added new view to support LOV in voucher entry
--  970114  MAGU     Corrected the word serie to series PROCEDURE Voucher_Serie_Delete_Allowed
--  970211  YoHe     Added column voucher_type_desc in &VIEW3
--  970307  AnDj     Corrected bug 97-0011
--  970404  MiJo     Added procedure to check IF combination voucher type and
--                   voucher group exist
--  970410  ViGu     Added column voucher_type_desc in &VIEW and &VIEW2
--                   Removed 'L' flag on Accounting_Year and User_Group in the above views.
--  970603  DavJ     Modified Error Message Text in Procedure Validate_Voucher_Type
--  970709  SLKO     Converted to Foundation 1.2.2d
--  970917  DAKA     VOUCHER_TYPE_USER_GROUP corrected to restore former functionality as LOV
--  980309  PICZ     Added VOUCHER_TYPE_USER_GRP_VOU_GRP
--  980921  Bren     Master Slave Connection
--                   Added Send_Vou_User_Info___, Send_Vou_User_Info_Delete___
--                   Send_Vou_User_Info_Modify___, Receive_Vou_User_Info .
--  990409  JPS      Modified with respect to New Template (Foundation 2.2.1)
--  000321  Bren     Added Create_Vou_Type_User_Group.
--  000322  Upul     Added Insert_User_Group , Do_Insert_User_Group & Check_User_Group.
--  000525  Kumudu   Remove Insert_User_Group and Do_Insert_User_Group .
--  000724  Uma      A536: Journal Code. Added Function_Group.
--  000724  Kumudu   Added new view as a  VOUCHER_TYPE_USER_GRP_INTERNAL.
--  000802  Uma      Changed Insert___ and Update___ with respect to A536.
--  000804  Uma      Changed Create_Vou_Type_User_Group with respect to A536.
--  000808  Uma      Changed VIEW3.
--  000808  Kumudu   Added new methods as Get_Default_Int_Vou_Type and Check_Int_Vou_Type_Valid.
--  000815  Uma      Changed Validate_Voucher_Type with respect to A536.
--                   Added voucher_group to the view VOUCHER_TYPE_USER_GROUP.
--  000817  Uma      Added voucher_group in insert___ and update___.
--  000828  Kumudu   Added new view VOUCHER_TYPE_INTERIM_VOU and method as Get_Def_Interim_Vou_Type.
--  000905  Uma      Changed Error msg in Voucher_Type_Delete_Allowed according to A536
--  000907  Kumudu   Added new view as VOUCHER_TYPE_INTERNAL_PERIOD and public function Get_Int_Vou_Type.
--  000913  Camk     Call #47935 Corrected.
--  000921  Uma      Corrected BugId #48194. Added ledger validations in Unpack_Check_Update.
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001009  Uma      Made corrections in VOUCHER_TYPE_USER_GRP_FA.
--  001009  Kumudu   Bug # 49510 Added new public method as Check_Fa_Vou_Type  .
--  001201  ovjose   For new Create Company concept added new view voucher_type_user_group_ect and voucher_type_user_group_pct. 
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010823  Gawilk   Bug # 23834 fixed. Added Function_Group_Modify_Allowed and check the 
--                   function group in Unpack_Check_Update___.
--  011008  Suumlk   Bug # 25068 fixed changed the order of keys in PROCEDURE Check_Delete___ and Delete___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020613  Uma      Corrected Bug# 29843. Added key function_group.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in viewes 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021106  KuPelk   IID ESFI110N Year End Accounting. Added some check statements to Unpack_Check_Insert 
--                   and Unpack_Check_Update method.
--  031006  Mnisse   Validate_Voucher_Type(), NOTFOUND check inside for loop changed.
--  031017  Brwelk   Added Cascade_Delete and removed CASCADE from view.
--  040326  Gepelk   2004 SP1 Merge
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  051107  Gawilk   Added view VOUCHER_TYPE_USER_GRP_ALL_GL
--  051118  WAPELK   Merged the Bug 52783. Correct the user group variable's width.
--  051128  Gawilk   LCS-51863. Added view VOUCHER_TYPE_USER_GROUP_INT
--  061011  NAMELK   Merged LCS Bug 58585, Modified the call in PROCEDURE Check_Delete__,
--                   from Is_Voucher_Type_Used_Internal to Is_User_Group_Used_Internal in
--  061127  Paralk   Merged LCS Bug 61065,Added accounting_year_ parameter to Is_User_Group_Used_Internal  
--  061127           and remove Is_User_Group_Used methods. and changed some validations in Check_Delete__ 
--  070222  NuFilk   FIPL609B. Modified Unpack_Check_Insert___ and Unpack_Check_Update___.
--  070316  Iswalk   FIPL609B, Added VOUCHER_TYPE_USER_GRP_FA_GL_IL.
--  070507  Chhulk   B143458 Modified VOUCHER_TYPE_USER_GROUP3
--  070515  Surmlk   Added ifs_assert_safe comment
--  070627  Shsalk   LCS Merge 65962. Modified Get_Default_Int_Vou_Type method.
--  070801  RUFELK   FIPL609B - Moved the VOUCHER_TYPE_USER_GRP_FA_GL_IL view to FaUtil.apy.
--  080310  Nsillk   Bug 71922, Corrected.Added method Check_Int_Only_Vou_Type , used in Internal Ledger Period Allocation
--  090210  Nirplk   Bug 77430, Validated the function group for authorization level. 
--  090605  THPELK   Bug 82609 - Removed aditional UNDEFINE statement for VIEW12.
--  090717  ErFelk   Bug 83174, Replaced constant INVALIDCOMB with INVVOUTYPE2 in Exist.
--  090810  LaPrlk   Bug 79846, Removed the precisions defined for NUMBER type variables.
--  090819  Mawelk   Bug 85094, Corrected.Rename the view VOUCHER_TYPE_USER_GRP_VOU_GRP to VOUCHER_TYPE_USER_VOV
--  091104  Jaralk   Bug 86478, modified error message in Function_Group_Delete_Allowed()
--  091221  HimRlk   Reverse engineering correcton, Removed method Voucher_Type_Delete_Allowed. Added REF to VoucherType from column voucher_type
--  091221           and added REF to UserGroupFinance from column user_group.
-- -------------------SIZZLER---------------------------------------------------
--  111010  Ersruk   Modified view VOUCHER_TYPE_USER_GROUP2 to add ledger id.
--  100312  Nsillk   EAFH-2455,Modified methods Import and Export to add support for user defined calendar
--  100426  Surwlk   Modified the key order of Check_Delete___ and Delete___.
--  110718  Nsillk   FIDEAGLE-537, Merged Bug 94459
--  111031  Shdilk   SFI-96, Added Get_Voucher_Types_For_Supplier.
--  111107  Shdilk   SFI-636, Added Get_Voucher_Types_For_Customer.
--  130509  Hecolk   Bug 109947, Modified PROCEDURE Create_Vou_Type_User_Group   
--  130819  Clstlk   Bug 111221, Corrected functions without RETURN statement in all code paths.
-------------------------------------------------------------------------------
--  121210  Maaylk   PEPA-183, Removed global variables
--  131121  MEALLK   PBFI-2131, Refactoring code
--  141217  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from VOUCHER_TYPE_USER_GROUP_TAB
-----------------------------------------------------------------------------
--  150206  PKurlk   PRFI-5178, Modified an error message for voucher types.
--  151008  chiblk   STRFI-200, New__ changed to New___ in Create_Vou_Type_User_Group
--  151118  Bhhilk   STRFI-39, Modified DefaultType enumeration to FinanceYesNo.
--  190107  Nudilk   Bug 146161, Corrected.
--  190226  Chwilk   Bug 147025, Added Check_User_Group() with function_group.
--  200117  Nudilk   Bug 151930, Corrected in Create_Vou_Type_User_Group.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   newrec_        VOUCHER_TYPE_USER_GROUP_TAB%ROWTYPE;
   empty_rec_     VOUCHER_TYPE_USER_GROUP_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN := FALSE;
   any_rows_      BOOLEAN := FALSE;
   data_found_    BOOLEAN := FALSE;
   year_found_    BOOLEAN;
   min_year_      NUMBER;
   max_year_      NUMBER;
   fetch_year_    NUMBER;

   CURSOR get_data IS
      SELECT C1, C2, C3, C4, C5, C6, N1
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM VOUCHER_TYPE_USER_GROUP_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.voucher_type = src.C1
                         AND dest.accounting_year = src.N1
                         AND dest.user_group = src.C2
                         AND dest.function_group = src.C5);

   CURSOR get_cal_data IS
      SELECT accounting_year
        FROM Accounting_Year_Tab
       WHERE company = crecomp_rec_.company;

   CURSOR get_user_data(year_ NUMBER) IS
      SELECT C1, C2, C3, C5, C6
        FROM Create_Company_Template_Pub
       WHERE component   = 'ACCRUL'
         AND lu          = lu_name_
         AND template_id = crecomp_rec_.template_id
         AND version     = crecomp_rec_.version
         AND N1          = year_;

   CURSOR get_min_max IS
      SELECT MAX(N1),MIN(N1)
        FROM Create_Company_Template_Pub
       WHERE component   = 'ACCRUL'
         AND lu          = lu_name_
         AND template_id = crecomp_rec_.template_id
         AND version     = crecomp_rec_.version;
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF (update_by_key_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
         SAVEPOINT make_company_insert;
         data_found_ := TRUE;
         BEGIN            
            newrec_ := empty_rec_;
            newrec_.company           := crecomp_rec_.company;
            newrec_.voucher_type      := rec_.c1;
            newrec_.accounting_year   := rec_.n1;
            newrec_.user_group        := rec_.c2; 
            newrec_.default_type      := rec_.c3;
            newrec_.function_group    := rec_.c5;
            newrec_.authorize_level   := rec_.c6;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
         END;
      END LOOP;
      
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');
         END IF;
      END IF;
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            OPEN get_min_max;
            FETCH get_min_max INTO min_year_,max_year_;
            CLOSE get_min_max;
            FOR rec_ IN get_cal_data LOOP
               year_found_ := FALSE;
               FOR grp_rec_ IN get_user_data(rec_.accounting_year) LOOP              
                  
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  SAVEPOINT make_company_insert;
                  year_found_ := TRUE;
                  data_found_ := TRUE;
                  BEGIN
                     newrec_.company           := crecomp_rec_.company;
                     newrec_.voucher_type      := grp_rec_.c1;
                     newrec_.accounting_year   := rec_.accounting_year;
                     newrec_.user_group        := grp_rec_.c2;
                     newrec_.default_type      := grp_rec_.c3;
                     newrec_.function_group    := grp_rec_.c5;
                     newrec_.authorize_level   := grp_rec_.c6;
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
                  END;
               END LOOP;
               IF (NOT year_found_) THEN
                  IF (rec_.accounting_year < min_year_) THEN
                     fetch_year_ := min_year_;
                  ELSIF (rec_.accounting_year > max_year_) THEN
                     fetch_year_ := max_year_;
                  END IF;
                  FOR grp_rec_ IN get_user_data(fetch_year_) LOOP
                     
                     i_ := i_ + 1;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     SAVEPOINT make_company_insert;
                     data_found_ := TRUE;
                     BEGIN
                        newrec_.company           := crecomp_rec_.company;
                        newrec_.voucher_type      := grp_rec_.C1;
                        newrec_.accounting_year   := rec_.accounting_year;
                        newrec_.user_group        := grp_rec_.c2;
                        newrec_.default_type      := grp_rec_.c3;
                        newrec_.function_group    := grp_rec_.c5;
                        newrec_.authorize_level   := grp_rec_.c6;
                        New___(newrec_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           @ApproveTransactionStatement(2014-03-24,dipelk)
                           ROLLBACK TO make_company_insert;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
                     END;
                  END LOOP;
               END IF;
            END LOOP;
         ELSE
            FOR rec_ IN get_data LOOP
               
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               SAVEPOINT make_company_insert;
               data_found_ := TRUE;
               BEGIN
                  newrec_.company           := crecomp_rec_.company;
                  newrec_.voucher_type      := rec_.c1;
                  newrec_.accounting_year   := rec_.n1;
                  newrec_.user_group        := rec_.c2; 
                  newrec_.default_type      := rec_.c3;
                  newrec_.function_group    := rec_.c5;
                  newrec_.authorize_level   := rec_.c6;
                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);                                                   
               END;
            END LOOP;      
         END IF;
         IF ( i_ = 0 ) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF msg_ IS NULL THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;      
      END IF;         
   END IF;      
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);                                          
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');                           
END Import___;   


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   newrec_        VOUCHER_TYPE_USER_GROUP_TAB%ROWTYPE;
   empty_rec_     VOUCHER_TYPE_USER_GROUP_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN := FALSE;
   year_found_    BOOLEAN;
   min_year_      NUMBER;
   max_year_      NUMBER;
   fetch_year_    NUMBER;
   any_rows_      BOOLEAN := FALSE;
   data_found_    BOOLEAN := FALSE;

   CURSOR get_data IS                                                            
      SELECT voucher_type, accounting_year, user_group, default_type, function_group, authorize_level
      FROM   voucher_type_user_group_tab src 
      WHERE  company = crecomp_rec_.old_company
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = src.company
               AND   vt.voucher_type = src.voucher_type),' ') IN ('00','*',' ')
      AND    NOT EXISTS (SELECT 1 
                         FROM voucher_type_user_group_tab dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.voucher_type = src.voucher_type
                         AND dest.accounting_year = src.accounting_year
                         AND dest.user_group = src.user_group
                         AND dest.function_group = src.function_group);
   CURSOR get_cal_data IS
      SELECT accounting_year
        FROM Accounting_Year_Tab
       WHERE company = crecomp_rec_.company;

   CURSOR get_user_data(year_ NUMBER) IS
      SELECT voucher_type,user_group,default_type,function_group,authorize_level
        FROM voucher_type_user_group_tab  vtu
       WHERE company         = crecomp_rec_.old_company
         AND accounting_year = year_
         AND EXISTS (SELECT 1
                  FROM  voucher_type_tab vt
                  WHERE vt.company      = vtu.company
                  AND   vt.voucher_type = vtu.voucher_type
                  AND   vt.ledger_id IN ('00','*'));

   CURSOR get_min_max IS
      SELECT MAX(accounting_year),MIN(accounting_year)
        FROM voucher_type_user_group_tab vtu
       WHERE company = crecomp_rec_.old_company
       AND EXISTS (SELECT 1
                  FROM  voucher_type_tab vt
                  WHERE vt.company      = vtu.company
                  AND   vt.voucher_type = vtu.voucher_type
                  AND   vt.ledger_id IN ('00','*'));
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);         
   IF (update_by_key_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
         SAVEPOINT make_company_insert;
         data_found_ := TRUE;
         BEGIN
            newrec_ := empty_rec_;
            newrec_.voucher_type      := rec_.voucher_type;
            newrec_.accounting_year   := rec_.accounting_year;
            newrec_.user_group        := rec_.user_group; 
            newrec_.default_type      := rec_.default_type;
            newrec_.function_group    := rec_.function_group;
            newrec_.authorize_level   := rec_.authorize_level;
            newrec_.company := crecomp_rec_.company;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
         END;
      END LOOP;
      
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');
         END IF;
      END IF;
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            OPEN get_min_max;
            FETCH get_min_max INTO min_year_,max_year_;
            CLOSE get_min_max;
            FOR rec_ IN get_cal_data LOOP
               year_found_ := FALSE;
               FOR grp_rec_ IN get_user_data(rec_.accounting_year) LOOP
                  year_found_ := TRUE;
                  data_found_ := TRUE;
                  BEGIN
                     newrec_.company           := crecomp_rec_.company;
                     newrec_.voucher_type      := grp_rec_.voucher_type;
                     newrec_.accounting_year   := rec_.accounting_year;
                     newrec_.user_group        := grp_rec_.user_group;
                     newrec_.default_type      := grp_rec_.default_type;
                     newrec_.function_group    := grp_rec_.function_group;
                     newrec_.authorize_level   := grp_rec_.authorize_level;
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
                  END;
               END LOOP;
               IF (NOT year_found_) THEN
                  IF rec_.accounting_year < min_year_ THEN
                     fetch_year_ := min_year_;
                  ELSIF rec_.accounting_year > max_year_ THEN
                     fetch_year_ := max_year_;
                  END IF;
                  FOR grp_rec_ IN get_user_data(fetch_year_) LOOP
                     data_found_ := TRUE;
                     BEGIN
                        newrec_.company           := crecomp_rec_.company;
                        newrec_.voucher_type      := grp_rec_.voucher_type;
                        newrec_.accounting_year   := rec_.accounting_year;
                        newrec_.user_group        := grp_rec_.user_group;
                        newrec_.default_type      := grp_rec_.default_type;
                        newrec_.function_group    := grp_rec_.function_group;
                        newrec_.authorize_level   := grp_rec_.authorize_level;
                        New___(newrec_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
                     END;
                  END LOOP;
               END IF;
            END LOOP;
         ELSE
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               SAVEPOINT make_company_insert;
               data_found_ := TRUE;
               BEGIN
                  newrec_ := empty_rec_;                  
                  newrec_.voucher_type      := rec_.voucher_type;
                  newrec_.accounting_year   := rec_.accounting_year;
                  newrec_.user_group        := rec_.user_group; 
                  newrec_.default_type      := rec_.default_type;
                  newrec_.function_group    := rec_.function_group;
                  newrec_.authorize_level   := rec_.authorize_level;
                  newrec_.company           := crecomp_rec_.company;
                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
      END IF;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;      
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'Error', msg_);                                                
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');                           
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   voucher_type_user_group_tab vtu
      WHERE  company = crecomp_rec_.company
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = vtu.company
               AND   vt.voucher_type = vtu.voucher_type),' ') IN ('00','*',' ');
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := 'ACCRUL';
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.voucher_type;
      pub_rec_.n1 := pctrec_.accounting_year;
      pub_rec_.c2 := pctrec_.user_group;
      pub_rec_.c3 := pctrec_.default_type;   
      pub_rec_.c5 := pctrec_.function_group;                    
      pub_rec_.c6 := pctrec_.authorize_level;                          
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;


PROCEDURE Check_No_Data_Found___(
   msg_         OUT VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   data_found_  IN BOOLEAN )
IS
BEGIN
   IF ( NOT data_found_ ) THEN
      msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully', msg_);
   ELSE
      IF msg_ IS NULL THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_TYPE_USER_GROUP_API', 'CreatedWithErrors');
      END IF;
   END IF;
END Check_No_Data_Found___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'AUTHORIZE_LEVEL', Authorize_Level_API.DECODE('Approved'), attr_ );
   Client_SYS.Add_To_Attr( 'DEFAULT_TYPE', Finance_Yes_No_API.Decode('N'), attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN VOUCHER_TYPE_USER_GROUP_TAB%ROWTYPE )
IS
BEGIN
   Check_Delete__(remrec_.company, remrec_.accounting_year,remrec_.voucher_type,remrec_.user_group);
   super(remrec_);
END Check_Delete___;


-- Check_Exist___
--   Check if a specific LU-instance already exist in the database.
FUNCTION Check_Exist___ (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    voucher_type    = voucher_type_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_type_user_group_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN
   super(newrec_, indrec_, attr_);
   
   Voucher_Type_Detail_API.Exist(newrec_.company, newrec_.voucher_type, newrec_.function_group);
   
   IF (newrec_.authorize_level = 'ApproveOnly' AND newrec_.function_group NOT IN ('M','Q','K')) THEN
      Error_SYS.Record_General(lu_name_, 'FUNGRPNOTALLOWED: The authorization level :P1 can only be selected for function groups M, K and Q',Authorize_Level_API.Decode(newrec_.authorize_level)); 
   END IF;   
END Check_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT voucher_type_user_group_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   ledger_id_  VARCHAR2(10);
BEGIN
   --Add pre-processing code here
   IF (newrec_.default_type = 'Y') THEN
      Update_Default__(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.user_group, newrec_.function_group);
      IF (newrec_.function_group = 'A') THEN
         ledger_id_ := Voucher_Type_API.Get_Ledger_Id(newrec_.company, newrec_.voucher_type);
         IF (ledger_id_ != '*') THEN
            Error_SYS.Record_General( lu_name_, 'DEFVOUTYPUSRGRP: The default voucher type for user group in function group A must be ''GL, affect IL''');
         END IF;
      END IF;
   END IF;   
   super(objid_, objversion_, newrec_, attr_);
   --Add post-processing code here
END Insert___;




@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_type_user_group_tab%ROWTYPE,
   newrec_ IN OUT voucher_type_user_group_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   is_used_       VARCHAR2(5);
   ledger_id_     VARCHAR2(10);
BEGIN
   ledger_id_ := Voucher_Type_API.Get_Ledger_Id(newrec_.company, newrec_.voucher_type);
   IF (ledger_id_ NOT IN ('*','00')) THEN
      Voucher_Type_API.Is_Voucher_Type_Used_Internal( is_used_, newrec_.company, newrec_.voucher_type, ledger_id_);
   END IF;
   IF ((newrec_.authorize_level IS NOT NULL) AND indrec_.authorize_level) THEN 
      IF (is_used_ = 'TRUE') THEN 
         Error_SYS.Record_General(lu_name_,'AUNOTALW: You cannot modify Authorization Level '||
                            'since there are vouchers for Voucher Type :P1', newrec_.voucher_type);
      END IF;
   END IF;
   IF ((newrec_.function_group IS NOT NULL) AND indrec_.function_group) THEN 
      IF (is_used_ = 'TRUE') THEN 
         Error_SYS.Record_General(lu_name_,'FGNOTALW: You cannot modify Function Group '||
                       'since there are vouchers for Voucher Type :P1', newrec_.voucher_type);
      ELSE
         Voucher_Type_Detail_API.Exist(newrec_.company, newrec_.voucher_type, newrec_.function_group); 
      END IF;           
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (newrec_.authorize_level = 'ApproveOnly' AND newrec_.function_group NOT IN ('M','Q','K')) THEN
      Error_SYS.Record_General( lu_name_, 'FUNGRPNOTALLOWED: The authorization level :P1 can only be selected for function groups M, K and Q',Authorize_Level_API.Decode(newrec_.authorize_level));   
   END IF;
END Check_Update___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     voucher_type_user_group_tab%ROWTYPE,
   newrec_     IN OUT voucher_type_user_group_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   ledger_id_     VARCHAR2(10);
BEGIN
   --Add pre-processing code here
   IF (newrec_.default_type = 'Y') THEN
      Update_Default__(newrec_.company,newrec_.accounting_year,newrec_.voucher_type,
                              newrec_.user_group, newrec_.function_group);
      ledger_id_ := Voucher_Type_API.Get_Ledger_Id(newrec_.company, newrec_.voucher_type);                              
      IF (newrec_.function_group = 'A') AND (ledger_id_ != '*') THEN
         Error_SYS.Record_General( lu_name_, 'DEFVOUTYPUSRGRP: The default voucher type for user group in function group A must be ''GL, affect IL''');
      END IF;
   END IF;   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   --Add post-processing code here
END Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Delete__ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   user_group_       IN VARCHAR2 )
IS
   is_used_       VARCHAR2(5);
   ledger_id_     VARCHAR2(10);
BEGIN
   ledger_id_ := Voucher_Type_API.Get_Ledger_Id(company_, voucher_type_);
   IF (ledger_id_ NOT IN ('*','00')) THEN
      Is_User_Group_Used_Internal( is_used_, company_, ledger_id_, voucher_type_, user_group_,accounting_year_);
      IF (is_used_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'VOUINTHOLD: There are vouchers in the Internal Ledger hold table for :P1 voucher type and :P2 user group.', voucher_type_,user_group_);
      END IF;
   ELSIF (ledger_id_ IN ('*','00')) THEN
      Voucher_API.Is_User_Group_Used( is_used_, company_, voucher_type_, user_group_,accounting_year_);
      IF (is_used_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'VOUGLHOLD: There are vouchers in the hold table for :P1 voucher type and :P2 user group.',voucher_type_,user_group_);
      END IF;
   END IF;
END Check_Delete__;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_Default__ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   user_group_       IN VARCHAR2,
   function_group_   IN VARCHAR2 )
IS
BEGIN
   UPDATE voucher_type_user_group_tab
   SET   default_type       = 'N'
   WHERE company            = company_
   AND   accounting_year    = accounting_year_
   AND   function_group     = function_group_
   AND   user_group         = user_group_;

   UPDATE voucher_type_user_group_tab
   SET   default_type       = 'Y'
   WHERE company            = company_
   AND   accounting_year    = accounting_year_
   AND   voucher_type       = voucher_type_
   AND   function_group   = function_group_
   AND   user_group         = user_group_;
END Update_Default__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   user_group_       IN VARCHAR2 )
IS
   msg_     VARCHAR2(2000);
BEGIN
   IF (NOT Check_Exist___(company_,
                          accounting_year_,
                          user_group_,
                          voucher_type_)) THEN
      msg_ := Language_SYS.Translate_Constant(lu_name_, 'ERRORTEXT1: for accounting year :P1 in Company :P2', Language_SYS.Get_Language, accounting_year_, company_);
      Error_SYS.Record_General(lu_name_, 'INVVOUTYPE2: User group :P1 is not connected to voucher type :P2 :P3', user_group_, voucher_type_, msg_);
   END IF;
END Exist;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_      IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   user_group_   IN VARCHAR2,
   year_         IN NUMBER )
IS
   accounting_year_ NUMBER;
BEGIN
   Exist (company_, accounting_year_, voucher_type_, user_group_ );
END Exist;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Authorize_Level (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VOUCHER_TYPE_USER_GROUP_TAB.authorize_level%TYPE;
   CURSOR get_attr IS
      SELECT authorize_level
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company = company_
      AND   accounting_year = accounting_year_
      AND   user_group = user_group_
      AND   voucher_type = voucher_type_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN Authorize_Level_API.Decode(temp_);
END Get_Authorize_Level;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Authorize_Level_Db (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VOUCHER_TYPE_USER_GROUP_TAB.authorize_level%TYPE;
   CURSOR get_attr IS
      SELECT authorize_level
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company = company_
      AND   accounting_year = accounting_year_
      AND   user_group = user_group_
      AND   voucher_type = voucher_type_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;   
   RETURN temp_;
END Get_Authorize_Level_Db;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Default_Voucher_Type (
   voucher_type_     OUT VARCHAR2,
   company_          IN  VARCHAR2,
   user_group_       IN  VARCHAR2,
   accounting_year_  IN  NUMBER,
   function_group_   IN  VARCHAR2,
   ledger_id_        IN  VARCHAR2 DEFAULT NULL)
IS
   def_voucher_type_     VARCHAR2(50);
   CURSOR get_default IS
      SELECT a.voucher_type
      FROM   VOUCHER_TYPE_USER_GROUP_TAB a, voucher_type_tab b
      WHERE  a.company         = b.company
      AND    a.voucher_type    = b.voucher_type
      AND    a.company         = company_
      AND    a.accounting_year = accounting_year_
      AND    a.user_group      = user_group_
      AND    a.function_group  = function_group_
      AND    a.default_type    = 'Y'
      AND    b.ledger_id       IN (NVL(ledger_id_,'*'), NVL(ledger_id_,'00'));
BEGIN
   OPEN get_default;
   FETCH get_default INTO def_voucher_type_;
   IF (get_default%NOTFOUND) THEN
     CLOSE get_default;
   ELSE
     CLOSE get_default;
   END IF;
   voucher_type_ := def_voucher_type_;
END Get_Default_Voucher_Type;


PROCEDURE Check_User_Have_Approvability (
   company_          IN  VARCHAR2,
   voucher_type_     IN  VARCHAR2,
   accounting_year_  IN  NUMBER,
   user_             IN  VARCHAR2 )
IS
   user_group_ VARCHAR2(30) := NULL;
   CURSOR get_user_group IS
      SELECT user_group
      FROM   voucher_type_user_group_tab
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    accounting_year  = accounting_year_
      AND    authorize_level   != 'Not Approved' ;
BEGIN
   FOR rec_ IN get_user_group LOOP
      IF (User_Group_Member_Finance_API.Is_User_Member_Of_Group( company_,    
                                                                 user_,  
                                                                 rec_.user_group )='TRUE') THEN
         user_group_ := rec_.user_group;
         EXIT;
      END IF;
   END LOOP;
   IF user_group_ IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'APPROVALNOTALLOWED: Voucher Approval not allowed as user :P1 is not connected to voucher type :P2 with approve auhorization level.', user_, voucher_type_);
   END IF;
END Check_User_Have_Approvability;

@UncheckedAccess
FUNCTION Get_Vou_Type_User_Grp (
   company_          IN  VARCHAR2,
   voucher_type_     IN  VARCHAR2,
   accounting_year_  IN  NUMBER,
   function_group_   IN  VARCHAR2,
   user_             IN  VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_user_group_per_vou_type IS
      SELECT user_group
      FROM   voucher_type_user_group_tab
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    accounting_year  = accounting_year_
      AND    function_group   = function_group_ ;
   CURSOR get_def_user_grp_per_vou_type IS
      SELECT user_group
      FROM   voucher_type_user_group_tab
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    accounting_year  = accounting_year_
      AND    function_group   = function_group_ 
      AND    default_type     = 'Y';
   user_group_       user_group_member_finance_tab.user_group%type := NULL;
BEGIN
   OPEN get_def_user_grp_per_vou_type;
   FETCH get_def_user_grp_per_vou_type INTO user_group_;

   IF get_def_user_grp_per_vou_type%FOUND THEN
      CLOSE get_def_user_grp_per_vou_type;
      -- check whether the default user group is connected to the user
      IF (User_Group_Member_Finance_API.Is_User_Member_Of_Group( company_,    
                                                                 user_,  
                                                                 user_group_)='TRUE') THEN
         RETURN user_group_;
      END IF;
   ELSE
      CLOSE get_def_user_grp_per_vou_type;
   END IF;               
   -- there is no default user_group for the voucher type
   -- iterate through all user groups connected to the voucher type and find the first match
   -- that is connected to the user
   FOR rec_ IN get_user_group_per_vou_type LOOP
      IF (User_Group_Member_Finance_API.Is_User_Member_Of_Group( company_,    
                                                                 user_,  
                                                                 rec_.user_group )='TRUE') THEN
         user_group_ := rec_.user_group;
      END IF;
      EXIT WHEN user_group_ IS NOT NULL;  
   END LOOP;
   RETURN  user_group_;
END Get_Vou_Type_User_Grp;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_If_Voucher_Type_Valid (
   valid_           OUT VARCHAR2,
   company_         IN  VARCHAR2,
   user_group_      IN  VARCHAR2,
   accounting_year_ IN  NUMBER,
   voucher_type_    IN  VARCHAR2 )
IS
   CURSOR get_default IS
      SELECT 'OK'
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    voucher_type    = voucher_type_;
BEGIN
   OPEN get_default;
   FETCH get_default INTO valid_;
   IF (get_default%NOTFOUND) THEN
      CLOSE get_default;
      Error_SYS.Record_General(lu_name_, 'NO_DEF_TYPE: The user group is not permitted to use this voucher type.' );
   ELSE
      CLOSE get_default;
   END IF;
END Check_If_Voucher_Type_Valid;


PROCEDURE Voucher_Serie_Delete_Allowed (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER )
IS
   dummy_   VARCHAR2(10);
   CURSOR check_voucher_serie IS
      SELECT 'TRUE'
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_;
BEGIN
   
   OPEN check_voucher_serie;
   FETCH check_voucher_serie INTO dummy_;
   IF (check_voucher_serie%NOTFOUND) THEN
      CLOSE check_voucher_serie;
   ELSE
      CLOSE check_voucher_serie;
      Error_SYS.Record_General(lu_name_,'NO_DEL_TYPE: You cannot delete the voucher series it has a user group attatched to it');
   END IF;
END Voucher_Serie_Delete_Allowed;


PROCEDURE Validate_Voucher_Type (
   company_          IN  VARCHAR2,
   voucher_type_     IN  VARCHAR2,
   function_group_   IN  VARCHAR2,
   accounting_year_  IN  NUMBER,
   user_group_       IN VARCHAR2 )
IS
   CURSOR check_function_group IS
      SELECT 1
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    Accounting_year  = accounting_year_
      AND    user_group       = user_group_
      AND    function_group   = function_group_;
   CURSOR check_voucher_type IS
      SELECT 1
      FROM   voucher_type_detail_tab
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    function_group   = function_group_;
   dummy_      NUMBER; 
   msg_        VARCHAR2(2000);     
BEGIN
   IF (NOT Company_Finance_API.Is_User_Authorized(company_)) THEN
      Error_SYS.Record_General(lu_name_, 'NOTAUSERTOCOM: User is Not authorised to Company :P2', company_);
   ELSE
      --  Added New error message to tackle the situation when user group is not connected to any voucher type
      --  with function group D in multicompany voucher entry
      IF (( function_group_ = 'D') AND (voucher_type_ IS NULL)) THEN
         Error_SYS.Record_General(lu_name_,
                              'USRGRNOTCONN: User group :P1 is not connected to a voucher type with function group D in Company :P2',
                              user_group_,
                              company_    );
      END IF;
      OPEN  check_function_group;
      FETCH check_function_group INTO dummy_;
      IF (check_function_group%NOTFOUND) THEN
         CLOSE check_function_group;
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'ERRORTEXT2: with function group :P1 for accounting year :P2 in Company :P3', Language_SYS.Get_Language, function_group_, accounting_year_, company_);
         Error_SYS.Record_General(lu_name_, 'INVVOUTYPE2: User group :P1 is not connected to voucher type :P2 :P3', user_group_, voucher_type_, msg_);
      END IF;
      CLOSE check_function_group;
      OPEN  check_voucher_type;
      FETCH check_voucher_type INTO dummy_;
      IF (check_voucher_type%NOTFOUND) THEN
         CLOSE check_voucher_type;
         Error_SYS.Record_General(lu_name_, 'VOUTYPNOCONN: Voucher type :P1 does not belong to function group :P2 in Company :P3',
                                             voucher_type_, function_group_, company_);
      END IF;
      CLOSE check_voucher_type;
   END IF;      
END Validate_Voucher_Type;


PROCEDURE Create_Vou_Type_User_Group (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   user_group_       IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   authorize_level_  IN VARCHAR2,
   default_type_     IN VARCHAR2,
   function_group_   IN VARCHAR2 DEFAULT '*' )
IS
   newrec_           voucher_type_user_group_tab%ROWTYPE;
   CURSOR get_function_group IS
      SELECT function_group
      FROM   Voucher_Type_Detail_Tab
      WHERE  company      = company_
      AND    voucher_type = voucher_type_;
BEGIN
   IF (Company_Finance_API.Get_Use_Vou_No_Period(company_) = 'TRUE') AND Check_Exist___ (company_, accounting_year_, user_group_, voucher_type_, function_group_) THEN
      RETURN;          
   END IF;
   IF (function_group_ = '*') OR (function_group_ IS NULL) THEN
      FOR rec_ IN get_function_group LOOP
         newrec_.company         := company_;
         newrec_.accounting_year := accounting_year_;
         newrec_.user_group      := user_group_;
         newrec_.voucher_type    := voucher_type_;
         newrec_.authorize_level := Authorize_Level_API.Encode(authorize_level_);
         newrec_.default_type    := Finance_Yes_No_API.Encode(default_type_);
         newrec_.function_group  := rec_.function_group;
      
         New___(newrec_);
      END LOOP;
   ELSE
      newrec_.company            := company_;
      newrec_.accounting_year    := accounting_year_;
      newrec_.user_group         := user_group_;
      newrec_.voucher_type       := voucher_type_;
      newrec_.authorize_level    := Authorize_Level_API.Encode(authorize_level_);
      newrec_.default_type       := Finance_Yes_No_API.Encode(default_type_);
      newrec_.function_group     := function_group_;
      
      New___(newrec_);
   END IF;
END Create_Vou_Type_User_Group;


@UncheckedAccess
FUNCTION Check_User_Group(
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(company_,accounting_year_,user_group_,voucher_type_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_User_Group;


@UncheckedAccess
FUNCTION Check_User_Group(
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   function_group_  IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(company_,accounting_year_,user_group_,voucher_type_,function_group_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_User_Group;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Function_Group_Delete_Allowed (
   company_        IN VARCHAR2,
   function_group_ IN VARCHAR2,
   voucher_type_   IN VARCHAR2 )
IS
   CURSOR check_function_group IS
      SELECT 'TRUE'
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company        = company_
      AND    voucher_type   = voucher_type_
      AND    function_group = function_group_ ;
   dummy_                VARCHAR2(10);
BEGIN
   OPEN check_function_group;
   FETCH check_function_group INTO dummy_;
   IF (check_function_group %NOTFOUND) THEN
      CLOSE check_function_group;
   ELSE
      CLOSE check_function_group;
      Error_SYS.Record_General(lu_name_, 'NOFUNCGROUPCHG1: You cannot delete Function Group of a Voucher Type, it has a User Group connected to Voucher Series');
   END IF;
END Function_Group_Delete_Allowed;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Default_Int_Vou_Type (
   voucher_type_    OUT VARCHAR2,
   company_         IN  VARCHAR2,
   user_group_      IN  VARCHAR2,
   accounting_year_ IN  NUMBER,
   function_group_  IN  VARCHAR2,
   ledger_id_       IN  VARCHAR2 )
IS
   def_voucher_type_     VARCHAR2(50);
   CURSOR get_default IS
      SELECT voucher_type
      FROM   voucher_type_user_grp_internal
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    function_group  = function_group_
      AND    ledger_id       = ledger_id_
      AND    default_type_db = 'Y' ;
BEGIN
   OPEN get_default;
   FETCH get_default INTO def_voucher_type_;
   CLOSE get_default;
  voucher_type_ := def_voucher_type_;
END Get_Default_Int_Vou_Type;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Def_Interim_Vou_Type (
   voucher_type_    OUT VARCHAR2,
   company_         IN  VARCHAR2,
   user_group_      IN  VARCHAR2,
   accounting_year_ IN  NUMBER,
   function_group_  IN  VARCHAR2,
   ledger_id_       IN  VARCHAR2 )
IS
   def_voucher_type_     VARCHAR2(50);
   CURSOR get_default IS
      SELECT voucher_type
      FROM   voucher_type_interim_vou
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    function_group  = function_group_
      AND    ledger_id       = ledger_id_
      AND    default_type_db = 'Y' ;
BEGIN
   OPEN get_default;
   FETCH get_default INTO def_voucher_type_;
   CLOSE get_default;
   voucher_type_ := def_voucher_type_;
END Get_Def_Interim_Vou_Type;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_Int_Vou_Type_Valid (
   valid_           OUT VARCHAR2,
   company_         IN  VARCHAR2,
   user_group_      IN  VARCHAR2,
   accounting_year_ IN  NUMBER,
   voucher_type_    IN  VARCHAR2,
   ledger_id_       IN  VARCHAR2 )
IS
   CURSOR get_default IS
      SELECT 'OK'
      FROM   voucher_type_user_grp_internal
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    voucher_type    = voucher_type_
      AND    ledger_id       = ledger_id_;
BEGIN
   OPEN get_default;
   FETCH get_default INTO valid_;
   IF (get_default%NOTFOUND) THEN
      CLOSE get_default;
      Error_SYS.Record_General(lu_name_, 'NO_DEF_TYPE: The user group is not permitted to use this voucher type.' );
   ELSE
      CLOSE get_default;
   END IF;
END Check_Int_Vou_Type_Valid;


@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Int_Vou_Type (
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   accounting_year_ IN NUMBER,
   function_group_  IN VARCHAR2,
   ledger_id_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   vou_type_     VARCHAR2(50);
   CURSOR get_voutype IS
      SELECT voucher_type
      FROM   voucher_type_internal_period
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    function_group  = function_group_
      AND    ledger_id       = ledger_id_
      AND    default_type_db = 'Y' ;
BEGIN
   OPEN get_voutype ;
   FETCH get_voutype INTO vou_type_;
   CLOSE get_voutype;
   RETURN  vou_type_;
END Get_Int_Vou_Type; 


@UncheckedAccess
FUNCTION Get_Voucher_Types_For_Supplier (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,    
   user_group_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   voucher_types_    VARCHAR2(2000);
   CURSOR get_voucher_types IS
      SELECT voucher_type
      FROM   VOUCHER_TYPE_USER_GROUP
      WHERE  company = company_
      AND    user_group  = user_group_
      AND    accounting_year = accounting_year_
      AND    function_group IN ('I','J');
BEGIN
   FOR voucher_rec_ IN get_voucher_types LOOP
      voucher_types_ := voucher_types_ || voucher_rec_.voucher_type || ',';
   END LOOP;
   RETURN voucher_types_;
END Get_Voucher_Types_For_Supplier;


@UncheckedAccess
FUNCTION Get_Voucher_Types_For_Customer (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,    
   user_group_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   voucher_types_    VARCHAR2(2000);
   CURSOR get_voucher_types IS
      SELECT voucher_type
      FROM   VOUCHER_TYPE_USER_GROUP
      WHERE  company = company_
      AND    user_group  = user_group_
      AND    accounting_year = accounting_year_
      AND    function_group IN ('F');
BEGIN
   FOR voucher_rec_ IN get_voucher_types LOOP
      voucher_types_ := voucher_types_ || voucher_rec_.voucher_type || ',';
   END LOOP;
   RETURN voucher_types_;
END Get_Voucher_Types_For_Customer;


FUNCTION Check_Fa_Vou_Type (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   user_group_      IN VARCHAR2,
   voucher_type_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR exist_vou_type IS
      SELECT 1
      FROM   voucher_type_user_grp_fa
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    user_group      = user_group_
      AND    voucher_type    = voucher_type_;
   dummy_          NUMBER;
   fa_vou_type_    VARCHAR2(10);
BEGIN
   OPEN exist_vou_type;
   FETCH exist_vou_type INTO dummy_;
   IF (exist_vou_type%FOUND) THEN
      CLOSE exist_vou_type;
      fa_vou_type_ :='TRUE';
   ELSE
      CLOSE exist_vou_type;
      fa_vou_type_ :='FALSE';
   END IF;
   RETURN fa_vou_type_;
END Check_Fa_Vou_Type;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Function_Group_Modify_Allowed (
   company_        IN VARCHAR2,
   function_group_ IN VARCHAR2,
   voucher_type_   IN VARCHAR2 )
IS
   CURSOR check_function_group IS
      SELECT 'TRUE'
      FROM   VOUCHER_TYPE_USER_GROUP_TAB
      WHERE  company        = company_
      AND    voucher_type   = voucher_type_
      AND    function_group = function_group_;
   dummy_    VARCHAR2(10);
BEGIN
   OPEN check_function_group;
   FETCH check_function_group INTO dummy_;
   IF (check_function_group %NOTFOUND) THEN
      CLOSE check_function_group;
   ELSE
      CLOSE check_function_group;
      Error_SYS.Record_General(lu_name_, 'NOFUNCGROUPCHG: You cannot change the Function Group it has a User Group attached to it');
   END IF;
END Function_Group_Modify_Allowed;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Cascade_Delete (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM   Voucher_Type_User_Group_Tab
   WHERE  Company         = company_
   AND    Accounting_Year = accounting_year_
   AND    Voucher_Type    = voucher_type_;
END Cascade_Delete;


PROCEDURE Is_User_Group_Used_Internal (
   is_used_          OUT VARCHAR2,
   company_          IN VARCHAR2,
   ledger_id_        IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   user_group_       IN VARCHAR2,
   accounting_year_  IN NUMBER )
IS
BEGIN
   is_used_ := 'FALSE';
   $IF Component_Intled_SYS.INSTALLED $THEN
      is_used_ := Internal_Hold_Voucher_API.Is_User_Group_Used(company_,ledger_id_,voucher_type_,user_group_,accounting_year_);
   $END
END Is_User_Group_Used_Internal;


PROCEDURE Check_Int_Only_Vou_Type (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   ledger_id_       IN VARCHAR2 )
IS
   CURSOR check_int_per_alloc IS
      SELECT 1 
        FROM voucher_type_tab a
       WHERE company      = company_
         AND voucher_type = voucher_type_
         AND ledger_id    = ledger_id_;
   temp_   NUMBER;         
BEGIN
   OPEN check_int_per_alloc;
   FETCH check_int_per_alloc INTO temp_;
   IF (check_int_per_alloc%NOTFOUND) THEN
      CLOSE check_int_per_alloc;
      Error_SYS.Record_General(lu_name_, 'NO_DEF_TYPE: The user group is not permitted to use this voucher type.' );
   ELSE
      CLOSE check_int_per_alloc;
   END IF;
END Check_Int_Only_Vou_Type;



PROCEDURE Create_Vou_Type_User_Group (
   company_                   IN VARCHAR2,
   source_year_               IN NUMBER,   
   accounting_year_           IN NUMBER )
IS
   newrec_       voucher_type_user_group_tab%ROWTYPE;
   
   CURSOR get_data IS
      SELECT * 
      FROM   voucher_type_user_group_tab 
      WHERE  company         = company_
      AND    accounting_year = source_year_;
BEGIN
   FOR rec_ IN get_data LOOP
      newrec_.voucher_type      := rec_.voucher_type;
      newrec_.accounting_year   := accounting_year_;
      newrec_.user_group        := rec_.user_group; 
      newrec_.default_type      := rec_.default_type;
      newrec_.function_group    := rec_.function_group;
      newrec_.authorize_level   := rec_.authorize_level;
      newrec_.company           := company_;
      New___(newrec_);
   END LOOP;
END Create_Vou_Type_User_Group;

FUNCTION Get_Interim_Simu_Vou_Type(
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   accounting_year_ IN NUMBER,
   function_group_  IN VARCHAR2,
   ledger_id_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 
IS
   non_default_simu_vou_type_    VARCHAR2(5);
   
   CURSOR get_non_def_sim IS
         SELECT a.voucher_type
         FROM   VOUCHER_TYPE_USER_GROUP_TAB a, voucher_type_tab b
         WHERE  a.company         = b.company
         AND    a.voucher_type    = b.voucher_type
         AND    a.company         = company_
         AND    a.accounting_year = accounting_year_
         AND    a.user_group      = user_group_
         AND    a.function_group  = function_group_
         AND    b.ledger_id       IN (NVL(ledger_id_,'*'), NVL(ledger_id_,'00'))
         AND ROWNUM = 1;
BEGIN
   OPEN get_non_def_sim;
   FETCH get_non_def_sim INTO non_default_simu_vou_type_;
   CLOSE get_non_def_sim;
   RETURN non_default_simu_vou_type_;   
END Get_Interim_Simu_Vou_Type;


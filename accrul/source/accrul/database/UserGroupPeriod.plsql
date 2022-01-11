-----------------------------------------------------------------------------
--
--  Logical unit: UserGroupPeriod
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960415  jela     Base Table to Logical Unit Generator 1.0A
--  970116  YoHe     Added procedure Is_Period_Open, Is_Period_Open_Date
--  970708  SLKO     Converted to Foundation 1.2.2d
--  980127  PICZ     Added function Is_Period_Open_For_Other_Than
--  980914  ToKu     Bug # 4973 ( added procedure Is_Period_Open_Date__)
--                   Also added General_SYS.Init_Method
--  980923  Bren     Master Slave Connection
--                   Added Send_User_Period_Info___, Send_User_Period_Info_Modify___,
--                   Send_User_Period_Info_Delete___, Receive_User_Period_Info.
--  990317  Bren     Bug #: 5779. Added Is_Period_Open___ & Is_Period_Open_ to handle overloaded functions.
--  981204  ToKu     Bug # 8065 fixed.
--  990413  JPS      Performed the Template Changes.(Foundation 2.2.1)
--  991221  SaCh     Removed public procedure Check_If_Closed which supported 7.3.1
--  000105  SaCh     Added public procedure Check_If_Closed.
--  000914  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001219  OVJOSE   For new Create Company concept added public procedure Make Company and added implementation
--                   procedures Import___, Copy___, Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010612  ARMOLK   Bug # 15677 Add call to General_SYS.Init_Method
--  010731  Brwelk   Added year end period checks to unpack_check_insert & Insert_User_Group.
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020129  THSRLK   IID 20004 - Removed def_tab from methord Export___.
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in USER_GROUP_PERIOD view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021015  Jakalk   Salsa Pre-Work Wish List. Removed method call 'Is_User_Authorized' in impl. methods.
--  021101  Dagalk   IID ITFI103N Internal Ledger Year end .Add field period_status_int .
--  021105  Dagalk   IID ITFI103N Internal Ledger Year end .Add conditions to period_status_int .
--  021106  Dagalk   IID ITFI103N Internal Ledger Year end .Add company template data .

--  030417  JeGuse   ESFI110N - Added function Check_Exist
--  030430  Raablk   RDFI140NG - Added Get_Dafault_User_Group.
--  030430  Jeguse   RDFI140NG - Renamed Get_Dafault_User_Group to Get_Default_User_Group and adjusted.
--  030804  Nimalk   SP4 Merge
--  030930  Raablk   LCS 38472 Merged.
--  031020  Brwelk   Init_Method Corrections
--  031104  prdilk   Added Is_Period_Open_GL_IL_Others, Is_Period_Open_GL_IL and Is_Period_Open_GL_IL___ Functions.
--  040329  Gepelk   2004 SP1 Merge.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  041005  WAPELK   Bug 45325 Merged.
--  050120  AnGiSe   Bug 120600 Changed error message constant NODELGRP to NODELETEGRP for language file to be updated.
--  050908  Nsillk   Bug 51513,Merged.
--  060908  Iswalk   B137001Added Next_Open_Period( ).
--  061011  Namelk   LCS Bug 58585 Merged. Call INTERNAL_HOLD_MANUAL_API.Check_Voucher to check
--                   whether there are vouchers in belonging to a particular user group.
--                   Modified check delete, to check whether there are transactions in hold tables of intled and genled.
--  070213  Kagalk   LCS Merge 62943, Modified Is_Period_Open_Date2 to get only ordinary periods.
--  070409  GaDalk   B142121 Added Get_Year_And_Period( ).
--  070515  Surmlk   Added ifs_assert_safe comment
--  070702  Paralk LCS Merge 65950 added Get_And_Validate_Il_Period()
--  071103  Yothlk   Bug 68462, Modified method Get_And_Validate_Period and Get_And_Validate_Il_Period 
--  081104  Makelk   Bug 78226, Modified the Method Next_Open_Period().
--  090219  reanpl   Bug 82373, SKwP Ceritificate - Final Closing of Period (SKwP-2)
--  090717  ErFelk   Bug 83174, Changed error messages of POSTWAIT and PERSTAT in Unpack_Check_Update___ and Unpack_Check_Insert___.
--  090727  Marulk   Bug 83535. Added validation on User Group Period closing.
--  090810  LaPrlk   Bug 79846, Removed the precisions defined for NUMBER type variables.
--  091104  CLSTLK   Bug 86324, Modified method Is_Period_Open_Date2().
--  091221  HimRlk   Reverse engineering correction, Removed method Period_Delete_Allowed. And added REF to AccountingPeriod 
--  091221           in column accounting_period in the view.
--  100312  Nsillk   EAFH-2455,Modified methods Import and Export to add support for user defined calendar
--  100420  Nsillk   EAFH-2684,Modified Import and Copy methods
--  100726  MAAYLK   Bug 92106, Added year period value to the error message.
--  121207  Maaylk   PEPA-183, Removed global variable
--  140407  Kanslk   Bug 112867, Modified 'Is_Period_Open_Date__()'.
--  151008  chiblk  STRFI-200, New__ changed to New___ in Insert_User_Group
--  151118  chiblk   STRFI-607 replace the enumeration Acc_Per_Status with Acc_Year_Per_Status.
--  160330  SAVMLK   STRFI-1626, Bug 128136 merged.
--  160608  CHWTLK   STRFI-2024, Merged LCS Bug 129625, Modified Check_Common___.
--  180508  Bhhilk   Bug 141473, Added new method Get_User_Grp_Period_Type.
--  190107  Nudilk   Bug 146161, Corrected.
--  201027  Chaulk   Bug 156027, Modified Copy___  method to set the period status.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Is_Period_Open___ (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   user_group_          IN VARCHAR2,
   ledger_id_           IN VARCHAR2 DEFAULT '00') RETURN VARCHAR2
IS
   status_  VARCHAR2(10);

   CURSOR is_period_open IS
      SELECT  period_status
      FROM    user_group_period_tab
      WHERE   company = company_
        AND   accounting_year    = accounting_year_
        AND   accounting_period  = accounting_period_
        AND   user_group         = user_group_
        AND   ledger_id          = ledger_id_;
        
   CURSOR is_period_open_all_ledger IS
      SELECT 1
      FROM   user_group_period_tab
      WHERE company =  company_
      AND   accounting_year    = accounting_year_
      AND   accounting_period  = accounting_period_
      AND   user_group         = user_group_
      AND   period_status      = 'C';
BEGIN
   IF ledger_id_ != '*' THEN
      OPEN is_period_open;
      FETCH is_period_open INTO status_;
      IF (is_period_open%NOTFOUND) THEN
         CLOSE is_period_open;
         RETURN 'FALSE';
      ELSE
         CLOSE is_period_open;
         IF status_ = 'O' THEN
            RETURN 'TRUE';
         ELSE
            RETURN 'FALSE';
         END IF;
      END IF;
   ELSE
      OPEN is_period_open_all_ledger;
      FETCH is_period_open_all_ledger INTO status_;
      IF (is_period_open_all_ledger%NOTFOUND) THEN
         CLOSE is_period_open_all_ledger;
         RETURN 'TRUE';
      ELSE
         CLOSE is_period_open_all_ledger;
         RETURN 'FALSE';
      END IF;
   END IF;
END Is_Period_Open___;

-- This method has the old parameter list without the ledger ID. 
-- This was written to get rid of the issues that are raised when calling the exist method
@UncheckedAccess
PROCEDURE Exist (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   user_group_        IN VARCHAR2  )
IS
BEGIN
   Exist(company_, accounting_year_, accounting_period_, user_group_, '00');
END Exist;


PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        user_group_period_tab%ROWTYPE;
   empty_rec_     user_group_period_tab%ROWTYPE;
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
      SELECT C1, C2, C3, C4, N1, N2
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM USER_GROUP_PERIOD_TAB dest
                         WHERE dest.company           = crecomp_rec_.company
                         AND   dest.user_group        = src.C1
                         AND   dest.accounting_year   = src.N1
                         AND   dest.accounting_period = src.N2
                         AND   dest.ledger_id         = src.C4);

   CURSOR get_cal_data IS
      SELECT accounting_year,accounting_period
        FROM Accounting_Period_Tab
       WHERE company = crecomp_rec_.company;

   CURSOR get_user_data(year_ NUMBER,period_ NUMBER) IS
      SELECT C1,C2,C3,C4
        FROM Create_Company_Template_Pub
       WHERE component   = 'ACCRUL'
         AND lu          = lu_name_
         AND template_id = crecomp_rec_.template_id
         AND version     = crecomp_rec_.version
         AND N1          = year_
         AND N2          = period_;

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
      IF (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE') THEN
         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
            data_found_ := TRUE;
            BEGIN         
               newrec_ := empty_rec_;
               newrec_.company                     := crecomp_rec_.company;
               newrec_.accounting_year             := rec_.n1;
               newrec_.accounting_period           := rec_.n2;
               newrec_.user_group                  := rec_.c1;
               newrec_.period_status               := rec_.c2;
               newrec_.ledger_id                   := rec_.c4;
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
            END;
         END LOOP;
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
               FOR grp_rec_ IN get_user_data(rec_.accounting_year,rec_.accounting_period) LOOP
                  i_ := i_ + 1;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  SAVEPOINT make_company_insert;
                  year_found_ := TRUE;
                  data_found_ := TRUE;
                  BEGIN                     
                     newrec_ := empty_rec_;
                     newrec_.company                     := crecomp_rec_.company;
                     newrec_.accounting_year             := rec_.accounting_year;
                     newrec_.accounting_period           := rec_.accounting_period;
                     newrec_.user_group                  := grp_rec_.c1;
                     newrec_.period_status               := grp_rec_.c2;
                     newrec_.ledger_id                   := grp_rec_.c4;
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
                  END;
               END LOOP;
               IF (NOT year_found_) THEN
                  IF rec_.accounting_year < min_year_ THEN
                     fetch_year_ := min_year_;
                  ELSIF rec_.accounting_year > max_year_ THEN
                     fetch_year_ := max_year_;
                  END IF;
                  FOR grp_rec_ IN get_user_data(fetch_year_,rec_.accounting_period) LOOP
                     i_ := i_ + 1;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     SAVEPOINT make_company_insert;
                     data_found_ := TRUE;
                     BEGIN                        
                        newrec_ := empty_rec_; 
                        newrec_.company                     := crecomp_rec_.company;
                        newrec_.accounting_year             := rec_.accounting_year;
                        newrec_.accounting_period           := rec_.accounting_period;
                        newrec_.user_group                  := grp_rec_.c1;
                        newrec_.period_status               := grp_rec_.c2;
                        newrec_.ledger_id                   := grp_rec_.c4;
                        New___(newrec_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           @ApproveTransactionStatement(2014-03-24,dipelk)
                           ROLLBACK TO make_company_insert;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
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
   
                  newrec_.company                     := crecomp_rec_.company;
                  newrec_.accounting_year             := rec_.n1;
                  newrec_.accounting_period           := rec_.n2;
                  newrec_.user_group                  := rec_.c1;
                  newrec_.period_status               := rec_.c2;
                  newrec_.ledger_id                   := rec_.c4;
                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
      END IF;
   END IF;
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_    Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_          NUMBER := 1;
   CURSOR get_data IS
      SELECT user_group, accounting_year, accounting_period, ledger_id
      FROM   user_group_period_tab
      WHERE  company = crecomp_rec_.company
      AND    ledger_id = '00';
   CURSOR get_def_data IS
       SELECT *
       FROM   create_company_template_pub
       WHERE  COMPONENT = 'ACCRUL'
       AND    LU    = 'UserGroupPeriod'
       AND    template_id = crecomp_rec_.user_template_id;

BEGIN
   IF (crecomp_rec_.user_template_id IS NULL) THEN
      FOR pctrec_ IN get_data LOOP
         pub_rec_.template_id := crecomp_rec_.template_id;
         pub_rec_.component := 'ACCRUL';
         pub_rec_.version  := crecomp_rec_.version;
         pub_rec_.lu := lu_name_;
         pub_rec_.item_id := i_;
         pub_rec_.c1 := pctrec_.user_group;
         pub_rec_.n1 := pctrec_.accounting_year;
         pub_rec_.n2 := pctrec_.accounting_period;
         pub_rec_.c2 := 'O';
         pub_rec_.c3 := 'O';
         pub_rec_.c4 := pctrec_.ledger_id;
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   ELSE
      FOR pctrec_ IN get_def_data LOOP
         pub_rec_.template_id := crecomp_rec_.template_id;
         pub_rec_.component := 'ACCRUL';
         pub_rec_.version  := crecomp_rec_.version;
         pub_rec_.lu := lu_name_;
         pub_rec_.item_id := i_;
         pub_rec_.c1 := pctrec_.c1;
         pub_rec_.n1 := pctrec_.n1;
         pub_rec_.n2 := pctrec_.n2;
         pub_rec_.c2 := pctrec_.c2;
         pub_rec_.c3 := pctrec_.c3;
         pub_rec_.c4 := pctrec_.c4;
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   END IF;
END Export___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        USER_GROUP_PERIOD_TAB%ROWTYPE;
   empty_rec_     USER_GROUP_PERIOD_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   any_rows_      BOOLEAN := FALSE;
   data_found_    BOOLEAN := FALSE;
   update_by_key_ BOOLEAN;
   year_found_    BOOLEAN;
   min_year_      NUMBER;
   max_year_      NUMBER;
   fetch_year_    NUMBER;
   
   CURSOR get_data IS
      SELECT accounting_year,accounting_period, user_group, ledger_id, period_status
      FROM   USER_GROUP_PERIOD_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND    ledger_id = '00'
      AND NOT EXISTS (SELECT 1
                      FROM USER_GROUP_PERIOD_TAB dest
                      WHERE dest.company           = crecomp_rec_.company
                      AND   dest.user_group        = src.user_group
                      AND   dest.accounting_year   = src.accounting_year
                      AND   dest.accounting_period = src.accounting_period
                      AND   ledger_id              = src.ledger_id);

   CURSOR get_cal_data IS
      SELECT accounting_year,accounting_period
      FROM Accounting_Period_Tab
      WHERE company = crecomp_rec_.company;
   CURSOR get_user_data(year_ NUMBER,period_ NUMBER) IS
      SELECT user_group, ledger_id, period_status
      FROM user_group_period_tab
      WHERE company         = crecomp_rec_.old_company
      AND accounting_year   = year_
      AND accounting_period = period_
      AND ledger_id = '00';
   CURSOR get_min_max IS
      SELECT MAX(accounting_year),MIN(accounting_year)
      FROM user_group_period_tab
      WHERE company = crecomp_rec_.old_company
      AND  ledger_id = '00';
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);

   IF (update_by_key_) THEN
      IF (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE') THEN
         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
            data_found_ := TRUE;
            BEGIN
               newrec_ := empty_rec_;
               -- assign the full record
               newrec_.accounting_year     := rec_.accounting_year;
               newrec_.accounting_period   := rec_.accounting_period;
               newrec_.user_group          := rec_.user_group;
               newrec_.company             := crecomp_rec_.company;
               newrec_.ledger_id           := rec_.ledger_id;
               newrec_.period_status       := rec_.period_status;
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
            END;
         END LOOP;
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
               FOR grp_rec_ IN get_user_data(rec_.accounting_year,rec_.accounting_period) LOOP
                  year_found_ := TRUE;
                  data_found_ := TRUE;
                  BEGIN
                     -- reset variables
                     newrec_ := empty_rec_;                     
                     
                     newrec_.company                     := crecomp_rec_.company;
                     newrec_.accounting_year             := rec_.accounting_year;
                     newrec_.accounting_period           := rec_.accounting_period;
                     newrec_.user_group                  := grp_rec_.user_group;
                     newrec_.period_status               := grp_rec_.period_status;
                     newrec_.ledger_id                   := grp_rec_.ledger_id;
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
                  END;
               END LOOP;
               IF (NOT year_found_) THEN
                  IF rec_.accounting_year < min_year_ THEN
                     fetch_year_ := min_year_;
                  ELSIF rec_.accounting_year > max_year_ THEN
                     fetch_year_ := max_year_;
                  END IF;
                  FOR grp_rec_ IN get_user_data(fetch_year_,rec_.accounting_period) LOOP
                     data_found_ := TRUE;
                     BEGIN
                        newrec_ := empty_rec_;                                             
                        
                        newrec_.company                     := crecomp_rec_.company;
                        newrec_.accounting_year             := rec_.accounting_year;
                        newrec_.accounting_period           := rec_.accounting_period;
                        newrec_.user_group                  := grp_rec_.user_group;
                        newrec_.period_status               := grp_rec_.period_status;
                        newrec_.ledger_id                   := grp_rec_.ledger_id;
                        New___(newrec_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
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
                  -- reset variables
                  newrec_ := empty_rec_;
                  -- assign the full record
                  newrec_.accounting_year     := rec_.accounting_year;
                  newrec_.accounting_period   := rec_.accounting_period;
                  newrec_.user_group          := rec_.user_group;
                  newrec_.company             := crecomp_rec_.company; 
                  newrec_.ledger_id           := rec_.ledger_id;
                  newrec_.period_status       := rec_.period_status;
                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
      END IF;
   END IF;
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Check_No_Data_Found___(
   msg_         OUT VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   data_found_  IN BOOLEAN )
IS
BEGIN
   IF ( NOT data_found_ ) THEN
      msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedSuccessfully', msg_);
   ELSE
      IF msg_ IS NULL THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_PERIOD_API', 'CreatedWithErrors');
      END IF;
   END IF;
END Check_No_Data_Found___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'PERIOD_STATUS', Acc_Year_Per_Status_API.Get_Client_Value(0), attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN USER_GROUP_PERIOD_TAB%ROWTYPE )
IS
   postings_in_wait_      VARCHAR2(5);
BEGIN
   super(remrec_);
   
   IF (remrec_.ledger_id  = '00') THEN 
      Voucher_API.Check_If_Postings_In_Vou_User(postings_in_wait_,
                                                remrec_.company,
                                                remrec_.accounting_period,
                                                remrec_.accounting_year,
                                                remrec_.user_group);
   
      IF (postings_in_wait_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'POSTWAIT: There are vouchers in the hold table for period :P1 - :P2 and user group :P3',
                                  remrec_.accounting_year,
                                  remrec_.accounting_period,
                                  remrec_.user_group);
      END IF;
   END IF;
   IF (remrec_.ledger_id != '00') THEN 
      $IF Component_Intled_SYS.INSTALLED $THEN
         IF( INTERNAL_HOLD_MANUAL_API.Check_Voucher(remrec_.company,remrec_.accounting_year,remrec_.accounting_period,remrec_.user_group, remrec_.ledger_id) = 'TRUE')THEN
            Error_SYS.Record_General(lu_name_,'POSTWAITINT: There are vouchers in the Internal Ledger hold table for period :P1 - :P2 and user group :P3',
                                     remrec_.accounting_year,
                                     remrec_.accounting_period,
                                     remrec_.user_group);
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT user_group_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);

   IF (User_Group_Finance_Api.Get_Allowed_Acc_Period(newrec_.company, newrec_.user_group ) = '2') THEN
      IF (Accounting_Period_Api.Is_Year_End_Period(newrec_.company,newrec_.accounting_year,newrec_.accounting_period) = FALSE) THEN
         Error_SYS.Record_General(lu_name_, 'YEARENDONLY: User group :P1 is only allowed for year-end periods.',newrec_.user_group);
      END IF;
   ELSE
      IF (Accounting_Period_Api.Is_Year_End_Period(newrec_.company,newrec_.accounting_year,newrec_.accounting_period) = TRUE) THEN
         Error_SYS.Record_General(lu_name_, 'ORDINARYONLY: User group :P1 is only allowed for ordinary periods.',newrec_.user_group);
      END IF;
   END IF;

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     user_group_period_tab%ROWTYPE,
   newrec_ IN OUT user_group_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                  VARCHAR2(30);
   value_                 VARCHAR2(4000);
   postings_in_wait_      VARCHAR2(5);
   dummy_                 NUMBER;

   CURSOR check_period_allocation(company_ VARCHAR2, alloc_year_ NUMBER, alloc_period_ NUMBER, user_group_ VARCHAR2) IS
      SELECT 1
      FROM   period_allocation_tab
      WHERE  company      = company_
      AND    alloc_year   = alloc_year_
      AND    alloc_period = alloc_period_
      AND    user_group   = user_group_;

BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
     
   ---------------------------------------------------------------------------
   IF( (newrec_.period_status = 'C')  AND (newrec_.ledger_id != '00'))THEN
      $IF Component_Intled_SYS.INSTALLED $THEN
         IF( INTERNAL_HOLD_MANUAL_API.Check_Voucher(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, newrec_.user_group, newrec_.ledger_id) = 'TRUE')THEN
            Error_SYS.Data_Access_Security(lu_name_,'POSTWAITINTCOMP: There are vouchers in the Internal Ledger hold table. :P1 Company: :P2 :P1 Period: :P3 :P4 :P1 User Group: :P5',
                                    chr(10)||chr(13),
                                    newrec_.company,
                                    newrec_.accounting_year,
                                    newrec_.accounting_period,
                                    newrec_.user_group);
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
   ---------------------------------------------------------------------------
   IF ( newrec_.period_status = 'C' OR newrec_.period_status = 'F') THEN
      IF (newrec_.ledger_id = '00') THEN 
         Voucher_API.Check_If_Postings_In_Vou_User(postings_in_wait_,
                                                   newrec_.company,
                                                   newrec_.accounting_period,
                                                   newrec_.accounting_year,
                                                   newrec_.user_group);
         IF (postings_in_wait_ = 'TRUE') THEN            
                                  
            Error_SYS.Data_Access_Security(lu_name_,'POSTWAITCOMP: There are vouchers in the hold table. :P1 Company: :P2 :P1 Accoounting Period: :P3 :P4 :P1 User Group: :P5',
                                          chr(10)||chr(13),
                                          newrec_.company,
                                          newrec_.accounting_year,
                                          newrec_.accounting_period,
                                          newrec_.user_group);
         END IF;
      END IF;
      OPEN check_period_allocation(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, newrec_.user_group);
      FETCH check_period_allocation INTO dummy_;
      IF (check_period_allocation%FOUND) THEN
         CLOSE check_period_allocation;
         Error_SYS.Record_General(lu_name_, 'USERGPER_STATUS: You cannot change the status on this period :P1 it exists in Period Allocation table in company :P2', 
                                 newrec_.accounting_period,
                                 newrec_.company);
      END IF;
      CLOSE check_period_allocation;
   END IF;

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     user_group_period_tab%ROWTYPE,
   newrec_ IN OUT user_group_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   closed_ VARCHAR2(10);
BEGIN
   IF (newrec_.ledger_id != '00') THEN 
      Check_If_Closed(closed_, newrec_.company, newrec_.accounting_year, newrec_.accounting_period, '00');
      IF (newrec_.period_status = 'C' AND closed_ = 'OPEN') THEN
         Error_Sys.Record_General(lu_name_,'PERSTAT: GL Period Status should be closed before Status of IL Period is in Closed.');
      END IF;
   END IF;
   IF (newrec_.ledger_id = '00') THEN 
      IF (newrec_.period_status = 'O' AND (Check_All_Ils_Open___(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, newrec_.user_group) = 'FALSE')) THEN
         Error_Sys.Record_General(lu_name_,'ILPERCL: The IL period should be in Open status before you open the GL period.');
      END IF;
   END IF;
   IF ((newrec_.period_status = 'O') AND (Acc_Period_Ledger_Info_API.Is_Period_Open(newrec_.company,newrec_.accounting_year,newrec_.accounting_period, newrec_.ledger_id) = 'FALSE')) THEN
      IF(newrec_.ledger_id = '00') THEN
         Error_SYS.Record_General(lu_name_,'NOCLOSEGL: The period for user group :P1 can not be opened for the general ledger as the period is closed for the specific ledger in the main calendar',newrec_.user_group);
      ELSE 
         Error_SYS.Record_General(lu_name_,'NOCLOSEIL: The period for user group :P1 can not be opened for the internal ledger :P2 as the period is closed for the specific ledger in the main calendar',newrec_.user_group, newrec_.ledger_id);          
      END IF;
   END IF; 
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Common___;



FUNCTION Check_All_Ils_Closed___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   user_group_          IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_         NUMBER; 
   
   CURSOR get_il_status IS 
      SELECT 1 
      FROM   user_group_period_tab
      WHERE  company             = company_
      AND    accounting_year     = accounting_year_
      AND    accounting_period   = accounting_period_
      AND    user_group          = user_group_
      AND    ledger_id           != '00'
      AND    period_status       = 'O';
BEGIN
   OPEN get_il_status;
   FETCH get_il_status INTO dummy_;
   IF get_il_status%FOUND THEN
      CLOSE get_il_status;
      RETURN 'FALSE';
   END IF;
   RETURN 'TRUE';
END Check_All_Ils_Closed___;


FUNCTION Check_All_Ils_Open___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   user_group_          IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_         NUMBER; 
   
   CURSOR get_il_status IS 
      SELECT 1 
      FROM   user_group_period_tab
      WHERE  company             = company_
      AND    accounting_year     = accounting_year_
      AND    accounting_period   = accounting_period_
      AND    user_group          = user_group_
      AND    ledger_id           != '00'
      AND    period_status       = 'C';
BEGIN
   OPEN get_il_status;
   FETCH get_il_status INTO dummy_;
   IF get_il_status%FOUND THEN
      CLOSE get_il_status;
      RETURN 'FALSE';
   END IF;
   RETURN 'TRUE';
END Check_All_Ils_Open___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Is_Period_Open_Date__ (
   is_open_          OUT VARCHAR2,
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_date_     IN DATE,
   user_group_       IN VARCHAR2,
   ledger_id_        IN VARCHAR2 DEFAULT '00' )
IS
   accounting_period_  NUMBER;
   dummy_              NUMBER;
BEGIN
   Accounting_Period_API.Get_Accounting_Year(dummy_,accounting_period_,company_,voucher_date_,user_group_);
   is_open_ := Is_Period_Open(company_,dummy_,accounting_period_,user_group_, ledger_id_);
END Is_Period_Open_Date__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Update_Period_Status_ (
   company_           IN VARCHAR2,
   period_status_     IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   ledger_id_         IN VARCHAR2)
IS 
BEGIN   
   UPDATE user_group_period_tab
      SET    period_status       = period_status_
      WHERE  company             = company_
      AND    accounting_year     = accounting_year_
      AND    accounting_period   = accounting_period_
      AND    ledger_id           = ledger_id_;
END Update_Period_Status_;


@UncheckedAccess
FUNCTION Is_Period_Open_ (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   user_group_          IN VARCHAR2,
   ledger_id_           IN VARCHAR2 DEFAULT '00') RETURN VARCHAR2
IS
   status_   VARCHAR2(6);
BEGIN
   IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      status_ := Is_Period_Open___(company_, accounting_year_, accounting_period_, user_group_, ledger_id_);
   ELSE
      status_ := 'NULL';
   END IF;
   RETURN status_ ;
END Is_Period_Open_;




-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Checkusergroup (
   exists_            OUT VARCHAR2,
   company_           IN  VARCHAR2,
   accounting_year_   IN  NUMBER,
   accounting_period_ IN  NUMBER,
   ledger_id_         IN  VARCHAR2 DEFAULT '00')
IS
   CURSOR check_user_group IS
      SELECT 'TRUE'
      FROM   USER_GROUP_PERIOD_TAB
      WHERE  company = company_
      AND  accounting_year  = accounting_year_
      AND  accounting_period = accounting_period_
      AND  ledger_id         = ledger_id_
      AND  rownum = 1;
BEGIN
   OPEN check_user_group;
   FETCH check_user_group INTO exists_;
   IF (check_user_group%NOTFOUND) THEN
      exists_ := 'FALSE';
   END IF;
   CLOSE check_user_group;
END Checkusergroup;


@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Check_If_Closed (
   closed_             OUT VARCHAR2,
   company_            IN  VARCHAR2,
   accounting_year_    IN  NUMBER,
   accounting_period_  IN  NUMBER,
   ledger_id_          IN  VARCHAR2 DEFAULT '00')
IS
   CURSOR Check_if_closed IS
      SELECT 'CLOSED'
      FROM   USER_GROUP_PERIOD_TAB
      WHERE  company           = company_
      AND    accounting_year   = accounting_year_
      AND    accounting_period = accounting_period_
      AND    ledger_id         = ledger_id_
      AND    period_status = 'C';
BEGIN
   OPEN Check_if_closed;
   FETCH Check_if_closed INTO closed_;
   IF (Check_if_closed%NOTFOUND) THEN
      closed_ := 'OPEN';
   END IF;
   CLOSE Check_if_closed;
END Check_If_Closed;


PROCEDURE Check_If_Closed (
   closed_         OUT VARCHAR2,
   company_        IN  VARCHAR2,
   period_         IN  NUMBER,
   ledger_id_      IN  VARCHAR2 DEFAULT '00')
IS

   accounting_year_     NUMBER;
   accounting_period_   NUMBER;

BEGIN
   Accounting_Period_API.Conv_Period( accounting_year_, accounting_period_, company_, period_ );
   Check_If_Closed( closed_, company_, accounting_year_, accounting_period_, ledger_id_ );
END Check_If_Closed;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_User_Group (
   company_           IN VARCHAR2,
   user_group_        IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   period_status_     IN VARCHAR2,
   ledger_id_         IN VARCHAR2 DEFAULT '00')
IS
   newrec_              user_group_period_tab%ROWTYPE;

BEGIN
   newrec_.company            := company_;
   newrec_.accounting_year    := accounting_year_;
   newrec_.accounting_period  := accounting_period_;
   newrec_.user_group         := user_group_;
   newrec_.ledger_id          := ledger_id_;
   newrec_.period_status      := period_status_;
   
   New___(newrec_);
END Insert_User_Group;


@UncheckedAccess
FUNCTION Check_Exist (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   user_group_        IN VARCHAR2,
   ledger_id_         IN VARCHAR2 DEFAULT '00') RETURN BOOLEAN
IS
BEGIN
   RETURN Check_Exist___ (company_,
                          accounting_year_,
                          accounting_period_,
                          user_group_,
                          ledger_id_);
END Check_Exist;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Period (
   accounting_year_   OUT NUMBER,
   accounting_period_ OUT NUMBER,
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   period_in_         IN  DATE,
   ledger_id_         IN  VARCHAR2 DEFAULT '00')
IS
   --
   year_        NUMBER;
   period_      NUMBER;

   CURSOR cs_acc_yr_pr IS
      SELECT  accounting_year, accounting_period
      FROM    USER_GROUP_PERIOD_TAB
      WHERE    company           = company_
      AND      user_group        = user_group_
      AND      accounting_year   = year_
      AND      accounting_period = period_
      AND      ledger_id         = ledger_id_;
BEGIN
   Accounting_Period_API.Get_Ordinary_Accounting_Year(year_, period_, company_, period_in_);
   OPEN cs_acc_yr_pr;
   FETCH cs_acc_yr_pr INTO  accounting_year_, accounting_period_;
   CLOSE cs_acc_yr_pr;
EXCEPTION
   WHEN no_data_found THEN
      Error_SYS.Record_General(lu_name_, 'NOGROUP: The user group :P1 is not connected to any period with the date :P2', user_group_, period_in_);
END Get_Period;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Accounting_Year (   
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   period_in_         IN  DATE,
   ledger_id_         IN  VARCHAR2 DEFAULT '00') RETURN NUMBER
IS
   accounting_year_    NUMBER;
   accounting_period_  NUMBER;   
BEGIN
   User_Group_Period_API.Get_Period(accounting_year_, accounting_period_, company_, user_group_, period_in_, ledger_id_);
   RETURN accounting_year_;   
END Get_Accounting_Year;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Accounting_Period (   
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   period_in_         IN  DATE,
   ledger_id_         IN  VARCHAR2 DEFAULT '00') RETURN NUMBER
IS
   accounting_year_    NUMBER;
   accounting_period_  NUMBER;   
BEGIN
   User_Group_Period_API.Get_Period(accounting_year_, accounting_period_, company_, user_group_, period_in_, ledger_id_);
   RETURN accounting_period_;   
END Get_Accounting_Period;


@UncheckedAccess
FUNCTION Is_Period_Open (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 DEFAULT '00') RETURN VARCHAR2
IS
   status_  VARCHAR2(6);
BEGIN
   IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      status_ := Is_Period_Open___(company_, accounting_year_, accounting_period_, user_group_, ledger_id_);
   ELSE
      status_ := 'NULL';
   END IF;
   RETURN status_ ;
END Is_Period_Open;




PROCEDURE Is_Period_Open (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 DEFAULT '00')
IS
BEGIN
   IF (Is_Period_Open(company_, accounting_year_, accounting_period_, user_group_, ledger_id_) = 'FALSE') THEN
      IF ( ledger_id_ NOT IN ('*', '00')) THEN
         Error_SYS.Record_General(lu_name_,'NOTOPENLEDPERIODGROUP: Period not open for user group :P1 for ledger ID :P2 in Company :P3.',user_group_, ledger_id_, company_);
      ELSE
         Error_SYS.Record_General(lu_name_,'NOTOPENCOMPERIODGROUP: Period not open for user group :P1 in Company :P2.',user_group_, company_);
      END IF;
   END IF;
END Is_Period_Open;


PROCEDURE Is_Period_Open_Date (
   is_open_            OUT VARCHAR2,
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_date_       IN DATE,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 DEFAULT '00')
IS
BEGIN
   Is_Period_Open_Date__( is_open_,
                          company_,
                          accounting_year_,
                          voucher_date_,
                          user_group_,
                          ledger_id_ );
END Is_Period_Open_Date;


PROCEDURE Is_Period_Open_Date (
   company_            IN VARCHAR2,
   voucher_date_       IN DATE,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 DEFAULT '00')
IS
   accounting_period_  NUMBER;
   accounting_year_    NUMBER;
BEGIN
   Accounting_Period_API.Get_Accounting_Year(accounting_year_, accounting_period_, company_, voucher_date_);
   User_Group_Period_API.Is_Period_Open(company_, accounting_year_, accounting_period_, user_group_, ledger_id_);
END Is_Period_Open_Date;


PROCEDURE Is_Period_Open_Date2 (
   is_open_            OUT VARCHAR2,
   company_            IN  VARCHAR2,
   voucher_date_       IN  DATE,
   user_group_         IN  VARCHAR2,
   ledger_id_          IN  VARCHAR2 DEFAULT '00')
IS
   accounting_period_  NUMBER;
   dummy_              NUMBER;
BEGIN
   Accounting_Period_API.Get_Ordinary_Accounting_Year(dummy_,accounting_period_,company_,voucher_date_);
   is_open_ := Is_Period_Open(company_,dummy_,accounting_period_,user_group_, ledger_id_);
END Is_Period_Open_Date2;



@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Period_Open_GL_IL_Others (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 DEFAULT '00') RETURN VARCHAR2
IS
   row_cnt_       NUMBER;
   results_       VARCHAR2(5);   
   
   CURSOR is_period_open_GL IS
      SELECT  1
      FROM    user_group_period_tab
      WHERE   company            = company_
      AND     accounting_year    = accounting_year_
      AND     accounting_period  = accounting_period_
      AND     user_group        != user_group_
      AND     period_status      = 'O'
      AND     ledger_id          = ledger_id_;
BEGIN
   OPEN is_period_open_GL;
   FETCH is_period_open_GL INTO row_cnt_;
   IF (is_period_open_GL%FOUND) THEN
      results_ := 'TRUE';
   ELSE
      results_ := 'FALSE';
   END IF;
   CLOSE is_period_open_GL;
   RETURN results_;
END Is_Period_Open_GL_IL_Others;


PROCEDURE Get_And_Validate_Period (
   accounting_year_   OUT NUMBER,
   accounting_period_ OUT NUMBER,
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   actual_date_       IN  DATE,
   ledger_id_         IN  VARCHAR2 DEFAULT '00')
IS
   trunc_date_            DATE := TRUNC(actual_date_);
   user_grp_per_status_   VARCHAR2(1); -- status for UserGroupPeriod Open or Closed
   acc_period_status_     VARCHAR2(1); -- status for AccountingPeriod Open or Closed
   data_found_            BOOLEAN;     -- Join failed, user group not connected to period
   ledger_id_value_       user_group_period_tab.ledger_id%TYPE;
   period_type_           VARCHAR2(10) := 'ORDINARY';
   user_grp_per_status_2_ VARCHAR2(1);
   acc_period_status_2_   VARCHAR2(1);   
   
   CURSOR get_data IS
      SELECT ugp.accounting_year,
             ugp.accounting_period,
             ugp.period_status,
             al.period_status,
             ap.year_end_period
      FROM   user_group_period_tab ugp,
             accounting_period_tab ap,
             acc_period_ledger_info_tab al
      WHERE  ugp.company           = ap.company
      AND    ugp.accounting_year   = ap.accounting_year
      AND    ugp.accounting_period = ap.accounting_period
      AND    ugp.company           = al.company
      AND    ugp.accounting_year   = al.accounting_year
      AND    ugp.accounting_period = al.accounting_period
      AND    ugp.ledger_id         = al.ledger_id
      AND    ugp.user_group        = user_group_
      AND    ugp.ledger_id         = ledger_id_value_
      AND    trunc_date_          >= ap.date_from
      AND    trunc_date_          <= ap.date_until
      AND    ap.company            = company_;

   CURSOR get_year_close_period IS
      SELECT ugp.accounting_year, ugp.accounting_period, ugp.period_status, al.period_status
      FROM   user_group_period_tab ugp,
             accounting_period_tab ap,
             acc_period_ledger_info_tab al
      WHERE  ugp.company           = ap.company
      AND    ugp.accounting_year   = ap.accounting_year
      AND    ugp.accounting_period = ap.accounting_period
      AND    ugp.company           = al.company
      AND    ugp.accounting_year   = al.accounting_year
      AND    ugp.accounting_period = al.accounting_period
      AND    ugp.ledger_id         = al.ledger_id
      AND    ugp.user_group        = user_group_
      AND    ugp.ledger_id         = ledger_id_value_
      AND    trunc_date_          >= ap.date_from
      AND    trunc_date_          <= ap.date_until
      AND    ap.company            = company_
      AND    ap.year_end_period    = 'YEARCLOSE'
      AND    al.period_status      = 'O';
BEGIN
   IF (ledger_id_ = '*') THEN
      ledger_id_value_ := '00';
   ELSE
      ledger_id_value_ := ledger_id_;
   END IF;
   
   OPEN get_data;
   FETCH get_data INTO accounting_year_,
                accounting_period_,
                user_grp_per_status_,
                acc_period_status_,
                period_type_;
   data_found_ := get_data%FOUND;
   CLOSE get_data;

   IF ((period_type_ = 'YEARCLOSE') AND ( user_grp_per_status_ != 'O' OR acc_period_status_ != 'O')) THEN
      OPEN get_year_close_period;
      FETCH get_year_close_period INTO accounting_year_, accounting_period_, user_grp_per_status_2_, acc_period_status_2_;
      IF get_year_close_period%FOUND THEN
         user_grp_per_status_ := user_grp_per_status_2_;
         acc_period_status_   := acc_period_status_2_;
      END IF;
      CLOSE get_year_close_period;
   END IF;

   IF (user_grp_per_status_ != 'O') THEN
      Error_SYS.Record_General(lu_name_,'USRGRPPER: Period :P1 is not open for user group :P2 in Company :P3', accounting_year_||' - '||accounting_period_, user_group_, company_);
   END IF;
   IF (acc_period_status_ != 'O') THEN
      ERROR_SYS.Record_General(lu_name_,'PERCLOSED: The period :P1 is closed in Company :P2', accounting_period_ , company_);
   END IF;
   IF (NOT data_found_) THEN
      Error_SYS.Record_General(lu_name_, 'USRGRPNOTCON: The user group :P1 is not connected to any period with the date :P2 in Company :P3 ', user_group_, actual_date_, company_ );
   END IF;
END Get_And_Validate_Period;


PROCEDURE Get_Default_User_Group (
   company_            IN  VARCHAR2,
   accounting_year_    IN  NUMBER,
   accounting_period_  IN  NUMBER,
   user_id_            IN  VARCHAR2,
   user_group_         OUT VARCHAR2,
   ledger_id_          IN  VARCHAR2 DEFAULT '00')
IS
   user_groupm_            VARCHAR2(20) := NULL;
   exist_user_             VARCHAR2(6);
   CURSOR check_exist IS
      SELECT user_group
      FROM   user_group_period_tab
      WHERE  company           = company_
      AND    accounting_year   = accounting_year_
      AND    accounting_period = accounting_period_
      AND    ledger_id         = ledger_id_;
BEGIN
   user_groupm_ := User_Group_Member_Finance_API.Get_Default_Group (company_,
                                                                    user_id_);
   FOR temp_user IN check_exist LOOP
      exist_user_   := Is_Period_Open_GL_IL_Others (company_,
                                                      accounting_year_,
                                                      accounting_period_,
                                                      temp_user.user_group,
                                                      ledger_id_);
      IF (temp_user.user_group = user_groupm_ AND exist_user_ = 'FALSE') THEN
         user_group_ := user_groupm_;
      END IF;
   END LOOP;
 END Get_Default_User_Group;

 
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Add_User_Group (
   company_           IN VARCHAR2,
   attr_              IN OUT VARCHAR2 )
IS
   info_       VARCHAR2(2000);
   objid_      VARCHAR2(200);
   objversion_ VARCHAR2(200);
BEGIN
   New__(info_, objid_, objversion_, attr_, 'DO');
END Add_User_Group;


@UncheckedAccess
FUNCTION Is_Period_Open_GL_IL (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER,
   user_group_         IN VARCHAR2,
   ledger_id_          IN VARCHAR2 ) RETURN VARCHAR2
IS
   status_  VARCHAR2(6);
BEGIN
   IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      status_ := Is_Period_Open___(company_, accounting_year_, accounting_period_, user_group_,ledger_id_);
   ELSE
      status_ := 'NULL';
   END IF;
   RETURN status_ ;
END Is_Period_Open_GL_IL;


@UncheckedAccess
FUNCTION Get_Period_No_Validate (
   company_     IN VARCHAR2,
   user_group_  IN VARCHAR2,
   actual_date_ IN DATE,
   ledger_id_   IN VARCHAR2 DEFAULT '00') RETURN NUMBER
IS
   trunc_date_                 DATE := TRUNC(actual_date_);
   accounting_period_          accounting_period_tab.accounting_period%TYPE;

   CURSOR get_period IS
      SELECT ugp.accounting_period
      FROM   user_group_period_tab ugp,
             accounting_period_tab ap
      WHERE  ugp.company           = ap.company
      AND    ugp.accounting_year   = ap.accounting_year
      AND    ugp.accounting_period = ap.accounting_period
      AND    ugp.user_group        = user_group_
      AND    ugp.ledger_id         = ledger_id_
      AND    trunc_date_          >= ap.date_from
      AND    trunc_date_          <= ap.date_until
      AND    ap.company            = company_;
BEGIN
   OPEN get_period;
   FETCH get_period INTO accounting_period_;
   CLOSE get_period;

   RETURN accounting_period_;
END Get_Period_No_Validate;


PROCEDURE Open_Period (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2 )
IS
   info_              VARCHAR2(2000);
   attr_              VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('PERIOD_STATUS_DB', 'O', attr_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
END Open_Period;


PROCEDURE Close_Period (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2 )
IS
   info_           VARCHAR2(2000);
   attr_           VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_ );
   Client_SYS.Add_To_Attr('PERIOD_STATUS_DB', 'C', attr_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
END Close_Period;


PROCEDURE Next_Open_Period (
   company_             IN     VARCHAR2,
   accounting_year_     IN OUT NUMBER,
   accounting_period_   IN OUT NUMBER,
   user_group_          IN     VARCHAR2,
   ledger_id_           IN     VARCHAR2 DEFAULT '00')
IS
   CURSOR next_period_open IS
      SELECT accounting_year, accounting_period 
      FROM   user_group_period_tab
      WHERE  company           = company_
        AND  user_group        = user_group_
        AND  ledger_id         = ledger_id_
        AND  period_status     = 'O'
        AND  ((accounting_year *100) + accounting_period) > ((accounting_year_ * 100)+ accounting_period_)
      ORDER BY accounting_year, accounting_period ;
BEGIN
   OPEN  next_period_open;
   FETCH next_period_open INTO accounting_year_, accounting_period_;   
   CLOSE next_period_open;
END Next_Open_Period;


@UncheckedAccess
PROCEDURE Get_Year_And_Period (
   accounting_year_   OUT NUMBER,
   accounting_period_ OUT NUMBER,
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   actual_date_       IN  DATE,
   ledger_id_         IN  VARCHAR2 DEFAULT '00')
IS
   trunc_date_            DATE := TRUNC(actual_date_);
   
   CURSOR get_year_period IS
      SELECT ugp.accounting_year,
             ugp.accounting_period
      FROM   user_group_period_tab ugp,
             accounting_period_tab ap
      WHERE  ugp.company           = ap.company
      AND    ugp.accounting_year   = ap.accounting_year
      AND    ugp.accounting_period = ap.accounting_period
      AND    ugp.user_group        = user_group_
      AND    ugp.ledger_id         = ledger_id_
      AND    trunc_date_          >= ap.date_from
      AND    trunc_date_          <= ap.date_until
      AND    ap.company            = company_;
BEGIN
   OPEN get_year_period;
   FETCH get_year_period INTO accounting_year_,accounting_period_;
   CLOSE get_year_period;
END Get_Year_And_Period;


PROCEDURE Create_User_Groups_Per_Year (
   company_                     IN VARCHAR2,
   source_year_                 IN NUMBER,
   accounting_year_             IN NUMBER,
   acc_period_create_method_db_ IN VARCHAR2)
IS
   newrec_  user_group_period_tab%ROWTYPE;
   
   CURSOR get_user_groups IS
      SELECT * 
      FROM   user_group_period_tab
      WHERE  company          = company_
      AND    accounting_year  = source_year_;
BEGIN
   FOR rec_ IN get_user_groups LOOP
      newrec_.company             := company_;
      newrec_.accounting_year     := accounting_year_;
      newrec_.accounting_period   := rec_.accounting_period;
      newrec_.user_group          := rec_.user_group;
      newrec_.ledger_id           := rec_.ledger_id;

      IF (acc_period_create_method_db_ LIKE 'CLOSED%') 
         OR (Accounting_Period_API.Get_Year_End_Period_Db(newrec_.company, newrec_.accounting_year, newrec_.accounting_period) = 'YEARCLOSE') THEN
         newrec_.period_status       := 'C';
      ELSE
         newrec_.period_status       := 'O';
      END IF;
      New___(newrec_);
   END LOOP;
END Create_User_Groups_Per_Year;


PROCEDURE Is_Period_Open_GL_IL(
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER, 
   user_group_        IN VARCHAR2,
   ledger_id_         IN VARCHAR2 )
IS
BEGIN
   IF (Is_Period_Open_GL_IL(company_, accounting_year_, accounting_period_, user_group_, ledger_id_) = 'FALSE') THEN
      Error_SYS.Record_General(lu_name_,'NOTOPENPERIODGROUP: Period not open for user group :P1', user_group_);
   END IF;
END Is_Period_Open_GL_IL;


@UncheckedAccess
FUNCTION Get_Ledger_Description(
   company_       IN VARCHAR2, 
   ledger_id_     IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN   
   RETURN All_Ledger_API.Get_Description(company_, ledger_id_);   
END Get_Ledger_Description;
   

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Insert_User_Group_All_Ledger (
   company_           IN VARCHAR2,
   user_group_        IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   period_status_     IN VARCHAR2)
IS
   newrec_              user_group_period_tab%ROWTYPE;
   CURSOR get_ledgers IS
      SELECT ledger_id
      FROM   all_ledger_tab
      WHERE  company = company_
      AND    ledger_id != '*'
      AND    ledger_id NOT IN (SELECT ledger_id 
                               FROM   user_group_period_tab
                               WHERE  company           = company_
                               AND    user_group        = user_group_
                               AND    accounting_year   = accounting_year_
                               AND    accounting_period = accounting_period_);
BEGIN
   FOR rec_ IN get_ledgers LOOP 
      newrec_.company            := company_;
      newrec_.accounting_year    := accounting_year_;
      newrec_.accounting_period  := accounting_period_;
      newrec_.user_group         := user_group_;
      newrec_.ledger_id          := rec_.ledger_id;
      newrec_.period_status      := period_status_;

      New___(newrec_);
   END LOOP;
END Insert_User_Group_All_Ledger;


FUNCTION Get_User_Grp_Period_Type (
   company_    VARCHAR2, 
   user_group_ VARCHAR2) RETURN VARCHAR2
IS
   CURSOR get_period_type IS
      SELECT ap.year_end_period
      FROM   user_group_period_tab ugp,
             accounting_period_tab ap
      WHERE  ugp.company           = ap.company
      AND    ugp.accounting_year   = ap.accounting_year
      AND    ugp.accounting_period = ap.accounting_period
      AND    ugp.user_group        = user_group_
      AND    ap.company = company_;
      
   acounting_period_type_ VARCHAR2(20);
BEGIN
   OPEN get_period_type;
   FETCH get_period_type INTO acounting_period_type_;
   CLOSE get_period_type;
   RETURN acounting_period_type_;
END Get_User_Grp_Period_Type;

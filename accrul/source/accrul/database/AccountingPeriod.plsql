-----------------------------------------------------------------------------
--
--  Logical unit: AccountingPeriod
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960412  jela     Base Table to Logical Unit Generator 1.0A
--  960531  jela     Added call to User_Group_Period_API in Unpack_Check_Update__
--                   to close periods there if Accounting Period is closed.
--  970326  AnDj     Added Check_Valid_Range__
--  970326  AnDj     Fixed Support 660, Deleted duplicate NOYEAR =>
--                   NOYEAR1 and NOYEAR2
--  970707  SLKO     Converted to Foundation1 1.2.2d
--  970715  PICZ     Column CONSOLIDATED added
--  970715  PICZ     Added Get_Consolidation_Info function
--  970721  PICZ     Added functions: Set_Consolidated_Flag, Clear_Consolidated_Flag,
--                   Period_Valid_For_Consolidation
--  970812  JoTh     Bug # 97-0039 to_date() added to where clause in procedure
--                   Get_Accounting_Year.
--  970926  PICZ     Fixed bug in Insert__: consolidated flag was inserted without
--                   call to Encode method
--  980122  SLKO     Converted to Foundation1 2.0.0
--  980203  MALR     Update of Default Data, added procedure ModifyDefDataAccper__.
--  980212  MALR     Changed procedure ModifyDefDataAccper__, UserGroup is also a parameter.
--  980308  MiJo     Bug #3439, Added new procedures, Get_Max_Period and Get_Min_Period.
--  980316  PiCz     Bug #1391 - removed coma (,) from error message CHG_STATUS -
--                   it was not possible to show whole error message
--  980317  PiCz     Bug #1308 - changed date's validation
--  980331  PiCz     Trunctaing date in Get_Accounting_Period
--  980625  Kanchi   Added View5 to overcome the bug # 4905
--  980921  Bren     Master Slave Connection
--                   Added Send_Acc_Period_Info___, Send_Acc_Period_Info_
--                   Send_Acc_Period_Info_Modify___, Send_Acc_Period_Info.
--  981030  Mang     Added View6 and View7.
--  990217  ANDJ     Bug # 9124 fixed.
--  990408  JPS      Added a Cursor in Periodexist.
--  990419  JPS      Performed Template Changes.(Foundation 2.2.1)
--  991026  Dhar     Added Procedure Year_Exist
--  000120  Dhar     Added Procedure Get_Previous_Period
--  000103  Uma      Made the field Description Mandatory in ACCOUNTING_PERIOD
--  000310  Bren     Added VIEW ACCOUNTING_PERIOD_DEF for Voucher Type Wizard.
--  000316  Upul     Add procedure Check_Year_End_Period & Check_Previous_Year_End_Period
--  000901  SaCh     Added procedure Get_Periods_Sans_Year_End.
--  000908  HiMu     Added General_SYS.Init_Method.
--  001004  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  OVJOSE   For new Create Company concept added new view accounting_period_ect and accounting_period_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010221  ToOs     Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010427  LiSv     For new Create Company concept remarked view ACCOUNTING_PERIOD_DEF
--  010509  JeGu     Bug #21705 Implementation New Dummyinterface
--                   Changed Insert__ RETURNING rowid INTO objid_
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010626  ASSALK   added code in Get_Consolidation_Info to check for the Opening balance of the year.
--  010731  Brwelk   Added Get_YearPer_For_YearEnd_User, Get_Acc_Year_Period_User_Group and view9.
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010905  JeGu     Simplified functions: Set_Consolidated_Flag, Clear_Consolidated_Flag,
--  010918  Brwelk   Changed Get_Period_Info___. Added a ORDER BY to the cursor.
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020213  Mnisse   IID 21003, Added company translation support for description
--  020318  Shsalk   Call Id 79709 Corrected. Changed the Get_Year_End_Period.
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020611  ovjose   Bug 29600 Corrected. Removed function call in ACCOUNTING_PERIOD_PCT.
--  020718  SUMALK   Bug 31711 Fixed.
--  021001  Nimalk   Removed usage of the view Company_Finance_Auth in ACCOUNTING_PERIOD,ACCOUNTING_PERIOD_FULL_LOV,
--                   ACCOUNTING_YEAR_FULL_LOV,ACCOUNTING_PERIOD_LOV,ACCOUNTING_YEAR_LOV,ACCOUNTING_PERIOD_TEMPview
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021101  KuPelk   IID ESFI110N Year End Accounting.Added ned IID as PeriodType(Year_End_Period).
--  021104  Dagalk   ITFI103N -Internal ledger Year-end Add new field period_status_int .
--  021106  KuPelk   IID ESFI110N Year End Accounting.Added new methods as Check_Year_Opening_Period,
--                   Get_Opening_Period and Get_Year_End_Period_Data and Check_Opening_Date.
--                   also add  period_status_int to company creation views and import, copy, export procedures
--  021121  Chprlk   Modified the wrong where clause in VIEW9 ACCOUNTING_YEAR_END_PERIOD
--  021121  Chprlk   Added a default parameter period status to Get_Year_End_Period
--  011203  Chprlk   Corrected comparisons for year_end_period
--  021206  Chprlk   Added new method Get_All_Ordinary_Period for Call 92000
--  021212  KuPelk   IID ESFI110N Changed Get_Year_End_Period method.
--  030331  Risrlk   IID RDFI140NF. Changed Db_Values. Year_end_period(Period_Type_API)
--  030403  Risrlk   IID RDFI140NF. Increased the Year_end_period column width of the views.
--  030417  Risrlk   Modified Get_Year_End_Period_Data__ method.
--  030731  prdilk   SP4 Merge.
--  031017  LoKrLK   LCS Patch Merge (38565). Modified Get_Period_Info___.
--  031017  Thsrlk   LCS Patch Merge (38745).
--  031020  Brwelk   Init_Method Corrections
--  040323  Gepelk   2004 SP1 Merge
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  041014  WAPELK   Merged Bug 45325.
--  041213  UPUNLK   Added private method Get_Year_Period__ to use in ACC_YEAR_PERIOD_PUB.
--  050105  UPUNLK   Added ACC_YEAR_PERIOD_PUB view to apy which is removed from apy.
--  050420  ISWALK   removed General_SYS.Init_Method() from Get_Year_Period__
--  050704  INGULK   FIAD377 Added a method Get_Next_Allowed_Periiod
--  050712  INGULK   FIAD377 Added methods Get_Previous_Allowed_Period & Is_Period_Allowed
--  051102  Nsillk   LCS Merge(53694).
--  051104  ShFrlk   LCS Bug 53325, Merged.
--  051107  Nsillk   LCS Merge(53901).
--  060210  Ingulk   Call Id 130916 - added a method Is_Year_Close().
--  060227  Gadalk   Call Id 132835 - Unpack_Check_Update___(), clossing year end periods
--  060320  Gadalk   Call Id 132835 - Changes in Check_Period_Closed()
--  060615  Kagalk   FIPL603A - Synchronize accounting periods and periods in journals.
--  070321  Shsalk   LCS Merge 60218 corrected. Modified procedure Get_Prev_Ordinary_Period.
--  070510  Prdilk   B141476, Modified Unpack_Check_Update___ to support translations. 
--  070629  Shsalk   B146296, corrected company template problem.
--  070910  Shwilk   LCS merge 66981, Modified method Check_Previous_Year_End_Period
--  071205  Jeguse   Bug 69803 Corrected.
--  080116  Sjaylk   Bug 70457, Changed Get_Prev_Ordinary_Period
--  080409  Nirplk   Bug 71549, Added new columns. Report_From_Date, report_until_date with validations
--  080721  Thpelk   Bug 75655, Modified the validaion in Unpack_Check_Update___().
--  081031  Makrlk   Bug 77389, Added new methods Get_Next_Allowing_Period() and Get_Number_Of_Allowed_Periods().
--  081208  Thpelk   Bug 77503, Corrected in Get_Next_Vou_Period() and Get_Next_Allowed_Period().
--  090219  reanpl   Bug 82373, SKwP Ceritificate - Final Closing of Period (SKwP-2)
--  090311  witopl   Bug 82373, SKwP Ceritificate - Final Closing of Period (SKwP-2)
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statements for VIEW10.
--  090717  ErFelk   Bug 83174, Replaced INS_00 with BALCONFLAG in Unpack_Check_Insert___, replaced UPDATE_00 with BALCONFLAG
--  090717           in Unpack_Check_Update___, replaced YEARENDPERIOD3 with YEARENDPERIOD5 in Check_Previous_Year_End_Period
--  090717           and replaced PER_IN_WAI1 with PER_HOLD_WAI in Check_Close_Period.  
--  090810  LaPrlk   Bug 79846, Removed the precisions defined for NUMBER type variables.
--  091120  Nirplk   Bug 87119, Corrected, modified the error msg PERIODCONSOLIDATED to support IEE client
--  091221  HimRlk   Reverse engineering correction, Removed method call to User_Group_Period_API.Period_Delete_Allowed in
--  091221           method Check_Delete_Record__.
--  100209  Nsillk   EAFH-1510 , Used Defined Calendar Modifications
--  100324  Nsillk   EAFH-2578 , Fetched the correct year opening description
--  100420  Nsillk   Modifications done to support update Company
--  100423  SaFalk   Modified REF for year_end_period in ACCOUNTING_PERIOD and ACCOUNTING_PERIOD_PCT.
--  100427  AsHelk   Bug 84970, Corrected. Ifs Assert Safe Annotation.
--  100716  Umdolk  EANE-2936, Reverse engineering - Corrected references and keys in base view.
--  101015  AjPelk   Bug 93466  Corrected. Added a method
--  110415  Sacalk   EASTONE-15173, Modified the view ACCOUNTING_PERIOD
--  110711  Sacalk   FIDEAGLE-300 , Merged LCS bug 96815, Added a new method Get_Next_Any_Period.
--  110712  Mohrlk   FIDEAGLE-1062, Merged bug 97478, Corrected in Get_Acc_Year_Period_User_Group().
--  111018  Shdilk   SFI-135, Conditional compilation.
--  111206  JuKoDE   SFI-1088, Added new function Get_Ordinary_Accounting_year() and Get_Ordinary_Accounting_period()
--  120119  Samblk   SFI-1499, merged bug 100546, Corrected, Moved some validations from Unpack_Check_Update___ to  Do_Final_Check().
--  120829  JuKoDE   EDEL-1532, Removed General_SYS in Get_Ordinary_Accounting_Year() and set PRAGMA in package specification.
--  120923  Chhulk   Bug 104778, Modified Import___().
--  120925  Chwilk   Bug 105088, Modified Unpack_Check_Update___.
--  121009  Machlk   Bug 105642, Removed the unneeded expression from where clause.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk      PEPA-183, Removed global variables
--  130808  NIANLK   CAHOOK-1280: Added new checks to validate Account Year and period lenghs
--  130514  Janblk   DANU-1024, Added a parameter to Get_Opening_Period() to exclude checking for period_status 
--  130913  Umdolk  DANU-1918, Added public view ACC_YEAR_PERIOD_SUMMARY_PUB.
--  130917  Umdolk  DANU-1934, Modified ACC_YEAR_PERIOD_SUMMARY_PUB to correct the fresh installation error.
--  130816  Clstlk  Bug 111218, Fixed General_SYS.Init_Method issue.
--  130821  SJayLK   RUB-1040, Added BI Metadata specific funtions to support BA Function based parameters
--  130902  MAWELK  Bug 111219 Fixed. 
--  130902  THPELK  Bug 112154, Corrected QA script cleanup - Financials  Type Cursor usage in procedure / function.
--  131118  Umdolk  PBFI-899, Refactoring
--  150421  THPELK  Bug 122078, Corrected in Check_Update___().
--  151117  Bhhilk  STRFI-12, Removed annotation from public get methords.
--  151118  Bhhilk  STRFI-39, Modified ConsolidatedYesNo enumeration to FinanceYesNo.
--  151118  chiblk   STRFI-607 replace the enumeration in Acc_per_status with Acc_Year_Per_Status.
--  151124  THPELK  STRFI-669, Code cleanup.
--  160330  SAVMLK   STRFI-1626, Bug 128136 merged.
--  160816  MAAYLK  STRFI-3406 (Bug 130949), modified Get_Voucher_Period() to fetch period from gen_led_arch_voucher_tab
--  161006  KGAMLK  FINLIFE-356 Added method Get_Until_Date_For_Year_Period
--  170123  SAVMLK  STRFI-4436, Bug 133609 merged.
--  180103  Nudilk  Bug 146098, Corrected in Create_Accounting_Periods.
--  200401  Chwtlk  Bug 153141, Modified in Copy___. Having NVL parameter as 1 gives erroneous results. It should be a non accounting period value.
--  200424  Savmlk  Bug 153603, Added new overloaded method Get_Previous_Period.
--  200902  Jadulk  FISPRING20-6694 , Removed conacc related logic.
--  210301  Jadulk  FISPRING20-9293, Modified Copy___, to support scenarios with user defined accounting period info that is not inline with the source company.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE PeriodTab IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE Year_Period_Rec IS RECORD (
   Accounting_Year   PLS_INTEGER,
   Accounting_Period PLS_INTEGER);

TYPE Year_Period_Tab IS TABLE OF Year_Period_Rec INDEX BY BINARY_INTEGER;

TYPE Micro_Cache_Year_Per_Type IS TABLE OF Year_Period_Rec INDEX BY VARCHAR2(1000);

micro_cache_year_per_tab_   Micro_Cache_Year_Per_Type;

micro_cache_year_per_value_ Year_Period_Rec;

micro_cache_year_per_time_  NUMBER := 0;

micro_cache_year_per_user_  VARCHAR2(30);

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


PROCEDURE Check_Date_Change_Allowed___ (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER )
IS   
   change_not_allowed_ EXCEPTION;
BEGIN
   -- Check Hold table 
   IF (Voucher_API.Exist_Vou_Per_Period(company_,
                                        accounting_year_,
                                        accounting_period_ ) = 'TRUE') THEN
      RAISE change_not_allowed_;
   END IF;
   IF (Rpd_Company_Period_API.Check_Exist(company_, accounting_year_, accounting_period_)) THEN
      Error_SYS.Record_General(lu_name_, 'CHNOTALLWED2: Reporting Period Definitions Exists for Year and Period - Valid From, Valid Until Cannot be modified.');              
   END IF;   
   -- Hold Table is clear, Check Genled
   $IF Component_Genled_SYS.INSTALLED $THEN      
      IF (Gen_Led_Voucher_API.Exist_Vou_Per_Period(company_,
                                                   accounting_year_,
                                                   accounting_period_ ) = 'TRUE') THEN
         RAISE change_not_allowed_;
      END IF;       
   $END  
   
   $IF Component_Intled_SYS.INSTALLED $THEN      
      IF (Internal_Hold_Voucher_API.Exist_Vou_Per_Period(company_,
                                                         accounting_year_,
                                                         accounting_period_ ) = 'TRUE') THEN
         RAISE change_not_allowed_;
      END IF; 
      
      IF (Internal_Voucher_API.Exist_Vou_Per_Period(company_,
                                                    accounting_year_,
                                                    accounting_period_ )= 'TRUE') THEN
         RAISE change_not_allowed_;
      END IF; 
   $END   
EXCEPTION 
   WHEN change_not_allowed_ THEN
      Error_SYS.Record_General(lu_name_, 'CHNOTALLWED: You are not allowed to modify valid from and valid until dates since transactions exist for the period.' );
END Check_Date_Change_Allowed___;


@UncheckedAccess
-- Get_Period_For_Desc___
--   Function try to find month number based on the name of the month (in english)
FUNCTION Get_Period_For_Desc___(
   month_desc_   IN VARCHAR2) RETURN NUMBER
IS
   upper_month_desc_ VARCHAR2(200) := UPPER(month_desc_);
   period_num_       NUMBER;
BEGIN
   IF upper_month_desc_ LIKE '%JANUARY%' THEN
      period_num_ := 1; 
   ELSIF upper_month_desc_ = '%FEBRUARY%' THEN      
      period_num_ := 2; 
   ELSIF upper_month_desc_ = '%MARCH%' THEN      
      period_num_ := 3; 
   ELSIF upper_month_desc_ = '%APRIL%' THEN      
      period_num_ := 4; 
   ELSIF upper_month_desc_ = '%MAY%' THEN      
      period_num_ := 5; 
   ELSIF upper_month_desc_ = '%JUNE%' THEN      
      period_num_ := 6; 
   ELSIF upper_month_desc_ = '%JULY%' THEN      
      period_num_ := 7; 
   ELSIF upper_month_desc_ = '%AUGUST%' THEN      
      period_num_ := 8; 
   ELSIF upper_month_desc_ = '%SEPTEMBER%' THEN      
      period_num_ := 9; 
   ELSIF upper_month_desc_ = '%OCTOBER%' THEN      
      period_num_ := 10; 
   ELSIF upper_month_desc_ = '%NOVEMBER%' THEN      
      period_num_ := 11; 
   ELSIF upper_month_desc_ = '%DECEMBER%' THEN      
      period_num_ := 12; 
   END IF;
   RETURN period_num_;
END Get_Period_For_Desc___;

@UncheckedAccess
-- Get_Month_Desc___
--   Function try to return a month name (or year opening period)in the current language
FUNCTION Get_Month_Desc___(
   month_         IN NUMBER) RETURN VARCHAR2
IS   
   desc_ VARCHAR2(200);
BEGIN
   IF month_ = 0 THEN      
      desc_ := Language_SYS.Translate_Constant(lu_name_, 'YEAROPENPERIOD: Year Opening Period');                  
   ELSIF month_ = 1 THEN      
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_JANUARY);
   ELSIF month_ = 2 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_FEBRUARY);
   ELSIF month_ = 3 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_MARCH);
   ELSIF month_ = 4 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_APRIL);
   ELSIF month_ = 5 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_MAY);
   ELSIF month_ = 6 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_JUNE);
   ELSIF month_ = 7 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_JULY);
   ELSIF month_ = 8 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_AUGUST);
   ELSIF month_ = 9 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_SEPTEMBER);
   ELSIF month_ = 10 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_OCTOBER);
   ELSIF month_ = 11 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_NOVEMBER);
   ELSIF month_ = 12 THEN            
      desc_ := Month_Name_Of_Year_API.Decode(Month_Name_Of_Year_API.DB_DECEMBER);
   END IF;
   RETURN desc_;
END Get_Month_Desc___;


FUNCTION Get_Next_From_Attr___ (
   attr_             IN     VARCHAR2,
   ptr_              IN OUT NOCOPY NUMBER,
   value_            IN OUT NOCOPY VARCHAR2,
   record_separator_ IN     VARCHAR2 ) RETURN BOOLEAN
IS
   from_  NUMBER;
   to_    NUMBER;
   index_ NUMBER;
BEGIN
   from_ := NVL(ptr_, 1);
   to_   := INSTR(attr_, record_separator_, from_);
   IF (to_ > 0) THEN
      index_ := INSTR(attr_, record_separator_, from_);
      value_ := SUBSTR(attr_, from_, index_-from_);
      ptr_   := to_+1;
      RETURN(TRUE);
   ELSE
      RETURN(FALSE);
   END IF;
END Get_Next_From_Attr___;

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_             VARCHAR2(32000);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
   newrec_           ACCOUNTING_PERIOD_TAB%ROWTYPE;
   empty_rec_        ACCOUNTING_PERIOD_TAB%ROWTYPE;
   msg_              VARCHAR2(2000);
   i_                NUMBER := 0;
   update_by_key_    BOOLEAN;
   any_rows_         BOOLEAN := FALSE;
   start_month_      NUMBER;
   month_            NUMBER;
   period_type_      VARCHAR2(20);
   cal_year_         NUMBER;   
   from_date_        DATE;
   set_off_val_      NUMBER;   
   indrec_           Indicator_Rec;
   last_year_        NUMBER;
   templ_year_       NUMBER;
   templ_month_      NUMBER;
   lang_codes_       VARCHAR2(200);
   temp_desc_        VARCHAR2(200);
   temp_lang_code_   VARCHAR2(5);
   text_separator_   VARCHAR2(1) := Client_SYS.text_separator_;
   value_            VARCHAR2(2000);
   ptr_              NUMBER := 1;   
   init_lang_code_   VARCHAR2(5) := Fnd_Session_API.Get_Language;

   -- NOTE: added D3 and D4. STD template will not have D3 and D4. However if a 
   --       user defined template contains report from date and report until date 
   --       it should get imported using D3 and D4. Therefore D3 and D4 columns were added.
   --       Added N3 and N4. Standard templates will not have these. These are used for
   --       companies with user defined calendar option and templates created by such companies
   CURSOR get_data IS
      SELECT C1, C2, C4, N1, N2, N3, N4, D1, D2, D3, D4
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM   accounting_period_tab dest
                         WHERE  dest.company = crecomp_rec_.company
                         AND    dest.accounting_year = src.N1
                         AND    dest.accounting_period = src.N2)
      ORDER BY N1, N2;

   -- Find what month is the first period for the template, to get correct description when using user defined calendar   
   -- Also the last year of the template to know when we cannot fetch any more translations from the template and need to generate
   -- translations instead.
   CURSOR get_from_date ( template_id_ VARCHAR2, component_ VARCHAR2, lu_ VARCHAR2 )IS
      SELECT t.d1, t.n1
      FROM   create_company_template_pub t
      WHERE  t.template_id = template_id_
      AND    t.component   = component_
      AND    t.lu          = lu_
      AND    t.n2          = 1
      ORDER BY t.n1 desc;      

BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);

   IF (update_by_key_) THEN
      IF (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE') THEN
         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-25,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN               
               newrec_ := empty_rec_;

               newrec_.company              := crecomp_rec_.company;
               newrec_.accounting_year      := rec_.n1;
               newrec_.accounting_period    := rec_.n2;
               newrec_.description          := rec_.c1;
               newrec_.year_end_period      := rec_.c2;               
               newrec_.date_from            := rec_.d1;
               newrec_.date_until           := rec_.d2;
               newrec_.report_from_date     := rec_.d3;
               newrec_.report_until_date    := rec_.d4;
               newrec_.cal_year             := rec_.n3;
               newrec_.cal_month            := rec_.n4;
               Client_SYS.Clear_Attr(attr_);
               indrec_ := Get_Indicator_Rec___(newrec_);
               Check_Insert___(newrec_, indrec_, attr_);
               Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
               Insert___(objid_, objversion_, newrec_, attr_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
            END;
         END LOOP;
      END IF;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');
         END IF;
      END IF;
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            start_month_ := crecomp_rec_.cal_start_month;
            lang_codes_ := crecomp_rec_.languages;
            OPEN get_from_date (crecomp_rec_.template_id, 'ACCRUL', 'AccountingPeriod') ;
            FETCH get_from_date INTO from_date_, last_year_;
            CLOSE get_from_date;            
            set_off_val_ := NVL(EXTRACT(MONTH FROM from_date_), 1);
            FOR year_ IN 0..crecomp_rec_.number_of_years-1 LOOP               
               i_ := i_ + 1;
               month_ := start_month_;
               cal_year_ := crecomp_rec_.cal_start_year + year_;
               FOR period_ IN 0..12 LOOP
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  SAVEPOINT make_company_insert;
                  BEGIN
                     IF (month_ = 13) THEN
                        month_ := 1;
                        cal_year_ := crecomp_rec_.cal_start_year + year_ + 1;
                     END IF;
                     IF (period_ = 0) THEN
                        period_type_ := 'YEAROPEN';
                     ELSE
                        period_type_ := 'ORDINARY';
                     END IF;
                     newrec_.company              := crecomp_rec_.company;
                     newrec_.accounting_year      := crecomp_rec_.acc_year + year_;
                     newrec_.accounting_period    := period_;
                     newrec_.year_end_period      := period_type_;                     
                     newrec_.date_from            := Get_First_Day_Month___(month_, cal_year_);
                     IF (period_ = 0) THEN
                        newrec_.date_until := newrec_.date_from;
                     ELSE
                        newrec_.date_until  := LAST_DAY(newrec_.date_from);
                     END IF;
                     newrec_.report_from_date     := NULL;
                     newrec_.report_until_date    := NULL;
                     newrec_.cal_year             := cal_year_;
                     newrec_.cal_month            := month_;
                     IF (period_ = 0) THEN
                        newrec_.cal_month := 0;
                        newrec_.cal_year  := newrec_.accounting_year;
                     END IF;
                     newrec_.description  := Get_Period_Desc(period_, 
                                                               newrec_.cal_year,
                                                               newrec_.cal_month);
                     Client_SYS.Clear_Attr(attr_);
                     indrec_ := Get_Indicator_Rec___(newrec_);
                     Check_Insert___(newrec_, indrec_, attr_);
                     Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
                     Insert___(objid_, objversion_, newrec_, attr_);
                     -- if more years are generated than it exist translations for in the template then generate descriptions based on Year and 
                     -- enumeration of the months.
                     IF (newrec_.cal_year > last_year_) THEN                        
                        ptr_ := 1;
                        WHILE Get_Next_From_Attr___(lang_codes_, ptr_, value_, text_separator_) LOOP
                           temp_lang_code_ := value_;
                           Fnd_Session_API.Set_Language(temp_lang_code_);                                                            
                           temp_desc_ := Get_Month_Desc___(newrec_.cal_month) || ' ' || newrec_.cal_year;                              
                           Enterp_Comp_Connect_V170_API.Insert_Company_Translation(crecomp_rec_.company,
                                                                                   'ACCRUL',
                                                                                   lu_name_,
                                                                                   newrec_.accounting_year || '^' || newrec_.accounting_period,
                                                                                   temp_lang_code_,
                                                                                   temp_desc_);                           
                        END LOOP;
                     ELSE
                        IF (set_off_val_ != 1) THEN                           
                           templ_year_    := Get_Set_Off_Year___(newrec_.cal_year, newrec_.cal_month, (set_off_val_ - 1 ));
                           templ_month_   := Get_Set_Off_Month___(newrec_.cal_month, (set_off_val_ - 1 ));                           
                        ELSE
                           templ_year_    := newrec_.accounting_year;
                           templ_month_   := newrec_.accounting_period;
                        END IF;
                        ptr_ := 1;
                        WHILE Get_Next_From_Attr___(lang_codes_, ptr_, value_, text_separator_) LOOP
                           temp_lang_code_ := value_;
                           Fnd_Session_API.Set_Language(temp_lang_code_);                                                            
                           temp_desc_ := Get_Month_Desc___(newrec_.cal_month) || ' ' || newrec_.cal_year;                              
                           Enterp_Comp_Connect_V170_API.Insert_Company_Translation(crecomp_rec_.company,
                                                                                   'ACCRUL',
                                                                                   lu_name_,
                                                                                   templ_year_ || '^' || templ_month_,
                                                                                   temp_lang_code_,
                                                                                   temp_desc_);                           
                        END LOOP;
                     END IF;                          
                     IF (period_ != 0) THEN
                        month_ := month_ + 1;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
                  END;
               END LOOP;
            END LOOP;
            Fnd_Session_API.Set_Language(init_lang_code_);            
         ELSE
            FOR rec_ IN get_data LOOP
               attr_ := NULL;
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               SAVEPOINT make_company_insert;
               BEGIN
                  newrec_.company              := crecomp_rec_.company;
                  newrec_.accounting_year      := rec_.n1;
                  newrec_.accounting_period    := rec_.n2;
                  newrec_.description          := rec_.c1;
                  newrec_.year_end_period      := rec_.c2;                  
                  newrec_.date_from            := rec_.d1;
                  newrec_.date_until           := rec_.d2;
                  newrec_.report_from_date     := rec_.d3;
                  newrec_.report_until_date    := rec_.d4;
                  newrec_.cal_year             := rec_.N3;
                  newrec_.cal_month            := rec_.N4;
                  Client_SYS.Clear_Attr(attr_);
                  indrec_ := Get_Indicator_Rec___(newrec_);
                  Check_Insert___(newrec_, indrec_, attr_);
                  Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
                  Insert___(objid_, objversion_, newrec_, attr_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully', msg_);
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');
            END IF;
         END IF;
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      -- Reset language code
      Fnd_Session_API.Set_Language(init_lang_code_);
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        ACCOUNTING_PERIOD_TAB%ROWTYPE;
   empty_rec_     ACCOUNTING_PERIOD_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   start_month_   NUMBER;
   month_         NUMBER;
   period_type_   VARCHAR2(20);
   cal_year_      NUMBER;
   indrec_        Indicator_Rec;
   from_date_        DATE;
   set_off_val_      NUMBER;   
   last_year_        NUMBER;
   templ_year_       NUMBER;
   templ_month_      NUMBER;
   lang_codes_       VARCHAR2(200);
   temp_desc_        VARCHAR2(200);
   temp_lang_code_   VARCHAR2(5);
   text_separator_   VARCHAR2(1) := Client_SYS.text_separator_;
   value_            VARCHAR2(2000);
   ptr_              NUMBER := 1;      
   init_lang_code_   VARCHAR2(5) := Fnd_Session_API.Get_Language;
   first_date_       DATE;
   first_year_       NUMBER;
   first_period_     NUMBER;
   
   CURSOR get_data IS
      SELECT accounting_year, accounting_period, description, year_end_period, date_from,
             date_until, report_from_date, report_until_date, cal_year,cal_month
      FROM   accounting_period_tab src 
      WHERE  company = crecomp_rec_.old_company
      AND    NOT EXISTS (SELECT 1 
                         FROM   accounting_period_tab dest
                         WHERE  dest.company           = crecomp_rec_.company
                         AND    dest.accounting_year   = src.accounting_year
                         AND    dest.accounting_period = src.accounting_period)
      ORDER BY accounting_year, accounting_period;
      
   -- Find what month is the first period for the source company , to get correct description when using user defined calendar   
   -- Also the last year of the source company to know when we cannot fetch any more translations from the template and need to generate
   -- translations instead.
   CURSOR get_from_date (old_company_ VARCHAR2)IS
      SELECT t.date_from, t.accounting_year
      FROM   accounting_period_tab t
      WHERE  t.company           = old_company_
      AND    t.accounting_period = 1
      ORDER BY t.accounting_year desc;      
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);

   IF (update_by_key_) THEN
      IF (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE') THEN
         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-25,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := empty_rec_;
          
               newrec_.accounting_year      := rec_.accounting_year;
               newrec_.accounting_period    := rec_.accounting_period;
               newrec_.description          := rec_.description;
               newrec_.year_end_period      := rec_.year_end_period;               
               newrec_.date_from            := rec_.date_from;
               newrec_.date_until           := rec_.date_until;
               newrec_.report_from_date     := rec_.report_from_date;
               newrec_.report_until_date    := rec_.report_until_date;
               newrec_.cal_year             := rec_.cal_year;
               newrec_.cal_month            := rec_.cal_month;
               newrec_.company              := crecomp_rec_.company;
               Client_SYS.Clear_Attr(attr_);
               indrec_ := Get_Indicator_Rec___(newrec_);
               Check_Insert___(newrec_, indrec_, attr_);
               Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
               Insert___(objid_, objversion_, newrec_, attr_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      END IF;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            start_month_ := crecomp_rec_.cal_start_month;
            lang_codes_ := crecomp_rec_.languages;
            OPEN get_from_date (crecomp_rec_.old_company);
            FETCH get_from_date INTO from_date_, last_year_;
            CLOSE get_from_date;
            first_date_ := Get_First_Normal_From_Date(crecomp_rec_.old_company);
            set_off_val_ := NVL(EXTRACT(MONTH FROM from_date_), -999); 
            first_year_   := NVL(EXTRACT(YEAR FROM first_date_), -999);
            first_period_ := NVL(EXTRACT(MONTH FROM first_date_), -999);
            FOR year_ IN 0..crecomp_rec_.number_of_years-1 LOOP
               month_ := start_month_;
               cal_year_ := crecomp_rec_.cal_start_year + year_;
               FOR period_ IN 0..12 LOOP
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  SAVEPOINT make_company_insert;
                  BEGIN
                     IF (month_ = 13) THEN
                        month_ := 1;
                        cal_year_ := crecomp_rec_.cal_start_year + year_ + 1;
                     END IF;
                     IF period_ = 0 THEN
                        period_type_ := 'YEAROPEN';
                     ELSE
                        period_type_ := 'ORDINARY';
                     END IF;
                     newrec_.company              := crecomp_rec_.company;
                     newrec_.accounting_year      := crecomp_rec_.acc_year + year_;
                     newrec_.accounting_period    := period_;                     
                     newrec_.description          := Get_Period_Desc(period_, cal_year_, month_);
                     newrec_.year_end_period      := period_type_;                     
                     newrec_.date_from            := Get_First_Day_Month___(month_, cal_year_);
                     IF period_ = 0 THEN
                        newrec_.date_until := newrec_.date_from;
                     ELSE
                        newrec_.date_until  := LAST_DAY(newrec_.date_from);
                     END IF;
                     newrec_.report_from_date     := NULL;
                     newrec_.report_until_date    := NULL;
                     newrec_.cal_year             := cal_year_;
                     newrec_.cal_month            := month_;
                     IF (period_ = 0) THEN
                        newrec_.cal_month := 0;
                        newrec_.cal_year  := newrec_.accounting_year;
                     END IF;
                     Client_SYS.Clear_Attr(attr_);
                     indrec_ := Get_Indicator_Rec___(newrec_);
                     Check_Insert___(newrec_, indrec_, attr_);
                     Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
                     Insert___(objid_, objversion_, newrec_, attr_);
                                          
                     -- if more years are generated than it exist translations for in the template then generate descriptions based on Year and 
                     -- enumeration of the months.
                     IF ((newrec_.cal_year >= last_year_) OR (crecomp_rec_.cal_start_year != first_year_) OR (start_month_ != first_period_)) THEN                        
                        ptr_ := 1;
                        WHILE Get_Next_From_Attr___(lang_codes_, ptr_, value_, text_separator_) LOOP
                           temp_lang_code_ := value_;                                                      
                           Fnd_Session_API.Set_Language(temp_lang_code_);
                           temp_desc_ := Get_Month_Desc___(newrec_.cal_month) || ' ' || newrec_.cal_year;
                           Enterp_Comp_Connect_V170_API.Insert_Company_Translation(crecomp_rec_.company,
                                                                                   'ACCRUL',
                                                                                   lu_name_,
                                                                                   newrec_.accounting_year || '^' || newrec_.accounting_period,
                                                                                   temp_lang_code_,
                                                                                   temp_desc_);                           
                        END LOOP;
                     ELSE
                        IF (set_off_val_ != -999) THEN                           
                           templ_year_ := Get_Set_Off_Year___(newrec_.cal_year, newrec_.cal_month, (set_off_val_ - 1 ));
                           templ_month_ := Get_Set_Off_Month___(newrec_.cal_month, (set_off_val_ - 1 ));                           
                        ELSE
                           templ_year_ := newrec_.accounting_year;
                           templ_month_ := newrec_.accounting_period;
                        END IF;                        
                        Enterp_Comp_Connect_V170_API.Copy_Comp_To_Comp_Trans(crecomp_rec_.company,
                                                                             crecomp_rec_.old_company,                                                                         
                                                                             'ACCRUL',
                                                                             lu_name_,
                                                                             lu_name_,
                                                                             templ_year_||'^'||templ_month_,
                                                                             newrec_.accounting_year || '^' || newrec_.accounting_period,                                                                              
                                                                             crecomp_rec_.languages);                     
                     END IF;                                               
                     IF (period_ != 0)THEN
                        month_ := month_ + 1;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
                  END;
               END LOOP;
            END LOOP;
            Fnd_Session_API.Set_Language(init_lang_code_);            
         ELSE
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               BEGIN
                  newrec_ := empty_rec_;
                 
                  newrec_.accounting_year      := rec_.accounting_year;
                  newrec_.accounting_period    := rec_.accounting_period;
                  newrec_.description          := rec_.description;
                  newrec_.year_end_period      := rec_.year_end_period;                  
                  newrec_.date_from            := rec_.date_from;
                  newrec_.date_until           := rec_.date_until;
                  newrec_.report_from_date     := rec_.report_from_date;
                  newrec_.report_until_date    := rec_.report_until_date;
                  newrec_.cal_year             := rec_.cal_year;
                  newrec_.cal_month            := rec_.cal_month;
                  newrec_.company              := crecomp_rec_.company;
                  Client_SYS.Clear_Attr(attr_);
                  indrec_ := Get_Indicator_Rec___(newrec_);
                  Check_Insert___(newrec_, indrec_, attr_);
                  Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
                  Insert___(objid_, objversion_, newrec_, attr_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);                                                   
               END;
            END LOOP;
         END IF;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      -- reset language
      Fnd_Session_API.Set_Language(init_lang_code_);
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_PERIOD_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;

   CURSOR get_data IS
      SELECT accounting_year, accounting_period, description, year_end_period, date_from,
      date_until, report_from_date, report_until_date, cal_year,cal_month
      FROM   accounting_period_tab
      WHERE  company = crecomp_rec_.company
      ORDER BY accounting_year, accounting_period;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.n1 := pctrec_.accounting_year;
      pub_rec_.n2 := pctrec_.accounting_period;
      pub_rec_.c1 := pctrec_.description;
      pub_rec_.c2 := pctrec_.year_end_period;      
      pub_rec_.d1 := pctrec_.date_from;
      pub_rec_.d2 := pctrec_.date_until;
      pub_rec_.c4 := 'N';
      pub_rec_.d3 := pctrec_.report_from_date;
      pub_rec_.d4 := pctrec_.report_until_date;
      pub_rec_.n3 := pctrec_.cal_year;
      pub_rec_.n4 := pctrec_.cal_month;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;


PROCEDURE Validate_Report_Date___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   report_from_date_    IN DATE,
   report_until_date_   IN DATE,
   valid_until_date_    IN DATE )
IS
   max_rep_until_date_  DATE;
   min_rep_from_date_   DATE;

   CURSOR get_max_rep_until_date IS
      SELECT MAX(report_until_date)
      FROM   accounting_period_tab
      WHERE  company            = company_
      AND    accounting_year    = accounting_year_
      AND    accounting_period  < accounting_period_
      AND    report_until_date IS NOT NULL;

   CURSOR get_min_rep_from_date  IS
      SELECT MIN(report_from_date)
      FROM   accounting_period_tab
      WHERE  company            = company_
      AND    accounting_year    = accounting_year_
      AND    accounting_period  > accounting_period_
      AND    report_from_date IS NOT NULL;
   
BEGIN     
   IF (((report_from_date_    IS NOT NULL) AND (report_until_date_ IS NULL))
      OR ((report_until_date_ IS NOT NULL) AND (report_from_date_  IS NULL))) THEN
      Error_SYS.Record_General(lu_name_, 'ERRBOTHDATES: Both Report From Date and Report Until Date must have values');
   END IF;

   IF (report_from_date_  IS NOT NULL) THEN
      IF NOT (report_from_date_ >= valid_until_date_) THEN
         Error_SYS.Record_General(lu_name_, 'ERRFROMDATE: Report From Date must be equal or later than the Valid Until Date');
      END IF;

      OPEN get_max_rep_until_date;
      FETCH get_max_rep_until_date INTO max_rep_until_date_;
      CLOSE get_max_rep_until_date;

      IF (report_from_date_ <= max_rep_until_date_) THEN
         Error_SYS.Record_General(lu_name_, 'ERRMINFROMDATE: Report From Date must be later than Report Until Date for the closest previous period');
      END IF;

      OPEN  get_min_rep_from_date;
      FETCH get_min_rep_from_date  INTO min_rep_from_date_;
      CLOSE get_min_rep_from_date;

      IF (report_until_date_ >= min_rep_from_date_) THEN
         Error_SYS.Record_General(lu_name_, 'ERRMAXUNTILDATE: Report Until Date must be earlier than Report From Date of the closest next period');
      END IF;
   END IF;
   IF (report_until_date_ IS NOT NULL) THEN
      IF NOT (report_until_date_ >= report_from_date_) THEN
         Error_SYS.Record_General(lu_name_, 'ERRMINUNTILDATE: Report Until Date must be equal or later than Report From Date');
      END IF;
   END IF;
END Validate_Report_Date___;


FUNCTION Get_First_Day_Month___(
   month_   IN NUMBER,
   year_    IN NUMBER ) RETURN DATE
IS
   v_month_  VARCHAR2(2);
   v_year_   VARCHAR2(4);
BEGIN
   v_month_ := TRIM(TO_CHAR(month_, '00'));
   v_year_  := TO_CHAR(year_);
   RETURN TO_DATE(v_year_ || '-' || v_month_ || '-01' ,'YYYY-MM-DD','NLS_CALENDAR=GREGORIAN');
END Get_First_Day_Month___;


FUNCTION Get_Set_Off_Year___ (
    cal_year_     IN NUMBER,
    cal_month_    IN NUMBER,
    month_diff_   IN NUMBER) RETURN NUMBER
IS
   year_         NUMBER;
BEGIN
   IF (cal_month_ = 0) THEN
      year_ := cal_year_;
   ELSIF (cal_month_ <= month_diff_) THEN
      year_ := cal_year_ - 1;
   ELSE
      year_ := cal_year_;
   END IF;
   RETURN year_;
END Get_Set_Off_Year___;


FUNCTION Get_Set_Off_Month___ (
    cal_month_    IN NUMBER,
    month_diff_   IN NUMBER) RETURN NUMBER
IS
   month_        NUMBER;
BEGIN
   IF (cal_month_ = 0) THEN
      month_ := 0;
   ELSIF (cal_month_ <= month_diff_) THEN
      month_ := cal_month_ + (12 - month_diff_) ;
   ELSE
      month_ := cal_month_ - month_diff_ ;
   END IF;
   RETURN month_;
END Get_Set_Off_Month___;

-- Build_Year_Period_Key___
--   Build a year-period key from the accounting year and accounting period
FUNCTION Build_Year_Period_Key___(
   year_period_rec_ Year_Period_Rec ) RETURN VARCHAR
IS
   ypk_   VARCHAR2(10);
BEGIN
   ypk_ := TO_CHAR(year_period_rec_.Accounting_Year * 100 + year_period_rec_.Accounting_Period);
   RETURN ypk_;
END Build_Year_Period_Key___;

@UncheckedAccess
-- Extract_Year_And_Period___
--   Method that extracts (and output) the year and period from a given year-period (e.g. 2016-01)
--   The year-period must be in the following format like YYYY-MM.
PROCEDURE Extract_Year_And_Period___(
   year_          OUT NUMBER,
   period_        OUT NUMBER,   
   year_period_   IN  VARCHAR2)
IS   
   invalid_number    EXCEPTION;
   PRAGMA EXCEPTION_INIT(invalid_number, -06502);      
BEGIN
   year_     := TO_NUMBER(SUBSTR(year_period_,1,4));
   period_   := TO_NUMBER(SUBSTR(year_period_,6,2));   
EXCEPTION 
   WHEN invalid_number THEN
      Error_SYS.Record_General(lu_name_, 
                               'INVYEARPERIODFMT: The Year Period :P1 is incorrect. The format must be entered as YYYY-MM',
                               year_period_);   
END Extract_Year_And_Period___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'YEAR_END_PERIOD',   Period_Type_API.Decode('ORDINARY'),           attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT ACCOUNTING_PERIOD_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS   
BEGIN
   IF (newrec_.cal_month IS NULL) THEN
      newrec_.cal_month := EXTRACT(MONTH FROM newrec_.date_until);
   END IF;
   IF (newrec_.cal_year IS NULL) THEN
      newrec_.cal_year := EXTRACT(YEAR FROM newrec_.date_until);
   END IF;   
   
   super(objid_, objversion_, newrec_, attr_);
   IF (NVL(Client_SYS.Get_Item_Value('CREATE_COMP', attr_),'FALSE') <> 'TRUE') THEN
      Create_Period_Ledger_Info___(newrec_);
   END IF;   
   Invalidate_Year_Per_Cache___;    
END Insert___;

PROCEDURE Create_Period_Ledger_Info___(
   newrec_        IN accounting_period_tab%ROWTYPE,
   ledger_id_     IN VARCHAR2 DEFAULT NULL)
IS   
   period_ledger_attr_  VARCHAR2(32000);
   info_                VARCHAR2(32000);
   objid_               VARCHAR2(32000);
   objversion_          VARCHAR2(32000);
   temp_attr_           VARCHAR2(32000);
   gl_status_           VARCHAR2(1);
   open_ye_count_       NUMBER;
   
   $IF Component_Intled_SYS.INSTALLED $THEN 
   CURSOR get_ledger_info IS
      SELECT ledger_id
      FROM   internal_ledger_tab
      WHERE  company = newrec_.company;   
   $END
   
   CURSOR get_gl_status IS
      SELECT period_status
      FROM   acc_period_ledger_info_tab
      WHERE  company  = newrec_.company
      AND    accounting_year = newrec_.accounting_year
      AND    accounting_period = newrec_.accounting_period
      AND    ledger_id = '00';
      
   CURSOR get_gl_open_ye_count IS
      SELECT COUNT(*)
      FROM   acc_period_ledger_info_tab p, accounting_period_tab a
      WHERE  p.company = a.company
      AND    p.accounting_year = a.accounting_year
      AND    p.accounting_period = a.accounting_period
      AND    a.year_end_period = 'YEARCLOSE'
      AND    p.company  = newrec_.company
      AND    p.ledger_id = '00'
      AND    p.period_status = 'O'
      AND    p.accounting_year = newrec_.accounting_year;
      
   CURSOR exist_open_ye IS
      SELECT COUNT(*)
      FROM   acc_period_ledger_info_tab p, accounting_period_tab a
      WHERE  p.company = a.company
      AND    p.accounting_year = a.accounting_year
      AND    p.accounting_period = a.accounting_period
      AND    a.year_end_period = 'YEARCLOSE'
      AND    p.company  = newrec_.company
      AND    p.ledger_id = ledger_id_
      AND    p.period_status = 'O'
      AND    p.accounting_year = newrec_.accounting_year;
BEGIN
   Client_SYS.Clear_Attr(period_ledger_attr_);
   Acc_Period_Ledger_Info_API.New__(info_, objid_, objversion_,period_ledger_attr_, 'PREPARE' );   
   Client_SYS.Add_To_Attr('COMPANY', newrec_.company, period_ledger_attr_);
   Client_SYS.Add_To_Attr('ACCOUNTING_YEAR', newrec_.accounting_year, period_ledger_attr_);
   Client_SYS.Add_To_Attr('ACCOUNTING_PERIOD', newrec_.accounting_period, period_ledger_attr_);
   temp_attr_ := period_ledger_attr_;
   Client_SYS.Add_To_Attr('LEDGER_ID', NVL(ledger_id_,'00'), period_ledger_attr_);
   IF (ledger_id_ != '00'  AND newrec_.year_end_period = 'YEARCLOSE') THEN
      -- This block execute when a new Internal Ledger ID is created.
      OPEN get_gl_open_ye_count;
      FETCH get_gl_open_ye_count INTO open_ye_count_;
      CLOSE get_gl_open_ye_count;
      
      IF (open_ye_count_ = 0) THEN
         
         OPEN exist_open_ye;
         FETCH exist_open_ye INTO open_ye_count_;
         CLOSE exist_open_ye;
         
         IF (open_ye_count_ = 1) THEN
            Client_SYS.Add_To_Attr('PERIOD_STATUS', Acc_Year_Per_Status_API.Decode('C'), period_ledger_attr_);
         END IF;
      ELSE
         OPEN get_gl_status;
         FETCH get_gl_status INTO gl_status_;
         CLOSE get_gl_status;
         
         Client_SYS.Add_To_Attr('PERIOD_STATUS', Acc_Year_Per_Status_API.Decode(gl_status_), period_ledger_attr_);
      END IF;
   END IF;
   Acc_Period_Ledger_Info_API.New__(info_, objid_, objversion_,period_ledger_attr_, 'DO' );

   $IF Component_Intled_SYS.INSTALLED $THEN 
   IF (ledger_id_ IS NULL) THEN
      FOR rec_ IN get_ledger_info LOOP
         period_ledger_attr_ := temp_attr_;
         Client_SYS.Add_To_Attr('LEDGER_ID', rec_.ledger_id, period_ledger_attr_);
         Acc_Period_Ledger_Info_API.New__(info_, objid_, objversion_,period_ledger_attr_, 'DO' );
      END LOOP;
   END IF;   
   $END
END Create_Period_Ledger_Info___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     accounting_period_tab%ROWTYPE,
   newrec_     IN OUT accounting_period_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   Invalidate_Year_Per_Cache___;
END Update___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN ACCOUNTING_PERIOD_TAB%ROWTYPE )
IS
BEGIN   
   $IF Component_Genled_SYS.INSTALLED $THEN
      Accounting_Journal_Item_API.Sync_Acc_Periods(remrec_.company, 
                                                   remrec_.accounting_year, 
                                                   remrec_.accounting_period,
                                                   remove_period_ => 'TRUE');
   $END
   
   super(objid_, remrec_);
   Invalidate_Year_Per_Cache___;
END Delete___;


PROCEDURE Invalidate_Year_Per_Cache___
IS
   null_value_ Year_Period_Rec;
BEGIN
   micro_cache_year_per_tab_.delete;
   micro_cache_year_per_value_ := null_value_;
   micro_cache_year_per_time_  := 0;
END Invalidate_Year_Per_Cache___;

PROCEDURE Update_Year_Per_Cache___ (
   company_ IN VARCHAR2,
   actual_date_ IN DATE )
IS
   date_param_ DATE := TRUNC(actual_date_);
   req_id_     VARCHAR2(1000) := company_||'^'||TO_CHAR(date_param_, 'YYYY-MM-DD');
   null_value_ Year_Period_Rec;
   time_       NUMBER;
   expired_    BOOLEAN;   
   
   CURSOR get_accounting_year IS
      SELECT  accounting_year, accounting_period
        FROM  accounting_period_tab
       WHERE  company      = company_
         AND  date_from    <= date_param_
         AND  date_until   >= date_param_
         ORDER BY accounting_period ASC;   
BEGIN   
   time_       := Database_SYS.Get_Time_Offset;
   expired_    := ((time_ - micro_cache_year_per_time_) > 100);
   IF (expired_ OR (micro_cache_year_per_user_ IS NULL) OR (micro_cache_year_per_user_ != Fnd_Session_API.Get_Fnd_User)) THEN
      Invalidate_Year_Per_Cache___;
      micro_cache_year_per_user_ := Fnd_Session_API.Get_Fnd_User;
   END IF;
   IF (NOT micro_cache_year_per_tab_.exists(req_id_)) THEN      
      OPEN  get_accounting_year;
      FETCH get_accounting_year INTO micro_cache_year_per_value_;      
      IF (get_accounting_year%NOTFOUND) THEN
         micro_cache_year_per_value_ := null_value_;
         micro_cache_year_per_time_  := time_;         
         CLOSE get_accounting_year;
         RETURN;
      ELSE
         IF (micro_cache_year_per_tab_.count >= 10) THEN
            DECLARE
               random_  NUMBER := NULL;
               element_ VARCHAR2(1000);
            BEGIN
               random_  := round(dbms_random.value(1,10), 0);
               element_ := micro_cache_year_per_tab_.first;
               FOR i IN 1..random_-1 LOOP
                  element_ := micro_cache_year_per_tab_.next(element_);
               END LOOP;
               micro_cache_year_per_tab_.delete(element_);               
            END;
         END IF;
         micro_cache_year_per_tab_(req_id_) := micro_cache_year_per_value_;
         micro_cache_year_per_time_ := time_;
      END IF;      
      CLOSE get_accounting_year;            
   END IF;
   micro_cache_year_per_value_ := micro_cache_year_per_tab_(req_id_);
END Update_Year_Per_Cache___;   

-- Get_Ordinary_Period_Info___
--   Purpose : to get ordinary period information
PROCEDURE Get_Ordinary_Period_Info___(
   accounting_year_       OUT NUMBER,
   accounting_period_     OUT NUMBER,
   company_               IN  VARCHAR2,
   date_in_               IN  DATE)
IS
   date_param_     DATE;
   CURSOR get_year IS
      SELECT  accounting_year, accounting_period
      FROM    accounting_period_tab
      WHERE   company    = company_
      AND     date_from  <= date_param_
      AND     date_until >= date_param_
      AND     year_end_period = 'ORDINARY'
      ORDER BY accounting_period ASC;
BEGIN
   date_param_ := TRUNC(date_in_);
   OPEN get_year;
   FETCH get_year INTO accounting_year_, accounting_period_;
   CLOSE get_year;
END Get_Ordinary_Period_Info___;

-- Get_Period_Info___
--   Purpose : get period(oridnary and year end period) information
PROCEDURE Get_Period_Info___(
   accounting_year_       OUT NUMBER,
   accounting_period_     OUT NUMBER,
   company_            IN     VARCHAR2,
   actual_date_        IN     DATE      )
IS 
BEGIN
   Update_Year_Per_Cache___(company_, actual_date_);
   accounting_year_   := micro_cache_year_per_value_.Accounting_Year;
   accounting_period_ := micro_cache_year_per_value_.Accounting_Period;
END Get_Period_Info___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_period_tab%ROWTYPE,
   newrec_ IN OUT accounting_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   year_end_period_  VARCHAR2(200);   
BEGIN
   newrec_.date_from := TRUNC(newrec_.date_from);
   newrec_.date_until := TRUNC(newrec_.date_until);
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   Check_Previous_Year_End_Period(newrec_);      
   year_end_period_ := Period_Type_API.Decode('YEAROPEN');      
   IF ( newrec_.accounting_period = 0 AND newrec_.year_end_period != 'YEAROPEN') THEN
      Error_SYS.Record_General(lu_name_, 'YEAROPENPERIOD3: Period 0 can only be Period Type ":P1" for opening period.', year_end_period_);
   END IF;
   IF (newrec_.accounting_period != 0 AND newrec_.year_end_period = 'YEAROPEN') THEN         
      Error_SYS.Record_General(lu_name_, 'YEAROPENPERIOD4: Only period 0 can be Period Type ":P1" for opening period.', year_end_period_);
   END IF;   
   IF (newrec_.year_end_period = 'YEAROPEN') THEN
      Check_Year_Opening_Period__(newrec_.company,newrec_.accounting_year,newrec_.accounting_period);
      Check_Opening_Date__(newrec_.company,newrec_.accounting_year,newrec_.accounting_period,newrec_.date_from,newrec_.date_until);
   END IF;

   Check_Valid_Range__(newrec_.date_from, newrec_.date_until);

   Validate_Report_Date___(newrec_.company,
                           newrec_.accounting_year,
                           newrec_.accounting_period,
                           newrec_.report_from_date,
                           newrec_.report_until_date,
                           newrec_.date_until);  
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   IF (Acc_Year_Ledger_Info_API.Get_Year_Status_Db(newrec_.company, newrec_.accounting_year, '00') != 'O') THEN
      Error_SYS.Record_General(lu_name_, 'ACCYEARNOTOPEN: Accounting year is not open. Therefore Accounting period(s) cannot be created.');
   END IF;
   IF (LENGTH(newrec_.accounting_period) > 2) THEN
      Error_SYS.Appl_General(lu_name_, 'ACCPERIODEXCEEDED: The accounting period should consist of either one character or two characters.');
   END IF;
   IF (newrec_.year_end_period = 'YEARCLOSE') THEN
      Check_Year_End_Period(newrec_.company,newrec_.accounting_year,newrec_.accounting_period);
   END IF;   
   
   Check_Period_Dates_New__(newrec_.company,newrec_.accounting_period,newrec_.date_from, newrec_.accounting_year, newrec_.year_end_period);
   Check_Period_Dates_New__(newrec_.company,newrec_.accounting_period,newrec_.date_until, newrec_.accounting_year, newrec_.year_end_period);
      
   Check_Whole_Period__(newrec_.company,newrec_.date_from,newrec_.date_until);        

   $IF Component_Genled_SYS.INSTALLED $THEN
      Accounting_Journal_Item_API.Sync_Acc_Periods(newrec_.company, 
                                                   newrec_.accounting_year, 
                                                   newrec_.accounting_period,
                                                   add_period_ => 'TRUE');
   $END
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     accounting_period_tab%ROWTYPE,
   newrec_ IN OUT accounting_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS  
BEGIN   
   IF (Acc_Year_Ledger_Info_API.Get_Year_Status_Db(newrec_.company, newrec_.accounting_year, '00') != 'O' AND ( indrec_.description OR indrec_.date_from OR indrec_.date_until)) THEN
      Error_SYS.Record_General(lu_name_, 'ACCYEARNOTOPENMOD: Accounting year is not open. Therefore Accounting period(s) cannot be Modified.');
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);
   IF (indrec_.date_from OR indrec_.date_until) THEN
      IF ((oldrec_.date_from != newrec_.date_from) OR (oldrec_.date_until != newrec_.date_until)) THEN
         Check_Date_Change_Allowed___( newrec_.company,
                                       newrec_.accounting_year,
                                       newrec_.accounting_period );
      END IF;
   END IF;
   IF (newrec_.year_end_period = 'YEARCLOSE') THEN
      Check_Previous_Year_End_Period(newrec_);
   END IF;   
END Check_Update___;

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN accounting_period_tab%ROWTYPE)
IS
   temp_   VARCHAR2(5);
BEGIN
   IF (Acc_Year_Ledger_Info_API.Get_Year_Status_Db(remrec_.company, remrec_.accounting_year, '00') != 'O') THEN
      Error_SYS.Record_General(lu_name_, 'ACCYEARNOTOPENDEL: Accounting year :P1 is closed in General Ledger. Therefore Accounting period(s) cannot be removed.', remrec_.accounting_year);
   END IF;      
   super(remrec_);   
   temp_ := Voucher_No_Serial_API.Is_Period_Exist( remrec_.company, remrec_.accounting_year, remrec_.accounting_period);      
   IF ( temp_ = 'TRUE') THEN
      Client_SYS.Add_Warning(lu_name_, 'VOUNOEXISTS: Voucher Number exist for the period :P1 to be deleted.', remrec_.accounting_period);
   END IF;   
END Check_Delete___;

-- Get_Max_Period___
--   Get the max period based on the company and accounting year
FUNCTION Get_Max_Period___ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN NUMBER
IS
   max_period_               NUMBER;   
   CURSOR getmaxperiod IS
      SELECT MAX(accounting_period)
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = accounting_year_;     
BEGIN
   OPEN   getmaxperiod;
   FETCH  getmaxperiod INTO max_period_;
   CLOSE  getmaxperiod;
   RETURN max_period_;
END Get_Max_Period___;


--Purpose : To get the Min period
FUNCTION Get_Min_Period___ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN NUMBER
IS
   CURSOR getminperiod IS
      SELECT MIN(accounting_period)
      FROM   accounting_period_tab
      WHERE  company       = company_
      AND  accounting_year = accounting_year_;
   min_period_               NUMBER;
BEGIN
   OPEN   getminperiod;
   FETCH  getminperiod INTO min_period_ ;
   CLOSE  getminperiod;
   RETURN min_period_;
END Get_Min_Period___;


FUNCTION Get_Cre_Period_Description___(
   period_rec_          IN Accounting_Period_Tab%ROWTYPE,
   source_year_         IN NUMBER,
   current_year_        IN NUMBER,
   new_accounting_year_ IN NUMBER ) RETURN VARCHAR2
IS
   description_   Accounting_Period_Tab.description%TYPE;
BEGIN
   IF (period_rec_.year_end_period = 'YEAROPEN') THEN
      description_     := Language_SYS.Translate_Constant(lu_name_, 'YEAROPENPERIOD: Year Opening Period') || ' '||new_accounting_year_;
   ELSIF (period_rec_.year_end_period = 'YEARCLOSE') THEN
      description_     := Language_SYS.Translate_Constant(lu_name_, 'YEARCLOSEPERIOD: Year Closing Period') || ' '||new_accounting_year_;
   ELSE  
      -- check period used across calender months.
      IF TO_CHAR(period_rec_.date_from, 'Month') != TO_CHAR(period_rec_.date_until, 'Month') THEN        
         -- check date_from description is not equal to source descripiton.
         IF period_rec_.description != TO_CHAR(period_rec_.date_from, 'Month') THEN
            -- remove the year part from the source description
            IF LENGTH(period_rec_.description) >3 AND SUBSTR(period_rec_.description,-4) = source_year_ THEN
               -- if year part available in the source, remove it before appending year.
               description_ := SUBSTR(period_rec_.description,1, (LENGTH(period_rec_.description)-4));
               description_ := TRIM(description_)||' '||current_year_;
               RETURN description_;
            ELSE
               -- if year part is not available in the source.
               description_ := TRIM(period_rec_.description)||' '||current_year_;
               RETURN description_;
            END IF;
         END IF;
      END IF;
      description_:= TRIM(TO_CHAR(period_rec_.date_from, 'Month'));
      description_ := description_||' '||current_year_;
   END IF;
   RETURN description_;
END Get_Cre_Period_Description___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Period_Dates_New__ (
   company_            IN VARCHAR2,
   accounting_period_  IN NUMBER,
   date_               IN DATE,
   accounting_year_    IN NUMBER DEFAULT NULL,
   year_end_period_    IN VARCHAR2 DEFAULT 'ORDINARY' )
IS
   acc_year_               NUMBER;
   acc_period_             NUMBER;
   period_already_exists_  VARCHAR2(5);
   period_type_            VARCHAR2(10);

   CURSOR get_acc_info IS
      SELECT accounting_year, accounting_period, year_end_period
      FROM accounting_period_tab
      WHERE company = company_
      AND   date_ BETWEEN date_from AND date_until;
BEGIN   
   OPEN  get_acc_info;
   FETCH get_acc_info INTO acc_year_, acc_period_, period_type_;
   CLOSE get_acc_info;

   IF (year_end_period_ = 'ORDINARY' AND year_end_period_ = period_type_) THEN
      IF (acc_year_ IS NULL OR (acc_year_ = accounting_year_ AND acc_period_ = accounting_period_)) THEN
         period_already_exists_ := 'FALSE';
      ELSE
         period_already_exists_ := 'TRUE';
      END IF;
   ELSE
      IF (acc_year_ IS NULL OR acc_year_ = accounting_year_ ) THEN
         period_already_exists_ := 'FALSE';
      ELSE
         period_already_exists_ := 'TRUE';
      END IF;
   END IF;

   IF (period_already_exists_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'IN_ANOTHER_PERIOD: Date :P1 is already part of another period', date_);
   END IF;
END Check_Period_Dates_New__;


PROCEDURE Check_Whole_Period__ (
   company_          IN VARCHAR2,
   date_from_        IN DATE,
   date_until_       IN DATE )
IS
   dummy_            VARCHAR2(10);

   CURSOR Check_dates IS
      SELECT 'TRUE'
      FROM accounting_period_tab
      WHERE company    = company_
      AND   date_from  > date_from_
      AND   date_until < date_until_;
BEGIN
   dummy_ := 'FALSE';
   OPEN  Check_dates;
   FETCH Check_dates INTO dummy_;   
   CLOSE Check_dates;
   
   IF (dummy_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'IN_PERIOD_OERLAP: This Period overlaps another period');
   END IF;
END Check_Whole_Period__;


PROCEDURE Check_Valid_Range__ (
   date_from_         IN DATE,
   date_until_        IN DATE )
IS
BEGIN
   IF (date_from_ > date_until_) THEN
      Error_SYS.Record_General(lu_name_,'DATERR: Date from must be before date until');
   END IF;
END Check_Valid_Range__;


--Purpose : validating opening period
PROCEDURE Check_Year_Opening_Period__ (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER )
IS
   min_value_       NUMBER;
   dummy_           NUMBER;   

   CURSOR year_open IS
      SELECT 1
      FROM   accounting_period_tab
      WHERE  company = company_
      AND    accounting_year = accounting_year_
      AND    year_end_period = 'YEAROPEN'
      AND    accounting_period = min_value_ ;
BEGIN
   IF (accounting_period_ != 0) THEN
      Error_SYS.Record_General(lu_name_, 'YEAROPENPERIOD2: Only the period 0 can be a year :P1 opening period.',accounting_year_);
   END IF;   
   min_value_ := Get_Min_Period___(company_, accounting_year_);   
   OPEN year_open;
   FETCH year_open INTO dummy_;
   IF (year_open%FOUND) THEN
      IF (accounting_period_ > min_value_) THEN
         CLOSE year_open;
         Error_SYS.Record_General(lu_name_, 'YEAROPENPERIOD2: Only the period 0 can be a year :P1 opening period.',accounting_year_);
      END IF;
   END IF;
   CLOSE year_open;
END Check_Year_Opening_Period__;


PROCEDURE Get_Opening_Period__ (
   period_desc_            OUT VARCHAR2,
   valid_until_            OUT DATE,
   accounting_period_      OUT NUMBER,
   company_                IN  VARCHAR2,
   accounting_year_        IN  NUMBER,
   exclude_period_status_  IN  VARCHAR2 DEFAULT NULL )
IS
BEGIN
   Acc_Period_Ledger_Info_API.Get_Opening_Period__(period_desc_,
                                                   valid_until_,
                                                   accounting_period_,
                                                   company_,
                                                   accounting_year_,
                                                   '00',
                                                   exclude_period_status_ );
END Get_Opening_Period__;


PROCEDURE Check_Opening_Date__ (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   date_from_           IN DATE,
   date_until_          IN DATE )
IS
   next_dt_from_         DATE;
   next_dt_until_        DATE;

   CURSOR get_next_date IS
      SELECT date_from, date_until
      FROM   accounting_period_tab
      WHERE  company = company_
      AND    accounting_year = accounting_year_
      AND    accounting_period = (accounting_period_+1);
BEGIN
   IF (date_from_ != date_until_) THEN
      Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD7: Valid From and Valid Until of Year Opening Period should be equal to the first date of the financial Year :P1.',accounting_year_);
   END IF;

   OPEN get_next_date;
   FETCH get_next_date INTO next_dt_from_,next_dt_until_;
   IF (get_next_date%FOUND) THEN
      IF NOT (date_from_ = next_dt_from_ AND date_until_ = next_dt_from_) THEN
         CLOSE get_next_date;
         Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD7: Valid From and Valid Until of Year Opening Period should be equal to the first date of the financial Year :P1.',accounting_year_);
      END IF;
   END IF;
   CLOSE get_next_date;   
END Check_Opening_Date__;


@UncheckedAccess
FUNCTION Get_Year_Period__ (
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER ) RETURN VARCHAR2
IS
   year_period_ VARCHAR2(7);
BEGIN
   IF (accounting_period_ < 10) THEN
      year_period_ := concat(to_char(accounting_year_),concat('-0', to_char(accounting_period_)));
   ELSE
      year_period_ := concat(to_char(accounting_year_),concat('-', to_char(accounting_period_)));
   END IF;
   RETURN year_period_;
END Get_Year_Period__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
--This method is used in Aurena Lobbies

FUNCTION Get_Year_Period_Str (
   company_ IN VARCHAR2,
   date_    IN DATE ) RETURN VARCHAR2
IS
   year_period_str_   VARCHAR2(7):= NULL;
   accounting_period_ NUMBER;
BEGIN
   accounting_period_ := Accounting_Period_API.Get_Accounting_Period(company_, date_);
   IF (accounting_period_ < 10) THEN
      year_period_str_ := concat('0', to_char(accounting_period_));
   ELSE
      year_period_str_ := to_char(accounting_period_);
   END IF;
   RETURN year_period_str_;
END Get_Year_Period_Str;

PROCEDURE Check_Year_End_Period (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER )
IS
   max_value_       NUMBER;
   dummy_           NUMBER;
   
   CURSOR year_end IS
      SELECT 1
      FROM   accounting_period_tab
      WHERE  company = company_
      AND    accounting_year = accounting_year_
      AND    year_end_period = 'YEARCLOSE'
      AND    accounting_period = max_value_;
BEGIN  
   max_value_ := Get_Max_Period(company_, accounting_year_);
   OPEN year_end;
   FETCH year_end INTO dummy_;
   IF (year_end%NOTFOUND) THEN
      IF (accounting_period_ <= max_value_) THEN
         CLOSE year_end;
         Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD2: It is not allowed to Check another Period when the Highest Period has already been Checked for the selected Year :P1',accounting_year_);
      END IF;
   END IF;
   CLOSE year_end;
END Check_Year_End_Period;


PROCEDURE Check_Previous_Year_End_Period (
   period_rec_ IN Accounting_Period_Tab%ROWTYPE )
IS
   max_year_end_period_  NUMBER;
   prev_dt_from_         DATE;
   prev_dt_until_        DATE;   
   next_year_end_period_ VARCHAR2(10);   
   open_date_            DATE;

   CURSOR check_any_year_end IS
      SELECT MAX(accounting_period)
      FROM   accounting_period_tab
      WHERE  company          = period_rec_.company
      AND    accounting_year  = period_rec_.accounting_year
      AND    year_end_period  = 'YEARCLOSE';
      
   CURSOR get_prev_period IS
      SELECT date_from,date_until
      FROM   accounting_period_tab
      WHERE  company             = period_rec_.company
      AND    accounting_year     = period_rec_.accounting_year
      AND    accounting_period   = (period_rec_.accounting_period - 1);

   CURSOR get_next_period IS
      SELECT year_end_period
      FROM   accounting_period_tab
      WHERE  company = period_rec_.company
      AND    accounting_year = period_rec_.accounting_year
      AND    accounting_period = (period_rec_.accounting_period + 1);
  
BEGIN
   IF (period_rec_.year_end_period = 'YEARCLOSE') THEN
      OPEN get_prev_period;
      FETCH get_prev_period INTO prev_dt_from_,prev_dt_until_;
      IF (get_prev_period%FOUND) THEN
         IF NOT (period_rec_.date_from = prev_dt_until_ AND period_rec_.date_until = prev_dt_until_) THEN
            CLOSE get_prev_period;
            Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD4: Valid From and Valid Until of Year End Period should be equal to the last date of the financial Year :P1.',period_rec_.accounting_year);
         END IF;         
      END IF;
      CLOSE get_prev_period;

      OPEN get_next_period;
      FETCH get_next_period INTO next_year_end_period_;
      IF (get_next_period%FOUND) THEN
         IF (next_year_end_period_ = 'ORDINARY') THEN
            CLOSE get_next_period;
            Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD3: It is not allowed to have Year end Period, with next period is an Ordinary period ');
         END IF;
      END IF;
      CLOSE get_next_period;      
   END IF;
   
   OPEN  check_any_year_end;
   FETCH check_any_year_end INTO max_year_end_period_;
   IF (check_any_year_end%NOTFOUND) THEN
      NULL;
   ELSE
      IF (period_rec_.accounting_period > max_year_end_period_ AND period_rec_.year_end_period = 'ORDINARY' ) THEN
         CLOSE check_any_year_end;
         Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD5: It is not allowed to create a new ordinary period with a number higher than previous year end period :P1.',max_year_end_period_);
      END IF;
   CLOSE check_any_year_end;
   END IF;
   
   open_date_ := Get_Date_From(period_rec_.company, period_rec_.accounting_year, 0);
   IF (open_date_ IS NOT NULL AND open_date_ > period_rec_.date_from ) THEN
      Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD8: It is not allowed to create a new ordinary period with a date lesser than year opening period.');
   END IF;
END Check_Previous_Year_End_Period;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Periodexist (
   exists_            OUT VARCHAR2,
   company_           IN     VARCHAR2,
   accounting_year_   IN     NUMBER,
   accounting_period_ IN     NUMBER )
IS
BEGIN   
   exists_ := 'FALSE';
   IF (Check_Exist___(company_, accounting_year_, accounting_period_)) THEN
      exists_ := 'TRUE';
   END IF;
END Periodexist;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_Period_Dates (
   company_     IN VARCHAR2,
   date_from_   IN DATE )
IS
   max_year_       NUMBER;
   min_year_       NUMBER;
   max_period_     NUMBER;
   min_period_     NUMBER;
   check_date_     DATE;
   min_date_       DATE;
BEGIN   
   BEGIN
      SELECT max(accounting_year), min(accounting_year)
         INTO   max_year_, min_year_
         FROM   accounting_period_tab
         WHERE  company = company_;
   EXCEPTION WHEN no_data_found THEN
      max_year_ := 0;
   END;
   BEGIN
      SELECT  max(accounting_period)
         INTO    max_period_
         FROM    accounting_period_tab
         WHERE   accounting_year = max_year_
         AND     company         = company_;
   END;
   BEGIN
      SELECT  min(accounting_period)
         INTO    min_period_
         FROM    accounting_period_tab
         WHERE   company         = company_
         AND     accounting_year = min_year_;
   END;
   BEGIN
      SELECT  date_from
         INTO    min_date_
         FROM    accounting_period_tab
         WHERE   company           = company_
         AND     accounting_year   = min_year_
         AND     accounting_period = min_period_;
   END;
   BEGIN
      IF (max_year_ != 0) THEN
         BEGIN
            SELECT  date_until
               INTO    check_date_
               FROM    accounting_period_tab
               WHERE   company           = company_
               AND     accounting_year   = max_year_
               AND     accounting_period = max_period_;
            IF (date_from_ > check_date_ + 1) THEN
               Error_SYS.Record_General(lu_name_, 'NO_INS_PER: The start date must not be more than one day after last stop date');
            END IF;
            IF (date_from_ < check_date_ + 1) THEN
               IF (date_from_ > min_date_) THEN
                  Error_SYS.Record_General(lu_name_, 'NO_INS_PER2: The start date is within the date range for another accounting period');               
               END IF;
            END IF;
         END;
      END IF;
   END;
END Check_Period_Dates;


PROCEDURE Get_Max_Period_Date (
   max_date_     OUT DATE,
   company_   IN     VARCHAR2 )
IS
   CURSOR max_date_until IS
      SELECT max(date_until)
      FROM   accounting_period_tab
      WHERE  company = company_;
BEGIN
   OPEN  max_date_until;
   FETCH max_date_until INTO max_date_;
   CLOSE max_date_until;
END Get_Max_Period_Date;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Period_Description (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   cal_year_          IN NUMBER DEFAULT NULL,
   cal_month_         IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
IS
   desc_  accounting_period.description%TYPE;
   CURSOR get_desc IS
      SELECT description
      FROM   accounting_period
      WHERE  company           = company_
      AND    accounting_year   = accounting_year_
      AND    accounting_period = accounting_period_;

   CURSOR get_cal IS
      SELECT description
      FROM   accounting_period
      WHERE  company   = company_
      AND    cal_year  = cal_year_
      AND    cal_month = cal_month_;
BEGIN
   IF (cal_year_ IS NULL OR cal_month_ IS NULL) THEN
      OPEN  get_desc;
      FETCH get_desc INTO desc_;
      CLOSE get_desc;
   ELSE
      OPEN  get_cal;
      FETCH get_cal INTO desc_;
      CLOSE get_cal;
   END IF;
   RETURN desc_;
END Get_Period_Description;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Period_Status (
   period_status_     OUT VARCHAR2,
   company_           IN     VARCHAR2,
   accounting_year_   IN     NUMBER,
   accounting_period_ IN     NUMBER )
IS
BEGIN
   period_status_ := Acc_Period_Ledger_Info_API.Get_Period_Status_Db(company_, 
                                                                     accounting_year_, 
                                                                     accounting_period_,
                                                                     '00');
END Get_Period_Status;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Period_Open (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER ) RETURN VARCHAR2
IS   
BEGIN
   RETURN Acc_period_ledger_Info_API.Is_Period_Open(company_, accounting_year_, accounting_period_, '00');
END Is_Period_Open;

/*
This method donot check company access as it is checked sperately. because calling places uses this method repeatedly 
and company check is only done once before calling this method.
*/
@UncheckedAccess
FUNCTION get_max_period_no_sec (   
   company_         IN     VARCHAR2,
   accounting_year_ IN     NUMBER ) RETURN NUMBER
IS   
BEGIN
   RETURN get_max_period___(company_, accounting_year_);
END get_max_period_no_sec;


@UncheckedAccess
PROCEDURE Get_Accounting_Year (
   accounting_year_    OUT NUMBER,
   accounting_period_  OUT NUMBER,
   company_            IN  VARCHAR2,
   date_in_            IN  DATE )
IS   
   year_               NUMBER;
   period_             NUMBER;   
BEGIN
   Get_Period_Info___(year_, period_, company_, date_in_);
   IF ((year_ IS NULL) OR (period_ IS NULL)) THEN
      Error_SYS.Record_General(lu_name_,
                               'NOYEAR1: No Period exists for the date :P1 in company :P2',
                               date_in_,
                               company_);
   END IF;
   accounting_year_   := year_;
   accounting_period_ := period_;
END Get_Accounting_Year;


PROCEDURE Get_Accounting_Year (
   accounting_year_       OUT NUMBER,
   accounting_period_     OUT NUMBER,
   company_               IN  VARCHAR2,
   date_in_               IN  DATE,
   user_group_            IN  VARCHAR2,
   ledger_id_             IN VARCHAR2 DEFAULT NULL)
IS
   year_end_period_     VARCHAR2(10);
   date_param_          DATE;

   CURSOR get_accounting_year IS
      SELECT  accounting_year, accounting_period, year_end_period
        FROM  accounting_period_tab
       WHERE  company          = company_
         AND  date_from       <= date_param_
         AND  date_until      >= date_param_
         AND  year_end_period LIKE year_end_period_
         ORDER BY accounting_period ASC;
         
   CURSOR get_yearend_accounting_year IS
      SELECT  p.accounting_year, p.accounting_period
        FROM  accounting_period_tab p, acc_period_ledger_info_tab l
        WHERE  p.company          = l.company
        AND    p.accounting_year = l.accounting_year
        AND    p.accounting_period = l.accounting_period
         AND   p.company          = company_
         AND  date_from       <= date_param_
         AND  date_until      >= date_param_
         AND  year_end_period = 'YEARCLOSE'
         AND ledger_id = NVL(ledger_id_, '00')
         AND  l.period_status = 'O'
         ORDER BY p.accounting_period ASC;
BEGIN
   IF (User_Group_Finance_API.Get_Allowed_Acc_Period(company_,user_group_) = '1') THEN
      year_end_period_ := 'ORDINARY';
   ELSE
      year_end_period_ := 'YEAR%';
   END IF;
   date_param_ := TRUNC(date_in_);
   OPEN  get_accounting_year;
   FETCH get_accounting_year INTO accounting_year_, accounting_period_, year_end_period_;
   CLOSE get_accounting_year;
   IF (year_end_period_ = 'YEARCLOSE') THEN
      OPEN  get_yearend_accounting_year;
      FETCH get_yearend_accounting_year INTO accounting_year_, accounting_period_;
      CLOSE get_yearend_accounting_year;       
   END IF;
   IF (year_end_period_ = 'YEAROPEN') THEN
      Error_SYS.Record_General(lu_name_,
                               'YEAROPEN: Not allow to use year open period.',
                               date_in_,
                               company_ );
   END IF;
   IF ((accounting_year_ IS NULL ) OR ( accounting_period_ IS NULL)) THEN
      Error_SYS.Record_General(lu_name_,
                               'NOYEAR1: No Period exists for the date :P1 in company :P2',
                               date_in_,
                               company_ );
   END IF;
END Get_Accounting_Year;


--Purpose : to get the Year information regardless of the period type( ordinary or year end)
@UncheckedAccess
FUNCTION Get_Accounting_Year (
   company_          IN VARCHAR2,
   actual_date_      IN DATE ) RETURN NUMBER
IS   
   year_             NUMBER;
   period_           NUMBER; -- dummy   
BEGIN
   Get_Period_Info___(year_, period_, company_, actual_date_);
   RETURN year_;
END Get_Accounting_Year;


--Purpose : to get the Accounting Year information regardless of the period type( ordinary or year end)
@UncheckedAccess
FUNCTION Get_Accounting_Period (
   company_          IN VARCHAR2,
   actual_date_      IN DATE ) RETURN NUMBER
IS
   year_             NUMBER; -- dummy
   period_           NUMBER;   
BEGIN
   Get_Period_Info___(year_, period_, company_, actual_date_);
   RETURN period_;
END Get_Accounting_Period;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Period_Delete_Allowed (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER )
IS
   --
   dummy_               VARCHAR2(1);
   --
   CURSOR period_after IS
      SELECT  'Y'
      FROM    accounting_period_tab
      WHERE   company = company_
      AND   ((accounting_year > accounting_year_)
             OR (accounting_year = accounting_year_ AND accounting_period > accounting_period_));
   CURSOR period_before IS
      SELECT  'Y'
      FROM    accounting_period_tab
      WHERE   company = company_
      AND   ((accounting_year < accounting_year_)
             OR (accounting_year = accounting_year_ AND accounting_period < accounting_period_));
BEGIN
   OPEN  period_before;
   FETCH period_before INTO dummy_;
   OPEN  period_after;
   FETCH period_after INTO dummy_;
   IF (period_after%FOUND AND period_before%FOUND) THEN
      CLOSE period_after;
      CLOSE period_before;      
      Error_SYS.Record_General(lu_name_, 'NO_DEL: It is not allowed to delete a period :P1 in the middle of a date range', accounting_period_);
   ELSE
      CLOSE period_after;
      CLOSE period_before;
   END IF;
END Period_Delete_Allowed;



@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Firstdate_Nextopenperiod (
   acc_period_out_     OUT NUMBER,
   acc_year_out_       OUT NUMBER,
   date_first_         OUT DATE,
   company_         IN     VARCHAR2,
   accounting_year_ IN     NUMBER,
   user_group_      IN     VARCHAR2,
   period_start_    IN     NUMBER,
   ledger_id_       IN     VARCHAR2 DEFAULT '00')
IS
   CURSOR acc_period IS
      SELECT  date_from , accounting_year, accounting_period
      FROM    accounting_period_tab
      WHERE   company = company_
      AND   ( accounting_year * 100 ) + accounting_period  >=
            ( accounting_year_ * 100) + period_start_
      ORDER BY accounting_year, accounting_period ;
   --
BEGIN
   date_first_     := NULL ;
   acc_period_out_ := 0 ;
   acc_year_out_   := 0;
   FOR ap_cur IN acc_period  LOOP
      IF (User_Group_Period_API.Is_Period_Open_GL_IL(company_, ap_cur.accounting_year, ap_cur.accounting_period, user_group_,ledger_id_) = 'TRUE') THEN
         date_first_     := ap_cur.date_from ;
         acc_period_out_ := ap_cur.accounting_period ;
         acc_year_out_   := ap_cur.accounting_year ;
         EXIT WHEN (TRUE);
         -- BREAK --
      END IF;
   END LOOP;
END Get_Firstdate_Nextopenperiod;

--Purpose : check whether there are any periods for the given year
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_Accounting_Year (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER )
IS   
   year_     VARCHAR2(5);
BEGIN
   Year_Exist(year_, company_, accounting_year_);   
   IF (year_ = 'FALSE') THEN
      Error_SYS.Record_General(lu_name_, 'NOYEAR2: Accounting Year :P1 does not exist.', accounting_year_);
   END IF;
END Check_Accounting_Year;


PROCEDURE Conv_Period (
   accounting_year_        OUT NUMBER,
   accounting_period_      OUT NUMBER,
   company_             IN     VARCHAR2,
   period_              IN     NUMBER )
IS
   new_period_          NUMBER;
   new_year_            NUMBER;
BEGIN
   new_period_        := substr(period_, 3, 4);
   accounting_period_ := new_period_;
   new_year_          := substr(period_, 1, 2);
   IF (new_year_ > 0) THEN
      accounting_year_ := 19||new_year_;
   ELSE
      accounting_year_ := 20||new_year_;
   END IF;
END Conv_Period;

--Purpose : to get the maximum and minimum accounting_period information
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Min_Max_Period (
   min_period_         OUT NUMBER,
   max_period_         OUT NUMBER,
   company_         IN     VARCHAR2,
   accounting_year_ IN     NUMBER )
IS
   CURSOR getminmaxperiod IS
      SELECT MIN(accounting_period), MAX(accounting_period)
      FROM   accounting_period_tab
      WHERE  company       = company_
      AND  accounting_year = accounting_year_;   
BEGIN
   OPEN   getminmaxperiod;
   FETCH  getminmaxperiod INTO min_period_, max_period_;
   CLOSE  getminmaxperiod;      
END Get_Min_Max_Period;


@SecurityCheck Company.UserAuthorized(company_)
@UncheckedAccess
PROCEDURE Get_Period_Date (
   date_from_            OUT DATE,
   date_until_           OUT DATE,
   company_           IN     VARCHAR2,
   accounting_year_   IN     NUMBER,
   accounting_period_ IN     NUMBER )
IS
   acc_rec_       accounting_period_tab%ROWTYPE;
  
BEGIN
   acc_rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_);
   date_from_ := acc_rec_.date_from;
   date_until_ := acc_rec_.date_until;  
END Get_Period_Date;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Next_Period (
   next_alloc_period_     OUT NUMBER,
   next_alloc_year_       OUT NUMBER,
   company_            IN     VARCHAR2,
   current_period_     IN     NUMBER,
   current_year_       IN     NUMBER )
IS
BEGIN
   Acc_Period_Ledger_Info_API.Get_Next_Period(next_alloc_period_,
                                              next_alloc_year_,
                                              company_,
                                              current_period_,
                                              current_year_,
                                              '00');
END Get_Next_Period;

-- Get_Max_Period
--   Get the maximum accounting_period information
@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Max_Period (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN NUMBER
IS   
BEGIN
   RETURN Get_Max_Period___(company_, accounting_year_);
END Get_Max_Period;


--Purpose : to get the minimum accounting_period information
@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Min_Period (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN NUMBER
IS   
BEGIN
   RETURN Get_Min_Period___(company_, accounting_year_);
END Get_Min_Period;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Year_Exist (
   exist_year_       IN OUT VARCHAR2,
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER )
IS
   CURSOR check_year IS
      SELECT 1
      FROM   accounting_period_tab
      WHERE  company       = company_
      AND  accounting_year = accounting_year_;
   exist_ NUMBER;
BEGIN
   OPEN  check_year ;
   FETCH check_year INTO exist_ ;
   IF (check_year%NOTFOUND) THEN      
      exist_year_ := 'FALSE';
   ELSE      
      exist_year_ := 'TRUE';
   END IF;
   CLOSE check_year ;
END Year_Exist;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Previous_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_         IN VARCHAR2,
   current_period_  IN NUMBER,
   current_year_    IN NUMBER )
IS
   period_status_    VARCHAR2(1);
BEGIN
   period_status_  := 'O';
   Get_Previous_Period (previous_period_,
                        previous_year_,
                        company_,
                        current_period_,
                        current_year_,
                        period_status_);
END Get_Previous_Period;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Previous_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_         IN VARCHAR2,
   current_period_  IN NUMBER,
   current_year_    IN NUMBER,
   period_status_   IN VARCHAR2)
IS
BEGIN
   Acc_Period_Ledger_Info_API.Get_Previous_Period(previous_period_,
                                                  previous_year_,
                                                  company_,
                                                  current_period_,
                                                  current_year_,
                                                  '00',
                                                  period_status_);
END Get_Previous_Period;



PROCEDURE Get_Year_End_Period (
   accounting_period_ OUT NUMBER,
   period_des_        OUT VARCHAR2,
   valid_until_       OUT DATE,
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   period_status_     IN VARCHAR2 DEFAULT 'O' )
IS
   period_rec_       Accounting_Period_API.public_rec;
BEGIN   
   IF (period_status_ = 'NONE') THEN
      accounting_period_ := Get_Max_Year_End_Period(company_, accounting_year_);
      IF (accounting_period_ IS NOT NULL ) THEN
         period_rec_ := Get(company_, accounting_year_, accounting_period_);
         period_des_ := period_rec_.description;
         valid_until_ := period_rec_.date_until;
      END IF;
   ELSE      
      Acc_Period_Ledger_Info_API.Get_Year_End_Period(accounting_period_,period_des_, valid_until_, company_,accounting_year_, '00', period_status_);
   END IF;
END Get_Year_End_Period;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_All_Periods (
   period_tab_          OUT Accounting_Period_API.PeriodTab,
   num_of_period_       OUT NUMBER,
   company_             IN  VARCHAR2,
   accounting_year_     IN  NUMBER ,
   ledger_id_           IN  VARCHAR2)
IS
   CURSOR Get_period IS
      SELECT   accounting_period
      FROM     accounting_period_tab apl
      WHERE    company             = company_
      AND      accounting_year     = accounting_year_;
      
   row_      NUMBER := 1;
BEGIN
   OPEN get_period;
   LOOP
      FETCH get_period INTO period_tab_(row_);
      EXIT WHEN get_period%NOTFOUND;
      row_ := row_ + 1;
   END LOOP;
   CLOSE get_period;
   num_of_period_ := row_ - 1;
END Get_All_Periods;


@UncheckedAccess
FUNCTION Is_Year_End_Period (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER ) RETURN BOOLEAN
IS
   CURSOR year_end_period_data IS
      SELECT 1
      FROM accounting_period_tab
      WHERE company           = company_
      AND   accounting_year   = accounting_year_
      AND   accounting_period = accounting_period_
      AND   year_end_period IN ('YEAROPEN','YEARCLOSE');

   dummy_                NUMBER;
BEGIN
   OPEN year_end_period_data;
   FETCH year_end_period_data INTO dummy_;
   IF (year_end_period_data%FOUND) THEN
      CLOSE year_end_period_data;
      RETURN TRUE;
   END IF;
   CLOSE year_end_period_data;
   RETURN FALSE;
END Is_Year_End_Period;

--Purpose : to get All ORDIINARY period belonging to the accounting year.
@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Get_All_Ordinary_Periods (
   period_tab_         OUT PeriodTab,
   num_of_period_      OUT NUMBER,
   company_            IN  VARCHAR2,
   accounting_year_    IN  NUMBER )
IS
   CURSOR Get_period IS
      SELECT accounting_period
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    year_end_period = 'ORDINARY';
   row_      NUMBER := 1;
BEGIN
   OPEN get_period;
   LOOP
      FETCH get_period INTO period_tab_(row_);
      EXIT WHEN get_period%NOTFOUND;
      row_ := row_ + 1;
   END LOOP;
   CLOSE get_period;
   num_of_period_ := row_ - 1;
END Get_All_Ordinary_Periods;

 
@UncheckedAccess
FUNCTION Get_Voucher_Period (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   voucher_type_    IN VARCHAR2 ) RETURN NUMBER
IS  
   accounting_period_ Accounting_Period_Tab.accounting_period%TYPE;
BEGIN
   -- Since voucher can be updated to GENLED
   -- First do accrul
   -- Then GENLED - since ACCRUL/Application can be installed/exist
   -- without GENLED , do dynamic calling
   accounting_period_ := Voucher_API.Get_Accounting_Period(company_, accounting_year_, voucher_type_, voucher_no_);
   IF (accounting_period_ IS NOT NULL) THEN
      RETURN accounting_period_;
   END IF;
   -- Then check for GENLED
   $IF Component_Genled_SYS.INSTALLED $THEN   
      accounting_period_ := Gen_Led_Voucher_API.Get_Accounting_Period(company_, voucher_type_, accounting_year_, voucher_no_);
      IF (accounting_period_ IS NOT NULL) THEN
         RETURN accounting_period_;
      END IF;      
      accounting_period_ := Gen_Led_Arch_Voucher_API.Get_Accounting_Period(company_, voucher_type_, accounting_year_, voucher_no_);
   $END   
   RETURN accounting_period_;
END Get_Voucher_Period;



@UncheckedAccess
PROCEDURE Get_Ordinary_Accounting_Year (
   accounting_year_   OUT NUMBER,
   accounting_period_ OUT NUMBER,
   company_           IN  VARCHAR2,
   date_in_           IN  DATE )
IS
   date_param_     DATE;   
BEGIN
   date_param_ := TRUNC(date_in_);
   Get_Ordinary_Period_Info___(accounting_year_, accounting_period_, company_, date_param_);   
END Get_Ordinary_Accounting_Year;


--Purpose : Public methods to get ORDIINARY year belonging to the given date.
@UncheckedAccess
FUNCTION Get_Ordinary_Accounting_year (
   company_        IN  VARCHAR2,
   date_in_        IN  DATE ) RETURN NUMBER
IS
   accounting_year_     NUMBER;
   accounting_period_   NUMBER;
BEGIN
   Get_Ordinary_Period_Info___(accounting_year_, accounting_period_, company_, date_in_);
   RETURN accounting_year_;
END Get_Ordinary_Accounting_year;


--Purpose : Public methods to get ORDIINARY period belonging to the given date.
@UncheckedAccess
FUNCTION Get_Ordinary_Accounting_period (
   company_        IN  VARCHAR2,
   date_in_        IN  DATE ) RETURN NUMBER
IS
   accounting_year_     NUMBER;
   accounting_period_   NUMBER;
BEGIN
   Get_Ordinary_Period_Info___(accounting_year_, accounting_period_, company_, date_in_);
   RETURN accounting_period_;
END Get_Ordinary_Accounting_period;


PROCEDURE Get_Opening_Period (
   period_desc_           OUT VARCHAR2,
   valid_until_           OUT DATE,
   accounting_period_     OUT NUMBER,
   company_               IN  VARCHAR2,
   accounting_year_       IN  NUMBER,
   exclude_period_status_ IN  VARCHAR2 DEFAULT NULL )
IS
BEGIN
   Get_Opening_Period__(period_desc_,
                        valid_until_,
                        accounting_period_,
                        company_,
                        accounting_year_,
                        exclude_period_status_);
END Get_Opening_Period;

@UncheckedAccess
FUNCTION Get_Accounting_Period_Ext (
   company_      IN VARCHAR2,
   user_group_   IN VARCHAR2,
   voucher_date_ IN DATE,
   ledger_id_    IN VARCHAR2 DEFAULT '00') RETURN NUMBER
IS
   vou_year_        NUMBER;
   period_          NUMBER;
   vou_period_      NUMBER;
   date_until_      DATE;
   date_from_       DATE;
   
   CURSOR year_end_period_data(year_end_period_ IN VARCHAR2) IS
      SELECT ap.accounting_period,ap.date_until, ap.date_from
      FROM   accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE  apl.company             = ap.company
      AND    apl.accounting_year     = ap.accounting_year
      AND    apl.accounting_period   = ap.accounting_period
      AND    apl.ledger_id           = ledger_id_
      AND    apl.company             = company_
      AND    apl.accounting_year     = vou_year_
      AND    ap.year_end_period      = year_end_period_
      AND    apl.period_status       = 'O';     
   
BEGIN
   vou_period_ := NULL; 
   Get_Ordinary_Period_Info___(vou_year_, vou_period_, company_, voucher_date_);  

   IF (User_Group_Finance_API.Get_Allowed_Acc_Period(company_, user_group_) = '2') THEN
      OPEN year_end_period_data('YEARCLOSE');
      FETCH year_end_period_data INTO period_,date_until_, date_from_;
      CLOSE year_end_period_data;
     
      -- if the date_until_ and date_from_ equals to voucher_date then YE period.
      IF ((voucher_date_ = date_until_) AND (voucher_date_ = date_from_) ) THEN
         RETURN period_;
      ELSE         
         OPEN year_end_period_data('YEAROPEN');
         FETCH year_end_period_data INTO period_,date_until_, date_from_;
         CLOSE year_end_period_data;      
         -- if the date_until_ and date_from_ equals to voucher_date then Year opening period.
         IF ((voucher_date_ = date_until_) AND (voucher_date_ = date_from_) ) THEN
            RETURN period_;
         ELSE
            RETURN vou_period_;
         END IF;
      END IF;
   ELSE
      RETURN vou_period_;
   END IF;
END Get_Accounting_Period_Ext;


PROCEDURE Get_Accounting_Year_Period_Ext (
   accounting_year_   OUT NUMBER,
   accounting_period_ OUT NUMBER,
   company_           IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   voucher_date_      IN  DATE )
IS
   vou_year_        NUMBER;
   period_          NUMBER;
   vou_period_      NUMBER;
   description_     VARCHAR2(100);
   date_until_      DATE;
   date_from_       DATE;
BEGIN
   vou_period_ := NULL;
   Get_Ordinary_Period_Info___(vou_year_,vou_period_,company_ ,voucher_date_);
   IF (User_Group_Finance_API.Get_Allowed_Acc_Period(company_,user_group_) = '2') THEN
      Get_Year_End_Period(period_, description_, date_until_, company_, vou_year_);
      date_from_ := Get_Date_From(company_ ,vou_year_, period_);
      -- if the date_until_ and date_from_ equals to voucher_date then YE period.
      IF ((voucher_date_ = date_until_) AND (voucher_date_ = date_from_) ) THEN
         accounting_period_ := period_;
      ELSE
         Get_Opening_Period(description_,date_until_,period_,company_,vou_year_);
         date_from_ := Get_Date_From(company_ ,vou_year_, period_);
         -- if the date_until_ and date_from_ equals to voucher_date then Year opening period.
         IF ((voucher_date_ = date_until_) AND (voucher_date_ = date_from_) ) THEN
            accounting_period_ := period_;
         ELSE
            accounting_period_ := vou_period_;
         END IF;
      END IF;
   ELSE
      accounting_period_ := vou_period_;
   END IF;
   IF ((vou_year_ IS NULL ) OR ( accounting_period_ IS NULL)) THEN
      Error_SYS.Record_General(lu_name_,
                               'NOYEAR1: No Period exists for the date :P1 in company :P2',
                               voucher_date_,
                               company_ );
   END IF;
   accounting_year_   := vou_year_;
END Get_Accounting_Year_Period_Ext;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Previous_Allowed_Period (
   prev_allowed_period_ OUT NUMBER,
   prev_allowed_year_   OUT NUMBER,
   company_             IN VARCHAR2,
   current_period_      IN NUMBER,
   current_year_        IN NUMBER )
IS  
BEGIN
   Acc_Period_Ledger_Info_API.Get_Previous_Allowed_Period(prev_allowed_period_,
                                                          prev_allowed_year_,
                                                          company_,
                                                          current_period_,
                                                          current_year_,
                                                          '00');
   
END Get_Previous_Allowed_Period;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Period_Allowed (
   company_ IN VARCHAR2,
   period_  IN NUMBER,
   year_    IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN Acc_Period_Ledger_Info_API.Is_Period_Allowed(company_,
                                                       period_,
                                                       year_,
                                                       '00');
END Is_Period_Allowed;


@UncheckedAccess
FUNCTION Is_Year_Close (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER ) RETURN VARCHAR2
IS
   CURSOR year_end_period_data IS
      SELECT 1
      FROM accounting_period_tab
      WHERE company           = company_
      AND   accounting_year   = accounting_year_
      AND   accounting_period = accounting_period_
      AND   year_end_period   = 'YEARCLOSE';

   dummy_                NUMBER;
BEGIN
   OPEN  year_end_period_data;
   FETCH year_end_period_data INTO dummy_;
   IF (year_end_period_data%FOUND) THEN
      CLOSE year_end_period_data;
      RETURN 'TRUE';
   END IF;
   CLOSE year_end_period_data;
   RETURN 'FALSE';
END Is_Year_Close;


@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Get_Next_Vou_Period (
   next_period_    IN OUT NUMBER,
   next_year_      IN OUT NUMBER,
   company_        IN VARCHAR2,
   current_period_ IN NUMBER,
   current_year_   IN NUMBER )
IS
   CURSOR next_acc_period IS
      SELECT  accounting_year, accounting_period
      FROM    accounting_period_tab
      WHERE   company = company_
      AND   (accounting_year * 100) + accounting_period  >
            (current_year_ * 100) + current_period_
      AND year_end_period != 'YEAROPEN'
      ORDER BY accounting_year, accounting_period ;

   CURSOR max_ordinary_period IS
      SELECT MAX(accounting_period)
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = current_year_
      AND    year_end_period = 'ORDINARY';
      
   CURSOR cnt_yc_open IS
      SELECT 1
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = current_year_
      AND    year_end_period = 'YEARCLOSE';      

   max_period_           NUMBER;
   max_ordinary_period_  NUMBER;
   cnt_year_close_open_  NUMBER;
BEGIN
   max_period_ := Get_Max_Period___(company_, current_year_);

   OPEN  max_ordinary_period;
   FETCH max_ordinary_period INTO max_ordinary_period_;
   CLOSE max_ordinary_period;

   IF (max_ordinary_period_ = current_period_) THEN
      IF( max_period_ = current_period_) THEN
         next_year_   := NULL;
         next_period_ := NULL;
      ELSE
         OPEN  cnt_yc_open;
         FETCH cnt_yc_open INTO cnt_year_close_open_;
         IF (cnt_yc_open%NOTFOUND) THEN
            CLOSE cnt_yc_open;
            next_year_   := NULL;
            next_period_ := NULL;
         ELSE
            CLOSE cnt_yc_open;
            OPEN  next_acc_period;
            FETCH next_acc_period INTO next_year_, next_period_;
            CLOSE next_acc_period;
         END IF;
      END IF;
   ELSE          
      OPEN  next_acc_period;
      FETCH next_acc_period INTO next_year_, next_period_;
      CLOSE next_acc_period;
   END IF;
END Get_Next_Vou_Period;


PROCEDURE Get_Yearper_For_Yearend_User (
   year_           OUT NUMBER,
   period_         OUT NUMBER,
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   voucher_date_    IN DATE )
IS
   vou_year_        NUMBER;
   vou_period_      NUMBER;
   description_     VARCHAR2(100);
   date_until_      DATE;
BEGIN
   IF (User_Group_Finance_API.Get_Allowed_Acc_Period(company_,user_group_) = '2') THEN
      Get_Period_Info___(vou_year_,vou_period_, company_, voucher_date_ );
      Get_Year_End_Period(period_, description_, date_until_, company_, vou_year_);
      IF (period_ IS NOT NULL) THEN
         year_ := vou_year_;
      END IF;
      IF (date_until_ != voucher_date_) OR (date_until_ IS NULL) THEN
         Error_SYS.Record_General(lu_name_, 'USERGRPDATEERROR: User Group :P1 is not valid for Voucher Date :P2', user_group_, voucher_date_ );
      END IF;
   ELSE
      year_ := 0;
      period_ := 0;
   END IF;
END Get_Yearper_For_Yearend_User;


PROCEDURE Get_Acc_Year_Period_User_Group (
   year_           OUT NUMBER,
   period_         OUT NUMBER,
   company_         IN VARCHAR2,
   user_group_      IN VARCHAR2,
   voucher_date_    IN DATE,
   check_period_status_ IN VARCHAR2 DEFAULT 'TRUE'  )
IS
   vou_year_        NUMBER;
   vou_period_      NUMBER;
   description_     VARCHAR2(100);
   date_until_      DATE;
   status_          VARCHAR2(5):= NULL;
BEGIN
   Get_Period_Info___(vou_year_,vou_period_, company_, voucher_date_);
   IF (User_Group_Finance_API.Get_Allowed_Acc_Period(company_,user_group_) = '2') THEN      
      IF (check_period_status_ = 'FALSE') THEN
         status_ := 'NONE';
      END IF;
      Get_Year_End_Period(period_, description_, date_until_, company_, vou_year_, status_);

      IF (period_ IS NOT NULL) THEN
         year_ := vou_year_;
      ELSE
         Error_SYS.Record_General(lu_name_,
                                  'NOYEARENDP: No Year-End Period exists for the date :P1 in company :P2',
                                  voucher_date_,
                                  company_);
      END IF;
   ELSE
      year_   := vou_year_;
      period_ := vou_period_;
   END IF;
END Get_Acc_Year_Period_User_Group;


@UncheckedAccess
FUNCTION Get_First_Normal_Period (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN NUMBER
IS
   CURSOR get_first_normal IS
      SELECT accounting_period
        FROM accounting_period_tab
       WHERE company         = company_
         AND accounting_year = accounting_year_
         AND year_end_period = 'ORDINARY'
       ORDER BY accounting_period ASC;
   acc_period_  NUMBER;
BEGIN
   OPEN get_first_normal;
   FETCH get_first_normal INTO acc_period_;
   IF (get_first_normal%FOUND) THEN
      CLOSE get_first_normal;
      RETURN acc_period_;
   END IF;
   CLOSE get_first_normal;
   RETURN -1;
END Get_First_Normal_Period;


@UncheckedAccess
FUNCTION Get_Last_Normal_Period (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN NUMBER
IS
   CURSOR get_first_normal IS
      SELECT accounting_period
        FROM accounting_period_tab
       WHERE company         = company_
         AND accounting_year = accounting_year_
         AND year_end_period = 'ORDINARY'
       ORDER BY accounting_period DESC;
   acc_period_  NUMBER;
BEGIN
   OPEN get_first_normal;
   FETCH get_first_normal INTO acc_period_;
   IF (get_first_normal%FOUND) THEN
      CLOSE get_first_normal;
      RETURN acc_period_;
   END IF;
   CLOSE get_first_normal;
   RETURN -1;
END Get_Last_Normal_Period;

@UncheckedAccess
FUNCTION Get_Max_Year_End_Period (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN NUMBER
IS
   CURSOR get_max_acc_period IS
      SELECT max(accounting_period)
        FROM accounting_period_tab
       WHERE company         = company_
         AND accounting_year = accounting_year_
         AND year_end_period = 'YEARCLOSE';
         
   acc_period_  NUMBER;
BEGIN
   OPEN get_max_acc_period;
   FETCH get_max_acc_period INTO acc_period_;
   CLOSE get_max_acc_period;
   RETURN acc_period_;
END Get_Max_Year_End_Period;

@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Get_Prev_Ordinary_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_             IN VARCHAR2,
   current_period_      IN NUMBER,
   current_year_        IN NUMBER,
   status_check_        IN VARCHAR2 DEFAULT NULL,
   no_of_periods_       IN NUMBER   DEFAULT NULL )
IS
BEGIN
   Acc_Period_Ledger_Info_API.Get_Prev_Ordinary_Period(previous_period_,
                                                       previous_year_,
                                                       company_,
                                                       current_period_,
                                                       current_year_,
                                                       '00',
                                                       status_check_ ,
                                                       no_of_periods_);
END Get_Prev_Ordinary_Period;


@UncheckedAccess
FUNCTION Period_Finally_Closed_Exist (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN   
   RETURN Acc_Period_Ledger_Info_API.Period_Finally_Closed_Exist(company_,
                                                                 accounting_year_,
                                                                 '00');
END Period_Finally_Closed_Exist;


--Purpose : to get the No of ordinary Period for a given year period range 
@UncheckedAccess
FUNCTION Get_Number_Of_Allowed_Periods (
   company_            IN VARCHAR2,
   first_acc_period_   IN NUMBER,
   first_acc_year_     IN NUMBER,
   last_acc_period_    IN NUMBER,
   last_acc_year_      IN NUMBER) RETURN NUMBER
IS
   no_of_periods_      NUMBER;

   CURSOR get_num_of_periods IS
      SELECT COUNT(accounting_period)
      FROM   accounting_period_tab
      WHERE  ((accounting_year*100+accounting_period) >= (first_acc_year_*100+first_acc_period_))
      AND    ((accounting_year*100+accounting_period) <= (last_acc_year_*100+last_acc_period_))
      AND    company = company_
      AND    year_end_period = 'ORDINARY';
BEGIN
   OPEN  get_num_of_periods;
   FETCH get_num_of_periods INTO no_of_periods_;
   CLOSE get_num_of_periods;   
   RETURN no_of_periods_;
END Get_Number_Of_Allowed_Periods;


@UncheckedAccess
FUNCTION Get_Period_Desc(
   period_  IN NUMBER,
   year_    IN NUMBER,
   month_   IN NUMBER ) RETURN VARCHAR2
IS
   desc_ VARCHAR2(100);
BEGIN
   IF period_ = 0 THEN
      desc_ := 'Year Opening Period '||year_;
   ELSIF month_ = 1 THEN
      desc_ := 'January '||year_;
   ELSIF month_ = 2 THEN
      desc_ := 'February '||year_;
   ELSIF month_ = 3 THEN
      desc_ := 'March '||year_;
   ELSIF month_ = 4 THEN
      desc_ := 'April '||year_;
   ELSIF month_ = 5 THEN
      desc_ := 'May '||year_;
   ELSIF month_ = 6 THEN
      desc_ := 'June '||year_;
   ELSIF month_ = 7 THEN
      desc_ := 'July '||year_;
   ELSIF month_ = 8 THEN
      desc_ := 'August '||year_;
   ELSIF month_ = 9 THEN
      desc_ := 'September '||year_;
   ELSIF month_ = 10 THEN
      desc_ := 'October '||year_;
   ELSIF month_ = 11 THEN
      desc_ := 'November '||year_;
   ELSIF month_ = 12 THEN
      desc_ := 'December '||year_;
   END IF;
   RETURN desc_;
END Get_Period_Desc;

PROCEDURE Do_Final_Check (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER )
IS
   previous_date_until_       DATE;
   previous_year_end_period_  accounting_period_tab.year_end_period%TYPE;
   is_year_end_               VARCHAR2(5);  
   
   CURSOR accper_data IS
      SELECT date_from, date_until, year_end_period, accounting_period, accounting_year 
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      ORDER BY  accounting_period;
      
   date_from_  DATE;
   no_seq_order   EXCEPTION;
BEGIN
   FOR get_rec IN accper_data LOOP
      Check_Period_Dates_New__(company_, get_rec.accounting_period, get_rec.date_from, get_rec.accounting_year, get_rec.year_end_period);
      Check_Period_Dates_New__(company_, get_rec.accounting_period, get_rec.date_until, get_rec.accounting_year, get_rec.year_end_period);
      is_year_end_ := Is_Year_Close(company_, accounting_year_, get_rec.accounting_period + 1);      

      IF (is_year_end_ = 'FALSE') THEN
         Check_Whole_Period__(company_, get_rec.date_from, get_rec.date_until);
      END IF;

      -- in table period_type stores as year_end_period
      IF (previous_year_end_period_ IS NOT NULL AND previous_date_until_ IS NOT NULL) THEN
         IF (previous_year_end_period_ = 'YEAROPEN' AND get_rec.year_end_period = 'ORDINARY') THEN
            -- condition1 applies to the ORDINARY period type , but raise the same error msg
            IF NOT (previous_date_until_ = get_rec.date_from) THEN
               date_from_ := get_rec.date_from;
               RAISE no_seq_order;               
            END IF;
         ELSIF (previous_year_end_period_ = 'ORDINARY' AND get_rec.year_end_period = 'ORDINARY') THEN
            -- condition1 applies to the ORDINARY period type , but raise the same error msg 
            IF NOT (previous_date_until_ + 1 = get_rec.date_from) THEN
               date_from_ := get_rec.date_from;
               RAISE no_seq_order;               
            END IF;
         END IF;
      END IF;
      previous_date_until_      := get_rec.date_until;
      previous_year_end_period_ := get_rec.year_end_period;
   END LOOP;
EXCEPTION
   WHEN no_seq_order THEN
      Error_SYS.Record_General(lu_name_, 'INVDATE1: Date :P1 and :P2 not in sequential order', previous_date_until_, date_from_);
END Do_Final_Check;

--Purpose : to get the next period information for the ORDINARY PERIODS
@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Get_Next_Allowed_Period (
   next_allow_period_ OUT NUMBER,
   next_allow_year_   OUT NUMBER,
   company_           IN  VARCHAR2,
   current_period_    IN  NUMBER,
   current_year_      IN  NUMBER )
IS
   CURSOR next_acc_period IS
      SELECT   accounting_year, accounting_period
      FROM     accounting_period_tab
      WHERE    company             = company_
      AND      (accounting_year * 100) + accounting_period  >
               (  current_year_ * 100) + current_period_
      AND      year_end_period = 'ORDINARY'
      ORDER BY accounting_year, accounting_period ;
BEGIN
   OPEN  next_acc_period;
   FETCH next_acc_period INTO next_allow_year_ , next_allow_period_  ;
   CLOSE next_acc_period;
END Get_Next_Allowed_Period;


--Purpose : to get the next period information regardless of the period type or period status
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Next_Any_Period (
   next_period_    OUT NUMBER,
   next_year_      OUT NUMBER,
   company_        IN  VARCHAR2,
   current_period_ IN  NUMBER,
   current_year_   IN  NUMBER )
IS
   CURSOR next_acc_period IS
      SELECT accounting_year, accounting_period
      FROM   accounting_period_tab
      WHERE  company    = company_
      AND   (accounting_year * 100) + accounting_period  >
            (  current_year_ * 100) + current_period_
      ORDER BY accounting_year, accounting_period ;
BEGIN
   OPEN  next_acc_period;
   FETCH next_acc_period INTO next_year_, next_period_;
   CLOSE next_acc_period;
END Get_Next_Any_Period;


@UncheckedAccess
FUNCTION Get_Period_Incr (
  company_            IN     VARCHAR2,
  year_period_key_    IN     VARCHAR2,
  include_year_end_   IN     VARCHAR2,
  increment_          IN     PLS_INTEGER ) RETURN VARCHAR2
IS
  fr_                 VARCHAR2(1);
  stmt_               VARCHAR2(2000);
  TYPE                Ref_Cur_Type IS REF CURSOR;
  c_get_period_       Ref_Cur_Type;
  order_by_stmt_      VARCHAR2(200);
  year_periods_       Year_Period_Tab;
BEGIN
   fr_ := '>';
   order_by_stmt_ := 'ORDER BY ACCOUNTING_YEAR ASC, ACCOUNTING_PERIOD ASC';
   IF (increment_ < 0 ) THEN
      fr_ := '<';
      order_by_stmt_ := 'ORDER BY ACCOUNTING_YEAR DESC, ACCOUNTING_PERIOD DESC';
   END IF;
   
   stmt_ := 'SELECT  accounting_year, accounting_period ' ||
            'FROM    ACCOUNTING_PERIOD_TAB ' ||
            'WHERE   company = :company_ ' ||
            'AND     (accounting_year * 100) + accounting_period '|| fr_ ||' :year_period_key_ ' ||
            'AND     year_end_period LIKE DECODE(:include_year_end_ ,''TRUE'',''%'',''ORDINARY'') ' ||
            'AND     ROWNUM <= TO_CHAR(ABS(:increment_)) ' ||
            order_by_stmt_;
   @ApproveDynamicStatement(2013-09-04,sjaylk)
   OPEN  c_get_period_ FOR stmt_ USING IN company_, 
                                      IN year_period_key_,
                                      IN UPPER(include_year_end_),
                                      IN increment_;
   FETCH c_get_period_ BULK COLLECT INTO year_periods_ ;
   CLOSE c_get_period_;       
   
   IF (year_periods_.COUNT = 0) THEN
      RETURN NULL;
   ELSE 
      RETURN(Build_Year_Period_Key___(year_periods_(ABS(increment_))));
   END IF;
END Get_Period_Incr;

PROCEDURE Get_Period_Info (   
   accounting_year_     OUT   NUMBER,
   accounting_period_   OUT   NUMBER,
   date_from_           OUT   DATE,
   date_until_          OUT   DATE,
   company_             IN    VARCHAR2,
   date_                IN    DATE )
IS 
   CURSOR get_accounting_per_info IS
      SELECT accounting_year, 
             accounting_period, 
             date_from, 
             date_until
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    date_   BETWEEN date_from AND date_until
      AND    year_end_period = 'ORDINARY';
      
BEGIN
   OPEN get_accounting_per_info;
   FETCH get_accounting_per_info INTO accounting_year_, accounting_period_, date_from_, date_until_;
   CLOSE get_accounting_per_info;
END Get_Period_Info;

FUNCTION Get_Period_Count (   
   company_             IN    VARCHAR2,
   from_year_period_    IN    NUMBER,
   until_year_period_   IN    NUMBER ) RETURN NUMBER
IS 
   
   no_of_periods_ NUMBER := 0;
   CURSOR count_accperiod IS
      SELECT COUNT(*)
      FROM   accounting_period_tab
      WHERE  company             = company_
      AND    ((accounting_year * 100) + accounting_period) BETWEEN from_year_period_ AND until_year_period_
      AND    year_end_period     = 'ORDINARY';
      
BEGIN
   OPEN  count_accperiod;
   FETCH count_accperiod INTO no_of_periods_; 
   IF ( count_accperiod%NOTFOUND) THEN      
      no_of_periods_ := 0;
   END IF;
   CLOSE count_accperiod; 
   
   RETURN no_of_periods_;
END Get_Period_Count;

--Purpose : to get the Year information for ORDINARY PERIOD of the period type( ordinary or year end)
@UncheckedAccess
FUNCTION Get_Acc_Year_Period (
   company_       IN     VARCHAR2,
   date_          IN     DATE) RETURN VARCHAR2
IS
   accounting_year_     NUMBER;
   accounting_period_   NUMBER;
BEGIN
   Get_Ordinary_Period_Info___ (accounting_year_, accounting_period_, company_, date_);
   RETURN TO_CHAR(accounting_year_)||TO_CHAR(accounting_period_,'FM00');   
END Get_Acc_Year_Period;


--Purpose : to get the Year/period information for current period. filterd for only ORDINARY PERIODs
@UncheckedAccess
FUNCTION Get_Curr_Acc_Year_Period (
   company_       IN     VARCHAR2) RETURN VARCHAR2
IS   
BEGIN   
   RETURN Get_Acc_Year_Period(company_, SYSDATE);
END Get_Curr_Acc_Year_Period;


--Purpose : to get the Year information for current period. filterd for only ORDINARY PERIODs
@UncheckedAccess
FUNCTION Get_Curr_Acc_Year (
   company_       IN     VARCHAR2) RETURN NUMBER
IS
BEGIN
   RETURN Get_Ordinary_Accounting_Year(company_, SYSDATE);
END Get_Curr_Acc_Year;


--Purpose : to get the period information for current period. filterd for only ORDINARY PERIODs
@UncheckedAccess
FUNCTION Get_Curr_Acc_Period (
   company_            IN     VARCHAR2) RETURN NUMBER
IS
BEGIN
   RETURN Get_Ordinary_Accounting_Period(company_, SYSDATE);
END Get_Curr_Acc_Period;


PROCEDURE Create_Accounting_Periods (
   company_                      IN VARCHAR2,
   source_year_                  IN NUMBER,
   from_year_                    IN NUMBER,
   accounting_year_              IN NUMBER,
   acc_period_create_method_db_  IN VARCHAR2)
IS
   newrec_        accounting_period_tab%ROWTYPE;
   indrec_        Indicator_Rec;
   empty_rec_     accounting_period_tab%ROWTYPE;
   current_year_  NUMBER;
   attr_          VARCHAR2(32000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);   
      
   CURSOR get_period_data IS 
      SELECT * 
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = source_year_;   
BEGIN
   FOR period_rec_ IN get_period_data LOOP
      Client_SYS.Clear_Attr(attr_);
      newrec_.company            := period_rec_.company;
      newrec_.accounting_year    := accounting_year_;
      newrec_.accounting_period  := period_rec_.accounting_period;
      newrec_.year_end_period    := period_rec_.year_end_period;
      newrec_.date_from          := ADD_MONTHS(period_rec_.date_from,  (accounting_year_ - source_year_)* 12);
      IF (period_rec_.year_end_period = 'YEAROPEN' OR period_rec_.year_end_period = 'YEARCLOSE') THEN
         newrec_.date_until      := newrec_.date_from;
      ELSE   
         newrec_.date_until      := ADD_MONTHS(period_rec_.date_until, (accounting_year_ - source_year_)* 12);
      END IF;
      current_year_ := TO_CHAR(newrec_.date_from, 'YYYY');
--      IF (acc_period_create_method_db_ = 'CLOSED') OR (period_rec_.year_end_period = 'YEARCLOSE') THEN
--         newrec_.period_status      := 'C';
--         newrec_.period_status_int  := 'C';
--      END IF;
      newrec_.description     := Get_Cre_Period_Description___(period_rec_,
                                                               source_year_, 
                                                               current_year_, 
                                                               newrec_.accounting_year);
      newrec_.report_from_date   := NULL;
      newrec_.report_until_date  := NULL;
      indrec_ := Get_Indicator_Rec___(empty_rec_, newrec_);
      Check_Insert___(newrec_, indrec_, attr_);      
      Client_SYS.Add_To_Attr('CREATE_COMP', 'TRUE', attr_);
      Insert___(objid_, objversion_, newrec_, attr_);
   END LOOP;
END Create_Accounting_Periods;


PROCEDURE Validate_Period_Format (
   corrected_year_period_ OUT VARCHAR2,
   company_               IN  VARCHAR2,   
   year_period_           IN  VARCHAR2)
IS
   year_                      NUMBER;
   period_                    NUMBER;
   period_exists_             BOOLEAN;
   period_exists_str_         VARCHAR2(10);
BEGIN  
   Extract_Year_Period(year_, period_, year_period_);
   Periodexist(period_exists_str_,
               company_,
               year_,
               period_);
   period_exists_ := (period_exists_str_ = 'TRUE');
   IF (NOT period_exists_) THEN
      Error_SYS.Record_General(lu_name_, 
                              'NOTYEARPERIOD: The Year-Period :P1 does not exist in company :P2.', 
                               year_period_,
                               company_);
   END IF;
   corrected_year_period_ := Year_Period_Output_Fmt(year_, period_);
END Validate_Period_Format;


PROCEDURE Extract_Year_Period(
   year_             OUT  NUMBER,
   period_           OUT  NUMBER,
   year_period_      IN   VARCHAR2 )
IS
   error_msg_      VARCHAR2(1000);
BEGIN
   error_msg_ := 'GROCONINVYEARPERIODFMT: The Year Period :P1 is incorrect. '||
   'The format can be supplied as YYYY-MM or YYYYMM or YYMM';

   IF (LENGTH(year_period_) = 7) THEN
      year_     := TO_NUMBER(SUBSTR(year_period_,1,4));
      period_   := TO_NUMBER(SUBSTR(year_period_,6,2));
   ELSIF (LENGTH(year_period_) = 6) THEN
      year_     := TO_NUMBER(SUBSTR(year_period_,1,4));
      period_   := TO_NUMBER(SUBSTR(year_period_,5,2));
   ELSIF (LENGTH(year_period_) = 4) THEN
      year_     := TO_NUMBER(SUBSTR(year_period_,1,2));
      period_   := TO_NUMBER(SUBSTR(year_period_,3,2));
      IF (year_ >= 50) THEN
         year_ := 1900 + year_;
      ELSE
         year_ := 2000 + year_;
      END IF;
   ELSE
      Error_SYS.Record_General(lu_name_, error_msg_, year_period_);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Record_General(lu_name_, error_msg_, year_period_);
END Extract_Year_Period;  


FUNCTION Year_Period_Output_Fmt(
   year_    IN  NUMBER,
   period_  IN  NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN(TO_CHAR(year_)||'-'||TO_CHAR(period_,'FM00'));
END Year_Period_Output_Fmt;

-- Year_Period_Output_Fmt
--   Function that returns a year period (e.g. 2018-01) from a year period key (e.g. 201801)
--   year_period_key is a number (based on format YYYYMM)
FUNCTION Year_Period_Output_Fmt(
   year_period_key_     IN  NUMBER) RETURN VARCHAR2
IS
   invalid_number    EXCEPTION;
   PRAGMA EXCEPTION_INIT(invalid_number, -06502);      
   year_                NUMBER;
   period_              NUMBER;
   year_period_str_     VARCHAR2(10) := TO_CHAR(year_period_key_);
BEGIN       
   year_     := TO_NUMBER(SUBSTR(year_period_str_,1,4));
   period_   := TO_NUMBER(SUBSTR(year_period_str_,5,2));   
   
   RETURN Year_Period_Output_Fmt(year_, period_);
EXCEPTION 
   WHEN invalid_number THEN
      Error_SYS.Record_General(lu_name_, 
                               'INVYEARPERKEYFMT: The Year Period Key :P1 is incorrect. The format should be entered as YYYYMM',
                               year_period_key_);   
END Year_Period_Output_Fmt;

@UncheckedAccess
-- Get_Until_Date_For_Year_Period
--   function that returns the Date Until for given year-period (e.g. 2016-01)
--   The year-period must be in the following format like YYYY-MM.
FUNCTION Get_Until_Date_For_Year_Period(
   company_       IN  VARCHAR2,
   year_period_   IN  VARCHAR2 ) RETURN DATE
IS
   year_       NUMBER;
   period_     NUMBER;
   until_date_ DATE;
BEGIN
   Extract_Year_And_Period___(year_, period_, year_period_);
   until_date_ := Get_Date_Until(company_, year_, period_);  
   RETURN until_date_;
END Get_Until_Date_For_Year_Period;


@UncheckedAccess
-- Get_Date_From_For_Year_Period
--   function that returns the Date From for given year-period (e.g. 2016-01)
--   The year-period must be in the following format like YYYY-MM.
FUNCTION Get_Date_From_For_Year_Period(
   company_       IN  VARCHAR2,
   year_period_   IN  VARCHAR2 ) RETURN DATE
IS
   year_       NUMBER;
   period_     NUMBER;
   date_from_  DATE;
BEGIN
   Extract_Year_And_Period___(year_, period_, year_period_);
   date_from_ := Get_Date_From(company_, year_, period_);  
   RETURN date_from_;
END Get_Date_From_For_Year_Period;


@UncheckedAccess
FUNCTION Get_Final_Ord_Calender_Date (
   company_            IN VARCHAR2) RETURN DATE
IS
   max_year_            NUMBER;
   last_normal_period_  NUMBER;
   last_date_           DATE;             
BEGIN
   max_year_ := Accounting_Year_API.Get_Max_Accounting_Year(company_);
   last_normal_period_ := Get_Last_Normal_Period(company_, max_year_);
   last_date_ := Get_Date_Until(company_, max_year_, last_normal_period_);
   RETURN last_date_;
END Get_Final_Ord_Calender_Date;

-- This is used to created Period_Ledger_Info records when a new Internal Ledger ID is created.
PROCEDURE Create_Acc_Period_Ledger_Info(
   company_       IN VARCHAR2,
   ledger_id_     IN VARCHAR2 )
IS
   newrec_        accounting_period_tab%ROWTYPE;   
   CURSOR get_rec IS
      SELECT accounting_year, accounting_period, year_end_period
      FROM   accounting_period_tab
      WHERE  company  = company_
      ORDER BY accounting_year, accounting_period;
BEGIN
   newrec_.company := company_;
   FOR rec_ IN get_rec LOOP 
      newrec_.accounting_year    := rec_.accounting_year;
      newrec_.accounting_period  := rec_.accounting_period;
      newrec_.year_end_period    := rec_.year_end_period;
      Create_Period_Ledger_Info___(newrec_, ledger_id_);
   END LOOP;
END Create_Acc_Period_Ledger_Info;

PROCEDURE Get_Min_Year_Period (
   min_year_         OUT NUMBER,
   min_period_       OUT NUMBER,
   company_          IN  VARCHAR2)
IS
   CURSOR get_min_year IS
      SELECT MIN(accounting_year)
      FROM   accounting_period_tab
      WHERE  company  = company_;       
BEGIN
   OPEN  get_min_year;
   FETCH get_min_year INTO min_year_ ;
   CLOSE get_min_year;   
   min_period_ := Get_Min_Period___(company_, min_year_);   
END Get_Min_Year_Period;


-- Build_Year_Period_Key
--   function that builds a year period key (e.g. 201601) from a year-period (e.g. 2016-01)
--   The year-period must be in the following format like YYYY-MM.
FUNCTION Build_Year_Period_Key (
   year_period_      IN VARCHAR2 ) RETURN NUMBER 
IS
   invalid_number    EXCEPTION;
   PRAGMA EXCEPTION_INIT(invalid_number, -06502);   
BEGIN
   -- In future release the Build_Year_Period_Key___ function should be used here once it is changed to return a number instead of a varchar 
   RETURN (TO_NUMBER(SUBSTR(year_period_, 1, 4)) * 100 + TO_NUMBER(SUBSTR(year_period_, 6, 2)));
EXCEPTION 
   WHEN invalid_number THEN
      Error_SYS.Record_General(lu_name_, 
                               'INVYEARPERIODFMT2: The Year-Period :P1 is incorrect. The format should be entered as YYYY-MM',
                               year_period_);
END Build_Year_Period_Key;


-- Build_Year_Period_Key
--   function that builds a year period key (e.g. 201601) from an accounting year and accounting period (e.g. year 2016 period 1)
--   The parameters accounting year and accounting period are numbers.
FUNCTION Build_Year_Period_Key (
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER) RETURN NUMBER 
IS
   ypk_              NUMBER;
BEGIN
   ypk_ := (accounting_year_ * 100 + accounting_period_);
   RETURN ypk_;                         
END Build_Year_Period_Key;

FUNCTION Get_First_Normal_From_Date (
   company_       IN    VARCHAR2 ) RETURN DATE
IS
   CURSOR get_first_normal_date IS
      SELECT date_from
        FROM accounting_period_tab
       WHERE company         = company_
         AND year_end_period = 'ORDINARY'
    ORDER BY accounting_year ASC, accounting_period ASC;
    
   date_from_              DATE;
BEGIN
   OPEN get_first_normal_date;
   FETCH get_first_normal_date INTO date_from_;
   CLOSE get_first_normal_date;
   RETURN date_from_;
END Get_First_Normal_From_Date;

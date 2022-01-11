-----------------------------------------------------------------------------
--
--  Logical unit: CompanyFinance
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960430  MiJo  Created
--  961106  Yohe  Add FUNCTION Get_Cons_Company
--  970319  MiJo  Added procedure Create_Accounting_Company for create company
--                global. This procedure calls procedure "Create_Company" in
--                every package that exist in view User_Source.
--  970603  MiJo  Added call to create_accounting_company in procedure new__.
--  970617  DavJ  Added Procedure Updated_Company
--  970623  SLKO  Converted to Foundation1 1.2.2d
--  970819  PICZ  Fixed problem with infinite loop when defining chain of
--                dependend companies
--  971007  ANDJ  Fixed Support # 189 by adding some ltrim(lpad(to_char...
--                format on objversion.
--  971229  SLKO  Converted to Foundation1 2.0.0
--  980128  MALR  Added FUNCTION Get_Correction_Type, the IID correction_type
--  980225  PICZ  Changed: Check_Cons_Company___: checking if it's possible
--                to change consolidation company
--  980604  LALI  Modified error output in Create_Accounting_Company
--  980721  Thus  Third Currency. Added function Get_Parallel_Acc_Currency.
--                Changed Insert & Update to add fields 'Time Stamp' and
--                parallel_acc_currency.
--  980825  Nish  Added Procedure Start_Drop_Company to Drop a Company.
--  980914  Bren  Master Slave Connection. Added procedure Send To Slaves.
--  980918  JPS   Added procedure New_Company__.
--  980923  JPS   Added procedure Create_Company_With_Log__.
--  980926  JPS   Check for length of the Company Code to be greater than 1 in
--                Unpack_check_insert.
--  981026  JPS   Out parameter added to Start_Drop_Company to pass a message
--                to client.
--  981202  Bren  Added 3 fields to the attr string to recalculate third currency
--                amounts when parallel_currency_code is initiated. These 3 fields
--                (RECALCULATE,THIRD_CURRENCY_RATE,CONVERSION_RATE) are set in the
--                Client.
--  990409  Ruwan Modified with respect to new template (not marked)
--  990427  JOBJ  Performance fix of view
--  990527  JPS   Corrected Bug # 18405
--  990617  JPS   Corrected Bug # 20684
--  991001 JOELSE You should no longer have to be application owner to create company.
--                (see also Gen_Led_User_API.Unpack_Check_Insert___).
--  991220  SaCh  Removed public function Get_Company_Name.
--  000105  SaCh  Added public function Get_Company_Name.
--  000124  Bren  Added a check to module = 'MFGSTD' to the procedure Drop Accounting Company
--  000424  SaCh  Added a check into procedure Create_Company to check whether there are wildcards
--                included in the company name.(If there are wild cards order reports in info services
--                gives errors when a company with a wild card is selected.)
--  000512  HiMu  Corrected Bug # 38405
--  000531  SaCh  Added Method_Keep to Insert methods.
--  000620  Uma   Changed Get_Oracle_User to Get_Fnd_User.
--  000619  LeKa  A526: Added Level_In_Percent and Level_In_Acc_Currency.
--                Also added function Get_Level_In_Percent and Get_Level_Acc_Currency.
--  000810  SaCh  Corrected bug # 75020.
--  000815  SaCh  Added function Get_Method_Keep in order to correct Bug # 46400.
--  210800  Upul  Added Method_Keep_Exist.
--  280800  SaCh  Corrected Bug # 45692.
--  280800  LiSv  A525: Added procedure Generate_Default_Data_ to create posting types when creating company.
--  000828  BmEk  A527: Added def_amount_method and Get_Def_Amount_Method.
--  000912  HiMu  Added General_SYS.Init_Method
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  001005  Ruwan  Modified view1 to show only the reference currency
--  001120  ovjose Removed method Update_Accrul_Third_Amounts___
--  001128  BmEk   Bug #18212. Also removed remarked code. Corrected error in method
--                 Create_Accounting_Company (replaced 'GENLED' with 'TAXLED' for module TAXLED in call to
--                 Create_Company_With_Log__).
--  001128  ovjose Removed Call_Company___, Create_New_Company___, New_Company__,
--                 Create_Company_With_Log__, Create_Accounting_Company and Create_X_Company
--                 due to a new approach of create company.
--  001130  LiSv   Added public New due to new approach of create company.
--  010210  LiSv   Added attribute creation_finished due to new approach of create company.
--  010112  ToOs   Bug 19024 - Removed methods Remove_Value and Remove_from_user_profiles for
--                 use of F1-methods instead. Changed Drop_company for better performance
--  010221  ToOs   Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010307  ToOs   Bug # 20512 PL code in where clause, added a new view VIEW_AUTH1 for faster check
--  010402  Uma    Bug # 20944 - Merge of Wizard Modifications.
--  040401  SUMALK Bug # 21143 Fixed. Added a order by clause with  row_number.
--  010508  JeGu   Bug #21705 Implementation New Dummyinterface
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  011005  Brwelk Bug #25118. Move Method Keep to INTLED. Removed public methods
--                 Get_Method_Keep, Method_Keep_Exist.
--  011017  Assalk Added a method for the updation of CompanyFinance Information.
--  020125  BmEk   IID 10220. Added colums City_Tax_Code, State_Tax_Code, County_Tax_Code and
--                 District_Tax_Code. Also added Get_Default_Tax_Codes.
--  020225  visuus IID 10506:Implementation of MC-Automatic supplier payment
--  021224  ISJALK SP3 merge, BUG 33138.
--  030320  SaAblk New public method Get_Currency_Rates
--  030328  JeGu   RDFI140N Performance
--  030428  SaAblk Call ID 95930. Modified references to currency_code and currency_rate to currency_code_tab and currency_rate_tab
--  030513  SaAblk Moved public method Get_Currency_Rates to the CurrencyRate LU
--  030731  prdilk SP4 Merge.
--  040902  reanpl FIJP344 Japanese Tax Rounding, added column tax_rounding_method
--  040906  ingulk FITH337A Added a column use_vou_no_period.
--  060125  shsalk Micro Cache Modifications.
--  070124  Thpelk FIPL644 - Added REVERSE_VOU_CORR_TYPE to the COMPANY_FINANCE.
--  070402  ovjose Added view company_finance_adm and Exist_Adm method. View is used from Solution Manager via Extended Server.
--  080624  Mepalk Bug 70348, Set list of values flag for currency_code column in VIEW_AUTH. 
--  090511  reanpl Bug 82373, SKwP Ceritificate - Final Closing of Period (SKwP-2)
--  090605  THPELK Bug 82609 - Added missing UNDEFINE statements for VIEW_ADM.
--  091019  OVJOSE   EAFH-382 - Removed code that add appowner in the company during 
--                   company creation. Also some general cleanup in the file.
--  100204  cldase EAFH-1508, Added validation on parallel currency and accounting currency. Added Is_Currency_Dates_Valid___()
--                 and modified Unpack_Check_Insert___
--  100307  Nsillk Added method to support adding companyfinance to templates
--  100312  OVJOSE Added Check_Exist and changed some of the views
--  100609  Kagalk EAFH-3134, Modified to set the time_stamp when modifying parallel currency.
--  100805  OVJOSE Changed where clause in VIEW_ADM due to changes in underlying view.
--  110504  RUFELK EASTONE-17733 - Removed incorrect updating of non-updatable fields time_stamp and recalculation_date in Unpack_Check_Update___().
--  110518  RUFELK EASTONE-19140 - Removed extra validation for CONACC company in Unpack_Check_Update___() and modified Check_Cons_Company___() to handle it.
--  110528  THPELK EASTONE-21645 Added missing General_SYS and PRAGMA.
--  120222  Mawelk SFI-1421 Bug 97739, Added a method   Check_Exist_Company()
--  120806   Maaylk Bug 101320, Used micro cache in Get_Parallel_Acc_Currency()
--    121204   Maaylk PEPA-183, Removed global variables
--  121123  Janblk DANU-122, Parallel currency implementation   
--  130514  DIFELK DANU-1085, used micro cache for parallel currency methods
--  131030  Umdolk PBFI-1909, Refactoring
--  170329  Chwtlk STRFI-4967, Merged LCS Bug 134102, Made column User_Def_Cal mandatory
--  181130  Nudilk Bug 145620, Corrected.
--  200730  Smallk GESPRING20-5106, Added Get_Tax_Id_Number().
--  200914  Jadulk FISPRING20-6695, Remove obsolete component logic related to CONACC
--  201111  Tkavlk FISPRING20-8158, Remove obsolete attributs logic
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE PkgNameTab IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

TYPE ModuleNameTab IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

TYPE MarkTab IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;


-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Is_Currency_Dates_Valid___(
   acc_curr_date_ IN DATE,
   par_curr_date_ IN DATE ) RETURN BOOLEAN
IS 
BEGIN
   IF (par_curr_date_ >= acc_curr_date_) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END Is_Currency_Dates_Valid___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   table_rec_     IN COMPANY_FINANCE_TAB%ROWTYPE )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        COMPANY_FINANCE_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   run_crecomp_   BOOLEAN := FALSE;
   indrec_        Indicator_Rec;
   CURSOR get_data IS
      SELECT correction_type, def_amount_method, reverse_vou_corr_type, period_closing_method
      FROM COMPANY_FINANCE_TAB
      WHERE company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM COMPANY_FINANCE_TAB dest
                      WHERE dest.company = crecomp_rec_.company);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);

   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            Client_SYS.Clear_Attr(attr_);
            newrec_.company               := table_rec_.company;
            newrec_.currency_code         := table_rec_.currency_code;
            newrec_.valid_from            := table_rec_.valid_from;
            newrec_.parallel_acc_currency := table_rec_.parallel_acc_currency;
            newrec_.time_stamp            := table_rec_.time_stamp;
            newrec_.recalculation_date    := table_rec_.recalculation_date;
            newrec_.use_vou_no_period     := table_rec_.use_vou_no_period;
            newrec_.user_def_cal          := crecomp_rec_.user_defined;
            newrec_.creation_finished     := table_rec_.creation_finished;
            newrec_.correction_type       := rec_.correction_type;
            newrec_.def_amount_method     := rec_.def_amount_method;
            newrec_.reverse_vou_corr_type := rec_.reverse_vou_corr_type;
            newrec_.period_closing_method := rec_.period_closing_method;
            IF (table_rec_.parallel_acc_currency IS NOT NULL) THEN
               newrec_.parallel_base         := table_rec_.parallel_base;
            END IF;

            indrec_ := Get_Indicator_Rec___(newrec_);
            indrec_.recalculation_date := FALSE;
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedSuccessfully');
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Import___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   table_rec_     IN COMPANY_FINANCE_TAB%ROWTYPE )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        COMPANY_FINANCE_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;
   indrec_        Indicator_Rec;
   CURSOR get_data IS
      SELECT C1, C2, C4, C5
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM COMPANY_FINANCE_TAB dest
                      WHERE dest.company = crecomp_rec_.company);
BEGIN

   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);

   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_.company               := table_rec_.company;
            newrec_.currency_code         := table_rec_.currency_code;
            newrec_.valid_from            := table_rec_.valid_from;
            newrec_.parallel_acc_currency := table_rec_.parallel_acc_currency;
            newrec_.time_stamp            := table_rec_.time_stamp;
            newrec_.recalculation_date    := table_rec_.recalculation_date;
            newrec_.use_vou_no_period     := table_rec_.use_vou_no_period;
            newrec_.user_def_cal          := crecomp_rec_.user_defined;
            newrec_.creation_finished     := table_rec_.creation_finished;
            newrec_.correction_type       := rec_.c1;
            newrec_.def_amount_method     := rec_.c2;            
            newrec_.reverse_vou_corr_type := rec_.c4;
            newrec_.period_closing_method := rec_.c5;
            newrec_.parallel_base         := table_rec_.parallel_base;
            Client_SYS.Clear_Attr(attr_);
            indrec_ := Get_Indicator_Rec___(newrec_);
            indrec_.recalculation_date := FALSE;
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'COMPANY_FINANCE_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_             NUMBER := 1;
   CURSOR get_data IS
      SELECT correction_type, def_amount_method,
             reverse_vou_corr_type, period_closing_method, use_vou_no_period
      FROM   COMPANY_FINANCE_TAB
      WHERE  company = crecomp_rec_.company;
BEGIN

   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := 'ACCRUL';
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.correction_type;      
      pub_rec_.c2 := pctrec_.def_amount_method;
      pub_rec_.c4 := pctrec_.reverse_vou_corr_type;
      pub_rec_.c5 := pctrec_.period_closing_method;
      pub_rec_.c6 := pctrec_.use_vou_no_period;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;


FUNCTION Check_If_Do_Create_Company___(
   crecomp_rec_    IN  Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) RETURN BOOLEAN
IS
   perform_update_         BOOLEAN;
   update_by_key_          BOOLEAN;
BEGIN
   perform_update_ := FALSE;
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF (update_by_key_) THEN
      perform_update_ := TRUE;
   ELSE
      IF (NOT Check_Exist___( crecomp_rec_.company )) THEN
         perform_update_ := TRUE;
      END IF;
   END IF;
   RETURN perform_update_;
END Check_If_Do_Create_Company___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('DEF_AMOUNT_METHOD', Def_Amount_Method_API.Decode('NET'), attr_);
   Client_SYS.Add_To_Attr('CREATION_FINISHED', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT COMPANY_FINANCE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   -- Add the current user to UserFinance
   User_Finance_API.Register_Company_User(newrec_.company,
                                          Fnd_Session_API.Get_Fnd_User);
EXCEPTION
   WHEN dup_val_on_index THEN
        Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN COMPANY_FINANCE_TAB%ROWTYPE )
IS
BEGIN
   Error_SYS.Appl_General(lu_name_,'INVDELETE: It is not valid to delete a company');
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     company_finance_tab%ROWTYPE,
   newrec_ IN OUT company_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.user_def_cal IS NULL) THEN      
      newrec_.user_def_cal := 'FALSE';
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.parallel_acc_currency IS NULL) THEN
      newrec_.time_stamp := NULL;
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT company_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   dupl_company_     VARCHAR2(30);
BEGIN
   IF (Client_SYS.Item_Exist('PAR_ACC_CURR_VALID_FROM', attr_)) THEN 
      newrec_.time_stamp := Client_SYS.Attr_Value_To_Date(Client_SYS.Cut_Item_Value('DESCRIPTION', attr_));
   END IF;   
   IF (Client_SYS.Item_Exist('DUPL_COMPANY', attr_)) THEN 
      dupl_company_ := Client_SYS.Cut_Item_Value('DUPL_COMPANY', attr_);
   END IF;

   IF (newrec_.use_vou_no_period IS NULL) THEN
      newrec_.use_vou_no_period := 'FALSE';
   END IF;
   newrec_.creation_finished      := NVL(newrec_.creation_finished, 'TRUE');  
   newrec_.period_closing_method  := NVL(newrec_.period_closing_method, 'REVERSIBLE');
   super(newrec_, indrec_, attr_);
   
   IF (newrec_.parallel_acc_currency IS NOT NULL) THEN      
      newrec_.recalculation_date := SYSDATE ;
   END IF;
   
   IF (newrec_.parallel_acc_currency IS NOT NULL AND newrec_.time_stamp IS NULL) THEN
      Error_SYS.Record_General(lu_name_,'NEEDVALIDFROM: Valid from date must be specified for Parallel Accounting Currency');
   END IF;

   IF (newrec_.parallel_acc_currency IS NOT NULL AND newrec_.time_stamp IS NOT NULL) THEN
      IF (NOT Is_Currency_Dates_Valid___(newrec_.valid_from, newrec_.time_stamp)) THEN
         Error_SYS.Record_General(lu_name_,'DATENOTVALID: The valid from date of the Parallel Accounting Currency must not be before the valid from date of the Accounting Currency');
      END IF;
   END IF;

END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     company_finance_tab%ROWTYPE,
   newrec_ IN OUT company_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   third_currency_rate_       NUMBER;
   conversion_factor_         NUMBER;

   CURSOR get_parallel_curr_rate_type IS
      SELECT t.currency_type 
      FROM currency_type_def_tab t
      WHERE t.rate_type_category = 'PARALLEL_CURRENCY';
BEGIN
   IF (Client_SYS.Item_Exist('DESCRIPTION', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'DESCRIPTION');   
   ELSIF (Client_SYS.Item_Exist('PAR_ACC_CURR_VALID_FROM', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'PAR_ACC_CURR_VALID_FROM');                
   END IF;
   attr_  := Client_SYS.Remove_Attr('RECALCULATE', attr_);
   IF (Client_SYS.Item_Exist('THIRD_CURRENCY_RATE', attr_)) THEN
      third_currency_rate_ := Client_SYS.Attr_Value_To_Number(Client_SYS.Cut_Item_Value('THIRD_CURRENCY_RATE', attr_));
   END IF;
   IF (Client_SYS.Item_Exist('CONVERSION_FACTOR', attr_)) THEN
      conversion_factor_ := Client_SYS.Attr_Value_To_Number(Client_SYS.Cut_Item_Value('CONVERSION_FACTOR', attr_));
   END IF;      
   super(oldrec_, newrec_, indrec_, attr_);
     
   -- Check that the user is an allowed user in the company
   User_Finance_API.Exist(newrec_.company, Fnd_Session_API.Get_Fnd_User);   
   
   IF (newrec_.parallel_acc_currency IS NOT NULL) THEN
      Iso_Currency_API.Exist(newrec_.parallel_acc_currency);
      IF (newrec_.parallel_base IS NULL) THEN
         newrec_.parallel_base := 'ACCOUNTING_CURRENCY';     
      END IF;
      IF (newrec_.parallel_rate_type IS NULL) THEN
         IF newrec_.parallel_base = 'ACCOUNTING_CURRENCY' THEN    
            newrec_.parallel_rate_type := Currency_Type_API.Get_Default_Type(newrec_.company);
         ELSE 
            OPEN get_parallel_curr_rate_type;
            FETCH get_parallel_curr_rate_type INTO newrec_.parallel_rate_type;
            CLOSE get_parallel_curr_rate_type;
         END IF;   
      END IF;
   END IF;
   IF newrec_.parallel_rate_type IS NOT NULL THEN
      IF oldrec_.parallel_acc_currency IS NULL THEN
         Error_SYS.Appl_General(lu_name_, 'NOPARCURR: Parallel Currency rate type cannot have a value when parallel currency is not defined for the company :P1',oldrec_.company);
      END IF;
      IF (Currency_Type_API.Is_Correct_Curr_Type(oldrec_.company,oldrec_.parallel_base,newrec_.parallel_rate_type,oldrec_.currency_code)!=1) THEN
         Error_SYS.Appl_General(lu_name_, 'Please check the value for Parallel Base Currency and enter correct Currency Rate Type.');
      END IF;
   END IF;
   IF indrec_.master_company THEN
      Validate_Master_Company___(oldrec_,newrec_);
   END IF;   
                         

   Client_SYS.Add_To_Attr( 'TIME_STAMP', newrec_.time_stamp, attr_ );
END Check_Update___;

PROCEDURE Check_Master_Company_Ref___ (
   newrec_ IN OUT company_finance_tab%ROWTYPE )
IS         
BEGIN   
   IF(NOT Company_API.Exists(newrec_.master_company)) THEN
      Error_SYS.Appl_General(lu_name_,'COMPNOTEXIST: Company :P1 does not exist.',newrec_.master_company);
   ELSE
      IF (Company_API.Get_Master_Company_Db(newrec_.master_company) != 'TRUE') THEN
         Error_SYS.Appl_General(lu_name_,'NOMASTERCOMP: Company :P1 is not a master company.',newrec_.master_company);
      END IF;      
   END IF;
END Check_Master_Company_Ref___;

PROCEDURE Validate_Master_Company___(
   oldrec_ IN     company_finance_tab%ROWTYPE,
   newrec_ IN OUT company_finance_tab%ROWTYPE)
IS
BEGIN
   IF Company_API.Get_Master_Company_Db(oldrec_.company) = 'TRUE' THEN
      Error_SYS.Appl_General(lu_name_, 'MASTEREXIST: A master company cannot be connected since company :P1 is also a master company.',newrec_.company);
   END IF;
   IF newrec_.master_company IS NULL AND oldrec_.master_company IS NOT NULL THEN
      Client_SYS.Add_Warning(lu_name_, 'MASTERREMOVED: All existing Master Company Account mapping will be removed.');
      Company_Finance_API.Update_Mc_Account_Mapping(oldrec_.company,oldrec_.master_company);
   ELSIF newrec_.master_company IS NOT NULL AND newrec_.master_company != oldrec_.master_company THEN
      Client_SYS.Add_Warning(lu_name_, 'MASTERUPDATE: Existing Master Company Account mapping might not be relevant if you change Master Company. If so, please review existing mapping. Alternatively first remove the old Master Company and save, which will remove all existing mapping.');
   END IF;   
END Validate_Master_Company___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Create_Client_Mapping__ (
   client_window_ IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS 
   clmapprec_    Client_Mapping_API.Client_Mapping_Pub;
   clmappdetrec_ Client_Mapping_API.Client_Mapping_Detail_Pub;
BEGIN
   clmapprec_.module := module_;
   clmapprec_.lu := lu_name_;
   clmapprec_.mapping_id := 'CCD_COMPANYFINANCE';
   clmapprec_.client_window := client_window_;  
   clmapprec_.rowversion := sysdate;
   Client_Mapping_API.Insert_Mapping(clmapprec_);

   clmappdetrec_.module := module_;
   clmappdetrec_.lu := lu_name_;
   clmappdetrec_.mapping_id :=  'CCD_COMPANYFINANCE';
   clmappdetrec_.column_type := 'NORMAL';  
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := sysdate;  
   
   clmappdetrec_.column_id := 'C1' ;
   clmappdetrec_.translation_link := 'COMPANY_FINANCE.CORRECTION_TYPE';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
        
   clmappdetrec_.column_id := 'C2' ;
   clmappdetrec_.translation_link := 'COMPANY_FINANCE.DEF_AMOUNT_METHOD';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
         
   clmappdetrec_.column_id := 'C4' ;
   clmappdetrec_.translation_link := 'COMPANY_FINANCE.REVERSE_VOU_CORR_TYPE';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C5' ;
   clmappdetrec_.translation_link := 'COMPANY_FINANCE.PERIOD_CLOSING_METHOD';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C6' ;
   clmappdetrec_.translation_link := 'COMPANY_FINANCE.USE_VOU_NO_PERIOD';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Create_Client_Mapping__;   


PROCEDURE Create_Company_Reg__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
   
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, 'COMPANY_FINANCE_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'CCD_COMPANYFINANCE', NULL);
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
      module_,'COMPANY_FINANCE_TAB',
      CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'COMPANY_FINANCE_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@Override
@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2 )
IS
BEGIN
   super(company_);
   -- Check that the user is an allowed user in the company. In earlier versions (pre 8.12) the Check_Exist___
   -- method checked against the view company_finance which filtered companies based on if the user was an 
   -- allowed user in the company. This could trigger a not exist error even if the company existed.
   -- Now the method distinguish between if the company exists and if the user is allowed to the company.
   -- The check if the user is allowed to the company is now performed against User_Finance_Tab which
   -- is the place where allowed users per company are stored.
   -- In the future (Apps9 or later) this security check will be removed and instead be placed in every calling LU
   -- that actually wants to perform a UserFinance check separately from a check that the CompanyFinance
   -- object exists.
   User_Finance_API.Exist_Current_User(company_);
   /*
   IF (NOT User_Finance_API.Is_User_Authorized(company_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_,
                                 'RECNOTEXIST: Access denied! User :P1 is not connected to Company :P2',
                                 Fnd_Session_API.Get_Fnd_User,
                                 company_);
   END IF;
   */
END Exist;


@UncheckedAccess
FUNCTION Get_Parallel_Acc_Currency (
   company_  IN VARCHAR2,
   date_     IN DATE) RETURN VARCHAR2
IS
BEGIN
   Update_Cache___(company_);
   -- In order support the date_ parameter check against the time_stamp attribute
   IF (date_ IS NOT NULL) THEN
      IF (TRUNC(date_) >= TRUNC(micro_cache_value_.time_stamp)) THEN
         RETURN micro_cache_value_.parallel_acc_currency;
      ELSE
         RETURN NULL;
      END IF;
   ELSE
      RETURN Get_Parallel_Acc_Currency(company_);
   END IF;
END Get_Parallel_Acc_Currency;


@UncheckedAccess
PROCEDURE Get_Accounting_Currency (
  currency_code_      IN OUT VARCHAR2,
  company_            IN     VARCHAR2 )
IS
BEGIN
  currency_code_:= Get_Currency_code( company_ );
END Get_Accounting_Currency;


@UncheckedAccess
FUNCTION Is_User_Authorized (
   company_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   is_user_authorised_ BOOLEAN;
BEGIN
   is_user_authorised_ := User_Finance_API.Is_User_Authorized(company_);
   IF (is_user_authorised_ IS NULL) THEN
      is_user_authorised_ := FALSE;
   END IF;
   RETURN(is_user_authorised_);
END Is_User_Authorized;


PROCEDURE Get_Control_Type_Value_Desc (
   description_       OUT VARCHAR2,
   company_        IN     VARCHAR2,
   ctrl_company_   IN     VARCHAR2 )
IS
BEGIN
   description_ := Get_Description(ctrl_company_);
END Get_Control_Type_Value_Desc;


@UncheckedAccess
FUNCTION Get_Company_Name (
   company_  IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   RETURN substr(Company_API.Get_name(company_), 1, 100);
END Get_Company_Name;


PROCEDURE New (
   attr_      IN OUT VARCHAR2 )
IS
   newrec_        COMPANY_FINANCE_TAB%ROWTYPE;
   objid_         VARCHAR2(100);
   objversion_    VARCHAR2(2000);
   indrec_        Indicator_Rec;
BEGIN
   Client_SYS.Add_To_Attr('DEF_AMOUNT_METHOD', Def_Amount_Method_API.Decode('NET'), attr_);
   Client_SYS.Add_To_Attr('CREATION_FINISHED', 'FALSE', attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New;


PROCEDURE Set_Creation_Finished (
   company_  IN VARCHAR2 )
IS
   oldrec_     COMPANY_FINANCE_TAB%ROWTYPE;
   newrec_     COMPANY_FINANCE_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   -- Check that the company exists before updating
   IF Check_Exist___(company_) THEN
      oldrec_ := Lock_By_Keys___(company_);
      newrec_ := oldrec_;
      newrec_.creation_finished := 'TRUE';
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);      
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
END Set_Creation_Finished;


PROCEDURE Update_Company_Finance (
   attr_      IN OUT VARCHAR2,
   company_   IN     VARCHAR2 )
IS
   objid_            VARCHAR2(100);
   objversion_       VARCHAR2(2000);
   info_             VARCHAR2(30);
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_,company_);
   Modify__(info_,objid_, objversion_,attr_,'DO');
END Update_Company_Finance;

@UncheckedAccess
FUNCTION Is_Third_Used (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_       VARCHAR2(5);
   CURSOR get_attr IS
      SELECT 'TRUE'
      FROM   company_finance_tab
      WHERE  company               = company_
      AND    parallel_acc_currency IS NOT NULL;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   IF (get_attr%NOTFOUND) THEN
      temp_ := 'FALSE';
   END IF;
   CLOSE get_attr;
   RETURN temp_;
END Is_Third_Used;


-- Exist_Adm
--   Validates that the company finance object exists and that the user is allowed to the company either as 
--   a user within the company or as an administrator (and granted a specific activity).
--   This method should only be used from logical units that needs to let an administrator pass ordinary
--   User Finance validation (which is done implicit in normal Exist method)
--   when administrating users in Solution Manager
--   This method will be removed once the implicit UserFinance check is removed from Exist method
--   and instead User_Finance_API.Exist_User_Admin should be used to handle the security check separately.
PROCEDURE Exist_Adm (
   company_  IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
   User_Finance_API.Exist_User_Admin(company_);
END Exist_Adm;


@UncheckedAccess
FUNCTION Check_Exist (
   company_  IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Check_Exist___(company_);
END Check_Exist;


@UncheckedAccess
FUNCTION Check_Exist_Company (
   company_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(company_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist_Company;


PROCEDURE Make_Company (
   attr_       IN VARCHAR2)
IS
   rec_              Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
   comp_fin_rec_     COMPANY_FINANCE_TAB%ROWTYPE;
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(2000);
BEGIN
   rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec('ACCRUL', attr_);
   ptr_ := NULL;
   
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'NEW_COMPANY') THEN
         comp_fin_rec_.company := value_;
      ELSIF (name_ = 'CURRENCY_CODE') THEN
         comp_fin_rec_.currency_code := value_;
      ELSIF (name_ = 'VALID_FROM') THEN
         comp_fin_rec_.valid_from := Client_SYS.Attr_Value_To_Date(value_);
      ELSIF (name_ = 'PARALLEL_ACC_CURRENCY') THEN
         comp_fin_rec_.parallel_acc_currency := value_;
         IF (value_ IS NOT NULL) THEN
            comp_fin_rec_.recalculation_date := SYSDATE ;
         END IF;
      ELSIF (name_ = 'PAR_ACC_CURR_VALID_FROM') THEN
         comp_fin_rec_.time_stamp := Client_SYS.Attr_Value_To_Date(value_);
      ELSIF (name_ = 'USE_VOU_NO_PERIOD') THEN
         comp_fin_rec_.use_vou_no_period := value_;
      ELSIF (name_ = 'PARALLEL_CURR_BASE') THEN
         comp_fin_rec_.parallel_base := value_;
      ELSE
         NULL;
      END IF;
   END LOOP;
   
   comp_fin_rec_.creation_finished := 'FALSE';

   IF (rec_.make_company = 'EXPORT') THEN
      Export___(rec_);
   ELSIF (rec_.make_company = 'IMPORT') THEN
      IF (rec_.action = 'NEW') THEN
         Import___(rec_, comp_fin_rec_);
      ELSIF (rec_.action = 'DUPLICATE') THEN
         Copy___(rec_, comp_fin_rec_);
      END IF;
   END IF;
END Make_Company;

PROCEDURE Update_Mc_Account_Mapping(
   company_        IN VARCHAR2,
   master_company_ IN VARCHAR2)
IS   
   mc_accnt_      VARCHAR2(50);   
   CURSOR get_accounts IS
      SELECT code_part_value
      FROM   accounting_code_part_value_tab 
      WHERE  company = company_
      AND    code_part = 'A'
      AND    master_com_code_part_value IS NOT NULL;      
BEGIN
   mc_accnt_ := NULL;
   FOR accnt_ IN get_accounts LOOP
      Account_API.Upd_Master_Company_Account(company_, accnt_.code_part_value, mc_accnt_);
   END LOOP;
   Account_Group_API.Remove_Mc_Account(company_);
END Update_Mc_Account_Mapping;

PROCEDURE Validate_Master_Company(
   attr_   IN VARCHAR2)
IS   
   company_            company_finance_tab.company%TYPE;
   is_master_company_  VARCHAR2(20);      
BEGIN
   company_ := client_sys.Get_Item_Value('MASTER_COMPANY',attr_);
   is_master_company_ := Company_API.Get_Master_Company_Db(company_);   
   IF (is_master_company_ = 'FALSE') THEN
        Error_Sys.Record_General(lu_name_, 'NOTMASTERCOMPANY: This page can only be used by a Master Company for Group Consolidation.');
   END IF; 
END Validate_Master_Company;

FUNCTION Get_Selected_Currency_Code (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2) RETURN VARCHAR2
IS
  currency_code_   VARCHAR2(3);
BEGIN   
   IF (currency_type_ = 'AccountingCurrency') THEN
      currency_code_ := Get_Currency_Code(company_);
   ELSE
      currency_code_ := Get_Parallel_Acc_Currency(company_);
   END IF;
   RETURN currency_code_;
END Get_Selected_Currency_Code;


-- gelr:accounting_xml_data, begin
@UncheckedAccess
FUNCTION Get_Tax_Id_Number (
   company_ company_finance_tab.company%TYPE) RETURN VARCHAR2
IS
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      RETURN Tax_Liability_Countries_API.Get_Tax_Id_Number_Db(company_, Company_API.Get_Country_Db(company_), TRUNC(SYSDATE));
   $ELSE
      RETURN NULL;
   $END
END Get_Tax_Id_Number;
-- gelr:accounting_xml_data, end

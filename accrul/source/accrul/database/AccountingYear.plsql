-----------------------------------------------------------------------------
--
--  Logical unit: AccountingYear
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History 
--  ------  ------  ---------------------------------------------------------
--  991227  BAMA     Created
--  000302  Uma      Corrected Bug Id# 32901.
--  000908  HiMu     Added General_SYS.Init_Method
--  001206  LISV     For new Create Company concept added new view accounting_year_ect and accounting_year_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010905  Assalk   Added Set_Consolidated_Flag,Clear_Consolidated_Flag.
--  010905  JeGu     Simplified functions: Set_Consolidated_Flag, Clear_Consolidated_Flag,
--                   Added column open_bal_consolidated_db to view ACC_YEAR
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020312  ovjose   Removed Create Company translation method Create_Company_Translations___
--  021001  Nimalk   Removed usage of the view Company_Finance_Auth in ACC_YEAR,
--                   YEAR_END_FROM_YEAR_LOV,YEAR_END_TO_YEAR_LOV view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021106  KuPelk   IID ESFI110N Year End Accounting.
--  021127  kuPelk   Bug# 91592 Corrected by removing Execute_Update method .
--  021204  KuPelk   IID ESFI110N .Added new method as Close_Opened_Year.
--  021218  KuPelk   IID ESFI110N .Added new method as  Update_Year_Data__.
--  021218  GePelk   IID ESFI110N .Added new method as Change_Blance_State__.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  041005  WAPELK   Bug 45325 Merged.
--  090303  Jaralk   Bug 80877 Added IF condition in Open_Up_Closed_Year () 
--                   to check if the successive year is open before opening the current year
--  090309  WITOPL   Bug 82373, SKwP-2 - Final Closing of Period - Finally Closed Year Added
--  090807  Maaylk   Bug 81730. Added method Check_Exist()
--  100420  Nsillk   Modifications done to support update Company
--  110415  Sacalk   EASTONE-15173, Modified the view ACC_YEAR
--  110518  RUFELK   EASTONE-20019, Modified the Prepare_Insert___() method.
--  110719  Sacalk   FIDEAGLE-307 , Merged LCS Bug 96469, corrected in Prepare_insert___
--  130808  NIANLK   CAHOOK-1280: Added new check to validate Account Year leng
--  131111  Umdolk   PBFI-1318, Refactoring.
--  141123  ShFrlk   PRMF-3684, Corrected. Error due to records in [CURSOR get_period_info] not getting sorted at certain instances. Therefore, sorted by Accounting_Year and Accounting_Period.
--  151118  chiblk   STRFI-607 replace the enumeration in Prepare_Insert___.
--  160311  Clstlk   STRFI-1418 Merged LCS bug 127629, Added new method Find_Next_Available_Year().
--  170907  Bhhilk   STRFI-9708, Merged Bug 137379, Added new method Find_Previous_Available_Year().
--  200701  Jadulk  FISPRING20-6694 , Removed conacc related logic.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE Year_Period_Rec IS RECORD
(
   accounting_year     accounting_period_tab.accounting_year%TYPE,
   accounting_period   accounting_period_tab.accounting_period%TYPE,
   date_from           accounting_period_tab.date_from%TYPE,
   date_until          accounting_period_tab.date_until%TYPE
);

TYPE Year_Period_Tab IS TABLE OF Year_Period_Rec INDEX BY BINARY_INTEGER;


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        accounting_year_tab%ROWTYPE;
   empty_rec_     accounting_year_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   indrec_        Indicator_Rec;
   
   CURSOR get_data IS
      SELECT N1
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM   accounting_year_tab dest
                         WHERE  dest.company         = crecomp_rec_.company
                         AND    dest.accounting_year = src.N1);
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   any_rows_      := Exist_Any___(crecomp_rec_.company);

   IF (NOT any_rows_) AND (crecomp_rec_.user_defined = 'TRUE') THEN
      FOR k in 0..crecomp_rec_.number_of_years-1 LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            Assign_Values___(newrec_, crecomp_rec_.company, crecomp_rec_.acc_year + k);
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
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;
   ELSE
      IF ( (update_by_key_ AND (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE')) OR 
         (NOT any_rows_) ) THEN

         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-25,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := empty_rec_;

               newrec_.company           := crecomp_rec_.company;
               newrec_.accounting_year   := rec_.n1;
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
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         -- this statement is to add to the log that the Create company process for LUs is finished even if
         -- has been performed
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        accounting_year_tab%ROWTYPE;
   empty_rec_     accounting_year_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   indrec_        Indicator_Rec;
   
   CURSOR get_data IS
      SELECT accounting_year
      FROM   accounting_year_tab src
      WHERE  company = crecomp_rec_.old_company
      AND    NOT EXISTS (SELECT 1 
                         FROM   accounting_year_tab dest
                         WHERE  dest.company         = crecomp_rec_.company
                         AND    dest.accounting_year = src.accounting_year);

BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   any_rows_      := Exist_Any___(crecomp_rec_.company);

   IF (NOT any_rows_) AND (crecomp_rec_.user_defined = 'TRUE') THEN
      FOR k in 0..crecomp_rec_.number_of_years-1 LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            Assign_Values___(newrec_, crecomp_rec_.company, crecomp_rec_.acc_year + k);
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
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;
   ELSE
      IF ( (update_by_key_ AND (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE')) OR (NOT any_rows_) ) THEN
         FOR rec_ IN get_data LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-25,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := empty_rec_;
               Assign_Values___(newrec_, crecomp_rec_.company, rec_.accounting_year);
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
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         -- this statement is to add to the log that the Create company process for LUs is finished even if
         -- nothing has been performed
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_YEAR_API', 'CreatedWithErrors');
END Copy___;

PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;

   CURSOR get_data IS
      SELECT accounting_year
      FROM   accounting_year_tab
      WHERE  company = crecomp_rec_.company;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      pub_rec_.n1          := pctrec_.accounting_year;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

PROCEDURE Get_Year_Periods___(
   year_periods_            OUT Year_Period_Tab,
   company_                 IN  VARCHAR2,
   accounting_year_from_    IN  NUMBER,
   accounting_period_from_  IN  NUMBER,
   accounting_year_until_   IN  NUMBER,
   accounting_period_until_ IN  NUMBER, 
   include_year_end_        IN  BOOLEAN DEFAULT TRUE)
IS 
   yp_from_           VARCHAR2(20);
   yp_until_          VARCHAR2(20);
   include_ye_        VARCHAR2(1) := 'Y';
   period_from_       NUMBER;
   period_until_      NUMBER;

   CURSOR get_period_info IS
      SELECT accounting_year,
             accounting_period,
             date_from,
             date_until
      FROM   accounting_period_tab
      WHERE  company    = company_
      AND   ((Accounting_Period_API.Get_Year_Period__(accounting_year, accounting_period) >= yp_from_)  AND
             (Accounting_Period_API.Get_Year_Period__(accounting_year, accounting_period) <= yp_until_))
      AND   (include_ye_ = 'Y' OR (include_ye_ = 'N' AND year_end_period = 'ORDINARY'))
      ORDER BY accounting_year, accounting_period;
BEGIN   
   --validations
   Company_Finance_API.Exist(company_);
   Exist(company_, accounting_year_from_);
   Exist(company_, accounting_year_until_);
   
   period_from_  := Assign_Period___(company_, accounting_year_from_, accounting_period_from_, 'MIN');
   period_until_ := Assign_Period___(company_, accounting_year_until_, accounting_period_until_, 'MAX');

   Accounting_Period_API.Exist(company_, accounting_year_from_, period_from_);
   Accounting_Period_API.Exist(company_, accounting_year_until_, period_until_);
   yp_from_  := Accounting_Period_API.Get_Year_Period__(accounting_year_from_, period_from_);
   yp_until_ := Accounting_Period_API.Get_Year_Period__(accounting_year_until_, period_until_);
   IF (yp_from_ > yp_until_) THEN
      Error_SYS.Appl_General(lu_name_,
                             'FROMGTUNTIL: The from year and period is greater than the until year and period');
   END IF;
   
   -- get data into out table
   IF (NOT include_year_end_) THEN
      include_ye_ := 'N';
   END IF;

   OPEN get_period_info;
   FETCH get_period_info BULK COLLECT INTO year_periods_;
   CLOSE get_period_info;
END Get_Year_Periods___;

FUNCTION Assign_Period___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   supplied_acc_period_ IN NUMBER,
   min_or_max_          IN VARCHAR2) RETURN NUMBER
IS
BEGIN   
   IF (supplied_acc_period_ IS NOT NULL) THEN
      RETURN supplied_acc_period_;
   END IF;

   IF (min_or_max_ = 'MIN') THEN
      RETURN (Accounting_Period_API.Get_Min_Period(company_, accounting_year_));
   ELSIF (min_or_max_ = 'MAX') THEN 
      RETURN (Accounting_Period_API.Get_Max_Period(company_, accounting_year_));
   ELSE
      RETURN (Accounting_Period_API.Get_Max_Period(company_, accounting_year_));
   END IF;   
END Assign_Period___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
END Prepare_Insert___;

PROCEDURE Create_Year_Ledger_Info___(
   newrec_        IN accounting_year_tab%ROWTYPE,
   ledger_id_     IN VARCHAR2 DEFAULT NULL)
IS
   year_ledger_attr_ VARCHAR2(32000);
   info_             VARCHAR2(32000);
   objid_            VARCHAR2(32000);
   objversion_       VARCHAR2(32000);
   temp_attr_        VARCHAR2(32000);
   
   $IF Component_Intled_SYS.INSTALLED $THEN
      CURSOR get_ledger_info IS
         SELECT ledger_id
         FROM   internal_ledger_tab
         WHERE  company = newrec_.company;
   $END
BEGIN
   Client_SYS.Clear_Attr(year_ledger_attr_);
   Acc_Year_Ledger_Info_API.New__(info_, objid_, objversion_,year_ledger_attr_, 'PREPARE' );   
   Client_SYS.Add_To_Attr('COMPANY', newrec_.company, year_ledger_attr_);
   Client_SYS.Add_To_Attr('ACCOUNTING_YEAR', newrec_.accounting_year, year_ledger_attr_); 
   temp_attr_ := year_ledger_attr_;
   Client_SYS.Add_To_Attr('LEDGER_ID', NVL(ledger_id_,'00'), year_ledger_attr_);   
   Acc_Year_Ledger_Info_API.New__(info_, objid_, objversion_,year_ledger_attr_, 'DO' );

   $IF Component_Intled_SYS.INSTALLED $THEN
   IF (ledger_id_ IS NULL) THEN 
     FOR rec_ IN get_ledger_info LOOP
        -- to set the correct attr_ after the new
        year_ledger_attr_ := temp_attr_;
        Client_SYS.Add_To_Attr('LEDGER_ID', rec_.ledger_id, year_ledger_attr_);
        Acc_Year_Ledger_Info_API.New__(info_, objid_, objversion_,year_ledger_attr_, 'DO' );
      END LOOP;
   END IF;
   $END
END Create_Year_Ledger_Info___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT ACCOUNTING_YEAR_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   IF (NVL(Client_SYS.Get_Item_Value('CREATE_COMP', attr_),'FALSE') <> 'TRUE') THEN
      Create_Year_Ledger_Info___(newrec_);
   END IF;   
END Insert___;

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN accounting_year_tab%ROWTYPE )
IS
BEGIN
   Period_Delete_Allowed(remrec_.company, remrec_.accounting_year);   
   super(remrec_);
END Check_Delete___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_year_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (LENGTH(newrec_.accounting_year) != 4) THEN
      Error_SYS.Appl_General(lu_name_, 'ACCYEARNOTMACTCH: The accounting year should consist of four characters.');
   END IF;   
   super(newrec_, indrec_, attr_);     
END Check_Insert___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_         IN     VARCHAR2,
   accounting_year_ IN     NUMBER )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_,  
                              'YEARNOTEXIST: Accounting year ":P1" does not exist in company ":P2"',
                              TO_CHAR(accounting_year_),
                              company_);
   super(company_, accounting_year_);
END Raise_Record_Not_Exist___;

PROCEDURE Assign_Values___ (
   newrec_          OUT accounting_year_tab%ROWTYPE,
   company_         IN  VARCHAR2,
   accounting_year_ IN  VARCHAR2 )
IS   
BEGIN
   newrec_.company               := company_;
   newrec_.accounting_year       := accounting_year_;
END Assign_Values___; 
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Create_Acc_Year_Ledger_Info(
   company_    IN VARCHAR2,
   ledger_id_  IN VARCHAR2 )
IS   
   newrec_     accounting_year_tab%ROWTYPE;
   
   CURSOR get_year_rec IS
      SELECT accounting_year 
      FROM   accounting_year_tab
      WHERE  company = company_
      ORDER BY accounting_year;   
BEGIN
   newrec_.company := company_;
   FOR rec_ IN get_year_rec LOOP
      newrec_.accounting_year := rec_.accounting_year;
      Create_Year_Ledger_Info___(newrec_, ledger_id_);
   END LOOP;
END Create_Acc_Year_Ledger_Info;

@UncheckedAccess
PROCEDURE Exist (
   accounting_year_  IN VARCHAR2,
   company_          IN VARCHAR2 )
IS
BEGIN
   Exist(company_, TO_NUMBER(accounting_year_));
END Exist;

-- Exist when keys are not in the proper order
@UncheckedAccess
PROCEDURE Exist (
   accounting_year_  IN NUMBER,
   company_          IN VARCHAR2)
IS
BEGIN
   Exist(company_, accounting_year_); 
END Exist;

PROCEDURE Period_Delete_Allowed (
   company_               IN VARCHAR2,
   accounting_year_       IN NUMBER )
IS
   exist_periods_               VARCHAR2(5);      
BEGIN
   Accounting_Period_API.Year_Exist(exist_periods_, company_, accounting_year_); 
   IF (exist_periods_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'NO_PER_DEL: The periods for this year have to be removed first');
   END IF;    
END Period_Delete_Allowed;

@UncheckedAccess
FUNCTION Get_Opening_Balanecs_Db (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN Acc_Year_Ledger_Info_API.Get_Opening_Balanecs_Db (company_ ,
                                                            accounting_year_ , 
                                                            '00');
END Get_Opening_Balanecs_Db;

--Done NN
@UncheckedAccess
FUNCTION Get_Opening_Balances (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN Acc_Year_Ledger_Info_API.Get_Opening_Balances (company_ ,
                                                         accounting_year_ , 
                                                         '00');
END Get_Opening_Balances;

FUNCTION Get_Max_Accounting_Year (
   company_          IN VARCHAR2 ) RETURN NUMBER
IS
   CURSOR get_max_year IS
      SELECT MAX(accounting_year)
      FROM   ACCOUNTING_YEAR_TAB
      WHERE  company = company_;
   max_year_ NUMBER;
BEGIN
   OPEN  get_max_year;
   FETCH get_max_year INTO max_year_;
   CLOSE get_max_year;
   RETURN max_year_;
END Get_Max_Accounting_Year;
--Done NN
@UncheckedAccess
FUNCTION Get_Closing_Balances (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN Acc_Year_Ledger_Info_API.Get_Closing_Balances (company_ ,
                                                         accounting_year_ , 
                                                         '00');
END Get_Closing_Balances;

--Done NN
@UncheckedAccess
FUNCTION Get_Closing_Balances_Db (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   RETURN Acc_Year_Ledger_Info_API.Get_Closing_Balances_Db (company_ ,
                                                         accounting_year_ , 
                                                         '00');
END Get_Closing_Balances_Db;

@UncheckedAccess
FUNCTION Check_Exist (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(company_, accounting_year_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist;


PROCEDURE Get_Year_Periods(
   year_periods_            OUT Year_Period_Tab,
   company_                 IN  VARCHAR2,
   accounting_year_from_    IN  NUMBER,
   accounting_period_from_  IN  NUMBER,
   accounting_year_until_   IN  NUMBER,
   accounting_period_until_ IN  NUMBER, 
   include_year_end_        IN  BOOLEAN DEFAULT TRUE)
IS
BEGIN
   Get_Year_Periods___(year_periods_,
                       company_,
                       accounting_year_from_,
                       accounting_period_from_,  
                       accounting_year_until_,   
                       accounting_period_until_, 
                       include_year_end_);        
END Get_Year_Periods;


PROCEDURE Get_Year_Periods(
   year_periods_            OUT Year_Period_Tab,
   company_                 IN  VARCHAR2,
   accounting_year_from_    IN  NUMBER,
   accounting_year_until_   IN  NUMBER,
   include_year_end_        IN  BOOLEAN DEFAULT TRUE)
IS
BEGIN
   Get_Year_Periods___(year_periods_,
                       company_,
                       accounting_year_from_,
                       NULL,  
                       accounting_year_until_,   
                       NULL, 
                       include_year_end_);        
END Get_Year_Periods;



PROCEDURE Create_Accounting_Calender (
   info_                        OUT   VARCHAR2,
   company_                     IN    VARCHAR2,
   source_year_                 IN    NUMBER,
   from_year_                   IN    NUMBER,
   until_year_                  IN    NUMBER,
   copy_user_groups_            IN    VARCHAR2,
   copy_user_grp_per_series_    IN    VARCHAR2, 
   vou_ser_create_method_db_    IN    VARCHAR2,
   acc_period_create_method_db_ IN    VARCHAR2)
IS
   newrec_                   accounting_year_tab%ROWTYPE;
   no_of_years_              NUMBER;
   error_                    BOOLEAN := FALSE;
   success_                  BOOLEAN := FALSE;
  
   CURSOR get_ledger_ids IS
      SELECT * 
      FROM   all_ledger_tab
      WHERE  company  = company_
      AND    ledger_id NOT IN ('*');
BEGIN
   IF (NOT Check_Exist___(company_, source_year_)) THEN
      Error_SYS.Record_General(lu_name_, 'NOSOURCEYEAR: Source year :P1 does not exist in company :P2', source_year_, company_);
   END IF;
   IF (from_year_ > until_year_) THEN
      Error_SYS.Record_General(lu_name_, 'UNTILLESSFROM: Until Year should be greater than From Year in company :P1', company_);
   END IF;
   no_of_years_ := until_year_ - from_year_;
   FOR k IN 0..no_of_years_ LOOP
      IF (NOT Check_Exist___(company_, (from_year_ + k))) THEN
         Assign_Values___(newrec_, company_, from_year_ + k);
         New___(newrec_);
         Accounting_Period_API.Create_Accounting_Periods(company_, source_year_, from_year_, newrec_.accounting_year, acc_period_create_method_db_);
         FOR rec_ IN get_ledger_ids LOOP
          -- Acc_Year_Ledger_Info_Api.Assign_Values_For_Year_Info(company_ , from_year_ + k ,rec_.ledger_id );
           Acc_Period_Ledger_Info_API.Create_Accounting_Periods(company_ ,rec_.ledger_id , newrec_.accounting_year , source_year_ , acc_period_create_method_db_);
         END LOOP;
         IF (NVL(copy_user_groups_,'FALSE') = 'FALSE') THEN             
            User_Group_Period_API.Create_User_Groups_Per_Year(company_, source_year_, newrec_.accounting_year, acc_period_create_method_db_);
         END IF;
         IF (vou_ser_create_method_db_ != 'EXCLUDE') THEN
            Voucher_No_Serial_API.Create_Voucher_Series(company_,
                                                        source_year_,
                                                        newrec_.accounting_year,
                                                        vou_ser_create_method_db_);
         END IF;                                             
         IF (NVL(copy_user_grp_per_series_, 'FALSE') = 'FALSE') THEN
            Voucher_Type_User_Group_API.Create_Vou_Type_User_Group(company_,
                                                                   source_year_,
                                                                   newrec_.accounting_year);
         END IF;         
         success_ := TRUE; 
      ELSE
         error_ := TRUE;
      END IF; 
   END LOOP; 
   IF (success_ AND (NOT error_)) THEN
      info_ := 'SUCCESS';
   ELSIF (success_ AND error_) THEN
      info_ := 'PARTIAL';
   ELSE
      info_ := 'ERROR';
   END IF;
END Create_Accounting_Calender;

@UncheckedAccess
FUNCTION Find_Next_Available_Year (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER) RETURN NUMBER
IS
   next_year_ NUMBER;
   CURSOR get_next_year IS
      SELECT accounting_year
      FROM   Accounting_Year_Tab
      WHERE  company         = company_
      AND    accounting_year > accounting_year_
      AND    rownum          = 1
      ORDER BY accounting_year;
BEGIN  
   OPEN  get_next_year; 
   FETCH get_next_year INTO next_year_;   
   CLOSE get_next_year;
   RETURN next_year_; 
END Find_Next_Available_Year;

@UncheckedAccess
FUNCTION Find_Previous_Available_Year (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER) RETURN NUMBER
IS
   pre_year_ NUMBER;
   CURSOR get_pre_year IS
      SELECT accounting_year
      FROM   Accounting_Year_Tab
      WHERE  company         = company_
      AND    accounting_year < accounting_year_      
      ORDER BY accounting_year DESC;
BEGIN  
   OPEN get_pre_year; 
   FETCH get_pre_year INTO pre_year_;
   CLOSE get_pre_year;
   RETURN pre_year_; 
END Find_Previous_Available_Year;
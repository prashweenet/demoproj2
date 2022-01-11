-----------------------------------------------------------------------------
--
--  Logical unit: VoucherNoSerial
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960416  xxxx     Base Table to Logical Unit Generator 1.0A
--  961223  MAGU     Added messages
--  970114  MAGU     Modified the message in Unpack_Check_Update___
--  970320  ANDJ     Deleted CLOSE Cursor in Check_series_group__
--  970326  ANDJ     Added attr accounting_year to...
--  970703  SLKO     Converted to Foundation 1.2.2d
--  970812  ANDJ     Fixed bug 97-0028. Added assignment in Unpack_Check_Update__
--  980209  ARBI     Corrected Rollback_PCA_Voucher_Serial_No
--  980320  ARBI     User group in Rollback_PCA_Voucher_Serial_No needn't be default
--  980921  Bren     Master Slave Connection
--                   Send_Vou_Serial_Info___,  Send_Vou_Serial_Info_Delete___,
--                   Send_Vou_Serial_Info_Modify___,  Receive_Vou_Serial_Info___.
--  990217  ANDJ     Bug # 9124 fixed.
--  990412  UPPE     Added PROCEDURE Exist_Db (db_value IN VARCHAR2)
--  990412  JPS      Performed Template changes. (Foundation 2.2.1)
--  990426  SHA      Fixed bug no.22044
--  000216  Uma      Corrected the dynamic cursor in Rollback_PCA_Voucher_Serial_No.
--  000309  Uma      Closed dynamic cursors in Exception.
--  000321  Bren     Added Create_Voucher_No.
--  000414  SaCh     Added RAISE to exceptions.
--  000801  Uma      A536 - Journal Code.
--  000804  Uma      Changed Create_Voucher_No with respect to A536
--  000921  Uma      Corrected BugId #48194. Added ledger validations in Unpack_Check_Update.
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001017  Uma      Corrected Bug #49503.
--  001201  OVJOSE   For new Create Company concept added new view voucher_no_serial_ect and voucher_no_serial_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010221  ToOs     Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010427  LiSv     For new Create Company concept remarked procedure Create_Voucher_No.
--  010510  JeGu     Bug #21705 Implementation New Dummyinterface
--                   Changed Insert__ RETURNING rowid INTO objid_
--  010514  OVJOSE   Unmarked Create_Voucher_No and added a defualt in parameter.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010719  SUMALK   Bug 22932 Fixed.(Removed Dynamic Sql and added Execute Immediate).
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010820  JeGu     Bug #23726 New version of procedure Check_Voucher_No
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020320  Uma      Merged Bug# 28673. Added FOUND condition.
--  020322  AsSalk   Changed the process where voucher serial is copied.Call ID 80321.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in VOUCHER_NO_SERIAL view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  030731  Nimalk   SP4 Merge
--  031017  Brwelk   Calling Cascade_Delete from Delete___.
--  040326  Gepelk   2004 SP1 Merge
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  040920  Ingulk   FITH337A - Added Period field as a key and added a method Auto_Voucher_No_Serial
--  041001  Ingulk   FITH337A - Added a method Is_Period_Exist
--  041117  Ingulk   Call ID 119545 Changes to the method Create_Voucher_No()
--  051103  Ingulk   Call ID 127747 added a cursor get_accounting_period to the method Create_Voucher_No()
--  051118  WAPELK  Merged the Bug 52783. Correct the user group variable's width.
--  060219  GADALK   B129952 - Changed Get_Next_Voucher_No
--  060306  CHHULK   B132027 - Corrections in Rollback_Pca_Voucher_Serial_No()
--  150306  CHHULK   B132027 - Changes in Global constant.
--  070108  Shsalk   LCS Merge 62604, Modified procedure Create_Voucher_No. 
--  070518  Nimalk   LCS Merge 64901, Corrected. Created new sub view to handle the order by problem for accounting year. 
--  070702  Shsalk   LCS Merge 66047. Changes made in VOUCHER_NO_SERIAL_YR sub view.
--  080421  Yothlk   Bug 72344, Corrected. Changes made in Copy___ method.
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statements for VIEWYR.
--  090717  ErFelk   Bug 83174, Replaced constant DESIGN_EROR with DESIGN_ERROR in Rollback_Pca_Voucher_Serial_No.
--  090810  LaPrlk   Bug 79846, Removed the precisions defined for NUMBER type variables.
--  091104  Jaralk   Bug 86478, corrected.removed the reference to VoucherTypeDetail  of voucher_type column
--  091205  HimRlk   Reverse engineering, Changed the REF from VoucherTypeDetail to VoucherType in column voucher_type in view comments.
--  100217  cldase   EAFH-1516, Modified creation of voucher series per voucher type to support user defined calendar.
--  110420  Sacalk   EASTONE-15863, Added an ORDER BY clause to view VOUCHER_NO_SERIAL 
--  111018  Shdilk   SFI-135, Conditional compilation.
--  120403  Clstlk   EASTRTM-8352, LCS Merge( Bug 101535).
--  121123  Thpelk   Bug 106680 - Modified Conditional compilation to use single component package.
--  121207  Maaylk   PEPA-183, Removed global variables
--  130304  Thpelk   Bug 108678 - Removed NOCHECK for VOUCHER_NO_SERIAL View.
--  130327  THPELK   Bug 108867 - Corrected Get_Next_Voucher_No().
--  131101  Umdolk   PBFI-2121, Refactoring
--  140402  Shedlk   PBFI-6177, Merged LCS bug 115914
--  140402  THPELK   PRFI-3936, Corrected.
--  151008  chiblk   STRFI-200, New__ changed to New___ in Create_Voucher_No
--  151118  Bhhilk   STRFI-39, Modified DefaultType enumeration to FinanceYesNo.
--  151222  CHWTLK   STRFI-831, Merge of Bug-126216, Modified Check_Update___();
--  190107  Nudilk   Bug 146161, Corrected.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Record___(
   newrec_   IN VOUCHER_NO_SERIAL_TAB%ROWTYPE )
IS
BEGIN
   IF (newrec_.SERIE_UNTIL <= newrec_.SERIE_FROM) THEN
      Error_SYS.Record_General(lu_name_,'SERIE_UNTIL: Serial until cannot be smaller than serial from');
   END IF;

   IF (newrec_.CURRENT_NUMBER < newrec_.SERIE_FROM) THEN
      Error_SYS.Record_General(lu_name_,'ACTUAL_NUMB_1: Current number must be larger than serial from');
   END IF;

   IF (newrec_.CURRENT_NUMBER > newrec_.SERIE_UNTIL) THEN
      Error_SYS.Record_General(lu_name_,'ACTUAL_NUMB_2: Current number must be smaller than serial until');
   END IF;
END Validate_Record___;


PROCEDURE Check_And_Validate___ ( newrec_ IN VOUCHER_NO_SERIAL_TAB%ROWTYPE )
IS
   exists_  VARCHAR2(5);
BEGIN
   Check_Series__(exists_,newrec_.company,newrec_.voucher_type,newrec_.accounting_year,newrec_.period,newrec_.serie_from,newrec_.serie_until,NULL);
   IF (exists_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'SERIES_EXIST: The series overlaps an existing series for another voucher type');
   END IF;
   Validate_Record___(newrec_);
   IF (newrec_.serie_from = 0) THEN
      Error_SYS.Record_General(lu_name_,'FROMSERIES_ZERO: Voucher series cannot start from number 0');
   END IF;
END Check_And_Validate___;


PROCEDURE Check_No_Data_Found___ (
   msg_         OUT VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   data_found_  IN BOOLEAN )
IS
BEGIN
   IF ( NOT data_found_ ) THEN
      msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedSuccessfully', msg_);
   ELSE
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedWithErrors');
      END IF;
   END IF;
END Check_No_Data_Found___;


PROCEDURE Add_Serie___ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   series_from_     IN NUMBER,
   series_until_    IN NUMBER,
   current_number_  IN NUMBER,
   period_          IN NUMBER )
IS
   newrec_  VOUCHER_NO_SERIAL_TAB%ROWTYPE;
BEGIN
   newrec_.company          := company_;
   newrec_.voucher_type     := voucher_type_;
   newrec_.accounting_year  := accounting_year_;
   newrec_.serie_from       := series_from_;
   newrec_.serie_until      := series_until_;
   newrec_.current_number   := current_number_;
   newrec_.period           := period_;
   New___(newrec_);  
END Add_Serie___;


PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_           VARCHAR2(2000);
   msg_            VARCHAR2(2000);
   i_              NUMBER := 0;
   end_year_       NUMBER;
   data_found_     BOOLEAN := FALSE;
   update_by_key_  BOOLEAN;
   any_rows_       BOOLEAN := FALSE;
   ndummy_         NUMBER;

   CURSOR get_distinct_voucher_type IS
      SELECT DISTINCT C1
      FROM   Create_Company_Template_Pub
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version;

   CURSOR get_data IS
      SELECT C1, N1, N2, N3,N4
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM VOUCHER_NO_SERIAL_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.accounting_year = src.N1
                         AND dest.voucher_type = src.C1
                         AND dest.period = src.N4);
   CURSOR period_99_exist IS
      SELECT 1
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    n4          = 99;
      
      
   CURSOR get_distinct_year_vou_type IS
      SELECT DISTINCT C1, N1
      FROM   Create_Company_Template_Pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1 
                        FROM VOUCHER_NO_SERIAL_TAB dest
                        WHERE dest.company = crecomp_rec_.company
                        AND dest.accounting_year = src.N1
                        AND dest.voucher_type = src.C1
                        AND dest.period = 99);

BEGIN
   Client_Sys.Clear_Attr(attr_);
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF (update_by_key_) THEN
      IF (Company_Finance_API.Get_User_Def_Cal(crecomp_rec_.company) = 'FALSE') THEN
         IF (Company_Finance_API.Get_Use_Vou_No_Period(crecomp_rec_.company) = 'FALSE') THEN
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               SAVEPOINT make_company_insert;
               BEGIN
                  Add_Serie___(crecomp_rec_.company, rec_.c1, rec_.n1, rec_.n2, rec_.n3, rec_.n2, 99);
                  data_found_ := TRUE;
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
               END;
            END LOOP;
         ELSE
            Auto_Voucher_No_Serial___(data_found_, crecomp_rec_.company, crecomp_rec_.template_id);
         END IF;
      END IF;
   ELSE
      IF (Company_Finance_API.Get_Use_Vou_No_Period(crecomp_rec_.company) = 'FALSE') THEN
         any_rows_ := Exist_Any___(crecomp_rec_.company);
         IF (NOT any_rows_) THEN
            IF (crecomp_rec_.user_defined = 'TRUE') THEN
               end_year_ := crecomp_rec_.acc_year+crecomp_rec_.number_of_years-1;
               FOR rec_ IN get_distinct_voucher_type LOOP
                  FOR year_ IN crecomp_rec_.acc_year..end_year_ LOOP
                     BEGIN
                        Add_Serie___(crecomp_rec_.company, rec_.c1, year_,
                                     year_||'000000', year_||'999999',
                                     year_||'000000', 99);
                        data_found_ := TRUE;
                     EXCEPTION
                        WHEN OTHERS THEN
                            msg_ := SQLERRM;
                            @ApproveTransactionStatement(2014-03-24,dipelk)
                            ROLLBACK TO make_company_insert;
                            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                     END;
                  END LOOP;
               END LOOP;
            ELSE
               OPEN period_99_exist;
               FETCH period_99_exist INTO ndummy_;
               CLOSE period_99_exist;
               IF ndummy_ IS NOT NULL THEN
                  FOR rec_ IN get_data LOOP
                     i_ := i_ + 1;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     SAVEPOINT make_company_insert;
                     BEGIN
                        Add_Serie___(crecomp_rec_.company, rec_.c1, rec_.n1, rec_.n2, rec_.n3, rec_.n2, 99);
                        data_found_ := TRUE;
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                     END;
                  END LOOP;
               ELSE
                  FOR rec_ IN get_distinct_year_vou_type LOOP
                     i_ := i_ + 1;
                     @ApproveTransactionStatement(2018-12-04,nudilk)
                     SAVEPOINT make_company_insert;
                     BEGIN
                        Add_Serie___(crecomp_rec_.company, rec_.c1, rec_.n1,
                                     rec_.n1||'000000', rec_.n1||'999999',
                                     rec_.n1||'000000', 99);
                        data_found_ := TRUE;
                     EXCEPTION
                        WHEN OTHERS THEN
                           msg_ := SQLERRM;
                           Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                     END;
                  END LOOP;
               END IF;
            END IF;
         END IF;
      ELSE
         Auto_Voucher_No_Serial___(data_found_, 
                                   crecomp_rec_.company, 
                                   crecomp_rec_.template_id, 
                                   crecomp_rec_.acc_year,
                                   crecomp_rec_.number_of_years, 
                                   crecomp_rec_.user_defined);
      END IF;
   END IF;
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      @ApproveTransactionStatement(2014-03-24,dipelk)
      ROLLBACK TO make_company_insert;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_          VARCHAR2(2000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        VOUCHER_NO_SERIAL_TAB%ROWTYPE;
   empty_rec_     VOUCHER_NO_SERIAL_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   any_rows_      BOOLEAN := FALSE;
   data_found_    BOOLEAN := FALSE;
   update_by_key_ BOOLEAN;

   serei_from_    NUMBER;
   serei_until_   NUMBER;
   year_exist_    VARCHAR2(5);
   period_exist_  VARCHAR2(5);
   last_period_   NUMBER;
   acc_year_      NUMBER;
   indrec_        Indicator_Rec;
   company_finance_rec_    Company_Finance_API.Public_Rec;
   
   CURSOR get_data IS
      SELECT accounting_year, voucher_type, period, serie_from, serie_until, current_number
      FROM   VOUCHER_NO_SERIAL_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND    NOT EXISTS (SELECT 1 
                         FROM VOUCHER_NO_SERIAL_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.accounting_year = src.accounting_year
                         AND dest.voucher_type = src.voucher_type
                         AND dest.period = src.period)
   AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = src.company
               AND   vt.voucher_type = src.voucher_type),' ') IN ('00','*',' ');

   CURSOR get_voucher_types IS
      SELECT DISTINCT voucher_type
      FROM   Voucher_Type_Tab
      WHERE  company    = crecomp_rec_.company;

   CURSOR get_year IS
      SELECT DISTINCT accounting_year
      FROM   accounting_period_tab
      WHERE  company    = crecomp_rec_.company
      ORDER BY accounting_year ASC;

BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   company_finance_rec_ := Company_Finance_API.Get(crecomp_rec_.company);
   IF (crecomp_rec_.user_defined = 'TRUE' AND company_finance_rec_.use_vou_no_period = 'TRUE') THEN
      FOR get_year_ IN get_year LOOP
         acc_year_ := TO_NUMBER(TO_CHAR(get_year_.accounting_year));
         Auto_Voucher_No_Serial___(data_found_,
                                   crecomp_rec_.company, 
                                   crecomp_rec_.template_id, 
                                   acc_year_,
                                   crecomp_rec_.number_of_years, 
                                   crecomp_rec_.user_defined,
                                   TRUE);
      END LOOP;
   ELSIF (crecomp_rec_.user_defined = 'FALSE' AND 
          Company_Finance_API.Get_Use_Vou_No_Period(crecomp_rec_.old_company) = 'FALSE' AND 
           company_finance_rec_.use_vou_no_period = 'TRUE') THEN
      FOR get_year_ IN get_year LOOP
         serei_from_ := TO_NUMBER(TO_CHAR(get_year_.accounting_year)||'000000');
         Accounting_Period_API.Year_Exist(year_exist_,crecomp_rec_.company,get_year_.accounting_year);
         IF (year_exist_ = 'TRUE') THEN
            last_period_  := Accounting_Period_API.Get_Max_Period(crecomp_rec_.company,get_year_.accounting_year);
            IF Accounting_Period_API.Is_Year_Close(crecomp_rec_.company,get_year_.accounting_year,last_period_) = 'TRUE' THEN
               last_period_ := last_period_ - 1;
            END IF;
            FOR period_ IN 1..last_period_ LOOP
               Accounting_Period_API.Periodexist(period_exist_,crecomp_rec_.company,get_year_.accounting_year,period_);
               IF (period_exist_ = 'TRUE') THEN
                  serei_from_  := serei_from_ + 10000;
                  serei_until_ := serei_from_ + 9999;
                  FOR get_voucher_types_ IN get_voucher_types LOOP
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     SAVEPOINT make_company_insert;
                     data_found_ := TRUE;
                     BEGIN
                        
                        newrec_ := empty_rec_;

                        newrec_.company := crecomp_rec_.company;
                        newrec_.accounting_year := get_year_.accounting_year;
                        newrec_.voucher_type := get_voucher_types_.voucher_type;
                        newrec_.period := period_;
                        newrec_.serie_from := serei_from_;
                        newrec_.serie_until := serei_until_;
                        newrec_.current_number := serei_from_;
                        Client_SYS.Clear_Attr(attr_);
                        indrec_ := Get_Indicator_Rec___(newrec_);
                        IF NOT Check_Exist___(newrec_.company, newrec_.voucher_type, newrec_.accounting_year, newrec_.period) THEN
                           Check_Insert___(newrec_, indrec_, attr_);                        
                           Insert___(objid_, objversion_, newrec_, attr_);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                            msg_ := SQLERRM;
                            @ApproveTransactionStatement(2014-03-24,dipelk)
                            ROLLBACK TO make_company_insert;
                            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                     END;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) AND
         (crecomp_rec_.user_defined = 'TRUE') THEN

         FOR get_voucher_types_ IN get_voucher_types LOOP
            FOR year_ IN 0..crecomp_rec_.number_of_years-1 LOOP
               acc_year_ := crecomp_rec_.acc_year + year_;
               data_found_ := TRUE;
               BEGIN
                   Add_Serie___(crecomp_rec_.company, get_voucher_types_.voucher_type, acc_year_,
                   acc_year_||'000000', acc_year_||'999999',
                   acc_year_||'000000', 99);
               EXCEPTION
                  WHEN OTHERS THEN
                      msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
               END;
            END LOOP;
         END LOOP;
      ELSE
         IF (update_by_key_ AND ( company_finance_rec_.user_def_cal = 'FALSE') OR
             (NOT any_rows_)) THEN
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               SAVEPOINT make_company_insert;
               data_found_ := TRUE;
               BEGIN                 
                  newrec_ := empty_rec_;                 
                  newrec_.voucher_type      := rec_.voucher_type;
                  newrec_.accounting_year   := rec_.accounting_year;
                  newrec_.serie_from        := rec_.serie_from;
                  newrec_.serie_until       := rec_.serie_until;
                  newrec_.period            := rec_.period;
                  newrec_.current_number    := rec_.current_number;
                  newrec_.company           := crecomp_rec_.company;
                  newrec_.current_number    := newrec_.serie_from;
                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
      END IF;
   END IF;
   IF ((update_by_key_) OR (NOT any_rows_)) THEN
      Check_No_Data_Found___(msg_, crecomp_rec_, data_found_);
   ELSE
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'VOUCHER_NO_SERIAL_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT voucher_type, accounting_year, serie_from, serie_until, period
      FROM   voucher_no_serial_tab vns
      WHERE  company = crecomp_rec_.company      
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = vns.company
               AND   vt.voucher_type = vns.voucher_type),' ') IN ('00','*',' ');

BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.voucher_type;
      pub_rec_.n1 := pctrec_.accounting_year;
      pub_rec_.n2 := pctrec_.serie_from;
      pub_rec_.n3 := pctrec_.serie_until;
      pub_rec_.n4 := pctrec_.period;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;


PROCEDURE Add_Vou_Num_Ser_Per_Period___ (
   data_found_  OUT BOOLEAN,   
   company_     IN VARCHAR2,
   template_id_ IN VARCHAR2,
   year_        IN NUMBER,
   is_copy_     IN BOOLEAN DEFAULT FALSE )
IS
   serei_from_    NUMBER;
   serei_from_str_ VARCHAR2(20);
   serei_until_   NUMBER;
   msg_           VARCHAR2(2000);
   year_exist_    VARCHAR2(5);
   period_exist_  VARCHAR2(5);
   last_period_   NUMBER;

   CURSOR get_voucher_types IS
      SELECT distinct c1
      FROM   Create_Company_Tem_Detail_Tab
      WHERE  component   = 'ACCRUL'
      AND    lu          = 'VoucherType'
      AND    template_id = template_id_;

   CURSOR get_voucher_types_comp_ IS
      SELECT distinct voucher_type
      FROM   Voucher_Type_Tab
      WHERE  company    = company_;
BEGIN
   data_found_ := FALSE;
   serei_from_str_ := TO_CHAR(year_)||'00000000';
   serei_from_ := TO_NUMBER(SUBSTR(serei_from_str_, 3));
   Accounting_Period_API.Year_Exist(year_exist_,company_,year_);
   IF (year_exist_ = 'TRUE') THEN
      last_period_  := Accounting_Period_API.Get_Max_Period(company_,year_);
      IF Accounting_Period_API.Is_Year_Close(company_,year_,last_period_) = 'TRUE' THEN
         last_period_ := last_period_ - 1;
      END IF;
      FOR period_ IN 1..last_period_ LOOP
         Accounting_Period_API.Periodexist(period_exist_,company_,year_,period_);
         IF (period_exist_ = 'TRUE') THEN
            serei_from_  := serei_from_ + 1000000;
            serei_until_ := serei_from_ + 999999;

            IF (is_copy_ = TRUE) THEN
               FOR get_voucher_types_ IN get_voucher_types_comp_ LOOP
                  data_found_ := TRUE;
                  BEGIN
                     IF NOT Check_Exist___(company_, get_voucher_types_.voucher_type, year_, period_) THEN
                        Add_Serie___(company_, get_voucher_types_.voucher_type, year_, serei_from_,
                                     serei_until_, serei_from_, period_);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                  END;
               END LOOP;
            ELSE
               FOR get_voucher_types_ IN get_voucher_types LOOP
                  data_found_ := TRUE;
                  BEGIN
                     IF NOT Check_Exist___(company_, get_voucher_types_.c1, year_, period_) THEN
                        Add_Serie___(company_, get_voucher_types_.c1, year_, serei_from_,
                                     serei_until_, serei_from_, period_);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, 'VOUCHER_NO_SERIAL_API', 'Error', msg_);
                  END;
               END LOOP;
            END IF;
         END IF;
      END LOOP;
   END IF;
END Add_Vou_Num_Ser_Per_Period___;


PROCEDURE Auto_Voucher_No_Serial___ (
   data_found_      OUT BOOLEAN,
   company_         IN VARCHAR2,
   template_id_     IN VARCHAR2,
   acc_year_        IN NUMBER DEFAULT NULL,
   number_of_years_ IN NUMBER DEFAULT NULL,
   user_defined_    IN VARCHAR2 DEFAULT NULL,
   is_copy_         IN BOOLEAN DEFAULT FALSE  )
IS
   temp_data_found_  BOOLEAN := FALSE;

   CURSOR get_year IS
      SELECT distinct n1
      FROM   Create_Company_Tem_Detail_Tab
      WHERE  component   = 'ACCRUL'
      AND    lu          = 'VoucherNoSerial'
      AND    template_id = template_id_
      ORDER BY n1 asc;
BEGIN
   data_found_ := FALSE;
   IF (user_defined_ = 'TRUE' AND acc_year_ IS NOT NULL AND number_of_years_ IS NOT NULL) THEN
      FOR year_ IN acc_year_..acc_year_+number_of_years_ LOOP
         Add_Vou_Num_Ser_Per_Period___(temp_data_found_, company_, template_id_, year_, is_copy_ );
         IF (temp_data_found_) THEN
            data_found_ := TRUE;
         END IF;
      END LOOP;
   ELSE
      FOR get_year_ IN get_year LOOP
         Add_Vou_Num_Ser_Per_Period___(temp_data_found_, company_, template_id_, get_year_.n1);
         IF (temp_data_found_) THEN
            data_found_ := TRUE;
         END IF;
      END LOOP;
   END IF;
END Auto_Voucher_No_Serial___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN VOUCHER_NO_SERIAL_TAB%ROWTYPE )
IS
   exists_ VARCHAR2(10);
BEGIN   
   IF (exists_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'NO_DEL_SER1: The series cannot be deleted it exists in the GL or wait table or has a group attached to it');
   END IF;
   Voucher_Type_User_Group_API.Voucher_Serie_Delete_Allowed(remrec_.company, remrec_.voucher_type, remrec_.accounting_year);
   IF (Voucher_API.Is_Vou_Exist(remrec_.company, remrec_.voucher_type,
                                remrec_.accounting_year, remrec_.serie_from, remrec_.serie_until) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'NO_DEL_SER2: The series cannot be deleted it is being used');
   END IF;   
   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN VOUCHER_NO_SERIAL_TAB%ROWTYPE )
IS
BEGIN   
   super(objid_, remrec_);   
   Voucher_Type_User_Group_API.Cascade_Delete(remrec_.company, remrec_.accounting_year, remrec_.voucher_type);   
END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_no_serial_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
  period_updated_  BOOLEAN := FALSE;
BEGIN
   IF (Company_Finance_API.Get_Use_Vou_No_Period(newrec_.company) = 'TRUE') THEN      
      Accounting_Period_API.Exist(newrec_.company,newrec_.accounting_year,newrec_.period);
   ELSE
      newrec_.period := 99;
      period_updated_ := TRUE;
   END IF;
   Check_And_Validate___(newrec_); 
   super(newrec_, indrec_, attr_);   
   IF (period_updated_) THEN
      Client_SYS.Add_To_Attr('PERIOD', newrec_.period, attr_);
   END IF;
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_no_serial_tab%ROWTYPE,
   newrec_ IN OUT voucher_no_serial_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   current_no_exp EXCEPTION;    
   is_used_       VARCHAR2(5);
   ledger_id_     VARCHAR2(10); 
   exists_        VARCHAR2(10);  
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
BEGIN
   ledger_id_ := Voucher_Type_API.Get_Ledger_Id(oldrec_.company, oldrec_.voucher_type);
   IF (ledger_id_ NOT IN ( '*','00')) THEN
      Voucher_Type_API.Is_Voucher_Type_Used_Internal ( is_used_, oldrec_.company, oldrec_.voucher_type, ledger_id_, newrec_.accounting_year);
      IF (is_used_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,'UPNOALOW: You cannot modify the voucher series '||
                             'since there are vouchers for Voucher Type :P1', oldrec_.voucher_type);
      END IF;
   END IF;
         
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (indrec_.current_number) THEN
      -- serie_from is not being changed in the form
      IF (Voucher_API.Is_Vou_Exist(newrec_.company, 
                                   newrec_.voucher_type,
                                   newrec_.accounting_year, 
                                   newrec_.serie_from,
                                   newrec_.serie_until) = 'TRUE') THEN
         RAISE current_no_exp;
      END IF;
   END IF;
   
   Get_Id_Version_By_Keys___(objid_,
                             objversion_,
                             newrec_.company,
                             newrec_.voucher_type,
                             newrec_.accounting_year,
                             newrec_.period);
   Check_Series__(exists_,
                  newrec_.company,
                  newrec_.voucher_type,
                  newrec_.accounting_year,
                  newrec_.period,
                  newrec_.serie_from,
                  newrec_.serie_until,
                  objid_);

   IF (exists_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'SERIES_EXIST: The series overlaps an existing series for another voucher type');
   END IF;

   Validate_Record___(newrec_);

   IF (newrec_.serie_from = 0) THEN
      Error_SYS.Record_General(lu_name_,'FROMSERIES_ZERO: Voucher series cannot start from number 0');
   END IF;
EXCEPTION
   WHEN current_no_exp THEN
      Client_SYS.Clear_Attr(attr_);
      newrec_.current_number := oldrec_.current_number;
      Client_SYS.Add_To_Attr('CURRENT_NUMBER', oldrec_.current_number, attr_);
      Client_SYS.Add_Info(lu_name_,'CURRENT_NUMBER: You cannot change the current voucher number :P1. The voucher number series is in use.', oldrec_.current_number);
END Check_Update___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   accounting_year_ IN NUMBER,
   period_ IN NUMBER )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_, NULL, company_ ||' '|| voucher_type_ ||' '|| accounting_year_||' '|| period_);
   super(company_, voucher_type_, accounting_year_, period_);
END Raise_Record_Not_Exist___;


PROCEDURE Create_Vou_Ser_Per_Year___ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER)
IS
   newrec_        voucher_no_serial_tab%ROWTYPE;
   serie_from_    NUMBER;
   serie_until_   NUMBER;
   
   CURSOR get_data IS
      SELECT voucher_type
      FROM   voucher_type_tab
      WHERE  company = company_;
      
BEGIN
   serie_from_    := TO_NUMBER(accounting_year_ ||'000000');
   serie_until_   := TO_NUMBER(accounting_year_ ||'999999'); 
   FOR rec_ IN get_data LOOP
      newrec_.company         := company_;
      newrec_.accounting_year := accounting_year_;
      newrec_.voucher_type    := rec_.voucher_type;
      newrec_.period          := 99;
      newrec_.serie_from      := serie_from_;
      newrec_.serie_until     := serie_until_;
      newrec_.current_number  := serie_from_;
      New___(newrec_);
   END LOOP;
END Create_Vou_Ser_Per_Year___;


PROCEDURE Create_Vou_Ser_Per_Period___ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER)
IS
   newrec_        voucher_no_serial_tab%ROWTYPE;
   serie_from_    NUMBER;
   serie_until_   NUMBER;
   
   CURSOR get_data IS
      SELECT voucher_type
      FROM   voucher_type_tab
      WHERE  company = company_;
   
   CURSOR get_periods IS
      SELECT accounting_period
      FROM   accounting_period_tab
      WHERE  company          = company_
      AND    accounting_year  = accounting_year_
      AND    year_end_period  = 'ORDINARY';
BEGIN
   FOR rec_ IN get_data LOOP
      serie_from_ := TO_NUMBER(TO_CHAR(accounting_year_)||'000000');
      FOR periods_ IN get_periods LOOP
         serie_from_  := serie_from_ + 10000;
         serie_until_ := serie_from_ + 9999;
         newrec_.company         := company_;
         newrec_.accounting_year := accounting_year_;
         newrec_.voucher_type    := rec_.voucher_type;
         newrec_.period          := periods_.accounting_period;
         newrec_.serie_from      := serie_from_;
         newrec_.serie_until     := serie_until_;
         newrec_.current_number  := serie_from_;
         New___(newrec_);
      END LOOP;
   END LOOP;
END Create_Vou_Ser_Per_Period___;



PROCEDURE Copy_Vou_No_Series___ (
   company_          IN VARCHAR2,
   source_year_      IN NUMBER,   
   accounting_year_  IN NUMBER )
IS
   newrec_  voucher_no_serial_tab%ROWTYPE;
   
   CURSOR get_data IS 
      SELECT * 
      FROM   voucher_no_serial_tab
      WHERE  company         = company_
      AND    accounting_year = source_year_;
BEGIN
   FOR rec_ IN get_data LOOP
      newrec_.company           := company_;
      newrec_.accounting_year   := accounting_year_;
      newrec_.voucher_type      := rec_.voucher_type;
      newrec_.serie_from        := rec_.serie_from;
      newrec_.serie_until       := rec_.serie_until;
      newrec_.period            := rec_.period;
      newrec_.current_number    := newrec_.serie_from;
      New___(newrec_);
   END LOOP;
END Copy_Vou_No_Series___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Series__ (
   exists_           OUT VARCHAR2,
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER,
   period_           IN NUMBER,
   serie_from_       IN NUMBER,
   serie_until_      IN NUMBER,
   objid_            IN VARCHAR2 )
IS
   CURSOR check_series IS
   SELECT 'TRUE'
   FROM   VOUCHER_NO_SERIAL_TAB
   WHERE  company = company_
   AND    Voucher_type    = voucher_type_
   AND    Accounting_year = accounting_year_
   AND    period          = period_
   AND    ( (serie_from <= serie_from_  AND serie_until >= serie_from_)
            OR
            (serie_from <= serie_until_ AND serie_until >= serie_until_) )
   AND    rowid != objid_;
BEGIN
   OPEN check_series;
   FETCH check_series into exists_;
   IF (check_series%NOTFOUND) THEN
      exists_ := 'FALSE';
   END IF;
   CLOSE check_series;
END Check_Series__;


PROCEDURE Check_Series_Group__ (
   exists_        OUT VARCHAR2,
   company_       IN  VARCHAR2,
   voucher_type_  IN  VARCHAR2 )
IS
   CURSOR check_series is
   SELECT 'TRUE'
   FROM   VOUCHER_NO_SERIAL_TAB
   WHERE  Company = company_
   AND    Voucher_type = voucher_type_;
BEGIN
   OPEN check_series;
   FETCH check_series INTO exists_;
   IF (check_series%NOTFOUND) THEN
      exists_ := 'FALSE';
   END IF;
   CLOSE check_series;
END Check_Series_Group__;


PROCEDURE Check_Delete_Record__ (
   exists_                    OUT VARCHAR2,
   company_                   IN  VARCHAR2,
   voucher_type_              IN  VARCHAR2,
   accounting_year_           IN NUMBER,
   period_                    IN NUMBER )
IS
   attr_       VARCHAR2(2000);
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr('VOUCHER_TYPE', voucher_type_, attr_);
      Client_SYS.Add_To_Attr('ACCOUNTING_YEAR', accounting_year_, attr_); 
      Gen_Led_Voucher_API.Voucher_Delete_Allowed ( attr_ );
   $ELSE
      NULL;
   $END
   Voucher_Type_User_Group_API.Voucher_Serie_Delete_Allowed(company_,voucher_type_,accounting_year_);   
END Check_Delete_Record__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Next_Voucher_No (
   voucher_no_          OUT NUMBER,
   company_             IN VARCHAR2,
   voucher_type_        IN VARCHAR2,
   date_voucher_        IN DATE,
   p_accounting_year_   IN NUMBER DEFAULT NULL,
   p_period_            IN NUMBER DEFAULT NULL)
IS
   automatic_         VARCHAR2(1);
   accounting_year_   NUMBER;
   period_            NUMBER;
   high_no_           NUMBER;
   new_actual_        NUMBER;
   date_param_        DATE;

   CURSOR get_voucher_number IS
      SELECT  nvl( current_number,0 ), nvl( serie_until,0 )
      FROM    Voucher_no_serial_tab
      WHERE   company         = company_
      AND     voucher_type    = voucher_type_
      AND     accounting_year = accounting_year_
      AND     period          = period_
      FOR     UPDATE OF current_number;

   CURSOR get_accounting_period IS
      SELECT  accounting_period
      FROM  accounting_period_tab
      WHERE  company     = company_
      AND  date_from    <= date_param_
      AND  date_until   >= date_param_
      AND  year_end_period = 'ORDINARY'
      ORDER BY accounting_period ASC;
BEGIN
   IF (p_accounting_year_ IS NOT NULL) AND (p_period_ IS NOT NULL) THEN
      accounting_year_ := p_accounting_year_;
      period_ := p_period_;
   ELSE
      -- get them by the voucher date.
      Accounting_Period_API.Get_Accounting_Year(accounting_year_, period_, company_, date_voucher_);
   END IF;
   
   IF (Company_Finance_API.Get_Use_Vou_No_Period(company_) = 'FALSE') THEN
      period_ := 99;
   ELSE 
      IF( period_ = 0 AND p_period_ IS NULL) THEN
         date_param_ := TRUNC( date_voucher_ );
         OPEN   get_accounting_period;
         FETCH  get_accounting_period INTO period_;
         CLOSE  get_accounting_period;
      END IF;
   END IF;

   Voucher_Type_API.Check_Automatic_(automatic_,company_,voucher_type_);

   IF (automatic_ = 'N') THEN
      Error_SYS.Record_General(lu_name_,'NO_AUT: An automatic generated voucher number cannot be deleted automatic allotment is set to NO');
   END IF;

   OPEN   get_voucher_number;
   FETCH  get_voucher_number INTO new_actual_, high_no_;
   IF (get_voucher_number%NOTFOUND) THEN
      CLOSE get_voucher_number;
      voucher_no_ := 0;
      Error_SYS.Record_General(lu_name_,'NO_SER: There are no voucher no series for voucher type :P1 and accounting year :P2',voucher_type_,accounting_year_);
   ELSE
      CLOSE get_voucher_number;
   END IF;

   IF ( new_actual_ >  high_no_) THEN
      Error_SYS.Record_General(lu_name_,'HIGH_NO: The voucher number is higher than series until');
   END IF;

-- Update the table with the new voucher number as the actual number

   UPDATE Voucher_no_serial_tab
   SET    current_number = ( new_actual_ + 1)
   WHERE  company       = company_
   AND  voucher_type    = voucher_type_
   AND  accounting_year = accounting_year_
   AND  period          = period_;

   voucher_no_ := new_actual_ ;
END Get_Next_Voucher_No;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_Voucher_No (
   company_       IN VARCHAR2,
   date_voucher_  IN DATE,
   voucher_type_  IN VARCHAR2,
   voucher_no_    IN NUMBER,
   acc_year_      IN NUMBER DEFAULT NULL,
   acc_period_    IN NUMBER DEFAULT NULL  )
IS
   number_ok_        VARCHAR2(2);
   accounting_year_  NUMBER;
   period_           NUMBER;

   CURSOR check_voucher_number IS
      SELECT  'OK'
      FROM    VOUCHER_NO_SERIAL_TAB
      WHERE   company       = company_
      AND   voucher_type    = voucher_type_
      AND   accounting_year = accounting_year_
      AND   period          = period_
      AND   voucher_no_ BETWEEN serie_from AND serie_until;

BEGIN
   IF (acc_year_ IS NOT NULL) AND (acc_period_ IS NOT NULL) THEN
      accounting_year_ := acc_year_;
      period_ := acc_period_; 
   ELSE
      Accounting_Period_API.Get_Accounting_year(accounting_year_,period_,company_,date_voucher_);
   END IF;
   IF (Company_Finance_API.Get_Use_Vou_No_Period(company_) = 'FALSE') THEN
      period_ := 99;
   END IF;
   number_ok_ := 'XX';
   OPEN  check_voucher_number;
   FETCH check_voucher_number INTO number_ok_;
   IF (number_ok_ != 'OK') THEN
      Error_SYS.Record_General(lu_name_,'INVALID_NO: The voucher number is outside the series');
   END IF;
   CLOSE check_voucher_number;
END Check_Voucher_No;


PROCEDURE Check_Voucher_No (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER )
IS
   number_ok_        VARCHAR2(2);

   CURSOR check_voucher_number IS
      SELECT 'OK'
      FROM  VOUCHER_NO_SERIAL_TAB
      WHERE company         = company_
      AND   voucher_type    = voucher_type_
      AND   accounting_year = accounting_year_
      AND   voucher_no_ BETWEEN serie_from AND serie_until;

BEGIN
   number_ok_ := 'XX';
   OPEN  check_voucher_number;
   FETCH check_voucher_number INTO number_ok_;
   IF (number_ok_ != 'OK') THEN
      Error_SYS.Record_General(lu_name_,'INVALID_NO: The voucher number is outside the series');
   END IF;
   CLOSE check_voucher_number;
END Check_Voucher_No;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Rollback_Pca_Voucher_Serial_No (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN VARCHAR2,
   period_          IN NUMBER,
   voucher_no_      IN NUMBER )
IS
   pca_user_group_  user_group_member_finance_tab.user_group%type;
   user_name_       VARCHAR2(30);
   rec_             VOUCHER_NO_SERIAL_TAB%ROWTYPE;
   per_             Voucher_No_Serial_Tab.period%TYPE;
BEGIN
   user_name_ := User_Finance_API.User_Id;

   $IF Component_Percos_SYS.INSTALLED $THEN
      -- check if group defined is the group which was determined in company tab
      pca_user_group_ := Company_Cost_Alloc_Info_API.Get_User_Group( company_);

      IF (pca_user_group_ IS NOT NULL) THEN
         IF (User_Group_Member_Finance_API.Is_User_Member_Of_Group(company_,
                                                                   user_name_,
                                                                   pca_user_group_ ) = 'FALSE') THEN
             Error_SYS.Record_General(lu_name_, 'DESIGN_ERROR: DESIGN ERROR. Only user group defined in PCA Company tab is allowed to use this procedure');
         END IF;
      ELSE
         Error_SYS.Record_General(lu_name_, 'DESIGN_ERROR: DESIGN ERROR. Only user group defined in PCA Company tab is allowed to use this procedure');
      END IF;

      per_ := period_;
      IF (Company_Finance_API.Get_Use_Vou_No_Period(company_) = 'FALSE') THEN
         per_ := 99;
      END IF;

      rec_ := Get_Object_By_Keys___(company_,
                                    voucher_type_,
                                    accounting_year_,
                                    per_);

      IF (rec_.current_number - 1 != voucher_no_) THEN
         Error_SYS.Record_General(lu_name_, 'NOTALLOWROLLBACK: Cannot perform the operation with Rollback mode since there are voucher(s) created with later voucher number(s). Use Correction mode instead.');
      END IF;

      UPDATE VOUCHER_NO_SERIAL_TAB
         SET current_number  = ( rec_.current_number - 1)
       WHERE company         = company_
         AND voucher_type    = voucher_type_
         AND accounting_year = accounting_year_
         AND period          = per_;
   $ELSE
      Error_SYS.Record_General(lu_name_, 'DESIGN_ERROR: DESIGN ERROR. Only user group defined in PCA Company tab is allowed to use this procedure');
   $END
END Rollback_Pca_Voucher_Serial_No;


PROCEDURE Create_Voucher_No (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   default_         IN VARCHAR2,
   user_group_      IN VARCHAR2 DEFAULT NULL,
   default_type_    IN VARCHAR2 DEFAULT NULL,
   authorize_level_ IN VARCHAR2 DEFAULT NULL,
   message_         IN VARCHAR2 DEFAULT NULL,
   function_group_  IN VARCHAR2 DEFAULT '*' ,
   from_vou_type_   IN VARCHAR2 DEFAULT NULL)
IS
   serie_from_          NUMBER;
   serie_until_         NUMBER;
   current_number_      NUMBER;
   acc_year_            NUMBER;
   def_default_type_    VARCHAR2(1) := 'N';
   voucher_per_used_    VARCHAR2(5);
   period_              NUMBER;
   
   func_group_found_    BOOLEAN;
   func_group_          Voucher_Type_User_Group_Tab.function_group%TYPE;
   user_grp_            Voucher_Type_User_Group_Tab.User_Group%TYPE;
   
   CURSOR get_acc_year IS
      SELECT Accounting_Year
      FROM   Accounting_Year_Tab
      WHERE  Company = company_;

   CURSOR vou_serial IS
      SELECT Serie_From, Serie_Until, Current_Number
      FROM  Voucher_No_Serial_Tab
      WHERE accounting_year = acc_year_
      AND   voucher_type    = from_vou_type_
      AND   company         = company_
      AND   period          = DECODE(voucher_per_used_,'TRUE',period_,'FALSE',99) ;

   CURSOR usr_grp_dat IS
      SELECT DISTINCT User_Group, Authorize_Level
      FROM   Voucher_Type_User_Group_Tab
      WHERE  Company         = company_
      AND    Voucher_Type    = from_vou_type_
      AND    Accounting_Year = acc_year_
      GROUP BY User_Group, Authorize_Level;
      
  CURSOR usr_grp_dat_per_func_grp IS
      SELECT DISTINCT User_Group, Authorize_Level
      FROM   Voucher_Type_User_Group_Tab
      WHERE  Company         = company_
      AND    Voucher_Type    = from_vou_type_
      AND    Accounting_Year = acc_year_ 
      AND    Function_Group  = func_group_ ;
      
  CURSOR get_function_group IS
      SELECT function_group
      FROM Voucher_Type_Detail_Tab
      WHERE company    = company_
      AND voucher_type = voucher_type_;


   CURSOR get_period IS
      SELECT accounting_period
      FROM   Accounting_Period_Tab
      WHERE  accounting_year = acc_year_
      AND    company = company_ ;

   count_         INTEGER;
   names_         message_sys.name_Table;
   values_        message_sys.line_Table;
   scount_        INTEGER;
   snames_        message_sys.name_Table;
   svalues_       message_sys.line_Table;
   rec_           voucher_no_serial_tab%ROWTYPE;
   auth_          VARCHAR2(20);
BEGIN
   IF (default_ = '1' OR default_ = 'TRUE') THEN
      IF (from_vou_type_ IS NULL) THEN
         NULL;
      ELSE
         OPEN get_acc_year;
         LOOP
            FETCH get_acc_year INTO acc_year_;
            EXIT WHEN get_acc_year%NOTFOUND;
            voucher_per_used_ := Company_Finance_API.Get_Use_Vou_No_Period(company_);
            IF(voucher_per_used_ = 'TRUE') THEN
               OPEN get_period;
               LOOP
                  FETCH get_period INTO period_;
                  EXIT WHEN get_period%NOTFOUND; 
                  OPEN  vou_serial;
                  FETCH vou_serial INTO serie_from_, serie_until_, current_number_;
                  IF (vou_serial%FOUND) THEN
                     rec_.company         := company_;
                     rec_.voucher_type    := voucher_type_;
                     rec_.accounting_year := acc_year_;
                     rec_.period          := period_;
                     rec_.serie_from      := serie_from_;
                     rec_.serie_until     := serie_until_;
                     current_number_      := serie_from_;
                     rec_.current_number  := current_number_;

                     New___(rec_);
                  END IF;
                  CLOSE vou_serial;
                END LOOP;
                CLOSE get_period;
                func_group_found_ := false;
                FOR rec_func_goup_ IN get_function_group LOOP
                   func_group_ := rec_func_goup_.function_group;
                   FOR rec_user_gr_func_gr_ IN usr_grp_dat_per_func_grp LOOP
                      func_group_found_ := true;
                      voucher_Type_User_Group_Api.Create_Vou_Type_User_Group(company_,
                                                                             acc_year_,
                                                                             rec_user_gr_func_gr_.User_Group,
                                                                             voucher_type_,
                                                                             Authorize_Level_API.Decode(rec_user_gr_func_gr_.Authorize_Level),
                                                                             Finance_Yes_No_API.Decode(def_default_type_),
                                                                             func_group_ );
                   END LOOP;

                   IF (func_group_found_ = false) THEN
                      -- All user groups conected to voucher type 'from_vou_type_' should be
                      -- connected to to new voucher type 'voucher_type_'.
                      user_grp_ := NULL;
                      FOR user_rec_ IN usr_grp_dat LOOP
                         IF (user_grp_ IS NULL OR user_grp_ <> user_rec_.user_group) THEN
                            Voucher_Type_User_Group_Api.Create_Vou_Type_User_Group(company_, 
                                                                                   acc_year_,
                                                                                   user_rec_.User_Group,
                                                                                   voucher_type_, 
                                                                                   Authorize_Level_API.Decode(user_rec_.Authorize_Level),
                                                                                   Finance_Yes_No_API.Decode(def_default_type_),
                                                                                   func_group_);
                            user_grp_ := user_rec_.user_group;                                                       
                         END IF;
                      END LOOP;
                   END IF;
                   func_group_found_ := false;
                END LOOP;
            ELSE
               OPEN  vou_serial;
               FETCH vou_serial INTO serie_from_, serie_until_, current_number_;
               IF (vou_serial%FOUND) THEN                     
                  rec_.company         := company_;
                  rec_.voucher_type    := voucher_type_;
                  rec_.accounting_year := acc_year_;
                  rec_.period          := 99;
                  rec_.serie_from      := serie_from_;
                  rec_.serie_until     := serie_until_;
                  current_number_      := serie_from_;
                  rec_.current_number  := current_number_;

                  New___(rec_);

                  func_group_found_ := false;
                  FOR rec_func_goup_ IN get_function_group LOOP
                     func_group_ := rec_func_goup_.function_group;
                     FOR rec_user_gr_func_gr_ IN usr_grp_dat_per_func_grp LOOP
                        func_group_found_ := true;
                        voucher_Type_User_Group_Api.Create_Vou_Type_User_Group(company_,
                                                                               acc_year_,
                                                                               rec_user_gr_func_gr_.User_Group,
                                                                               voucher_type_,
                                                                               Authorize_Level_API.Decode(rec_user_gr_func_gr_.Authorize_Level),
                                                                               Finance_Yes_No_API.Decode(def_default_type_),
                                                                               func_group_ );
                     END LOOP;

                     IF (func_group_found_ = false) THEN
                        -- All user groups conected to voucher type 'from_vou_type_' should be
                        -- connected to to new voucher type 'voucher_type_'.
                        user_grp_ := NULL;
                        FOR user_rec_ IN usr_grp_dat LOOP
                           IF (user_grp_ IS NULL OR user_grp_ <> user_rec_.user_group) THEN
                              Voucher_Type_User_Group_Api.Create_Vou_Type_User_Group(company_, 
                                                                                     acc_year_,
                                                                                     user_rec_.User_Group,
                                                                                     voucher_type_, 
                                                                                     Authorize_Level_API.Decode(user_rec_.Authorize_Level),
                                                                                     Finance_Yes_No_API.Decode(def_default_type_),
                                                                                     func_group_);
                              user_grp_ := user_rec_.user_group;                                                       
                           END IF;
                        END LOOP;
                     END IF;
                     func_group_found_ := false;
                  END LOOP;
               END IF;
               CLOSE vou_serial;
            END IF;
         END LOOP;    
         CLOSE get_acc_year;
      END IF;
   ELSE
      auth_ := Authorize_Level_api.Encode(authorize_level_);

      Message_SYS.Get_Attributes ( message_, count_, names_, values_ );
      FOR i_ IN 1..count_ LOOP
         Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
      END LOOP;
      FOR i_ IN 1..count_ LOOP
         Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
         rec_.company                 := svalues_(1);
         rec_.voucher_type            := svalues_(2);
         rec_.accounting_year         := To_number(svalues_(3));
         rec_.period                  := To_number(svalues_(4));
         rec_.serie_from              := To_number(svalues_(5));
         rec_.serie_until             := To_number(svalues_(6));
         rec_.current_number          := To_number(svalues_(7));

         IF (rec_.serie_from IS NULL) OR (rec_.serie_until IS NULL) OR (rec_.current_number IS NULL) THEN
            Error_SYS.Record_General(lu_name_, 'SERIEWRONG: Enter Valid Number Series');
         ELSE
            IF (rec_.serie_from >= rec_.serie_until) THEN
               Error_SYS.Record_General(lu_name_, 'INVALRANGE: Until Number must be greater than From Number');
            END IF;
            IF NOT ((rec_.serie_from <= rec_.current_number ) AND (rec_.serie_until >= rec_.current_number)) THEN
               Error_SYS.Record_General(lu_name_, 'INVALNEXT: Next Number does not fall in to the defined range');
            END IF;
         END IF;
         
         New___(rec_);
         
         Voucher_Type_User_Group_Api.Create_Vou_Type_User_Group(rec_.company,
                                                                rec_.accounting_year,
                                                                user_group_,
                                                                rec_.voucher_type,
                                                                Authorize_Level_API.Decode(auth_),
                                                                default_type_,
                                                                function_group_ );    --      A536
      END LOOP;
   END IF;
END Create_Voucher_No;


PROCEDURE Auto_Voucher_No_Serial (
   company_         IN VARCHAR2,
   template_id_     IN VARCHAR2,
   acc_year_        IN NUMBER DEFAULT NULL,
   number_of_years_ IN NUMBER DEFAULT NULL,
   user_defined_    IN VARCHAR2 DEFAULT NULL,
   is_copy_         IN BOOLEAN DEFAULT FALSE  )
IS
   /*
   CURSOR get_year IS
      SELECT distinct n1
      FROM   Create_Company_Tem_Detail_Tab
      WHERE  component   = 'ACCRUL'
      AND    lu          = 'VoucherNoSerial'
      AND    template_id = template_id_
      ORDER BY n1 asc;
   */
BEGIN

   Auto_Voucher_No_Serial(company_, 
                          template_id_,
                          acc_year_,
                          number_of_years_,
                          user_defined_,
                          is_copy_);
/*
   IF (user_defined_ = 'TRUE' AND acc_year_ IS NOT NULL AND number_of_years_ IS NOT NULL) THEN
      FOR year_ IN acc_year_..acc_year_+number_of_years_ LOOP
         Add_Vou_Num_Ser_Per_Period___( company_, template_id_, year_, is_copy_ );
      END LOOP;
   ELSE
      FOR get_year_ IN get_year LOOP
         Add_Vou_Num_Ser_Per_Period___( company_, template_id_, get_year_.n1);
      END LOOP;
   END IF;
*/   
END Auto_Voucher_No_Serial;


FUNCTION Is_Period_Used (
   template_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_period IS
      SELECT n4
      FROM   Create_Company_Tem_Detail_Tab
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = template_id_;

   period_    Voucher_No_Serial_Tab.period%TYPE;

BEGIN
   OPEN  get_period;
   FETCH get_period INTO period_;
   CLOSE get_period;
   IF (period_ = 99 ) THEN
      RETURN 'FALSE';
   ELSIF( period_ IS NULL ) THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
END Is_Period_Used;


FUNCTION Is_Period_Exist (
   company_ IN VARCHAR2,
   year_    IN NUMBER,
   period_  IN NUMBER ) RETURN VARCHAR2
IS
   CURSOR get_voucher_series IS
      SELECT  'TRUE'
      FROM    Voucher_No_Serial_Tab
      WHERE   company            = company_
      AND     accounting_year    = year_
      AND     period             = period_;

   temp_      VARCHAR2(5);
BEGIN
   OPEN  get_voucher_series ;
   FETCH get_voucher_series INTO temp_;
   IF (get_voucher_series%NOTFOUND) THEN
      temp_ := 'FALSE';
   END IF;
   CLOSE get_voucher_series;
   RETURN temp_;
END Is_Period_Exist;



PROCEDURE Create_Voucher_Series (
   company_             IN VARCHAR2,
   source_year_         IN NUMBER,   
   accounting_year_     IN NUMBER,
   creation_method_db_  IN VARCHAR2)
IS
BEGIN
   IF (creation_method_db_ = 'PER_YEAR') THEN
      Create_Vou_Ser_Per_Year___(company_, accounting_year_);
   ELSIF (creation_method_db_ = 'PER_PERIOD') THEN
      Create_Vou_Ser_Per_Period___(company_, accounting_year_);
   ELSIF (creation_method_db_ = 'FROM_SOURCE_YEAR') THEN
      Copy_Vou_No_Series___(company_, source_year_, accounting_year_);
   END IF;
END Create_Voucher_Series;

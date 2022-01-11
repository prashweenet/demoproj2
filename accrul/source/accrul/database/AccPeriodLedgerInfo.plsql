-----------------------------------------------------------------------------
--
--  Logical unit: AccPeriodLedgerInfo
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  170907  Bhhilk  STRFI-9708, Merged Bug 137379 used Accounting_Year_API.Find_Next_Available_Year instead of acc_year + 1.
--  200424  Savmlk  Bug 153603, Added new overloaded method Get_Previous_Period.
--  200902  Jadulk  FISPRING20-6694 , Removed conacc related logic and constants.
--  201027  Chaulk  Bug 156027, Modified Copy___  method to set the period status.
-----------------------------------------------------------------------------

layer Core; 

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_           acc_period_ledger_info_tab%ROWTYPE;
   empty_rec_        acc_period_ledger_info_tab%ROWTYPE;
   msg_              VARCHAR2(2000);
   i_                NUMBER := 0;
   update_by_key_    BOOLEAN;
   any_rows_         BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT C1, C2, N1, N2
      FROM   create_company_template_pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM   acc_period_ledger_info_tab dest
                         WHERE  dest.company           = crecomp_rec_.company
                         AND    dest.accounting_year   = src.N1
                         AND    dest.accounting_period = src.N2
                         AND    dest.ledger_id         = src.C1)
      ORDER BY N1, N2;
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
               newrec_.ledger_id            := rec_.c1;
               newrec_.period_status        := rec_.c2;
               
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
            END;
         END LOOP;
      END IF;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');
         END IF;
      END IF;
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            FOR year_ IN 0..crecomp_rec_.number_of_years-1 LOOP               
               FOR period_ IN 0..12 LOOP
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  SAVEPOINT make_company_insert;
                  BEGIN
                     newrec_.company              := crecomp_rec_.company;
                     newrec_.accounting_year      := crecomp_rec_.acc_year + year_;
                     newrec_.accounting_period    := period_;
                     newrec_.ledger_id            := '00';
                     newrec_.period_status        := 'O';
               
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
                  END;
               END LOOP;
            END LOOP;
         ELSE
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               SAVEPOINT make_company_insert;
               BEGIN
                  newrec_.company              := crecomp_rec_.company;
                  newrec_.accounting_year      := rec_.n1;
                  newrec_.accounting_period    := rec_.n2;
                  newrec_.ledger_id            := rec_.c1;
                  newrec_.period_status        := rec_.c2;

                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     @ApproveTransactionStatement(2014-03-24,dipelk)
                     ROLLBACK TO make_company_insert;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
               END;
            END LOOP;
         END IF;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');
            END IF;
         END IF;
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        acc_period_ledger_info_tab%ROWTYPE;
   empty_rec_     acc_period_ledger_info_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   
   CURSOR get_data IS
      SELECT accounting_year, accounting_period, period_status
      FROM   acc_period_ledger_info_tab src 
      WHERE  company   = crecomp_rec_.old_company
      AND    ledger_id = '00'
      AND    NOT EXISTS (SELECT 1 
                         FROM   acc_period_ledger_info_tab dest
                         WHERE  dest.company           = crecomp_rec_.company
                         AND    dest.accounting_year   = src.accounting_year
                         AND    dest.accounting_period = src.accounting_period
                         AND    dest.ledger_id         = '00')
      ORDER BY accounting_year, accounting_period;
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
               newrec_.accounting_year      := rec_.accounting_year;
               newrec_.accounting_period    := rec_.accounting_period;
               newrec_.ledger_id            := '00';
               newrec_.period_status        := rec_.period_status;
               
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      END IF;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');
   ELSE
      any_rows_ := Exist_Any___(crecomp_rec_.company);
      IF (NOT any_rows_) THEN
         IF (crecomp_rec_.user_defined = 'TRUE') THEN
            FOR year_ IN 0..crecomp_rec_.number_of_years-1 LOOP
               FOR period_ IN 0..12 LOOP
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  SAVEPOINT make_company_insert;
                  BEGIN
                     newrec_.company              := crecomp_rec_.company;
                     newrec_.accounting_year      := crecomp_rec_.acc_year + year_;
                     newrec_.accounting_period    := period_;
                     newrec_.ledger_id            := '00';
                     newrec_.period_status        := 'O';
                     
                     New___(newrec_);
                  EXCEPTION
                     WHEN OTHERS THEN
                        msg_ := SQLERRM;
                        @ApproveTransactionStatement(2014-03-24,dipelk)
                        ROLLBACK TO make_company_insert;
                        Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
                  END;
               END LOOP;
            END LOOP;
         ELSE
            FOR rec_ IN get_data LOOP
               i_ := i_ + 1;
               BEGIN
                  newrec_ := empty_rec_;
                  newrec_.company              := crecomp_rec_.company;                 
                  newrec_.accounting_year      := rec_.accounting_year;
                  newrec_.accounting_period    := rec_.accounting_period;
                  newrec_.ledger_id            := '00';
                  newrec_.period_status        := rec_.period_status;

                  New___(newrec_);
               EXCEPTION
                  WHEN OTHERS THEN
                     msg_ := SQLERRM;
                     Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);                                                   
               END;
            END LOOP;
         END IF;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_PERIOD_LEDGER_INFO_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;

   CURSOR get_data IS
      SELECT accounting_year, accounting_period
      FROM   accounting_period_tab
      WHERE  company = crecomp_rec_.company
      ORDER BY accounting_year, accounting_period;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      pub_rec_.n1          := pctrec_.accounting_year;
      pub_rec_.n2          := pctrec_.accounting_period;
      pub_rec_.c1          := '00';
      pub_rec_.c2          := 'O';

      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT acc_period_ledger_info_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   
   IF (indrec_.period_status AND newrec_.ledger_id != '00' AND newrec_.period_status = 'C'  
      AND Is_Period_Open(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, '00') = 'TRUE') THEN
      Error_Sys.Record_General(lu_name_,'PERSTAT: GL Period Status should be closed before Status of IL Period is in Closed.');
   END IF;
   IF (indrec_.period_status AND newrec_.ledger_id = '00' AND newrec_.period_status = 'O'  
      AND Is_Ye_Exists_In_Status_Gl___(newrec_.company, newrec_.accounting_year, 'O')) THEN
      Error_Sys.Record_General(lu_name_,'YEMRETHNONE: More than one Year End Period can not be Open at the same time.');
   ELSIF (indrec_.period_status AND newrec_.ledger_id != '00' AND newrec_.period_status = 'O'  
      AND Is_Ye_Exists_In_Status_Il___(newrec_.company, newrec_.accounting_year, newrec_.ledger_id, 'O')) THEN
      Error_Sys.Record_General(lu_name_,'YEMRETHNONEIL: More than one Year End Period can not be Open at the same time(Open year end period exist in IL).');
   END IF;
END Check_Insert___;

PROCEDURE Validate_Final_Close___ (
   newrec_     IN   acc_period_ledger_info_tab%ROWTYPE)
IS
   period_rec_  Accounting_Period_API.Public_Rec;
   dummy_       NUMBER;
 
   CURSOR check_prev_periods IS
      SELECT 1
      FROM   acc_period_ledger_info_tab l,
             accounting_period_tab p
      WHERE  p.company           = l.company
      AND    p.accounting_year   = l.accounting_year
      AND    p.accounting_period = l.accounting_period
      AND    p.company           = newrec_.company
      AND    p.accounting_year   = newrec_.accounting_year
      AND    p.date_until        < period_rec_.date_from
      AND    p.year_end_period   = 'ORDINARY'      
      AND    l.ledger_id         = newrec_.ledger_id      
      AND    l.period_status    != 'F';

   CURSOR check_periods IS
      SELECT 1
      FROM   acc_period_ledger_info_tab l,
             accounting_period_tab p
      WHERE  p.company           = l.company
      AND    p.accounting_year   = l.accounting_year
      AND    p.accounting_period = l.accounting_period    
      AND    p.company           = newrec_.company
      AND    p.accounting_year   = newrec_.accounting_year 
      AND    p.year_end_period  IN ('ORDINARY','YEAROPEN')
      AND    l.ledger_id         = newrec_.ledger_id   
      AND    l.period_status    != 'F';  
   

BEGIN
   period_rec_ := Accounting_Period_API.Get(newrec_.company, newrec_.accounting_year, newrec_.accounting_period);
   IF (period_rec_.year_end_period = 'ORDINARY') THEN
      OPEN check_prev_periods;
      FETCH check_prev_periods INTO dummy_;
      IF check_prev_periods%FOUND THEN
         CLOSE check_prev_periods;
         Error_SYS.Record_General(lu_name_, 'ACCPERFINCLOSE10: To close the period finally all previous Ordinary periods for the ledger must be in state "Finally Closed".');
      END IF;
      CLOSE check_prev_periods;
   ELSIF (period_rec_.year_end_period IN('YEAROPEN', 'YEARCLOSE')) THEN
      IF NVL(Acc_Year_Ledger_Info_API.Get_Year_Status_Db(newrec_.company, newrec_.accounting_year-1, newrec_.ledger_id),'C') = 'O' THEN
         Error_SYS.Record_General(lu_name_, 'ACCPERFINCLOSE20: To close the period finally previous year must be in state "Closed" or "Finally Closed".');
      END IF;
      IF (period_rec_.year_end_period = 'YEARCLOSE') THEN
         OPEN check_periods;
         FETCH check_periods INTO dummy_;
         IF check_periods%FOUND THEN
            CLOSE check_periods;
            Error_SYS.Record_General(lu_name_, 'ACCPERFINCLOSE30: To close the period finally all Ordinary and Year Opening periods must be in state "Finally Closed for the ledger".');
         END IF;
         CLOSE check_periods;
      END IF;
   END IF;
   $IF Component_Genled_SYS.INSTALLED $THEN 
      IF ( newrec_.ledger_id = '00' AND period_rec_.year_end_period IN ('ORDINARY','YEARCLOSE')) THEN      
         IF (Accounting_Journal_Item_API.Exists_Journal_Items_In_State(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, 'Empty')= 'TRUE') THEN
            Error_SYS.Record_General(lu_name_, 'ACCPERFINCLOSE40: To close the period finally all Accounting Journals must be in state "Automatic" or "Generated".');
         END IF;         
      END IF;   
   $END
END Validate_Final_Close___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('PERIOD_STATUS',     Acc_Year_Per_Status_API.Decode('O'),          attr_ );
   Client_SYS.Add_To_Attr('YEAR_END_PERIOD',   Period_Type_API.Decode('ORDINARY'),           attr_ );
END Prepare_Insert___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     acc_period_ledger_info_tab%ROWTYPE,
   newrec_ IN OUT acc_period_ledger_info_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS 
   period_rec_            Accounting_Period_API.Public_Rec;
BEGIN        
   
   super(oldrec_, newrec_, indrec_, attr_);

   -------------------------------------------------------------------------------
   IF ( newrec_.ledger_id = '00' AND newrec_.period_status = 'O' AND Is_Any_Il_Exists_In_Status___(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, 'C')) THEN           
      Error_SYS.Record_General(lu_name_,'ILPERCL: The IL period should be in Open status before you open the GL period.');
   END IF;
   IF ( newrec_.ledger_id != '00' AND newrec_.period_status = 'C' AND Get_Period_Status_Db(newrec_.company, newrec_.accounting_year, newrec_.accounting_period,'00')= 'O') THEN
      Error_SYS.Record_General(lu_name_,'PERSTAT: GL Period Status should be closed before Status of IL Period is in Closed.');
   END IF;  
   -----------------------------------------------------------------------------------
   -- Added to close User Groups per Period if Accounting Period is closed.       
   IF (newrec_.period_status IN ('C','F')) THEN
      Check_Close_Period(newrec_.company, newrec_.accounting_year, newrec_.accounting_period, newrec_.ledger_id);
      IF (newrec_.period_status = 'C' ) THEN         
         User_Group_Period_API.Update_Period_Status_( newrec_.company,
                                                      newrec_.period_status,
                                                      newrec_.accounting_year,
                                                      newrec_.accounting_period,
                                                      newrec_.ledger_id);         
      END IF;
   END IF;   
   ------------------------------------------------------------------------
   -- check if any accounting year and accounting period exist in period allocation tab before user
   -- could change period allocation from open to close period   
   IF (newrec_.period_status = 'C') OR (newrec_.period_status = 'F') THEN
      IF Period_Allocation_API.Check_Year_Period_Exist_Ledger(newrec_.company,newrec_.accounting_year,newrec_.accounting_period, newrec_.ledger_id) = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_,'CHG_STATUS: You cannot change the status on this period :P1 it exists in Period Allocation table', newrec_.accounting_period);
      END IF;
   END IF;
   period_rec_ := Accounting_Period_API.Get(newrec_.company, newrec_.accounting_year, newrec_.accounting_period);
   IF (period_rec_.year_end_period = 'YEARCLOSE') THEN
       Check_Previous_Year_End_Period(newrec_, period_rec_);
   END IF;
   IF (oldrec_.period_status <> newrec_.period_status) THEN
      IF (newrec_.period_status = 'F') THEN
         Validate_Final_Close___(newrec_);
      ELSIF (newrec_.period_status = 'C') THEN
         Validate_Close___(newrec_);
      ELSIF ( newrec_.ledger_id = '00') THEN
         $IF Component_Genled_SYS.INSTALLED $THEN
            Accounting_Journal_Item_API.Sync_Acc_Periods(newrec_.company, 
                                                         newrec_.accounting_year, 
                                                         newrec_.accounting_period);
         $ELSE
            NULL;
        $END
     END IF;     
   END IF;
END Check_Update___;

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN acc_period_ledger_info_tab%ROWTYPE )
IS
BEGIN
   Check_Delete_Record__(remrec_.company,
                         remrec_.accounting_year,
                         remrec_.accounting_period,
                         remrec_.ledger_id);                        
                         
   --Add pre-processing code here
   super(remrec_);
   --Add post-processing code here
END Check_Delete___;

PROCEDURE Validate_Close___ (
   newrec_ acc_period_ledger_info_tab%ROWTYPE )
IS
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      IF NVL(Acc_Journal_Year_API.Get_Sort_Order_Db(newrec_.company, newrec_.accounting_year), 'XXX') = 'SEQUENCE_NO' THEN
         IF (Gen_Led_Voucher_Row_API.Exists_Row_Not_In_Journal(newrec_.company, newrec_.accounting_year, newrec_.accounting_period) = 'TRUE') THEN
            Error_SYS.Record_General(lu_name_, 'ACCPERCLOSE10: Period :P1 can not be closed because not all voucher rows exist in Accounting Journal with Sort by "Sequence No"',
                                                newrec_.accounting_period);
         END IF;
      END IF;
   $ELSE
      NULL;
   $END
END Validate_Close___;

FUNCTION Is_Any_Il_Exists_In_Status___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN NUMBER,
   period_status_       IN VARCHAR2) RETURN BOOLEAN
IS
   temp_                   NUMBER;
   
   CURSOR is_any_open_il  IS
      SELECT 1
      FROM   acc_period_ledger_info_tab
      WHERE  company           = company_
      AND    accounting_year   = accounting_year_
      AND    accounting_period = accounting_period_
      AND    ledger_id        != '00'
      AND    period_status     = period_status_;
BEGIN
   OPEN is_any_open_il;
   FETCH is_any_open_il INTO temp_;
   IF (is_any_open_il%FOUND)THEN
      CLOSE is_any_open_il;
      RETURN TRUE;
   END IF;
   CLOSE is_any_open_il;
   RETURN FALSE;
END Is_Any_Il_Exists_In_Status___;


FUNCTION Is_Ye_Exists_In_Status_Gl___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   period_status_       IN VARCHAR2) RETURN BOOLEAN
IS
   temp_                   NUMBER;
   
   CURSOR is_any_open_ye  IS
      SELECT 1
      FROM   acc_period_ledger_info_tab l, accounting_period_tab ap
      WHERE  l.company             = ap.company
      AND    l.accounting_year     = ap.accounting_year
      AND    l.accounting_period   = ap.accounting_period
      AND    ap.year_end_period    = 'YEARCLOSE'
      AND    l.company             = company_
      AND    l.accounting_year     = accounting_year_
      AND    l.ledger_id           = '00'
      AND    l.period_status       = period_status_;
BEGIN
   OPEN is_any_open_ye;
   FETCH is_any_open_ye INTO temp_;
   IF (is_any_open_ye%FOUND)THEN
      CLOSE is_any_open_ye;
      RETURN TRUE;
   END IF;
   CLOSE is_any_open_ye;
   RETURN FALSE;
END Is_Ye_Exists_In_Status_Gl___;


FUNCTION Is_Ye_Exists_In_Status_Il___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   ledger_id_           IN VARCHAR2,
   period_status_       IN VARCHAR2) RETURN BOOLEAN
IS
   temp_                   NUMBER;
   
   CURSOR is_any_open_ye  IS
      SELECT 1
      FROM   acc_period_ledger_info_tab l, accounting_period_tab ap
      WHERE  l.company             = ap.company
      AND    l.accounting_year     = ap.accounting_year
      AND    l.accounting_period   = ap.accounting_period
      AND    l.ledger_id           = ledger_id_
      AND    ap.year_end_period    = 'YEARCLOSE'
      AND    l.company             = company_
      AND    l.accounting_year     = accounting_year_
      AND    l.ledger_id           != '00'
      AND    l.period_status       = period_status_;
BEGIN
   dbms_output.put_line(' FALSE');
   OPEN is_any_open_ye;
   FETCH is_any_open_ye INTO temp_;
   IF (is_any_open_ye%FOUND)THEN
      CLOSE is_any_open_ye;
      RETURN TRUE;
   END IF;
   CLOSE is_any_open_ye;
   RETURN FALSE;
END Is_Ye_Exists_In_Status_Il___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
PROCEDURE Get_Opening_Period__ (
   period_desc_            OUT VARCHAR2,
   valid_until_            OUT DATE,
   accounting_period_      OUT NUMBER,
   company_                IN  VARCHAR2,
   accounting_year_        IN  NUMBER,
   ledger_id_              IN  VARCHAR2,
   exclude_period_status_  IN  VARCHAR2 DEFAULT NULL )
IS
   CURSOR opening_period_data IS
      SELECT ap.accounting_period,
             ap.description,
             ap.date_until
      FROM   accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE  apl.company           = ap.company
      AND    apl.accounting_year   = ap.accounting_year
      AND    apl.accounting_period = ap.accounting_period
      AND    apl.ledger_id         = ledger_id_
      AND    apl.company           = company_
      AND    apl.accounting_year   = accounting_year_
      AND    ap.year_end_period    = 'YEAROPEN'
      AND    apl.period_status     = DECODE(exclude_period_status_, NULL, 'O', apl.period_status);

BEGIN
   OPEN opening_period_data;
   FETCH opening_period_data INTO accounting_period_, period_desc_, valid_until_;
   CLOSE opening_period_data;
END Get_Opening_Period__;

PROCEDURE Check_Delete_Record__ (
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   ledger_id_          IN     VARCHAR2)
IS
   attr_               VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr('ACCOUNTING_YEAR', accounting_year_, attr_);
   Client_SYS.Add_To_Attr('ACCOUNTING_PERIOD', accounting_period_, attr_);
   -- Move this to ledger_info
   $IF Component_Genled_SYS.INSTALLED $THEN
      IF ( ledger_id_ = '00') THEN
         Gen_Led_Voucher_API.Period_Delete_Allowed(attr_);       
         Project_Balance_API.Period_Delete_Allowed ( attr_ );
         Accounting_Journal_Item_API.Sync_Acc_Periods(company_, 
                                                      accounting_year_, 
                                                      accounting_period_);
         
      END IF;                                                   
   $END
   IF ( ledger_id_ = '00') THEN
      Voucher_API.Period_Delete_Allowed(attr_);
   END IF;
  
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF ( ledger_id_ != '00') THEN
         Internal_Voucher_API.Period_Delete_Allowed(  company_            ,
                                                      accounting_year_    ,
                                                      accounting_period_  ,
                                                      ledger_id_          );          
         Internal_Hold_Voucher_API.Period_Delete_Allowed(  company_      ,
                                                     accounting_year_    ,
                                                     accounting_period_  ,
                                                     ledger_id_          ); 
      END IF;
   $END   
END Check_Delete_Record__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Accounting_Periods(
   company_                     IN VARCHAR2,
   ledger_id_                   IN VARCHAR2,
   accounting_year_             IN NUMBER,
   source_year_                 IN NUMBER,
   acc_period_create_method_db_ IN VARCHAR2 )
IS   
   newrec_          acc_period_ledger_info_tab%ROWTYPE;         
   CURSOR get_period_data IS 
      SELECT * 
      FROM   accounting_period_tab
      WHERE  company         = company_
      AND    accounting_year = source_year_;  
BEGIN
   FOR period_rec_ IN get_period_data LOOP
      newrec_.company            := company_;
      newrec_.accounting_year    := accounting_year_;
      newrec_.ledger_id          := ledger_id_;
      newrec_.accounting_period  := period_rec_.accounting_period;
      IF (acc_period_create_method_db_ = 'CLOSED') OR (period_rec_.year_end_period = 'YEARCLOSE') THEN
         newrec_.period_status      := 'C';
      ELSE
         newrec_.period_status      := 'O';
      END IF;         
      New___(newrec_);
   END LOOP;
END Create_Accounting_Periods;

PROCEDURE Get_Previous_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_         IN VARCHAR2,
   current_period_  IN NUMBER,
   current_year_    IN NUMBER,
   ledger_id_       IN VARCHAR2)
IS
   period_staus_   VARCHAR2(1);
BEGIN
   period_staus_ := 'O';   
   Get_Previous_Period (previous_period_,
                        previous_year_,
                        company_,
                        current_period_,
                        current_year_,
                        ledger_id_,
                        period_staus_);
END Get_Previous_Period;

PROCEDURE Get_Previous_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_         IN VARCHAR2,
   current_period_  IN NUMBER,
   current_year_    IN NUMBER,
   ledger_id_       IN VARCHAR2,
   period_staus_    IN VARCHAR2)
IS
   CURSOR previous_acc_period IS
      SELECT accounting_year, accounting_period
      FROM   acc_period_ledger_info_tab
      WHERE  company   = company_
      AND    ledger_id = ledger_id_      
      AND    (accounting_year * 100) + accounting_period  <
             (current_year_ * 100 ) + current_period_
      AND    (period_status = period_staus_ OR period_staus_ IS NULL)
      ORDER BY (accounting_year) DESC, (accounting_period) DESC ;
BEGIN
   OPEN  previous_acc_period;
   FETCH previous_acc_period INTO previous_year_ , previous_period_ ;
   CLOSE previous_acc_period;
END Get_Previous_Period;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Next_Period (
   next_alloc_period_      OUT NUMBER,
   next_alloc_year_        OUT NUMBER,
   company_                IN  VARCHAR2,
   current_period_         IN  NUMBER,
   current_year_           IN  NUMBER,
   ledger_id_              IN  VARCHAR2)
IS
   CURSOR next_acc_period IS
      SELECT accounting_year, accounting_period
      FROM   acc_period_ledger_info_tab
      WHERE  company   = company_
      AND    ledger_id = ledger_id_
      AND    (accounting_year * 100) + accounting_period  >
             (current_year_ * 100) + current_period_
      AND    period_status = 'O'
      ORDER BY accounting_year, accounting_period ;
BEGIN
   OPEN  next_acc_period;
   FETCH next_acc_period INTO next_alloc_year_ , next_alloc_period_;
   CLOSE next_acc_period;
END Get_Next_Period;

FUNCTION Year_Balanced_At_Period_Close (
   company_         IN VARCHAR2,
   acc_year_        IN NUMBER,
   acc_period_      IN NUMBER,
   ledger_id_       IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_               NUMBER;
   amount_balance_      NUMBER;
   par_amount_balance_  NUMBER;
  
   CURSOR oth_open_periods IS
      SELECT 1
        FROM acc_period_ledger_info_tab
       WHERE company             = company_
         AND accounting_year     = acc_year_
         AND accounting_period  != acc_period_
         AND ledger_id           = ledger_id_
         AND period_status      != 'F';
BEGIN
   -- check if it is the last period in the year,
   OPEN oth_open_periods;
   FETCH oth_open_periods INTO dummy_;
   IF oth_open_periods%NOTFOUND THEN
      CLOSE oth_open_periods;
      -- it's last period in the year - check balances and return false when it's not 0
      IF ( ledger_id_ = '00') THEN
         $IF Component_Genled_SYS.INSTALLED $THEN
            Accounting_Balance_API.Cal_Tot_Amount_Bal(amount_balance_, company_, acc_year_, acc_year_);
         $END
         IF (NVL(amount_balance_,0) != 0) THEN
            RETURN 'FALSE';
         END IF;
      ELSE
         $IF Component_Intled_SYS.INSTALLED $THEN
            Int_Accounting_Balance_API.Cal_Tot_Amount_Bal_Par(amount_balance_, par_amount_balance_, company_, acc_year_, acc_year_, ledger_id_);
         $END
         IF (NVL(amount_balance_,0) != 0) THEN
            RETURN 'FALSE';
         END IF;
      END IF;
   ELSE
      CLOSE oth_open_periods;
   END IF;
   RETURN 'TRUE';  
END Year_Balanced_At_Period_Close;

PROCEDURE Close_Period_Finally (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2 )
IS
   info_           VARCHAR2(2000);
   attr_           VARCHAR2(2000);
BEGIN   
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('PERIOD_STATUS_DB', 'F', attr_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
END Close_Period_Finally;

PROCEDURE Close_Period (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2 )
IS
   info_           VARCHAR2(2000);
   attr_           VARCHAR2(2000);
BEGIN   
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('PERIOD_STATUS_DB', 'C', attr_ );
   Modify__( info_, objid_, objversion_, attr_, 'DO' );
END Close_Period;

PROCEDURE Open_Period (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2 )
IS
   info_           VARCHAR2(2000);
   attr_           VARCHAR2(2000);
BEGIN   
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('PERIOD_STATUS_DB', 'O', attr_);
   Modify__(info_, objid_, objversion_, attr_, 'DO');
END Open_Period;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Period_Status (
   period_status_     OUT VARCHAR2,
   company_           IN  VARCHAR2,
   accounting_year_   IN  NUMBER,
   accounting_period_ IN  NUMBER,
   ledger_id_         IN  VARCHAR2)
IS
BEGIN
   period_status_ := Get_Period_Status_Db(company_,
                                          accounting_year_  ,
                                          accounting_period_,
                                          ledger_id_);
END Get_Period_Status;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Period_Allowed (
   company_    IN VARCHAR2,
   period_     IN NUMBER,
   year_       IN NUMBER,
   ledger_id_  IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR allowed_period IS
      SELECT  '1'
      FROM     accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE    apl.company             = ap.company
      AND      apl.accounting_year     = ap.accounting_year
      AND      apl.accounting_period   = ap.accounting_period
      AND      apl.ledger_id           = ledger_id_
      AND      apl.company             = company_
      AND      apl.accounting_year     = year_
      AND      apl.accounting_period   = period_
      AND      apl.period_status       = 'O'
      AND      ap.year_end_period      = 'ORDINARY';

   is_allowed_       VARCHAR2(5);
BEGIN
   OPEN  allowed_period;
   FETCH allowed_period INTO is_allowed_;
   CLOSE allowed_period;

   IF (is_allowed_ = '1') THEN
      is_allowed_ := 'TRUE';
   ELSE
      is_allowed_ := 'FALSE';
   END IF;
   RETURN is_allowed_;
END Is_Period_Allowed;

@SecurityCheck Company.UserAuthorized(company_)   
PROCEDURE Get_Prev_Ordinary_Period (
   previous_period_    OUT NUMBER,
   previous_year_      OUT NUMBER,
   company_             IN VARCHAR2,
   current_period_      IN NUMBER,
   current_year_        IN NUMBER,
   ledger_id_           IN VARCHAR2,
   status_check_        IN VARCHAR2 DEFAULT NULL,
   no_of_periods_       IN NUMBER   DEFAULT NULL )
IS
   dummy_                  NUMBER := 1;
   dummy_no_of_periods_    NUMBER ;
   CURSOR prev_ordinary_acc_period IS
      SELECT   apl.accounting_year, apl.accounting_period
      FROM     accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE    apl.company             = ap.company
      AND      apl.accounting_year     = ap.accounting_year
      AND      apl.accounting_period   = ap.accounting_period
      AND      apl.ledger_id           = ledger_id_
      AND      apl.company             = company_
      AND      (apl.accounting_year * 100) + apl.accounting_period  <
               (current_year_ * 100 ) + current_period_
      AND      apl.period_status       = 'O'
      AND      ap.year_end_period      = 'ORDINARY'
      ORDER BY (apl.accounting_year) DESC, (apl.accounting_period) DESC ;

   CURSOR prev_ord_acc_period_status IS
      SELECT  accounting_year, accounting_period
      FROM    accounting_period_tab
      WHERE   company                  = company_
      AND     (accounting_year * 100) + accounting_period  <
              (current_year_ * 100 ) + current_period_
      AND     year_end_period          = 'ORDINARY'
      ORDER BY (accounting_year) DESC, (accounting_period) DESC ;
BEGIN
   dummy_no_of_periods_       := NVL(no_of_periods_, 1);
   IF (dummy_no_of_periods_ <= 0) THEN
      dummy_no_of_periods_    := 1;
   END IF;
   -- Note- This functionality was requested by PRJREP
   IF (status_check_ IS NULL) THEN
      FOR rec_ IN prev_ordinary_acc_period LOOP
         dummy_ := dummy_ + 1;
         previous_year_    := rec_.accounting_year; 
         previous_period_  := rec_.accounting_period;
         EXIT WHEN (dummy_ > dummy_no_of_periods_ );
      END LOOP;
   ELSE
      FOR rec_ IN prev_ord_acc_period_status LOOP
         dummy_ := dummy_ + 1;
         previous_year_    := rec_.accounting_year; 
         previous_period_  := rec_.accounting_period;
         EXIT WHEN (dummy_ > dummy_no_of_periods_ );
      END LOOP;
   END IF;
END Get_Prev_Ordinary_Period;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Previous_Allowed_Period (
   prev_allowed_period_ OUT NUMBER,
   prev_allowed_year_   OUT NUMBER,
   company_             IN VARCHAR2,
   current_period_      IN NUMBER,
   current_year_        IN NUMBER,
   ledger_id_           IN VARCHAR2)
IS
   CURSOR prev_acc_period IS
      SELECT   apl.accounting_year, apl.accounting_period
      FROM     accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE    apl.company             = ap.company
      AND      apl.accounting_year     = ap.accounting_year
      AND      apl.accounting_period   = ap.accounting_period
      AND      apl.ledger_id           = ledger_id_
      AND      apl.company             = company_
      AND      (apl.accounting_year * 100) + apl.accounting_period  <
               (current_year_ * 100) + current_period_
      AND      apl.period_status       = 'O'
      AND      ap.year_end_period      = 'ORDINARY'
      ORDER BY accounting_year DESC, accounting_period DESC ;
BEGIN
   OPEN  prev_acc_period;
   FETCH prev_acc_period INTO prev_allowed_year_ , prev_allowed_period_  ;
   CLOSE prev_acc_period;
END Get_Previous_Allowed_Period;

--Done NN
PROCEDURE Check_Period_Closed (
   all_period_status_     OUT VARCHAR2,
   closed_exist_          OUT VARCHAR2,
   finally_closed_exist_  OUT VARCHAR2,
   company_               IN  VARCHAR2,
   accounting_year_       IN  NUMBER,
   closing_balances_db_   IN  VARCHAR2,
   ledger_id_             IN  VARCHAR2 )
IS
   period_tab_         Accounting_Period_API.PeriodTab;
   num_of_period_      NUMBER;
   period_status_      VARCHAR2(1);
  
BEGIN
   all_period_status_    := 'TRUE';
   closed_exist_         := 'FALSE';
   finally_closed_exist_ := 'FALSE';
   Accounting_Period_API.Get_All_Periods(period_tab_, num_of_period_, company_, accounting_year_,ledger_id_);
   FOR i IN 1..num_of_period_ LOOP
      period_status_ := Get_Period_Status_Db(company_, accounting_year_, period_tab_(i),ledger_id_);
      IF (period_status_ = 'O') THEN
         all_period_status_ := 'FALSE';
      ELSIF (period_status_ = 'C') THEN
         closed_exist_ := 'TRUE';
      ELSIF (period_status_ = 'F') THEN
         finally_closed_exist_ := 'TRUE';
      END IF;
   END LOOP;
   IF (closing_balances_db_ = 'FV') THEN
      period_status_ := Get_Period_Status_Db(company_, Accounting_Year_API.Find_Next_Available_Year(company_, accounting_year_), 0,ledger_id_);
      IF (period_status_ = 'C') OR (period_status_ = 'F') THEN
         all_period_status_ := 'FALSE';
      END IF;
   END IF;
END Check_Period_Closed;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Period_Open (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   accounting_period_  IN NUMBER,
   ledger_id_          IN VARCHAR2) RETURN VARCHAR2
IS
   status_             NUMBER;

   CURSOR is_period_open IS
      SELECT  1
      FROM    acc_period_ledger_info_tab
      WHERE   company           = company_
      AND     accounting_year   = accounting_year_
      AND     accounting_period = accounting_period_
      AND     ledger_id         = ledger_id_
      AND     period_status     = 'O';
BEGIN
   OPEN  is_period_open;
   FETCH is_period_open INTO status_;
   IF (is_period_open%NOTFOUND) THEN
      CLOSE is_period_open;
      RETURN 'FALSE';
   ELSE      
      CLOSE is_period_open;
      RETURN 'TRUE';
   END IF;
END Is_Period_Open;

FUNCTION Is_Open_Period_Exist_All (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   ledger_id_          IN VARCHAR2) RETURN VARCHAR2
IS
   status_             NUMBER;
   CURSOR is_period_open IS
      SELECT  1
      FROM    acc_period_ledger_info_tab
      WHERE   company           = company_
      AND     accounting_year   < accounting_year_
      AND     ledger_id         = ledger_id_
      AND     period_status     = 'O';
BEGIN
   OPEN  is_period_open;
   FETCH is_period_open INTO status_;
   IF (is_period_open%NOTFOUND) THEN
      CLOSE is_period_open;
      RETURN 'FALSE';
   ELSE      
      CLOSE is_period_open;
      RETURN 'TRUE';
   END IF;
END Is_Open_Period_Exist_All;

PROCEDURE Open_Period (
   company_           IN   VARCHAR2,
   accounting_year_   IN   NUMBER,
   accounting_period_ IN   NUMBER,
   ledger_id_         IN   VARCHAR2)
IS
   rec_ acc_period_ledger_info_tab%ROWTYPE;
BEGIN   
   rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_, ledger_id_);
   IF (rec_.period_status != 'C' ) THEN         
      Error_SYS.Record_General(lu_name_, 'WRONGPERIODSTATUS: Wrong period status.');         
   END IF;
   IF ( Acc_Year_Ledger_Info_API.Get_Year_Status_Db(company_, accounting_year_, ledger_id_) = 'C') THEN
      Error_SYS.Record_General(lu_name_, 'WRONGYEARSTATUS: Period cannot be opened as the year is already closed.');         
   END IF;
   rec_.period_status := 'O';     
   Modify___( rec_);   
 END Open_Period;
 
 PROCEDURE Open_All_IL_Period (
    company_           IN VARCHAR2,
    accounting_year_   IN NUMBER,
    accounting_period_ IN NUMBER)
 IS
    rec_   acc_period_ledger_info_tab%ROWTYPE;
    CURSOR get_periods IS
      SELECT  *
      FROM    acc_period_ledger_info_tab
      WHERE   company           = company_
      AND     accounting_year   = accounting_year_
      AND     accounting_period = accounting_period_
      AND     ledger_id  NOT IN ('00','*')
      AND     period_status = 'C';
BEGIN    
   -- Check whether Year is closed.
   FOR ledger_rec IN get_periods LOOP
     IF ( Acc_Year_Ledger_Info_API.Get_Year_Status_Db(company_, accounting_year_, ledger_rec.ledger_id) = 'C') THEN
        Error_SYS.Record_General(lu_name_, 'WRONGYEARSTATUS: Period cannot be opened as the year is already closed.');         
     END IF;
     rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_, ledger_rec.ledger_id);
     rec_.period_status := 'O';     
     Modify___( rec_);   
   END LOOP;
END Open_All_IL_Period;
 
PROCEDURE Close_Period (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   ledger_id_         IN VARCHAR2)
IS
   rec_                  acc_period_ledger_info_tab%ROWTYPE;   
BEGIN
   rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_, ledger_id_);
   rec_.period_status := 'C';     
   Modify___( rec_);   
END Close_Period;

 
PROCEDURE Close_All_IL_Period (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER)
IS
   rec_   acc_period_ledger_info_tab%ROWTYPE;
   CURSOR get_periods IS
      SELECT  *
      FROM    acc_period_ledger_info_tab
      WHERE   company           = company_
      AND     accounting_year   = accounting_year_
      AND     accounting_period = accounting_period_
      AND     ledger_id  NOT IN ('00','*')
      AND     period_status = 'O';
BEGIN
   FOR ledger_rec IN get_periods LOOP
      rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_, ledger_rec.ledger_id);
      rec_.period_status := 'C';
      Modify___( rec_);
   END LOOP;
END Close_All_IL_Period;
 
@UncheckedAccess
FUNCTION Period_Finally_Closed_Exist (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   ledger_id_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_  NUMBER;
   
   CURSOR check_period IS
      SELECT 1
      FROM   acc_period_ledger_info_tab
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    ledger_id       = ledger_id_
      AND    period_status   = 'F';
BEGIN   
   OPEN  check_period;
   FETCH check_period INTO dummy_;
   IF (check_period%FOUND) THEN
      CLOSE check_period;
      RETURN 'TRUE';
   ELSE
      CLOSE check_period;
      RETURN 'FALSE';
   END IF;
END Period_Finally_Closed_Exist;

PROCEDURE Close_Period_Finally (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   ledger_id_         IN VARCHAR2)
IS
   rec_                  acc_period_ledger_info_tab%ROWTYPE;   
BEGIN   
   rec_ := Get_Object_By_Keys___(company_, accounting_year_, accounting_period_, ledger_id_);
   rec_.period_status := 'F';     
   Modify___( rec_);   
END Close_Period_Finally;

PROCEDURE Get_Year_End_Period (
   accounting_period_ OUT NUMBER,
   period_des_        OUT VARCHAR2,
   valid_until_       OUT DATE,
   company_           IN  VARCHAR2,
   accounting_year_   IN  NUMBER,
   ledger_id_         IN  VARCHAR2,
   period_status_     IN  VARCHAR2 DEFAULT 'O' )
IS  
   period_rec_       Accounting_Period_API.public_rec;
   
   CURSOR year_end_period IS
      SELECT MAX(apl.accounting_period)
      FROM   accounting_period_tab ap, acc_period_ledger_info_tab apl
      WHERE  apl.company           = ap.company
      AND    apl.accounting_year   = ap.accounting_year
      AND    apl.accounting_period = ap.accounting_period
      AND    apl.company           = company_
      AND    apl.accounting_year   = accounting_year_
      AND    apl.ledger_id         = ledger_id_      
      AND    ap.year_end_period    = 'YEARCLOSE'
      AND    (apl.period_status    = period_status_ 
              OR (period_status_ = 'C' AND apl.period_status IN ('C','F'))
              OR (period_status_ = 'NONE'));
      
BEGIN   
   IF (period_status_ = 'NONE') THEN
      accounting_period_ := Accounting_Period_API.Get_Max_Year_End_Period(company_, accounting_year_);
   ELSE      
      OPEN year_end_period;
      FETCH year_end_period INTO accounting_period_;
      CLOSE year_end_period;
   END IF;

   IF (accounting_period_ IS NOT NULL ) THEN
      period_rec_  := Accounting_Period_API.Get(company_, accounting_year_, accounting_period_);
      period_des_  := period_rec_.description;
      valid_until_ := period_rec_.date_until;
   END IF;
END Get_Year_End_Period;

PROCEDURE Check_Previous_Year_End_Period (
   newrec_        IN Acc_Period_Ledger_Info_Tab%ROWTYPE,
   period_rec_    IN Accounting_Period_API.Public_Rec)
IS
   dummy1_               NUMBER;

   CURSOR check_open_year_end IS
      SELECT 1
      FROM   accounting_period_tab p, acc_period_ledger_info_tab l
      WHERE  p.company           = l.company
      AND    p.accounting_year   = l.accounting_year
      AND    p.accounting_period = l.accounting_period
      AND    p.company           = newrec_.company
      AND    p.accounting_year   = newrec_.accounting_year
      AND    p.accounting_period <> newrec_.accounting_period
      AND    p.year_end_period   = 'YEARCLOSE'
      AND    l.period_status     = 'O'
      AND    l.ledger_id         = newrec_.ledger_id;
   
BEGIN
   IF (newrec_.period_status = 'O') THEN
      OPEN check_open_year_end;
      FETCH check_open_year_end INTO dummy1_;
      IF (check_open_year_end%FOUND) THEN
         CLOSE check_open_year_end;
         Error_SYS.Record_General(lu_name_, 'YEARENDPERIOD6: More than one Year End Period can not be Open at the same time ');
      END IF;
      CLOSE check_open_year_end;
   END IF;  
   
END Check_Previous_Year_End_Period;

PROCEDURE Check_Close_Period (
   company_           IN  VARCHAR2,
   accounting_year_   IN  NUMBER,
   accounting_period_ IN  NUMBER,
   ledger_id_         IN  VARCHAR2)
IS
   result_            VARCHAR2(5):= 'FALSE';
BEGIN      
   IF ( ledger_id_ = '00') THEN
      Voucher_API.Check_If_Postings_In_Voucher(result_, company_, accounting_period_, accounting_year_);
   ELSE
      $IF Component_Intled_SYS.INSTALLED $THEN
         Internal_Hold_Voucher_API.Check_If_Postings_In_Voucher(result_, company_, ledger_id_, accounting_period_, accounting_year_ );
      $ELSE         
         result_ := 'FALSE';
      $END      
   END IF;      
   IF (result_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_,'PER_HOLD_WAI: There are transactions in the wait table that belongs to this period :P1', accounting_period_);
   END IF;
END Check_Close_Period;


@UncheckedAccess
FUNCTION All_Il_Period_Status(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   accounting_period_   IN VARCHAR2) RETURN VARCHAR2
IS
   open_                  NUMBER := 0;
   close_                 NUMBER := 0;
   
   CURSOR period_status_  IS
      SELECT p.period_status
      FROM   acc_period_ledger_info_tab p, acc_year_ledger_info_tab y
      WHERE  p.company             =  y.company
      AND    p.accounting_year     =  y.accounting_year
      AND    p.ledger_id           =  y.ledger_id
      AND    y.year_status         =  'O'
      AND    p.company             =  company_
      AND    p.accounting_year     =  accounting_year_
      AND    p.accounting_period   =  accounting_period_
      AND    p.ledger_id           != '00';
BEGIN
   FOR rec_ IN period_status_ LOOP
      IF rec_.period_status = 'O' THEN
         open_ := 1;
      ELSIF rec_.period_status = 'C' THEN
         close_ := 1;
      END IF;
   END LOOP;

   IF close_ = 1 AND open_ = 1 THEN
      RETURN 'BOTH';
   ELSIF close_ = 1 THEN
      RETURN 'OPEN';
   ELSIF open_ = 1 THEN
      RETURN 'CLOSE';
   ELSE
      RETURN 'NONE';
   END IF;

END All_Il_Period_Status;
 -------------------- LU  NEW METHODS -------------------------------------

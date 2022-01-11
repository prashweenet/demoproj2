-----------------------------------------------------------------------------
--
--  Logical unit: AccYearLedgerInfo
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  170907  Bhhilk  STRFI-9708, Merged Bug 137379, used Accounting_Year_API.Find_Next_Available_Year instead of acc_year + 1.
--  190110  Nudilk  Bug 146161, Corrected Export___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Is_Any_Il_Exists_In_Status___(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   year_status_         IN VARCHAR2) RETURN BOOLEAN
IS
   temp_                   NUMBER;
   
   CURSOR is_any_open_il  IS
      SELECT 1
      FROM   acc_year_ledger_info_tab
      WHERE  company           = company_
      AND    accounting_year   = accounting_year_
      AND    ledger_id        != '00'
      AND    year_status      = year_status_;
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

PROCEDURE Assign_Values___ (
   newrec_          OUT acc_year_ledger_info_tab%ROWTYPE,
   company_         IN  VARCHAR2,
   accounting_year_ IN  VARCHAR2 )
IS   
BEGIN
   newrec_.company               := company_;
   newrec_.accounting_year       := accounting_year_;
   newrec_.ledger_id             := '00';
   newrec_.opening_balances      := 'N';
   newrec_.closing_balances      := 'N';
   newrec_.year_status           := 'O';
END Assign_Values___;


PROCEDURE Validate_Accounting_Year___( 
   accounting_year_ IN NUMBER)
IS   
BEGIN
   IF (accounting_year_ IS NULL) THEN
      Error_SYS.Record_General( lu_name_, 'NO_ACCYEAR: Not a valid Accounting Year' );
   END IF;   
END Validate_Accounting_Year___;

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        acc_year_ledger_info_tab%ROWTYPE;
   empty_rec_     acc_year_ledger_info_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   
   CURSOR get_data IS
      SELECT N1, C1, C2, C3, C4
      FROM   create_company_template_pub src
      WHERE  component   = 'ACCRUL'
      AND    lu          = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM   acc_year_ledger_info_tab dest
                         WHERE  dest.company         = crecomp_rec_.company
                         AND    dest.accounting_year = src.N1
                         AND    dest.ledger_id       = src.C1);
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
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');                     
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
               newrec_.ledger_id         := rec_.c1;
               newrec_.opening_balances  := rec_.c2;
               newrec_.closing_balances  := rec_.c3;
               newrec_.year_status       := rec_.c4;
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         -- this statement is to add to the log that the Create company process for LUs is finished even if
         -- has been performed
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_        acc_year_ledger_info_tab%ROWTYPE;
   empty_rec_     acc_year_ledger_info_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   any_rows_      BOOLEAN := FALSE;
   
   CURSOR get_data IS
      SELECT accounting_year
      FROM   acc_year_ledger_info_tab src
      WHERE  company   = crecomp_rec_.old_company
      AND    ledger_id = '00'
      AND    NOT EXISTS (SELECT 1 
                         FROM   acc_year_ledger_info_tab dest
                         WHERE  dest.company         = crecomp_rec_.company
                         AND    dest.accounting_year = src.accounting_year
                         AND    dest.ledger_id       = '00');

BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   any_rows_ := Exist_Any___(crecomp_rec_.company);

   IF (NOT any_rows_) AND (crecomp_rec_.user_defined = 'TRUE') THEN
      FOR k in 0..crecomp_rec_.number_of_years-1 LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            Assign_Values___(newrec_, crecomp_rec_.company, crecomp_rec_.acc_year + k);
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');                     
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
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-25,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);                                                   
            END;
         END LOOP;
         IF (i_ = 0) THEN
            msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully', msg_);                                                   
         ELSE
            IF (msg_ IS NULL) THEN
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');                  
            ELSE
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');                     
            END IF;                     
         END IF;
      ELSE
         -- this statement is to add to the log that the Create company process for LUs is finished even if
         -- nothing has been performed
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedSuccessfully');
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACC_YEAR_LEDGER_INFO_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT accounting_year
      FROM   acc_year_ledger_info_tab
      WHERE  company   = crecomp_rec_.company
      AND    ledger_id = '00';
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      pub_rec_.n1          := pctrec_.accounting_year;
      pub_rec_.c1          := '00';
      pub_rec_.c2          := 'N';
      pub_rec_.c3          := 'N';
      pub_rec_.c4          := 'O'; 
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(attr_);
   Client_SYS.Add_To_Attr('OPENING_BALANCES', Acc_Year_Op_Bal_API.Decode('N'), attr_);
   Client_SYS.Add_To_Attr('CLOSING_BALANCES', Acc_Year_Cl_Bal_API.Decode('N'), attr_);
   Client_SYS.Add_To_Attr('YEAR_STATUS', Acc_Year_Per_Status_API.Decode('O'), attr_);
   Client_SYS.Add_To_Attr('YEAR_STATUS_DB', 'O', attr_);   
   --Add post-processing code here
END Prepare_Insert___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     acc_year_ledger_info_tab%ROWTYPE,
   newrec_ IN OUT acc_year_ledger_info_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   IF ( indrec_.year_status) THEN
      IF ( newrec_.ledger_id = '00' AND oldrec_.year_status = 'C' AND newrec_.year_status = 'O' AND Is_Any_Il_Exists_In_Status___(newrec_.company, newrec_.accounting_year, 'C')) THEN
         Error_SYS.Record_General (lu_name_, 'ILNOTOPEN: All the internal ledgers should be open for the year :P1 prior to open up the closed accounting year for the general ledger.', newrec_.accounting_year);      
      ELSIF ( newrec_.ledger_id != '00' AND oldrec_.year_status = 'O' AND newrec_.year_status = 'C' AND (Get_Year_Status_Db(newrec_.company, newrec_.accounting_year, '00') NOT IN ('F', 'C'))) THEN
         Error_SYS.Record_General (lu_name_, 'GLNOTCLOSED: The general ledger should be closed for the year :P1 prior to run the year end for IL.', newrec_.accounting_year);
      END IF;
   END IF;
   --Add post-processing code here
END Check_Update___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
PROCEDURE Open_Up_Closed_Year__ (
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   ledger_id_           IN VARCHAR2)
IS 
  
  oldrec_   Acc_Year_Ledger_Info_Tab%ROWTYPE;
  newrec_   Acc_Year_Ledger_Info_Tab%ROWTYPE;
BEGIN
   oldrec_  := Lock_By_Keys___(company_, accounting_year_, ledger_id_);
   newrec_  := oldrec_;   
   Validate_Accounting_Year___(newrec_.accounting_year);
   newrec_.year_status := 'O';
   Modify___(newrec_);   
END Open_Up_Closed_Year__;

PROCEDURE Update_Year_Data__ (
   company_             IN VARCHAR2,
   from_year_           IN NUMBER,
   from_period_         IN NUMBER,
   ledger_id_           IN VARCHAR2,
   closing_balances_db_ IN VARCHAR2 )
IS   
   oldrec_      acc_year_ledger_info_tab%ROWTYPE;
   newrec_      acc_year_ledger_info_tab%ROWTYPE;
BEGIN
   oldrec_  := Lock_By_Keys___(company_, from_year_, ledger_id_);
   newrec_  := oldrec_;
   Validate_Accounting_Year___(newrec_.accounting_year);   
   IF (from_period_ != 0) THEN      
      newrec_.closing_balances := closing_balances_db_;
   ELSE
      newrec_.opening_balances := closing_balances_db_;
   END IF;   
   Modify___(newrec_);  
END Update_Year_Data__;

PROCEDURE Close_Opened_Year__ (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   ledger_id_        IN VARCHAR2)
IS  
   oldrec_      Acc_Year_Ledger_Info_Tab%ROWTYPE;
   newrec_      Acc_Year_Ledger_Info_Tab%ROWTYPE;
BEGIN
   oldrec_  := Lock_By_Keys___(company_, accounting_year_, ledger_id_);
   newrec_  := oldrec_;
   Validate_Accounting_Year___(newrec_.accounting_year);   
   -- based on the presumption, that alternatively: all of the periods must be 'closed' or all must be 'finally closed' 
   -- (which is hopefully validated before).
   IF (Acc_Period_Ledger_Info_API.Period_Finally_Closed_Exist(company_, accounting_year_, ledger_id_) != 'TRUE') THEN
      newrec_.year_status := 'C';      
   ELSE
      newrec_.year_status := 'F';
   END IF;
   Modify___(newrec_);   
END Close_Opened_Year__;

PROCEDURE Change_Balance_State__ (
   company_       IN VARCHAR2,
   acc_year_      IN NUMBER,
   acc_period_    IN NUMBER,
   ledger_id_     IN VARCHAR2)
IS   
BEGIN   
   Update_Year_Data__ (company_, acc_year_, acc_period_, ledger_id_, 'N'); 
END Change_Balance_State__;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Prev_Not_Open_Bal_Year (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   ledger_id_        IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ NUMBER;
   CURSOR get_attr IS
      SELECT 1
      FROM   acc_year_ledger_info_tab
      WHERE  company           = company_      
      AND    accounting_year   <= accounting_year_
      AND    ledger_id         = ledger_id_
      AND    opening_balances IN ('FB','FV');
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   IF (get_attr%FOUND) THEN
      CLOSE get_attr;
      RETURN 'TRUE';
   END IF;
   CLOSE get_attr;
   RETURN 'FALSE';
END Check_Prev_Not_Open_Bal_Year;

@UncheckedAccess
FUNCTION Get_First_Year (
   company_          IN VARCHAR2,
   ledger_id_        IN VARCHAR2) RETURN NUMBER
IS
   temp_ NUMBER;
   CURSOR get_attr IS
      SELECT MIN(accounting_year)
      FROM   acc_year_ledger_info_tab
      WHERE  company           = company_      
      AND    ledger_id         = ledger_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   
   RETURN temp_;
END Get_First_Year;

PROCEDURE Update_Year_Status (
   company_         IN  VARCHAR2,
   accounting_year_ IN  VARCHAR2,
   ledger_id_       IN VARCHAR2 )
IS      
   newrec_ acc_year_ledger_info_tab%ROWTYPE;
   oldrec_ acc_year_ledger_info_tab%ROWTYPE;
   CURSOR get_attr IS
      SELECT accounting_year
      FROM   acc_year_ledger_info_tab
      WHERE  company           = company_ 
      AND    accounting_year   < accounting_year_
      AND    Get_Year_Status_Db(company_, accounting_year, '00') IN ('C', 'F')
      AND    ledger_id         = ledger_id_;
BEGIN 
   IF Acc_Period_Ledger_Info_API.Is_Open_Period_Exist_All(company_,accounting_year_,ledger_id_) ='TRUE' THEN
       Error_SYS.Record_General (lu_name_, 'NOPRCLOS: All accounting periods from accounting year '||Get_First_Year(company_,ledger_id_)||' to accounting year '||accounting_year_||' are not closed.');
   END IF;
   FOR year_ IN get_attr  LOOP
      oldrec_              := Lock_By_Keys___(company_,year_.accounting_year, ledger_id_);
      newrec_              := oldrec_;
      newrec_.year_status  := 'C';
      newrec_.accounting_year := year_.accounting_year;
      Modify___(newrec_);
   END LOOP;
END Update_Year_Status;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


@UncheckedAccess
FUNCTION Check_Exist (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   ledger_id_       IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(company_, accounting_year_, ledger_id_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist;


PROCEDURE Final_Year_End (
   company_    IN    VARCHAR2,
   from_year_  IN    NUMBER,
   to_year_    IN    NUMBER,
   ledger_id_  IN    VARCHAR2)
IS   
   oldrec_     Acc_Year_Ledger_Info_Tab%ROWTYPE;
   newrec_     Acc_Year_Ledger_Info_Tab%ROWTYPE;
BEGIN
   -- from_year_
   oldrec_  := Lock_By_Keys___(company_, from_year_, ledger_id_);
   newrec_  := oldrec_;   
   Validate_Accounting_Year___(newrec_.accounting_year);   
   newrec_.closing_balances := 'FB';
   
   -- based on the presumption, that alternatively: all of the periods must be 'closed' or all must be 'finally closed' 
   -- (which is hopefully validated before).
   IF (Acc_Period_Ledger_Info_API.Period_Finally_Closed_Exist(company_, from_year_,ledger_id_) != 'TRUE') THEN
      newrec_.year_status := 'C';      
   ELSE
      newrec_.year_status := 'F';      
   END IF;
   Modify___(newrec_);   
   
   --to_year_
   oldrec_  := Lock_By_Keys___(company_, to_year_, ledger_id_);
   newrec_  := oldrec_;   
   Validate_Accounting_Year___(newrec_.accounting_year);   
   newrec_.opening_balances := 'FB';
   Modify___(newrec_);
END Final_Year_End;

PROCEDURE Open_Up_Closed_Year (
   company_    IN VARCHAR2,
   acc_year_   IN NUMBER,
   ledger_id_  IN VARCHAR2)
IS 
   next_year_   NUMBER;
   dummy_       NUMBER;
   oldrec_      acc_year_ledger_info_tab%ROWTYPE;
   newrec_      acc_year_ledger_info_tab%ROWTYPE;      

   CURSOR closed_open_period IS
      SELECT 1
      FROM   accounting_period_tab p, 
             acc_period_ledger_info_tab l
      WHERE  p.company           = l.company
      AND    p.accounting_year   = l.accounting_year      
      AND    p.accounting_period = l.accounting_period
      AND    p.company           = company_
      AND    p.accounting_year   = next_year_
      AND    ledger_id           = ledger_id_
      AND    p.year_end_period   = 'YEAROPEN'
      AND    l.period_status    IN ('F','C');
BEGIN   
   oldrec_  := Lock_By_Keys___(company_, acc_year_, ledger_id_);
   newrec_  := oldrec_;   
   
   Validate_Accounting_Year___(newrec_.accounting_year);
   
   IF (Get_Year_Status_Db(company_, Accounting_Year_API.Find_Next_Available_Year(company_,acc_year_), ledger_id_) != 'C') THEN
      -- Open the current year
      newrec_.year_status        := 'O';
      newrec_.closing_balances   := 'P';
      Modify___(newrec_);
      
      next_year_ := Accounting_Year_API.Find_Next_Available_Year(company_, acc_year_);
      IF (next_year_ IS NOT NULL) THEN
         -- set the next year status         
         oldrec_  := Lock_By_Keys___(company_, next_year_, ledger_id_);
         newrec_  := oldrec_;         
         Validate_Accounting_Year___(newrec_.accounting_year);         

         OPEN closed_open_period;
         FETCH closed_open_period INTO dummy_;
         IF (closed_open_period%FOUND) THEN
            CLOSE closed_open_period;
            Error_SYS.Record_General (lu_name_, 'NOPCLOS: The year cannot be re-opened when the opening period of the following year is closed!');
         END IF;
         CLOSE closed_open_period;

         newrec_.opening_balances := 'P';
         Modify___(newrec_);     
      END IF;      
   ELSE
      Error_SYS.Record_General(lu_name_, 'NOYEARSCLOSED: All subsequent years must be open');
   END IF;
END Open_Up_Closed_Year;

PROCEDURE Preliminary_Year_End (
   company_    IN VARCHAR2,
   from_year_  IN NUMBER,
   to_year_    IN NUMBER,
   ledger_id_  IN VARCHAR2)
IS
   oldrec_  acc_year_ledger_info_tab%ROWTYPE;
   newrec_  acc_year_ledger_info_tab%ROWTYPE;
BEGIN
   -- from year
   oldrec_  := Lock_By_Keys___(company_, from_year_, ledger_id_);
   newrec_  := oldrec_;    
   Validate_Accounting_Year___(newrec_.accounting_year);   
   newrec_.closing_balances := 'P';   
   Modify___(newrec_);
   
   -- to year   
   oldrec_  := Lock_By_Keys___(company_, to_year_, ledger_id_);
   newrec_  := oldrec_;   
   Validate_Accounting_Year___(newrec_.accounting_year);   
   newrec_.opening_balances := 'P';
   Modify___(newrec_);   
END  Preliminary_Year_End;

-- DONE
@SecurityCheck Company.UserAuthorized(company_)
@UncheckedAccess
FUNCTION Get_Opening_Balanecs_Db (
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   ledgr_id_         IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ acc_year_ledger_info_tab.opening_balances%TYPE;
   
   CURSOR get_attr IS
      SELECT opening_balances
      FROM   acc_year_ledger_info_tab
      WHERE  company         = company_      
      AND    accounting_year = accounting_year_
      AND    ledger_id       = ledgr_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Opening_Balanecs_Db;
-------------------- LU  NEW METHODS -------------------------------------

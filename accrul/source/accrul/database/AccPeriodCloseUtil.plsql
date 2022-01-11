-----------------------------------------------------------------------------
--
--  Logical unit: AccPeriodCloseUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  140812  Samllk  PRFI-229,    Added Utility and the methods Get_Ext_Trans_Types(), Get_Currency_Reval_Status(),
--                               Get_Revenue_Recog_Status(), Get_Procedure_Status(), Get_Bal_Trans_Cons_Status(),
--                               Get_Not_Transferred_Count(), Get_Month_End_Final_Status(), Get_Ext_Trans_Types_Db(),
--                               Get_Depr_Prop_Status()
--  141104  Samllk  PRFI-3258,   Added method Get_Not_Transferred_Count_()
--  150202  Samllk  PRFI-4269,   Removed Get_Bal_Trans_Cons_Status() and modified Get_Month_End_Final_Status()
--  150916  Samllk  AFT-4960,    Added methods to get the status of all transactions and added constants to represent statuses
--  151209  Bhhilk  STRFI-685,   Added UncheckedAccess annotation to Get_GL_Trans_Types(), Get_GL_Trans_Types_Db() methords
--  160701  Samllk  STRFI-2151   Merged Bug 130047
--  200219  Umdolk  Bug 152495   Changed Maintenance transactions to warnings according to the value from All_Postings_Trans_Error method.
--  200701  Jadulk  FISPRING20-6694 , Removed conacc related logic.
--  200902  Jadulk  FISPRING20-6694 , Removed Not Consolidated Balances from Subsidiaries constant related logic.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------
ERROR               CONSTANT NUMBER  := 3;
WARNING             CONSTANT NUMBER  := 2;
SUCCESS             CONSTANT NUMBER  := 1;
NOT_AVAILABLE       CONSTANT NUMBER  := 0;

-------------------- PRIVATE DECLARATIONS -----------------------------------



-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Ext_Trans_Types_Db  RETURN VARCHAR2
IS
BEGIN
   RETURN ('INVENTORY^PURCHASE^PROCESSING^RENTAL^MAINTENANCE TIME^TOOLS AND FACILITIES^WORK ORDER EXPENSES^WORK ORDER EXTERNALS^');   
END Get_Ext_Trans_Types_Db;

@UncheckedAccess
FUNCTION Get_Ext_Trans_Types  RETURN VARCHAR2
IS
   value_list_    VARCHAR2(4000);
BEGIN
   value_list_ := Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSINVNT: Inventory') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSPURCH: Purchase') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSPROCS: Processing') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSRENTL: Rental') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSMAINT: Maintenance Time') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSTOOLS: Tools and Facilities') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSWKEXP: Work Order Expenses') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'EXTTRANSWKEXT: Work Order Externals') || '^';
   
   RETURN Language_Sys.Translate_Constant(lu_name_, value_list_);   
END Get_Ext_Trans_Types;

@UncheckedAccess
FUNCTION Get_Currency_Reval_Status (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   ledger_id_         IN VARCHAR2 ) RETURN NUMBER
IS  
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      RETURN Currency_Revaluation_API.Get_Curr_Reval_Status_Lobby(company_, accounting_year_, accounting_period_, ledger_id_);
   $END
   RETURN NOT_AVAILABLE;   
END Get_Currency_Reval_Status;
   
@UncheckedAccess
FUNCTION Get_Procedure_Status (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   ledger_id_         IN VARCHAR2) RETURN NUMBER
IS   
BEGIN
   $IF Component_Percos_SYS.INSTALLED $THEN
      RETURN Cost_Allocation_Procedure_API.Get_Procedure_Status_Lobby(company_, accounting_year_, accounting_period_, ledger_id_);
   $END
   RETURN Acc_Period_Close_Util_API.NOT_AVAILABLE;   
   
END Get_Procedure_Status;
   
FUNCTION Get_Depr_Prop_Status (
    company_           IN VARCHAR2,
    accounting_year_   IN NUMBER,
    accounting_period_ IN NUMBER,
    ledger_id_         IN VARCHAR2) RETURN NUMBER
IS   
BEGIN
   $IF Component_Fixass_SYS.INSTALLED $THEN
      RETURN Depr_Proposal_API.Get_Depr_Prop_Status_Lobby(company_,accounting_year_, accounting_period_, ledger_id_ );
   $END
   RETURN NOT_AVAILABLE; 
    
END Get_Depr_Prop_Status;

@UncheckedAccess
FUNCTION Get_Not_Transferred_Count  (
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   trans_type_         IN     VARCHAR2)  RETURN NUMBER
IS
   end_date_            DATE;
BEGIN
   end_date_   := Accounting_Period_API.Get_Date_Until(company_, accounting_year_, accounting_period_);
   RETURN Get_Not_Transferred_Count_(company_, trans_type_, end_date_); 
END Get_Not_Transferred_Count;

@UncheckedAccess
FUNCTION Get_Not_Transferred_Count_  (
   company_            IN     VARCHAR2,
   trans_type_         IN     VARCHAR2,
   end_date_           IN     DATE DEFAULT NULL)  RETURN NUMBER
IS
   count_               NUMBER := 0;
   booking_source1_     VARCHAR2(15);
   booking_source2_     VARCHAR2(15) := NULL;
   cost_type_           VARCHAR2(20);
   voucher_type_        Voucher_Type_Tab.voucher_type%TYPE;
   function_group_      Function_Group_Tab.function_group%TYPE;
   
   $IF Component_Mpccom_SYS.INSTALLED $THEN
      CURSOR get_dist_manu_count_ IS
         SELECT COUNT(accounting_id)
         FROM   MPCCOM_ACCOUNTING
         WHERE  contract IN (select contract from site_public where company = company_)
         AND    status_code IN ('1', '2', '99')
         AND    date_applied <= end_date_
         AND    booking_source IN (booking_source1_, booking_source2_);
      CURSOR get_dist_manu_count_all_ IS
         SELECT COUNT(accounting_id)
         FROM   MPCCOM_ACCOUNTING
         WHERE  contract IN (select contract from site_public where company = company_)
         AND    status_code IN ('1', '2', '99')
         AND    booking_source IN (booking_source1_, booking_source2_);
   $END
BEGIN   
   IF(trans_type_ = 'INVENTORY') THEN
      booking_source1_ := 'INVENTORY';
   ELSIF (trans_type_ = 'PURCHASE') THEN
      booking_source1_ := 'PURCHASE';
   ELSIF (trans_type_ = 'PROCESSING') THEN
      booking_source1_ := 'LABOR';
      booking_source2_ := 'OPERATION';
   ELSIF (trans_type_ = 'RENTAL') THEN
      booking_source1_ := 'RENTAL';
   ELSIF (trans_type_ = 'MAINTENANCE TIME') THEN
      voucher_type_ :=  'MT';
   ELSIF (trans_type_ = 'TOOLS AND FACILITIES') THEN
      voucher_type_ :=  'MT2';
   ELSIF (trans_type_ = 'WORK ORDER EXPENSES') THEN
      voucher_type_ :=  'MT4';
   ELSIF (trans_type_ = 'WORK ORDER EXTERNALS') THEN
      voucher_type_ :=  'MT5';
   END IF;
   
   IF (trans_type_ IN ('INVENTORY', 'PURCHASE', 'PROCESSING', 'RENTAL')) THEN
      IF(booking_source2_ IS NULL) THEN
         booking_source2_ := booking_source1_;
      END IF;
      $IF Component_Mpccom_SYS.INSTALLED $THEN
         IF(end_date_ IS NOT NULL) THEN
            OPEN  get_dist_manu_count_;
            FETCH get_dist_manu_count_ INTO count_;
            CLOSE get_dist_manu_count_;
         ELSE
            OPEN  get_dist_manu_count_all_;
            FETCH get_dist_manu_count_all_ INTO count_;
            CLOSE get_dist_manu_count_all_;
         END IF;
      $ELSE
        NULL;
      $END
   ELSIF (trans_type_ IN ('MAINTENANCE TIME', 'TOOLS AND FACILITIES', 'WORK ORDER EXPENSES', 'WORK ORDER EXTERNALS')) THEN
      $IF Component_Wo_SYS.INSTALLED $THEN
         function_group_      := Voucher_Type_Detail_API.Get_Function_Group(company_, voucher_type_);
         IF (function_group_ = 'V') THEN
            cost_type_ := Work_Order_Cost_Type_API.DB_PERSONNEL;
         ELSIF (function_group_ = 'TF') THEN
            cost_type_ := Work_Order_Cost_Type_API.DB_TOOLS_FACILITIES;
         ELSIF (function_group_ = 'TP') THEN
            cost_type_ := Work_Order_Cost_Type_API.DB_EXTERNAL;
         ELSIF (function_group_ = 'TE') THEN
            cost_type_ := Work_Order_Cost_Type_API.DB_EXPENSES;
         END IF;
         count_ := Jt_Task_Accounting_Util_API.Get_Untransferd_Account_Count(company_, cost_type_, end_date_);
      $ELSE
        NULL;
      $END
   END IF;
   RETURN count_; 
END Get_Not_Transferred_Count_;

@UncheckedAccess
FUNCTION Get_Period_Allocation_Until (
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   ledger_id_          IN     VARCHAR2) RETURN NUMBER  
IS   
BEGIN
   IF ( ledger_id_ = '00') THEN
      RETURN Period_Allocation_API.Exists_Year_Period_Until(company_, accounting_year_, accounting_period_, ledger_id_);
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF ( ledger_id_ != '00') THEN
         RETURN Int_Period_Allocation_API.Exists_Year_Period_Until(company_, accounting_year_, accounting_period_, ledger_id_);
      END IF;
   $END
END Get_Period_Allocation_Until;

@UncheckedAccess
FUNCTION Get_Voucher_Count(
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   ledger_id_          IN     VARCHAR2) RETURN NUMBER
IS 
BEGIN
   IF ( NOT Company_Finance_API.Is_User_Authorized(company_) ) THEN
      RETURN 0;
   END IF;
   IF ( ledger_id_ = '00') THEN      
      RETURN Voucher_API.Get_Voucher_Count_Period_Until(company_, accounting_year_, accounting_period_);   
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      RETURN Internal_Hold_Voucher_API.Get_Voucher_Count_Period_Until(company_, accounting_year_, accounting_period_, ledger_id_);
   $END
END Get_Voucher_Count;

FUNCTION Get_Month_End_Final_Status(
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   ledger_id_          IN     VARCHAR2) RETURN NUMBER
IS
   start_date_          DATE;
   end_date_            DATE;
   result_              VARCHAR2(8);
   s_dummy_             VARCHAR2(100);
   year_end_period_     VARCHAR2(100);
   acc_period_rec_      Accounting_Period_API.Public_Rec;   
  
BEGIN
   acc_period_rec_ := Accounting_Period_API.Get(company_, accounting_year_, accounting_period_);
   
   start_date_       := acc_period_rec_.date_from;
   end_date_         := acc_period_rec_.date_until;
   year_end_period_  := acc_period_rec_.year_end_period;   
   
   IF (ledger_id_ IN ('00', '*')) THEN
      Voucher_API.Check_If_Postings_In_Voucher(result_, company_, accounting_period_, accounting_year_);
   END IF;
   IF (result_ = 'TRUE') THEN
      RETURN ERROR;     
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF (ledger_id_ NOT IN ('00', '*')) THEN
         Internal_Hold_Voucher_API.Check_If_Postings_In_Voucher(result_, company_, ledger_id_, accounting_period_, accounting_year_);
      END IF;
      IF (result_ = 'TRUE') THEN
         RETURN ERROR;     
      END IF;
   $END      
   
   IF (Period_Allocation_API.Check_Year_Period_Exist_Ledger(company_, accounting_year_, accounting_period_, ledger_id_) = 'TRUE') THEN
      RETURN ERROR;
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF (ledger_id_ NOT IN ('00', '*')) THEN
         IF (Int_Period_Allocation_API.Check_Year_Period_Exist_Ledger(company_, accounting_year_, accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN ERROR;
         END IF;
      END IF;
   $END    
   $IF Component_Genled_SYS.INSTALLED $THEN
      IF (Currency_Revaluation_API.Check_Non_Posted_Reval_Exist(company_, accounting_year_, accounting_period_, ledger_id_) = 'TRUE') THEN
         RETURN ERROR;
      ELSIF (Revenue_Recognition_API.All_Posted_For_Period_Ledger(company_, accounting_year_, accounting_period_, ledger_id_) = 'FALSE') THEN
         RETURN ERROR;
      END IF;
   $END
   $IF Component_Percos_SYS.INSTALLED $THEN
      IF (Cost_Allocation_Procedure_API.Check_Non_Closed_Proc_Exist(company_, accounting_year_, accounting_period_, ledger_id_) = 'TRUE') THEN
         RETURN ERROR;
      END IF;
   $END
   $IF Component_Mpccom_SYS.INSTALLED $THEN
      IF (Mpccom_Accounting_API.All_Postings_Transferred(company_, start_date_, end_date_) = 'FALSE') THEN
         RETURN ERROR;
      END IF;
   $END
   $IF Component_Wo_SYS.INSTALLED $THEN
      result_ := Jt_Task_Transaction_API.All_Postings_Trans_Error(company_, start_date_, end_date_);
      IF (result_ = 'ERROR') THEN
         RETURN ERROR;
      ELSIF (result_ = 'WARNING') THEN
         RETURN WARNING;   
      END IF;
   $END
   
   IF (year_end_period_ != Period_Type_API.DB_YEAR_OPENING) THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         Invoice_API.Post_Error_Invs_Exist(result_, company_, accounting_year_, accounting_period_, start_date_, end_date_);
         IF (result_ = 'TRUE') THEN
            RETURN WARNING;
         ELSE
            Invoice_Utility_Pub_API.Preliminary_Invs_Exist(result_, company_, accounting_year_, accounting_period_, start_date_, end_date_);
            IF (result_ = 'TRUE') THEN
               RETURN WARNING;
            ELSIF (Ext_Inc_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_, accounting_year_, accounting_period_, start_date_, end_date_) = 'TRUE') THEN   
               RETURN WARNING;
            ELSIF (Ext_Out_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_, accounting_year_, accounting_period_, start_date_, end_date_) = 'TRUE') THEN
               RETURN WARNING;
            END IF;
         END IF;
      $END
      $IF Component_Payled_SYS.INSTALLED $THEN         
         Prel_Payment_Trans_Util_API.Check_Non_Approved_Paym_Exists(result_, s_dummy_, company_, accounting_year_, accounting_period_, start_date_, end_date_);
         IF (result_ = 'TRUE') THEN
            RETURN WARNING;
         ELSIF (Mixed_Payment_API.All_Approved_For_Period(company_, accounting_year_, accounting_period_, start_date_, end_date_) = 'FALSE') THEN
            RETURN WARNING;
         ELSIF (Cash_Box_API.All_Approved_For_Period(company_, accounting_year_, accounting_period_, start_date_, end_date_) = 'FALSE') THEN
            RETURN WARNING;
         ELSIF(Ext_Payment_Head_API.Check_Non_Used_Pay_Exist(company_, accounting_year_, accounting_period_, start_date_, end_date_) = 'TRUE') THEN
            RETURN WARNING;
         END IF;
      $END
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF (Fa_Object_Transaction_API.All_Imp_Trans_Post_For_Period(company_, start_date_, end_date_) = 'FALSE') THEN
            RETURN WARNING;
         ELSIF (Change_Object_Value_Temp_API.All_Change_Acq_Post_For_Period(company_, start_date_, end_date_) = 'FALSE') THEN
            RETURN WARNING;
         ELSIF (Change_Object_Value_Temp_API.All_Change_Net_Post_For_Period(company_, start_date_, end_date_, ledger_id_) = 'FALSE') THEN
            RETURN WARNING;
         ELSIF (Depr_Proposal_API.All_Proposal_Post_For_Period(company_, accounting_year_, accounting_period_, ledger_id_) = 'FALSE') THEN
            RETURN WARNING;
         END IF;
      $END
      IF (Ext_Load_Info_API.Non_Created_Vou_Exist_Ledger(company_, start_date_, end_date_, ledger_id_) = 'TRUE') THEN
         RETURN WARNING;
      END IF;  
   END IF;
   RETURN SUCCESS;
END Get_Month_End_Final_Status;

@UncheckedAccess
FUNCTION Get_GL_Trans_Types  RETURN VARCHAR2
IS
   value_list_    VARCHAR2(4000);
BEGIN
   value_list_ := ' ^' || Language_sys.Translate_Constant(lu_name_ ,'TRANS1: Not Updated Vouchers') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS2: Not Updated Vouchers with Period Allocation') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS3: Not Posted Currency Revaluation') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS4: Not Posted Revenue Recognition') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS5: Not Closed Cost Allocation Procedure') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS7: Pending Transfers from Distribution/Manufacturing') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS9: Pending Transfers from Maintenance') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS8: Customer Invoices with Posting Errors') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS10: Customer Invoices in Preliminary Status') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS11: Not Approved Preliminary Payments') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS12: Not Approved Mixed Payments') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS13: Not Approved Cashbox') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS14: Not Posted Trans. in Post Imported Trans. Window') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS15: Not Posted Trans. in Change in Acq. Value') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS16: Not Posted Trans. in Change Net Value') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS17: Not Posted Depreciation Proposals') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS18: Ext. Vouchers waiting to be Created') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS19: Ext. Supplier Invoices waiting to be Created') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS20: Ext. Customer Invoices waiting to be Created') || '^';
   value_list_ := value_list_ || Language_sys.Translate_Constant(lu_name_ ,'TRANS21: Ext. Payments waiting to be Created') || '^';
   
   RETURN value_list_;
END Get_GL_Trans_Types;

@UncheckedAccess
FUNCTION Get_GL_Trans_Types_Db  RETURN VARCHAR2
IS
   value_list_    VARCHAR2(4000);
BEGIN
   value_list_ := ' ^' || 'NOT UPDATED VOUCHERS' || '^';
   value_list_ := value_list_ || 'NOT UPDATED VOUCHERS WITH PERIOD ALLOCATION' || '^';
   value_list_ := value_list_ || 'NOT POSTED CURRENCY REVALUATION' || '^';
   value_list_ := value_list_ || 'NOT POSTED REVENUE RECOGNITION' || '^';
   value_list_ := value_list_ || 'NOT CLOSED COST ALLOCATION PROCEDURE' || '^';
   value_list_ := value_list_ || 'PENDING TRANSFERS FROM DISTRIBUTION/MANUFACTURING' || '^';
   value_list_ := value_list_ || 'PENDING TRANSFERS FROM MAINTENANCE' || '^';
   value_list_ := value_list_ || 'CUSTOMER INVOICES WITH POSTING ERRORS' || '^';
   value_list_ := value_list_ || 'CUSTOMER INVOICES IN PRELIMINARY STATUS' || '^';
   value_list_ := value_list_ || 'NOT APPROVED PRELIMINARY PAYMENTS' || '^';
   value_list_ := value_list_ || 'NOT APPROVED MIXED PAYMENTS' || '^';
   value_list_ := value_list_ || 'NOT APPROVED CASHBOX' || '^';
   value_list_ := value_list_ || 'NOT POSTED TRANS IN POST IMPORTED TRANS WINDOW' || '^';
   value_list_ := value_list_ || 'NOT POSTED TRANS IN CHANGE IN ACQ VALUE' || '^';
   value_list_ := value_list_ || 'NOT POSTED TRANS IN CHANGE NET VALUE' || '^';
   value_list_ := value_list_ || 'NOT POSTED DEPRECIATION PROPOSALS' || '^';
   value_list_ := value_list_ || 'EXT VOUCHERS WAITING TO BE CREATED' || '^';
   value_list_ := value_list_ || 'EXT SUPPLIER INVOICES WAITING TO BE CREATED' || '^';
   value_list_ := value_list_ || 'EXT CUSTOMER INVOICES WAITING TO BE CREATED' || '^';
   value_list_ := value_list_ || 'EXT PAYMENTS WAITING TO BE CREATED' || '^';
   
   RETURN value_list_;
END Get_GL_Trans_Types_Db;

-- This is used by the Multi Company Lobby for Month End Process
@UncheckedAccess
FUNCTION Get_Not_Transferred  (
   company_            IN     VARCHAR2,
   accounting_year_    IN     NUMBER,
   accounting_period_  IN     NUMBER,
   ledger_id_          IN     VARCHAR2,
   trans_type_         IN     VARCHAR2)  RETURN NUMBER
IS
   start_date_          DATE;
   end_date_            DATE;  
   result_              VARCHAR2(8);
   exists_ledger_       BOOLEAN := TRUE;
BEGIN
   IF (company_ IS NULL AND trans_type_ != ' ' ) THEN
      RETURN NOT_AVAILABLE;
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF ( ledger_id_ NOT IN ('00', '*')) THEN
         exists_ledger_ := Internal_Ledger_API.Exists(company_, ledger_id_);
      END IF;
   $END
      
   Accounting_Period_API.Get_Period_Date(start_date_, end_date_, company_, accounting_year_, accounting_period_);   
   IF(trans_type_ = 'NOT UPDATED VOUCHERS') THEN
      IF (ledger_id_ = '00') THEN
         Voucher_API.Check_If_Postings_In_Voucher(result_, company_, accounting_year_, accounting_period_);            
      END IF;
      IF ( result_ = 'TRUE') THEN         
         RETURN ERROR;      
      END IF;      
      $IF Component_Intled_SYS.INSTALLED $THEN
         IF ( NOT exists_ledger_ ) THEN
            RETURN NOT_AVAILABLE;
         END IF;
         IF (ledger_id_ IS NOT NULL AND ledger_id_ != '00') THEN           
            Internal_Hold_Voucher_API.Check_If_Postings_In_Voucher(result_, company_, ledger_id_, accounting_period_, accounting_year_);
         END IF;
         IF (result_ = 'TRUE') THEN
            RETURN ERROR;     
         END IF;
      $END
      RETURN SUCCESS;
   ELSIF (trans_type_ = 'NOT UPDATED VOUCHERS WITH PERIOD ALLOCATION') THEN
      IF (ledger_id_ = '00') THEN
         IF(Period_Allocation_API.Check_Year_Period_Exist_Ledger(company_, accounting_year_ , accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN ERROR;
         END IF;
      END IF;
      $IF Component_Intled_SYS.INSTALLED $THEN
         
         IF (ledger_id_ IS NOT NULL AND ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
            IF (Int_Period_Allocation_API.Check_Year_Period_Exist_Ledger(company_, accounting_year_, accounting_period_, ledger_id_) = 'TRUE') THEN
               RETURN ERROR;
            END IF;
         END IF;
      $END      
      RETURN SUCCESS;      
   ELSIF (trans_type_ = 'NOT POSTED CURRENCY REVALUATION') THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         IF ( ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
         END IF;
         IF(Currency_Revaluation_API.Check_Non_Posted_Reval_Exist(company_, accounting_year_ , accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN ERROR;
         ELSE
            RETURN SUCCESS;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT POSTED REVENUE RECOGNITION') THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         IF ( ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
         END IF;
         IF(Revenue_Recognition_API.All_Posted_For_Period_Ledger(company_, accounting_year_ , accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN ERROR;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT CLOSED COST ALLOCATION PROCEDURE') THEN
      $IF Component_Percos_SYS.INSTALLED $THEN
         IF ( ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
         END IF;
         IF(Cost_Allocation_Procedure_API.Check_Non_Closed_Proc_Exist(company_, accounting_year_ , accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN ERROR;
         ELSE
            RETURN SUCCESS;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'PENDING TRANSFERS FROM DISTRIBUTION/MANUFACTURING') THEN
      $IF Component_Mpccom_SYS.INSTALLED $THEN   
         IF(Mpccom_Accounting_API.All_Postings_Transferred(company_, start_date_, end_date_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN ERROR;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'PENDING TRANSFERS FROM MAINTENANCE') THEN
      $IF Component_Wo_SYS.INSTALLED $THEN
         result_ := Jt_Task_Transaction_API.All_Postings_Trans_Error(company_, start_date_, end_date_);
         IF (result_ = 'NOERROR') THEN
            RETURN SUCCESS;
         ELSIF (result_ = 'ERROR') THEN
            RETURN ERROR;
         ELSIF (result_ = 'WARNING') THEN
            RETURN WARNING;   
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'CUSTOMER INVOICES WITH POSTING ERRORS') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         RETURN Invoice_API.Get_Cust_Invo_Post_Err(company_, start_date_, end_date_);
      $END
      RETURN SUCCESS;      
   ELSIF (trans_type_ = 'CUSTOMER INVOICES IN PRELIMINARY STATUS') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
        RETURN Invoice_API.Get_Cust_Inv_Prelpost_Err(company_, start_date_, end_date_);
      $END
      RETURN SUCCESS;      
   ELSIF (trans_type_ = 'NOT APPROVED PRELIMINARY PAYMENTS') THEN
      $IF Component_Payled_SYS.INSTALLED $THEN 
         RETURN Prel_Payment_API.Get_Not_Approved_Prel_Pay(company_, start_date_, end_date_);
      $END
      RETURN SUCCESS;
      
   ELSIF (trans_type_ = 'NOT APPROVED MIXED PAYMENTS') THEN
      $IF Component_Payled_SYS.INSTALLED $THEN 
         RETURN Mixed_Payment_API.Get_Not_Approved_Mix_Pay(company_, start_date_, end_date_);
      $END
      RETURN SUCCESS;      
   ELSIF (trans_type_ = 'NOT APPROVED CASHBOX') THEN
      $IF Component_Payled_SYS.INSTALLED $THEN 
         RETURN Cash_Box_API.Get_Not_Approved_Cash_Box(company_, start_date_, end_date_);
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT POSTED TRANS IN POST IMPORTED TRANS WINDOW') THEN
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF(Fa_Object_Transaction_API.All_Imp_Trans_Post_For_Period(company_, start_date_, end_date_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN WARNING;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT POSTED TRANS IN CHANGE IN ACQ VALUE') THEN
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF(Change_Object_Value_Temp_API.All_Change_Acq_Post_For_Period(company_, start_date_, end_date_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN WARNING;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT POSTED TRANS IN CHANGE NET VALUE') THEN
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF ( ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
         END IF;
         IF(Change_Object_Value_Temp_API.All_Change_Net_Post_For_Period(company_, start_date_, end_date_, ledger_id_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN WARNING;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'NOT POSTED DEPRECIATION PROPOSALS') THEN
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF ( ledger_id_ != '00') THEN
            IF ( NOT exists_ledger_ ) THEN
               RETURN NOT_AVAILABLE;
            END IF;
         END IF;
         IF(Depr_Proposal_API.All_Proposal_Post_For_Period(company_, accounting_year_ , accounting_period_, ledger_id_) = 'TRUE') THEN
            RETURN SUCCESS;
         ELSE
            RETURN WARNING;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'EXT VOUCHERS WAITING TO BE CREATED') THEN
      IF ( ledger_id_ != '00') THEN
         IF ( NOT exists_ledger_ ) THEN
            RETURN NOT_AVAILABLE;
         END IF;
      END IF;
      IF(Ext_Load_Info_API.Non_Created_Vou_Exist_Ledger(company_, start_date_, end_date_, ledger_id_) = 'TRUE') THEN
         RETURN WARNING;
      ELSE
         RETURN SUCCESS;
      END IF;
   ELSIF (trans_type_ = 'EXT SUPPLIER INVOICES WAITING TO BE CREATED') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         IF(Ext_Inc_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_, accounting_year_ , accounting_period_, start_date_, end_date_) = 'TRUE') THEN
            RETURN WARNING;
         ELSE
            RETURN SUCCESS;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'EXT CUSTOMER INVOICES WAITING TO BE CREATED') THEN
      $IF Component_Invoic_SYS.INSTALLED $THEN
         IF(Ext_Out_Inv_Load_Info_API.Check_Non_Created_Inv_Exist(company_, accounting_year_ , accounting_period_, start_date_, end_date_) = 'TRUE') THEN
            RETURN WARNING;
         ELSE
            RETURN SUCCESS;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSIF (trans_type_ = 'EXT PAYMENTS WAITING TO BE CREATED') THEN
      $IF Component_Payled_SYS.INSTALLED $THEN
         IF(Ext_Payment_Head_API.Check_Non_Used_Pay_Exist(company_, accounting_year_ , accounting_period_, start_date_, end_date_) = 'TRUE') THEN
            RETURN WARNING;
         ELSE
            RETURN SUCCESS;
         END IF;
      $ELSE
         RETURN SUCCESS;
      $END
   ELSE
      RETURN NULL;
   END IF;
END Get_Not_Transferred;

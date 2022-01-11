-----------------------------------------------------------------------------
--
--  Logical unit: ExtCheck
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970128  MaGu    Created
--  970625  MiJo    Add nvl(voucher_no,0) on insert to table Ext_Voucher_Row Tab.
--  970807  SLKO    Converted to Foundation 1.2.2d
--  970820  DavJ    Added currency_debet_amount,currency_credit_amount,
--                  debet_amount, credit_amount
--  971016  JoTh    Sequence number used for Voucher No in Create_Voucher_Row__
--                  Calculation of difference posting corrected
--  971205  MiJo    Bug fix 2551, added abs round amount.
--  980226  MALR    Bug fix from 8.3.0b: Bug # 3360, procedure process_by_trans_date___.
--                  Additional corrections, CallId # 4139.
--  980303  MALR    Additional corrections, bug fix from 8.3.0b: Bug # 3360.
--  980812  JOBJ    Modified process_by_trans_date___
--  980914  ToKu    Bug # 4973 (Added new procedure Check_Transaction__)
--  981026  Bren    Third Currency
--                  Changed Process_By_Voucher_No,Process_By_Load_Group_Item___,
--                  Process_By_Ref_Number___, Process_By_Trans_Date___, Create_Voucher__,
--                  and Create_Voucher_Row__.
--  000912  HiMu    Added General_SYS.Init_Method
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  010301  JeGu    Bug # 20361 Changed Where-statements cursors for performance reasons
--  010530  JeGu    Some Code cleanup
--                  Some error-messages made translateable
--  010726  AjRolk  Bug ID 23210 Fixed, added voucher no validation to Validate_Transaction_Data__
--  010802  Uma     Corrected Bug# 23517.
--  010919  Uma     Corrected Bug# 24495.
--  020524  Hecolk  Bug 28600, Merged
--  020701  Uma     Did more changes under Bug# 28600.
--  021011  PPerse  Merged External Files
--  030211  JeGu    Changed Check_Transaction__(check if delete ext_voucher_tab etc) (part of bug 33919 ?)
--  030805  prdilk  SP4 Merge.
--  040324  Gepelk  2004 SP1 Merge.
--  040913  nsillk  Corrected Bug# 46250 Removed transaction_rec_.load_group_item getting null. 
--  050408  viselk  LCS Bug 49859 Merged.
--  050510  Nsillk  LCS Merge(50266).
--  051017  Jeguse  LCS Merge 53103
--  051116  WAPELK  Merged the Bug 52783. Correct the user group variable's width.
--  051223  Samwlk  LCS Bug 54573, Merged.
--  051223  Samwlk  LCS Bug 54799, Merged.
--  060208  Samwlk  LCS Bug 55284, Merged.
--  060209  Samwlk  LCS Bug 55422, Merged.
--  060308  Hecolk  LCS Merge 56037, Modified PROCEDURE Check_Project___
--  060802  Kagalk  LCS Merge 56398, Modified method Validate_Transaction_Data__ 
--  061025  GaDaLK  LCS Merge 59910.
--  061103  Thaylk  LCS Merge 57225, Corrected.
--  070207  Kagalk  LCS Merge 62180.    
--  070330  Kagalk  LCS Merge 58728.     
--  070522  Nimalk  LCS Merge 64926, Corrected. Modified method Create_Voucher 
--  070905  MARULK  LCS Merge 67358. Modification made to pass text seperatly to codestring validation.
--  070911  MAKRLK  LCS Merge 67468. Modified method Create_Voucher
--  080430  NiFelk  Bug 73280, Corrected in Validate_Transaction_Data__.
--  080909  AjPelk  Bug 71024 Corrected
--  090819  Nsillk  Bug 84885 Corrected
--  100710  Jaralk  Bug 91425, Corrected in create_Voucher__()
--  101011  AJPElk  Bug 92374 Corrected. added imp methods and codes 
--  110701  Sacalk  FIDEAGLE-891, Bug 97339 Corected.
--  110803  Kanslk  FIDEAGLE-1257, Moved 'Compare_Code_Strings_Info', 'Compare_Code_Part()', 'Is_File_Value()', 'Apply_Defined_Codestr()' 
--                             and 'Codepart_Info()' to Accounting_Codestr_Co_Util_API and modified Validate_Transaction_Data__ to reflect the move of methods.
--  111018  Swralk  SFI-128, Added conditional compilation for the places that had called package FIXASS_CONNECTION_V871_API.
--  111018  Shdilk  SFI-135, Conditional compilation.
--  120418  Clstlk  EASTRTM-8916 LCS Merge (Bug 101936).
--  120713  AJPELK  Bug 102402, Merged
--  120821  Sacalk  EDEL-1403, Added Columns to support Automation of Add investment in FA 
--  120829  Sacalk  EDEL-1353, Modified in PROCEDURE Process_By_Load_Group_Item___   
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk  PEPA-183, Removed global variables
--  130325  Shedlk  Bug 108853, Corrected in Validate_Transaction_Data__. Copied process_code to codestr_rec_ from transaction_rec_
--  130515  THPELK  Bug 109753, Corrected, make trans_code Uppercase in Create_Voucher_Row__().
--  130603  NIRPLK  Bug 110432, Corrected in Validate_Transaction_Data__().    
--  121123  Janblk  DANU-122, Parallel currency implementation.
--  130605  NILILK  DANU-1217, Modified Process_By_Load_Group_Item___.  
--  130607  NILILK  DANU-1311, Modified Create_Voucher__ to support Allow Voucher Differences Functionality for Parallel Currency
--  140313  THPELK  PBFI-4122 LCS Merge (Bug 113054).
--  140408  Nirylk  PBFI-5614, Modified Validate_Transaction_Data__(), Create_Voucher_Row__(), Create_Voucher__() and Check_Transaction()
--  140710  CLSTLK  PRFI-1013 LCS Merge (Bug 117598).
--  141202  Mawelk  PRFI-3865. Modify Create_Voucher_Row__()
--  150128  AjPelk  PRFI-4489, Lcs merge Bug 120401, Added check on new field CURRENCY_RATE_TYPE
--  160108  AjPelk  STRFI-694, LCS merged 125052.
--  160203  Chwilk  STRFI-1151, Modified Validate_Transaction_Data__.
--  160422  Savmlk  STRFI-1629, LCS merged Bug 128292.
--  170317  Chwtlk  STRFI-5391, Merged LCS Bug 134848, Modified Prepare_Tax_Transaction___ and Create_Voucher_Row__.
--  170404  Nudilk  Bug Bug 135160, Corrected.
--  170525  Savmlk  STRFI-6332, Modified Process_By_Load_Group_Item___() to handle rounding issue when there are multiple vouchers.
--  170626  Bhhilk  STRFI-6749, Merged LCS Bug 135719, Modified Validate_Transaction_Data__.
--  171221  Bhhilk  STRFI-11287, Merged LCS Bug 139430, Modified Validate_Transaction_Data__.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Process_By_Load_Group_Item___ (
   ext_group_by_item_ IN VARCHAR2,
   voucher_type_      IN VARCHAR2,
   ext_voucher_diff_  IN VARCHAR2,
   ext_voucher_date_  IN VARCHAR2,
   ext_vouch_extern_  IN VARCHAR2,
   load_date_         IN DATE,
   user_              IN VARCHAR2,
   company_           IN VARCHAR2,
   load_id_           IN VARCHAR2 )
IS   
   stmt_check_event_date_       VARCHAR2(4000);
   stmt_check_retro_date_       VARCHAR2(4000);
   stmt_check_trans_reason_     VARCHAR2(4000);
   err_msg_                     VARCHAR2(2000);
   err_msg_user_group_          VARCHAR2(2000);   
   tax_type_                    VARCHAR2(200);
   group_by_value_              VARCHAR2(30);
   rec_load_group_item_         VARCHAR2(50);
   rec_company_                 VARCHAR2(20);
   object_id_                   VARCHAR2(20);
   rec_object_id_               VARCHAR2(20);
   update_                      VARCHAR2(5) := 'FALSE';   
   def_amount_method_           VARCHAR2(5) := Company_Finance_API.Get_Def_Amount_Method_Db(company_);
   stat_acc_                    VARCHAR2(5);
   fa_code_part_                VARCHAR2(1);   
   
   amount_                      NUMBER;   
   acc_year_                    NUMBER;
   rec_load_id_                 NUMBER;   
   rec_records_                 NUMBER;
   third_curr_amount_           NUMBER;
   acc_period_                  NUMBER;
   num_user_group_              NUMBER;
   voucher_no_seq_              NUMBER := 0;   
   voucher_date_                DATE;   
   is_acqusition_acc_           BOOLEAN;
   error_                       BOOLEAN;   
   temp_user_group_             user_group_member_finance_tab.user_group%type;   
   new_trans_rec_               Ext_Transactions_API.ExtTransRec;
   old_trans_rec_               Ext_Transactions_API.ExtTransRec;
   third_curr_null_             VARCHAR2(5) := 'FALSE';
   load_file_id_                NUMBER;
   tax_code_rec_                Statutory_Fee_API.Public_Rec;

   CURSOR getrec IS
      SELECT company,
             load_id,
             record_no,
             load_group_item,
             load_error,
             transaction_date,
             voucher_type,
             voucher_no,
             accounting_year,
             account,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j,
             currency_debet_amount,
             currency_credit_amount,
             currency_amount,                -- to support old version
             debet_amount,
             credit_amount,
             amount,                         -- to support old version
             third_currency_debit_amount,
             third_currency_credit_amount,
             currency_code,
             quantity,
             process_code,
             optional_code,
             project_activity_id,
             text,
             party_type,
             party_type_id,
             reference_number,
             reference_serie,
             trans_code,
             tax_amount,
             user_group,
             event_date,
             retroactive_date,
             transaction_reason,
             third_currency_tax_amount
      FROM   Ext_Transactions
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    objstate = 'Loaded'
      ORDER BY load_group_item;

   TYPE DynamicCursorType IS REF CURSOR;
   dynamic_cursor_event_date_    DynamicCursorType;
   dynamic_cursor_retro_date_    DynamicCursorType;
   dynamic_cursor_trans_reason_  DynamicCursorType;
BEGIN
   err_msg_                       := '';
   error_                         := FALSE;
   amount_                        := 0;
   third_curr_amount_             := 0;
   old_trans_rec_.load_group_item := '';
   err_msg_user_group_            := '';
   num_user_group_                := 0;
   temp_user_group_               := NULL;
   
   load_file_id_:= Ext_Load_Info_API.Get_Load_File_Id(company_, load_id_);
   
   $IF Component_Fixass_SYS.INSTALLED $THEN 
      fa_code_part_            := Accounting_Code_Parts_API.Get_Codepart_Function(company_, 'FAACC');
      stmt_check_event_date_   := 'SELECT   company, load_id, load_group_item, code_'||fa_code_part_||' object_id, COUNT(DISTINCT event_date)records '|| 
                                  'FROM     ext_transactions_tab ' ||
                                  'WHERE    company  = :company_ ' ||
                                  'AND      load_id  = :load_id_ ' ||
                                  'GROUP BY company, load_id, load_group_item, code_'||fa_code_part_;
                                  
      stmt_check_retro_date_   := 'SELECT   company, load_id, load_group_item, code_'||fa_code_part_||' object_id, COUNT(DISTINCT retroactive_date)records '|| 
                                  'FROM     ext_transactions_tab ' ||
                                  'WHERE    company  = :company_ ' ||
                                  'AND      load_id  = :load_id_ ' ||
                                  'GROUP BY company, load_id, load_group_item, code_'||fa_code_part_;   
                                  
      stmt_check_trans_reason_ := 'SELECT   company, load_id, load_group_item, code_'||fa_code_part_||' object_id, COUNT(DISTINCT transaction_reason)records '|| 
                                  'FROM     ext_transactions_tab ' ||
                                  'WHERE    company  = :company_ ' ||
                                  'AND      load_id  = :load_id_ ' ||
                                  'GROUP BY company, load_id, load_group_item, code_'||fa_code_part_;                              
   $END
   
   OPEN getrec;
   LOOP
      FETCH getrec
         INTO new_trans_rec_.company,
              new_trans_rec_.load_id,
              new_trans_rec_.record_no,
              new_trans_rec_.load_group_item,
              new_trans_rec_.load_error,
              new_trans_rec_.transaction_date,
              new_trans_rec_.voucher_type,
              new_trans_rec_.voucher_no,
              new_trans_rec_.accounting_year,
              new_trans_rec_.codestring_rec.code_a,
              new_trans_rec_.codestring_rec.code_b,
              new_trans_rec_.codestring_rec.code_c,
              new_trans_rec_.codestring_rec.code_d,
              new_trans_rec_.codestring_rec.code_e,
              new_trans_rec_.codestring_rec.code_f,
              new_trans_rec_.codestring_rec.code_g,
              new_trans_rec_.codestring_rec.code_h,
              new_trans_rec_.codestring_rec.code_i,
              new_trans_rec_.codestring_rec.code_j,
              new_trans_rec_.currency_debet_amount,
              new_trans_rec_.currency_credit_amount,
              new_trans_rec_.currency_amount,            -- to support old version
              new_trans_rec_.debet_amount,
              new_trans_rec_.credit_amount,
              new_trans_rec_.amount,                     -- to support old version
              new_trans_rec_.third_currency_debit_amount,
              new_trans_rec_.third_currency_credit_amount,
              new_trans_rec_.currency_code,
              new_trans_rec_.quantity,
              new_trans_rec_.process_code,
              new_trans_rec_.optional_code,
              new_trans_rec_.project_activity_id,
              new_trans_rec_.text,
              new_trans_rec_.party_type,
              new_trans_rec_.party_type_id,
              new_trans_rec_.reference_number,
              new_trans_rec_.reference_serie,
              new_trans_rec_.trans_code,
              new_trans_rec_.tax_amount,
              new_trans_rec_.user_group,
              new_trans_rec_.event_date,
              new_trans_rec_.retroactive_date,
              new_trans_rec_.transaction_reason,
              new_trans_rec_.third_currency_tax_amount;
      IF ((old_trans_rec_.load_group_item IS NULL) OR (old_trans_rec_.load_group_item != new_trans_rec_.load_group_item)) THEN
         IF (num_user_group_ >= 1) THEN
            err_msg_user_group_ := 'SAME_USERG: Transaction lines per voucher should have the same user group';
            BEGIN
               Error_SYS.Record_General('ExtCheck', 'SAME_USERG: Transaction lines per voucher should have the same user group');
            EXCEPTION
               WHEN OTHERS THEN
                  err_msg_user_group_ := SQLERRM;
            END;
            Ext_Transactions_API.Update_Load_Error(old_trans_rec_.company,
                                                   old_trans_rec_.load_id,
                                                   old_trans_rec_.load_group_item,
                                                   ext_group_by_item_,
                                                   err_msg_user_group_);
            error_ := TRUE;    
         END IF;
         IF (old_trans_rec_.load_group_item IS NOT NULL) THEN
            temp_user_group_ := NULL;
            num_user_group_ := 0;
            err_msg_user_group_ := '';
         END IF;
      END IF;
      IF (temp_user_group_ IS NULL) THEN
         temp_user_group_ := new_trans_rec_.user_group;
      ELSE
         IF (temp_user_group_ <> new_trans_rec_.user_group) THEN
            num_user_group_ := num_user_group_ + 1;
         END IF;
      END IF;    

      EXIT WHEN getrec%NOTFOUND;

      IF (new_trans_rec_.load_error IS NOT NULL) AND (error_ = FALSE) THEN
         error_ := TRUE;
      END IF;      
      stat_acc_ := Accounting_Code_Part_A_API.Is_Stat_Account(new_trans_rec_.company, new_trans_rec_.codestring_rec.code_a);
      IF (new_trans_rec_.optional_code IS NOT NULL)THEN 
         tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(new_trans_rec_.company, new_trans_rec_.optional_code, new_trans_rec_.transaction_date, 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
         tax_type_     := tax_code_rec_.fee_type;
      END IF;
      IF (old_trans_rec_.load_group_item IS NULL OR (old_trans_rec_.load_group_item != new_trans_rec_.load_group_item)) THEN
         IF (error_ = FALSE) THEN
            IF (old_trans_rec_.load_group_item IS NOT NULL) THEN
               group_by_value_ := old_trans_rec_.load_group_item;
               third_curr_null_:= Is_Par_Amount_Null(load_file_id_, ext_group_by_item_, group_by_value_);
               IF (ext_voucher_diff_ = 'N') AND (amount_ != 0 OR (third_curr_amount_ !=0 AND third_curr_null_ = 'TRUE')) THEN
                  IF (amount_ != 0) THEN
                     err_msg_ := 'VOU_NOT_BAL: Voucher :P1 is not balanced in accounting currency';
                  ELSE                     
                     err_msg_ := 'VOU_NOT_PAR_BAL: Voucher :P1 is not balanced in parallel currency';
                  END IF;
                  BEGIN
                     Error_SYS.Record_General('ExtCheck', err_msg_, old_trans_rec_.load_group_item);
                  EXCEPTION
                     WHEN OTHERS THEN
                        err_msg_ := SQLERRM;
                  END;
                  Ext_Transactions_API.Update_Load_Error(old_trans_rec_.company,
                                                         old_trans_rec_.load_id,
                                                         group_by_value_,
                                                         ext_group_by_item_,
                                                         err_msg_);
               ELSE
                  IF (ext_voucher_diff_ = '2' AND amount_ = 0 AND third_curr_amount_ !=0 AND third_curr_null_= 'FALSE') THEN
                     Balance_Parallel_Diff___(company_, load_id_, third_curr_amount_, group_by_value_);
                  END IF;                   
                  Create_Voucher__(voucher_no_seq_,
                                   old_trans_rec_.company,
                                   old_trans_rec_.load_id,
                                   ext_group_by_item_,
                                   ext_voucher_diff_,
                                   group_by_value_,
                                   voucher_type_,
                                   voucher_date_,
                                   acc_year_,
                                   acc_period_,
                                   user_,
                                   old_trans_rec_.user_group);

                  Ext_Transactions_API.Update_Transaction(old_trans_rec_.company,
                                                          old_trans_rec_.load_id,
                                                          group_by_value_,
                                                          ext_group_by_item_,
                                                          'Checked');
               END IF;
            END IF;
            error_ := FALSE;
            Validate_Voucher_Data__(err_msg_,
                                    acc_year_,
                                    voucher_date_,
                                    acc_period_,
                                    voucher_type_,
                                    ext_voucher_date_,
                                    ext_vouch_extern_,
                                    load_date_,
                                    user_,
                                    new_trans_rec_.user_group,
                                    new_trans_rec_);
            IF (err_msg_ IS NULL) AND (stat_acc_ = 'FALSE') THEN
               --amount_ := nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount) + nvl(new_trans_rec_.tax_amount,0);
               -- Added IF condition to check tax type CALCTAX. 
               -- tax_amount is calculated for calvat in external files, but not depend on gross and net.
               IF (tax_type_ NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
                  IF (def_amount_method_ = 'NET') THEN
                     amount_ := nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount) + nvl(new_trans_rec_.tax_amount,0);
                  ELSE
                     amount_ := nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount);
                  END IF;
               ELSE
                  amount_ := nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount);
               END IF;
               IF (NVL(new_trans_rec_.third_currency_debit_amount,0) != 0 OR nvl(new_trans_rec_.third_currency_credit_amount,0) != 0) THEN
                  IF (tax_type_ NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN                   
                     IF (def_amount_method_ = 'NET') THEN           
                        third_curr_amount_ := nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount) + nvl(new_trans_rec_.third_currency_tax_amount,0);              
                     ELSE            
                        third_curr_amount_ := nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount);
                     END IF;
                  ELSE
                     third_curr_amount_ := nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount);   
                  END IF; 
               END IF;
            END IF;
         END IF;
      ELSIF (error_ = FALSE ) AND (old_trans_rec_.load_group_item = new_trans_rec_.load_group_item) AND (stat_acc_ = 'FALSE') THEN
         --amount_ := amount_ + nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount) + nvl(new_trans_rec_.tax_amount,0);
         -- Added IF condition to check tax type CALCTAX. 
         -- tax_amount is calculated for calvat in external files, but not depend on gross and net.
         IF (tax_type_ NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
            IF (def_amount_method_ = 'NET') THEN
               amount_ := amount_ + nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount) + nvl(new_trans_rec_.tax_amount,0);
            ELSE
               amount_ := amount_ + nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount);
            END IF;
         ELSE
            amount_ := amount_ + nvl(new_trans_rec_.debet_amount,-new_trans_rec_.credit_amount);
         END IF;
         IF (NVL(new_trans_rec_.third_currency_debit_amount,0) != 0 OR nvl(new_trans_rec_.third_currency_credit_amount,0) != 0) THEN
            IF (tax_type_ NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
               IF (def_amount_method_ = 'NET') THEN
                  third_curr_amount_ := third_curr_amount_ + nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount) + nvl(new_trans_rec_.third_currency_tax_amount,0);
               ELSE
                  third_curr_amount_ := third_curr_amount_ + nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount);
               END IF;
            ELSE
               third_curr_amount_ := third_curr_amount_ + nvl(new_trans_rec_.third_currency_debit_amount,-new_trans_rec_.third_currency_credit_amount);
            END IF;
         END IF;
      END IF;
      IF (err_msg_ IS NOT NULL) THEN
         -- update the error message in the transaction table for the whole group
         group_by_value_ := new_trans_rec_.load_group_item;
         Ext_Transactions_API.Update_Load_Error(new_trans_rec_.company,
                                                new_trans_rec_.load_id,
                                                group_by_value_,
                                                ext_group_by_item_,
                                                err_msg_);
         error_ := TRUE;
      END IF;
      -- FA Add Investment Validations
      $IF Component_Fixass_SYS.INSTALLED $THEN 
         IF (fa_code_part_ IS NOT NULL) THEN
            is_acqusition_acc_ := Acquisition_Account_API.Is_Acquisition_Account(new_trans_rec_.company,  new_trans_rec_.codestring_rec.code_a);
            IF (is_acqusition_acc_) THEN
               IF (fa_code_part_ = 'B') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_b;
               ELSIF (fa_code_part_ = 'C') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_c;
               ELSIF (fa_code_part_ = 'D') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_d;
               ELSIF (fa_code_part_ = 'E') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_e;
               ELSIF (fa_code_part_ = 'F') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_f;
               ELSIF (fa_code_part_ = 'G') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_g;
               ELSIF (fa_code_part_ = 'H') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_h;
               ELSIF (fa_code_part_ = 'I') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_i;
               ELSIF (fa_code_part_ = 'J') THEN
                  object_id_ := new_trans_rec_.codestring_rec.code_j;
               END IF;
               IF (object_id_ IS NOT NULL) THEN	
                  IF (new_trans_rec_.event_date IS NULL) THEN 
                     new_trans_rec_.event_date := new_trans_rec_.transaction_date; 
                     update_ := 'TRUE';
                  END IF; 
                  IF (new_trans_rec_.retroactive_date IS NULL) THEN 
                     new_trans_rec_.retroactive_date := new_trans_rec_.event_date; 
                     update_ := 'TRUE';
                  END IF;
                  IF (new_trans_rec_.transaction_reason IS NULL) THEN 
                     new_trans_rec_.transaction_reason := Fa_Object_API.Get_Acquisition_Reason(company_, object_id_); 
                     update_ := 'TRUE';
                  END IF;      
               END IF;   
               -- FA Event Date external
               @ApproveDynamicStatement(2012-08-30,sacalk)
               OPEN  dynamic_cursor_event_date_ FOR stmt_check_event_date_ USING company_, load_id_;
               LOOP
                  FETCH dynamic_cursor_event_date_ INTO rec_company_, rec_load_id_, rec_load_group_item_, rec_object_id_, rec_records_;
                  IF (rec_records_ > 1) THEN
                     err_msg_ :=  'EVENTDATE: All the event dates for object :P1 should be the same within each voucher.';
                     BEGIN
                        Error_SYS.Record_General('ExtCheck', err_msg_, rec_object_id_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           err_msg_ := SQLERRM;
                     END;
                     Ext_Transactions_API.Update_Load_Error (company_,
                                                             load_id_,
                                                             group_by_value_,
                                                             ext_group_by_item_,
                                                             err_msg_);
                  END IF;
                  EXIT WHEN dynamic_cursor_event_date_%NOTFOUND;
               END LOOP; 
               rec_company_                 := '';
               rec_load_id_                 := 0;
               rec_load_group_item_         := '';
               rec_object_id_               := '';
               rec_records_                 := 0;                
               CLOSE dynamic_cursor_event_date_;

               -- FA Retroactive Date external
               @ApproveDynamicStatement(2012-08-30,sacalk)
               OPEN dynamic_cursor_retro_date_ FOR stmt_check_retro_date_ USING company_, load_id_;
               LOOP
                  FETCH dynamic_cursor_retro_date_ INTO rec_company_, rec_load_id_, rec_load_group_item_, rec_object_id_, rec_records_;
                  IF (rec_records_ > 1) THEN
                     err_msg_ := 'RETRODATE: All the retroactive dates for object :P1 should be the same within each voucher.' ;
                     BEGIN
                        Error_SYS.Record_General('ExtCheck', err_msg_, rec_object_id_);
                     EXCEPTION
                        WHEN OTHERS THEN
                           err_msg_ := SQLERRM;
                     END;
                     Ext_Transactions_API.Update_Load_Error (company_,
                                                             load_id_,
                                                             group_by_value_,
                                                             ext_group_by_item_,
                                                             err_msg_);
                  END IF;
                  EXIT WHEN dynamic_cursor_retro_date_%NOTFOUND ;
               END LOOP; 
               rec_company_                 := '';
               rec_load_id_                 := 0;
               rec_load_group_item_         := '';
               rec_object_id_               := '';
               rec_records_                 := 0;                
               CLOSE  dynamic_cursor_retro_date_;

               -- FA Transaction Reason external
               @ApproveDynamicStatement(2012-08-30,sacalk)
               OPEN  dynamic_cursor_trans_reason_ FOR stmt_check_trans_reason_ USING company_, load_id_;
               LOOP
                  FETCH dynamic_cursor_trans_reason_ INTO  rec_company_, rec_load_id_, rec_load_group_item_, rec_object_id_, rec_records_;
                  IF (rec_records_ > 1) THEN
                     err_msg_ := 'TRANSREASON: All the transaction reasons for object :P1 should be the same within each voucher.' ;
                     BEGIN
                        Error_SYS.Record_General('ExtCheck', err_msg_, rec_object_id_);
                        EXCEPTION
                           WHEN OTHERS THEN
                              err_msg_ := SQLERRM;
                     END;
                     Ext_Transactions_API.Update_Load_Error (company_,
                                                             load_id_,
                                                             group_by_value_,
                                                             ext_group_by_item_,
                                                             err_msg_);
                  END IF;
                  EXIT WHEN dynamic_cursor_trans_reason_%NOTFOUND;
               END LOOP;
               rec_company_                 := '';
               rec_load_id_                 := 0;
               rec_load_group_item_         := '';
               rec_object_id_               := '';
               rec_records_                 := 0;                
               CLOSE dynamic_cursor_trans_reason_;                       

               IF (update_ = 'TRUE') THEN 
                  UPDATE EXT_TRANSACTIONS_TAB 
                     SET event_date            = new_trans_rec_.event_date, 
                         retroactive_date      = new_trans_rec_.retroactive_date, 
                         transaction_reason    = new_trans_rec_.transaction_reason
                  WHERE company    = new_trans_rec_.company
                  AND load_id    = new_trans_rec_.load_id
                  AND record_no  = new_trans_rec_.record_no;
               END IF;
            END IF;
         END IF;
      $END
      old_trans_rec_ := new_trans_rec_;
      err_msg_ := '';
   END LOOP;
   CLOSE getrec;

   IF (old_trans_rec_.load_group_item IS NOT NULL) THEN
      IF (num_user_group_ >= 1) THEN
         err_msg_ := 'SAME_USERG: Transaction lines per voucher should have the same user group';
         BEGIN
            Error_SYS.Record_General('ExtCheck', 'SAME_USERG: Transaction lines per voucher should have the same user group');
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
         END;
         Ext_Transactions_API.Update_Load_Error(old_trans_rec_.company,
                                                old_trans_rec_.load_id,
                                                old_trans_rec_.load_group_item,
                                                ext_group_by_item_,
                                                err_msg_);
         error_ := TRUE;                                           
      END IF;
      IF (old_trans_rec_.load_group_item IS NOT NULL) THEN
         temp_user_group_ := NULL;
         num_user_group_ := 0;
      END IF;
   END IF;
   
   -- processing for the last voucher
   IF (error_ = FALSE) AND (old_trans_rec_.load_group_item IS NOT NULL) THEN
      group_by_value_ := old_trans_rec_.load_group_item;
      IF (ext_voucher_diff_ = 'N') AND (amount_ != 0 OR third_curr_amount_ != 0) THEN
         third_curr_null_:= Is_Par_Amount_Null(load_file_id_, ext_group_by_item_, group_by_value_);
         IF (amount_ = 0 AND third_curr_null_= 'FALSE') THEN
            Balance_Parallel_Diff___ (company_, load_id_, third_curr_amount_, group_by_value_);
            
            Create_Voucher__(voucher_no_seq_,
                             old_trans_rec_.company,
                             old_trans_rec_.load_id,
                             ext_group_by_item_,
                             ext_voucher_diff_,
                             group_by_value_,
                             voucher_type_,
                             voucher_date_,
                             acc_year_,
                             acc_period_,
                             user_,
                             old_trans_rec_.user_group);

            Ext_Transactions_API.Update_Transaction(old_trans_rec_.company,
                                                    old_trans_rec_.load_id,
                                                    group_by_value_,
                                                    ext_group_by_item_,
                                                    'Checked');
         ELSE 
            IF (amount_ != 0) THEN
               err_msg_ := 'VOU_NOT_BAL: Voucher :P1 is not balanced in accounting currency';
            ELSIF (third_curr_amount_ != 0) THEN
               err_msg_ := 'VOU_NOT_BAL_PAR: Voucher :P1 is not balanced in parallel currency';
            END IF;   
            BEGIN
               Error_SYS.Record_General('ExtCheck', err_msg_, old_trans_rec_.load_group_item);
            EXCEPTION
               WHEN OTHERS THEN
                  err_msg_ := SQLERRM;
            END;
            Ext_Transactions_API.Update_Load_Error ( old_trans_rec_.company,
                                                     old_trans_rec_.load_id,
                                                     group_by_value_,
                                                     ext_group_by_item_,
                                                     err_msg_ );
         END IF;
      ELSE
         Create_Voucher__(voucher_no_seq_,
                          old_trans_rec_.company,
                          old_trans_rec_.load_id,
                          ext_group_by_item_,
                          ext_voucher_diff_,
                          group_by_value_,
                          voucher_type_,
                          voucher_date_,
                          acc_year_,
                          acc_period_,
                          user_,
                          old_trans_rec_.user_group);

         Ext_Transactions_API.Update_Transaction(old_trans_rec_.company,
                                                 old_trans_rec_.load_id,
                                                 group_by_value_,
                                                 ext_group_by_item_,
                                                 'Checked');
      END IF;
   END IF;
END Process_By_Load_Group_Item___;


PROCEDURE Check_Project___ (
   err_msg_      OUT VARCHAR2,
   rec_          IN  Ext_Transactions_API.ExtTransRec,
   voucher_date_ IN  DATE )
IS
   project_cost_element_   VARCHAR2(100);
   project_origin_         VARCHAR2(30);   
   dummy_codepart_value_   VARCHAR2(20);   
   state_                  VARCHAR2(20);
   dummy_project_id_       VARCHAR2(20);
   function_group_         VARCHAR2(10);
   is_project_code_part_   VARCHAR2(1);   
   postable_               NUMBER;
   exclude_proj_followup_  accounting_code_part_value_tab.exclude_proj_followup%TYPE;
BEGIN
   is_project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(rec_.company, 'PRACC');
   IF (is_project_code_part_ = 'B') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_b;
   ELSIF (is_project_code_part_ = 'C') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_c;
   ELSIF (is_project_code_part_ = 'D') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_d;
   ELSIF (is_project_code_part_ = 'E') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_e;
   ELSIF (is_project_code_part_ = 'F') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_f;
   ELSIF (is_project_code_part_ = 'G') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_g;
   ELSIF (is_project_code_part_ = 'H') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_h;
   ELSIF (is_project_code_part_ = 'I') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_i;
   ELSIF (is_project_code_part_ = 'J') THEN
      dummy_codepart_value_ := rec_.codestring_rec.code_j;
   END IF;

   dummy_project_id_ := dummy_codepart_value_;

   IF NOT (rec_.project_activity_id = -123456 ) THEN
      IF (rec_.project_activity_id IS NOT NULL AND dummy_codepart_value_ IS NULL) THEN
         Error_SYS.Appl_General(lu_name_, 'NOPROJSPECIFIED: A Project must be specified in order for Activity Sequence No to have a value');
      END IF;
   END IF;
   
   IF (dummy_codepart_value_ IS NOT NULL) THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         project_origin_:= Accounting_Project_API.Get_Project_Origin_Db(rec_.company , dummy_codepart_value_);
      $ELSE
         project_origin_ := NULL;
      $END
   END IF;
   
   function_group_ := Voucher_Type_Detail_API.Get_Function_Group(rec_.company, rec_.voucher_type);
   exclude_proj_followup_ := Account_API.Get_Exclude_Proj_Followup(rec_.company, rec_.codestring_rec.code_a);
   IF (project_origin_ = 'FINPROJECT') AND (rec_.project_activity_id IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_, 'FINPROJACTINOTALLOWED: Project :P1 is defined with project origin Financial Project and it is not allowed to post to a project activity.', dummy_codepart_value_);
   ELSIF (project_origin_ = 'PROJECT') AND (rec_.project_activity_id IS NULL) THEN
      IF (function_group_ != 'Z') THEN
         IF NVL(exclude_proj_followup_, 'FALSE') = 'FALSE' THEN
            Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Activity Sequence No must have a value for Project :P1', dummy_codepart_value_);
         END IF;
      END IF;
   ELSIF (project_origin_ = 'PROJECT') AND (rec_.project_activity_id IS NOT NULL) AND (rec_.project_activity_id > 0 ) AND
      NVL(exclude_proj_followup_, 'FALSE') = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', rec_.codestring_rec.code_a);
   ELSIF (project_origin_ = 'JOB') THEN
      IF (function_group_ NOT IN ('M', 'K', 'Q','A','P','R','Z','D')) THEN
         IF (rec_.project_activity_id <> 0) THEN
            Error_SYS.Record_General(lu_name_, 'ACTSEQNOMUSTBEZERO: Activity Sequence No must be zero for Project :P1', dummy_codepart_value_);
         END IF;
      END IF;
   END IF;
   
   IF (project_origin_ = 'PROJECT') THEN      
      IF (NVL(exclude_proj_followup_, 'FALSE') = 'FALSE') THEN                     
         project_cost_element_ := Cost_Element_To_Account_API.Get_Project_Follow_Up_Element(rec_.company, rec_.codestring_rec.code_a, rec_.codestring_rec.code_b, rec_.codestring_rec.code_c, 
                                                                                            rec_.codestring_rec.code_d, rec_.codestring_rec.code_e, rec_.codestring_rec.code_f, rec_.codestring_rec.code_g, 
                                                                                            rec_.codestring_rec.code_h, rec_.codestring_rec.code_i, rec_.codestring_rec.code_j, voucher_date_, 'TRUE');               
      END IF;      
   END IF;
   IF (NVL(rec_.project_activity_id,0) <> 0) THEN
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF (project_origin_ = 'PROJECT') THEN
            IF function_group_ != 'P' THEN
               IF function_group_ IN ('I', 'J', 'T', 'V', 'TF') THEN
                  postable_ := Activity_API.Is_Activity_Valid(dummy_codepart_value_, rec_.project_activity_id);
               ELSE
                  postable_ := Activity_API.Is_Activity_Postable(dummy_codepart_value_, rec_.project_activity_id);
               END IF;               
               IF (nvl(postable_, 1) = 0) THEN
                  Error_SYS.Record_General(lu_name_,'ACTIDNOTPOSTABLE: In Project :P1 , Activity Sequence No :P2  is planned, closed or cancelled. This operation is not allowed on such activities.', dummy_codepart_value_, rec_.project_activity_id);
               END IF;
            ELSE
               state_ := Project_API.Get_Objstate(dummy_codepart_value_);
               IF (state_!= 'Completed' AND state_ IS NOT NULL) THEN
                  Error_SYS.Record_General(lu_name_, 'PROJNOTCOMPLETED: Project :P1 must be completed', dummy_project_id_);
               END IF;
            END IF;
         END IF;

         IF (function_group_ != 'P' AND project_origin_ IN ('FINPROJECT','JOB')) THEN
            $IF Component_Genled_SYS.INSTALLED $THEN
               state_ := Accounting_Project_API.Get_Project_Db_Status(rec_.company,dummy_codepart_value_);
               IF (state_ = 'C') THEN
                  Error_SYS.Record_General(lu_name_,'COMPLETEDFINPROJ: This operation is not allowed on Completed Project :P1.', dummy_codepart_value_);
               END IF;
            $ELSE
               NULL;
            $END
         END IF;
      $ELSE
         NULL;
      $END
   END IF;  
EXCEPTION 
   WHEN OTHERS THEN
      err_msg_ := sqlerrm;
      External_File_Utility_API.Error_Text_Only(err_msg_);
END Check_Project___;


PROCEDURE Check_Object___(
   rec_     IN  Ext_Transactions_API.ExtTransRec,
   err_msg_ OUT VARCHAR2)
IS
   object_id_             VARCHAR2(20);
   fa_code_part_          VARCHAR2(10);   
   function_group_        VARCHAR2(10);   
   is_acq_account_        BOOLEAN;
   
   fa_codestring_rec_     Accounting_codestr_API.CodestrRec;
   $IF Component_Fixass_SYS.INSTALLED $THEN
      object_acq_rec_     Fa_Object_API.Public_Object_Acq_Rec;
   $END
   
   no_action              EXCEPTION;
BEGIN
   $IF Component_Fixass_SYS.INSTALLED $THEN  
      IF (rec_.codestring_rec.code_a IS NULL) THEN
         RAISE no_action;
      END IF;
      function_group_ := Voucher_Type_Detail_API.Get_Function_Group(rec_.company,
                                                                    rec_.voucher_type);
      IF (function_group_ IN ('A', 'Q', 'YE')) THEN
         RAISE no_action;
      END IF;
      fa_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(rec_.company,
                                                                       'FAACC');
      is_acq_account_ := Acquisition_Account_API.Is_Acquisition_Account(rec_.company,
                                                                        rec_.codestring_rec.code_a);
      IF (is_acq_account_) THEN         
         fa_codestring_rec_.code_a := rec_.codestring_rec.code_a;
         fa_codestring_rec_.code_b := rec_.codestring_rec.code_b;
         fa_codestring_rec_.code_c := rec_.codestring_rec.code_c;
         fa_codestring_rec_.code_d := rec_.codestring_rec.code_d;
         fa_codestring_rec_.code_e := rec_.codestring_rec.code_e;
         fa_codestring_rec_.code_f := rec_.codestring_rec.code_f;
         fa_codestring_rec_.code_g := rec_.codestring_rec.code_g;
         fa_codestring_rec_.code_h := rec_.codestring_rec.code_h;
         fa_codestring_rec_.code_i := rec_.codestring_rec.code_i;
         fa_codestring_rec_.code_j := rec_.codestring_rec.code_j;
         IF (fa_code_part_ = 'B') THEN
            object_id_ := rec_.codestring_rec.code_b;
         ELSIF (fa_code_part_ = 'C') THEN
            object_id_ := rec_.codestring_rec.code_c;
         ELSIF (fa_code_part_ = 'D') THEN
            object_id_ := rec_.codestring_rec.code_d;
         ELSIF (fa_code_part_ = 'E') THEN
            object_id_ := rec_.codestring_rec.code_e;
         ELSIF (fa_code_part_ = 'F') THEN
            object_id_ := rec_.codestring_rec.code_f;
         ELSIF (fa_code_part_ = 'G') THEN
            object_id_ := rec_.codestring_rec.code_g;
         ELSIF (fa_code_part_ = 'H') THEN
            object_id_ := rec_.codestring_rec.code_h;
         ELSIF (fa_code_part_ = 'I') THEN
            object_id_ := rec_.codestring_rec.code_i;
         ELSIF (fa_code_part_ = 'J') THEN
            object_id_ := rec_.codestring_rec.code_j;
         END IF;
         --  Check Fa vouchers for the current object in the hold table
         IF (object_id_ IS NOT NULL) THEN
            Voucher_Row_API.Check_Code_Str_Fa(rec_.company,
                                              object_id_,
                                              fa_code_part_,
                                              fa_codestring_rec_);
         END IF;
         object_acq_rec_.company         := rec_.company;
         object_acq_rec_.object_id       := object_id_;
         object_acq_rec_.account         := rec_.codestring_rec.code_a;
         object_acq_rec_.code_b          := rec_.codestring_rec.code_b;
         object_acq_rec_.code_c          := rec_.codestring_rec.code_c;
         object_acq_rec_.code_d          := rec_.codestring_rec.code_d;
         object_acq_rec_.code_e          := rec_.codestring_rec.code_e;
         object_acq_rec_.code_f          := rec_.codestring_rec.code_f;
         object_acq_rec_.code_g          := rec_.codestring_rec.code_g;
         object_acq_rec_.code_h          := rec_.codestring_rec.code_h;
         object_acq_rec_.code_i          := rec_.codestring_rec.code_i;
         object_acq_rec_.code_j          := rec_.codestring_rec.code_j;
         object_acq_rec_.voucher_type    := rec_.voucher_type;
         object_acq_rec_.voucher_number  := rec_.voucher_no;
         object_acq_rec_.accounting_year := rec_.accounting_year;
         object_acq_rec_.function_group  := function_group_;
         object_acq_rec_.fa_code_part    := fa_code_part_;
         object_acq_rec_.message_flag    := 'FALSE';
         Fa_Object_API.Check_Acquisition (object_acq_rec_); 
      END IF;
   $ELSE
      NULL;
   $END
EXCEPTION
   WHEN no_action THEN
      NULL;
   WHEN OTHERS THEN
      err_msg_ := sqlerrm;      
END Check_Object___;


PROCEDURE Prepare_Tax_Transaction___ (
   voucher_no_seq_               IN  OUT NUMBER,
   row_no_                       IN  OUT NUMBER,
   accounting_year_              IN  NUMBER,
   voucher_type_                 IN  VARCHAR2,
   voucher_date_                 IN  DATE,
   transaction_rec_              IN  OUT  Ext_Transactions_API.ExtTransRec,
   debit_amount_                 IN  OUT NUMBER,
   credit_amount_                IN  OUT NUMBER,
   currency_debit_amount_        IN  OUT NUMBER,
   currency_credit_amount_       IN  OUT NUMBER,
   third_currency_debit_amount_  IN  OUT NUMBER,
   third_currency_credit_amount_ IN  OUT NUMBER )
IS
   control_value_attr_        VARCHAR2(2000);   
   def_amount_method_         VARCHAR2(5) := Company_Finance_API.Get_Def_Amount_Method_Db(transaction_rec_.company);
   codestring_rec_            Accounting_Codestr_API.CodestrRec;
   tax_rec_                   Statutory_Fee_API.Public_Rec;   
BEGIN
   IF (transaction_rec_.optional_code IS NOT NULL AND transaction_rec_.tax_amount IS NOT NULL) THEN
      tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(transaction_rec_.company, transaction_rec_.optional_code, transaction_rec_.transaction_date, 'TRUE', 'FALSE', 'FETCH_AND_VALIDATE');
      transaction_rec_.third_currency_debit_amount  := NULL;
      transaction_rec_.third_currency_credit_amount := NULL;
      transaction_rec_.quantity                     := NULL;
      transaction_rec_.process_code                 := NULL;
      transaction_rec_.project_activity_id          := NULL;
      transaction_rec_.tax_transaction              := 'TRUE';

      -- Added a condition to check whether transaction_rec_.tax_amount is zero and
      -- assigned null to amounts(credit/debit/curr credit/curr debit).
      IF NVL(transaction_rec_.tax_amount,0) > 0 THEN
         transaction_rec_.debet_amount := transaction_rec_.tax_amount;
         transaction_rec_.credit_amount := NULL;
         IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
            debit_amount_  := debit_amount_ + transaction_rec_.debet_amount;
            IF (def_amount_method_ = 'GROSS') THEN
                debit_amount_ := debit_amount_ - transaction_rec_.debet_amount;
            END IF;
         END IF;
         transaction_rec_.tax_amount := NULL;
      ELSIF NVL(transaction_rec_.tax_amount,0) < 0 THEN
         transaction_rec_.credit_amount := -transaction_rec_.tax_amount;
         transaction_rec_.debet_amount := NULL;
         IF (tax_rec_.fee_type NOT IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
            credit_amount_ := credit_amount_ + transaction_rec_.credit_amount;
            IF (def_amount_method_ = 'GROSS') THEN
               credit_amount_ := credit_amount_ - transaction_rec_.credit_amount;
            END IF;
         END IF;
         transaction_rec_.tax_amount := NULL;
      ELSIF NVL(transaction_rec_.tax_amount,0) = 0 THEN
         transaction_rec_.debet_amount   := 0;
         transaction_rec_.credit_amount  := 0;
         transaction_rec_.amount         := 0;
         transaction_rec_.tax_amount     := NULL;
      END IF;

      -- Added a condition to check whether transaction_rec_.currency_tax_amount is zero and
      -- assigned null to amounts(credit/debit/curr credit/curr debit).
      IF NVL(transaction_rec_.currency_tax_amount,0) > 0 THEN
         transaction_rec_.currency_debet_amount := transaction_rec_.currency_tax_amount;
         transaction_rec_.currency_credit_amount := NULL;
         currency_debit_amount_ := currency_debit_amount_ + transaction_rec_.currency_debet_amount;
         IF (def_amount_method_ = 'GROSS') THEN
            currency_debit_amount_ := currency_debit_amount_ - transaction_rec_.currency_debet_amount;
         END IF;
         transaction_rec_.currency_tax_amount := NULL;
      ELSIF NVL(transaction_rec_.currency_tax_amount,0) < 0 THEN
         transaction_rec_.currency_credit_amount := -transaction_rec_.currency_tax_amount;
         transaction_rec_.currency_debet_amount := NULL;
         currency_credit_amount_ := currency_credit_amount_ + transaction_rec_.currency_credit_amount;
         IF (def_amount_method_ = 'GROSS') THEN
            currency_credit_amount_ := currency_credit_amount_ - transaction_rec_.currency_credit_amount;
         END IF;
         transaction_rec_.currency_tax_amount := NULL;
      ELSIF NVL(transaction_rec_.currency_tax_amount,0) = 0 THEN
         transaction_rec_.currency_debet_amount  := 0;
         transaction_rec_.currency_credit_amount := 0;
         transaction_rec_.currency_amount        := 0;
         transaction_rec_.currency_tax_amount := NULL;
      END IF;

-- Added a condition to check whether transaction_rec_.third_currency_tax_amount is zero and
-- assigned null to amounts(credit/debit/curr credit/curr debit).
      IF (NVL(transaction_rec_.third_currency_tax_amount,0) > 0) THEN
         transaction_rec_.third_currency_debit_amount := transaction_rec_.third_currency_tax_amount;
         transaction_rec_.third_currency_credit_amount := NULL;
         third_currency_debit_amount_ := third_currency_debit_amount_ + transaction_rec_.third_currency_debit_amount;
         IF (def_amount_method_ = 'GROSS') THEN
            third_currency_debit_amount_ := third_currency_debit_amount_ - transaction_rec_.third_currency_debit_amount;
         END IF;
         transaction_rec_.third_currency_tax_amount := NULL;
      ELSIF (NVL(transaction_rec_.third_currency_tax_amount,0) < 0) THEN
         transaction_rec_.third_currency_credit_amount := -transaction_rec_.third_currency_tax_amount;
         transaction_rec_.third_currency_debit_amount := NULL;
         third_currency_credit_amount_ := third_currency_credit_amount_ + transaction_rec_.third_currency_credit_amount;
         IF (def_amount_method_ = 'GROSS') THEN
            third_currency_credit_amount_ := third_currency_credit_amount_ - transaction_rec_.third_currency_credit_amount;
         END IF;
         transaction_rec_.third_currency_tax_amount := NULL;   
      ELSIF (NVL(transaction_rec_.third_currency_tax_amount,0) = 0) THEN
         transaction_rec_.third_currency_debit_amount  := 0;
         transaction_rec_.third_currency_credit_amount := 0;
         transaction_rec_.third_currency_amount        := 0;
         transaction_rec_.third_currency_tax_amount := NULL;    
      END IF;

      IF (tax_rec_.fee_type != Fee_Type_API.DB_NO_TAX) THEN
         IF (tax_rec_.fee_type IN (Fee_Type_API.DB_TAX)) THEN
            IF (transaction_rec_.tax_direction IN ('TAXRECEIVED')) THEN
               Client_SYS.Clear_Attr(control_value_attr_);
               Client_SYS.Add_To_Attr('AC1', '*', control_value_attr_);
               Client_SYS.Add_To_Attr('AC7', transaction_rec_.optional_code, control_value_attr_);
               Client_SYS.Add_To_Attr('AC10', '*', control_value_attr_);

               transaction_rec_.trans_code := 'AP1';
               Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                              transaction_rec_.company,
                                              transaction_rec_.trans_code,
                                              voucher_date_,
                                              control_value_attr_ );
               Add_Preaccounting___(codestring_rec_, transaction_rec_.codestring_rec);                                            

               transaction_rec_.codestring_rec.code_a := codestring_rec_.code_a;
               transaction_rec_.codestring_rec.code_b := codestring_rec_.code_b;
               transaction_rec_.codestring_rec.code_c := codestring_rec_.code_c;
               transaction_rec_.codestring_rec.code_d := codestring_rec_.code_d;
               transaction_rec_.codestring_rec.code_e := codestring_rec_.code_e;
               transaction_rec_.codestring_rec.code_f := codestring_rec_.code_f;
               transaction_rec_.codestring_rec.code_g := codestring_rec_.code_g;
               transaction_rec_.codestring_rec.code_h := codestring_rec_.code_h;
               transaction_rec_.codestring_rec.code_i := codestring_rec_.code_i;
               transaction_rec_.codestring_rec.code_j := codestring_rec_.code_j;

               -- To create Tax Transaction
               Create_Voucher_Row__(voucher_no_seq_,
                                    row_no_,
                                    accounting_year_,
                                    voucher_type_,
                                    transaction_rec_,
                                    TRUE);

            ELSIF (transaction_rec_.tax_direction IN ('TAXDISBURSED')) THEN
               Client_SYS.Clear_Attr(control_value_attr_);
               Client_SYS.Add_To_Attr('AC1', '*', control_value_attr_);
               Client_SYS.Add_To_Attr('AC7', transaction_rec_.optional_code, control_value_attr_);
               Client_SYS.Add_To_Attr('AC10', '*', control_value_attr_);

               transaction_rec_.trans_code := 'AP2';
               Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                              transaction_rec_.company,
                                              transaction_rec_.trans_code,
                                              voucher_date_,
                                              control_value_attr_ );
                                            
               Add_Preaccounting___(codestring_rec_, transaction_rec_.codestring_rec);                                            

               transaction_rec_.codestring_rec.code_a := codestring_rec_.code_a;
               transaction_rec_.codestring_rec.code_b := codestring_rec_.code_b;
               transaction_rec_.codestring_rec.code_c := codestring_rec_.code_c;
               transaction_rec_.codestring_rec.code_d := codestring_rec_.code_d;
               transaction_rec_.codestring_rec.code_e := codestring_rec_.code_e;
               transaction_rec_.codestring_rec.code_f := codestring_rec_.code_f;
               transaction_rec_.codestring_rec.code_g := codestring_rec_.code_g;
               transaction_rec_.codestring_rec.code_h := codestring_rec_.code_h;
               transaction_rec_.codestring_rec.code_i := codestring_rec_.code_i;
               transaction_rec_.codestring_rec.code_j := codestring_rec_.code_j;

               -- To create Tax Transaction
               Create_Voucher_Row__(voucher_no_seq_,
                                    row_no_,
                                    accounting_year_,
                                    voucher_type_,
                                    transaction_rec_,
                                    TRUE );
            END IF;
         ELSIF (tax_rec_.fee_type IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
            IF (transaction_rec_.tax_direction IN ('TAXRECEIVED')) THEN
               -- Calculate the tax amounts for the caluculated tax
               Tax_Handling_Accrul_Util_API.Calculate_Calc_Tax_Amounts(transaction_rec_.currency_tax_amount,
                                                                       transaction_rec_.tax_amount,
                                                                       transaction_rec_.third_currency_tax_amount,
                                                                       transaction_rec_.currency_credit_amount,
                                                                       transaction_rec_.currency_debet_amount,
                                                                       transaction_rec_.credit_amount,
                                                                       transaction_rec_.debet_amount,
                                                                       transaction_rec_.third_currency_credit_amount,
                                                                       transaction_rec_.third_currency_debit_amount,
                                                                       transaction_rec_.company,
                                                                       transaction_rec_.currency_code,
                                                                       transaction_rec_.optional_code,
                                                                       'FALSE',
                                                                       tax_rec_.fee_rate,
                                                                       voucher_date_);                   
                   
               Client_SYS.Clear_Attr(control_value_attr_);
               Client_SYS.Add_To_Attr('AC1', '*', control_value_attr_);
               Client_SYS.Add_To_Attr('AC7', transaction_rec_.optional_code, control_value_attr_);
               Client_SYS.Add_To_Attr('AC10', '*', control_value_attr_);

               transaction_rec_.trans_code := 'AP3';
               Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                              transaction_rec_.company,
                                              transaction_rec_.trans_code,
                                              voucher_date_,
                                              control_value_attr_ );
                                            
               Add_Preaccounting___(codestring_rec_, transaction_rec_.codestring_rec);                                            

               transaction_rec_.codestring_rec.code_a := codestring_rec_.code_a;
               transaction_rec_.codestring_rec.code_b := codestring_rec_.code_b;
               transaction_rec_.codestring_rec.code_c := codestring_rec_.code_c;
               transaction_rec_.codestring_rec.code_d := codestring_rec_.code_d;
               transaction_rec_.codestring_rec.code_e := codestring_rec_.code_e;
               transaction_rec_.codestring_rec.code_f := codestring_rec_.code_f;
               transaction_rec_.codestring_rec.code_g := codestring_rec_.code_g;
               transaction_rec_.codestring_rec.code_h := codestring_rec_.code_h;
               transaction_rec_.codestring_rec.code_i := codestring_rec_.code_i;
               transaction_rec_.codestring_rec.code_j := codestring_rec_.code_j;

               -- To create Tax Transaction
               Create_Voucher_Row__(voucher_no_seq_,
                                    row_no_,
                                    accounting_year_,
                                    voucher_type_,
                                    transaction_rec_,
                                    TRUE );
                                        
               Client_SYS.Clear_Attr(control_value_attr_);
               Client_SYS.Add_To_Attr('AC1', '*', control_value_attr_);
               Client_SYS.Add_To_Attr('AC7', transaction_rec_.optional_code, control_value_attr_);
               Client_SYS.Add_To_Attr('AC10', '*', control_value_attr_);
                   
               transaction_rec_.trans_code := 'AP4';
                  
               Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                              transaction_rec_.company,
                                              transaction_rec_.trans_code,
                                              voucher_date_,
                                              control_value_attr_ );
                   
               Add_Preaccounting___(codestring_rec_, transaction_rec_.codestring_rec);
                                                    
               IF (transaction_rec_.debet_amount IS NOT NULL) THEN
                  transaction_rec_.currency_credit_amount       := transaction_rec_.currency_debet_amount;
                  transaction_rec_.currency_debet_amount        := NULL;
                  transaction_rec_.credit_amount                := transaction_rec_.debet_amount;
                  transaction_rec_.debet_amount                 := NULL;
                  transaction_rec_.third_currency_credit_amount := transaction_rec_.third_currency_debit_amount;
                  transaction_rec_.third_currency_debit_amount  := NULL;
               ELSIF (transaction_rec_.credit_amount IS NOT NULL) THEN
                  transaction_rec_.currency_debet_amount        := transaction_rec_.currency_credit_amount;
                  transaction_rec_.currency_credit_amount       := NULL;
                  transaction_rec_.debet_amount                 := transaction_rec_.credit_amount;
                  transaction_rec_.credit_amount                := NULL;
                  transaction_rec_.third_currency_debit_amount  := transaction_rec_.third_currency_credit_amount;
                  transaction_rec_.third_currency_credit_amount := NULL;
               END IF;

               transaction_rec_.tax_base_amount                  := transaction_rec_.tax_base_amount * -1;
               transaction_rec_.currency_tax_base_amount         := transaction_rec_.currency_tax_base_amount * -1;
               transaction_rec_.third_curr_tax_base_amount       := transaction_rec_.third_curr_tax_base_amount * -1;

               transaction_rec_.tax_direction := 'TAXDISBURSED';

   
               transaction_rec_.codestring_rec.code_a := codestring_rec_.code_a;
               transaction_rec_.codestring_rec.code_b := codestring_rec_.code_b;
               transaction_rec_.codestring_rec.code_c := codestring_rec_.code_c;
               transaction_rec_.codestring_rec.code_d := codestring_rec_.code_d;
               transaction_rec_.codestring_rec.code_e := codestring_rec_.code_e;
               transaction_rec_.codestring_rec.code_f := codestring_rec_.code_f;
               transaction_rec_.codestring_rec.code_g := codestring_rec_.code_g;
               transaction_rec_.codestring_rec.code_h := codestring_rec_.code_h;
               transaction_rec_.codestring_rec.code_i := codestring_rec_.code_i;
               transaction_rec_.codestring_rec.code_j := codestring_rec_.code_j;

               -- To create Tax Transaction
               Create_Voucher_Row__(voucher_no_seq_,
                                    row_no_,
                                    accounting_year_,
                                    voucher_type_,
                                    transaction_rec_,
                                    TRUE );

            ELSIF (transaction_rec_.tax_direction IN ('TAXDISBURSED')) THEN
               Client_SYS.Clear_Attr(control_value_attr_);
               Client_SYS.Add_To_Attr( 'AC1', '*', control_value_attr_);
               Client_SYS.Add_To_Attr( 'AC7', transaction_rec_.optional_code, control_value_attr_);
               Client_SYS.Add_To_Attr( 'AC10', '*', control_value_attr_);
                   
               transaction_rec_.currency_tax_amount := 0;
               transaction_rec_.tax_amount          := 0;
                   
               IF (transaction_rec_.debet_amount IS NOT NULL) THEN
                  transaction_rec_.currency_credit_amount       := 0;
                  transaction_rec_.currency_debet_amount        := NULL;
                  transaction_rec_.credit_amount                := 0;
                  transaction_rec_.debet_amount                 := NULL;
                  transaction_rec_.third_currency_credit_amount := 0;
                  transaction_rec_.third_currency_debit_amount  := NULL;
               ELSIF (transaction_rec_.credit_amount IS NOT NULL) THEN
                  transaction_rec_.currency_debet_amount        := 0;
                  transaction_rec_.currency_credit_amount       := NULL;
                  transaction_rec_.debet_amount                 := 0;
                  transaction_rec_.credit_amount                := NULL;
                  transaction_rec_.third_currency_debit_amount  := 0;
                  transaction_rec_.third_currency_credit_amount := NULL;
               END IF; 
               
               -- Changed tarns_code as AP2 since External Vouchers should be indentical  
               -- to Manual vouchers. Previous value is 'AP4'
               transaction_rec_.trans_code := 'AP2';
                   
               Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                              transaction_rec_.company,
                                              transaction_rec_.trans_code,
                                              voucher_date_,
                                              control_value_attr_ );
                                            
               Add_Preaccounting___(codestring_rec_, transaction_rec_.codestring_rec);                                           

               transaction_rec_.codestring_rec.code_a := codestring_rec_.code_a;
               transaction_rec_.codestring_rec.code_b := codestring_rec_.code_b;
               transaction_rec_.codestring_rec.code_c := codestring_rec_.code_c;
               transaction_rec_.codestring_rec.code_d := codestring_rec_.code_d;
               transaction_rec_.codestring_rec.code_e := codestring_rec_.code_e;
               transaction_rec_.codestring_rec.code_f := codestring_rec_.code_f;
               transaction_rec_.codestring_rec.code_g := codestring_rec_.code_g;
               transaction_rec_.codestring_rec.code_h := codestring_rec_.code_h;
               transaction_rec_.codestring_rec.code_i := codestring_rec_.code_i;
               transaction_rec_.codestring_rec.code_j := codestring_rec_.code_j;

               -- To create Tax Transaction
               Create_Voucher_Row__(voucher_no_seq_,
                                    row_no_,
                                    accounting_year_,
                                    voucher_type_,
                                    transaction_rec_,
                                    TRUE );
            END IF;
         END IF;
      END IF;
   END IF;
END Prepare_Tax_Transaction___;


PROCEDURE Check_User_Group___ (
   error_msg_  OUT VARCHAR2,
   user_group_ IN  VARCHAR2 )
IS
BEGIN
   IF (user_group_ IS NULL) THEN
      Error_SYS.Record_General(lu_name_,'NOUSRGRP: User ID not connected to User Group');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      error_msg_ := SQLERRM;
END Check_User_Group___;


PROCEDURE Add_Preaccounting___ (
   codestring_rec_            IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   vourow_codestr_rec_        IN            Accounting_Codestr_API.CodestrRec)
IS
BEGIN   
   IF codestring_rec_.code_b = CHR(0) THEN
      codestring_rec_.code_b := vourow_codestr_rec_.code_b;
   END IF;
   IF codestring_rec_.code_c = CHR(0) THEN
      codestring_rec_.code_c := vourow_codestr_rec_.code_c;
   END IF;
   IF codestring_rec_.code_d = CHR(0) THEN
      codestring_rec_.code_d := vourow_codestr_rec_.code_d;
   END IF;
   IF codestring_rec_.code_e = CHR(0) THEN
      codestring_rec_.code_e := vourow_codestr_rec_.code_e;
   END IF;
   IF codestring_rec_.code_f = CHR(0) THEN
      codestring_rec_.code_f := vourow_codestr_rec_.code_f;
   END IF;
   IF codestring_rec_.code_g = CHR(0) THEN
      codestring_rec_.code_g := vourow_codestr_rec_.code_g;
   END IF;
   IF codestring_rec_.code_h = CHR(0) THEN
      codestring_rec_.code_h := vourow_codestr_rec_.code_h;
   END IF;
   IF codestring_rec_.code_i = CHR(0) THEN
      codestring_rec_.code_i := vourow_codestr_rec_.code_i;
   END IF;
   IF codestring_rec_.code_j = CHR(0) THEN
      codestring_rec_.code_j := vourow_codestr_rec_.code_j;
   END IF;
END Add_Preaccounting___;

-- Balance handling method to balance amounts in the external voucher for parallel currency when creating the voucher. 
--This should be seen as an exception to how voucher are balanced.
PROCEDURE Balance_Parallel_Diff___ (
   company_            IN  VARCHAR2,
   load_id_            IN  NUMBER,
   par_curr_balance_   IN  NUMBER,
   group_by_value_     IN  VARCHAR2)
IS 
   -- Find the row with smallest amount (which is still larger than the diff) and sorted on row_no if amounts are equal. 
   CURSOR get_ext_voucher_row IS
      SELECT NVL(r.third_currency_debit_amount,r.third_currency_credit_amount) par_amount, rowid, company
            debet_amount, credit_amount,
            currency_debet_amount, currency_credit_amount,
            third_currency_debit_amount, third_currency_credit_amount, currency_code
      FROM ext_transactions_tab r
      WHERE company = company_
      AND load_id = load_id_
      AND load_group_item =  group_by_value_
      AND NVL(r.third_currency_debit_amount,r.third_currency_credit_amount) > ABS(par_curr_balance_)
      ORDER BY 1 ASC, record_no ASC;
      
   row_rec_                get_ext_voucher_row%ROWTYPE;
BEGIN   
   IF (par_curr_balance_ != 0) THEN
      OPEN  get_ext_voucher_row;
      FETCH get_ext_voucher_row INTO row_rec_;
      CLOSE get_ext_voucher_row;

      IF (par_curr_balance_ > 0) THEN
         IF (row_rec_.third_currency_debit_amount IS NOT NULL) THEN                  
            row_rec_.third_currency_debit_amount := row_rec_.third_currency_debit_amount - par_curr_balance_;                  
         ELSE
            row_rec_.third_currency_credit_amount := row_rec_.third_currency_credit_amount + par_curr_balance_;                  
         END IF;               
      ELSE
         IF (row_rec_.third_currency_debit_amount IS NOT NULL) THEN                  
            row_rec_.third_currency_debit_amount := row_rec_.third_currency_debit_amount + ABS(par_curr_balance_);                  
         ELSE
            row_rec_.third_currency_credit_amount := row_rec_.third_currency_credit_amount - ABS(par_curr_balance_);                  
         END IF;               
      END IF;

      UPDATE ext_transactions_tab                     
         SET third_currency_debit_amount  = row_rec_.third_currency_debit_amount,
             third_currency_credit_amount = row_rec_.third_currency_credit_amount
       WHERE rowid = row_rec_.rowid;                        
   END IF;  
END Balance_Parallel_Diff___;

   
PROCEDURE Raise_Load_Not_Exist___ (
   load_id_       IN VARCHAR2)
IS 
BEGIN   
   Error_SYS.Record_General(lu_name_, 'EXTLOADNOTEXIST: External load id :P1 does not exist', load_id_);      
END Raise_Load_Not_Exist___;

PROCEDURE Raise_Ext_Int_Par_Not___ (
   company_       IN VARCHAR2,
   load_type_     IN VARCHAR2)
IS 
BEGIN   
   Error_SYS.Record_General(lu_name_, 'EXTPARNOTEXIST: External interface parameters does not exist for company :P1, load type :P2', company_, load_type_);   
END Raise_Ext_Int_Par_Not___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Validate_Voucher_Data__ (
   err_txt_           OUT VARCHAR2,
   accounting_year_   OUT NUMBER,
   voucher_date_      OUT DATE,
   accounting_period_ OUT NUMBER,
   voucher_type_      IN  VARCHAR2,
   ext_voucher_date_  IN  VARCHAR2,
   ext_vouch_extern_  IN  VARCHAR2,
   load_date_         IN  DATE,
   user_              IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   transaction_rec_   IN  Ext_Transactions_API.ExtTransRec )
IS
   error_excep_      EXCEPTION;
   
   err_msg_          VARCHAR2(2000);
   valid_            VARCHAR2(10);
   dummy_            VARCHAR2(10);
   ledger_id_        VARCHAR2(10);
   status_           VARCHAR2(6);
   acc_year_         NUMBER;
   acc_period_       NUMBER;
   vouch_date_       DATE;
BEGIN
   err_msg_ := '';
   -- find the voucher date based on the parameters
   IF (ext_voucher_date_ = '1') THEN -- load date
      vouch_date_ := load_date_;
   ELSIF (ext_voucher_date_ = '2') THEN -- transaction date
      vouch_date_ := transaction_rec_.transaction_date;
   END IF;
   voucher_date_ := vouch_date_;
   -- check if voucher date is correct
   -- fetch the accounting year and period for the voucher date
   Accounting_Period_API.Get_Accounting_Year_Period_Ext( acc_year_,
                                                         acc_period_,
                                                         transaction_rec_.company,
                                                         transaction_rec_.user_group,
                                                         vouch_date_ );
   accounting_year_   := acc_year_;
   accounting_period_ := acc_period_;

   IF (ext_vouch_extern_ = '1') THEN
      IF (transaction_rec_.voucher_no IS NOT NULL) THEN
         -- check for the existence of voucher_no in the hold table
         BEGIN
            Voucher_API.Exist ( transaction_rec_.company,
                                voucher_type_,
                                acc_year_,
                                transaction_rec_.voucher_no );
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
         END;
         IF (err_msg_ IS NULL) THEN
            err_msg_ := 'VOU_NO_EXIST: Voucher number :P1 already exist';
            BEGIN
               Error_SYS.Record_General('ExtCheck', err_msg_, transaction_rec_.voucher_no);
            EXCEPTION
               WHEN OTHERS THEN
                  err_msg_ := SQLERRM;
            END;
            RAISE error_excep_;
         ELSE
            err_msg_ := '';
         END IF;

      END IF;
   END IF;

   -- check for voucher type exists for accounting year and user group is allowed to use voucher type
   BEGIN
      Voucher_Type_User_Group_API.Check_If_Voucher_Type_Valid ( valid_,
                                                                transaction_rec_.company,
                                                                user_group_,
                                                                acc_year_,
                                                                voucher_type_ );
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;

   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;

   ledger_id_ := voucher_type_api.Get_Ledger_Id(transaction_rec_.company,transaction_rec_.voucher_type);
   IF (ledger_id_ = '00' OR ledger_id_= '*') THEN
      -- check if period is open for current user group  
      dummy_ := User_Group_Period_API.Is_Period_Open(transaction_rec_.company,
                                                     acc_year_,
                                                     acc_period_,
                                                     user_group_);
      
      IF (dummy_ = 'FALSE') THEN
         err_msg_ := 'PER_CLO_UGR: Period is closed for user group :P1';
         BEGIN
           Error_SYS.Record_General('ExtCheck', err_msg_, user_group_);
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
         END;
         RAISE error_excep_;
      END IF;
   ELSE
      status_ := User_Group_Period_API.Is_Period_Open_GL_IL(transaction_rec_.company,
                                                            acc_year_,
                                                            acc_period_,
                                                            user_group_,
                                                            ledger_id_);
             
      IF (status_ = 'FALSE') THEN
         err_msg_ := 'PER_CLO_UGR: Period is closed for user group :P1';
         BEGIN
            Error_SYS.Record_General('ExtCheck', err_msg_, user_group_);
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
            END;
         RAISE error_excep_;         
      END IF;
   END IF;    
EXCEPTION
   WHEN error_excep_ THEN
      err_txt_ := err_msg_;
END Validate_Voucher_Data__;


PROCEDURE Validate_Transaction_Data__ (
   err_txt_           OUT VARCHAR2,
   voucher_type_      IN  VARCHAR2,
   ext_vouch_extern_  IN  VARCHAR2,
   ext_group_item_    IN  VARCHAR2,
   ext_voucher_date_  IN  VARCHAR2,
   load_date_         IN  DATE,
   user_              IN  VARCHAR2,
   user_group_        IN  VARCHAR2,
   transaction_rec_   IN  Ext_Transactions_API.ExtTransRec,
   val_code_str_      IN  VARCHAR2,
   use_codestr_compl_ IN  VARCHAR2 )
IS
   err_msg_                        VARCHAR2(2000);
   req_code_str_                   VARCHAR2(2000);
   defined_codestr_                VARCHAR2(2000);
   error_code_part1_               VARCHAR2(100);
   error_code_part2_               VARCHAR2(100);
   description_                    VARCHAR2(100);
   tax_type_                       VARCHAR2(100);   
   req_id_                         VARCHAR2(100);
   account_in_attr_                VARCHAR2(100);   
   mismatch_code_part_             VARCHAR2(50);
   amount_method_                  VARCHAR2(20);
   dummy_                          VARCHAR2(10);
   modify_codestr_cmpl_            VARCHAR2(5);
   mis_match_                      VARCHAR2(5);
   account_is_null_                VARCHAR2(5);
   allowed_accounting_period_      VARCHAR2(1);
   code_part_cmpl_                 VARCHAR2(1);
   account_validation_             VARCHAR2(5) := 'FALSE';
   transaction_date_period_        NUMBER;
   transaction_date_year_          NUMBER; 
   opening_period_                 NUMBER;
   deductible_factor_              NUMBER;
   voucher_date_                   DATE;
   date_until_                     DATE;
   mismatch_acc_curr_amt_          BOOLEAN := FALSE;
   mismatch_third_curr_            BOOLEAN := FALSE;
   company_fin_rec_                Company_Finance_API.Public_Rec;
   acc_currency_                   Currency_Code_Tab.Currency_Code%TYPE;
   third_currency_                 Currency_Code_Tab.Currency_Code%TYPE;     
   code_part_cmpl_value_           accounting_code_part_value_tab.code_part_value%TYPE;
   mismatch_file_codepart_value_   accounting_code_part_value_tab.code_part_value%TYPE;
   mismatch_cmpl_code_part_value_  accounting_code_part_value_tab.code_part_value%TYPE;
   codestr_rec_                    Accounting_Codestr_API.CodestrRec;
   temp_transaction_rec_           Ext_Transactions_API.ExtTransRec;
   transaction_rec_tmp_            Ext_Transactions_API.ExtTransRec;
   tax_rec_                        Statutory_Fee_API.Public_Rec;
   error_excep_                    EXCEPTION;
   use_codestring_compl_           BOOLEAN := FALSE;
   tax_direction_                  VARCHAR2(20); 
   CURSOR check_type_parallel(company_ VARCHAR2,par_cur_type_ VARCHAR2) IS
      SELECT 1
      FROM   CURRENCY_TYPE_TAB
      WHERE  company = company_
      AND    rate_type_category IN ('PROJECT','NORMAL')
      AND    currency_type = par_cur_type_;
BEGIN
   err_msg_ := '';
   -- mandatory information
   IF (ext_vouch_extern_ = '1') AND (transaction_rec_.voucher_no IS NULL) THEN -- voucher no. should exist in transaction
      -- set the error message
      err_msg_ := 'VOU_NO_NULL: Voucher No should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF transaction_rec_.voucher_type IS NULL THEN
      err_msg_ := 'VOU_TYPE_NULL: Voucher Type should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF transaction_rec_.voucher_type != voucher_type_ THEN
      err_msg_ := 'VOU_TYPE_MISS_MATCH: Voucher Type :P1 does not match with the Voucher Type :P2 defined in the Load Type';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_, transaction_rec_.voucher_type, voucher_type_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF (ext_group_item_ = '2') AND (nvl(transaction_rec_.load_group_item,'?') = '?') THEN
      err_msg_ := 'LOAD_GRP_NULL: Load group item should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF ((ext_group_item_ = '3') OR (ext_voucher_date_ = '2')) AND (transaction_rec_.transaction_date IS NULL) THEN
      err_msg_ := 'VOU_DATE_NULL: Voucher date should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF (ext_group_item_ = '4') AND (transaction_rec_.reference_number IS NULL) THEN
      err_msg_ := 'REF_NO_NULL: Reference number should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;

   -- this line moved to here
   codestr_rec_ := transaction_rec_.codestring_rec;
   tax_direction_ := transaction_rec_.tax_direction; 
   IF (Pseudo_Codes_API.Exist_Pseudo_Code(transaction_rec_.company , codestr_rec_.code_a) = 'TRUE') THEN
      BEGIN
         Pseudo_Codes_API.Check_If_Ownership(transaction_rec_.company, codestr_rec_.code_a, Fnd_Session_API.Get_Fnd_User);
         Ext_Transactions_API.Apply_File_Pseudo(codestr_rec_, tax_direction_, transaction_rec_.company, transaction_rec_.load_id, transaction_rec_.record_no);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;
   
   IF (use_codestr_compl_ = 'TRUE') THEN
      -- check whether the code string has manually changed with a code string completion
      -- if so there is no need validate again.
      IF (transaction_rec_.modify_codestr_cmpl = 'FALSE' OR transaction_rec_.modify_codestr_cmpl = 'PSUDO') THEN
         codestr_rec_.process_code := transaction_rec_.process_code;
         FOR i_ IN 1..10 LOOP
            IF (i_ = 1) THEN
               IF codestr_rec_.code_a IS NULL THEN
                  -- keep this flag to calculate tax
                  account_is_null_ := 'TRUE';
               END IF;
            END IF;
            -- get the first code string completion information from the text file
            -- here the order is from account to code part j
            Accounting_Codestr_Co_Util_API.Codepart_Info (code_part_cmpl_,                -- out 
                                                          code_part_cmpl_value_,          -- out
                                                          codestr_rec_,                   -- in
                                                          i_);                            -- in
            IF (code_part_cmpl_ IS NOT NULL AND code_part_cmpl_value_ IS NOT NULL) THEN
               defined_codestr_ := Accounting_Codestr_Compl_API.Get_Complete_CodeString(transaction_rec_.company ,
                                                                                        code_part_cmpl_,
                                                                                        code_part_cmpl_value_);
               
               account_in_attr_ := Client_SYS.Get_Item_Value('ACCOUNT', defined_codestr_);
               IF (codestr_rec_.code_a IS NOT NULL OR account_in_attr_ IS NOT NULL )THEN
                  Account_API.Get_Required_Code_Part(req_code_str_,
                                                     transaction_rec_.company,
                                                     NVL(codestr_rec_.code_a, account_in_attr_));

                  FOR index_ IN 2..10 LOOP
                     req_id_ := Client_SYS.Get_Item_Value('CODE_'||CHR(64+ index_), req_code_str_);
                     IF (req_id_ = 'S') THEN
                        defined_codestr_ := Client_SYS.Remove_Attr('CODE_'||CHR(64+ index_), defined_codestr_); 
                     END IF;
                  END LOOP;
               END IF;                                                                         
            ELSE
               defined_codestr_ := NULL; 
            END IF;
            IF (defined_codestr_ IS NOT NULL) THEN
               modify_codestr_cmpl_ := 'FALSE';
               mis_match_ := 'FALSE';
               
               Accounting_Codestr_Co_Util_API.Compare_Code_Strings_Info (mismatch_code_part_  ,
                                                                         mismatch_file_codepart_value_   ,
                                                                         mismatch_cmpl_code_part_value_   ,
                                                                         mis_match_,
                                                                         codestr_rec_   ,
                                                                         defined_codestr_);
               
               IF (mis_match_ = 'TRUE') THEN
                  BEGIN                     
                     IF (Accounting_Codestr_Co_Util_API.Is_Codestring_Value(mismatch_code_part_ ,
                                                                            mismatch_file_codepart_value_ ,
                                                                            codestr_rec_)= 'TRUE') THEN
                        -- preparing the relevant parameters for the error
                        error_code_part1_ := Accounting_Code_Parts_API.Get_Name(transaction_rec_.company ,
                                                                                code_part_cmpl_);
                        error_code_part1_ := code_part_cmpl_value_||' '||error_code_part1_;
                        error_code_part2_ := Accounting_Code_Parts_API.Get_Name(transaction_rec_.company ,
                                                                                mismatch_code_part_); 
                        -- use this way since for error msg we cannot give more than 3 parameters 
                        error_code_part2_ := mismatch_file_codepart_value_||' '||error_code_part2_;
                        Error_SYS.Appl_General(lu_name_,'CODESTR_MISMATCH: The :P1 specified in the external file conflicts with the code string completion defined for :P2 .', error_code_part2_, error_code_part1_);
                     ELSE
                        -- preparing the relevant parameters for the error
                        error_code_part1_ := Accounting_Code_Parts_API.Get_Name(transaction_rec_.company ,
                                                                               mismatch_code_part_);
                        error_code_part1_ := mismatch_file_codepart_value_||' '||error_code_part1_;
                        error_code_part2_ := Accounting_Code_Parts_API.Get_Name(transaction_rec_.company ,
                                                                                code_part_cmpl_);
                        -- use this way since for error msg we cannot give more than 3 parameters
                        error_code_part2_ := code_part_cmpl_value_||' '||error_code_part2_;
                        Error_SYS.Appl_General(lu_name_,'CODESTR_MISMATCH2: Code string completion defined for :P1 conflicts with :P2 .', error_code_part2_, error_code_part1_);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        err_msg_ := SQLERRM;
                        External_File_Utility_API.Error_Text_Only(err_msg_);
                  END;
                  IF (err_msg_ IS NOT NULL) THEN
                     RAISE error_excep_;
                  END IF;
               ELSE
                  Accounting_Codestr_Co_Util_API.Apply_Defined_Codestr (codestr_rec_, defined_codestr_);
                  
                  Ext_Transactions_API.Update_Codestr(transaction_rec_.company,
                                                      transaction_rec_.load_id,
                                                      transaction_rec_.record_no,
                                                      codestr_rec_);
                  IF (codestr_rec_.code_a IS NOT NULL) THEN
                     transaction_rec_tmp_ := transaction_rec_;
                     transaction_rec_tmp_.codestring_rec := codestr_rec_;
                     use_codestring_compl_ := TRUE;
                     IF (transaction_rec_tmp_.optional_code IS NULL) THEN
                     -- no need to re-calculate the tax_code since the tax_code value in the file gets the first priority 
                        Ext_Transactions_API.Auto_Tax_Calculation_Prepare(transaction_rec_tmp_);
                        Ext_Transactions_API.Update_Tax_Calc_Info (transaction_rec_.company,
                                                                transaction_rec_.load_id,
                                                                transaction_rec_.record_no,
                                                                transaction_rec_tmp_.optional_code,
                                                                transaction_rec_tmp_.tax_direction,
                                                                transaction_rec_tmp_.currency_tax_amount,
                                                                transaction_rec_tmp_.tax_amount,
                                                                transaction_rec_tmp_.tax_base_amount,
                                                                transaction_rec_tmp_.currency_tax_base_amount,
                                                                transaction_rec_tmp_.third_currency_tax_amount,
                                                                transaction_rec_tmp_.third_curr_tax_base_amount);

 


                     END IF;
                     account_is_null_ := 'FALSE';
                  END IF;
               END IF;
            ELSE
               modify_codestr_cmpl_ := 'TRUE';
            END IF;
         END LOOP;
      ELSIF (transaction_rec_.modify_codestr_cmpl = 'ACCNT' OR transaction_rec_.modify_codestr_cmpl = 'PSUDO') THEN
         -- ACCNT means when only account has changed manually
         IF (codestr_rec_.code_a IS NOT NULL) THEN
            transaction_rec_tmp_                       := transaction_rec_;
            transaction_rec_tmp_.codestring_rec.code_a := codestr_rec_.code_a;
            IF (transaction_rec_tmp_.optional_code IS NULL) THEN
               -- no need to re-calculate the tax_code since the tax_code value in the file gets the first priority 
               Ext_Transactions_API.Auto_Tax_Calculation_Prepare(transaction_rec_tmp_);
               Ext_Transactions_API.Update_Tax_Calc_Info(transaction_rec_.company,
                                                         transaction_rec_.load_id,
                                                         transaction_rec_.record_no,
                                                         transaction_rec_tmp_.optional_code,
                                                         transaction_rec_tmp_.tax_direction,
                                                         transaction_rec_tmp_.currency_tax_amount,
                                                         transaction_rec_tmp_.tax_amount,
                                                         transaction_rec_tmp_.tax_base_amount,
                                                         transaction_rec_tmp_.currency_tax_base_amount,
                                                         transaction_rec_tmp_.third_currency_tax_amount,
                                                         transaction_rec_tmp_.third_curr_tax_base_amount);
            END IF;
            modify_codestr_cmpl_ := 'TRUE';
         END IF;
      END IF;
      -- update the flag - modify_codestr_cmpl_ to prevent LOOPING for the secod time 
      -- when there is no code string compl defined for a record 
      IF (modify_codestr_cmpl_ = 'TRUE') THEN
         Ext_Transactions_API.Update_Modify_Codestr_Cmpl(transaction_rec_.company,
                                                         transaction_rec_.load_id,
                                                         transaction_rec_.record_no,
                                                         modify_codestr_cmpl_);
      END IF;
   END IF;

   IF (codestr_rec_.code_a IS NULL) THEN
      err_msg_ := 'ACCOUNT_NULL: Account must not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   IF (transaction_rec_.currency_code IS NULL) THEN
      err_msg_ := 'CURR_CODE_NULL: Currency code must not be null for not accounting currency';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   
   company_fin_rec_  := Company_Finance_API.Get(transaction_rec_.company);
   acc_currency_     := company_fin_rec_.currency_code;
   third_currency_   := company_fin_rec_.parallel_acc_currency;
   
   IF ((acc_currency_ != transaction_rec_.currency_code) AND
       ((transaction_rec_.currency_amount IS NULL) OR          -- to support old version
        (nvl(transaction_rec_.currency_debet_amount,transaction_rec_.currency_credit_amount) IS NULL)) AND (transaction_rec_.third_currency_amount IS NULL)) THEN
      err_msg_ := 'CAMOUNT_NULL: Currency amount must not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   
   IF NVL(transaction_rec_.debet_amount,0) * NVL(transaction_rec_.currency_debet_amount,0) < 0  OR 
      NVL(transaction_rec_.credit_amount,0)*NVL(transaction_rec_.currency_credit_amount,0) < 0  OR
      NVL(transaction_rec_.currency_amount,0)*NVL(transaction_rec_.amount,0)               < 0  THEN
      BEGIN
         Error_SYS.Record_General('ExtCheck', 'CDMISMATCH: There is a mismatch in the resulting negative Amount and positive Currency Amount or a mismatch in the negative Currency Amount and positive Amount.');
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   

   IF (((transaction_rec_.debet_amount = 0 OR transaction_rec_.debet_amount IS NULL) AND (transaction_rec_.credit_amount IS NULL OR transaction_rec_.credit_amount = 0)) OR
      ((transaction_rec_.credit_amount = 0 OR transaction_rec_.credit_amount IS NULL) AND (transaction_rec_.debet_amount IS NULL OR transaction_rec_.debet_amount = 0))) 
      AND (transaction_rec_.quantity IS NULL OR transaction_rec_.quantity = 0) AND (transaction_rec_.third_currency_amount = 0 OR transaction_rec_.third_currency_amount IS NULL) THEN
         err_msg_ := 'ZERO_AMOUNT: Amount or Quantity must have a value';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;   
   END IF;

   IF (transaction_rec_.debet_amount IS NOT NULL AND transaction_rec_.credit_amount IS NOT NULL) OR 
      (transaction_rec_.currency_debet_amount IS NOT NULL AND transaction_rec_.currency_credit_amount IS NOT NULL) OR
      (transaction_rec_.third_currency_debit_amount IS NOT NULL AND transaction_rec_.third_currency_credit_amount IS NOT NULL) THEN
      err_msg_ := 'DEBIT_CREDIT: Both Debit and Credit amounts are not allowed in the same voucher row';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
   
   mismatch_acc_curr_amt_ := FALSE;
   IF (acc_currency_ = transaction_rec_.currency_code) THEN
      IF (transaction_rec_.debet_amount IS NOT NULL AND transaction_rec_.currency_debet_amount IS NOT NULL) AND
         (transaction_rec_.debet_amount != transaction_rec_.currency_debet_amount) THEN
         mismatch_acc_curr_amt_ := TRUE;
      ELSIF (transaction_rec_.credit_amount IS NOT NULL AND transaction_rec_.currency_credit_amount IS NOT NULL) AND
            (transaction_rec_.credit_amount != transaction_rec_.currency_credit_amount) THEN            
         mismatch_acc_curr_amt_ := TRUE;
      ELSIF (transaction_rec_.amount IS NOT NULL AND transaction_rec_.currency_amount IS NOT NULL) AND
            (transaction_rec_.amount != transaction_rec_.currency_amount) THEN
         mismatch_acc_curr_amt_ := TRUE;
      END IF;
   END IF;
   
   IF mismatch_acc_curr_amt_ THEN
      BEGIN
         Error_SYS.Record_General('ExtCheck', 'CURR_AMOUNT_MISMATCH: Curreny amount and amount cannot have different values when the voucher row is in accounting currency.');
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;
      
   mismatch_third_curr_ := FALSE;
   IF (acc_currency_ = NVL(third_currency_, ' ') AND acc_currency_ = transaction_rec_.currency_code) THEN
      IF (transaction_rec_.debet_amount IS NOT NULL AND transaction_rec_.third_currency_debit_amount IS NOT NULL) AND 
         (transaction_rec_.debet_amount != transaction_rec_.third_currency_debit_amount) THEN
         mismatch_third_curr_ := TRUE;
      ELSIF (transaction_rec_.credit_amount IS NOT NULL AND transaction_rec_.third_currency_credit_amount IS NOT NULL) AND
            (transaction_rec_.credit_amount != transaction_rec_.third_currency_credit_amount) THEN
         mismatch_third_curr_ := TRUE;
      ELSIF (transaction_rec_.currency_debet_amount IS NOT NULL AND transaction_rec_.third_currency_debit_amount IS NOT NULL) AND
            (transaction_rec_.currency_debet_amount != transaction_rec_.third_currency_debit_amount) THEN
         mismatch_third_curr_ := TRUE;
      ELSIF (transaction_rec_.currency_credit_amount IS NOT NULL AND transaction_rec_.third_currency_credit_amount IS NOT NULL) AND
            (transaction_rec_.currency_credit_amount != transaction_rec_.third_currency_credit_amount) THEN
         mismatch_third_curr_ := TRUE;
      END IF;
   END IF;
   
   IF mismatch_third_curr_ THEN
      BEGIN
         Error_SYS.Record_General('ExtCheck', 'THIRD_AMOUNT_MISMATCH: Parallel currency amount cannot have different value from currency amount/amount when the voucher row is in accounting currency..');
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;
   END IF;

   IF (ext_voucher_date_ = '1') THEN  --load date
      voucher_date_ := load_date_;
   ELSIF (ext_voucher_date_ = '2') THEN  --transaction date
      voucher_date_ := transaction_rec_.transaction_date;
   END IF;
   allowed_accounting_period_ := User_Group_Finance_API.Get_Allowed_Acc_Period(transaction_rec_.company,
                                                                               transaction_rec_.user_group);
   -- Check whether the user group is a Year End user group.                                                       
   IF (allowed_accounting_period_ = '2') AND (voucher_date_ IS NOT NULL) THEN  
      Accounting_Period_API.Get_Accounting_Year_Period_Ext( transaction_date_year_,
                                                            transaction_date_period_,
                                                            transaction_rec_.company,
                                                            transaction_rec_.user_group,
                                                            voucher_date_ );
      Accounting_Period_API.Get_Opening_Period( description_,
                                                date_until_,
                                                opening_period_,
                                                transaction_rec_.company,
                                                transaction_date_year_); 
      IF (opening_period_ = transaction_date_period_) THEN
         BEGIN
            Error_SYS.Record_General('ExtCheck', 'NOT_ALLOW: Not allow to use year open period');
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
         END;
         RAISE error_excep_; 
      ELSE
         IF (Accounting_Period_API.Is_Year_End_Period(transaction_rec_.company,
                                                      transaction_date_year_,
                                                      transaction_date_period_) = FALSE) THEN
            BEGIN
               Error_SYS.Record_General('ExtCheck', 'NO_PER: No Period exists for the date :P1 in company :P2', 
                                         voucher_date_, 
                                         transaction_rec_.company );
            EXCEPTION
               WHEN OTHERS THEN
                  err_msg_ := SQLERRM;
            END;
            RAISE error_excep_;
         END IF;
      END IF;
   END IF;
   
   IF (ext_vouch_extern_ = '1') AND (transaction_rec_.voucher_no IS NULL) THEN
      err_msg_ := 'VOU_NO_NULL: Voucher No should not be null';
      BEGIN
         Error_SYS.Record_General('ExtCheck', err_msg_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      RAISE error_excep_;      
   END IF;

   IF (ext_vouch_extern_ = '1') AND (transaction_rec_.voucher_no IS NOT NULL) THEN
      BEGIN
         Voucher_No_Serial_API.Check_Voucher_No(transaction_rec_.company,
                                                voucher_date_,
                                                transaction_rec_.voucher_type,
                                                transaction_rec_.voucher_no);

      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
   END IF;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;

   -- validate code string
   codestr_rec_.quantity := transaction_rec_.quantity;
   codestr_rec_.text := transaction_rec_.text;
   codestr_rec_.process_code := transaction_rec_.process_code;


   IF (val_code_str_ = 'I') THEN
      BEGIN
         Ext_Transactions_API.Validate_Code_String( codestr_rec_,
                                                    transaction_rec_.company,
                                                    user_group_,
                                                    voucher_date_ );
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;

      -- The Ledger Accounts are only allowed for vouchers with function group Q
      -- If Parameter 'Validate Codestring' is set to Excluded (E) this will be allowed
      BEGIN
         IF (NVL(transaction_rec_.tax_transaction,'FALSE') = 'FALSE') THEN
            IF (Account_API.Is_Ledger_Account(transaction_rec_.company, codestr_rec_.code_a) )THEN
               IF (Voucher_Type_Detail_API.Get_Function_Group(transaction_rec_.company, transaction_rec_.voucher_type) != 'Q') THEN
                  Error_SYS.Record_General(lu_name_,
                                           'VOUISLEDGER: Ledger Account :P1 is only permitted for Vouchers with Function Group Q',
                                           codestr_rec_.code_a);

               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;

      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;

   -- check if currency code exists
   BEGIN
      Currency_Code_API.Exist(transaction_rec_.company,
                              transaction_rec_.currency_code);
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;

   -- check if processing code exists
   IF (transaction_rec_.process_code IS NOT NULL) THEN
      BEGIN
         Account_Process_Code_API.Validate_Process_Code(dummy_,
                                                        transaction_rec_.company,
                                                        transaction_rec_.process_code,
                                                        voucher_date_);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;

   -- Validate delivery type Id
   IF (transaction_rec_.deliv_type_id IS NOT NULL) THEN
      BEGIN
         Voucher_Row_API.Validate_Delivery_Type_Id__(transaction_rec_.company,
                                                     transaction_rec_.deliv_type_id);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
      END;
      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;
   
   Check_Object___(transaction_rec_, 
                   err_msg_);
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;
   
   IF (use_codestring_compl_) THEN
      Check_Project___(err_msg_, transaction_rec_tmp_, voucher_date_);
   ELSE
      Check_Project___(err_msg_, transaction_rec_, voucher_date_);
   END IF;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;
   
   BEGIN
      -- Validate Tax Code      
      IF (Voucher_Type_API.Get_Simulation_Voucher(transaction_rec_.company, transaction_rec_.voucher_type) = 'FALSE') THEN
         IF (Voucher_Type_Detail_API.Get_Function_Group(transaction_rec_.company, transaction_rec_.voucher_type) IN ('M', 'Q')) THEN
            IF (transaction_rec_.optional_code IS NULL) THEN
               Tax_Handling_Util_API.Validate_Tax_Code_Manda_On_Acc(transaction_rec_.company, codestr_rec_.code_a);   
            END IF;
         END IF;
      END IF;
      IF (transaction_rec_.optional_code IS NOT NULL OR codestr_rec_.code_a IS NOT NULL) THEN
         IF codestr_rec_.code_a IS NOT NULL THEN
            account_validation_ := 'TRUE';
         END IF;
         Tax_Handling_Util_API.Validate_Tax_On_Trans(transaction_rec_.company,
                                                     'RESTRICTED',
                                                     transaction_rec_.optional_code,
                                                     account_validation_,
                                                     codestr_rec_.code_a,
                                                     voucher_date_);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;
   
   -- Validate Tax Direction, Tax Amount, Currency Tax Amount.
   BEGIN
      IF (transaction_rec_.optional_code IS NOT NULL AND tax_direction_ IS NULL) THEN
         Error_SYS.Appl_General(lu_name_,'NOTAXDIRECTION: Tax Code :P1 must have Tax Direction.',transaction_rec_.optional_code);
      END IF;

      IF transaction_rec_.optional_code  IS NOT NULL AND tax_direction_ IS NOT NULL AND
          NVL(transaction_rec_.tax_amount,0) = 0 AND NVL(transaction_rec_.currency_tax_amount,0) != 0 THEN
         Error_SYS.Appl_General(lu_name_,'NOTAXAMOUNT: Tax Amount has not been entered.');
      END IF;

      IF transaction_rec_.optional_code  IS NOT NULL AND tax_direction_ IS NOT NULL AND
          NVL(transaction_rec_.tax_amount,0) != 0 AND NVL(transaction_rec_.currency_tax_amount,0) = 0 THEN
         Error_SYS.Appl_General(lu_name_,'NOCURRTAXAMOUNT: Currency Tax Amount has not been entered.');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;
   --Validate Tax Direction
   BEGIN
      IF (transaction_rec_.optional_code  IS NOT NULL AND codestr_rec_.code_a IS NOT NULL) THEN
         tax_rec_  := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(transaction_rec_.company, transaction_rec_.optional_code, SYSDATE, 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
         tax_type_ := tax_rec_.fee_type;
         IF (tax_type_ IN (Fee_Type_API.DB_NO_TAX)) THEN
            temp_transaction_rec_.tax_direction := tax_type_;
            IF Tax_Direction_API.Encode(transaction_rec_.tax_direction) IS NOT NULL AND transaction_rec_.tax_direction IS NOT NULL THEN
               IF temp_transaction_rec_.tax_direction != Tax_Direction_API.Encode(transaction_rec_.tax_direction) THEN
                  Error_SYS.Appl_General(lu_name_,'INVALID_TAXDIR: Tax Direction :P1 is not valid for Tax Code :P2.',transaction_rec_.tax_direction,transaction_rec_.optional_code);
               END IF;
            ELSIF Tax_Direction_API.Encode(transaction_rec_.tax_direction) IS NULL AND transaction_rec_.tax_direction IS NOT NULL THEN
               IF temp_transaction_rec_.tax_direction != transaction_rec_.tax_direction THEN
                  Error_SYS.Appl_General(lu_name_,'INVALID_TAXDIR: Tax Direction :P1 is not valid for Tax Code :P2.',transaction_rec_.tax_direction,transaction_rec_.optional_code);
               END IF;
            END IF;
         ELSIF Tax_Direction_API.Encode(transaction_rec_.tax_direction) IN (Fee_Type_API.DB_NO_TAX) THEN
            Error_SYS.Appl_General(lu_name_,'INVALID_TAXDIR: Tax Direction :P1 is not valid for Tax Code :P2.',transaction_rec_.tax_direction,transaction_rec_.optional_code);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;

   BEGIN
      IF transaction_rec_.optional_code IS NOT NULL THEN
         tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(transaction_rec_.company, transaction_rec_.optional_code, voucher_date_, 'TRUE', 'TRUE', 'FETCH_IF_VALID'); 
         
         IF (tax_rec_.fee_type = Fee_Type_API.DB_CALCULATED_TAX) THEN
            amount_method_ := Def_Amount_Method_API.DB_NET;
         ELSE
            amount_method_ := company_fin_rec_.def_amount_method;
         END IF;         
         
         IF (Tax_Direction_API.Encode(transaction_rec_.tax_direction) = Tax_Direction_API.DB_TAX_DISBURSED) THEN
            deductible_factor_ := 1;
         ELSE
            deductible_factor_ := tax_rec_.deductible / 100;
         END IF;
         
         Tax_Handling_Accrul_Util_API.Check_Max_Overwrite_Level(transaction_rec_.company,
                                                                transaction_rec_.currency_code,
                                                                transaction_rec_.optional_code,
                                                                transaction_rec_.tax_percentage,
                                                                amount_method_,
                                                                transaction_rec_.amount,
                                                                transaction_rec_.tax_amount,
                                                                deductible_factor_,
                                                                tax_rec_,
                                                                voucher_date_);         
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         err_msg_ := SQLERRM;
   END;
   IF (err_msg_ IS NOT NULL) THEN
      RAISE error_excep_;
   END IF;
   
   IF (NVL(transaction_rec_.currency_debet_amount,0) != 0 OR NVL(transaction_rec_.currency_credit_amount,0)!= 0) THEN
      IF (((transaction_rec_.debet_amount = 0 OR transaction_rec_.debet_amount IS NULL) AND (transaction_rec_.credit_amount IS NULL OR transaction_rec_.credit_amount = 0)) OR
         ((transaction_rec_.credit_amount = 0 OR transaction_rec_.credit_amount IS NULL) AND (transaction_rec_.debet_amount IS NULL OR transaction_rec_.debet_amount = 0))) 
         AND (transaction_rec_.quantity IS NOT NULL AND transaction_rec_.quantity != 0 ) THEN
         BEGIN
            Error_SYS.Record_General('ExtCheck', 'ZERO_AMOUNT2: The Amount field cannot be zero when a value exists in the Currency Amount field.');
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_ := SQLERRM;
               External_File_Utility_API.Error_Text_Only(err_msg_);
         END;
         RAISE error_excep_;   
      END IF;
   END IF;
   
   IF (transaction_rec_.currency_rate_type IS NOT NULL) THEN
      BEGIN
         Currency_Type_API.Exist(transaction_rec_.company ,
                                 transaction_rec_.currency_rate_type);
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
            External_File_Utility_API.Error_Text_Only(err_msg_);
      END;
      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;
   
   IF (transaction_rec_.parallel_curr_rate_type IS NOT NULL) THEN
      BEGIN
         IF (company_fin_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN
            OPEN check_type_parallel(transaction_rec_.company,transaction_rec_.parallel_curr_rate_type);
            FETCH check_type_parallel INTO dummy_;
            IF (check_type_parallel%FOUND) THEN
               CLOSE check_type_parallel;
               Error_SYS.Record_General(lu_name_,'RATETYPEPARALLEL: The selected Currency Rate Type should have the Rate Type Category defined as Parallel Currency.');
            END IF;
            CLOSE check_type_parallel;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            err_msg_ := SQLERRM;
            External_File_Utility_API.Error_Text_Only(err_msg_);
      END;
      IF (err_msg_ IS NOT NULL) THEN
         RAISE error_excep_;
      END IF;
   END IF;   
EXCEPTION
   WHEN error_excep_ THEN
      -- let the error message propagate to the higher level and take care of it in the prev. level
      err_txt_ := err_msg_;
END Validate_Transaction_Data__;


PROCEDURE Create_Voucher__ (
   voucher_no_seq_    IN OUT NUMBER,
   company_           IN VARCHAR2,
   load_id_           IN VARCHAR2,
   ext_group_by_item_ IN VARCHAR2,
   ext_voucher_diff_  IN VARCHAR2,
   group_by_value_    IN VARCHAR2,
   voucher_type_      IN VARCHAR2,
   voucher_date_      IN DATE,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   user_              IN VARCHAR2,
   user_group_        IN VARCHAR2 )
IS
   value_attr_                    VARCHAR2(2000);
   posting_type_desc_             VARCHAR2(200);
   prv_load_group_item_           VARCHAR2(50);
   
   row_no_                        NUMBER;
   debit_amount_                  NUMBER;
   credit_amount_                 NUMBER;
   currency_debit_amount_         NUMBER;
   currency_credit_amount_        NUMBER;
   tax_base_amount_               NUMBER;
   currency_tax_base_amount_      NUMBER;
   voucher_no_                    NUMBER;
   third_currency_debit_amount_   NUMBER;
   third_currency_credit_amount_  NUMBER;
   third_curr_tax_base_amount_    NUMBER;
   same_                          NUMBER;
   not_same_                      NUMBER;   
   transaction_date_              DATE;   
   f_vouch_head_                  BOOLEAN;   
   main_correction_               ext_parameters_tab.correction%TYPE;
   condition2_                    ext_parameters_tab.correction%TYPE;
   function_group_                VOUCHER_TYPE_DETAIL_TAB.function_group%TYPE;   
   transaction_rec_               Ext_Transactions_API.ExtTransRec;
   transaction_rec2_              Ext_Transactions_API.ExtTransRec;
   codestring_rec_                Accounting_Codestr_API.CodestrRec;
   adjust_debit_                  BOOLEAN := FALSE;
   acc_diff_                      BOOLEAN := FALSE;
   second_row_                    BOOLEAN := FALSE;
  
   CURSOR getrec IS
      SELECT company,
             load_id,
             record_no,
             load_group_item,
             load_error,
             transaction_date,
             voucher_type,
             voucher_no,
             accounting_year,
             account,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j,
             currency_debet_amount,
             currency_credit_amount,
             currency_amount,          -- to support old version
             debet_amount,
             credit_amount,
             amount,                   -- to support old version
             third_currency_debit_amount,
             third_currency_credit_amount,
             third_currency_amount,
             third_currency_tax_amount,
             currency_code,
             quantity,
             process_code,
             optional_code,
             tax_percentage,
             project_activity_id,
             text,
             party_type,
             party_type_id,
             reference_number,
             reference_serie,
             trans_code,
             tax_direction,
             tax_amount,
             currency_tax_amount,
             tax_base_amount,
             currency_tax_base_amount,
             correction,
             load_type,
             currency_rate,
             event_date, 
             retroactive_date,
             transaction_reason,
             third_curr_tax_base_amount,
             deliv_type_id ,
             currency_rate_type,
             parallel_curr_rate_type
      FROM   Ext_Transactions
      WHERE  company         = company_
      AND    load_id         = load_id_
      AND    load_group_item = group_by_value_
      ORDER BY record_no;
      
   CURSOR check_rows_ IS
      SELECT load_group_item
      FROM   ext_transactions_tab
      WHERE  company         = company_
      AND    load_id         = load_id_
      AND    load_group_item = group_by_value_;
   
BEGIN
   debit_amount_           := 0;
   credit_amount_          := 0;
   currency_debit_amount_  := 0;
   currency_credit_amount_ := 0;
   third_currency_debit_amount_     := 0;
   third_currency_credit_amount_    := 0;
   f_vouch_head_           := TRUE;
   function_group_ := Voucher_Type_Detail_API.Get_Function_Group(company_,
                                                                 voucher_type_);
   not_same_ := 1;
   same_     := 1;
   FOR get_ IN check_rows_ LOOP
      IF (prv_load_group_item_ IS NULL) THEN
         prv_load_group_item_ := get_.load_group_item;
      ELSIF (prv_load_group_item_ <> get_.load_group_item) THEN
         not_same_ := -1;
      ELSE
         same_     := 1;
      END IF;
      prv_load_group_item_ := get_.load_group_item;
   END LOOP;
   IF (not_same_ * same_ > 0)  THEN
      Ext_Create_API.Delete_Extvouchers__(company_, load_id_, prv_load_group_item_);
   END IF;
   
   OPEN getrec;
   LOOP
      FETCH getrec
         INTO transaction_rec_.company,
              transaction_rec_.load_id,
              transaction_rec_.record_no,
              transaction_rec_.load_group_item,
              transaction_rec_.load_error,
              transaction_rec_.transaction_date,
              transaction_rec_.voucher_type,
              transaction_rec_.voucher_no,
              transaction_rec_.accounting_year,
              transaction_rec_.codestring_rec.code_a,
              transaction_rec_.codestring_rec.code_b,
              transaction_rec_.codestring_rec.code_c,
              transaction_rec_.codestring_rec.code_d,
              transaction_rec_.codestring_rec.code_e,
              transaction_rec_.codestring_rec.code_f,
              transaction_rec_.codestring_rec.code_g,
              transaction_rec_.codestring_rec.code_h,
              transaction_rec_.codestring_rec.code_i,
              transaction_rec_.codestring_rec.code_j,
              transaction_rec_.currency_debet_amount,
              transaction_rec_.currency_credit_amount,
              transaction_rec_.currency_amount,      -- to support old version
              transaction_rec_.debet_amount,
              transaction_rec_.credit_amount,
              transaction_rec_.amount,               -- to support old version
              transaction_rec_.third_currency_debit_amount,
              transaction_rec_.third_currency_credit_amount,
              transaction_rec_.third_currency_amount,
              transaction_rec_.third_currency_tax_amount,
              transaction_rec_.currency_code,
              transaction_rec_.quantity,
              transaction_rec_.process_code,
              transaction_rec_.optional_code,
              transaction_rec_.tax_percentage,
              transaction_rec_.project_activity_id,
              transaction_rec_.text,
              transaction_rec_.party_type,
              transaction_rec_.party_type_id,
              transaction_rec_.reference_number,
              transaction_rec_.reference_serie,
              transaction_rec_.trans_code,
              transaction_rec_.tax_direction,
              transaction_rec_.tax_amount,
              transaction_rec_.currency_tax_amount,
              transaction_rec_.tax_base_amount,
              transaction_rec_.currency_tax_base_amount,
              transaction_rec_.correction,
              transaction_rec_.load_type,
              transaction_rec_.currency_rate,
              transaction_rec_.event_date,
              transaction_rec_.retroactive_date,
              transaction_rec_.transaction_reason,
              transaction_rec_.third_curr_tax_base_amount,
              transaction_rec_.deliv_type_id,
              transaction_rec_.currency_rate_type,
              transaction_rec_.parallel_curr_rate_type;

      EXIT WHEN getrec%NOTFOUND;
      IF (ext_group_by_item_ <> '1') THEN -- voucher no should not be considered in transaction
         transaction_rec_.voucher_no := NULL;
      END IF;

      voucher_no_        := transaction_rec_.voucher_no;
      transaction_date_  := transaction_rec_.transaction_date;
      IF (f_vouch_head_ = TRUE) THEN
         Create_Voucher_Head__(voucher_no_seq_,
                               voucher_type_,
                               voucher_date_,
                               accounting_year_,
                               accounting_period_,
                               user_,
                               user_group_,
                               transaction_rec_);
         f_vouch_head_ := FALSE;
      END IF;
      IF (transaction_rec_.optional_code IS NOT NULL AND transaction_rec_.tax_direction IS NOT NULL) THEN
         transaction_rec_.tax_direction := Tax_Direction_API.Encode(transaction_rec_.tax_direction);
         IF (transaction_rec_.tax_amount IS NOT NULL AND transaction_rec_.currency_tax_amount IS NOT NULL) THEN
            IF (transaction_rec_.tax_base_amount IS NOT NULL) THEN
               tax_base_amount_ := transaction_rec_.tax_base_amount;
               transaction_rec_.tax_base_amount := NULL;
            END IF;
            IF (transaction_rec_.currency_tax_base_amount IS NOT NULL) THEN
               currency_tax_base_amount_ := transaction_rec_.currency_tax_base_amount;
               transaction_rec_.currency_tax_base_amount := NULL;
            END IF;
            IF (transaction_rec_.third_currency_tax_amount IS NOT NULL) THEN
               third_curr_tax_base_amount_ := transaction_rec_.third_curr_tax_base_amount;
               transaction_rec_.third_curr_tax_base_amount := NULL;
            END IF;
         END IF;
      END IF;
      transaction_rec_.tax_transaction := 'FALSE';
      Create_Voucher_Row__(voucher_no_seq_,
                           row_no_,
                           accounting_year_,
                           voucher_type_,
                           transaction_rec_);

      IF (Account_API.Is_Stat_Account(transaction_rec_.company,transaction_rec_.codestring_rec.code_a) = 'FALSE') THEN
         debit_amount_           := debit_amount_ + nvl(transaction_rec_.debet_amount,0);
         credit_amount_          := credit_amount_ + nvl(transaction_rec_.credit_amount,0);
         currency_debit_amount_  := currency_debit_amount_ + nvl(transaction_rec_.currency_debet_amount,0);
         currency_credit_amount_ := currency_credit_amount_ + nvl(transaction_rec_.currency_credit_amount,0);
         third_currency_debit_amount_  := third_currency_debit_amount_ + nvl(transaction_rec_.third_currency_debit_amount,0);
         third_currency_credit_amount_ := third_currency_credit_amount_ + nvl(transaction_rec_.third_currency_credit_amount,0);
      END IF;
      
      IF (transaction_rec_.optional_code IS NOT NULL AND transaction_rec_.tax_direction IS NOT NULL AND
           transaction_rec_.tax_amount IS NOT NULL AND transaction_rec_.currency_tax_amount IS NOT NULL) THEN
         IF (tax_base_amount_ IS NOT NULL) THEN
            transaction_rec_.tax_base_amount := tax_base_amount_;
         END IF;

         IF (currency_tax_base_amount_ IS NOT NULL) THEN
            transaction_rec_.currency_tax_base_amount := currency_tax_base_amount_;
         END IF;
         
         IF (third_curr_tax_base_amount_ IS NOT NULL) THEN
            transaction_rec_.third_curr_tax_base_amount := third_curr_tax_base_amount_;
         END IF;
         IF (function_group_ != 'Q' OR function_group_ IS NULL) THEN
            Prepare_Tax_Transaction___(voucher_no_seq_,
                                       row_no_,
                                       accounting_year_,
                                       voucher_type_,
                                       voucher_date_,
                                       transaction_rec_,
                                       debit_amount_,
                                       credit_amount_,
                                       currency_debit_amount_,
                                       currency_credit_amount_,
                                       third_currency_debit_amount_,
                                       third_currency_credit_amount_);
         END IF;
      END IF;
   END LOOP;
   CLOSE getrec;

   main_correction_ := Ext_Parameters_API.Get_Correction(transaction_rec_.company, transaction_rec_.load_type);
   IF (main_correction_= 'TRUE' AND ext_voucher_diff_ = 'Y' AND debit_amount_-(credit_amount_) != 0) THEN
      condition2_ := 'TRUE';
   ELSE
      condition2_ := 'FALSE';
   END IF;      
   -- adding new row for the diff.
   IF (condition2_ = 'TRUE') OR ( (ext_voucher_diff_ = 'Y') AND ((abs(debit_amount_) != abs(credit_amount_)) OR (abs(third_currency_debit_amount_) != abs(third_currency_credit_amount_))) ) THEN
      Client_SYS.Add_To_Attr('AC1', '*', value_attr_);
      Client_SYS.Add_To_Attr('AC5', user_group_, value_attr_);
      Posting_Ctrl_API.Posting_Event(codestring_rec_,
                                     company_,
                                     'AP9',
                                     trunc(sysdate),
                                     value_attr_);

      posting_type_desc_ := Posting_Ctrl_API.Get_Posting_Type_Desc(company_, 'AP9');

      IF (ext_group_by_item_ = '1') THEN
         transaction_rec_.voucher_no       := voucher_no_ ;
         transaction_rec_.transaction_date := '';
         transaction_rec_.reference_number := '';
      ELSIF (ext_group_by_item_ = '2') THEN
         transaction_rec_.voucher_no       := NULL;
         transaction_rec_.load_group_item  := group_by_value_;
         transaction_rec_.transaction_date := '';
         transaction_rec_.reference_number := '';
      ELSIF (ext_group_by_item_= '3') THEN
         transaction_rec_.voucher_no       := NULL;
         transaction_rec_.transaction_date := to_date(group_by_value_);
         transaction_rec_.reference_number := '';
      ELSIF (ext_group_by_item_= '4') THEN
         transaction_rec_.voucher_no       := NULL;
         transaction_rec_.transaction_date := '';
         transaction_rec_.reference_number := group_by_value_;
      END IF;
      transaction_rec_.company             := company_;
      transaction_rec_.load_id             := load_id_;
      transaction_rec_.codestring_rec      := codestring_rec_;      
      -- get the accounting currency
      transaction_rec_.currency_code   := Company_Finance_API.Get_Currency_Code(company_);
      transaction_rec_.quantity        := 0;
      transaction_rec_.process_code    := '';
      transaction_rec_.optional_code   := '';
      transaction_rec_.text            := posting_type_desc_;
      transaction_rec_.party_type      := '';
      transaction_rec_.party_type_id   := '';
      transaction_rec_.reference_serie := '';
      transaction_rec_.trans_code      := 'AP9';
      transaction_rec_.tax_direction       := '';
      transaction_rec_.tax_amount          := '';
      transaction_rec_.currency_tax_amount := '';
      transaction_rec_.tax_base_amount     := '';
      transaction_rec_.currency_tax_base_amount := '';
      transaction_rec_.Project_Activity_Id := NULL;
      transaction_rec_.tax_transaction := 'FALSE';           

      -- multiply amount by -1 to be added to the less side
      IF ((abs(debit_amount_) != abs(credit_amount_)) OR (abs(third_currency_debit_amount_) != abs(third_currency_credit_amount_))) THEN         
         transaction_rec2_ := transaction_rec_;         
         
         IF (abs(debit_amount_) != abs(credit_amount_)) THEN
            acc_diff_ := TRUE;
            IF (debit_amount_ > credit_amount_) THEN
               adjust_debit_ := FALSE;
               transaction_rec_.debet_amount := NULL;
               transaction_rec_.credit_amount := debit_amount_ - credit_amount_;
               transaction_rec_.amount := -transaction_rec_.credit_amount;     -- to support old version
               
               transaction_rec_.currency_debet_amount := NULL;
               transaction_rec_.currency_credit_amount := 0;
               transaction_rec_.currency_amount := transaction_rec_.currency_credit_amount;                              
            ELSE
               adjust_debit_ := TRUE;
               transaction_rec_.debet_amount := credit_amount_ - debit_amount_;
               transaction_rec_.credit_amount := NULL;
               transaction_rec_.amount := transaction_rec_.debet_amount;    -- to support old version
               
               transaction_rec_.currency_debet_amount := 0;
               transaction_rec_.currency_credit_amount := NULL;
               transaction_rec_.currency_amount := transaction_rec_.currency_debet_amount;               
            END IF;
         ELSE
            transaction_rec_.debet_amount := 0;
            transaction_rec_.credit_amount := NULL;
            transaction_rec_.amount := transaction_rec_.debet_amount;    -- to support old version
            transaction_rec_.currency_debet_amount := 0;
            transaction_rec_.currency_credit_amount := NULL;
            transaction_rec_.currency_amount := transaction_rec_.currency_debet_amount;                           
         END IF;  
         
         IF (abs(third_currency_debit_amount_) != abs(third_currency_credit_amount_))  THEN
            IF (third_currency_debit_amount_ > third_currency_credit_amount_) AND acc_diff_ AND adjust_debit_ THEN
               -- Two transaction must be created since we cannot create debit and credit amounts on same voucher row
               transaction_rec_.third_currency_debit_amount := 0;
               transaction_rec_.third_currency_credit_amount := NULL;
               transaction_rec_.third_currency_amount := transaction_rec_.third_currency_debit_amount;    -- to support old version                              
                              
               second_row_ := TRUE;
               -- set values for additional voucher rounding row
               transaction_rec2_.third_currency_debit_amount := NULL;
               transaction_rec2_.third_currency_credit_amount := third_currency_debit_amount_ - third_currency_credit_amount_;
               transaction_rec2_.third_currency_amount := -transaction_rec2_.third_currency_credit_amount;     -- to support old version               
               -- acc amount
               transaction_rec2_.debet_amount := NULL;
               transaction_rec2_.credit_amount := 0;
               transaction_rec2_.amount := transaction_rec2_.credit_amount;     -- to support old version                     
               -- trans curr amount
               transaction_rec2_.currency_debet_amount := transaction_rec2_.debet_amount;
               transaction_rec2_.currency_credit_amount := transaction_rec2_.credit_amount;
               transaction_rec2_.currency_amount := transaction_rec2_.amount;
            ELSIF (third_currency_debit_amount_ < third_currency_credit_amount_) AND acc_diff_ AND NOT adjust_debit_ THEN
               -- Two transaction must be created since we cannot create debit and credit amounts on same voucher row
               transaction_rec_.third_currency_credit_amount := 0;
               transaction_rec_.third_currency_debit_amount := NULL;
               transaction_rec_.third_currency_amount := transaction_rec_.third_currency_credit_amount;    -- to support old version                
               
               second_row_ := TRUE;
               -- set values for additional voucher rounding row
               transaction_rec2_.third_currency_credit_amount := NULL;
               transaction_rec2_.third_currency_debit_amount := third_currency_credit_amount_ - third_currency_debit_amount_;
               transaction_rec2_.third_currency_amount := -transaction_rec2_.third_currency_debit_amount;     -- to support old version                              
               -- acc amount
               transaction_rec2_.credit_amount := NULL;
               transaction_rec2_.debet_amount := 0;
               transaction_rec2_.amount := transaction_rec2_.debet_amount;     -- to support old version                                       
               -- trans curr amount
               transaction_rec2_.currency_debet_amount := transaction_rec2_.debet_amount;
               transaction_rec2_.currency_credit_amount := transaction_rec2_.credit_amount;
               transaction_rec2_.currency_amount := transaction_rec2_.amount;                                
            ELSE
               IF (third_currency_debit_amount_ > third_currency_credit_amount_) THEN
                  transaction_rec_.third_currency_debit_amount := NULL;
                  transaction_rec_.third_currency_credit_amount := third_currency_debit_amount_ - third_currency_credit_amount_;
                  transaction_rec_.third_currency_amount := -transaction_rec_.third_currency_credit_amount;     -- to support old version
               ELSE
                  transaction_rec_.third_currency_debit_amount := third_currency_credit_amount_ - third_currency_debit_amount_;
                  transaction_rec_.third_currency_credit_amount := NULL;
                  transaction_rec_.third_currency_amount := transaction_rec_.third_currency_debit_amount;    -- to support old version
               END IF;
            END IF;
         ELSE
            transaction_rec_.third_currency_debit_amount := 0;
            transaction_rec_.third_currency_credit_amount := NULL;
            transaction_rec_.third_currency_amount := transaction_rec_.third_currency_debit_amount;    -- to support old version                  
         END IF;   
      END IF;      
      Create_Voucher_Row__(voucher_no_seq_,
                           row_no_,
                           accounting_year_,
                           voucher_type_,
                           transaction_rec_);                             
      -- only create the second rounding row when needed                             
      IF (second_row_) THEN
         Create_Voucher_Row__(voucher_no_seq_,
                              row_no_,
                              accounting_year_,
                              voucher_type_,
                              transaction_rec2_);         
      END IF;                             
   END IF;
END Create_Voucher__;

PROCEDURE Remove_Voucher__ (
   company_ IN VARCHAR2,
   load_id_ IN VARCHAR2 )
IS
BEGIN
   NULL;
END Remove_Voucher__;

PROCEDURE Create_Voucher_Head__ (
   voucher_no_seq_    IN OUT NUMBER,
   voucher_type_      IN VARCHAR2,
   voucher_date_      IN DATE,
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   user_              IN VARCHAR2,
   user_group_        IN VARCHAR2,
   transaction_rec_   IN Ext_Transactions_API.ExtTransRec )
IS
BEGIN
   IF (transaction_rec_.voucher_no IS NULL) THEN
      voucher_no_seq_ := voucher_no_seq_ + 1;
   END IF;
   INSERT
      INTO Ext_Voucher_Tab (
         Company,
         Accounting_Year,
         Voucher_No,
         Load_Id,
         Load_Group_Item,
         Transaction_Date,
         reference_number,
         Voucher_Type,
         Voucher_Date,
         User_Group,
         Accounting_Period,
         Date_Reg,
         Userid,
         Interim_Voucher,
         Rowstate,
         Rowversion )
      VALUES (
         transaction_rec_.company,
         accounting_year_,
         decode(transaction_rec_.voucher_no, NULL, voucher_no_seq_, transaction_rec_.voucher_no),
         transaction_rec_.load_id,
         transaction_rec_.load_group_item,
         transaction_rec_.transaction_date,
         transaction_rec_.reference_number,
         transaction_rec_.voucher_type,       --Merged External Files
         voucher_date_,
         user_group_,
         accounting_period_,
         sysdate,
         user_,               -- from load_info_tab
         'N',
         'Confirmed',         -- whether some function is present in voucher apy to set the rowstate
         sysdate);
END Create_Voucher_Head__;


PROCEDURE Create_Voucher_Row__ (
   voucher_no_seq_  IN  OUT NUMBER,
   row_no_          IN  OUT NUMBER,
   accounting_year_ IN  NUMBER,
   voucher_type_    IN  VARCHAR2,
   transaction_rec_ IN  Ext_Transactions_API.ExtTransRec,
   tax_trans_       IN BOOLEAN DEFAULT FALSE   )
IS
   trans_code_                   VARCHAR2(100);
   tax_type_                     VARCHAR2(100);
   correction_                   VARCHAR2(1);
   
   debet_amount_                 NUMBER;
   credit_amount_                NUMBER;
   currency_debet_amount_        NUMBER;
   currency_credit_amount_       NUMBER;
   third_currency_debit_amount_  NUMBER;
   third_currency_credit_amount_ NUMBER;
   reference_row_no_             NUMBER ;
   tax_code_rec_                 Statutory_Fee_API.Public_Rec;
BEGIN
   IF (tax_trans_) THEN
      reference_row_no_ := row_no_;
   END IF;

   IF (transaction_rec_.trans_code IS NULL) THEN
      trans_code_ := 'EXTERNAL';
   ELSE
      trans_code_ := transaction_rec_.trans_code;
   END IF;

   IF (transaction_rec_.optional_code IS NOT NULL ) THEN
      tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(transaction_rec_.company, transaction_rec_.optional_code, TRUNC(SYSDATE), 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
      tax_type_     := tax_code_rec_.fee_type;
   ELSE
      tax_type_ := NULL;
   END IF;

   IF (NOT(tax_type_ = Fee_Type_API.DB_CALCULATED_TAX AND transaction_rec_.tax_direction = 'TAXDISBURSED' AND trans_code_ = 'AP2')) THEN                                           
      IF (nvl(transaction_rec_.debet_amount,0) = 0 AND nvl(transaction_rec_.credit_amount,0) = 0) THEN
         IF ( transaction_rec_.amount > 0 ) THEN
            debet_amount_ := transaction_rec_.amount;
         ELSE
            credit_amount_ := -transaction_rec_.amount;
         END IF;
      ELSE
         debet_amount_ := transaction_rec_.debet_amount;
         credit_amount_ := transaction_rec_.credit_amount;
      END IF;
      IF (nvl(transaction_rec_.currency_debet_amount,0)=0 AND nvl(transaction_rec_.currency_credit_amount,0)=0) THEN
         IF ( transaction_rec_.currency_amount > 0 ) THEN
            currency_debet_amount_ := transaction_rec_.currency_amount;
         ELSE
            currency_credit_amount_ := -transaction_rec_.currency_amount;
         END IF;
      ELSE
         currency_debet_amount_ := transaction_rec_.currency_debet_amount;
         currency_credit_amount_ := transaction_rec_.currency_credit_amount;
      END IF;
      IF (nvl(transaction_rec_.third_currency_debit_amount,0)=0 AND nvl(transaction_rec_.third_currency_credit_amount,0)=0) THEN
         IF (transaction_rec_.third_currency_amount > 0) THEN
            third_currency_debit_amount_ := transaction_rec_.third_currency_amount;
         ELSE
            third_currency_credit_amount_ := -transaction_rec_.third_currency_amount;
         END IF;
      ELSE
         third_currency_debit_amount_ := transaction_rec_.third_currency_debit_amount;
         third_currency_credit_amount_ := transaction_rec_.third_currency_credit_amount;
      END IF;
   END IF;
   -- find out the posting differences from parameters tab and perform the operation
   IF (row_no_ IS NULL) THEN
      row_no_ := 1;
   ELSE
      row_no_ := row_no_ + 1;
   END IF;
   
   IF (transaction_rec_.correction = 'FALSE') THEN
      correction_ := 'N';
   ELSE
      correction_ := 'Y';
   END IF;
   INSERT
      INTO Ext_Voucher_Row_Tab (
         Company,
         Accounting_Year,
         Voucher_No,
         Load_Id,
         Load_Group_Item,
         Transaction_Date,
         Row_No,
         Voucher_Type,
         Account,
         Code_B,
         Code_C,
         Code_D,
         Code_E,
         Code_F,
         Code_G,
         Code_H,
         Code_I,
         Code_J,
         Currency_Debet_Amount,
         Currency_Credit_Amount,
         Debet_Amount,
         Credit_Amount,
         Third_Currency_Debit_Amount,
         Third_Currency_Credit_Amount,
         --Third_Currency_Amount,
         Third_Currency_Tax_Amount,
         Currency_Code,
         Quantity,
         Process_Code,
         Optional_Code,
         Tax_Percentage,
         project_activity_id,
         Text,
         Party_Type,
         Party_Type_Id,
         Trans_Code,
         reference_number,
         reference_serie,
         Corrected,
         tax_direction,
         tax_amount,
         currency_tax_amount,
         tax_base_amount,
         currency_tax_base_amount,
         currency_rate,
         event_date, 
         retroactive_date,
         transaction_reason,
         third_curr_tax_base_amount,
         deliv_type_id,
         record_no,
         reference_row_no,
         currency_rate_type,
         parallel_curr_rate_type,
         tax_transaction,
         Rowversion )
      VALUES (
         transaction_rec_.company,
         accounting_year_,
         decode(transaction_rec_.voucher_no, NULL, voucher_no_seq_, transaction_rec_.voucher_no),
         transaction_rec_.load_id,
         transaction_rec_.load_group_item,
         transaction_rec_.transaction_date,
         row_no_,
         transaction_rec_.voucher_type,   --Merged External Files
         transaction_rec_.codestring_rec.code_a,
         transaction_rec_.codestring_rec.code_b,
         transaction_rec_.codestring_rec.code_c,
         transaction_rec_.codestring_rec.code_d,
         transaction_rec_.codestring_rec.code_e,
         transaction_rec_.codestring_rec.code_f,
         transaction_rec_.codestring_rec.code_g,
         transaction_rec_.codestring_rec.code_h,
         transaction_rec_.codestring_rec.code_i,
         transaction_rec_.codestring_rec.code_j,
         currency_debet_amount_,
         currency_credit_amount_,
         debet_amount_,
         credit_amount_,
         transaction_rec_.third_currency_debit_amount,
         transaction_rec_.third_currency_credit_amount,
         --transaction_rec_.third_currency_amount,
         transaction_rec_.third_currency_tax_amount,
         transaction_rec_.currency_code,
         transaction_rec_.quantity,
         transaction_rec_.process_code,
         transaction_rec_.optional_code,
         transaction_rec_.tax_percentage,
         transaction_rec_.project_activity_id,
         transaction_rec_.text,
         transaction_rec_.party_type,
         transaction_rec_.party_type_id,
         trans_code_,
         transaction_rec_.reference_number,
         transaction_rec_.reference_serie,
         correction_,
         transaction_rec_.tax_direction,
         transaction_rec_.tax_amount,
         transaction_rec_.currency_tax_amount,
         transaction_rec_.tax_base_amount,
         transaction_rec_.currency_tax_base_amount,
         transaction_rec_.currency_rate,
         transaction_rec_.event_date,
         transaction_rec_.retroactive_date,
         transaction_rec_.transaction_reason,
         transaction_rec_.third_curr_tax_base_amount,
         transaction_rec_.deliv_type_id,
         transaction_rec_.record_no,
         reference_row_no_,
         transaction_rec_.currency_rate_type,
         transaction_rec_.parallel_curr_rate_type,
         NVL(transaction_rec_.tax_transaction, 'FALSE'),
         sysdate );
END Create_Voucher_Row__;


PROCEDURE Check_Transaction__ (
   info_       OUT VARCHAR2,
   company_    IN  VARCHAR2,
   load_id_    IN  VARCHAR2,
   check_proc_ IN  VARCHAR2 )
IS   
   err_msg_           VARCHAR2(2000);
   error_msg_         VARCHAR2(200);
   user_              VARCHAR2(30);
   load_type_         VARCHAR2(20);
   use_codestr_compl_ VARCHAR2(5);
   voucher_type_      VARCHAR2(3);   
   ext_group_by_item_ VARCHAR2(1);
   ext_vouch_extern_  VARCHAR2(1);
   ext_voucher_diff_  VARCHAR2(1);
   ext_voucher_date_  VARCHAR2(1);
   tem_val_code_      VARCHAR2(1);   
   dummy_             NUMBER;
   acc_year_          NUMBER;
   acc_period_        NUMBER;   
   load_date_         DATE;
   voucher_date_      DATE;   
   user_group_        user_group_member_finance_tab.user_group%type;
   transaction_rec_   Ext_Transactions_API.ExtTransRec;
   
   CURSOR GetLoadInfo IS
      SELECT voucher_type,
             userid,
             load_date,
             load_type
      FROM   ext_load_info_tab
      WHERE  company = company_
      AND    load_id = load_id_;
   
   CURSOR GetExtParam IS
      SELECT ext_group_item,
             ext_voucher_no_alloc,
             ext_voucher_diff,
             ext_voucher_date,
             validate_code_string,
             use_codestr_compl
      FROM   Ext_Parameters_Tab
      WHERE  company   = company_
      AND    load_type = load_type_;

   CURSOR getrec IS
      SELECT company,
             load_id,
             record_no,
             load_group_item,
             load_error,
             transaction_date,
             voucher_type,
             voucher_no,
             accounting_year,
             account,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j,
             currency_debet_amount,
             currency_credit_amount,
             currency_amount,                -- to support old version
             debet_amount,
             credit_amount,
             amount,                         -- to support old version
             third_currency_debit_amount,
             third_currency_credit_amount,
             third_currency_amount,
             third_currency_tax_amount,
             currency_code,
             quantity,
             process_code,
             optional_code,
             tax_percentage,
             project_activity_id,
             text,
             party_type,
             party_type_id,
             reference_number,
             reference_serie,
             trans_code,
             tax_direction,
             tax_amount,
             currency_tax_amount,
             user_group,
             modify_codestr_cmpl,
             event_date, 
             retroactive_date,
             transaction_reason,
             deliv_type_id,
             currency_rate_type,
             parallel_curr_rate_type
      FROM   Ext_Transactions
      WHERE  company  = company_
      AND    load_id  = load_id_
      AND    objstate = 'Loaded'
      ORDER BY load_group_item;   
    --Merged External Files
BEGIN
   -- when check is called from create proc.
   IF (check_proc_ = 'FALSE') THEN
      Ext_Transactions_API.Update_Transaction(company_,
                                              load_id_,
                                              'Checked',
                                              'Loaded');
   ELSE
      -- check for the load id first if it exists
      Ext_Load_Info_API.Exist(company_,
                              load_id_);
      Ext_Transactions_API.Exist(company_,
                                 load_id_);
   END IF;

   Ext_Transactions_API.Check_Found(dummy_,
                                    company_,
                                    load_id_,
                                    'Loaded' );
   IF (dummy_ = 0) THEN
      Ext_Transactions_API.Check_Found(dummy_,
                                       company_,
                                       load_id_,
                                       'Checked');
      IF (dummy_ = 1) THEN
         Error_SYS.Record_General(lu_name_, 'CHECKED_EXIST: Load ID :P1 is already in state Checked' ,load_id_);
      ELSE
         Error_SYS.Record_General(lu_name_, 'UPDATED_EXIST: Load ID :P1 is already in state Updated', load_id_);
      END IF;
   END IF;

   -- If only checked exists don't remove records
   Ext_Transactions_API.Check_Other_Found(dummy_,
                                          company_,
                                          load_id_,
                                          'Checked' );
   IF (dummy_ > 0) THEN
      --delete previous records
      DELETE
      FROM  Ext_Voucher_Tab
      WHERE company = company_
      AND   load_id = load_id_;

      DELETE
      FROM  Ext_Voucher_Row_Tab
      WHERE company = company_
      AND   load_id = load_id_;
   
      -- this is to clear the rowstate of checked transactions.
      UPDATE Ext_Transactions_Tab
      SET rowstate = 'Loaded'
      WHERE company = company_
      AND   load_id = load_id_
      AND   rowstate = 'Checked';      
   END IF;

   OPEN  GetLoadInfo;
   FETCH GetLoadInfo INTO voucher_type_,
                          user_,
                          load_date_,
                          load_type_;
   IF (GetLoadInfo%NOTFOUND) THEN
      CLOSE GetLoadInfo;
      Raise_Load_Not_Exist___(load_id_);      
   END IF;
   CLOSE GetLoadInfo;
   OPEN  GetExtParam;
   FETCH GetExtParam INTO ext_group_by_item_,
                          ext_vouch_extern_,
                          ext_voucher_diff_,
                          ext_voucher_date_,
                          tem_val_code_,
                          use_codestr_compl_;
   IF (GetExtParam%NOTFOUND) THEN
      CLOSE GetExtParam;
      Raise_Ext_Int_Par_Not___(company_, load_type_);      
   END IF;
   CLOSE GetExtParam;

   OPEN getrec;
   LOOP
      FETCH getrec
         INTO transaction_rec_.company,
              transaction_rec_.load_id,
              transaction_rec_.record_no,
              transaction_rec_.load_group_item,
              transaction_rec_.load_error,
              transaction_rec_.transaction_date,
              transaction_rec_.voucher_type,
              transaction_rec_.voucher_no,
              transaction_rec_.accounting_year,
              transaction_rec_.codestring_rec.code_a,
              transaction_rec_.codestring_rec.code_b,
              transaction_rec_.codestring_rec.code_c,
              transaction_rec_.codestring_rec.code_d,
              transaction_rec_.codestring_rec.code_e,
              transaction_rec_.codestring_rec.code_f,
              transaction_rec_.codestring_rec.code_g,
              transaction_rec_.codestring_rec.code_h,
              transaction_rec_.codestring_rec.code_i,
              transaction_rec_.codestring_rec.code_j,
              transaction_rec_.currency_debet_amount,
              transaction_rec_.currency_credit_amount,
              transaction_rec_.currency_amount,          -- to support old version
              transaction_rec_.debet_amount,
              transaction_rec_.credit_amount,
              transaction_rec_.amount,                   -- to support old version
              transaction_rec_.third_currency_debit_amount,
              transaction_rec_.third_currency_credit_amount,
              transaction_rec_.third_currency_amount,
              transaction_rec_.third_currency_tax_amount,
              transaction_rec_.currency_code,
              transaction_rec_.quantity,
              transaction_rec_.process_code,
              transaction_rec_.optional_code,
              transaction_rec_.tax_percentage,
              transaction_rec_.project_activity_id,
              transaction_rec_.text,
              transaction_rec_.party_type,
              transaction_rec_.party_type_id,
              transaction_rec_.reference_number,
              transaction_rec_.reference_serie,
              transaction_rec_.trans_code,
              transaction_rec_.tax_direction,
              transaction_rec_.tax_amount,
              transaction_rec_.currency_tax_amount,
              transaction_rec_.user_group,
              transaction_rec_.modify_codestr_cmpl,
              transaction_rec_.event_date,
              transaction_rec_.retroactive_date,
              transaction_rec_.transaction_reason,
              transaction_rec_.deliv_type_id,
              transaction_rec_.currency_rate_type,
              transaction_rec_.parallel_curr_rate_type;
      EXIT WHEN getrec%NOTFOUND;
      user_group_ := transaction_rec_.user_group;
      Check_User_Group___ (error_msg_, user_group_ );
      IF (ext_voucher_date_ = '1') THEN  --load date
         voucher_date_ := load_date_;
      ELSIF (ext_voucher_date_ = '2') THEN  --transaction date
         voucher_date_ := transaction_rec_.transaction_date;
      END IF;
      Accounting_Period_API.Get_Accounting_Year_Period_Ext(acc_year_,
                                                           acc_period_,
                                                           transaction_rec_.company,
                                                           user_group_,
                                                           voucher_date_);
      Validate_Transaction_Data__(err_msg_,
                                  voucher_type_,
                                  ext_vouch_extern_,
                                  ext_group_by_item_,
                                  ext_voucher_date_,
                                  load_date_,
                                  user_,
                                  user_group_,
                                  transaction_rec_,
                                  tem_val_code_,
                                  use_codestr_compl_);
      IF (error_msg_ IS NOT NULL) THEN
         err_msg_ := error_msg_;
      END IF;
      Ext_Transactions_API.Update_Load_Error(transaction_rec_.company,
                                             transaction_rec_.load_id,
                                             transaction_rec_.record_no,
                                             err_msg_);
      err_msg_ := '';
   END LOOP;
   CLOSE getrec;
-- (the grouping other grouping columns are always put in this column)
   Process_By_Load_Group_Item___(ext_group_by_item_,
                                 voucher_type_,
                                 ext_voucher_diff_,
                                 ext_voucher_date_,
                                 ext_vouch_extern_,
                                 load_date_,
                                 user_,
                                 company_,
                                 load_id_);

   err_msg_ := Ext_Transactions_API.Exist_Error(company_,
                                                load_id_);
   IF (err_msg_ = 'TRUE') THEN
      Ext_Load_Info_API.Update_Ext_Load_State(company_,
                                              load_id_,
                                              '4');

      -- Important- If a modification is required both error text below  should be modified(Both should be same)
      err_msg_ := 'ERRORINCHECK: Load ID :P1 is checked with errors'; 
      info_ := Language_SYS.Translate_Constant(lu_name_,'ERRORINCHECK: Load ID :P1 is checked with errors');
   ELSE
      Ext_Load_Info_API.Update_Ext_Load_State(company_,
                                              load_id_,
                                              '3');

      -- Important- If a modification is required both error text below  should be modified(Both should be same)
      err_msg_ := 'NOERRORCHECK: Load ID :P1 is checked without errors';
      info_ := Language_SYS.Translate_Constant(lu_name_,'NOERRORCHECK: Load ID :P1 is checked without errors');
   END IF;

   Client_SYS.Clear_Info;
   Client_SYS.Add_Info(lu_name_, err_msg_, load_id_);
   info_ := Client_SYS.Get_All_Info;
END Check_Transaction__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Check_Transaction (
   info_       OUT VARCHAR2,
   company_    IN  VARCHAR2,
   load_id_    IN  VARCHAR2,
   check_proc_ IN  VARCHAR2 )
IS
BEGIN
   Check_Transaction__(info_,
                       company_,
                       load_id_,
                       check_proc_);
END Check_Transaction;


PROCEDURE Check_Transaction (
   err_msg_          OUT VARCHAR2,
   transaction_rec_  IN  Ext_Transactions_API.ExtTransRec )
IS
   
   err_txt_           VARCHAR2(2000);
   user_              VARCHAR2(30);
   user_group_        VARCHAR2(30);
   load_type_         VARCHAR2(20);
   use_codestr_compl_ VARCHAR2(5);   
   voucher_type_      VARCHAR2(3);
   ext_group_by_item_ VARCHAR2(1);
   ext_vouch_extern_  VARCHAR2(1);
   ext_voucher_date_  VARCHAR2(1);
   tem_val_code_      VARCHAR2(1);
   
   accounting_year_   NUMBER;
   accounting_period_ NUMBER;
   
   voucher_date_      DATE;
   load_date_         DATE;
   
   CURSOR GetLoadInfo IS
      SELECT voucher_type,
             userid,
             load_date,
             load_type
      FROM   ext_load_info_tab
      WHERE  company = transaction_rec_.company
      AND    load_id = transaction_rec_.load_id;
   CURSOR GetExtParam IS
      SELECT ext_group_item,
             ext_voucher_no_alloc,
             ext_voucher_date,
             validate_code_string,
             use_codestr_compl
      FROM   Ext_Parameters_Tab
      WHERE  company   = transaction_rec_.company
      AND    load_type = load_type_;
BEGIN
   err_txt_ := '';
   OPEN  GetLoadInfo;
   FETCH GetLoadInfo INTO voucher_type_,
                          user_,
                          load_date_,
                          load_type_;
   IF (GetLoadInfo%NOTFOUND) THEN
      CLOSE GetLoadInfo;
      Raise_Load_Not_Exist___(transaction_rec_.load_id);      
   END IF;
   CLOSE GetLoadInfo;

   OPEN  GetExtParam;
   FETCH GetExtParam INTO ext_group_by_item_,
                          ext_vouch_extern_,
                          ext_voucher_date_,
                          tem_val_code_,
                          use_codestr_compl_;
   IF (GetExtParam%NOTFOUND) THEN
      CLOSE GetExtParam;
      Raise_Ext_Int_Par_Not___(transaction_rec_.company, load_type_);      
   END IF;
   CLOSE GetExtParam;

   -- find out the user group for the user
   user_group_ :=  transaction_rec_.user_group;
   IF (ext_voucher_date_ = '1') THEN  --load date
      voucher_date_ := load_date_;
   ELSIF (ext_voucher_date_ = '2') THEN  --transaction date
      voucher_date_ := transaction_rec_.transaction_date;
   END IF;
   Accounting_Period_API.Get_Accounting_Year_Period_Ext(accounting_year_,
                                                        accounting_period_,
                                                        transaction_rec_.company,
                                                        user_group_,
                                                        voucher_date_);   
   Validate_Transaction_Data__(err_txt_,
                               voucher_type_,
                               ext_vouch_extern_,
                               ext_group_by_item_,
                               ext_voucher_date_,
                               load_date_,
                               user_,
                               user_group_,
                               transaction_rec_,
                               tem_val_code_,
                               use_codestr_compl_);
   IF (err_txt_ IS NULL) THEN
      Validate_Voucher_Data__(err_txt_,
                              accounting_year_,
                              voucher_date_,
                              accounting_period_,
                              voucher_type_,
                              ext_voucher_date_,
                              ext_vouch_extern_,
                              load_date_,
                              user_,
                              user_group_,
                              transaction_rec_);
   END IF;
   err_msg_ := err_txt_;
EXCEPTION
   WHEN OTHERS THEN
      err_msg_ := SQLERRM;
END Check_Transaction;

   
 -- This method checks whether the parallel amounts in the file loaded are null or not. 
FUNCTION Is_Par_Amount_Null (
   load_file_id_        IN VARCHAR2,
   load_group_item_     IN VARCHAR2,
   load_group_value_    IN VARCHAR2) RETURN VARCHAR2
IS
   third_curr_null_           VARCHAR2(5) := 'FALSE';
   
   CURSOR get_ext_file_trans IS
      SELECT c.*
      FROM ext_load_info_tab a, Ext_Transactions_Tab b, Ext_File_Trans_Tab c
      WHERE a.company= b.company
      AND a.load_id = b.load_id
      AND a.load_file_id = load_file_id_
      AND c.load_file_id = a.load_file_id      
      AND c.row_no = b.record_no
      AND c.row_state = 3
      AND b.load_group_item = load_group_value_;
BEGIN
   FOR rec_ IN get_ext_file_trans LOOP  
      IF ((rec_.n10 IS NOT NULL) OR (rec_.n11 IS NOT NULL)OR (rec_.n15 IS NOT NULL)) THEN
         third_curr_null_ := 'TRUE'; 
      END IF;      
   END LOOP;
   RETURN third_curr_null_;
END Is_Par_Amount_Null;



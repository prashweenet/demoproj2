-----------------------------------------------------------------------------
--
--  Logical unit: PaymentTermDetails
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021029  LoKrLK  IID ITFI107E Installment Basic Data - New File Created 
--  021030  LoKrLK  IID ITFI107E Installment Basic Data - Made Payment_Method a Non Mandatory Field
--  021101  LoKrLK  IID ITFI107E Installment Basic Data - Added 3 new Functions Calc_Due_Date,
--  021101          Calc_Payment_Date,Calc_Disc_Base
--  021105  LoKrLK  IID ITFI107E Installment Basic Data - Modified View Comments
--  021105  LoKrLK  IID ITFI107E Installment Basic Data - Added a new parameter to Calc_Due_Date
--  021106  LoKrLK  IID ITFI107E Installment Basic Data - Modified Calc_Due_Date Function
--  021120  SamBLK  IID ITFI107E - added PAYMENT_TERM_DETAILS_ECT,PAYMENT_TERM_DETAILS_PCT,and relevent
--  021120          methods (Copy___,Import___, Export___,Make_Company)
--  021122  LoKrLK  IID ITFI107E Installment Basic Data - Modified Unpack_Check_Update and Unpack_Check_Insert
--  021206  LoKrLK  B91978 Modified Calc_Due_Date
--  030113  LoKrLK  B91978 Modified Calc_Due_Date
--  030214  LoKrLK  B92790 Modified Calc_Due_Date
--  030303  GaWiLK  IID ITFI108E - B94219. Added method Get_Installment_Count.
--  032503  TiUkLk  Moved Transaction_SYS.Package_Is_Installed() calls to the PRIVATE DECLARATIONS section
--  030424  LoKrLK  IID DEFI162N Modified the Primary Key. Added Day_From.
--  030424          Added Fileds Day_To and discount_specified
--  030428  TiUkLk  IID DEFI162N Modified views PAYMENT_TERM_DETAILS_ECT and PAYMENT_TERM_DETAILS_PCT
--  030430  LoKrLK  IID DEFI162N Modified Calc_Due_Date
--  030507  LoKrLK  IID DEFI162N Added Procedure Update_Net_Amount_Percentage
--  030509  LoKrLK  IID DEFI162N Added Procedure Reset_Global_Variables
--  030512  LoKrLK  IID DEFI162N Removed Procedure Reset_Global_Variables
--  030522  LoKrLK  IID DEFI162N Modified Get_Installment_Count
--  030529  LoKrLK  IID DEFI162N Added Null Coulumns as well to Create Company Methods
--  030605  TiUkLk  IID DEFI162N Added new method Regen_Installments()
--  030617  SAMBLK  IID DEFI162N Check Due Date calculation
--  030620  TiUkLk  IID DEFI162N Added new method Get_Installment_Item_Count()
--  030818  LoKrLK  Code Review.
--  030904  LoKrLK  DEFI162N Modified Export___
--
--  040615  sachlk  FIPR338A2: Unicode Changes.
--  040701  AnGiSe  B115589 Added validations in Unpack_Check_Update.
--  040702  AnGiSe  B115589 Added new method Check_Payment_Method and call to method from Unpack_Check_Insert 
--                  and Unpack_Check_Update.
--  040712  anpelk  B115738, Make the method call Check_Payment_Method dynamic.
--  041228  KaGalk  LCS Merge 48359
--  050422  reanpl  FIME232, merged UK changes (Added new method Validate_For_Contract for validations in SalesContract)
--  050705  KaGalk  LCS Merge 50820
--  060110  Maaylk  B130598 Changed the way of calculating the Due_Date()
--  061013  SuSalk  LCS Merge 59330, Modified method Calc_Due_Date().
--  070522  Vohelk  B143136 Removed validation for Days to Due Date on Unpack_Check_Update___
--  100226  Nirplk  Bug 88617, Corrected, Modified function Calc_Due_Date().
--  100907  Kanslk  Bug 89933, Modified Calc_Due_Date().
--  100928  Machlk  Added institute_id
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110829  Mohrlk  FIDEAGLE-1390, Merged Bug 98417, Modified Calc_Due_Date().
--  120727  Nirplk  Bug 104154, Corrected in Calc_Due_Date().
--  121204  Maaylk  PEPA-183, Removed global variable
--  140905  DipeLK  PRFI-2155,Wrong event date for PO receipts in cash flow
--  151203  chiblk  STRFI-682,removing sub methods and rewriting them as implementation methods
--  181823  Nudilk  Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('FREE_DELIVERY_MONTHS', 0 , attr_);
   Client_SYS.Add_To_Attr('END_OF_MONTH', 'FALSE' , attr_);
   Client_SYS.Add_To_Attr('DISCOUNT_SPECIFIED', 'FALSE' , attr_);
   -- gelr:it_payment_formats, begin
   Client_SYS.Add_To_Attr('COLLECTIVE_RIBA', 'FALSE', attr_);
   -- gelr:it_payment_formats, end
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT payment_term_details_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   vat_dist_db_   VARCHAR2(20);
BEGIN
   IF (newrec_.free_delivery_months IS NULL) THEN
      newrec_.free_delivery_months := 0;
   END IF;  
   vat_dist_db_ := Payment_Term_API.Get_Vat_Distribution_Db(newrec_.company, newrec_.pay_term_id);
   IF ((vat_dist_db_) = 'FIRSTINSTONLYTAX') THEN
      IF ((newrec_.installment_number = 1)  AND (newrec_.net_amount_percentage != 0)) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORNETAMTZERO: The Net Amount Percentage for the first Installment must be zero!');
      END IF;
   END IF;   
   super(newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'DAY_FROM', newrec_.day_from);
   IF (newrec_.day_from != 1) THEN
      newrec_.net_amount_percentage := Get_Net_Amount_Percentage(newrec_.company,
                                                                 newrec_.pay_term_id,
                                                                 newrec_.installment_number);
   END IF;
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     payment_term_details_tab%ROWTYPE,
   newrec_ IN OUT payment_term_details_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF indrec_.day_from THEN
      IF newrec_.day_from = 1 THEN
         Update_Net_Amount_Percentage(newrec_.company,
                                      newrec_.pay_term_id,
                                      newrec_.installment_number,
                                      newrec_.net_amount_percentage);
      END IF;
   END IF;
END Check_Update___;

@Override 
PROCEDURE Check_Common___ (
   oldrec_ IN     payment_term_details_tab%ROWTYPE,
   newrec_ IN OUT payment_term_details_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   vat_dist_db_   VARCHAR2(30);
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   vat_dist_db_ := Payment_Term_API.Get_Vat_Distribution_Db( newrec_.company, newrec_.pay_term_id );

   IF (newrec_.net_amount_percentage = 0 AND vat_dist_db_ != 'FIRSTINSTONLYTAX') THEN     
      IF (Get_Installment_Count(newrec_.company, newrec_.pay_term_id) > 1) THEN         
         Error_SYS.Appl_General(lu_name_, 'ZERONETAMOUNT: Cannot enter zero to the Net Amount Percentage.');
      END IF;
   END IF;
   Validate_Days_To_Due_Date___(newrec_.days_to_due_date);
   Validate_Del_Month___(newrec_.free_delivery_months);
   Validate_Day_To___(newrec_.day_to, newrec_.day_from);
   IF ((newrec_.due_date1 < 0 OR newrec_.due_date1  > 31) OR (newrec_.due_date2  < 0 OR newrec_.due_date2  > 31) OR (newrec_.due_date3  < 0 OR newrec_.due_date3  > 31) ) THEN 
      Validate_Specific_Due_Date___();
   END IF;
   IF (newrec_.due_date1 IS NULL) THEN
      IF (indrec_.due_date2 AND newrec_.due_date2 IS NOT NULL) THEN 
         Error_SYS.Record_General(lu_name_, 'VALDUEDATECHK: The field Specific Due Day 1 must be entered before entering the field Specific Due Day 2 !');
      END IF;
   END IF;
   IF (newrec_.due_date1 IS NULL OR newrec_.due_date2 IS NULL) THEN
      IF (indrec_.due_date3 ) THEN 
         IF (newrec_.due_date3 IS NOT NULL) THEN 
            Error_SYS.Record_General(lu_name_, 'VALDUEDATECHECK: The fields Specific Due Day 1 and 2 must be entered before entering the field Specific Due Day 3 !');
         END IF;
      END IF;
   END IF;
   IF ((vat_dist_db_) = 'FIRSTINSTONLYTAX') THEN
      IF ((newrec_.installment_number = 1)  AND (newrec_.net_amount_percentage != 0)) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORNETAMTZERO: The Net Amount Percentage for the first Installment must be zero!');
      END IF;
   END IF;
   Check_Net_Percentage___(newrec_.company, newrec_.pay_term_id, newrec_.day_from, newrec_.net_amount_percentage);  
   -- gelr:it_payment_formats, begin
   IF (newrec_.collective_riba IS NULL) THEN
      newrec_.collective_riba := 'FALSE';
   END IF;
   -- gelr:it_payment_formats, end
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_      IN payment_term_details_tab%ROWTYPE )
IS
   vat_dist_db_    VARCHAR2(20);
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   vat_dist_db_ := Payment_Term_API.Get_Vat_Distribution_Db(remrec_.company, remrec_.pay_term_id);
   IF ((vat_dist_db_) = 'FIRSTINSTONLYTAX') THEN
      IF ((remrec_.installment_number = 1)  AND (remrec_.net_amount_percentage = 0)) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORNETAMTZERO: The Net Amount Percentage for the first Installment must be zero!');
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN payment_term_details_tab%ROWTYPE )
IS
BEGIN
   Error_SYS.Record_General(lu_name_,'NOTINSEQUENCE: Sequence should be defined in a consecutive order starting from 1.');
   super(rec_);
END Raise_Record_Exist___; 


FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___; 

PROCEDURE Sum_Net_Amount___(
   sum_net_amount_percentage_ IN OUT NUMBER,
   tot_rem_                   IN OUT NUMBER,
   net_amount_percentage_     IN OUT NUMBER,
   rem_                       IN NUMBER,
   count_inst_                IN NUMBER,
   inst_num_                  IN NUMBER )
IS  
BEGIN
   IF (count_inst_ = inst_num_) THEN 
      net_amount_percentage_     := 100 - sum_net_amount_percentage_;
   ELSIF (tot_rem_ > 0.01) THEN
      net_amount_percentage_     := net_amount_percentage_ + 0.01;
      tot_rem_        := tot_rem_ - 0.01 + rem_;
      sum_net_amount_percentage_ := sum_net_amount_percentage_ + net_amount_percentage_;
   ELSE 
      sum_net_amount_percentage_ := sum_net_amount_percentage_ + net_amount_percentage_;
      tot_rem_        := tot_rem_ + rem_;
   END IF;   
END Sum_Net_Amount___;


PROCEDURE Validate_Days_To_Due_Date___(
   days_to_due_date_   IN NUMBER)
IS
BEGIN
   IF (days_to_due_date_ IS NOT NULL) THEN
      IF (days_to_due_date_ < 0) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORDAYSTODUE: The field Days to Due Date cannot be negative !');
      END IF;
   END IF;
END Validate_Days_To_Due_Date___;


PROCEDURE Validate_Free_Deliv_Months___(
   free_delivery_months_ IN NUMBER)
IS
BEGIN
   IF (free_delivery_months_ IS NOT NULL) THEN
      IF (free_delivery_months_ < 0) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORFREEDELMONTH: The field No of Free Deliv. Months must be greater than or equal to zero !');
      END IF;
   END IF;
END Validate_Free_Deliv_Months___;


PROCEDURE Validate_Specific_Due_Day___(
   due_day_   IN NUMBER)
IS
BEGIN
   IF (due_day_ IS NOT NULL) THEN
      IF (due_day_ < 1 OR due_day_ > 31) THEN 
         Validate_Specific_Due_Date___();
      END IF;   
   END IF;
END Validate_Specific_Due_Day___;

PROCEDURE Validate_Specific_Due_Date___
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'ERRORSPECDUEDATE: The Specific Due Day should be between 1 and 31 !');
END Validate_Specific_Due_Date___;

PROCEDURE Validate_No_Of_Installments___(
   company_             IN VARCHAR2,
   pay_term_id_         IN VARCHAR2,
   no_of_installments_  IN NUMBER)
IS
BEGIN
   IF ((NVL(no_of_installments_,0) < 2) AND (Payment_term_API.Get_Vat_Distribution_Db(company_, pay_term_id_) = 'FIRSTINSTONLYTAX')) THEN            
      Error_SYS.Record_General(lu_name_, 'ERRORNOINST: The field Number of Installments must be > 1 !');
   ELSIF (NVL(no_of_installments_,0) < 1) THEN 
      Error_SYS.Record_General(lu_name_, 'ERRORCHECKNOINST: The field Number of Installments must be > 0 !');
   END IF;   
END Validate_No_Of_Installments___; 

PROCEDURE Validate_Del_Month___(
   free_delivery_months_  IN NUMBER)
IS
BEGIN
   IF (free_delivery_months_ IS NOT NULL) THEN
      IF (free_delivery_months_ < 0) THEN 
         Error_SYS.Record_General(lu_name_, 'INVALFREEDELM: The field No of Free Delivery Months cannot be negative !');
      END IF;
   END IF;   
END Validate_Del_Month___;  

PROCEDURE Validate_Day_To___(
   day_to_     IN NUMBER,
   day_from_   IN NUMBER)
IS
BEGIN   
   IF (day_to_ IS NOT NULL) THEN
      IF ((day_to_ < 2) or (day_to_ > 31) or (day_to_ = 30) or (day_to_ <= day_from_)) THEN 
         Error_SYS.Record_General(lu_name_, 'VALDUEDAYTO: Value for Day To field is invalid !');
      END IF;
   END IF;   
END Validate_Day_To___;


PROCEDURE Check_Net_Percentage___(
   company_               IN VARCHAR2,
   pay_term_id_           IN VARCHAR2, 
   day_from_              IN NUMBER,
   net_amount_percentage_ IN NUMBER)
IS
   vat_dist_db_   VARCHAR2(30);
BEGIN
   vat_dist_db_ := Payment_Term_API.Get_Vat_Distribution_Db(company_, pay_term_id_);
   IF (day_from_ = 1 AND net_amount_percentage_ IS NULL) THEN 
      Error_SYS.Record_General(lu_name_, 'ERRORNETPERCENT: Net Amount Percentage Cannot be NULL !'); 
   END IF;      
   IF ((net_amount_percentage_ <= 0 AND day_from_ = 1) AND (vat_dist_db_ != 'FIRSTINSTONLYTAX') ) THEN 
      Error_SYS.Record_General(lu_name_, 'VALNETAMOUNT: The field Net Amount Percentage must be >= 0 !');
   END IF;   
END Check_Net_Percentage___;

FUNCTION Get_Min_Inst_Num (
   installment_num_     IN NUMBER ) RETURN NUMBER
IS 
   temp_    NUMBER := 999;
BEGIN
   IF (installment_num_ < temp_ ) THEN 
      temp_ := installment_num_;
      RETURN temp_;
   END IF;
END Get_Min_Inst_Num;

PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   pay_term_id_list_    IN  VARCHAR2,
   installment_no_list_ IN  VARCHAR2,      
   day_from_list_       IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   log_id_              IN  NUMBER,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         payment_term_details_tab.company%TYPE;
   TYPE payment_term_details IS TABLE OF payment_term_details_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                        
   ref_payment_term_       payment_term_details;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;
   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pay_term_id_list_) LOOP
      ref_payment_term_(i_).pay_term_id:= value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, installment_no_list_) LOOP
      ref_payment_term_(i_).installment_number:= Client_SYS.Attr_Value_To_Number(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, day_from_list_) LOOP
      ref_payment_term_(i_).day_from:= Client_SYS.Attr_Value_To_Number(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP    
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_payment_term_.FIRST..ref_payment_term_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;     
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_payment_term_(j_).pay_term_id,   
                                 ref_payment_term_(j_).installment_number,
                                 ref_payment_term_(j_).day_from,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

PROCEDURE Validate_Installment_Id___(
   installment_no_        IN NUMBER,
   day_from_              IN NUMBER,
   dummy_installment_num_ IN NUMBER)
IS 
BEGIN
   IF (installment_no_ IS NOT NULL) THEN 
      IF ((day_from_ != 1) AND  (dummy_installment_num_ != installment_no_)) THEN 
         Error_SYS.Record_General(lu_name_, 'VALINSTALLERROR: Installment has invalid range of values for period.');
      END IF;
   END IF;   
END Validate_Installment_Id___;

@DynamicComponentDependency PAYLED
PROCEDURE Check_Way_Id_Ref___ (
   newrec_ IN OUT NOCOPY payment_term_details_tab%ROWTYPE )
IS
   
BEGIN
   Payment_Way_API.Exist(newrec_.company, newrec_.payment_method);
   
   IF (Payment_Term_API.Get_Block_For_Direct_Debiting(newrec_.company, newrec_.pay_term_id) = 'TRUE' 
      AND Payment_Way_API.Is_Way_Id_Allowed(newrec_.company, newrec_.payment_method, 'DIRECTDEBITING')= 'TRUE') THEN
      Error_SYS.Appl_General(lu_name_, 'PAYMETHODERR: Payment method :P1 not allowed as payment term is blocked for direct debiting.', newrec_.payment_method);
   END IF;  
END Check_Way_Id_Ref___;

@DynamicComponentDependency PAYLED
PROCEDURE Check_Institute_Id_Ref___ (
   newrec_ IN OUT NOCOPY payment_term_details_tab%ROWTYPE )
IS
   
BEGIN  
   Payment_Institute_API.Exist(newrec_.company, newrec_.institute_id);         
         
   IF (newrec_.payment_method IS NOT NULL AND newrec_.institute_id IS NOT NULL) THEN      
      Payment_Way_Per_Institute_API.New_Exist(newrec_.company, newrec_.institute_id, newrec_.payment_method);
   END IF;   
END Check_Institute_Id_Ref___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_      IN VARCHAR2,
   target_company_      IN VARCHAR2,
   pay_term_id_         IN VARCHAR2,
   installment_no_      IN NUMBER,
   day_from_            IN NUMBER,
   update_method_       IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              payment_term_details_tab%ROWTYPE;
   target_rec_              payment_term_details_tab%ROWTYPE;
   old_target_rec_          payment_term_details_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, pay_term_id_, installment_no_, day_from_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, pay_term_id_, installment_no_, day_from_);
   log_key_ := pay_term_id_ ||'^'|| installment_no_ ||'^'|| day_from_;

   IF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source creates a new record which does not exist in the target company
      New___(target_rec_);
      log_detail_status_ := 'CREATED';
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'UPDATE_ALL') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user wants to update the entire record in the target
      target_rec_.rowkey := old_target_rec_.rowkey;
      Modify___(target_rec_);
      log_detail_status_ := 'MODIFIED';     
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NOT NULL) THEN
      -- Source removes a record, the same record is removed in the target company
      Remove___(old_target_rec_);      
      log_detail_status_ := 'REMOVED';      
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source removes a record, the same record does not exist in the target company to be removed
      Raise_Record_Not_Exist___(target_company_, pay_term_id_, installment_no_, day_from_);
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'NO_UPDATE') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user does not wan to update records in the target
      Raise_Record_Exist___(target_rec_);
   END IF;
   IF (Company_Basic_Data_Window_API.Check_Copy_From_Source_Company(target_company_,source_company_, lu_name_)) THEN
      IF log_detail_status_ IN ('CREATED','MODIFIED') THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      ELSIF log_detail_status_ = 'REMOVED' THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
 
PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                 NUMBER;
   name_                VARCHAR2(200);
   value_               VARCHAR2(32000);
   company_             VARCHAR2(100);
   pay_term_id_list_    VARCHAR2(32000);
   target_company_list_ VARCHAR2(32000);
   installment_no_list_ VARCHAR2(32000);
   day_from_list_       VARCHAR2(32000);
   update_method_list_  VARCHAR2(32000);
   copy_type_           VARCHAR2(100);
   attr1_               VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'PAY_TERM_ID_LIST') THEN
         pay_term_id_list_ := value_;
      ELSIF (name_ = 'INSTALLMENT_NUMBER_LIST') THEN
         installment_no_list_ := value_;
      ELSIF (name_ = 'DAY_FROM_LIST') THEN
         day_from_list_ := value_;         
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(company_,
                      target_company_list_,
                      pay_term_id_list_,
                      installment_no_list_,
                      day_from_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_      IN VARCHAR2,
   target_company_list_ IN VARCHAR2,
   pay_term_id_list_    IN VARCHAR2,
   installment_no_list_ IN VARCHAR2,
   day_from_list_       IN VARCHAR2,
   update_method_list_  IN VARCHAR2,
   copy_type_           IN VARCHAR2,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         payment_term_details_tab.company%TYPE;
   TYPE payment_term_details IS TABLE OF payment_term_details_tab%ROWTYPE 
                           INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                           INDEX BY BINARY_INTEGER;                        
   ref_payment_term_details_ payment_term_details;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pay_term_id_list_) LOOP
      ref_payment_term_details_(i_).pay_term_id := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, installment_no_list_) LOOP
      ref_payment_term_details_(i_).installment_number := Client_SYS.Attr_Value_To_Number(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, day_from_list_) LOOP
      ref_payment_term_details_(i_).day_from := Client_SYS.Attr_Value_To_Number(value_);
      i_ := i_ + 1;
   END LOOP;   
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Create_New_Record(log_id_, source_company_, copy_type_,lu_name_);
   END IF;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_payment_term_details_.FIRST..ref_payment_term_details_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_payment_term_details_(j_).pay_term_id,
                                 ref_payment_term_details_(j_).installment_number,
                                 ref_payment_term_details_(j_).day_from,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Update_Status(log_id_);
   END IF;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Free_Delivery_Months_Range (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.free_delivery_months%TYPE;
   CURSOR get_attr IS
      SELECT free_delivery_months
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Free_Delivery_Months_Range ;


@UncheckedAccess
FUNCTION Get_Days_To_Due_Date_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.days_to_due_date%TYPE;
   CURSOR get_attr IS
      SELECT days_to_due_date
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Days_To_Due_Date_Range ;


@UncheckedAccess
FUNCTION Get_End_Of_Month_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.end_of_month%TYPE;
   CURSOR get_attr IS
      SELECT end_of_month
      FROM  PAYMENT_TERM_DETAILS_TAB
      WHERE company            = company_
      AND   pay_term_id        = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_End_Of_Month_Range ;


@UncheckedAccess
FUNCTION Get_Due_Date1_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.due_date1%TYPE;
   CURSOR get_attr IS
      SELECT due_date1
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Due_Date1_Range ;


@UncheckedAccess
FUNCTION Get_Due_Date2_Range (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.due_date2%TYPE;
   CURSOR get_attr IS
      SELECT due_date2
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Due_Date2_Range ;


@UncheckedAccess
FUNCTION Get_Due_Date3_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.due_date3%TYPE;
   CURSOR get_attr IS
      SELECT due_date3
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Due_Date3_Range ;


@UncheckedAccess
FUNCTION Get_Payment_Method (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.payment_method%TYPE;
   CURSOR get_attr IS
      SELECT payment_method
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Payment_Method;


@UncheckedAccess
FUNCTION Get_Institute_Id_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.institute_id%TYPE;
   CURSOR get_attr IS
      SELECT institute_id
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Institute_Id_Range ;


@UncheckedAccess
FUNCTION Get_Day_To_Range  (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.day_to%TYPE;
   CURSOR get_attr IS
      SELECT day_to
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Day_To_Range ;


@UncheckedAccess
FUNCTION Get_Discount_Specified_Range (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.discount_specified%TYPE;
   CURSOR get_attr IS
      SELECT discount_specified
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from_ BETWEEN day_from AND day_to;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Discount_Specified_Range ;


@UncheckedAccess
FUNCTION Calc_Due_Date (
   company_             IN VARCHAR2,
   pay_term_id_         IN VARCHAR2,
   installment_number_  IN NUMBER,
   invoice_date_        IN DATE,
   identity_            IN VARCHAR2 DEFAULT NULL,
   party_type_db_       IN VARCHAR2 DEFAULT NULL,
   payment_method_      IN VARCHAR2 DEFAULT NULL ) RETURN DATE
IS
   lu_rec_            PAYMENT_TERM_DETAILS_TAB%ROWTYPE;
   commercial_year_   VARCHAR2(10);
   last_month_no_     NUMBER;
   tmp_date_          DATE;
   due_date_          DATE;
   specific_date_     DATE;
   specific_day_      VARCHAR2(2);
   specific_day_no_   NUMBER;
   due_date_to_return_ DATE;

   due_date1_    NUMBER;
   due_date2_    NUMBER;
   due_date3_    NUMBER;
   payment_way_  VARCHAR2(20);
   days_to_due_  NUMBER;
   to_end_of_month_ NUMBER;
   final_date_      NUMBER;
   temp_date_no_    NUMBER;
BEGIN

   lu_rec_   := Get_Object_By_Keys___(company_,
                                      pay_term_id_,
                                      installment_number_,
                                      Get_Day_From(company_,pay_term_id_,installment_number_,to_number(to_char(invoice_date_,'DD'))));
   due_date_ := TRUNC(invoice_date_);


   IF payment_method_ IS NULL THEN
      payment_way_ := lu_rec_.payment_method;
   ELSE
      payment_way_ := payment_method_;
   END IF;

   IF (lu_rec_.free_delivery_months > 0) THEN
      tmp_date_  := (Add_Months(due_date_, lu_rec_.free_delivery_months - 1));
      due_date_  := (Last_Day(tmp_date_));
   END IF;

   -- Calculation Commercial Year New SALSA Code

   commercial_year_ := Payment_Term_API.Get_Use_Commercial_Year (company_,pay_term_id_);

   IF (commercial_year_ = 'TRUE') AND (lu_rec_.days_to_due_date > 0 )THEN
      IF to_char(due_date_, 'DD') = '31' THEN
         due_date_ := due_date_ - 1;
      END IF;

      IF ((to_char(due_date_, 'MM') = '02') AND (lu_rec_.free_delivery_months > 0)) THEN
         IF to_char(due_date_, 'DD') = '29' THEN
            days_to_due_ := lu_rec_.days_to_due_date + 1;
         ELSIF to_char(due_date_, 'DD') = '28' THEN
            days_to_due_ := lu_rec_.days_to_due_date + 2;   
         END IF;
      ELSE
         days_to_due_ := lu_rec_.days_to_due_date;
      END IF;  

      WHILE days_to_due_ > 0 LOOP
         -- calculate how much days are left in 30 days month
         to_end_of_month_ := 30 - to_number(to_char(due_date_, 'DD'));

         IF days_to_due_ > to_end_of_month_ THEN
            -- the 30 days month is not enough, take first day in next month
            due_date_    := Last_Day(due_date_) + 1;
            -- and substact days left to the end of 30 days month and 1 day
            days_to_due_ := days_to_due_ - to_end_of_month_ - 1;
         ELSE
            -- the 30 days month would be enough
            -- so add the days to due, but not go later than current calendar month
            due_date_    := least(due_date_ + days_to_due_, Last_Day(due_date_));
            days_to_due_ := 0;
         END IF;
      END LOOP;
   ELSE
      due_date_ := (due_date_ + NVL(lu_rec_.days_to_due_date,0));
   END IF;

   -- Commercial Year Calculation Ends

   due_date_to_return_ := NULL;

   IF (lu_rec_.end_of_month) = 'TRUE' AND (commercial_year_ = 'FALSE')   THEN
      due_date_ := (Last_Day(due_date_));
   ELSIF  (lu_rec_.end_of_month) = 'TRUE' AND (commercial_year_ = 'TRUE') THEN
          IF (lu_rec_.days_to_due_date > 0 ) OR (lu_rec_.days_to_due_date = 0   AND due_date_ !=Last_Day(due_date_)) OR lu_rec_.free_delivery_months > 0 THEN
              last_month_no_ :=  to_number(to_char(Last_Day(due_date_),'DD'));
              IF (last_month_no_ > 30) THEN
                  due_date_ := (Last_Day(due_date_)) - 1;
              ELSE
                  due_date_ := (Last_Day(due_date_));
              END IF;
          END IF;
   END IF;

   IF ((lu_rec_.due_date1 IS NOT NULL) AND (lu_rec_.due_date2 IS NULL) AND (lu_rec_.due_date3 IS NULL)) THEN
      
      due_date1_ := lu_rec_.due_date1;
      specific_date_ := trunc(due_date_, 'MM') + (due_date1_ - 1);
      IF ((specific_date_ < due_date_) OR
          ((specific_date_ = due_date_) AND (lu_rec_.free_delivery_months >0))) THEN 
         specific_date_ := (Add_Months(specific_date_,1));
      END IF;      
   ELSIF ((lu_rec_.due_date1 IS NOT NULL) AND (lu_rec_.due_date2 IS NOT NULL) AND (lu_rec_.due_date3 IS NULL)) THEN
-- Sorting specific due date
      IF (lu_rec_.due_date1 < lu_rec_.due_date2) THEN
         due_date1_ := lu_rec_.due_date1;
         due_date2_ := lu_rec_.due_date2;
      ELSE
         due_date1_ := lu_rec_.due_date2;
         due_date2_ := lu_rec_.due_date1;
      END IF;
-- now due_date1_ < due_date2_

      specific_day_    := substr(to_char(due_date_,'DDMMYY'),1,2);
      specific_day_no_ := to_number(specific_day_);
      temp_date_no_ := 100; -- temp_date_no_ set to 100 as it is greater than any value of the day of a month ( 31 is the maximum a day can get for its value)
      IF (due_date1_ >= specific_day_no_) THEN
         temp_date_no_ := due_date1_;
      END IF;

      IF (due_date2_ >= specific_day_no_) THEN
         IF (temp_date_no_ > due_date2_) THEN
            temp_date_no_ := due_date2_;
         END IF;
      END IF;

      IF (temp_date_no_ = 100 ) THEN -- temp_date_no_ remains in 100 whenever specific_day_no_ is greater than , due_date1_, due_date2_, due_date3_
         to_end_of_month_ := to_number(to_char(Last_Day(due_date_), 'DD')) - to_number(to_char(due_date_, 'DD'));
         due_date_ := due_date_ + (to_end_of_month_ + 1);
         temp_date_no_ := due_date1_;
      END IF;

      specific_date_ := trunc(due_date_, 'MM') + (temp_date_no_ - 1);


   ELSIF ((lu_rec_.due_date1 IS NOT NULL) AND (lu_rec_.due_date2 IS NOT NULL) AND (lu_rec_.due_date3 IS NOT NULL)) THEN

      specific_day_    := substr(to_char(due_date_,'DDMMYY'),1,2);
      specific_day_no_ := to_number(specific_day_);
      
-- Sorting specific due date
      IF (lu_rec_.due_date1 < lu_rec_.due_date2) THEN
         due_date1_ := lu_rec_.due_date1;
         due_date3_ := lu_rec_.due_date2;
      ELSE
         due_date1_ := lu_rec_.due_date2;
         due_date3_ := lu_rec_.due_date1;
      END IF;
      IF (lu_rec_.due_Date3 < due_date1_) THEN
         due_date2_ := due_date1_;
         due_date1_ := lu_rec_.due_date3;
      ELSIF (lu_rec_.due_date3 > due_date3_) THEN
         due_date2_ := due_date3_;
         due_date3_ := lu_rec_.due_date3;
      ELSE
         due_date2_ := lu_rec_.due_date3;
      END IF;
-- now due_date1_ < due_date2_ < due_date3_

      temp_date_no_ := 100; -- temp_date_no_ set to 100 as it is greater than any value of the day of a month ( 31 is the maximum a day can get for its value)
      IF (due_date1_ >= specific_day_no_) THEN
         temp_date_no_ := due_date1_;
      END IF;

      IF (due_date2_ >= specific_day_no_) THEN
         IF (temp_date_no_ > due_date2_) THEN 
            temp_date_no_ := due_date2_;
         END IF;
      END IF;

      IF (due_date3_ >= specific_day_no_) THEN
         IF (temp_date_no_ > due_date3_) THEN 
            temp_date_no_ := due_date3_;
         END IF;
      END IF;

      IF (temp_date_no_ = 100 ) THEN -- temp_date_no_ remains in 100 whenever specific_day_no_ is greater than , due_date1_, due_date2_, due_date3_
         to_end_of_month_ := to_number(to_char(Last_Day(due_date_), 'DD')) - to_number(to_char(due_date_, 'DD'));
         due_date_ := due_date_ + (to_end_of_month_ + 1);
         temp_date_no_ := due_date1_;
      END IF;

      specific_date_ := trunc(due_date_, 'MM') + (temp_date_no_ - 1);
      due_date_to_return_ := specific_date_;
   ELSIF (lu_rec_.due_date1 IS NULL) THEN
      specific_date_ := due_date_;
   END IF;

   final_date_ := To_Number(Substr(To_Char(specific_date_, 'DD-MM-YYYY'),1,2));
   due_date_to_return_ := specific_date_;

   IF due_date_to_return_ < trunc(invoice_date_)
      OR (( due_date1_ IS NOT NULL AND due_date2_ IS NULL AND due_date3_ IS NULL)
         AND (final_date_ != due_date1_))
      OR (( due_date1_ IS NOT NULL AND due_date2_ IS NOT NULL AND due_date3_ IS NULL) 
         AND (final_date_ != due_date1_ AND final_date_ != due_date2_ ))
      OR (( due_date1_ IS NOT NULL AND due_date2_ IS NOT NULL AND due_date3_ IS NOT NULL) 
         AND (final_date_ != due_date1_ AND final_date_ != due_date2_ AND final_date_ != due_date3_)) THEN
         
      IF (due_date1_ IS NULL) THEN
         specific_date_ := Add_Months(Trunc(due_date_, 'MM'),1);
      ELSE
         specific_date_ := Add_Months(Trunc(due_date_, 'MM'),1) + (due_date1_ - 1);
      END IF;
         
      due_date_to_return_ :=  specific_date_;
   END IF;

   IF ((party_type_db_ = 'CUSTOMER' ) AND (Payment_Term_API.Get_Consider_Pay_Vac_Period (company_,pay_term_id_)='TRUE')) THEN
      RETURN Payment_Vacation_Period_API.Get_New_Vac_Due_Date(company_,payment_way_,identity_,due_date_to_return_);
   ELSE
      RETURN due_date_to_return_;
   END IF;

END Calc_Due_Date;


@UncheckedAccess
FUNCTION Calc_Disc_Base (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER,
   invoice_date_ IN DATE ) RETURN DATE
IS
   no_free_deliv_month_ NUMBER;
BEGIN

   no_free_deliv_month_ := Get_Free_Delivery_Months_Range(company_,
                                                          pay_term_id_,
                                                          installment_number_,
                                                          to_number(to_char(invoice_date_,'DD')));
   IF (no_free_deliv_month_ > 0 ) THEN
       RETURN (Last_Day(Add_Months(invoice_date_, no_free_deliv_month_ - 1)));
   ELSE
       RETURN (invoice_date_);
   END IF;
END Calc_Disc_Base;


@UncheckedAccess
FUNCTION Get_Installment_Count (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   count_ PAYMENT_TERM_DETAILS_TAB.installment_number%TYPE;
   CURSOR get_count IS
      SELECT count(*)
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   day_from = 1;
BEGIN
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
   RETURN count_;
END Get_Installment_Count;


@UncheckedAccess
FUNCTION Get_Net_Amount_Percentage (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   installment_number_ IN NUMBER ) RETURN NUMBER
IS
   temp_ PAYMENT_TERM_DETAILS_TAB.net_amount_percentage%TYPE;
   CURSOR get_attr IS
      SELECT net_amount_percentage
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_;

BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Net_Amount_Percentage;


@UncheckedAccess
FUNCTION Get_Day_From (
   company_            IN VARCHAR2,
   pay_term_id_        IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_                IN NUMBER ) RETURN NUMBER
IS
   CURSOR curGetData IS
   SELECT day_from
     FROM payment_term_details_tab
    WHERE company = company_
      AND pay_term_id = pay_term_id_
      AND installment_number = installment_number_
      AND day_ BETWEEN day_from AND day_to ;

   n_return_value_ NUMBER;

BEGIN
   OPEN  curGetData;
   FETCH curGetData INTO n_return_value_;
   CLOSE curGetData;

   RETURN n_return_value_;

END Get_Day_From;


PROCEDURE Update_Net_Amount_Percentage (
   company_               IN VARCHAR2,
   pay_term_id_           IN VARCHAR2,
   installment_number_    IN NUMBER,
   net_amount_percentage_ IN NUMBER )
IS

   CURSOR get_Value IS
   SELECT  day_from
     FROM  PAYMENT_TERM_DETAILS_TAB
    WHERE  company = company_
      AND  pay_term_id = pay_term_id_
      AND  installment_number = installment_number_
      AND  day_from !=1;

   objid_        VARCHAR2(80);
   objversion_   VARCHAR2(2000);
   attr_         VARCHAR2(2000);
   info_         VARCHAR2(2000);

BEGIN
   FOR rec_ IN  get_Value LOOP
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr( 'NET_AMOUNT_PERCENTAGE', net_amount_percentage_, attr_ );
      Get_Id_Version_By_Keys___ (objid_, objversion_, company_, pay_term_id_, installment_number_,rec_.day_from);
      Modify__(info_, objid_, objversion_, attr_, 'DO');
   END LOOP;

END Update_Net_Amount_Percentage;


@UncheckedAccess
FUNCTION Get_Installment_Item_Count (
   company_            IN VARCHAR2,
   pay_term_id_        IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_           IN NUMBER ) RETURN NUMBER
IS
   count_       NUMBER;
   count_inst_  NUMBER;
   CURSOR get_count IS
      SELECT count(*)
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number < installment_number_;

   CURSOR get_count_inst IS
      SELECT count(*)
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   installment_number = installment_number_
      AND   day_from <= day_from_;
BEGIN
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;

   OPEN get_count_inst;
   FETCH get_count_inst INTO count_inst_;
   CLOSE get_count_inst;

   RETURN count_ + count_inst_;   
END Get_Installment_Item_Count;

PROCEDURE Regen_Installments (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2 )
IS
   installment_id_ NUMBER:=1;
   CURSOR get_row IS
      SELECT installment_number, day_from
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      ORDER BY installment_number;
BEGIN
   FOR row_ IN get_row LOOP
      IF (row_.day_from = 1) THEN
         IF (row_.installment_number<>installment_id_) THEN            
         UPDATE PAYMENT_TERM_DETAILS_TAB
            SET installment_number = installment_id_
          WHERE company = company_
            AND pay_term_id = pay_term_id_
            AND installment_number = row_.installment_number;
       END IF;
         installment_id_ := installment_id_ + 1;
      END IF;
   END LOOP;
END Regen_Installments;


@UncheckedAccess
FUNCTION Validate_For_Contract (
   company_          IN VARCHAR2,
   pay_term_id_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   installment_count_    NUMBER;
   validation_           VARCHAR2(5):='FALSE';
   discount_specified_   VARCHAR2(5);
   CURSOR get_disc IS
      SELECT nvl(discount_specified, 'FALSE')
      FROM PAYMENT_TERM_DETAILS_TAB
      WHERE company = company_
      AND   pay_term_id = pay_term_id_
      AND   day_from = 1;

BEGIN
   -- check if there are any details defined
   installment_count_ := Get_Installment_Count(company_, pay_term_id_);

   IF (installment_count_ = 1) THEN
      -- fetch the discount_specified
      OPEN  get_disc;
      FETCH get_disc INTO discount_specified_;
      CLOSE get_disc;
      IF (discount_specified_ = 'FALSE') THEN
         validation_ := 'TRUE';
      END IF;
   END IF;
   RETURN validation_;
END Validate_For_Contract;


PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                 NUMBER;
   name_                VARCHAR2(200);
   value_               VARCHAR2(32000);
   source_company_      VARCHAR2(100);
   pay_term_id_list_    VARCHAR2(2000);
   installment_no_list_ VARCHAR2(2000);  
   day_from_list_       VARCHAR2(2000);
   target_company_list_ VARCHAR2(2000);
   update_method_list_  VARCHAR2(2000);
   attr1_               VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Payment_Term_Details_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'PAY_TERM_ID_LIST') THEN
            pay_term_id_list_ := value_;
            ELSIF (name_ = 'INSTALLMENT_NUMBER_LIST') THEN
            installment_no_list_ := value_;
         ELSIF (name_ = 'DAY_FROM_LIST') THEN
            day_from_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  pay_term_id_list_,
                                  installment_no_list_,
                                  day_from_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

FUNCTION Installment_Exist(
   company_      IN VARCHAR2,
   pay_term_id_  IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   CURSOR check_exist IS
      SELECT 1
      FROM   payment_term_details_tab
      WHERE  company = company_
      AND    pay_term_id = pay_term_id_;
BEGIN
   OPEN check_exist;
   FETCH check_exist INTO dummy_;
   IF check_exist%FOUND THEN
      CLOSE check_exist;
      RETURN 'TRUE';
   ELSE
      CLOSE check_exist;
      RETURN 'FALSE';
   END IF;   
   RETURN NULL;
END Installment_Exist;


FUNCTION Get_Total_Percentage(
   company_     IN VARCHAR2,
   pay_term_id_ IN VARCHAR2) RETURN NUMBER
IS
   temp_   payment_term_details_tab.net_amount_percentage%TYPE;
   CURSOR get_percentage IS
      SELECT SUM(net_amount_percentage)
      FROM   payment_term_details_tab
      WHERE  company     = company_
      AND    pay_term_id = pay_term_id_
      AND    day_from    = 1;
BEGIN
   OPEN get_percentage;
   FETCH get_percentage INTO temp_;
   CLOSE get_percentage;
   RETURN temp_;   
END Get_Total_Percentage;


FUNCTION Get_Specific_Range(
   company_     IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   inst_num_    IN VARCHAR2) RETURN NUMBER
IS
   temp_   payment_term_details_tab.net_amount_percentage%TYPE;
   CURSOR get_count IS
      SELECT COUNT(installment_number)
      FROM   payment_term_details_tab
      WHERE  company     = company_
      AND    pay_term_id = pay_term_id_
      AND    installment_number = inst_num_;
BEGIN
   OPEN get_count;
   FETCH get_count INTO temp_;
   CLOSE get_count;
   RETURN temp_;   
END Get_Specific_Range;


PROCEDURE Validate_installment_Range (
   company_             IN VARCHAR2,
   pay_term_id_         IN VARCHAR2,
   installment_no_      IN NUMBER,
   day_to_              IN NUMBER)
IS
   temp_count_   NUMBER := 0;   
   CURSOR installment_count IS 
      SELECT COUNT (installment_number)
      FROM   payment_term_details_tab
      WHERE  company = company_
      AND    pay_term_id = pay_term_id_
      AND    installment_number = installment_no_;
BEGIN
   OPEN installment_count;
   FETCH installment_count INTO temp_count_;
   IF (temp_count_ = 1) AND (day_to_ != 31) THEN
      Error_SYS.Record_General(lu_name_, 'VALINSTALLERROR: Installment has invalid range of values for period.');
   END IF; 
   CLOSE installment_count;   
END Validate_installment_Range;


PROCEDURE Create_Automatic_Payment_Plan (
   company_                 IN VARCHAR2,
   pay_term_id_             IN VARCHAR2,
   no_of_installments_      IN NUMBER,
   no_of_free_deliv_months_ IN NUMBER,
   days_to_due_date_        IN NUMBER,   
   institute_id_            IN VARCHAR2,
   payment_method_          IN VARCHAR2,
   end_of_month_            IN BOOLEAN,
   due_day1_                IN NUMBER,
   due_day2_                IN NUMBER,
   due_day3_                IN NUMBER )
IS 
   rec_              Payment_Term_Details_Tab %ROWTYPE;   
   rem_              NUMBER := 0;
   sum_net_amount_   NUMBER := 0;
   tot_rem_          NUMBER := 0;
   end_of_month_val_ VARCHAR2(5);
   vat_dist_val_     VARCHAR2(30);
   days_             NUMBER := 0;
BEGIN 
   Validate_Items(company_, pay_term_id_, days_to_due_date_, no_of_free_deliv_months_, due_day1_, due_day2_, due_day3_, no_of_installments_);
   vat_dist_val_   := Payment_term_API.Get_Vat_Distribution_Db(company_, pay_term_id_);
   FOR i_ IN 1.. no_of_installments_ LOOP  

      IF (end_of_month_) THEN
         end_of_month_val_ := 'TRUE';
      ELSE
         end_of_month_val_ := 'FALSE';
      END IF;

      rec_.installment_number := i_;
      rec_.company            := company_;
      rec_.pay_term_id        := pay_term_id_;
      rec_.free_delivery_months := no_of_free_deliv_months_;
      IF (days_to_due_date_ IS NOT NULL) THEN 
         days_ := days_ + days_to_due_date_;
         rec_.days_to_due_date := days_;
      END IF; 
      rec_.institute_id        := institute_id_;
      rec_.payment_method      := payment_method_;
      rec_.end_of_month        := end_of_month_val_;
      rec_.day_from := 1;
      rec_.day_to   := 31;
      IF (('FIRSTINSTONLYTAX' = vat_dist_val_) AND (i_ = 1)) THEN
         rec_.net_amount_percentage := 0;
      ELSIF (('FIRSTINSTONLYTAX' = vat_dist_val_) AND (i_ > 1)) THEN            
         rec_.net_amount_percentage := trunc((100 /(no_of_installments_ - 1)), 7);
         rem_ := (100/ (no_of_installments_ - 1)) - rec_.net_amount_percentage;
         Sum_Net_Amount___(sum_net_amount_, tot_rem_, rec_.net_amount_percentage, rem_, i_, no_of_installments_);
      ELSE 
         rec_.net_amount_percentage := trunc((100 / no_of_installments_), 7 );
         rem_ := (100/ no_of_installments_) - rec_.net_amount_percentage;
         Sum_Net_Amount___(sum_net_amount_, tot_rem_, rec_.net_amount_percentage, rem_, i_, no_of_installments_);
      END IF;
      rec_.due_date1 := due_day1_;
      rec_.due_date2 := due_day2_;
      rec_.due_date3 := due_day3_;
      New___(rec_);
   END LOOP; 
END Create_Automatic_Payment_Plan;


PROCEDURE Validate_Items(
   company_              IN VARCHAR2,
   pay_term_id_          IN VARCHAR2,
   days_to_due_date_     IN NUMBER,
   free_delivery_months_ IN NUMBER,
   due_day1_             IN NUMBER,
   due_day2_             IN NUMBER,
   due_day3_             IN NUMBER,
   no_of_installments_   IN NUMBER)
IS 
BEGIN
   Validate_Days_To_Due_Date___(days_to_due_date_);
   Validate_Free_Deliv_Months___(free_delivery_months_);
   Validate_Specific_Due_Day___(due_day1_);
   Validate_Specific_Due_Day___(due_day2_);
   Validate_Specific_Due_Day___(due_day3_);
   Validate_No_Of_Installments___(company_, pay_term_id_, no_of_installments_);   
END Validate_Items;



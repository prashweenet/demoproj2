-----------------------------------------------------------------------------
--
--  Logical unit: PaymentTerm
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960606  JoTh     Created
--  960606  JoTh     Attr_Value_To_Number bortkommenterad
--  960606  JoTh     Added handling of Language_Text_API
--  960606  PARO     Added Function Get_Description
--  960613  JoTh     Column name DESCRIPTION changed
--  960619  JoTh     Added function Calc_Due_Date
--  960619  JoTh     Column comment UPPERCASE added
--  960816  JoTh     Function Get_Pay_Term_Disc added
--  960911  DAKA     Calling to function  Attribute_Definition_API.Check_Value
--                   added
--  970612  DavJ     Added TEXT_FIELD_TRANSLATION_API.Remove_Text in Procedure Remove
--  980301  JeLa     Module code changed to ACCRUL
--  980928  JPS      Added new procedure Get_Default_Data_
--  990416  JPS      Performed Template Changes.(Foundation 2.2.1)
--  990901  AnTo     Rename columns free_deliv_month to no_free_deliv_month
--                   Added end_of_month, specific_due_day, block_for_direct_debiting
--  990913  AnTo     Change the Function Calc_Due_Date
--  990915  AnTo     Function Calc_Disc_Base added
--  000203  Uma      Corrected Bug Id# 33011.
--  000914  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001219  OVJOSE   For new Create Company concept added public procedure Make Company and added implementation
--                   procedures Import___, Copy___, Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010719 SUMALK    Bug 22932 Fixed.( Removed dbms__sql and added Execute Immediate)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020207  ASODSE   IID 21003 Company Translations, Replaced "Text Field Translation"
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  021028  Samblk   IID ITFI107E - added column Considr Payment Vacation Period, Combo box Base for Discount Date
--  021028           combo box Vat Distribution and Removed Colunms Number of Free Dilivery Months,
--  021028           Days to Due Date, End of Month, Specific Due Date to LU PaymentTerm
--  021106  ovjose   IID Glob06. Added column description to Table.
--  021115  LoKrLK   IID ITFI107E Modified Function Check_Vat_Distribution
--  021120  samblk   IID ITFI107E - added use_commercial_year to Cpmpany template
--  021230  LoKrLK   B92252 Modified Calc_Due_Date Function
--  030113  Ravilk   BEFI138N.Added a column "Exclude_Credit_Limit' to Payment_Term_Tab.
--  030113  Ravilk   BEFI138N.Added a column "Exclude_Credit_Limit' to Company Template.
--  030317  LoKrLK   IID ITFI108E Changed Vat Distribution Server Value
--  032503  TiUkLk   Moved Transaction_SYS.Package_Is_Installed() calls to the PRIVATE DECLARATIONS section
--  030423  LoKrLK   IID DEFI162N Removed Column Base_For_Disc_Date
--  030424  NiKaLK   DEFI162N Removal of Column Base_For_Disc_Date for company template modification
--  030425  LoKrLK   IID DEFI162N Modfied Function Calc_Due_Date
--  030512  NiKaLK   IID ITFI108E Modified function Calc_Due_Date
--  030521  TiUkLK   IID DEFI162N Modified method Get_Pay_Term_Disc()
--  030611  LoKrLK   IID DEFI162N Modified method Calc_Due_Date
--  030818  LoKrLK   Code Review.
--  030917  GaWiLK   Set the Description as second column for template.
--  031022  RAFA   Added Get_Installment_Data
--
--  040615  sachlk   FIPR338A2: Unicode Changes.
--  040702  AnGiSe  B115589 Added new method Check_Installment_Lines and method call from Unpack_Check_Update.
--  040712  anpelk  B115738, Make the method call Check_Installment_Lines dynamic.
--  040906  AsHelk  Merged LCS Bug 46034.
--  060315  Hecolk  LCS Merge 56178, Added new Function Get_Payment_Method
--  061016  SuSalk  LCS Merge 60185, Modified method Calc_Due_Date.
--  100929  Machlk  Added suppress_amount.
--  110727  Sacalk  FIDEAGLE-198, Fixed errors in Dictionary Test
--  111031  Nirplk  SFI-494, Merged Bug 99407, Added party_type_db_ as parameter to Calc_Due_Date.
--   121204   Maaylk  PEPA-183, Removed global variables
--  130603  Mawelk  Bug 110385 Fixed.
--  130605  SALIDE  EDEL-2186, Added cash_disc_fixass_acq_value and Modify_Cash_Discount_Fixass() and Is_Any_Cash_Disc_Selected()
--  131031  Lamalk  PBFI-698, Changed the method call to Fa_Company_API.Get_Reduction_Cash_Discount_Db() where method Fa_Company_API.Get_Reduction_Cash_Discount() is called
--  131101  PRatlk  PBFI-2058, Refactored according to the new template
--  180225  NaLrlk  STRSC-16873, Modified method Get_Installment_Data to make descriptive error message for missing pay term id.
--  181823  Nudilk  Bug 143758, Corrected.
--  181009  Ajpelk  Bug 144187, Merged APP9 correction.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
--  190717  Dkanlk  Bug 142602, Merged APP9 correction, Added default value for 'print_swiss_q_r_code'.
--  201127  Lakhlk  FISPRING20-8431, Merged LCS bug 156743, Corrected client value for 'print_swiss_q_r_code'.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   company_                      VARCHAR2(20);
   cash_disc_fixass_acq_value_   VARCHAR2(20);
BEGIN
   company_ := Client_SYS.Get_Item_Value('COMPANY', attr_);
   super(attr_);
   Client_SYS.Add_To_Attr('BLOCK_FOR_DIRECT_DEBITING', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('CONSIDER_PAY_VAC_PERIOD', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('USE_COMMERCIAL_YEAR', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('VAT_DISTRIBUTION', Vat_Distribution_API.Decode('EVEN'), attr_ );
   Client_SYS.Add_To_Attr('EXCLUDE_CREDIT_LIMIT', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('SUPPRESS_AMOUNT', 'FALSE', attr_);
   Client_SYS.Add_To_Attr('PRINT_SWISS_Q_R_CODE', Fnd_Boolean_API.Decode('FALSE'), attr_);
   cash_disc_fixass_acq_value_ := Fnd_Boolean_API.DB_FALSE;
$IF (Component_Fixass_SYS.INSTALLED) $THEN
   cash_disc_fixass_acq_value_ := Fa_Company_API.Get_Reduction_Cash_Discount_Db( company_);
$END
   Client_SYS.Add_To_Attr('CASH_DISC_FIXASS_ACQ_VALUE_DB', cash_disc_fixass_acq_value_, attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT PAYMENT_TERM_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.rowversion := 1;
   objversion_ := to_char(newrec_.rowversion);
   super(objid_, objversion_, newrec_, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     PAYMENT_TERM_TAB%ROWTYPE,
   newrec_     IN OUT PAYMENT_TERM_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   newrec_.rowversion := newrec_.rowversion + 1;
   objversion_ := to_char(newrec_.rowversion);
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT payment_term_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_       VARCHAR2(30);
   value_      VARCHAR2(4000);
BEGIN
   IF newrec_.exclude_credit_limit IS NULL THEN
        newrec_.exclude_credit_limit := 'FALSE';
   END IF;
   IF newrec_.suppress_amount IS NULL THEN
        newrec_.suppress_amount := 'FALSE';
   END IF;
   IF ( newrec_.description IS NULL ) THEN
      newrec_.description := newrec_.pay_term_id;
   END IF;
   IF (newrec_.cash_disc_fixass_acq_value IS NULL) THEN
      newrec_.cash_disc_fixass_acq_value := Fnd_Boolean_API.DB_FALSE;
   END IF;
   IF newrec_.print_swiss_q_r_code IS NULL THEN
        newrec_.print_swiss_q_r_code := 'FALSE';
   END IF;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     payment_term_tab%ROWTYPE,
   newrec_ IN OUT payment_term_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_          VARCHAR2(30);
   value_         VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF nvl(newrec_.block_for_direct_debiting, 'FALSE') = 'TRUE' THEN
      IF Check_Installment_Lines(newrec_.company, newrec_.pay_term_id) = 1 THEN
         Error_SYS.Appl_General(lu_name_, 'BLOCKNOTALLOW: Payment Term include installment lines with direct debiting payment methods.');
      END IF;
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated
FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___; 

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     payment_term_tab%ROWTYPE,
   newrec_ IN OUT payment_term_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS    
   temprec_   payment_term_details_tab%ROWTYPE;
   CURSOR pey_term_details IS
      SELECT *
      FROM   payment_term_details_tab
      WHERE  company     = newrec_.company
      AND    pay_term_id = newrec_.pay_term_id;
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   OPEN pey_term_details;
   FETCH pey_term_details INTO temprec_;
   CLOSE pey_term_details;
   IF ((newrec_.vat_distribution) = 'FIRSTINSTONLYTAX') THEN
      IF ((temprec_.pay_term_id = newrec_.pay_term_id) AND (temprec_.installment_number = 1)  AND (temprec_.net_amount_percentage != 0) ) THEN 
         Error_SYS.Record_General(lu_name_, 'ERRORNETAMTZERO: The Net Amount Percentage for the first Installment must be zero!');
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_      IN payment_term_tab%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_      IN VARCHAR2,
   target_company_      IN VARCHAR2,
   pay_term_id_         IN VARCHAR2,
   update_method_       IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              payment_term_tab%ROWTYPE;
   target_rec_              payment_term_tab%ROWTYPE;
   old_target_rec_          payment_term_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);  
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, pay_term_id_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, pay_term_id_);
   log_key_ := pay_term_id_;

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
      Raise_Record_Not_Exist___(target_company_, pay_term_id_);
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
   Enterp_Comp_Connect_V170_API.Copy_Comp_To_Comp_Trans(source_company_,
                                                        target_rec_.company,
                                                        module_,
                                                        lu_name_,
                                                        lu_name_,
                                                        pay_term_id_,
                                                        pay_term_id_);
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;
   
PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   pay_term_id_list_    IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   log_id_               IN  NUMBER,
   attr_                 IN  VARCHAR2 DEFAULT NULL)
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         payment_term_tab.company%TYPE;
   TYPE payment_term IS TABLE OF payment_term_tab.pay_term_id%TYPE 
                           INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                           INDEX BY BINARY_INTEGER;                        
   ref_payment_term_       payment_term;
   ref_attr_               attr;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pay_term_id_list_) LOOP
      ref_payment_term_(i_):= value_;
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
                                 ref_payment_term_(j_),      
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

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
   update_method_list_  VARCHAR2(32000);
   copy_type_           VARCHAR2(100);
   attr1_               VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'SOURCE_COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'PAY_TERM_ID_LIST') THEN
         pay_term_id_list_ := value_;
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
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_      IN  VARCHAR2,
   target_company_list_ IN  VARCHAR2,
   pay_term_id_list_    IN  VARCHAR2,
   update_method_list_  IN  VARCHAR2,
   copy_type_           IN  VARCHAR2,
   attr_                IN  VARCHAR2 DEFAULT NULL)
IS
   ptr_                    NUMBER;
   ptr1_                   NUMBER;
   ptr2_                   NUMBER;
   i_                      NUMBER;
   update_method_          VARCHAR2(20);
   value_                  VARCHAR2(2000);
   target_company_         payment_term_tab.company%TYPE;
   TYPE payment_term IS TABLE OF payment_term_tab.pay_term_id%TYPE 
                           INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) 
                           INDEX BY BINARY_INTEGER;                        
   ref_payment_term_       payment_term;
   ref_attr_               attr;
   log_id_                 NUMBER;
   attr_value_             VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, pay_term_id_list_) LOOP
      ref_payment_term_(i_):= value_;
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
         FOR j_ IN ref_payment_term_.FIRST..ref_payment_term_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_payment_term_(j_),      
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

@Override
@UncheckedAccess
PROCEDURE Exist (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2 )
IS
BEGIN
   -- This new addition of the same logic ensures an override.
   IF (NOT Check_Exist___(company_, pay_term_id_)) THEN
      Error_SYS.Record_General(lu_name_, 'PAYTERMNOTEXIST: The payment term :P1 does not exist in company :P2.', pay_term_id_, company_);
   END IF;
   
   super(company_, pay_term_id_);
END Exist;


@UncheckedAccess
FUNCTION Calc_Due_Date (
   company_       IN VARCHAR2,
   pay_term_id_   IN VARCHAR2,
   invoice_date_  IN DATE,
   party_type_db_ IN VARCHAR2 DEFAULT NULL ) RETURN DATE   
IS
   nfirst_installment_ NUMBER;
   vat_type_           payment_term_tab.vat_distribution%TYPE;

   CURSOR get_min_installment IS
   SELECT installment_number
   FROM   payment_term_details_tab
   WHERE  pay_term_id = pay_term_id_
   AND    company = company_
   AND    Net_amount_Percentage >0
   ORDER BY DAYS_TO_DUE_DATE;

  CURSOR get_first_installment IS
   SELECT installment_number
   FROM   payment_term_details_tab
   WHERE  pay_term_id = pay_term_id_
   AND    company = company_
   ORDER BY DAYS_TO_DUE_DATE;

  CURSOR get_vat_type IS
     SELECT vat_distribution
     FROM payment_term_tab
     WHERE pay_term_id = pay_term_id_
     AND company = company_;


BEGIN

   OPEN get_vat_type;
   FETCH get_vat_type INTO vat_type_;
   CLOSE get_vat_type;

   IF vat_type_ = 'FIRSTINSTONLYTAX' THEN
      OPEN get_first_installment;
      FETCH get_first_installment INTO nfirst_installment_;
      CLOSE get_first_installment;
   ELSE
      OPEN  get_min_installment;
      FETCH get_min_installment INTO nfirst_installment_;
      CLOSE get_min_installment;
   END IF;

   RETURN Payment_Term_Details_API.Calc_Due_Date(company_,
                                                 pay_term_id_,
                                                 nfirst_installment_,
                                                 TRUNC(invoice_date_),
                                                 party_type_db_ => party_type_db_);

END Calc_Due_Date;




PROCEDURE Get_Pay_Term_Disc (
   company_       IN VARCHAR2,
   pay_term_id_   IN VARCHAR2,
   installment_number_ IN NUMBER,
   day_from_           IN NUMBER,
   attr_          IN OUT VARCHAR2 )
IS
   outpar_     VARCHAR2(2000);
   tmp_attr_   VARCHAR2(2000);
BEGIN
   outpar_ := attr_;
   $IF Component_Invoic_SYS.INSTALLED $THEN
      Payment_Term_Disc_API.Get_Pay_Term_Disc( company_, pay_term_id_, installment_number_, day_from_, outpar_ );
      tmp_attr_ :=  outpar_;
   $ELSE
      tmp_attr_ := NULL;
   $END
   attr_ := tmp_attr_;
END Get_Pay_Term_Disc;


PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   pay_term_id_   IN VARCHAR2 )
IS
BEGIN
   description_ := Get_Description(company_, pay_term_id_);
END Get_Control_Type_Value_Desc;

@UncheckedAccess
FUNCTION Calc_Disc_Base (
   company_      IN VARCHAR2,
   pay_term_id_  IN VARCHAR2,
   invoice_date_ IN DATE ) RETURN DATE
IS
   no_free_deliv_month_ NUMBER;
BEGIN
   -- Have added 1 as defaule value for installment_id
   no_free_deliv_month_ := Payment_Term_Details_API.Get_Free_Delivery_Months_Range(company_,
                                                                                   pay_term_id_,
                                                                                   1,
                                                                                   to_number(to_char(invoice_date_,'DD')));
   IF (no_free_deliv_month_ > 0 ) THEN
       RETURN (Last_Day(Add_Months(invoice_date_, no_free_deliv_month_ - 1)));
   ELSE
       RETURN (invoice_date_);
   END IF;
END Calc_Disc_Base;




@UncheckedAccess
FUNCTION Get_Payment_Method (
   company_       IN VARCHAR2,
   pay_term_id_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   first_installment_  NUMBER;
   day_from_           NUMBER;
   vat_type_           payment_term_tab.vat_distribution%TYPE;

   CURSOR get_min_installment IS
      SELECT installment_number, day_from
      FROM   payment_term_details_tab
      WHERE  pay_term_id = pay_term_id_
      AND    company = company_
      AND    Net_amount_Percentage >0
      ORDER BY DAYS_TO_DUE_DATE;

  CURSOR get_first_installment IS
      SELECT installment_number, day_from
      FROM   payment_term_details_tab
      WHERE  pay_term_id = pay_term_id_
      AND    company = company_
      ORDER BY DAYS_TO_DUE_DATE;

  CURSOR get_vat_type IS
     SELECT vat_distribution
     FROM payment_term_tab
     WHERE pay_term_id = pay_term_id_
     AND company = company_;
BEGIN

   OPEN get_vat_type;
   FETCH get_vat_type INTO vat_type_;
   CLOSE get_vat_type;

   IF vat_type_ = 'FIRSTINSTONLYTAX' THEN
      OPEN get_first_installment;
      FETCH get_first_installment INTO first_installment_, day_from_;
      CLOSE get_first_installment;
   ELSE
      OPEN  get_min_installment;
      FETCH get_min_installment INTO first_installment_, day_from_;
      CLOSE get_min_installment;
   END IF;

   RETURN Payment_Term_Details_API.Get_Payment_Method( company_,
                                                       pay_term_id_,
                                                       first_installment_,
                                                       day_from_ );                                                 
END Get_Payment_Method;




@UncheckedAccess
FUNCTION Check_Installment_Lines (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_                      NUMBER;
   
   $IF Component_Payled_SYS.INSTALLED $THEN
      CURSOR get_direct_debiting_lines IS
         SELECT 1
         FROM   PAYMENT_TERM_DETAILS  
         WHERE  company = company_ 
         AND    pay_term_id = pay_term_id_
         AND    way_id IN ( SELECT pw.way_id  
                            FROM   PAYMENT_WAY_TAB pw, PAYMENT_FORMAT_TAB pf 
                            WHERE  pw.format_id = pf.format_id
                            AND    pw.company = company_
                            AND    pf.format_type = 'DIRECTDEBITINGFORMAT');
   $END
BEGIN
   $IF Component_Payled_SYS.INSTALLED $THEN
      temp_ := NULL;
      
      OPEN  get_direct_debiting_lines;
      FETCH get_direct_debiting_lines INTO temp_;
      CLOSE get_direct_debiting_lines;
   $END
   RETURN nvl(temp_,0);
END Check_Installment_Lines; 




PROCEDURE Check_Vat_Distribution (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2,
   vat_distribution_ IN VARCHAR2 )
IS
   CURSOR get_pay_term_detail IS
       SELECT net_amount_percentage
       FROM PAYMENT_TERM_DETAILS
       WHERE company = company_
       AND   pay_term_id = pay_term_id_
       ORDER BY installment_number;

   net_amount_percentage_  NUMBER;

BEGIN


   IF (Vat_Distribution_API.Encode(vat_distribution_) = 'FIRSTINSTONLYTAX') THEN

      OPEN get_pay_term_detail;
      FETCH  get_pay_term_detail INTO net_amount_percentage_;
      IF get_pay_term_detail%FOUND THEN
         IF (net_amount_percentage_ != 0) THEN
            Error_SYS.Record_General(lu_name_, 'NOTEXIST: The First Installment does not exist with Zero percentage.');
         END IF;
      END IF;
      CLOSE get_pay_term_detail;

   END IF;
END Check_Vat_Distribution;


PROCEDURE Get_Installment_Data (
   attr_               IN OUT VARCHAR2,
   company_            IN VARCHAR2,
   identity_           IN VARCHAR2,
   party_type_db_      IN VARCHAR2,
   pay_term_id_        IN VARCHAR2,
   currency_           IN VARCHAR2,
   net_curr_amount_    IN NUMBER,
   vat_curr_amount_    IN NUMBER,
   date_               IN DATE )
IS
   CURSOR get_pay_term_details IS
      SELECT *
      FROM   PAYMENT_TERM_DETAILS_TAB
      WHERE  company     = company_
      AND    pay_term_id = pay_term_id_
      AND    to_number(to_char(date_,'DD')) BETWEEN day_from and day_to
      ORDER BY installment_number;

   CURSOR count_pay_term_details IS
      SELECT count(*)
      FROM   PAYMENT_TERM_DETAILS_TAB
      WHERE  company     = company_
      AND    pay_term_id = pay_term_id_;


   temp_identity_        VARCHAR2(20);
   rounding_             NUMBER;
   calc_due_date_        DATE;
   vat_distribution_db_  VARCHAR2(50);
   percentage_           NUMBER;
   amount_               NUMBER;
   sum_amount_           NUMBER := 0;
   count_pay_det_        NUMBER;
   count_rec_            NUMBER := 0;
BEGIN
   rounding_ := Currency_Code_API.Get_Currency_Rounding(company_, currency_);
   IF (pay_term_id_ IS NULL) THEN
      Error_SYS.Appl_General(lu_name_, 'NOPAYTERMEXIST: Payment Term is not defined for the Supplier :P1 for Company :P2', identity_, company_);   
   END IF;
   vat_distribution_db_ := Payment_Term_API.Get_Vat_Distribution_Db(company_, pay_term_id_);
   IF party_type_db_ = 'CUSTOMER' THEN
      -- temp_identity_ necessary only for customer to use Payment Vacation Period in Calculate_Due_Date
      temp_identity_ := identity_;
   ELSE
      temp_identity_ := NULL;
   END IF;
   -- check if there are any details defined
   OPEN  count_pay_term_details;
   FETCH count_pay_term_details INTO count_pay_det_;
   CLOSE count_pay_term_details;

   IF NVL(count_pay_det_, 0) = 0 THEN
      IF party_type_db_ = 'SUPPLIER' THEN
         Error_SYS.Appl_General(lu_name_, 'NOPAYTERMDETSUPP: There are no Payment Terms defined for Supplier :P1.', identity_);   
      ELSE
         Error_SYS.Appl_General(lu_name_, 'NOPAYTERMDET: There are no Payment Term Details defined for Payment Term :P1.', pay_term_id_);
      END IF;
   END IF;
   Client_SYS.Clear_Attr(attr_);
   -- for each payment term detail create one installment
   FOR rec_ IN get_pay_term_details LOOP
      count_rec_ := count_rec_ + 1;
      -- calculate due amount
      percentage_ := rec_.net_amount_percentage;
      IF (vat_distribution_db_= 'EVEN') THEN   -- Even
         amount_ := (net_curr_amount_+ vat_curr_amount_)* (percentage_ / 100);
      ELSIF (vat_distribution_db_= 'ALLTAXONFIRSTINST') THEN  -- All on first installment
         IF (count_rec_ = 1) THEN
            amount_ := (net_curr_amount_* (percentage_ / 100)) + nvl(vat_curr_amount_,0);
         ELSE
            amount_ := net_curr_amount_* (percentage_ / 100);
         END IF;
      ELSIF (vat_distribution_db_= 'FIRSTINSTONLYTAX') THEN  -- First installment only VAT
         IF (count_rec_ = 1) THEN
            amount_ := nvl(vat_curr_amount_,0);
         ELSE
            amount_ := net_curr_amount_* (percentage_ / 100);
         END IF;
      ELSE
         NULL;
      END IF;
      amount_     := ROUND(amount_, rounding_);
      sum_amount_ := sum_amount_ + amount_;

      -- for the last installment adjust amount
      IF count_rec_ = count_pay_det_ THEN
         amount_ := amount_ + ((net_curr_amount_+ vat_curr_amount_) - sum_amount_);
      END IF;
      IF (nvl(amount_,0) != 0) THEN
         -- calculate due date
         calc_due_date_ := Payment_Term_Details_API.Calc_Due_Date(
                              company_,
                              pay_term_id_,
                              rec_.installment_number,
                              date_,
                              temp_identity_,
                              party_type_db_);
         Client_SYS.Add_To_Attr('INSTALLMENT_ID', rec_.installment_number, attr_);
         Client_SYS.Add_To_Attr('DUE_DATE', calc_due_date_, attr_);
         Client_SYS.Add_To_Attr('CURR_AMOUNT', amount_, attr_);
      END IF;
   END LOOP;
END Get_Installment_Data;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Modify_Cash_Discount_Fixass(
   company_    IN VARCHAR2,
   flag_       IN VARCHAR2 )
IS
   oldrec_     PAYMENT_TERM_TAB%ROWTYPE;
   newrec_     PAYMENT_TERM_TAB%ROWTYPE;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   attr_       VARCHAR2(2000);

   CURSOR get_all IS
      SELECT pay_term_id
      FROM   PAYMENT_TERM_TAB
      WHERE  company = company_;
BEGIN
   FOR rec_ IN get_all LOOP
      oldrec_ := Lock_By_Keys___ (company_, rec_.pay_term_id);
      newrec_ := oldrec_;
      newrec_.cash_disc_fixass_acq_value := flag_;
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END LOOP;
END Modify_Cash_Discount_Fixass;


@UncheckedAccess
FUNCTION Is_Any_Cash_Disc_Selected (
   company_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_      NUMBER;
   CURSOR is_exist IS
      SELECT 1
      FROM   PAYMENT_TERM_TAB
      WHERE  company = company_
      AND    cash_disc_fixass_acq_value = 'TRUE';
BEGIN
   OPEN  is_exist;
   FETCH is_exist INTO dummy_;
   IF (is_exist%FOUND) THEN
      CLOSE is_exist;
      RETURN 'TRUE';
   END IF;
   CLOSE is_exist;
   RETURN 'FALSE';
END Is_Any_Cash_Disc_Selected;


@UncheckedAccess
FUNCTION Is_Fa_Reduct_Cash_Disc_Allowed (
   company_ IN VARCHAR2,
   pay_term_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   fa_reduct_cash_disc_ VARCHAR2(5) := 'FALSE';
   temp_                PAYMENT_TERM_TAB.cash_disc_fixass_acq_value%TYPE;
   CURSOR get_attr IS
      SELECT cash_disc_fixass_acq_value
      FROM   PAYMENT_TERM_TAB
      WHERE  company     = company_
       AND   pay_term_id = pay_term_id_;
BEGIN
$IF Component_Fixass_SYS.INSTALLED $THEN
   fa_reduct_cash_disc_ := Fa_Company_API.Get_Reduction_Cash_Discount_Db(company_);
$END

   IF (fa_reduct_cash_disc_ = 'TRUE') THEN
      OPEN get_attr;
      FETCH get_attr INTO temp_;
      CLOSE get_attr;
      RETURN temp_;
   ELSE
      RETURN 'FALSE';
   END IF;
END Is_Fa_Reduct_Cash_Disc_Allowed;


PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   pay_term_id_list_       VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Payment_Term_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'PAY_TERM_ID_LIST') THEN
            pay_term_id_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                  target_company_list_,
                                  pay_term_id_list_,
                                  update_method_list_,
                                  log_id_,
                                  attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

PROCEDURE Get_Reduct_Cash_Disc_Val(
   company_                    IN VARCHAR2,
   cash_disc_fixass_acq_value_ IN BOOLEAN)
IS
   reduct_cash_disc_  VARCHAR2(20); 
   cash_disc_val_     VARCHAR2(5);
BEGIN
   IF (cash_disc_fixass_acq_value_) THEN
      cash_disc_val_ := 'TRUE';
   ELSE
      cash_disc_val_ := 'FALSE';
   END IF;
   $IF Component_Fixass_SYS.INSTALLED $THEN
      reduct_cash_disc_ := Fa_Company_API.Get_Reduction_Cash_Discount_Db(company_);
   $END      
   IF (reduct_cash_disc_= 'FALSE' AND cash_disc_val_ = 'TRUE') THEN 
      Error_SYS.Record_General(lu_name_, 'ERRORFIXASSVAL: Cash Discount will only be applied to the acquisition values of FA objects in companies which allow the reduction for cash discount in Company/Fixed Assets/Acquisition Parameters.');
   END IF;   
END Get_Reduct_Cash_Disc_Val;

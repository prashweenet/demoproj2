-----------------------------------------------------------------------------
--
--  Logical unit: PaymentVacationPeriod
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021031  TiUkLK   Created, IID ITFI107E - Installment Basic Data
--  021114  GaWiLK   IID ITFI107E. Modified create company basic data additions.
--  021202  TiUkLK   Call 91980 Get_New_Vac_Due_Date() and Date_Validation() methods modified.
--  030211  GaWiLK   IID ITFI107E - B93808. Added party_type customer for the view.
--  032503  TiUkLk   Moved Transaction_SYS.Package_Is_Installed() calls to the PRIVATE DECLARATIONS section
--  032603  GaWiLK   IID ITFI108E. Added method Validate_Payment_Method___.
--  030714  Risrlk   IID RDFI140E. Modified import___, copy___, Make_Company methods and added
--                   import_copy___, calc_new_date___, crecomp_insert___, modify_key_date___ methods.
--  030715  Risrlk   IID RDFI140E. Modified import_copy___ method.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  091023  AjPelk   EAST-219 , Added view comment for missing field party_type
--  100308  Nsillk   EAFH-2157 , Modified method Import_Copy__
--  100401  Nsillk   EAFH-2584 , Fixed in method Import_Copy__ , checked for null in a different way and validated dates when copying
--  100831  ovjose   Removed Modify_Key_Date___. Date handling changed, no need to modify the dates for diff templates.
--  110324  Umdolk   EAPM-16108, Corrected errors in create company in Import___.
--  121204  Maaylk   PEPA-183, Removed global variables
--  131004  PRatlk   PBFI-2060, Refactored according to the new template
--  181823  Nudilk   Bug 143758, Corrected.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE table_rec     IS TABLE OF PAYMENT_VACATION_PERIOD_TAB%ROWTYPE INDEX BY BINARY_INTEGER;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Payment_Method___ (
   company_ IN VARCHAR2,
   payment_method_ IN VARCHAR2 )
IS
   $IF Component_Payled_SYS.INSTALLED $THEN
      count_ NUMBER;
      CURSOR count_cur IS
         SELECT count(*) FROM PAYMENT_WAY_LOV2 
         WHERE company     = company_
         AND party_type_db = 'CUSTOMER'
         AND way_id        = payment_method_;
   $END
BEGIN
   $IF Component_Payled_SYS.INSTALLED $THEN
      OPEN count_cur;
      FETCH count_cur INTO count_;
      CLOSE count_cur;
      IF count_ = 0 THEN
         Error_SYS.Record_General( 'PaymentVacationPeriod', 'WRONGWAYID: Payment Method :P1 can not be used for Customers.',payment_method_);
      END IF;
   $ELSE
      NULL;
   $END
END Validate_Payment_Method___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('PAYMENT_METHOD', '%', attr_);
   Client_SYS.Add_To_Attr('CUSTOMER_ID', '%', attr_);
   Client_SYS.Add_To_Attr('PARTY_TYPE', Party_Type_API.Decode('CUSTOMER'), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT payment_vacation_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   IF (newrec_.customer_id <> '%') THEN
      Customer_Info_API.Exist(newrec_.customer_id);
   END IF;
   IF (newrec_.payment_method <> '%') THEN
      $IF Component_Payled_SYS.INSTALLED $THEN
         Payment_Way_API.Exist(newrec_.company, newrec_.payment_method);
      $END
      Validate_Payment_Method___(newrec_.company, newrec_.payment_method);
   END IF;
   IF (newrec_.start_date IS NOT NULL) THEN
      Date_Validation( newrec_.company,
                       newrec_.payment_method,
                       newrec_.customer_id,
                       newrec_.start_date,
                       newrec_.end_date,
                       newrec_.start_date,
                       'START_DATE' );
   END IF;
   IF (newrec_.end_date IS NOT NULL) THEN
      Date_Validation( newrec_.company,
                       newrec_.payment_method,
                       newrec_.customer_id,
                       newrec_.start_date,
                       newrec_.end_date,
                       newrec_.end_date,
                       'END_DATE' );
   END IF;
   IF (newrec_.new_due_date IS NOT NULL) THEN
      Date_Validation( newrec_.company,
                       newrec_.payment_method,
                       newrec_.customer_id,
                       newrec_.start_date,
                       newrec_.end_date,
                       newrec_.new_due_date,
                       'NEW_DUE_DATE' );
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     payment_vacation_period_tab%ROWTYPE,
   newrec_ IN OUT payment_vacation_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.customer_id <> '%' ) THEN
      Customer_Info_API.Exist(newrec_.customer_id);
   END IF; 
   Date_Validation( newrec_.company,
                    newrec_.payment_method,
                    newrec_.customer_id,
                    newrec_.start_date,
                    newrec_.new_due_date,
                    newrec_.end_date,
                    'END_DATE' );
   Date_Validation( newrec_.company,
                    newrec_.payment_method,
                    newrec_.customer_id,
                    newrec_.start_date,
                    newrec_.end_date,
                    newrec_.new_due_date,
                    'NEW_DUE_DATE' );
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
PROCEDURE Check_Delete___ (
   remrec_      IN payment_vacation_period_tab%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     payment_vacation_period_tab%ROWTYPE,
   newrec_ IN OUT payment_vacation_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN VARCHAR2,
   target_company_list_ IN VARCHAR2,
   payment_method_list_ IN VARCHAR2,
   customer_id_list_    IN VARCHAR2,
   start_date_list_     IN VARCHAR2,
   update_method_list_  IN VARCHAR2,
   log_id_              IN  NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   TYPE payment_vacation_period IS TABLE OF payment_vacation_period_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                          NUMBER;
   ptr1_                         NUMBER;
   ptr2_                         NUMBER;
   i_                            NUMBER;
   update_method_                VARCHAR2(20);
   value_                        VARCHAR2(2000);
   target_company_               payment_vacation_period_tab.company%TYPE;
   ref_payment_vacation_period_  payment_vacation_period;
   ref_attr_                     attr;
   attr_value_                   VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, payment_method_list_) LOOP
      ref_payment_vacation_period_(i_).payment_method := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, customer_id_list_) LOOP
      ref_payment_vacation_period_(i_).customer_id := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, start_date_list_) LOOP
      ref_payment_vacation_period_(i_).start_date := Client_SYS.Attr_Value_To_Date(value_);
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
         FOR j_ IN ref_payment_vacation_period_.FIRST..ref_payment_vacation_period_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_payment_vacation_period_(j_).payment_method,      
                                 ref_payment_vacation_period_(j_).customer_id,      
                                 ref_payment_vacation_period_(j_).start_date,      
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_To_Companies_For_Svc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Copy_To_Companies__ (
   source_company_      IN VARCHAR2,
   target_company_      IN VARCHAR2,
   payment_method_      IN VARCHAR2,
   customer_id_         IN VARCHAR2,
   start_date_          IN DATE,
   update_method_       IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              payment_vacation_period_tab%ROWTYPE;
   target_rec_              payment_vacation_period_tab%ROWTYPE;
   old_target_rec_          payment_vacation_period_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10); 
BEGIN
   source_rec_ := Get_Object_By_Keys___(source_company_, payment_method_, customer_id_, start_date_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_Sys.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, payment_method_, customer_id_, start_date_);
   log_key_ := payment_method_ ||'^'|| customer_id_ ||'^'|| start_date_;

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
      Raise_Record_Not_Exist___(target_company_, payment_method_, customer_id_, start_date_);
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
   payment_method_list_ VARCHAR2(32000);
   target_company_list_ VARCHAR2(32000);
   customer_id_list_    VARCHAR2(32000);
   start_date_list_     VARCHAR2(32000);
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
      ELSIF (name_ = 'PAYMENT_METHOD_LIST') THEN
         payment_method_list_ := value_;
      ELSIF (name_ = 'CUSTOMER_ID_LIST') THEN
         customer_id_list_ := value_;
      ELSIF (name_ = 'START_DATE_LIST') THEN
         start_date_list_ := value_;         
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
                      payment_method_list_,
                      customer_id_list_,
                      start_date_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_      IN VARCHAR2,
   target_company_list_ IN VARCHAR2,
   payment_method_list_ IN VARCHAR2,
   customer_id_list_    IN VARCHAR2,
   start_date_list_     IN VARCHAR2,
   update_method_list_  IN VARCHAR2,
   copy_type_           IN VARCHAR2,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   TYPE payment_vacation_period IS TABLE OF payment_vacation_period_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                         NUMBER;
   ptr1_                        NUMBER;
   ptr2_                        NUMBER;
   i_                           NUMBER;
   update_method_               VARCHAR2(20);
   value_                       VARCHAR2(2000);
   target_company_              payment_vacation_period_tab.company%TYPE;
   ref_payment_vacation_period_ payment_vacation_period;
   ref_attr_                    attr;
   log_id_                      NUMBER;
   attr_value_                  VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, payment_method_list_) LOOP
      ref_payment_vacation_period_(i_).payment_method := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, customer_id_list_) LOOP
      ref_payment_vacation_period_(i_).customer_id := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, start_date_list_) LOOP
      ref_payment_vacation_period_(i_).start_date := Client_SYS.Attr_Value_To_Date(value_);
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
         FOR j_ IN ref_payment_vacation_period_.FIRST..ref_payment_vacation_period_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_payment_vacation_period_(j_).payment_method,      
                                 ref_payment_vacation_period_(j_).customer_id,      
                                 ref_payment_vacation_period_(j_).start_date,      
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

PROCEDURE Date_Validation (
   company_        IN VARCHAR2,
   payment_method_ IN VARCHAR2,
   customer_id_    IN VARCHAR2,
   start_date_     IN DATE,
   end_date_       IN DATE,
   val_date_       IN DATE,
   type_of_val_    IN VARCHAR2 )
IS
   CURSOR get_dates IS
      SELECT start_date, end_date
      FROM   Payment_Vacation_Period
      WHERE  company        = company_
      AND    payment_method = payment_method_
      AND    customer_id    = customer_id_;

BEGIN
   -- Date_Validation() method is used to validate Start Date, End Date and New Due Date
   -- Value of type_of_val is used to identify the Type of Validation
   IF (type_of_val_ = 'START_DATE') THEN
      FOR date_rec_ IN get_dates LOOP
         IF val_date_ >= date_rec_.START_DATE AND val_date_ <= date_rec_.END_DATE THEN
            Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE0: Start Date can not overlap with other Vacation Periods.' );
         END IF;
      END LOOP;
   END IF;
   IF (type_of_val_ = 'END_DATE') THEN
      IF (val_date_ < start_date_) THEN
         Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE1: The End Date cannot be earlier than the Start Date.' );
      END IF;
      -- here the value in the end_date is actually the new_due_date
      IF (val_date_ > end_date_) THEN
         Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE2: The End Date cannot be later than the New Due Date.' );
      END IF;
      FOR date_rec_ IN get_dates LOOP
         IF (val_date_ >= date_rec_.start_date AND 
             val_date_ <= date_rec_.end_date) THEN
            IF (start_date_ <> date_rec_.start_date) THEN
               Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE3: End Date cannot overlap with other Vacation Periods.' );
            END IF;
         END IF;
      END LOOP;
   END IF;
   IF (type_of_val_ = 'NEW_DUE_DATE') THEN
      IF (val_date_ < start_date_) THEN
         Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE4: The New Due Date cannot be earlier than the Start Date.' );
      END IF;
      IF (val_date_ >= start_date_ AND val_date_ <= end_date_) THEN
         Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE5: New Due Date cannot be in the Vacation Period.' );
      END IF;
      FOR date_rec_ IN get_dates LOOP
         IF (val_date_ >= date_rec_.start_date AND 
             val_date_ <= date_rec_.end_date) THEN
            Error_SYS.Appl_General(lu_name_, 'VALIDATEDATE6: New Due Date cannot be in a Vacation Period.' );
         END IF;
      END LOOP;
   END IF;
END Date_Validation;


@UncheckedAccess
FUNCTION Get_New_Vac_Due_Date (
   company_        IN VARCHAR2,
   payment_method_ IN VARCHAR2,
   customer_id_    IN VARCHAR2,
   due_date_       IN DATE ) RETURN DATE
IS
   customer_               VARCHAR2(20);
   temp_cust_              VARCHAR2(20);
   payment_way_            VARCHAR2(20);
   dummy_                  VARCHAR2(20);
   new_due_date_           DATE;
   found_                  BOOLEAN;
   changed_new_due_date_   BOOLEAN;
   CURSOR get_pay IS
      SELECT payment_method
      FROM   Payment_Vacation_Period
      WHERE  company = company_
      AND    payment_method = payment_way_;
   CURSOR get_cust IS
      SELECT payment_method
      FROM   Payment_Vacation_Period
      WHERE  company = company_
      AND    payment_method = payment_way_
      AND    customer_id = customer_;
   CURSOR get_dates IS
      SELECT START_DATE, END_DATE, NEW_DUE_DATE
      FROM   Payment_Vacation_Period
      WHERE  company = company_
      AND    payment_method = payment_way_
      AND    customer_id = customer_;
BEGIN
   new_due_date_ := due_date_;
   changed_new_due_date_ := TRUE;
   LOOP
      customer_ := customer_id_;
      payment_way_ := payment_method_;
      found_ :=FALSE;
      changed_new_due_date_ := FALSE;
      OPEN  get_pay;
      FETCH get_pay INTO dummy_;
      IF get_pay%NOTFOUND THEN
         payment_way_ := '%';
      END IF;
      CLOSE get_pay;
      OPEN  get_cust;
      FETCH get_cust INTO dummy_;
      IF get_cust%NOTFOUND THEN
         customer_ := '%';
      END IF;
      CLOSE get_cust;
      FOR date_rec_ IN get_dates LOOP
         IF (new_due_date_ >= date_rec_.START_DATE AND 
             new_due_date_ <= date_rec_.end_date) THEN
            new_due_date_ := date_rec_.NEW_DUE_DATE;
            found_ := TRUE;
            changed_new_due_date_ := TRUE;
         END IF;
      END LOOP;
      temp_cust_ := customer_;
      IF NOT (found_ = TRUE) THEN
         customer_ := '%';
         FOR date_rec_ IN get_dates LOOP
            IF (new_due_date_ >= date_rec_.start_date AND 
                new_due_date_ <= date_rec_.end_date) THEN
               new_due_date_ := date_rec_.new_due_date;
               found_ := TRUE;
               changed_new_due_date_ := TRUE;
            END IF;
         END LOOP;
      END IF;
      IF NOT (found_ = TRUE) THEN
         customer_    := temp_cust_;
         payment_way_ := '%';
         FOR date_rec_ IN get_dates LOOP
            IF (new_due_date_ >= date_rec_.start_date AND 
                new_due_date_ <= date_rec_.end_date) THEN
               new_due_date_ := date_rec_.new_due_date;
               found_ := TRUE;
               changed_new_due_date_ := TRUE;
            END IF;
         END LOOP;
      END IF;
      IF NOT (found_ = TRUE) THEN
         customer_ := '%';
         payment_way_ := '%';
         FOR date_rec_ IN get_dates LOOP
            IF (new_due_date_ >= date_rec_.start_date AND 
                new_due_date_ <= date_rec_.end_date) THEN
               new_due_date_ := date_rec_.new_due_date;
               found_ := TRUE;
               changed_new_due_date_ := TRUE;
            END IF;
         END LOOP;
      END IF;
      EXIT WHEN changed_new_due_date_ = FALSE;
   END LOOP;
   RETURN new_due_date_;
END Get_New_Vac_Due_Date;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN  VARCHAR2,
   run_in_background_ IN  BOOLEAN,
   log_id_            IN  NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   payment_method_list_    VARCHAR2(2000);
   customer_id_list_       VARCHAR2(2000);
   start_date_list_        VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Payment_Vacation_Period_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'PAYMENT_METHOD_LIST') THEN
            payment_method_list_ := value_;
         ELSIF (name_ = 'CUSTOMER_ID_LIST') THEN
            customer_id_list_ := value_;
         ELSIF (name_ = 'START_DATE_LIST') THEN
            start_date_list_ := value_;         
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                   target_company_list_,
                                   payment_method_list_,
                                   customer_id_list_,
                                   start_date_list_,
                                   update_method_list_,
                                   log_id_,
                                   attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

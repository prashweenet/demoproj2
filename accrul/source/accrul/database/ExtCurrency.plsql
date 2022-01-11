-----------------------------------------------------------------------------
--
--  Logical unit: ExtCurrency
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000119  Ruwan Created
--  000912  HiMu  Added General_SYS.Init_Method
--  010402  Uma   Corrected Bug# 20944. Added Procedure Start_Online_Process_.
--  010911  JeGu  Bug #24286 Added column inverted. Changed some procedures/functions
--  020116  JeGu  Added External File handling
--  020123  JeGu  Removed all Design-generated view,functions,procedures
--                This information is now stored in Ext_File_Trans_Tab
--  0510302 AsHelk Merged LCS Bug 47218.
--  090211  Jeguse Bug 79498 Corrected
--  100426  Jaralk bug 89531 Corrected, New parameter added 'conv_fact_considered_' to file type 'ExtCurrency" when using           
--  Automatic Currency Update Wizard to select the option whether the multiplication by conversion factor should be done or no
--  160907  AjPelk STRFI-3450 Merged LCS bug 130758.
--  190620  Nudilk Bug 148930, Corrected Update_Currency_Rates.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Update_Currency_Rates (
   company_                IN  VARCHAR2,
   base_currency_          IN  VARCHAR2,
   currency_type_          IN  VARCHAR2,
   inverted_               IN  VARCHAR2,
   file_template_id_       IN  VARCHAR2,
   file_type_              IN  VARCHAR2,
   file_name_              IN  VARCHAR2,
   id_                     IN  NUMBER,
   trans_update_           IN  VARCHAR2 DEFAULT 'TRUE',
   conv_fact_considered_   IN  VARCHAR2 DEFAULT NULL )
IS
   cal_curr_rate_     NUMBER;
   dummy_             NUMBER;
   conv_factor_       NUMBER;
   ref_inverted_      VARCHAR2(5);
   ref_curr_rate_     NUMBER;
   rate_attr_         VARCHAR2(32000);
   objid_             VARCHAR2(30) ;
   objversion_        VARCHAR2(30) ;
   newinfo_           VARCHAR2(2000) ;
   counter_           NUMBER := 0;
   error_text_        VARCHAR2(2000);
   parallel_curr_     BOOLEAN := FALSE;
   currency_type_rec_ Currency_Type_API.Public_Rec;
   
   CURSOR get_ext_curr_rates IS
      SELECT c1 currency_code,
             n1 currency_rate,
             d1 valid_from,
             row_no
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = id_
      AND    row_state    IN ('2','3','5')
      AND    c1 IS NOT NULL
      FOR UPDATE;
   CURSOR currency_code_exist (company_ VARCHAR2,
                              curr_code_ VARCHAR2) IS
      SELECT 1
      FROM   Currency_Code_Tab
      WHERE  company       = company_
      AND    currency_code = curr_code_;
   CURSOR get_comp_curr_rate (curr_code_ VARCHAR2) IS
      SELECT n1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id  = id_
      AND    c1            = curr_code_;
   CURSOR currency_rate_exist (company_ VARCHAR2,
                               curr_type_ VARCHAR2,
                               curr_code_ VARCHAR2,
                               valid_from_ date) IS
      SELECT 1
      FROM   currency_rate_tab
      WHERE  company       = company_
      AND    currency_type = curr_type_
      AND    currency_code = curr_code_
      AND    valid_from    = valid_from_;
BEGIN
   currency_type_rec_ := Currency_Type_API.Get(company_, currency_type_);
   ref_inverted_      := Currency_Code_API.Get_Inverted (company_,
                                                         currency_type_rec_.ref_currency_code);
                                                         
   IF (NVL(Company_Finance_API.Get_Parallel_Base_Db(company_), ' ') = 'TRANSACTION_CURRENCY') THEN
      IF (currency_type_rec_.rate_type_category = 'PARALLEL_CURRENCY') THEN
         parallel_curr_ := TRUE;
      END IF;
   END IF;
   
   --base_curr_found_ := TRUE;
   --OPEN ext_currency_exist ( base_currency_);
   --FETCH ext_currency_exist INTO dummy_;
  -- IF (ext_currency_exist%NOTFOUND) THEN
   --   base_curr_found_ := FALSE;
   --   Error_Sys.Record_General(lu_name_, 'NOBCURR: Base Currency :P1 not found in the Currency Rate File :P2',base_currency_,file_name_);
  -- END IF;
   --CLOSE ext_currency_exist;
   --IF (base_curr_found_) THEN
      FOR get_rate_ IN get_ext_curr_rates LOOP -- from Ext_File_Trans_Tab
         Trace_SYS.Message ('get_rate_.currency_code : '||get_rate_.currency_code);
         Trace_SYS.Message ('get_rate_.currency_rate : '||TO_CHAR(get_rate_.currency_rate));
         Trace_SYS.Message ('get_rate_.valid_from    : '||TO_CHAR(get_rate_.valid_from,'yyyy-mm-dd'));
         OPEN currency_code_exist (company_,
                                   get_rate_.currency_code);
         FETCH currency_code_exist INTO dummy_;
         IF (currency_code_exist%FOUND) THEN
            conv_factor_ := Currency_Code_API.Get_Conversion_Factor (company_,
                                                                     get_rate_.currency_code);
            Trace_SYS.Message ('conv_factor_ : '||TO_CHAR(conv_factor_));
            
            IF (currency_type_rec_.ref_currency_code = base_currency_ OR parallel_curr_) THEN   -- If base currency of company = base currency in text file
               IF (inverted_ = 'TRUE') THEN
                  cal_curr_rate_ := get_rate_.currency_rate;
               ELSE
                  IF (conv_fact_considered_ IS NULL) THEN
                     cal_curr_rate_ := get_rate_.currency_rate  * conv_factor_;
                  ELSIF (conv_fact_considered_ = 'N') THEN                   
                     cal_curr_rate_ := get_rate_.currency_rate  * conv_factor_;
                  ELSIF (conv_fact_considered_ = 'Y')THEN
                     cal_curr_rate_ := get_rate_.currency_rate;
                                       
                  END IF;
               END IF;

            ELSE
               -- Note: This code should be revisited in next core as this could lead to incorrect currency rates.               
               OPEN get_comp_curr_rate (currency_type_rec_.ref_currency_code);        --from Ext_Currency
               FETCH get_comp_curr_rate INTO ref_curr_rate_;
               IF (get_comp_curr_rate%FOUND) THEN
                  IF (inverted_ = 'TRUE') THEN
                     cal_curr_rate_ := (get_rate_.currency_rate / ref_curr_rate_ );
                  ELSE
                     IF (conv_fact_considered_ IS NULL) THEN
                        cal_curr_rate_ := (get_rate_.currency_rate / ref_curr_rate_ ) * conv_factor_;
                     ELSIF (conv_fact_considered_ = 'N') THEN
                        cal_curr_rate_ := (get_rate_.currency_rate / ref_curr_rate_ ) * conv_factor_;                      
                     ELSIF (conv_fact_considered_ = 'Y') THEN
                        cal_curr_rate_ := (get_rate_.currency_rate / ref_curr_rate_ ); 
                     END IF;
                  END IF;
                  CLOSE get_comp_curr_rate;
               ELSE
                  -- Base Currency of the file is different from the reference currency
                  -- Therefore Reference Currency should be there in ext file to calculate Currency rates
                  CLOSE get_comp_curr_rate;
                  Error_Sys.Record_General(lu_name_, 'NOREFCURR: Reference Currency :P1 not found in the Currency Rate File :P2',currency_type_rec_.ref_currency_code,file_name_);
               END IF;
            END IF;
            IF (inverted_ != 'TRUE' AND ref_inverted_ = 'TRUE') THEN
               IF (conv_fact_considered_ IS NULL) THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_/conv_factor_)) * conv_factor_;
               ELSIF (conv_fact_considered_ = 'N') THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_/conv_factor_)) * conv_factor_;                  
               ELSIF  (conv_fact_considered_ = 'Y') THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_)); 
               END IF;
            ELSIF (inverted_ = 'TRUE' AND ref_inverted_ != 'TRUE') THEN
               IF (conv_fact_considered_ IS NULL) THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_)) * conv_factor_;
               ELSIF (conv_fact_considered_ = 'N') THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_)) * conv_factor_;                  
               ELSIF  (conv_fact_considered_ = 'Y') THEN
                  cal_curr_rate_ := (1/(cal_curr_rate_)); 
               END IF;
            END IF;
            
            -- If Reference Currency is present in Text File Then The Currency rate should be equal to conversion factor.
            IF (get_rate_.currency_code = currency_type_rec_.ref_currency_code)  THEN
               IF (cal_curr_rate_ != conv_factor_) THEN
                  Error_Sys.Record_General(lu_name_, 'RATENOTEQUALDIVFACTOR: Currency Rate of the Reference Currency :P1 should be equal to the Conversion Factor. File :P2', currency_type_rec_.ref_currency_code,file_name_);
               END IF;
            END IF;
            
            Client_SYS.Clear_Attr(rate_attr_);
            Client_SYS.Add_To_Attr('COMPANY',           company_,                                  rate_attr_);
            Client_SYS.Add_To_Attr('CURRENCY_CODE',     get_rate_.currency_code,                   rate_attr_);
            Client_SYS.Add_To_Attr('VALID_FROM',        get_rate_.valid_from,                      rate_attr_);
            Client_SYS.Add_To_Attr('CURRENCY_TYPE',     currency_type_,                            rate_attr_);
            Client_SYS.Add_To_Attr('CURRENCY_RATE',     cal_curr_rate_,                            rate_attr_);
            Client_SYS.Add_To_Attr('CONV_FACTOR',       conv_factor_,                              rate_attr_);
            Client_SYS.Add_To_Attr('REF_CURRENCY_CODE', currency_type_rec_.ref_currency_code,      rate_attr_);
            OPEN currency_rate_exist (company_,
                                      currency_type_,
                                      get_rate_.currency_code,
                                      get_rate_.valid_from);
            FETCH currency_rate_exist INTO dummy_;
            IF (currency_rate_exist%NOTFOUND) THEN
               Currency_Rate_API.New__(newinfo_,
                                       objid_,
                                       objversion_,
                                       rate_attr_,
                                       'DO') ;
               IF (trans_update_ = 'TRUE') THEN
                  Ext_File_Trans_API.Update_Row_State (id_,
                                                       get_rate_.row_no,
                                                       '3');
               END IF;
               counter_ := counter_ + 1;
            ELSE
               error_text_ := Language_SYS.Translate_Constant ('EXT_CURRENCY_API', 'CRATEVALIDF: Currency rate with same valid from date already exist');
               Ext_File_Trans_API.Update_Row_State (id_,
                                                    get_rate_.row_no,
                                                    '5',
                                                    error_text_);
            END IF;
            CLOSE currency_rate_exist;
         ELSE
            error_text_ := Language_SYS.Translate_Constant ('EXT_CURRENCY_API', 'CURRNOTEXT: Currency code does not exist');
            Ext_File_Trans_API.Update_Row_State (id_,
                                                 get_rate_.row_no,
                                                 '5',
                                                 error_text_);
         END IF;
         CLOSE currency_code_exist;
      END LOOP;
  -- END IF;
END Update_Currency_Rates;


PROCEDURE Start_Ext_Currency (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER,
   parameter_string_ IN     VARCHAR2 DEFAULT NULL)
IS
   ext_file_load_rec_       Ext_File_Load_API.Public_Rec;
   parameter_attr_          VARCHAR2(2000);
   company_                 VARCHAR2(20);
   task_id_                 VARCHAR2(20);
   currency_type_           VARCHAR2(10);
   base_currency_           VARCHAR2(3);
   rates_inverted_          VARCHAR2(5);
   file_template_id_        VARCHAR2(30);
   file_type_               VARCHAR2(30);
   file_name_               VARCHAR2(2000);
   tmp_                     VARCHAR2(2000) := NULL;
   dummy_                   VARCHAR2(10)   := '<DUMMY>';
   load_state_              VARCHAR2(200);
   err_msg_                 VARCHAR2(2000);
   conv_fact_considered_       VARCHAR2(5);
BEGIN
   ext_file_load_rec_ := Ext_File_Load_API.Get (load_file_id_);
   IF (parameter_string_ IS NOT NULL) THEN
      parameter_attr_ := parameter_string_;
   ELSE
      parameter_attr_ := ext_file_load_rec_.parameter_string;
   END IF;
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_TYPE', file_type_);
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_TEMPLATE_ID',   file_template_id_);
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_NAME', file_name_);
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'COMPANY',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      company_ := tmp_;
   ELSE
      company_ := NULL;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'TASK_ID',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      task_id_ := tmp_;
   ELSE
      task_id_ := NULL;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'CURRENCY_TYPE',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      currency_type_ := tmp_;
   ELSE
      currency_type_ := NULL;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'BASE_CURRENCY',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      base_currency_ := tmp_;
   ELSE
      base_currency_ := NULL;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'RATES_INVERTED',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      rates_inverted_ := tmp_;
   ELSE
      rates_inverted_ := NULL;
   END IF;

   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'CONVERSION_FACTOR_CONSIDERED',
                                       dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      conv_fact_considered_ := tmp_;
   ELSE
      conv_fact_considered_ := NULL;
   END IF;
     
   IF (ext_file_load_rec_.state != '3' ) THEN
      load_state_ := Ext_File_State_API.Decode(ext_file_load_rec_.state);
      Error_SYS.Record_General( lu_name_, 'EXTLOADNOTUNP: Load File Id :P1 has wrong state :P2', load_file_id_, load_state_ );
   END IF;
   Trace_SYS.Message ('load_file_id_      : '||load_file_id_);
   Trace_SYS.Message ('company_           : '||company_);
   Trace_SYS.Message ('file_type_         : '||file_type_);
   Trace_SYS.Message ('file_template_id_  : '||file_template_id_);
   Trace_SYS.Message ('file_name_         : '||file_name_);
   Trace_SYS.Message ('task_id_           : '||task_id_);
   Trace_SYS.Message ('currency_type_     : '||currency_type_);
   Trace_SYS.Message ('base_currency_     : '||base_currency_);
   Trace_SYS.Message ('rates_inverted_    : '||rates_inverted_);

   IF (task_id_ IS NULL) THEN
      Ext_Currency_API.Update_Currency_Rates ( company_,
                                               base_currency_,
                                               currency_type_,
                                               rates_inverted_,
                                               file_template_id_,
                                               file_type_,
                                               file_name_,
                                               load_file_id_,
                                               'FALSE',
                                               conv_fact_considered_ );
   ELSE
      Ext_Currency_API.Start_Task_Process ( task_id_,
                                            load_file_id_,
                                            file_type_,
                                            file_template_id_,
                                            file_name_,
                                            base_currency_,
                                            rates_inverted_ ,
                                            conv_fact_considered_);
   END IF;
   Ext_File_Load_API.Update_State ( load_file_id_,
                                    '4' );
   Ext_File_Trans_API.Update_State_Load ( load_file_id_,
                                          '2',
                                          '3' );
   err_msg_ := 'RATESUPDATED: Currency Rates Are Updated';
   Trace_SYS.Message ('err_msg_   : '||err_msg_);
   Client_SYS.Clear_Info;
   Client_SYS.Add_Info(lu_name_, 'RATESUPDATED: Currency Rates Are Updated');
   info_ := Client_SYS.Get_All_Info;
   Trace_SYS.Message ('info_      : '||info_);
END Start_Ext_Currency;


PROCEDURE Start_Task_Process (
   task_id_              IN VARCHAR2,
   load_file_id_         IN VARCHAR2,
   file_type_            IN VARCHAR2,
   file_template_id_     IN VARCHAR2,
   file_name_            IN VARCHAR2,
   base_currency_        IN VARCHAR2,
   rates_inverted_       IN VARCHAR2,
   conv_fact_considered_ IN VARCHAR2 DEFAULT NULL )
IS
   CURSOR get_task_det IS
      SELECT *
      FROM   Ext_Currency_Task_Detail
      WHERE  task_id = task_id_;
BEGIN
   FOR rec_ IN get_task_det LOOP
      Ext_Currency_API.Update_Currency_Rates ( rec_.company,
                                               base_currency_,
                                               rec_.currency_type,
                                               rates_inverted_,
                                               file_template_id_,
                                               file_type_,
                                               file_name_,
                                               load_file_id_,
                                               'FALSE',
                                               conv_fact_considered_ );
   END LOOP;
END Start_Task_Process;




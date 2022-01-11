-----------------------------------------------------------------------------
--
--  Logical unit: CurrencyRate
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960319  PEJON    Created
--  960605  PiBu     'FLAGS=AMI-L^ on col. valid_from is deliberately set to Not
--                   key Flags to solve Lov using CURRENCY(COMPANY,CURRENCY_TYPE)
--                   solution.
--  961016  JOBJ     Modified according to the report Generator
--  970311  AnDj     Added Function Get_Rounded_Currency_Rate
--  970415  VIGU     Currency rate is rounded to the number of decimals in currency
--                   rate specified in Currency Code LU before saving.
--  970417  VIGU     Modified Get_Currency_Rate function, made clause valid_from < date_
--                   to valid_from <= date_
--  970718  SLKO     Converted to Foundation1 1.2.2d
--  971024  PICZ     Added function Check_If_Curr_Rate_Exists
--  980106  SLKO     Converted to Foundation1 2.0.0
--  981016  PRASI    The Following Function are added/modified To support for the Triangulation Functionality.
--                   Check_Delete___ , Unpack_Check_Insert___ , Unpack_Check_Update___
--                   Check_Emu_Currency
--  981017  PRASI    The functions Get_Max_Date___, Get_Default_Curr_Rate___, Get_Default_Conv_Factor___
--                   and Get_Def_Rate_And_Conv___ were added. A major re-write was done on the
--                   Get_Currency_Rate function/procedure and the Get_Conv_factor function
--                   to handle Triangulation. This included the addition of three default input
--                   parameters to these functions.
--  990303  MANGI    Changed Get_Currency_Rate_Default so that to take values from type 1, if the Cur
--                   code is ref cur.
--  990419  NiHe     Modified with respect to new template
--  990925  Channa   Fixed bug in function Currency_Rate___
--  000912  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001027  Bren     View5 was created for WEB's request. Added new function Currency_Rate_Base_Disp to display the
--                   rate before invertion. Ie the way the user wishes to see the rate.
--  001130  OVJOSE   For new Create Company concept added new view currency_rate_ect and currency_rate_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020312  ovjose   Removed Create Company translation method Create_Company_Translations___
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020324  Shsalk   Call Id 73590 Corrected.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in CURRENCY_RATE
--                   CURRENCY_RATE1,CURRENCY_RATE2,LATEST_CURRENCY_RATES  and ALL_CURRENCY_RATES_WEB view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021025  KuPelk   Call Id 90634 Corrected that error message in Unpack_Check_insert and Unpack_Check_Update methods.
--  030513  SaAblk   Moved Get_Currency_Rates from Company_Finance to this LU as Get_Currency_Rates_For_Company
--  030731  prdilk   SP4 Merge.
--  030922  Thsrlk   Validation for currency code in Methord Import__ ;
--  040323  Gepelk   2004 SP1 Merge
--  041025  Nalslk   FITH354 - Modified method Get_Currency_Rate_Defaults
--  060106  Samwlk   LCS Bug 54576 Merged.
--  060125  Nalslk   Ignored period checks to enable account specific currency rates for revaluation.
--  060727  DHSELK   Modified to_date() function to work with Persian Calander.
--  0601024 AmNilk   Merged LCS Bug 57849, changed RATEINCORRECT error message
--  070515  Chsalk   LCS Merge 62300, changed NODATE error message to NOVAL
--  071026  RUFELK   Bug 68433, Modified the Unpack_Check_Insert___() method.
--  071101  RUFELK   Bug 68433, Modified the CURRENCY_RATE2 view.
--  090717  ErFelk   Bug 83174, Replaced constant ERROR8 with ERROR4 in Display_Error___.
--  090727  Gadalk   Bug 83230, Added Get_Curr_Rate_Data(). (Merge from app7)
--  090812  Roralk   Bug 85238, Added 'ELSE' part to the function 'Get_Curr_Rate_Data'.
--  090819  Gadalk   Bug 82764, Modified Unpack_Check_Insert___.
--  100423  SaFalk   Modified REF for currency_type in CURRENCY_RATE1 and CURRENCY_RATE2.
--  100729  Ersruk   Added method Get_Project_Currency_Rate().
--  100803  Janslk   Added view CURRENCY_RATES_PER_RATE_TYPE.
--  100806  Janslk   Changed Unpack_Check_Insert___ to check both Normal and 
--                   Project currency types.
--  101115  Chselk   Overloaded the methods Display_Error___,Check_If_Curr_Code_Exists. Renamed method Get_Project_Currency_Rate() to
--                   Get_Currency_Conversion_Rate(). Modified the methods to add a option to pass the error message as an out parameter. 
--  110106  Janslk   Added currency code as a parameter to Display_Error___ methods.
--  110419  Shhelk   EASTONE-15969 Passed currency_code_ instead of base_currency_code_ in Fetch_Currency_Rate_Base()
--  110822  Anwese   Added view CURRENCY_RATE_MV_HLP
--  121123  Janblk   DANU-122, Parallel currency implementation  
--  121207  ovjose   DANU-264, Removed interfaces Get_Parr_Curr_Rate, Get_Third_Currency_Rate.
--                   The methods does not support if transaction currency is bas for parallel currency
--  130801  ovjose   Added columns direct_currency_rate/_round for better performance in BI to use direct rates when performing calculations
--  131030  Umdolk   PBFI-1880, Refactoring
--  14-124  Umdolk   PBFI-4964, Added custom check exist method for currency type and removed code from Check_Insert___.
--  190802  Nudilk   Bug 149273, Provided overloaded methods to handle security based on project acess.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE RATE_DATA_REC_TYPE IS RECORD (
                            currency_rate  NUMBER,
                            conv_factor    NUMBER,
                            error_code     NUMBER,
                            currency_type  VARCHAR2(10),
                            inverted       VARCHAR2(5));

TYPE CurrRateInfoRecType IS RECORD (
                            currency_rate       NUMBER,
                            conv_factor         NUMBER,
                            curr_rate_base_disp NUMBER,
                            currency_type       VARCHAR2(10),
                            inverted            VARCHAR2(5));


-------------------- PRIVATE DECLARATIONS -----------------------------------

-- Cache for the Get_Max_Date___ method Start
TYPE code_cache_maxdate_tab IS TABLE OF DATE INDEX BY VARCHAR2(50);
micro_cache_maxdate_tab_        code_cache_maxdate_tab;
micro_cache_maxdate_time_       NUMBER := 0;
micro_cache_maxdate_user_       VARCHAR2(30);   

TYPE Linked_Date_Cache IS TABLE OF      VARCHAR2(50) INDEX BY PLS_INTEGER;
micro_cache_date_link_tab_              Linked_Date_Cache;
micro_cache_date_max_id_                PLS_INTEGER;
-- estimating that setting a cache size that would fit a bit more than a year (365 days) is enough and also not consume to much memory
max_cached_date_element_count_          CONSTANT NUMBER := 400;  
max_cached_date_element_life_           CONSTANT NUMBER := 10;
-- Cache for the Get_Max_Date___ method End

-- Cache for the Get_Attributes___ method Start
TYPE code_cache_rate_rec_tab IS TABLE OF RATE_DATA_REC_TYPE INDEX BY VARCHAR2(50);
micro_cache_rate_rec_tab_        code_cache_rate_rec_tab;
micro_cache_rate_rec_time_       NUMBER := 0;
micro_cache_rate_rec_user_       VARCHAR2(30);

TYPE Linked_Rate_Rec_Cache IS TABLE OF      VARCHAR2(50) INDEX BY PLS_INTEGER;
micro_cache_rec_link_tab_              Linked_Rate_Rec_Cache;
micro_cache_rec_max_id_                PLS_INTEGER;
-- estimating that setting a cache size that would fit a bit more than a year (365 days) is enough and also not consume to much memory
max_cached_rec_element_count_          CONSTANT NUMBER := 400; 
max_cached_rec_element_life_           CONSTANT NUMBER := 10;
-- Cache for the Get_Attributes___ method End

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Currency_Rate___ (
   company_            IN VARCHAR2,
   currency_type_      IN VARCHAR2,
   currency_code_      IN VARCHAR2,
   base_currency_code_ IN VARCHAR2,
   date_               IN DATE,
   is_base_emu_        IN VARCHAR2 ) RETURN RATE_DATA_REC_TYPE
IS
   is_curr_code_emu_       VARCHAR2(5);
   ref_curr_inverted_      VARCHAR2(5);
   max_date_               DATE;
   -- default euro type
   def_eur_curr_type_      VARCHAR2(20);
   -- default base type
   def_base_curr_type_     VARCHAR2(20);
   -- try to increase preformance.
   date_base_join_euro_    DATE;
   date_trans_join_euro_   DATE;
   error_code_             NUMBER;
   -- records
   base_to_eur_rec_        RATE_DATA_REC_TYPE;
   trans_to_eur_rec_       RATE_DATA_REC_TYPE;
   return_rec_             RATE_DATA_REC_TYPE;
   -- exception
   stop_execution          EXCEPTION;
BEGIN
   -- 1.   Init variables
   -- 1.1  Compare dates
   -- 1.1  Check currency and company attributes
   is_curr_code_emu_   := Currency_Code_API.Get_Valid_Emu( company_, currency_code_, date_ );
   ref_curr_inverted_  := Currency_Code_API.Get_Inverted( company_, base_currency_code_ );
   -- 1.2  Try to override currency_type?
   IF ( is_base_emu_ = 'TRUE' OR is_curr_code_emu_ = 'TRUE' ) THEN
      -- 1.2.1 Check if the currency type is a default type
      def_eur_curr_type_ := Currency_Type_API.Get_Default_Euro_Type__( company_ );
   END IF;

   -- 1.3  Compare dates
   IF is_base_emu_ = 'TRUE' THEN
      date_base_join_euro_ :=  Get_Max_Eur_Date(company_, base_currency_code_, def_eur_curr_type_);
   END IF;

   IF is_curr_code_emu_ = 'TRUE' THEN
      date_trans_join_euro_ :=  Get_Max_Eur_Date(company_, currency_code_, def_eur_curr_type_);
   END IF;

   -- 1.4  Part of return value
   error_code_      := 0;  -- set code 0 ( no error ) as default, assign other value when error.

   -- start logic
   IF  ( base_currency_code_ != 'EUR' )  THEN
      -- Triangulation must be performed
      IF ( ( is_base_emu_ = 'FALSE' ) AND ( is_curr_code_emu_ = 'TRUE' ) ) THEN -- case one
         -- The currency type should not have the reference currency as 'EUR'. This would
         -- cause the base_to_eur_rec_.currency_rate to be incorrect.
         IF (Currency_Type_API.Get_Ref_Currency_Code( company_, currency_type_ ) = 'EUR') THEN
            def_base_curr_type_ := Currency_Type_API.Get_Default_Type( company_ );
         ELSE
            def_base_curr_type_ := currency_type_;
         END IF;
         -- The currency type has to contain a rate between base currency and Euro
         max_date_  := Get_Max_Date___(company_, def_base_curr_type_, 'EUR', date_);
         IF max_date_ IS NULL THEN
            error_code_ := 2;  -- There is no rate between base curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         base_to_eur_rec_ := Get_Attributes___ ( company_, def_base_curr_type_, 'EUR', max_date_);

         IF ( base_to_eur_rec_.error_code = -1 ) THEN
            error_code_ := 2;  -- There is no rate between base curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         trans_to_eur_rec_ := Get_Attributes___ ( company_, def_eur_curr_type_, currency_code_, date_trans_join_euro_ );
         IF ( trans_to_eur_rec_.error_code = -1 ) THEN
            error_code_ := 3;  -- There is no rate between trans curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         IF ref_curr_inverted_ = 'FALSE' THEN
            return_rec_.currency_rate := (((base_to_eur_rec_.currency_rate / base_to_eur_rec_.conv_factor) / (trans_to_eur_rec_.currency_rate / trans_to_eur_rec_.conv_factor)) * trans_to_eur_rec_.conv_factor);
            return_rec_.conv_factor := trans_to_eur_rec_.conv_factor;
            return_rec_.inverted := 'FALSE';
         ELSE
            return_rec_.currency_rate := (((base_to_eur_rec_.currency_rate / base_to_eur_rec_.conv_factor) * (trans_to_eur_rec_.currency_rate / trans_to_eur_rec_.conv_factor)) * trans_to_eur_rec_.conv_factor);
            return_rec_.conv_factor := trans_to_eur_rec_.conv_factor;
            return_rec_.inverted := 'TRUE';
         END IF;
      ELSIF ( ( is_base_emu_ = 'TRUE' ) AND ( is_curr_code_emu_ = 'TRUE' ) ) THEN -- case two
         -- Only the currency rates given in the default currency type having ref currency EUR are considered
         -- Now only default rate types...
         base_to_eur_rec_ := Get_Attributes___ ( company_, def_eur_curr_type_, base_currency_code_, date_base_join_euro_ );
         IF ( base_to_eur_rec_.error_code = -1 ) THEN
            error_code_ := 2;  -- There is no rate between base curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         trans_to_eur_rec_ := Get_Attributes___ ( company_, def_eur_curr_type_, currency_code_, date_trans_join_euro_ );
         IF ( trans_to_eur_rec_.error_code = -1 ) THEN
            error_code_ := 3;  -- There is no rate between trans curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         return_rec_.currency_rate := (((base_to_eur_rec_.currency_rate / base_to_eur_rec_.conv_factor) / (trans_to_eur_rec_.currency_rate / trans_to_eur_rec_.conv_factor)) * trans_to_eur_rec_.conv_factor);
         return_rec_.conv_factor := trans_to_eur_rec_.conv_factor;
         return_rec_.inverted := 'FALSE';
      ELSIF ( ( is_base_emu_ = 'TRUE' ) AND ( is_curr_code_emu_ = 'FALSE' ) ) THEN  -- case three
         -- The base to EURO conversion rate is got from the default currency type having ref currency EUR
         base_to_eur_rec_ := Get_Attributes___ ( company_, def_eur_curr_type_, base_currency_code_, date_base_join_euro_ );
         IF ( base_to_eur_rec_.error_code = -1 ) THEN
            error_code_ := 2;  -- There is no rate between base curr and Euro
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         -- The rate between EURO and the transaction currency would be dependent on the currency type ONLY if the currency type
         -- has a ref currency EUR.
         IF (Currency_Type_API.Get_Ref_Currency_Code( company_, currency_type_ ) = 'EUR') THEN
            max_date_  := Get_Max_Date___(company_, currency_type_, currency_code_, date_);
            IF max_date_ IS NULL THEN
               error_code_ := 4;  -- The currency code is not valid in the currency type
               return_rec_.error_code := error_code_;
               RAISE stop_execution;
            END IF;
            trans_to_eur_rec_ := Get_Attributes___ ( company_, currency_type_, currency_code_, max_date_ );
            IF ( trans_to_eur_rec_.error_code = -1 ) THEN
               error_code_ := 5;  -- There is no rate for the transaction currency in the currency type
               return_rec_.error_code := error_code_;
               RAISE stop_execution;
            END IF;
         ELSE
         -- The rate between EURO and the transaction currency would have to be specified in the default currency type with
         -- ref currency EUR.
            max_date_  := Get_Max_Date___(company_, def_eur_curr_type_, currency_code_, date_);
            IF max_date_ IS NULL THEN
               error_code_ := 6;  -- The currency code is not valid in the default EURO currency type
               return_rec_.error_code := error_code_;
               RAISE stop_execution;
            END IF;
            trans_to_eur_rec_ := Get_Attributes___ ( company_, def_eur_curr_type_, currency_code_, max_date_ );
            IF ( trans_to_eur_rec_.error_code = -1 ) THEN
               error_code_ := 7;  -- There is no rate between trans curr and Euro in default currency type
               return_rec_.error_code := error_code_;
               RAISE stop_execution;
            END IF;
         END IF;
         return_rec_.currency_rate := (((base_to_eur_rec_.currency_rate / base_to_eur_rec_.conv_factor) / (trans_to_eur_rec_.currency_rate / trans_to_eur_rec_.conv_factor)) * trans_to_eur_rec_.conv_factor);
         return_rec_.conv_factor := trans_to_eur_rec_.conv_factor;
         return_rec_.inverted := 'FALSE';
      ELSE
     -- No Triangulation is done. Same as before.
         max_date_  := Get_Max_Date___(company_, currency_type_, currency_code_, date_);
         IF max_date_ IS NULL THEN
            error_code_ := 8;  -- The currency code is not valid in the currency type
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         return_rec_ := Get_Attributes___ ( company_, currency_type_, currency_code_, max_date_ );
         IF ( return_rec_.error_code = -1 ) THEN
            error_code_ := 9;  -- No rate between currency and accounting currency
            return_rec_.error_code := error_code_;
            RAISE stop_execution;
         END IF;
         IF ref_curr_inverted_ = 'FALSE' THEN
            return_rec_.inverted := 'FALSE';
         ELSE
            return_rec_.inverted := 'TRUE';
         END IF;
      END IF;
   ELSE
   -- No Triangulation is done. Same as before.
      max_date_  := Get_Max_Date___(company_, currency_type_, currency_code_, date_);
      IF max_date_ IS NULL THEN
         error_code_ := 8;  -- The currency code is not valid in the currency type
         return_rec_.error_code := error_code_;
         RAISE stop_execution;
      END IF;
      return_rec_ := Get_Attributes___ ( company_, currency_type_, currency_code_, max_date_ );
      IF ( return_rec_.error_code = -1 ) THEN
         error_code_ := 9;  -- No rate between currency and accounting currency
         return_rec_.error_code := error_code_;
         RAISE stop_execution;
      END IF;
      IF ref_curr_inverted_ = 'FALSE' THEN
         return_rec_.inverted := 'FALSE';
      ELSE
         return_rec_.inverted := 'TRUE';
      END IF;
   END IF;
   return_rec_.error_code := error_code_;
   RETURN return_rec_;
EXCEPTION
   WHEN stop_execution THEN
      RETURN return_rec_;
END Currency_Rate___;


PROCEDURE Invalidate_Date_Cache___
IS
BEGIN
   micro_cache_maxdate_tab_.delete;
   micro_cache_maxdate_time_ := 0;
   micro_cache_date_link_tab_.delete;
   micro_cache_date_max_id_ := 0;   
END Invalidate_Date_Cache___;

PROCEDURE Invalidate_Rate_Cache___
IS
BEGIN
   micro_cache_rate_rec_tab_.delete;
   micro_cache_rate_rec_time_ := 0;         
   micro_cache_rec_link_tab_.delete;
   micro_cache_rec_max_id_ := 0;   
END Invalidate_Rate_Cache___;

PROCEDURE Invalidate_Micro_Caches___
IS  
BEGIN
   -- max date cache
   Invalidate_Date_Cache___;      
   -- rec cache (used by Get_Attribute___)
   Invalidate_Rate_Cache___; 
END Invalidate_Micro_Caches___;

FUNCTION Get_Max_Date___ (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   date_          IN DATE ) RETURN DATE
IS
   max_date_          DATE;   
   time_              NUMBER;
   expired_           BOOLEAN := FALSE;   
   req_id_            VARCHAR2(50) := company_ ||'^'|| currency_type_ ||'^'|| currency_code_ ||'^'|| TO_CHAR(date_, 'YYYY-MM-DD');         
   date_null_         DATE;  
   not_found          EXCEPTION;   
   
   CURSOR get_max_date IS
      SELECT   max(valid_from)      
      FROM     CURRENCY_RATE_TAB
      WHERE    company       =  company_
      AND      currency_code =  currency_code_
      AND      currency_type =  currency_type_
      AND      valid_from    <= date_ ;
BEGIN      
   time_    := Database_SYS.Get_Time_Offset;
   expired_ := ((time_ - micro_cache_maxdate_time_) > max_cached_date_element_life_);        
      
   IF (expired_ OR (micro_cache_maxdate_user_ IS NULL) OR (micro_cache_maxdate_user_ != Fnd_Session_API.Get_Fnd_User)) THEN
      Invalidate_Date_Cache___;
      micro_cache_maxdate_user_ := Fnd_Session_API.Get_Fnd_User;
   END IF;      

   IF (NOT micro_cache_maxdate_tab_.exists(req_id_)) THEN
      OPEN  Get_max_date;
      FETCH Get_max_date INTO max_date_;
      CLOSE Get_max_date;  
      
      IF (max_date_ IS NULL) THEN         
         RAISE not_found;
      END IF;      

      IF (micro_cache_maxdate_tab_.count >= max_cached_date_element_count_) THEN         
         DECLARE
            random_  NUMBER := NULL;
            element_ VARCHAR2(1000);
         BEGIN
            random_ := round(dbms_random.value(1, max_cached_date_element_count_), 0);
            element_ := micro_cache_date_link_tab_(random_);            
            micro_cache_maxdate_tab_.delete(element_);
            micro_cache_date_link_tab_.delete(random_);
            micro_cache_date_link_tab_(random_) := req_id_;
         END;
      ELSE
         micro_cache_date_max_id_ := micro_cache_date_max_id_ + 1;
         micro_cache_date_link_tab_(micro_cache_date_max_id_) := req_id_;
      END IF;      
      micro_cache_maxdate_tab_(req_id_) := max_date_;
      micro_cache_maxdate_time_ := time_;
   END IF;
   RETURN micro_cache_maxdate_tab_(req_id_);        
EXCEPTION
   WHEN not_found THEN      
      micro_cache_maxdate_tab_.delete(req_id_);
      micro_cache_maxdate_time_  := time_;
      RETURN date_null_;
END Get_Max_Date___;


FUNCTION Get_Attributes___ (
   company_ IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   date_          IN DATE ) RETURN RATE_DATA_REC_TYPE
IS
   rec_   RATE_DATA_REC_TYPE;
   CURSOR get_attributes IS
      SELECT   currency_rate,conv_factor, 0 error_code, currency_type, 'TEMP'
        FROM   CURRENCY_RATE_TAB
       WHERE   company  = company_
         AND   currency_code = currency_code_
         AND   currency_type = currency_type_
         AND   valid_from = date_;

      time_             NUMBER;
      expired_          BOOLEAN := FALSE;   
      req_id_           VARCHAR2(50) := company_ ||'^'|| currency_type_ ||'^'|| currency_code_ ||'^'|| TO_CHAR(date_, 'YYYY-MM-DD');
      not_found         EXCEPTION;
BEGIN      
   time_    := Database_SYS.Get_Time_Offset;
   expired_ := ((time_ - micro_cache_rate_rec_time_) > max_cached_rec_element_life_);           
   
   IF (expired_ OR (micro_cache_rate_rec_user_ IS NULL) OR (micro_cache_rate_rec_user_ != Fnd_Session_API.Get_Fnd_User)) THEN
      Invalidate_Rate_Cache___;
      micro_cache_rate_rec_user_ := Fnd_Session_API.Get_Fnd_User;
   END IF;      

   IF (NOT micro_cache_rate_rec_tab_.exists(req_id_)) THEN
      OPEN  get_attributes;
      FETCH get_attributes INTO rec_;
      IF (get_attributes%NOTFOUND) THEN
         rec_.error_code := -1;
      END IF;         
      CLOSE get_attributes;  
      
      IF (rec_.error_code = -1) THEN         
         RAISE not_found;
      END IF;            
      
      IF (micro_cache_rate_rec_tab_.count >= max_cached_rec_element_count_) THEN
         DECLARE
            random_  NUMBER := NULL;
            element_ VARCHAR2(50);
         BEGIN
            random_ := round(dbms_random.value(1, max_cached_rec_element_count_), 0);
            element_ := micro_cache_rec_link_tab_(random_);
            micro_cache_rate_rec_tab_.delete(element_);
            micro_cache_rec_link_tab_.delete(random_);
            micro_cache_rec_link_tab_(random_) := req_id_;
         END;
      ELSE
         micro_cache_rec_max_id_ := micro_cache_rec_max_id_ + 1;
         micro_cache_rec_link_tab_(micro_cache_rec_max_id_) := req_id_;
      END IF;   
      
      micro_cache_rate_rec_tab_(req_id_) := rec_;
      micro_cache_rate_rec_time_ := time_;
   END IF;
   RETURN micro_cache_rate_rec_tab_(req_id_);        
EXCEPTION
   WHEN not_found THEN
      micro_cache_rate_rec_tab_.delete(req_id_);
      micro_cache_rate_rec_time_  := time_;
      RETURN rec_;
END Get_Attributes___;


PROCEDURE Display_Error___ (
   error_code_ IN NUMBER,
   curr_type_  IN VARCHAR2,
   curr_code_  IN VARCHAR2,
   company_    IN VARCHAR2)
IS
   error_text_ VARCHAR2(2000);
BEGIN
   Display_Error___(error_text_, error_code_, curr_type_, curr_code_, company_ => company_);
END Display_Error___;


PROCEDURE Display_Error___ (
   error_text_    OUT VARCHAR2,
   error_code_    IN  NUMBER,
   curr_type_     IN  VARCHAR2,
   curr_code_     IN  VARCHAR2,
   ignore_errors_ IN  BOOLEAN  DEFAULT FALSE, 
   company_       IN  VARCHAR2 DEFAULT NULL)
IS
   msg_ VARCHAR2(2000);
BEGIN
   IF error_code_ = 1 THEN
      msg_ := 'ERROR1: The transaction currency code is not defined in the default EURO currency type';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR1: The transaction currency code is not defined in the default EURO currency type');
      END IF;
   ELSIF error_code_ = 2 THEN
      msg_ := 'ERROR2: There is no rate between base currency and Euro';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR2: There is no rate between base currency and Euro');
      END IF;
   ELSIF error_code_ = 3 THEN
      msg_ := 'ERROR3: There is no rate between transaction currency and Euro';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR3: There is no rate between transaction currency and Euro');
      END IF;
   ELSIF error_code_ = 4 THEN
      msg_ := 'ERROR4: The currency code :P1 is not valid in the currency rate type :P2 in company :P3.';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_, NULL, curr_code_, curr_type_, company_);
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR4: The currency code :P1 is not valid in the currency rate type :P2 in company :P3.', curr_code_, curr_type_, company_);
      END IF;
   ELSIF error_code_ = 5 THEN
      msg_ := 'ERROR5: There is no rate for the transaction currency in the currency type';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR5: There is no rate for the transaction currency in the currency type');
      END IF;
   ELSIF error_code_ = 6 THEN
      msg_ := 'ERROR6: The currency code is not valid in the default EURO currency type';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR6: The currency code is not valid in the default EURO currency type');
      END IF;
   ELSIF error_code_ = 7 THEN
      msg_ := 'ERROR7: There is no rate between transaction currency and Euro in default currency type';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR7: There is no rate between transaction currency and Euro in default currency type');
      END IF;
   ELSIF error_code_ = 8 THEN
      msg_ := 'ERROR4: The currency code :P1 is not valid in the currency rate type :P2 in company :P3.';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_, NULL, curr_code_, curr_type_, company_);
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR4: The currency code :P1 is not valid in the currency rate type :P2 in company :P3.', curr_code_, curr_type_, company_);
      END IF;
   ELSIF error_code_ = 9 THEN
      msg_ := 'ERROR9: No rate between currency and accounting currency';
      IF (ignore_errors_) THEN
         error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_);   
      ELSE
         Error_SYS.Record_General(lu_name_, 'ERROR9: No rate between currency and accounting currency');
      END IF;
   END IF;
END Display_Error___;


FUNCTION Check_Emu_Currency_Exist___ (
   company_ IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   valid_from_ IN DATE ) RETURN VARCHAR2
IS
   dummy_       NUMBER;
   return_var_  VARCHAR2(6):= 'FALSE';
   CURSOR exist_control IS
      SELECT 1
      FROM   CURRENCY_RATE_TAB
      WHERE  company = company_
      AND    currency_type = currency_type_
      AND    currency_code = currency_code_
      AND    valid_from >= valid_from_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      return_var_ := 'TRUE';
      RETURN return_var_ ;
   END IF;
   CLOSE exist_control;
   RETURN return_var_;
END Check_Emu_Currency_Exist___;


FUNCTION Calculate_Direct_Curr_Rate___ (
   rec_     IN CURRENCY_RATE_TAB%ROWTYPE) RETURN NUMBER
IS
   currency_rate_             NUMBER;
   is_ref_curr_code_emu_      VARCHAR2(5);
   is_curr_code_emu_          VARCHAR2(5);
   ref_curr_inverted_         VARCHAR2(5);
   inverted_                  VARCHAR2(5);
BEGIN
   is_ref_curr_code_emu_   := Currency_Code_API.Get_Valid_Emu(rec_.company, rec_.ref_currency_code, rec_.valid_from);
   is_curr_code_emu_       := Currency_Code_API.Get_Valid_Emu(rec_.company, rec_.currency_code, rec_.valid_from);
   ref_curr_inverted_      := Currency_Code_API.Get_Inverted(rec_.company, rec_.ref_currency_code);

   -- No special handling for old EMU currencies (triangulation). So IF changes are done on old EMU currenies 
   -- the direct rate could get incorrect value.

   IF (rec_.ref_currency_code != 'EUR') THEN
      IF (is_ref_curr_code_emu_ = 'FALSE' AND is_curr_code_emu_ = 'TRUE') THEN
         IF (ref_curr_inverted_ = 'FALSE') THEN
            inverted_ := 'FALSE';  
         ELSE
            inverted_ := 'TRUE';
         END IF;     
      ELSIF (is_ref_curr_code_emu_ = 'TRUE' AND is_curr_code_emu_ = 'TRUE') THEN
         inverted_ := 'FALSE';
      ELSIF (is_ref_curr_code_emu_ = 'TRUE' AND is_curr_code_emu_ = 'FALSE') THEN 
         inverted_ := 'FALSE';
      ELSE
         IF (ref_curr_inverted_ = 'FALSE') THEN
            inverted_ := 'FALSE';  
         ELSE
            inverted_ := 'TRUE';
         END IF;  
      END IF;  
   ELSE
      IF (ref_curr_inverted_ = 'FALSE') THEN
         inverted_ := 'FALSE';  
      ELSE
         inverted_ := 'TRUE';
      END IF;  
   END IF;

   IF (inverted_ = 'TRUE') THEN
      currency_rate_ := (1/(rec_.currency_rate/rec_.conv_factor));
   ELSE
      currency_rate_ := rec_.currency_rate/rec_.conv_factor;
   END IF;

   RETURN currency_rate_;
END Calculate_Direct_Curr_Rate___;


FUNCTION Calculate_Direct_Curr_Rate___ (
   company_             IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   valid_from_          IN DATE,
   currency_rate_       IN NUMBER,
   conv_factor_         IN NUMBER,
   ref_currency_code_   IN VARCHAR2) RETURN NUMBER
IS
   rec_     CURRENCY_RATE_TAB%ROWTYPE;
BEGIN
   rec_.company := company_;
   rec_.currency_type := currency_type_;
   rec_.currency_code := currency_code_;
   rec_.valid_from := valid_from_;
   rec_.currency_rate := currency_rate_;
   rec_.conv_factor := conv_factor_;
   rec_.ref_currency_code := ref_currency_code_;
   RETURN Calculate_Direct_Curr_Rate___(rec_);
END Calculate_Direct_Curr_Rate___;


PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   dummy_                        VARCHAR2(1);
   msg_                          VARCHAR2(2000);
   base_curr_conv_fac_           CURRENCY_RATE_TAB.conv_factor%TYPE;
   emu_curr_                     VARCHAR2(5);
   i_                            NUMBER := 0;
   valid_from_                   DATE;
   conv_factor_                  NUMBER;
   par_curr_conv_fac_            CURRENCY_RATE_TAB.conv_factor%TYPE;
   run_crecomp_                  BOOLEAN := FALSE;
   do_insert_                    BOOLEAN := FALSE;
   direct_currency_rate_         NUMBER;
   direct_currency_rate_round_   NUMBER;
   company_finance_rec_          Company_Finance_API.Public_Rec;
   
   CURSOR get_data IS
      SELECT *
      FROM   currency_rate_def_tab;

   CURSOR exist_key (currency_type_ IN VARCHAR2, currency_code_ IN VARCHAR2) IS
      SELECT 'X'
      FROM   CURRENCY_RATE_TAB
      WHERE  company = crecomp_rec_.company
      AND    currency_type = currency_type_
      AND    currency_code = currency_code_;
BEGIN
   run_crecomp_         := Check_If_Do_Create_Company___(crecomp_rec_);
   company_finance_rec_ := Company_Finance_API.Get(crecomp_rec_.company);
   base_curr_conv_fac_  := NVL(Currency_Code_API.Get_Conversion_Factor(crecomp_rec_.company, company_finance_rec_.currency_code),1);
   emu_curr_            := Currency_Code_API.Get_Emu(crecomp_rec_.company, company_finance_rec_.currency_code);
   par_curr_conv_fac_   := NVL(Currency_Code_API.Get_Conversion_Factor(crecomp_rec_.company, company_finance_rec_.parallel_acc_currency),1);
   
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         BEGIN
            IF (rec_.currency_code = 'XXX') THEN
               rec_.currency_code := company_finance_rec_.currency_code;
               rec_.conv_factor := base_curr_conv_fac_;
               rec_.currency_rate := base_curr_conv_fac_;
               rec_.ref_currency_code := company_finance_rec_.currency_code;
            ELSIF (rec_.currency_code = 'YYY' AND company_finance_rec_.parallel_acc_currency IS NOT NULL) THEN
               rec_.currency_code := company_finance_rec_.parallel_acc_currency;
               rec_.conv_factor := par_curr_conv_fac_;
               rec_.currency_rate := par_curr_conv_fac_;
               rec_.ref_currency_code := company_finance_rec_.parallel_acc_currency;
            END IF;
            -- do not go any further if the currency codes are still dummy values
            IF (rec_.currency_code != 'XXX' AND rec_.currency_code != 'YYY') THEN
               OPEN exist_key(rec_.currency_type, rec_.currency_code);
               FETCH exist_key INTO dummy_;
               IF (exist_key%NOTFOUND) THEN
                  CLOSE exist_key;
                  do_insert_ := FALSE;

                  IF (Currency_Code_API.Get_Valid_Emu(crecomp_rec_.company, rec_.currency_code, SYSDATE) = 'TRUE') THEN
                     valid_from_ := TO_DATE('1999-01-01','YYYY-MM-DD', 'NLS_CALENDAR=GREGORIAN');
                  ELSIF (rec_.currency_code = 'EUR') THEN
                     valid_from_ := TO_DATE('1999-01-01','YYYY-MM-DD', 'NLS_CALENDAR=GREGORIAN');
                  ELSE
                     valid_from_ := crecomp_rec_.valid_from;
                  END IF;

                  IF (company_finance_rec_.parallel_acc_currency IS NOT NULL AND rec_.currency_type = '3') THEN
                     -- only when transaction currency as base
                     IF (company_finance_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN
                        do_insert_  := TRUE;
                     END IF;
                  ELSIF (emu_curr_ = 'TRUE') OR (company_finance_rec_.currency_code = 'EUR') THEN
                     IF (rec_.currency_type = '2') THEN
                        do_insert_ := TRUE;
                        conv_factor_ := Currency_Code_API.Get_Conversion_Factor(crecomp_rec_.company, rec_.currency_code);
                        rec_.conv_factor := (rec_.conv_factor * conv_factor_);
                        rec_.currency_rate := rec_.currency_rate * conv_factor_;
                     END IF;
                  ELSE
                     do_insert_ := TRUE;
                  END IF;

                  IF (do_insert_) THEN
                     Iso_Currency_API.Exist_Db(rec_.currency_code);
                     direct_currency_rate_ := Calculate_Direct_Curr_Rate___(crecomp_rec_.company,
                                                                            rec_.currency_type,
                                                                            rec_.currency_code,
                                                                            valid_from_,
                                                                            rec_.currency_rate,
                                                                            rec_.conv_factor,
                                                                            rec_.ref_currency_code);
                     direct_currency_rate_round_ := ROUND(direct_currency_rate_, Currency_Code_API.Get_No_Of_Decimals_In_Rate(crecomp_rec_.company, rec_.currency_code));
                     INSERT
                     INTO currency_rate_tab (
                        rowversion,
                        company,
                        currency_type,
                        valid_from,
                        currency_code,
                        currency_rate,
                        conv_factor,
                        ref_currency_code,
                        direct_currency_rate,
                        direct_currency_rate_round)                        
                     VALUES(
                        SYSDATE,
                        crecomp_rec_.company,
                        rec_.currency_type,
                        valid_from_,
                        rec_.currency_code,
                        rec_.currency_rate,
                        rec_.conv_factor,
                        rec_.ref_currency_code,
                        direct_currency_rate_,
                        direct_currency_rate_round_);
                  END IF;
               ELSE
                  CLOSE exist_key;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'CURRENCY_RATE_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
BEGIN
   Import___(crecomp_rec_);
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
BEGIN
   NULL;
END Export___;


FUNCTION Exist_Any___(
   company_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN  := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
      SELECT 1
      FROM   CURRENCY_RATE_TAB
      WHERE  company = company_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO idum_;
   IF ( exist_control%NOTFOUND) THEN
      b_exist_ := FALSE;
   END IF;
   CLOSE exist_control;
   RETURN b_exist_;
END Exist_Any___;


FUNCTION Check_If_Do_Create_Company___(
   crecomp_rec_    IN  ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) RETURN BOOLEAN
IS
   perform_update_         BOOLEAN;
   update_by_key_          BOOLEAN;
BEGIN
   perform_update_ := FALSE;
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF ( update_by_key_ ) THEN
      perform_update_ := TRUE;
   ELSE
      IF ( NOT Exist_Any___( crecomp_rec_.company ) ) THEN
         perform_update_ := TRUE;
      END IF;
   END IF;
   RETURN perform_update_;
END Check_If_Do_Create_Company___;


PROCEDURE Get_Parallel_Currency_Rate___(
   currency_rate_       OUT NUMBER,
   conversion_factor_   OUT NUMBER,
   inverted_            OUT VARCHAR2,
   company_             IN  VARCHAR2,
   trans_curr_code_     IN  VARCHAR2,
   valid_date_          IN  DATE,
   parallel_curr_type_  IN  VARCHAR2 DEFAULT NULL,
   acc_curr_code_       IN  VARCHAR2 DEFAULT NULL,
   parallel_curr_code_  IN  VARCHAR2 DEFAULT NULL,
   parallel_curr_base_  IN  VARCHAR2 DEFAULT NULL,
   is_acc_emu_          IN  VARCHAR2 DEFAULT NULL,
   is_parallel_emu_     IN  VARCHAR2 DEFAULT NULL)
IS
   tmp_acc_curr_code_      currency_code.currency_code%TYPE    := acc_curr_code_;
   tmp_para_curr_code_     currency_code.currency_code%TYPE    := parallel_curr_code_;
   tmp_is_acc_emu_         VARCHAR2(10)                        := is_acc_emu_;
   tmp_is_parallel_emu_    VARCHAR2(10)                        := is_parallel_emu_;
   tmp_currency_type_      VARCHAR2(10)                        := parallel_curr_type_;
   tmp_para_curr_base_     VARCHAR2(25)                        := parallel_curr_base_;
   curr_code_to_use_       currency_code.currency_code%TYPE;   -- The currency code for with the rate should be retrieved
   ref_curr_code_to_use_   currency_code.currency_code%TYPE;   -- The reference currency code to which the rate is set against. same currency as the curr type is based on
   is_ref_curr_code_emu_   VARCHAR2(5);
   dummy_                  NUMBER;
   rec_                    RATE_DATA_REC_TYPE;
   No_Parallel_Curr_Rate   EXCEPTION;
   PRAGMA EXCEPTION_INIT(No_Parallel_Curr_Rate, -20110) ;

   CURSOR check_type_not_parallel IS
      SELECT 1
      FROM   CURRENCY_TYPE_TAB
      WHERE  company = company_
      AND    rate_type_category IN ('PROJECT','NORMAL')
      AND    currency_type = tmp_currency_type_;
BEGIN
   IF (tmp_para_curr_code_ IS NULL) THEN
      tmp_para_curr_code_ := Company_Finance_API.Get_Parallel_Acc_Currency(company_, SYSDATE);   
   END IF;

   IF (tmp_para_curr_code_ IS NOT NULL) THEN
      IF (tmp_para_curr_base_ IS NULL) THEN
         tmp_para_curr_base_ := Company_Finance_API.Get_Parallel_Base_Db(company_);
      END IF;

      IF (tmp_para_curr_base_ = 'TRANSACTION_CURRENCY') THEN
         curr_code_to_use_     := trans_curr_code_;
         ref_curr_code_to_use_ := tmp_para_curr_code_;

         IF (tmp_is_parallel_emu_ IS NULL) THEN
            is_ref_curr_code_emu_ := Currency_Code_API.Get_Emu(company_,
                                                               tmp_para_curr_code_);
         END IF;
      ELSE
         IF (tmp_acc_curr_code_ IS NULL) THEN
            tmp_acc_curr_code_ := Company_Finance_API.Get_Currency_Code(company_);
         END IF;
         IF (tmp_is_acc_emu_ IS NULL) THEN
            is_ref_curr_code_emu_ := Currency_Code_API.Get_Emu(company_,
                                                               tmp_acc_curr_code_);
         END IF;
         curr_code_to_use_     := tmp_para_curr_code_;
         ref_curr_code_to_use_ := tmp_acc_curr_code_;
      END IF;

      IF (tmp_currency_type_ IS NULL) THEN
         -- get the currency type, either the default parallel type or based on Buy/Sell rate type
         -- The interface with two parameters does not yet exist, should be added.
         /*
         tmp_currency_type_ := Company_Finance_API.Get_Parallel_Rate_Type(company_,
                                                                          curr_type_rel_to_);
         */
         tmp_currency_type_ := Company_Finance_API.Get_Parallel_Rate_Type(company_);
      END IF;
      IF (tmp_para_curr_base_ = 'TRANSACTION_CURRENCY') THEN
         OPEN check_type_not_parallel;
         FETCH check_type_not_parallel INTO dummy_;
         IF (check_type_not_parallel%FOUND) THEN
            CLOSE check_type_not_parallel;
            Error_SYS.Appl_General(lu_name_,'RATETYPEPARALLEL: The selected Currency Rate Type should have the Rate Type Category defined as Parallel Currency.');
         END IF;
         CLOSE check_type_not_parallel;
      END IF;
      rec_ := Currency_Rate___(company_,
                               tmp_currency_type_,
                               curr_code_to_use_,
                               ref_curr_code_to_use_,
                               valid_date_,
                               is_ref_curr_code_emu_);

      IF (rec_.error_code != 0) THEN
         Display_Error___(rec_.error_code, tmp_currency_type_, curr_code_to_use_, company_);
      END IF;

      conversion_factor_      := rec_.conv_factor;
      currency_rate_          := rec_.currency_rate;
      inverted_               := rec_.inverted;
   END IF;
EXCEPTION
   WHEN No_Parallel_Curr_Rate THEN
      Error_SYS.Appl_General(lu_name_, 'NOTHIRD: The currency rate for parallel currency is not valid in the currency type :P1 in company :P2.', tmp_currency_type_, company_);
END Get_Parallel_Currency_Rate___;

-- Get_Curr_Conv_Rate_Base___
--   Method that returns the cross rate between two currencies with same currency type
--   The rate is calculated without taking the Inverted flag into account so when using this rate the Inverted flag
--   and the conversion factor for the reference currency (of the currency_type) needs to be applied.
PROCEDURE Get_Curr_Conv_Rate_Base___ (
   currency_rate_      OUT NUMBER,
   conv_factor_        OUT NUMBER,
   inverted_           OUT VARCHAR2,
   error_text_         OUT VARCHAR2,
   company_            IN VARCHAR2,
   to_currency_code_   IN VARCHAR2,
   from_currency_code_ IN VARCHAR2,
   currency_type_      IN VARCHAR2,
   valid_from_         IN DATE,
   ignore_errors_      IN BOOLEAN DEFAULT FALSE )
IS
   ref_currency_code_      CURRENCY_RATE_TAB.ref_currency_code%TYPE;
   is_base_emu_            VARCHAR2(5);
   valid_from_date_        DATE;
   rec_                    RATE_DATA_REC_TYPE;
   ref_to_to_curr_rate_    NUMBER;     -- the rate between the reference currency and the to_currency_code
   ref_to_from_curr_rate_  NUMBER;     -- the rate between the reference currency and the from_currency_code
   to_conv_factor_         NUMBER;
   from_conv_factor_       NUMBER;

   CURSOR get_ref_currency (currency_code_ VARCHAR2) IS
      SELECT a.ref_currency_code, a.valid_from
      FROM CURRENCY_RATE_TAB a 
      WHERE a.company        = company_
         AND a.currency_code = currency_code_
         AND a.currency_type = currency_type_
         AND valid_from IN (SELECT MAX(b.valid_from)
                            FROM CURRENCY_RATE_TAB b
                            WHERE b.company        = company_
                               AND b.currency_code = currency_code_
                               AND b.currency_type = currency_type_
                               AND b.valid_from    <= valid_from_);
BEGIN
   --Check currency code exist for currency type
   Check_If_Curr_Code_Exists(error_text_, company_, currency_type_, to_currency_code_, ignore_errors_);

   IF (error_text_ IS NULL) THEN
      --Check transaction currency code exist for currency type
      Check_If_Curr_Code_Exists(error_text_, company_, currency_type_, from_currency_code_, ignore_errors_);
   END IF;

   IF (error_text_ IS NULL) THEN
      --Fetch ref_curr/currency_code_
      OPEN get_ref_currency(to_currency_code_);
      FETCH get_ref_currency INTO ref_currency_code_, valid_from_date_;
      CLOSE get_ref_currency;

      is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, ref_currency_code_, valid_from_date_);

      --Fetch currency rate record for to_currecy_code_ ()convert-to currency)
      rec_ := Currency_Rate___(company_, currency_type_, to_currency_code_, ref_currency_code_, valid_from_date_, is_base_emu_);
      to_conv_factor_ := rec_.conv_factor;
      
      -- Check for errors in fetching the currency rates
      IF (rec_.error_code != 0 ) THEN
         Display_Error___(error_text_, rec_.error_code, currency_type_, to_currency_code_, ignore_errors_, company_);
      END IF;

      IF (error_text_ IS NULL) THEN
         --ref_to_to_curr_rate_ := rec_.currency_rate/rec_.conv_factor;
         ref_to_to_curr_rate_ := rec_.currency_rate;

         --Fetch ref_curr/trans_curr
         OPEN get_ref_currency(from_currency_code_);
         FETCH get_ref_currency INTO ref_currency_code_, valid_from_date_;
         CLOSE get_ref_currency;

         --Fetch currency rate record for from_currency_code_ (convert-from currency)
         rec_ := Currency_Rate___(company_, currency_type_, from_currency_code_, ref_currency_code_, valid_from_date_, is_base_emu_);
         from_conv_factor_ := rec_.conv_factor;
         
         -- Check for errors in fetching the currency rates
         IF (rec_.error_code != 0 ) THEN
            Display_Error___(error_text_, rec_.error_code, currency_type_, from_currency_code_, ignore_errors_, company_);
         END IF;

         IF (error_text_ IS NULL) THEN            
            ref_to_from_curr_rate_ := rec_.currency_rate;
            --Calculate Currency Rate (Currency rates always > 0, hence no devision by 0)
            inverted_ := rec_.inverted;
            --currency_rate_ := (1/(ref_to_from_curr_rate_ / ref_to_to_curr_rate_)) * from_conv_factor_;            
            currency_rate_ := (1/((ref_to_from_curr_rate_ / from_conv_factor_) / ref_to_to_curr_rate_));
            conv_factor_ := to_conv_factor_;            
         END IF;
      END IF;
   END IF;
END Get_Curr_Conv_Rate_Base___;

PROCEDURE Check_Currency_Type_Ref___ (
   newrec_ IN OUT currency_rate_tab%ROWTYPE )
IS
BEGIN
   Currency_Type_API.Check_Exist_All_Types(newrec_.company, newrec_.currency_type);
END Check_Currency_Type_Ref___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     currency_rate_tab%ROWTYPE,
   newrec_ IN OUT currency_rate_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (indrec_.currency_rate) THEN
      newrec_.currency_rate := ROUND ( newrec_.currency_rate,
                                       Currency_Code_API.Get_No_Of_Decimals_In_Rate(newrec_.company, newrec_.currency_code ) ) ;
      IF (newrec_.currency_rate <= 0) THEN
         Error_SYS.Appl_General(lu_name_, 'RATEINCORRECT: Currency rate cannot be zero or negative.');
      END IF;
   END IF;
   
   newrec_.direct_currency_rate := Calculate_Direct_Curr_Rate___(newrec_);
   newrec_.direct_currency_rate_round := ROUND(newrec_.direct_currency_rate, Currency_Code_API.Get_No_Of_Decimals_In_Rate(newrec_.company, newrec_.currency_code));
   
   super(oldrec_, newrec_, indrec_, attr_);
   
   Client_SYS.Add_To_Attr( 'CURRENCY_RATE', newrec_.currency_rate, attr_ );

   IF (newrec_.currency_code = newrec_.ref_currency_code) AND (newrec_.currency_rate != newrec_.conv_factor) THEN
      Error_SYS.Appl_General(lu_name_,'NOVALIDRATE: Currency Rate of the reference currency :P1 should be equal to the Conversion Factor',newrec_.currency_code);
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN CURRENCY_RATE_TAB%ROWTYPE )
IS   
BEGIN
   IF (Currency_Code_API.Get_Valid_Emu(remrec_.company, remrec_.currency_code, sysdate) = 'TRUE' AND (remrec_.ref_currency_code = 'EUR')) THEN
      Error_SYS.Appl_General(lu_name_,'DELETEEMU: You cannot delete the currency :P1 since it is an EMU currency',remrec_.currency_code);
   END IF;
   super(remrec_);
END Check_Delete___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN currency_rate_tab%ROWTYPE )
IS
BEGIN
   --Add pre-processing code here
   super(objid_, remrec_);
   --Add post-processing code here
   Invalidate_Micro_Caches___;
END Delete___;




@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT currency_rate_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
   emu_valid_date_  DATE;
   conv_factor_     NUMBER;
BEGIN   
   IF (indrec_.currency_code) THEN
      emu_valid_date_ := Currency_Code_API.Get_Emu_Currency_From_Date(newrec_.company, newrec_.currency_code);
      IF (newrec_.ref_currency_code) = 'EUR' THEN
         IF (emu_valid_date_ IS NOT NULL) THEN
            IF Check_Emu_Currency_Exist___(newrec_.company, newrec_.currency_type, newrec_.currency_code, emu_valid_date_) = 'TRUE' THEN
               Error_SYS.Appl_General(lu_name_,'EMUCUREXIST: The EMU currency :P1 has already been included in this currency type',newrec_.currency_code);
            END IF;
         END IF;
      END IF; 
   END IF;      

   IF (indrec_.conv_factor) THEN
      conv_factor_ := Currency_Code_API.Get_Conversion_Factor(newrec_.company, newrec_.currency_code);
      IF (newrec_.conv_factor IS NULL) THEN
         newrec_.conv_factor := conv_factor_;
      ELSIF (conv_factor_ != newrec_.conv_factor) THEN
         Error_SYS.Appl_General(lu_name_, 'CONVINCORRECT: The conversion factor specified is incorrect');
      END IF;
   END IF;
   
   super(newrec_, indrec_, attr_);

   Client_SYS.Add_To_Attr( 'CONV_FACTOR', newrec_.conv_factor, attr_ );
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT currency_rate_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   
BEGIN
   --Add pre-processing code here
   -- trunc the date to always make sure that the date is without timestamp
   newrec_.valid_from := TRUNC(newrec_.valid_from);   
   super(objid_, objversion_, newrec_, attr_);
   --Add post-processing code here
END Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     currency_rate_tab%ROWTYPE,
   newrec_ IN OUT currency_rate_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN
   IF (indrec_.currency_rate) THEN
      IF (oldrec_.ref_currency_code = 'EUR') THEN
         IF Currency_Code_API.Get_Valid_Emu(newrec_.company, newrec_.currency_code, sysdate) = 'TRUE' THEN
            Error_SYS.Appl_General(lu_name_,'NOEMUMODIFI: Currency Exchange rate cannot be modified since :P1 is an EMU Currency',newrec_.currency_code);
         END IF;
      END IF;      
   END IF;
      
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Update___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     currency_rate_tab%ROWTYPE,
   newrec_     IN OUT currency_rate_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   --Add pre-processing code here
   -- trunc the date to always make sure that the date is without timestamp
   newrec_.valid_from := TRUNC(newrec_.valid_from);
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);   
   --Add post-processing code here
   Invalidate_Micro_Caches___;
END Update___;

PROCEDURE Fetch_Currency_Rate_Base___ (
   conversion_factor_   OUT NUMBER,
   currency_rate_       OUT NUMBER,
   inverted_            OUT VARCHAR2,
   company_             IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   date_                IN DATE,
   is_base_emu_         IN VARCHAR2 )

IS
   rec_           RATE_DATA_REC_TYPE;
   t_is_base_emu_ VARCHAR2(5);
BEGIN
   t_is_base_emu_    :=  is_base_emu_;
   IF (is_base_emu_ = 'DUMMY') THEN
      t_is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   END IF;
   rec_ := Currency_Rate___(company_,currency_type_,currency_code_,base_currency_code_,date_, t_is_base_emu_);
   IF (rec_.error_code != 0) THEN
      Display_Error___(rec_.error_code, currency_type_, currency_code_, company_);
   END IF;
   conversion_factor_  := rec_.conv_factor;
   currency_rate_      := rec_.currency_rate;
   inverted_           := rec_.inverted;
END Fetch_Currency_Rate_Base___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Create_Company_Reg__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
   
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, 'CURRENCY_RATE_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      NULL, NULL);
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
      module_,'CURRENCY_RATE_TAB',
      CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'CURRENCY_RATE_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Currency_Rate (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   valid_from_    IN DATE ) RETURN NUMBER
IS
   rec_                 RATE_DATA_REC_TYPE;
   base_currency_code_  VARCHAR2(3);
   is_base_emu_         VARCHAR2(5);   
BEGIN
   base_currency_code_  := Company_Finance_API.Get_Currency_Code( company_ );
   is_base_emu_         := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, valid_from_);
   rec_                 := Currency_Rate___ ( company_, currency_type_,currency_code_, base_currency_code_, valid_from_, is_base_emu_);
   IF ( rec_.error_code != 0 ) THEN
      RETURN NULL;
   ELSE
      IF rec_.inverted = 'TRUE' THEN
         RETURN (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
      ELSE
         RETURN rec_.currency_rate;
      END IF;
   END IF;
END Get_Currency_Rate;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Currency_Rate (
   conv_factor_      OUT NUMBER,
   currency_rate_    OUT NUMBER,
   company_          IN VARCHAR2,
   currency_code_    IN VARCHAR2,
   currency_type_    IN VARCHAR2,
   date_             IN DATE )
IS
   rec_                RATE_DATA_REC_TYPE;
   base_currency_code_ VARCHAR2(3);
   is_base_emu_        VARCHAR2(5);
BEGIN
   base_currency_code_   := Company_Finance_API.Get_Currency_Code(company_);
   is_base_emu_          := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   rec_                  := Currency_Rate___(company_, currency_type_, currency_code_, base_currency_code_,date_, is_base_emu_);
   IF (rec_.error_code != 0) THEN
      Display_Error___(rec_.error_code, currency_type_, currency_code_, company_);
   END IF;
   conv_factor_  := rec_.conv_factor;
   IF (rec_.inverted = 'TRUE') THEN
      currency_rate_ := (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
   ELSE
      currency_rate_ := rec_.currency_rate;
   END IF;
END Get_Currency_Rate;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Currency_Rate (
   conv_factor_      OUT NUMBER,
   currency_rate_    OUT NUMBER,
   inverted_         OUT VARCHAR2,
   company_          IN VARCHAR2,
   currency_code_    IN VARCHAR2,
   currency_type_    IN VARCHAR2,
   date_             IN DATE )
IS
   rec_                RATE_DATA_REC_TYPE;
   base_currency_code_ VARCHAR2(3);
   is_base_emu_        VARCHAR2(5);
BEGIN
   base_currency_code_   := Company_Finance_API.Get_Currency_Code( company_ );
   is_base_emu_          := Currency_Code_api.Get_Valid_Emu(company_, base_currency_code_, date_);
   rec_                  := Currency_Rate___ ( company_, currency_type_, currency_code_, base_currency_code_,date_, is_base_emu_ );
   IF ( rec_.error_code != 0 ) THEN
      Display_Error___(rec_.error_code, currency_type_, currency_code_, company_);
   END IF;
   conv_factor_  := rec_.conv_factor;
   IF (rec_.inverted = 'TRUE') THEN
      currency_rate_ := (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
   ELSE
      currency_rate_ := rec_.currency_rate;
   END IF;
   inverted_ := rec_.inverted;
END Get_Currency_Rate;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Conv_Factor (
   company_ IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   valid_from_ IN DATE ) RETURN NUMBER
IS
   base_currency_code_  CURRENCY_RATE_TAB.currency_code%TYPE;
   is_base_emu_         VARCHAR2(5);
   rec_                 RATE_DATA_REC_TYPE;
BEGIN
   base_currency_code_  := Company_Finance_API.Get_Currency_Code(company_);
   is_base_emu_         := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, valid_from_);
   rec_                 := Currency_Rate___(company_, currency_type_,currency_code_, base_currency_code_, valid_from_, is_base_emu_);
   IF (rec_.error_code != 0) THEN
      RETURN NULL;
   ELSE
      RETURN rec_.conv_factor;
   END IF;
END Get_Conv_Factor;


@UncheckedAccess
FUNCTION Get_Curr_Rate_Data (
   company_       IN VARCHAR2,
   currency_code_ IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   date_          IN DATE ) RETURN CurrRateInfoRecType
IS
   curr_rate_info_rec_  CurrRateInfoRecType;
   rec_                 RATE_DATA_REC_TYPE;
   is_base_emu_         VARCHAR2(5);
   base_currency_code_  currency_code_tab.currency_code%TYPE;
BEGIN
   IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
      base_currency_code_ := Company_Finance_API.Get_Currency_Code(company_);
      is_base_emu_        := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
      rec_                := Currency_Rate___(company_, currency_type_,currency_code_, base_currency_code_, date_, is_base_emu_);
      IF (rec_.error_code != 0) THEN
         RETURN NULL;
      ELSE
         IF rec_.inverted = 'TRUE' THEN
            curr_rate_info_rec_.currency_rate := (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
         ELSE
            curr_rate_info_rec_.currency_rate := rec_.currency_rate;
         END IF;
         curr_rate_info_rec_.curr_rate_base_disp := rec_.currency_rate;
         curr_rate_info_rec_.conv_factor         := rec_.conv_factor;
      END IF;
      RETURN curr_rate_info_rec_;
   ELSE
      RETURN NULL;
   END IF;
END Get_Curr_Rate_Data;


@UncheckedAccess
FUNCTION Get_Rounded_Currency_Rate (
   company_           IN VARCHAR2,
   currency_code_     IN VARCHAR2,
   currency_rate_     IN NUMBER ) RETURN NUMBER
IS
   decimals_in_rate_  NUMBER;
BEGIN
   decimals_in_rate_ := Currency_Code_API.Get_No_Of_Decimals_In_Rate(company_, currency_code_);
   RETURN  Round(currency_rate_, decimals_in_rate_);
END Get_Rounded_Currency_Rate;


@UncheckedAccess
FUNCTION Check_If_Curr_Rate_Exists (
   company_       IN  VARCHAR2,
   currency_code_ IN  VARCHAR2 )  RETURN VARCHAR2
IS
   dummy_ VARCHAR2(10);
   --
   CURSOR check_rate_exist IS
      SELECT  'TRUE'
      FROM    CURRENCY_RATE_TAB
      WHERE   company = company_
      AND     currency_code = currency_code_;
   --
BEGIN
   IF ( Company_Finance_API.Is_User_Authorized(company_) ) THEN
      OPEN check_rate_exist;
      FETCH check_rate_exist INTO dummy_;
      IF check_rate_exist%FOUND THEN
         CLOSE check_rate_exist;
         RETURN 'TRUE';
      ELSE
         CLOSE check_rate_exist;
      END IF;
      RETURN 'FALSE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_If_Curr_Rate_Exists;


@UncheckedAccess
FUNCTION Check_If_Curr_Rate_Exists (
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2,
   currency_code_ IN  VARCHAR2 )  RETURN VARCHAR2
IS
   dummy_ VARCHAR2(10);
   curr_type_  CURRENCY_RATE_TAB.currency_type%TYPE;
   --
   CURSOR check_rate_exist IS
      SELECT  'TRUE'
      FROM    CURRENCY_RATE_TAB
      WHERE   company = company_
      AND     currency_type = curr_type_
      AND     currency_code = currency_code_;
   --
BEGIN
   IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
      curr_type_ := currency_type_;
      OPEN check_rate_exist;
      FETCH check_rate_exist INTO dummy_;
      IF (check_rate_exist%FOUND) THEN
         CLOSE check_rate_exist;
         RETURN 'TRUE';
      ELSE
         CLOSE check_rate_exist;
         IF (Currency_Code_API.Get_Valid_Emu(company_, currency_code_, sysdate) = 'TRUE') THEN
            curr_type_ := Currency_Type_API.Get_Default_Euro_Type__(company_);
            OPEN check_rate_exist;
            FETCH check_rate_exist INTO dummy_;
            IF (check_rate_exist%FOUND) THEN
               CLOSE check_rate_exist;
               RETURN 'TRUE';
            END IF;
            CLOSE check_rate_exist;
         END IF;
      END IF;
      RETURN 'FALSE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_If_Curr_Rate_Exists;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_If_Curr_Code_Exists (
   error_text_    OUT VARCHAR2,
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2,
   currency_code_ IN  VARCHAR2,
   ignore_errors_ IN  BOOLEAN DEFAULT FALSE )
IS
      
   dummy_ VARCHAR2(10);
   curr_type_  CURRENCY_RATE_TAB.currency_type%TYPE;

   msg_ VARCHAR2(2000);

   CURSOR exist_curr_code IS
     SELECT  'TRUE'
      FROM    CURRENCY_RATE_TAB
      WHERE   company = company_
      AND     currency_code = currency_code_
      AND     currency_type = curr_type_;
BEGIN
   curr_type_ := currency_type_;
   OPEN exist_curr_code;
   FETCH exist_curr_code INTO dummy_;
   IF (exist_curr_code%NOTFOUND) THEN
      CLOSE exist_curr_code;
      IF (Currency_Code_API.Get_Valid_Emu(company_, currency_code_, sysdate) = 'TRUE') THEN
         curr_type_ := Currency_Type_API.Get_Default_Euro_Type__(company_);
         OPEN exist_curr_code;
         FETCH exist_curr_code INTO dummy_;
         IF (exist_curr_code%NOTFOUND) THEN            
            msg_ := 'NOCURRCODEINEURO: The currency code :P1 does not exist in default EURO currency type :P2';
            IF (ignore_errors_) THEN
               error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_, NULL, currency_code_, curr_type_);   
            ELSE
               CLOSE exist_curr_code;
               Error_SYS.Record_General(lu_name_, msg_, currency_code_, curr_type_);
            END IF;
         END IF;
         CLOSE exist_curr_code;
      ELSE
         msg_ := 'NOCURRCODE: The currency code :P1 does not exist for currency type :P2';
         IF (ignore_errors_) THEN
            error_text_ := Language_SYS.Translate_Constant(lu_name_, msg_, NULL, currency_code_, currency_type_);   
         ELSE
            Error_SYS.Record_General(lu_name_, msg_, currency_code_, currency_type_);
         END IF;
      END IF;
   ELSE
      CLOSE exist_curr_code;
   END IF;
END Check_If_Curr_Code_Exists;


PROCEDURE Check_If_Curr_Code_Exists (
   company_       IN  VARCHAR2,
   currency_type_ IN  VARCHAR2,
   currency_code_ IN  VARCHAR2 )
IS
   dummy_ VARCHAR2(200);
BEGIN
   Check_If_Curr_Code_Exists(dummy_, company_, currency_type_, currency_code_);
END Check_If_Curr_Code_Exists;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Currency_Rate_Base (
   company_             IN VARCHAR2,
   trans_currency_code_ IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   trans_date_          IN DATE ) RETURN NUMBER
IS
   rec_           RATE_DATA_REC_TYPE;
   is_base_emu_   VARCHAR2(5);
BEGIN
   is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, trans_date_);
   rec_         := Currency_Rate___(company_, currency_type_,trans_currency_code_, base_currency_code_, trans_date_, is_base_emu_);
   IF (rec_.error_code != 0) THEN
      RETURN NULL;
   ELSE
      IF (rec_.inverted = 'TRUE') THEN
         RETURN (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
      ELSE
         RETURN rec_.currency_rate;
      END IF;
   END IF;
END Get_Currency_Rate_Base;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Fetch_Currency_Rate_Base (
   conversion_factor_   OUT NUMBER,
   currency_rate_       OUT NUMBER,
   inverted_            OUT VARCHAR2,
   company_             IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   date_                IN DATE,
   is_base_emu_         IN VARCHAR2 )

IS
BEGIN
   Fetch_Currency_Rate_Base___( conversion_factor_,
                                currency_rate_,
                                inverted_,
                                company_,
                                currency_code_,
                                base_currency_code_,
                                currency_type_,
                                date_,
                                is_base_emu_);
END Fetch_Currency_Rate_Base;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Fetch_Currency_Rate_Base (
   conversion_factor_   OUT NUMBER,
   currency_rate_       OUT NUMBER,
   error_text_          OUT VARCHAR2,
   inverted_            OUT VARCHAR2,
   company_             IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   date_                IN DATE,
   is_base_emu_         IN VARCHAR2 )

IS
   rec_           RATE_DATA_REC_TYPE;
   t_is_base_emu_ VARCHAR2(5);
BEGIN
   t_is_base_emu_    :=  is_base_emu_;
   
   --Check currency code exist for currency type
   Check_If_Curr_Code_Exists(error_text_, company_, currency_type_, base_currency_code_, TRUE);

   IF (error_text_ IS NULL) THEN
      --Check transaction currency code exist for currency type
      Check_If_Curr_Code_Exists(error_text_, company_, currency_type_, currency_code_, TRUE);
      IF(error_text_ IS NOT NULL) THEN
         RETURN;
      END IF;
   ELSE
      RETURN;
   END IF;
   
   IF (is_base_emu_ = 'DUMMY') THEN
      t_is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   END IF;
   rec_ := Currency_Rate___(company_,currency_type_,currency_code_,base_currency_code_,date_, t_is_base_emu_);
   IF (rec_.error_code != 0) THEN
      Display_Error___(error_text_, rec_.error_code, currency_type_, currency_code_, TRUE, company_);
   END IF;
   conversion_factor_  := rec_.conv_factor;
   currency_rate_      := rec_.currency_rate;
   inverted_           := rec_.inverted;
END Fetch_Currency_Rate_Base;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
PROCEDURE Fetch_Currency_Rate_Base (
   conversion_factor_   OUT NUMBER,
   currency_rate_       OUT NUMBER,
   inverted_            OUT VARCHAR2,
   company_             IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   date_                IN DATE,
   is_base_emu_         IN VARCHAR2,
   project_id_          IN VARCHAR2)
IS
   check_company_security_ BOOLEAN := FALSE;
BEGIN
   IF project_id_ IS NOT NULL THEN 
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF Project_Access_API.Has_User_Project_Access(project_id_) = 1 THEN
            -- Note: by pass the company security check in this senario.
            check_company_security_ := FALSE;
         ELSE
            check_company_security_ := TRUE;
         END IF;
      $ELSE
         check_company_security_ := TRUE;
      $END
   ELSE
      check_company_security_ := TRUE;
   END IF;
   
   IF check_company_security_ THEN 
      Fetch_Currency_Rate_Base( conversion_factor_,
                                currency_rate_,
                                inverted_,
                                company_,
                                currency_code_,
                                base_currency_code_,
                                currency_type_,
                                date_,
                                is_base_emu_);
   ELSE
      Fetch_Currency_Rate_Base___( conversion_factor_,
                                   currency_rate_,
                                   inverted_,
                                   company_,
                                   currency_code_,
                                   base_currency_code_,
                                   currency_type_,
                                   date_,
                                   is_base_emu_);
   END IF;
END Fetch_Currency_Rate_Base;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Curr_Rate (
   conv_factor_      OUT NUMBER,
   currency_rate_    OUT NUMBER,
   company_          IN VARCHAR2,
   currency_code_    IN VARCHAR2,
   currency_type_    IN VARCHAR2,
   date_             IN DATE )
IS
   rec_                RATE_DATA_REC_TYPE;
   base_currency_code_ VARCHAR2(3);
   is_base_emu_        VARCHAR2(5);
BEGIN
   base_currency_code_   := Company_Finance_API.Get_Currency_Code(company_);
   is_base_emu_          := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   rec_                  := Currency_Rate___(company_, currency_type_, currency_code_, base_currency_code_,date_, is_base_emu_);
   IF (rec_.error_code != 0) THEN
      Display_Error___(rec_.error_code, currency_type_, currency_code_, company_);
   END IF;
   conv_factor_  := rec_.conv_factor;
   IF (rec_.inverted = 'TRUE') THEN
      currency_rate_ := (1/(rec_.currency_rate/rec_.conv_factor));
   ELSE
      currency_rate_ := rec_.currency_rate;
   END IF;
END Get_Curr_Rate;


-- Get_Parallel_Currency_Rate
--   Method to retrieve parallel currency rate based on either transaction currency or accounting currency
--   Output parameters:
--   currency_rate_:         The currency rate between either transaction or accounting currency towards parallel currency
--   conversion_factor_:     Conversion factor of the currency
--   inverted_:              If the currency is an inverted currency or not
--   Input parameters:
--   company_:               Company for which data should be returned
--   trans_curr_code_:       Transaction currency
--   valid_date_:            Date for which to find the rate
--   parallel_curr_type_:    The currency type to find the rate. Could be retrieved by Company_Finance_API.Get_Parallel_Rate_Type if it is not defined from client or in flow.
--   parallel_curr_base_:    Base for calculating parallel currency (TRANSACTION_CURRENCY or ACCOUNTING_CURRENCY), db value
--   acc_curr_code_:         Accounting Currency for the company
--   parallel_curr_code_:    Parallel Currency for the company
--   is_acc_emu_:            If Accounting currency is a valid EMU currency or not
--   is_parallel_emu_:       If Parallel currency is a valid EMU currency or not
--   curr_type_rel_to_:      If the currency type is related to CUSTOMER/SUPPLIER or default type for parallel
@UncheckedAccess
PROCEDURE Get_Parallel_Currency_Rate (
   currency_rate_       OUT NUMBER,
   conversion_factor_   OUT NUMBER,
   inverted_            OUT VARCHAR2,
   company_             IN  VARCHAR2,
   trans_curr_code_     IN  VARCHAR2,
   valid_date_          IN  DATE,
   parallel_curr_type_  IN  VARCHAR2 DEFAULT NULL,
   parallel_curr_base_  IN  VARCHAR2 DEFAULT NULL,
   acc_curr_code_       IN  VARCHAR2 DEFAULT NULL,
   parallel_curr_code_  IN  VARCHAR2 DEFAULT NULL,
   is_acc_emu_          IN  VARCHAR2 DEFAULT NULL,
   is_parallel_emu_     IN  VARCHAR2 DEFAULT NULL,
   curr_type_rel_to_    IN  VARCHAR2 DEFAULT NULL)
IS
BEGIN
   Get_Parallel_Currency_Rate___(currency_rate_,
                                 conversion_factor_,
                                 inverted_,
                                 company_,
                                 trans_curr_code_,
                                 valid_date_,
                                 parallel_curr_type_,
                                 acc_curr_code_,
                                 parallel_curr_code_,
                                 parallel_curr_base_,
                                 is_acc_emu_,
                                 is_parallel_emu_);
END Get_Parallel_Currency_Rate;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Fetch_Defaults (
   conversion_factor_   OUT NUMBER,
   currency_rate_       OUT NUMBER,
   currency_type_       OUT VARCHAR2,
   inverted_            OUT VARCHAR2,
   company_             IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   date_                IN DATE )

IS
   default_type_ VARCHAR2(10);
   rec_          RATE_DATA_REC_TYPE;
   is_base_emu_  VARCHAR2(5);
BEGIN
   default_type_      := Currency_Type_API.Get_Default_Type(company_);
   is_base_emu_       := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   rec_               := Currency_Rate___(company_, default_type_, currency_code_, base_currency_code_, date_, is_base_emu_);
   conversion_factor_ := rec_.conv_factor;
   currency_rate_     := rec_.currency_rate;
   currency_type_     := default_type_;
   inverted_          := rec_.inverted;
END Fetch_Defaults;


@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Conv_Factor_Base (
   company_          IN VARCHAR2,
   currency_code_    IN VARCHAR2,
   currency_type_    IN VARCHAR2,
   date_             IN DATE,
   base_curr_code_   IN VARCHAR2,
   is_base_curr_emu_ IN VARCHAR2 ) RETURN NUMBER
IS
   rec_  RATE_DATA_REC_TYPE;
BEGIN
   rec_ := Currency_Rate___(company_, currency_type_, currency_code_, base_curr_code_, date_, is_base_curr_emu_);
   IF (rec_.error_code != 0) THEN
      RETURN NULL;
   ELSE
      RETURN rec_.conv_factor;
   END IF;
END Get_Conv_Factor_Base;


FUNCTION Currency_Rate_Info (
   company_             IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   currency_code_       IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   date_                IN DATE,
   is_base_emu_         IN VARCHAR2 ) RETURN RATE_DATA_REC_TYPE
IS
   rate_info_  RATE_DATA_REC_TYPE;
BEGIN
   IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
      RETURN Currency_Rate___(company_, currency_type_, currency_code_, base_currency_code_,date_,is_base_emu_);
   ELSE
      RETURN rate_info_;
   END IF;
END Currency_Rate_Info;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Currency_Rate_Defaults (
   currency_type_   IN OUT    VARCHAR2,
   conv_factor_     OUT       NUMBER,
   currency_rate_   OUT       NUMBER,
   company_         IN        VARCHAR2,
   currency_code_   IN        VARCHAR2,
   date_            IN        DATE )
IS
   base_currency_code_  CURRENCY_RATE_TAB.currency_code%TYPE;
   is_base_emu_         VARCHAR2(5);
   type_                VARCHAR2(100);
   rec_                 RATE_DATA_REC_TYPE;
BEGIN
   IF (currency_type_ IS NULL) THEN
      type_ := Currency_Type_API.Get_Default_Type( company_ );
   ELSE
      type_ := currency_type_;
   END IF;
   base_currency_code_  := Company_Finance_API.Get_Currency_Code(company_);
   is_base_emu_         := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, date_);
   rec_                 := Currency_Rate___(company_, type_, currency_code_, base_currency_code_, date_, is_base_emu_);

   IF (rec_.currency_rate IS NULL) THEN          
      Error_SYS.Appl_General(lu_name_, 'NOVALID: The currency code :P1 is not valid in the currency rates for company :P2 and currency type :P3.', currency_code_, company_, type_);  
   END IF;

   IF (rec_.inverted = 'TRUE') THEN
      currency_rate_ := (1/(rec_.currency_rate/rec_.conv_factor))*rec_.conv_factor;
   ELSE
      currency_rate_ := rec_.currency_rate;
   END IF;

   conv_factor_   := rec_.conv_factor;
   currency_type_ := type_;
END Get_Currency_Rate_Defaults;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Max_Eur_Date (
   company_               IN VARCHAR2,
   currency_code_         IN VARCHAR2,
   def_eur_currency_type_ IN VARCHAR2 ) RETURN DATE
IS
   max_valid_from_   CURRENCY_RATE_TAB.Valid_From%TYPE;

   CURSOR Fetch_Date IS
      SELECT MAX(valid_from)
      FROM   CURRENCY_RATE_TAB
      WHERE  company       = company_
      AND    currency_Code = currency_code_
      AND    currency_Type = def_eur_currency_type_;
BEGIN
   OPEN Fetch_Date;
   FETCH Fetch_Date INTO max_valid_from_;
   CLOSE Fetch_Date;
   RETURN max_valid_from_;
END Get_Max_Eur_Date;


PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS
   rec_        Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec('ACCRUL', attr_);

   IF (rec_.make_company = 'EXPORT') THEN
      Export___(rec_);
   ELSIF (rec_.make_company = 'IMPORT') THEN
      IF (rec_.action = 'NEW') THEN
         Import___(rec_);
      ELSIF (rec_.action = 'DUPLICATE') THEN
         Copy___(rec_);
      END IF;
   END IF;
END Make_Company;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Currency_Rate_Base_Disp (
   company_             IN VARCHAR2,
   trans_currency_code_ IN VARCHAR2,
   base_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   trans_date_          IN DATE ) RETURN NUMBER
IS
   rec_           RATE_DATA_REC_TYPE;
   is_base_emu_   VARCHAR2(5);
BEGIN
   is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, base_currency_code_, trans_date_);
   rec_         := Currency_Rate___(company_, currency_type_, trans_currency_code_, base_currency_code_, trans_date_, is_base_emu_);
   IF (rec_.error_code != 0) THEN
      RETURN NULL;
   ELSE
      RETURN rec_.currency_rate;
   END IF;
END Currency_Rate_Base_Disp;


PROCEDURE Get_Currency_Info (
   curr_rate_      IN OUT NUMBER,
   conv_fact_      IN OUT NUMBER,
   company_        IN     VARCHAR2,
   curr_type_      IN     VARCHAR2,
   curr_code_      IN     VARCHAR2,
   date_from_      IN     DATE,
   date_until_     IN     DATE,
   ignore_periods_ IN     BOOLEAN DEFAULT FALSE )
IS
   CURSOR get_curr_rate IS
      SELECT currency_rate,
             conv_factor
      FROM   currency_rate_tab
      WHERE  company       = company_
      AND    currency_type = curr_type_
      AND    currency_code = curr_code_
      AND    valid_from    =
         (SELECT MAX(valid_from)
          FROM   currency_rate_tab
          WHERE  company       = company_
          AND    currency_type = curr_type_
          AND    currency_code = curr_code_
          AND    valid_from BETWEEN date_from_ AND date_until_);

   CURSOR get_curr_rate2 IS
      SELECT currency_rate,
             conv_factor
      FROM   currency_rate_tab
      WHERE  company       = company_
      AND    currency_type = curr_type_
      AND    currency_code = curr_code_
      AND    valid_from    =
         (SELECT MAX(valid_from)
          FROM   currency_rate_tab
          WHERE  company       = company_
          AND    currency_type = curr_type_
          AND    currency_code = curr_code_
          AND    valid_from   <= date_until_);
BEGIN
   IF (ignore_periods_) THEN
      OPEN get_curr_rate2;
      FETCH get_curr_rate2 INTO curr_rate_, conv_fact_;
      CLOSE get_curr_rate2;
   ELSE
      OPEN get_curr_rate;
      FETCH get_curr_rate INTO curr_rate_, conv_fact_;
      CLOSE get_curr_rate;
   END IF;
END Get_Currency_Info;


-- Get_Currency_Rates_For_Company
--   Returns all the currency rates connected to a specific company
FUNCTION Get_Currency_Rates_For_Company (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS

   div_factor_     NUMBER;
   curr_rate_      NUMBER;
   rounding_       NUMBER := 8;
   dom_curr_       VARCHAR2(3);
   inverted_       VARCHAR2(5);
   is_dom_emu_     VARCHAR2(5);
   curr_type_      VARCHAR2(10);
   euro_type_      VARCHAR2(10);
   attr_           VARCHAR2(32000);
   date_           DATE := SYSDATE;

   CURSOR cur_curr is
      SELECT currency_code
      FROM   Currency_Code_Tab cc
      WHERE  cc.company = company_
      AND EXISTS
         (SELECT 1
          FROM   Currency_Rate_Tab cr
          WHERE  cc.company       = cr.company
          AND    cc.currency_code = cr.currency_code
          AND    cr.currency_type IN (curr_type_,euro_type_));

BEGIN
   dom_curr_   := Company_Finance_API.Get_Currency_Code(company_);
   is_dom_emu_ := Currency_Code_API.Get_Emu(company_, dom_curr_);
   curr_type_  := Currency_Type_API.Get_Default_Type(company_);
   euro_type_  := Currency_Type_API.Get_Default_Euro_Type__(company_);
   Client_SYS.Clear_Attr(attr_);

   FOR rec_curr IN cur_curr LOOP
      Currency_Rate_API.Fetch_Currency_Rate_Base (div_factor_,
                                                  curr_rate_,
                                                  inverted_,
                                                  company_,
                                                  rec_curr.currency_code,
                                                  dom_curr_,
                                                  curr_type_,
                                                  date_,
                                                  is_dom_emu_);

      Client_SYS.Add_To_Attr('CURRENCY_CODE', rec_curr.currency_code,attr_);
      Client_SYS.Add_To_Attr('CURRENCY_RATE', ROUND(curr_rate_/div_factor_, rounding_), attr_);
   END LOOP;
   RETURN attr_;
END Get_Currency_Rates_For_Company;



PROCEDURE Get_Currency_Conversion_Rate (
   currency_rate_      OUT NUMBER,
   company_            IN VARCHAR2,
   to_currency_code_   IN VARCHAR2,
   from_currency_code_ IN VARCHAR2,
   currency_type_      IN VARCHAR2,
   valid_from_         IN DATE )
IS
   error_text_ VARCHAR2(2000);
BEGIN
   Get_Currency_Conversion_Rate(currency_rate_,
                                error_text_,
                                company_,           
                                to_currency_code_,  
                                from_currency_code_,
                                currency_type_,     
                                valid_from_);
END Get_Currency_Conversion_Rate;


-- Get_Currency_Conversion_Rate
--   Method that returns the cross rate between two currencies with same currency type
--   The rate is calculated taking the Inverted flag into account so when using this rate in calculations the rate
--   can be applied directly together with the amount (amount * rate_).
PROCEDURE Get_Currency_Conversion_Rate (
   currency_rate_      OUT NUMBER,
   error_text_         OUT VARCHAR2,
   company_            IN VARCHAR2,
   to_currency_code_   IN VARCHAR2,
   from_currency_code_ IN VARCHAR2,
   currency_type_      IN VARCHAR2,
   valid_from_         IN DATE,
   ignore_errors_      IN BOOLEAN DEFAULT FALSE )
IS
   conv_factor_         NUMBER;
   inverted_            VARCHAR2(5);
BEGIN   
   Get_Curr_Conv_Rate_Base___(currency_rate_, conv_factor_, inverted_, error_text_, company_, to_currency_code_, from_currency_code_, currency_type_, valid_from_, ignore_errors_); 
   
   IF (error_text_ IS NULL) THEN
      IF (inverted_ = 'TRUE') THEN
         currency_rate_ := (currency_rate_/conv_factor_);
      ELSE
         currency_rate_ := 1 / (currency_rate_/conv_factor_);
      END IF;
   END IF;      
END Get_Currency_Conversion_Rate;


-- Get_Curr_Conversion_Rate_Base
--   Method that returns the cross rate between two currencies with same currency type, just as if the rate would have
--   been entered in the currency rate table (in same manner as against the ref currency, considering the Inverted Flag)
--   The rate is calculated without taking the Inverted flag into account so when using this rate in calculations the Inverted flag
--   and the Conversion Factor for the reference currency (of the currency_type) needs to be applied.
PROCEDURE Get_Curr_Conversion_Rate_Base (
   currency_rate_       OUT NUMBER,
   conv_factor_         OUT NUMBER, 
   inverted_            OUT VARCHAR2,
   error_text_          OUT VARCHAR2,
   company_             IN VARCHAR2,
   to_currency_code_    IN VARCHAR2,
   from_currency_code_  IN VARCHAR2,
   currency_type_       IN VARCHAR2,
   valid_from_          IN DATE,
   ignore_errors_       IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   Get_Curr_Conv_Rate_Base___(currency_rate_, conv_factor_, inverted_, error_text_, company_, to_currency_code_, from_currency_code_, currency_type_, valid_from_, ignore_errors_); 
END Get_Curr_Conversion_Rate_Base;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Project_Currency_Rate (
   currency_rate_             OUT NUMBER,
   company_                   IN  VARCHAR2,
   currency_code_             IN  VARCHAR2,
   transaction_currency_code_ IN  VARCHAR2,
   currency_type_             IN  VARCHAR2,
   valid_from_                IN  DATE )
IS
   ref_currency_code_ CURRENCY_RATE_TAB.ref_currency_code%TYPE;
   is_base_emu_       VARCHAR2(5);
   valid_from_date_   DATE;
   rec_               RATE_DATA_REC_TYPE;
   ref_to_curr_rate_  NUMBER;
   ref_to_trans_rate_ NUMBER;

   CURSOR get_ref_currency (currency_code_ VARCHAR2) IS
      SELECT a.ref_currency_code, a.valid_from
      FROM CURRENCY_RATE_TAB a
      WHERE a.company        = company_
         AND a.currency_code = currency_code_
         AND a.currency_type = currency_type_
         AND valid_from IN (SELECT MAX(b.valid_from)
                            FROM CURRENCY_RATE_TAB b
                            WHERE b.company        = company_
                               AND b.currency_code = currency_code_
                               AND b.currency_type = currency_type_
                               AND b.valid_from    <= valid_from_);
BEGIN
   --Check currency code exist for currency type
   Check_If_Curr_Code_Exists(company_, currency_type_, currency_code_);

   --Check transaction currency code exist for currency type
   Check_If_Curr_Code_Exists(company_, currency_type_, transaction_currency_code_);

   --Fetch ref_curr/currency_code_
   OPEN get_ref_currency(currency_code_);
   FETCH get_ref_currency INTO ref_currency_code_, valid_from_date_;
   CLOSE get_ref_currency;

   is_base_emu_ := Currency_Code_API.Get_Valid_Emu(company_, ref_currency_code_, valid_from_date_);

   --Fetch currency rate record for currecy_code_ (convert-to currency)
   rec_ := Currency_Rate___(company_, currency_type_, currency_code_, ref_currency_code_, valid_from_date_, is_base_emu_);

   -- Check for errors in fetching the currency rates
   IF (rec_.error_code != 0 ) THEN
      Display_Error___(rec_.error_code, currency_type_, currency_code_, company_);
   END IF;

   IF (rec_.inverted = 'TRUE') THEN
      ref_to_curr_rate_ := (1/(rec_.currency_rate/rec_.conv_factor));
   ELSE
      ref_to_curr_rate_ := rec_.currency_rate/rec_.conv_factor;
   END IF;

   --Fetch ref_curr/trans_curr
   OPEN get_ref_currency(transaction_currency_code_);
   FETCH get_ref_currency INTO ref_currency_code_, valid_from_date_;
   CLOSE get_ref_currency;

   --Fetch currency rate record for transaction_currency_code_ (convert-from currency)
   rec_ := Currency_Rate___(company_, currency_type_, transaction_currency_code_, ref_currency_code_, valid_from_date_, is_base_emu_);

   -- Check for errors in fetching the currency rates
   IF (rec_.error_code != 0 ) THEN
      Display_Error___(rec_.error_code, currency_type_, transaction_currency_code_, company_);
   END IF;

   IF (rec_.inverted = 'TRUE') THEN
      ref_to_trans_rate_ := (1/(rec_.currency_rate/rec_.conv_factor));
   ELSE
      ref_to_trans_rate_ := rec_.currency_rate/rec_.conv_factor;
   END IF;

   --Calculate Currency Rate (Currency rates always > 0, hence no devision by 0)
   currency_rate_ := ref_to_trans_rate_/ref_to_curr_rate_;
END Get_Project_Currency_Rate;


-- Get_Par_Curr_Rate_For_Dir_Calc
--   Method to retrieve parallel currency rate not inverted and without conversion factor, that can be used for direct calculation into the parallel amount
--   without have to deal with conversion factor or if currency is inverted or not.
--   E.g. parallel_amount := (transaction amount or accounting amount) * Get_Par_Curr_Rate_For_Dir_Calc(...)
--   Input parameters:
--   company_:               Company for which data should be returned
--   trans_curr_code_:       Transaction currency
--   valid_date_:            Date for which to find the rate
--   parallel_curr_type_:    The currency type to find the rate. Could be retrieved by Company_Finance_API.Get_Parallel_Rate_Type if it is not defined from client or in flow.
--   acc_curr_code_:         Accounting Currency for the company
--   parallel_curr_code_:    Parallel Currency for the company
--   parallel_curr_base_:    Base for calculating parallel currency (TRANSACTION_CURRENCY or ACCOUNTING_CURRENCY), db value
--   is_acc_emu_:            If Accounting currency is a valid EMU currency or not
--   is_parallel_emu_:       If Parallel currency is a valid EMU currency or not
--   curr_type_rel_to_:      If the currency type is related to CUSTOMER/SUPPLIER or default type for parallel currency (see currency_type_ parameter)
FUNCTION Get_Par_Curr_Rate_For_Dir_Calc (
   company_             IN     VARCHAR2,
   trans_curr_code_     IN     VARCHAR2,
   valid_date_          IN     DATE,
   parallel_curr_type_  IN     VARCHAR2 DEFAULT NULL,
   acc_curr_code_       IN     VARCHAR2 DEFAULT NULL,
   parallel_curr_code_  IN     VARCHAR2 DEFAULT NULL,
   parallel_curr_base_  IN     VARCHAR2 DEFAULT NULL,
   is_acc_emu_          IN     VARCHAR2 DEFAULT NULL,
   is_parallel_emu_     IN     VARCHAR2 DEFAULT NULL,
   curr_type_rel_to_    IN     VARCHAR2 DEFAULT NULL) RETURN NUMBER
IS
   currency_rate_       NUMBER;
   conversion_factor_   NUMBER;
   inverted_            VARCHAR2(5);
BEGIN

   Get_Parallel_Currency_Rate___(currency_rate_,
                                 conversion_factor_,
                                 inverted_,
                                 company_,
                                 trans_curr_code_,
                                 valid_date_,
                                 parallel_curr_type_,
                                 acc_curr_code_,
                                 parallel_curr_code_,
                                 parallel_curr_base_,
                                 is_acc_emu_,
                                 is_parallel_emu_);

   IF (parallel_curr_base_ = 'TRANSACTION_CURRENCY') THEN
      IF (inverted_= 'TRUE') THEN
         currency_rate_ := 1 / (currency_rate_ /conversion_factor_);
      ELSE
         currency_rate_ := currency_rate_ / conversion_factor_;
      END IF;
   ELSIF (parallel_curr_base_ = 'ACCOUNTING_CURRENCY') THEN
      IF (inverted_= 'TRUE') THEN
         currency_rate_ := currency_rate_ / conversion_factor_;
      ELSE
         currency_rate_ := 1 / ( currency_rate_ / conversion_factor_ );
      END IF;
   END IF;

   RETURN currency_rate_;
END Get_Par_Curr_Rate_For_Dir_Calc;


-- Is_Parallel_Curr_Rate_Inverted
--   Method to retrieve if the parallel currency rate is inverted or not. Depends on parallel currency base setting and/or if EMU currency.
--   Returns TRUE/FALSE or NULL if parallel currency is not used in the company
--   Input parameters:
--   company_:               Company for which data should be returned
--   trans_curr_code_:       Transaction currency
@UncheckedAccess
FUNCTION Is_Parallel_Curr_Rate_Inverted (
   company_          IN VARCHAR2,
   trans_curr_code_  IN VARCHAR2) RETURN VARCHAR2
IS
   comp_fin_rec_           Company_Finance_API.Public_Rec := Company_Finance_API.Get(company_);
   inverted_               VARCHAR2(5);
   ref_curr_inverted_      VARCHAR2(5);
   curr_code_to_use_       VARCHAR2(3);
   ref_curr_code_to_use_   VARCHAR2(3);
   is_ref_curr_code_emu_   VARCHAR2(5);
   is_curr_code_emu_       VARCHAR2(5);
BEGIN
   -- check if parallel currency is even used. IF not then NULL is returned
   IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
      IF (comp_fin_rec_.parallel_base = 'TRANSACTION_CURRENCY') THEN
         curr_code_to_use_       := trans_curr_code_;
         ref_curr_code_to_use_   := comp_fin_rec_.parallel_acc_currency;
         is_ref_curr_code_emu_   := Currency_Code_API.Get_Emu(company_,
                                                              comp_fin_rec_.parallel_acc_currency);
      ELSE
         curr_code_to_use_       := comp_fin_rec_.parallel_acc_currency;
         ref_curr_code_to_use_   := comp_fin_rec_.currency_code;
         is_ref_curr_code_emu_   := Currency_Code_API.Get_Emu(company_,
                                                              comp_fin_rec_.currency_code);
      END IF;

      ref_curr_inverted_ := Currency_Code_API.Get_Inverted(company_,
                                                           ref_curr_code_to_use_);

      is_curr_code_emu_  := Currency_Code_API.Get_Valid_Emu(company_,
                                                            curr_code_to_use_,
                                                            SYSDATE);

      IF (ref_curr_code_to_use_ != 'EUR') THEN
         IF (is_ref_curr_code_emu_ = 'FALSE' AND is_curr_code_emu_ = 'TRUE') THEN
            IF (ref_curr_inverted_ = 'FALSE') THEN
               inverted_ := 'FALSE';  
            ELSE
               inverted_ := 'TRUE';
            END IF;     
         ELSIF (is_ref_curr_code_emu_ = 'TRUE' AND is_curr_code_emu_ = 'TRUE') THEN
            inverted_ := 'FALSE';
         ELSIF (is_ref_curr_code_emu_ = 'TRUE' AND is_curr_code_emu_ = 'FALSE') THEN 
            inverted_ := 'FALSE';
         ELSE
            IF (ref_curr_inverted_ = 'FALSE') THEN
               inverted_ := 'FALSE';  
            ELSE
               inverted_ := 'TRUE';
            END IF;  
         END IF;  
      ELSE
         IF (ref_curr_inverted_ = 'FALSE') THEN
            inverted_ := 'FALSE';  
         ELSE
            inverted_ := 'TRUE';
         END IF;  
      END IF;
   END IF;
   RETURN inverted_;
END Is_Parallel_Curr_Rate_Inverted;


@UncheckedAccess
FUNCTION Get_Par_Curr_Rate_Conv_Factor ( 
   company_             IN VARCHAR2,
   trans_curr_code_     IN VARCHAR2,
   trans_date_          IN DATE,
   acc_curr_code_       IN VARCHAR2 DEFAULT NULL,
   parallel_curr_code_  IN VARCHAR2 DEFAULT NULL,
   parallel_base_db_    IN VARCHAR2 DEFAULT NULL,
   parallel_rate_type_  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
IS
   comp_fin_rec_           Company_Finance_API.Public_Rec;
   conv_factor_            NUMBER;
   curr_code_to_use_       VARCHAR2(3);
   ref_curr_code_to_use_   VARCHAR2(3);
   is_ref_curr_code_emu_   VARCHAR2(5);
   tmp_acc_curr_code_      VARCHAR2(3) := acc_curr_code_;
   tmp_parallel_curr_code_ VARCHAR2(3) := parallel_curr_code_;
   tmp_parallel_base_db_   VARCHAR2(25) := parallel_base_db_;
   tmp_parallel_rate_type_ VARCHAR2(10) := parallel_rate_type_;
BEGIN
   -- IF any of the default parameter are null fetch the record to get all data needed in one fetch.
   IF (tmp_acc_curr_code_ IS NULL OR tmp_parallel_curr_code_ IS NULL OR tmp_parallel_base_db_ IS NULL OR tmp_parallel_rate_type_ IS NULL) THEN
      comp_fin_rec_           := Company_Finance_API.Get(company_);
      tmp_acc_curr_code_      := NVL(acc_curr_code_, comp_fin_rec_.currency_code);
      tmp_parallel_curr_code_ := NVL(parallel_curr_code_, comp_fin_rec_.parallel_acc_currency);
      tmp_parallel_base_db_   := NVL(parallel_base_db_, comp_fin_rec_.parallel_base);
      tmp_parallel_rate_type_ := NVL(parallel_rate_type_, comp_fin_rec_.parallel_rate_type);
   END IF;

   -- check if parallel currency is even used. IF not then NULL is returned
   IF (tmp_parallel_curr_code_ IS NOT NULL) THEN
      IF (tmp_parallel_base_db_ = 'TRANSACTION_CURRENCY') THEN
         curr_code_to_use_       := trans_curr_code_;
         ref_curr_code_to_use_   := tmp_parallel_curr_code_;
         is_ref_curr_code_emu_   := Currency_Code_API.Get_Emu(company_,
                                                              tmp_parallel_curr_code_);
      ELSE
         curr_code_to_use_       := tmp_parallel_curr_code_;
         ref_curr_code_to_use_   := tmp_acc_curr_code_;
         is_ref_curr_code_emu_   := Currency_Code_API.Get_Emu(company_,
                                                              tmp_acc_curr_code_);
      END IF;
      conv_factor_ := Get_Conv_Factor_Base(company_,
                                           curr_code_to_use_,
                                           tmp_parallel_rate_type_,
                                           trans_date_,
                                           ref_curr_code_to_use_,
                                           is_ref_curr_code_emu_);
   END IF;
   RETURN conv_factor_;
END Get_Par_Curr_Rate_Conv_Factor;


-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_       IN VARCHAR2,
   currency_type_ IN VARCHAR2,
   valid_from_    IN DATE,
   currency_code_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, currency_type_, currency_code_, valid_from_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist;

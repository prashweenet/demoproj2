-----------------------------------------------------------------------------
--
--  Logical unit: RpdCompany
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151007  chiblk  STRFI-200, New__ changed to New___ in Generate_Rpd_Periods___
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Gen_Params___(
   rpd_id_                 IN VARCHAR2,
   company_                IN VARCHAR2,
   from_accounting_year_   IN NUMBER,
   until_accounting_year_  IN NUMBER)
IS
BEGIN

   Error_SYS.Check_Not_Null(lu_name_, 'RPD_ID',                rpd_id_);
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY',               company_);
   Error_SYS.Check_Not_Null(lu_name_, 'FROM_ACCOUNTING_YEAR',  from_accounting_year_);
   Error_SYS.Check_Not_Null(lu_name_, 'UNTIL_ACCOUNTING_YEAR', until_accounting_year_);

   Rpd_Identity_API.Exist(rpd_id_);
   Company_Finance_API.Exist(company_);
   Accounting_Year_API.Exist(company_, from_accounting_year_);
   Accounting_Year_API.Exist(company_, until_accounting_year_);

   IF (from_accounting_year_ > until_accounting_year_) THEN
      Error_SYS.Appl_General(lu_name_,
                             'INVFROMUNTIL: The accounting year interval :P1 until :P2 is incorrectly defined '||
                                           'for the reporting period definition/company ":P3."',
                             TO_CHAR(from_accounting_year_),
                             TO_CHAR(until_accounting_year_),
                             rpd_id_||'/'||company_);
   END IF;

END Validate_Gen_Params___;


PROCEDURE Generate_Rpd_Periods___(
   rpd_id_                 IN VARCHAR2,
   company_                IN VARCHAR2,
   from_accounting_year_   IN NUMBER,
   until_accounting_year_  IN NUMBER,
   include_year_end_       IN BOOLEAN DEFAULT FALSE)
IS
   year_periods_  Accounting_Year_API.Year_Period_Tab;
   ip_start_      PLS_INTEGER := 1;
   newrec_        rpd_company_tab%ROWTYPE; 
BEGIN
   IF (NOT Check_Exist___(rpd_id_, company_)) THEN
     newrec_.company := company_;
     newrec_.rpd_id  := rpd_id_;
    
     New___(newrec_);
   END IF;             
   
   Validate_Gen_Params___(rpd_id_,
                          company_,
                          from_accounting_year_,
                          until_accounting_year_);
   
   --check if reporting years, corresponding to accounting years, are already defined in the reporting group
   Rpd_Year_API.Exist_Year_In_Interval(rpd_id_,
                                       from_accounting_year_,
                                       until_accounting_year_);

   -- get info about accounting periods for the input company
   Accounting_Year_API.Get_Year_Periods(year_periods_,
                                        company_,
                                        from_accounting_year_,
                                        until_accounting_year_,
                                        include_year_end_);

   FOR iyear_ IN from_accounting_year_..until_accounting_year_ LOOP

      -- create a reporting year corresponding to current accounting year
      Rpd_Year_API.New_Instance(rpd_id_, iyear_);

      -- next create reporting periods for the year according to accounting periods   

      FOR iperiod_ IN ip_start_..NVL(year_periods_.COUNT,0) LOOP

         -- stop period loop if new year
         IF (year_periods_(iperiod_).accounting_year <> iyear_) THEN
            EXIT;
         END IF;
         Rpd_Period_API.New_Instance(rpd_id_,
                                     iyear_,
                                     year_periods_(iperiod_).accounting_period,
                                     year_periods_(iperiod_).date_from,
                                     year_periods_(iperiod_).date_until);

         -- also create a record for the current company connecting the reporting period and
         -- the accounting period
         Rpd_Company_Period_API.New_Instance(rpd_id_,
                                             company_,
                                             year_periods_(iperiod_).accounting_year,
                                             year_periods_(iperiod_).accounting_period,
                                             year_periods_(iperiod_).accounting_year,
                                             year_periods_(iperiod_).accounting_period);
         -- set next period to handle
         ip_start_ := ip_start_ + 1;

      END LOOP;

   END LOOP;
   
END Generate_Rpd_Periods___;


PROCEDURE Map_Accounting_Periods___(
   no_period_count_        OUT NUMBER,
   rpd_id_                 IN  VARCHAR2,
   company_                IN  VARCHAR2,
   from_accounting_year_   IN  NUMBER,
   until_accounting_year_  IN  NUMBER,
   include_year_end_       IN  BOOLEAN DEFAULT FALSE)
IS
   map_count_              NUMBER := 0;     
   ip_start_               PLS_INTEGER := 1;
   year_periods_           Accounting_Year_API.Year_Period_Tab;
   year_period_from_rec_   Rpd_PERIOD_API.Rpd_Year_Period_Rec;
   year_period_until_rec_  Rpd_PERIOD_API.Rpd_Year_Period_Rec;   
BEGIN
   no_period_count_ := 0;
   Validate_Gen_Params___(rpd_id_,
                          company_,
                          from_accounting_year_,
                          until_accounting_year_);

   -- get info about accounting periods for the input company
   Accounting_Year_API.Get_Year_Periods(year_periods_,
                                        company_,
                                        from_accounting_year_,
                                        until_accounting_year_,
                                        include_year_end_);

   -- accounting year loop
   FOR iyear_ IN from_accounting_year_..until_accounting_year_ LOOP

      -- accounting period loop
      FOR iperiod_ IN ip_start_..NVL(year_periods_.COUNT,0) LOOP

         -- stop period loop if new year
         IF (year_periods_(iperiod_).accounting_year <> iyear_) THEN
            EXIT;
         END IF;

         -- get reporting period info for accounting period start (from) date
         year_period_from_rec_ := Rpd_Period_API.Get_Period_For_Date(rpd_id_,
                                                                     year_periods_(iperiod_).date_from);
         IF (year_period_from_rec_.rpd_id IS NOT NULL) THEN
            -- get reporting period info for accounting period end (until) date
            year_period_until_rec_ := Rpd_Period_API.Get_Period_For_Date(rpd_id_,
                                                                         year_periods_(iperiod_).date_until);

            IF (year_period_until_rec_.rpd_id IS NOT NULL) THEN

               -- the from and until date returns a period, now check if the reporting year and period are the same
               
               IF (year_period_from_rec_.rpd_year   = year_period_until_rec_.rpd_year AND
                   year_period_from_rec_.rpd_period = year_period_until_rec_.rpd_period
                  ) THEN

                  -- We have found a reporting period that contains both the from and until date of the
                  -- current accounting period => create the reporting period-accounting period relation
                  -- Do not create an error if the record already exists
                  BEGIN
                     map_count_ := map_count_ + 1;
                     Rpd_Company_Period_API.New_Instance(rpd_id_,
                                                         company_,
                                                         year_period_until_rec_.rpd_year,
                                                         year_period_until_rec_.rpd_period,
                                                         year_periods_(iperiod_).accounting_year,
                                                         year_periods_(iperiod_).accounting_period);
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;
            ELSE
               no_period_count_ := no_period_count_ + 1;               
            END IF;
         END IF;
         -- set next period to handle
         ip_start_ := ip_start_ + 1;
      END LOOP;
   END LOOP;
   IF (map_count_ = 0) THEN
           Error_SYS.Appl_General(lu_name_, 
                                  'NOMATCH: No matching Reporting periods were found for Accounting Year :P1 to Accounting Year :P2.',
                                  p1_ => from_accounting_year_,
                                  p2_ => until_accounting_year_);        
   END IF;           
END Map_Accounting_Periods___;

@Override 
PROCEDURE Raise_Record_Not_Exist___ (
   rpd_id_ IN VARCHAR2,
   company_ IN VARCHAR2) 
IS
BEGIN      
   Error_SYS.Record_Not_Exist(lu_name_,  
                          'GRPCOMPNOTEXIST: :P1 company is not connected to :P2 reporting period definition.',
                           company_,
                           rpd_id_);    
   super(rpd_id_, company_);    
END Raise_Record_Not_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Generate_Rpd_Periods(
   rpd_id_                 IN VARCHAR2,
   company_                IN VARCHAR2,
   from_accounting_year_   IN NUMBER,
   until_accounting_year_  IN NUMBER,
   include_year_end_       IN VARCHAR2 DEFAULT 'FALSE')
IS
   no_period_count_        NUMBER := 0;
BEGIN
   -- No need to create the details for opening/closing periods, 
   -- because they should be part of the normal accounting periods, as long as there is atleast one normal acc period
   Generate_Rpd_Periods___(rpd_id_,
                           company_,
                           from_accounting_year_,
                           until_accounting_year_,
                           FALSE);
   
   Map_Accounting_Periods___(no_period_count_,
                             rpd_id_,
                             company_,
                             from_accounting_year_,
                             until_accounting_year_,
                             NVL(include_year_end_, 'FALSE') = 'TRUE');
END Generate_Rpd_Periods;


PROCEDURE Map_Accounting_Periods(
   no_period_count_        OUT VARCHAR2,
   rpd_id_                 IN  VARCHAR2,
   company_                IN  VARCHAR2,
   from_accounting_year_   IN  NUMBER,
   until_accounting_year_  IN  NUMBER,
   include_year_end_       IN  VARCHAR2 DEFAULT 'FALSE')
IS
BEGIN
   Map_Accounting_Periods___(no_period_count_,
                             rpd_id_,
                             company_,
                             from_accounting_year_,
                             until_accounting_year_,
                             include_year_end_ = 'TRUE');
END Map_Accounting_Periods;




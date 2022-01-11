-----------------------------------------------------------------------------
--
--  Logical unit: RpdYear
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151007  chiblk  STRFI-200, New__ changed to New___ in New_Instance
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

DEF_NO_PERIODS_PER_YEAR  CONSTANT PLS_INTEGER := 12;

TYPE Period_Interval_Rec IS RECORD
(
    interval_start_date  DATE,
    interval_until_date  DATE,
    next_start_date      DATE
);


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Generate_Rpd_Periods___(
   rpd_id_               IN VARCHAR2,
   rpd_year_             IN NUMBER,
   calendar_year_        IN NUMBER,
   from_calendar_month_  IN NUMBER)
IS   
   -- opens up for alternative implementation!!
   no_period_     PLS_INTEGER  := DEF_NO_PERIODS_PER_YEAR;
   pirec_         Period_Interval_Rec;

BEGIN
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_ID', rpd_id_);
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_YEAR', rpd_year_);

   Rpd_Identity_API.Exist(rpd_id_);
   Exist(rpd_id_, rpd_year_);
   IF((NVL(from_calendar_month_, 1) > 12) OR (NVL(from_calendar_month_, 1) < 1)) THEN
      Error_SYS.Appl_General(lu_name_, 'INVMONTH: Start month should be between 1 - 12.');
   END IF;        
   pirec_.interval_start_date := Get_Start_Date___(calendar_year_, from_calendar_month_);

   FOR iperiod_ IN 1..no_period_ LOOP
      pirec_ := Get_Interval_Info___(pirec_);

      Rpd_Period_API.New_Instance(rpd_id_,
                                  rpd_year_,
                                  iperiod_,
                                  pirec_.interval_start_date,
                                  pirec_.interval_until_date);
      
      pirec_.interval_start_date := pirec_.next_start_date;
      
   END LOOP;
   
END Generate_Rpd_Periods___;


PROCEDURE Exist_Year_In_Interval___(
   rpd_id_          IN VARCHAR2,
   from_rpd_year_   IN NUMBER,
   until_rpd_year_  IN NUMBER)
IS
   idum_  PLS_INTEGER;
   CURSOR find_year IS
      SELECT 1
      FROM RPD_YEAR_TAB
      WHERE rpd_id = rpd_id_
      AND   rpd_year BETWEEN from_rpd_year_ AND until_rpd_year_;
BEGIN
   OPEN find_year;
   FETCH find_year INTO idum_;
   IF (find_year%FOUND) THEN
      CLOSE find_year;
      Error_SYS.Appl_General(lu_name_,
                              'YEAREXIST: Reporting years between time interval :P2 to :P3 already exist for reporting period definition :P1.',
                              rpd_id_,
                              TO_CHAR(from_rpd_year_),
                              TO_CHAR(until_rpd_year_));
   END IF;
   CLOSE find_year;
END Exist_Year_In_Interval___;


FUNCTION Get_Start_Date___(
   rpd_year_    IN NUMBER,
   start_month_ IN NUMBER) RETURN DATE
IS
   ymd_string_      VARCHAR2(10);  
BEGIN
   -- opens up for alernative implementaion
   ymd_string_ := TO_CHAR(rpd_year_) || NVL(TO_CHAR(start_month_, 'FM00'), '01') || '01';

   RETURN(TRUNC(TO_DATE(ymd_string_, 'YYYYMMDD')));
END Get_Start_Date___;


FUNCTION Get_Interval_Info___(
   period_interval_rec_  IN Period_Interval_Rec) RETURN Period_Interval_Rec
IS
   new_rec_  Period_Interval_Rec;
BEGIN
   new_rec_.interval_start_date := period_interval_rec_.interval_start_date;

   new_rec_.interval_until_date := TRUNC(ADD_MONTHS(new_rec_.interval_start_date, 1) - 1);

   new_rec_.next_start_date     := TRUNC(new_rec_.interval_until_date + 1); 

   RETURN(new_rec_);
   
END Get_Interval_Info___;


PROCEDURE Validate_Insert___(
   newrec_   IN RPD_YEAR_TAB%ROWTYPE)
IS
BEGIN
   IF (newrec_.rpd_year <= 0) THEN
      Error_SYS.Appl_General(lu_name_,
                             'INVALIDYEAR: Reporting year :P1 in :P2 reporting period definition is invalid. '||
                                          'The reporting year must be greater than 0.',
                             TO_CHAR(newrec_.rpd_year),
                             newrec_.rpd_id);
   END IF;
END Validate_Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT rpd_year_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   Validate_Insert___(newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   rpd_id_ IN VARCHAR2,
   rpd_year_ IN NUMBER )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_,  
                              'YEARNOTEXIST: Reporting year :P1 does not exist for :P2 reporting period definition.',
                              rpd_year_,
                              rpd_id_);
   super(rpd_id_, rpd_year_);
END Raise_Record_Not_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Generate_Rpd_Periods(
   rpd_id_               IN VARCHAR2,
   rpd_year_             IN NUMBER,
   calendar_year_        IN NUMBER,
   from_calendar_month_  IN NUMBER)  
IS
BEGIN
   Generate_Rpd_Periods___(rpd_id_,
                           rpd_year_,
                           calendar_year_,
                           from_calendar_month_);      

END Generate_Rpd_Periods;


PROCEDURE Exist_Year_In_Interval(
   rpd_id_         IN VARCHAR2,
   from_rpd_year_  IN NUMBER,
   until_rpd_year_ IN NUMBER)
IS
BEGIN
   Exist_Year_In_Interval___(rpd_id_,
                             from_rpd_year_, 
                             until_rpd_year_);
END Exist_Year_In_Interval;


PROCEDURE New_Instance( 
   rpd_id_       IN VARCHAR2,
   rpd_year_     IN NUMBER)
IS
   newrec_     rpd_year_tab%ROWTYPE;
BEGIN
   newrec_.rpd_id    := rpd_id_;
   newrec_.rpd_year  := rpd_year_;

   New___(newrec_);
END New_Instance;




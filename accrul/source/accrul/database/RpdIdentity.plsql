-----------------------------------------------------------------------------
--
--  Logical unit: RpdIdentity
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0Over
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131101  Lamalk  PBFI-2090, Refactored code according to template standards
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Generate_Rpd_Periods___(
   rpd_id_               IN VARCHAR2,
   from_calendar_year_   IN NUMBER,
   until_calendar_year_  IN NUMBER,
   from_calendar_month_  IN NUMBER,
   start_rpd_year_       IN NUMBER)
IS
   i_    NUMBER := 0;        
BEGIN
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_ID', rpd_id_);
   Error_SYS.Check_Not_Null(lu_name_, 'FROM_CALENDAR_YEAR', from_calendar_year_);
   Error_SYS.Check_Not_Null(lu_name_, 'UNTIL_CALENDAR_YEAR', until_calendar_year_);

   IF (from_calendar_year_ > until_calendar_year_) THEN
      Error_SYS.Appl_General(lu_name_,
                             'INVFROMUNTIL: The reporting year interval :P1 until :P2 is incorrectly defined for '||
                                           'reporting period definition :P3.',
                             TO_CHAR(from_calendar_year_),
                             TO_CHAR(until_calendar_year_),
                             rpd_id_);
   END IF;
   
   Exist(rpd_id_);
   Rpd_Year_API.Exist_Year_In_Interval(rpd_id_, 
                                       start_rpd_year_, 
                                       start_rpd_year_ + (until_calendar_year_ - from_calendar_year_));

   FOR iyear_ IN start_rpd_year_..(start_rpd_year_ + (until_calendar_year_ - from_calendar_year_)) LOOP
      Rpd_Year_API.New_Instance( rpd_id_, iyear_ );

      Rpd_Year_API.Generate_Rpd_Periods(rpd_id_,
                                        iyear_,
                                        from_calendar_year_ + i_,
                                        from_calendar_month_);
      i_ := i_ + 1;
   END LOOP;
   
END Generate_Rpd_Periods___;


FUNCTION Is_Rpd_Periods_Defined___(
   rpd_id_               IN VARCHAR2) RETURN VARCHAR2   
IS
   return_  VARCHAR2(5) := 'FALSE';    
   dummy_   NUMBER;        
   
   CURSOR is_year_defined IS
      SELECT 1           
      FROM   rpd_period_tab      
      WHERE  rpd_id = rpd_id_;      
BEGIN
   OPEN  is_year_defined;        
   FETCH is_year_defined INTO dummy_;
   IF (is_year_defined%FOUND) THEN   
      return_ := 'TRUE';        
   END IF;        
   CLOSE is_year_defined;        
   RETURN return_;
END Is_Rpd_Periods_Defined___;


@Override
PROCEDURE Unpack___ (
   newrec_   IN OUT rpd_identity_tab%ROWTYPE,
   indrec_   IN OUT Indicator_Rec,
   attr_     IN OUT VARCHAR2 )
IS
BEGIN
   IF (Client_SYS.Item_Exist('RPD_ID', attr_)) THEN
      newrec_.rpd_id := UPPER(Client_SYS.Cut_Item_Value('RPD_ID', attr_));
   END IF;
   super(newrec_, indrec_, attr_);
END Unpack___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   rpd_id_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_,  
                                'GRPNOTEXIST: Reporting period definition identity ":P1" does not exist.',
                                 rpd_id_);
   super(rpd_id_);
END Raise_Record_Not_Exist___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Generate_Rpd_Periods(
   rpd_id_               IN VARCHAR2,
   from_calendar_year_   IN NUMBER,
   until_calendar_year_  IN NUMBER,
   from_calendar_month_  IN NUMBER,
   start_rpd_year_       IN NUMBER)
IS
BEGIN
   IF (LENGTH(from_calendar_year_) != 4)  THEN
      Error_SYS.Appl_General(lu_name_, 'STARTYEARLENGTH: The Start Year should consist of four characters.');
   END IF;      
   IF (LENGTH(start_rpd_year_) != 4)  THEN
      Error_SYS.Appl_General(lu_name_, 'FIRSTYEARLENGTH: The First Year should consist of four characters.');
   END IF;   
   Generate_Rpd_Periods___(rpd_id_,
                           from_calendar_year_, 
                           until_calendar_year_,
                           from_calendar_month_,
                           start_rpd_year_);
END Generate_Rpd_Periods;


@UncheckedAccess
FUNCTION Is_Rpd_Periods_Defined(
   rpd_id_               IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN Is_Rpd_Periods_Defined___(rpd_id_);
END Is_Rpd_Periods_Defined;        




-----------------------------------------------------------------------------
--
--  Logical unit: RpdPeriod
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

TYPE Rpd_Year_Period_Rec IS RECORD
(
   rpd_id          RPD_PERIOD_TAB.rpd_id%TYPE,
   rpd_year        RPD_PERIOD_TAB.rpd_year%TYPE,
   rpd_period      RPD_PERIOD_TAB.rpd_period%TYPE,
   year_period_num RPD_PERIOD_TAB.year_period_num%TYPE
);


-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE Current_Relative_Info_Rec IS RECORD
(
    current_year          PLS_INTEGER,
    current_period        PLS_INTEGER,
    current_quarter       PLS_INTEGER,
    current_half_year     PLS_INTEGER,
    current_rel_period    PLS_INTEGER,
    current_rel_year      PLS_INTEGER,
    current_rel_quarter   PLS_INTEGER,
    current_rel_half_year PLS_INTEGER
);


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Yp_To_Out_Str___(
   year_      IN NUMBER,
   period_    IN NUMBER) RETURN VARCHAR2
IS
BEGIN
   RETURN(TO_CHAR(year_)||' '||TO_CHAR(period_));
END Yp_To_Out_Str___;


FUNCTION Date_To_Out_Str___(
   date_      IN DATE) RETURN VARCHAR2
IS
BEGIN
   RETURN(TO_CHAR(date_,'YYYY-MM-DD'));
END Date_To_Out_Str___;


PROCEDURE Set_Year_Period___(
   newrec_   IN OUT RPD_PERIOD_TAB%ROWTYPE)
IS
BEGIN
   newrec_.year_period_num := TO_CHAR(newrec_.rpd_year)||
                              TO_CHAR(newrec_.rpd_period,'FM00');
   newrec_.year_period_str := TO_CHAR(newrec_.year_period_num);
END Set_Year_Period___;


PROCEDURE Validate_Insert___(
   newrec_   IN RPD_PERIOD_TAB%ROWTYPE)
IS
BEGIN
   Validate_Dates___(newrec_, TRUE);
   Validate_Period___(newrec_);
END Validate_Insert___;


PROCEDURE Validate_Modify___(
   newrec_   IN RPD_PERIOD_TAB%ROWTYPE)
IS
BEGIN
   Validate_Dates___(newrec_, FALSE);
END Validate_Modify___;


PROCEDURE Validate_Period___(
   rec_   IN RPD_PERIOD_TAB%ROWTYPE)
IS
BEGIN
   IF (rec_.rpd_period <= 0) THEN
      Error_SYS.Appl_General(lu_name_,
                             'INVALIDPERIOD: Reporting period :P1 connected to reporting year :P2 in '||
                                            'reporting period definition :P3 is invalid. The reporting period must be greater than 0.',
                             TO_CHAR(rec_.rpd_period),
                             TO_CHAR(rec_.rpd_year),
                             rec_.rpd_id);
   END IF;
END Validate_Period___;


PROCEDURE Validate_Dates___(
   rpd_period_rec_  IN RPD_PERIOD_TAB%ROWTYPE,
   insert_mode_     IN BOOLEAN DEFAULT TRUE)
IS
   error_found_  BOOLEAN;
   dummy_        NUMBER; 
   dummy1_       NUMBER;   
   INVALID_DATES EXCEPTION;

   CURSOR C1 IS
      SELECT *
      FROM   RPD_PERIOD_TAB
      WHERE  rpd_id  = rpd_period_rec_.rpd_id
      AND    ((rpd_period_rec_.from_date  >= from_date AND rpd_period_rec_.from_date  <= until_date)
             OR
              (rpd_period_rec_.until_date >= from_date AND rpd_period_rec_.until_date <= until_date)
             OR
              (rpd_period_rec_.from_date   < from_date AND rpd_period_rec_.until_date >  until_date));
   
   CURSOR C2 IS
      SELECT rpd_period 
      FROM   RPD_PERIOD_TAB
      WHERE  rpd_id     = rpd_period_rec_.rpd_id
      AND    rpd_year   = rpd_period_rec_.rpd_year
      AND    rpd_period < rpd_period_rec_.rpd_period 
      AND    until_date > rpd_period_rec_.from_date; 
   
   CURSOR C3 IS
      SELECT rpd_period 
      FROM   RPD_PERIOD_TAB
      WHERE  rpd_id     = rpd_period_rec_.rpd_id
      AND    rpd_year   = rpd_period_rec_.rpd_year
      AND    rpd_period > rpd_period_rec_.rpd_period 
      AND    until_date < rpd_period_rec_.from_date; 
   
   CURSOR C4 IS   
      SELECT rpd_year, rpd_period 
      FROM   RPD_PERIOD_TAB
      WHERE  rpd_id     = rpd_period_rec_.rpd_id
      AND    rpd_year   < rpd_period_rec_.rpd_year 
      AND    until_date > rpd_period_rec_.from_date; 
   
   CURSOR C5 IS   
      SELECT rpd_year, rpd_period 
      FROM   RPD_PERIOD_TAB
      WHERE  rpd_id     = rpd_period_rec_.rpd_id
      AND    rpd_year   > rpd_period_rec_.rpd_year 
      AND    until_date < rpd_period_rec_.from_date; 
BEGIN
   IF (rpd_period_rec_.from_date > rpd_period_rec_.until_date) THEN
      Error_SYS.Appl_General(lu_name_, 
                             'INVDATE1: The from and until dates of reporting period definition :P1 and '||
                                        'reporting period :P2 are invalid. The from date :P3 must be earlier than the until date, or same as the until date.',
                             rpd_period_rec_.rpd_id,
                             Yp_To_Out_Str___(rpd_period_rec_.rpd_year,rpd_period_rec_.rpd_period),
                             Date_To_Out_Str___(rpd_period_rec_.from_date));
   END IF;

   -- Loop over found incorrect intervals and handle the special case where the in-from and in-until date are equal.
   -- For this case it is ok if in-from=in-until=from or in-from=in-until=until
   FOR rec_ IN C1 LOOP
      error_found_ := TRUE;

      IF (rpd_period_rec_.from_date  = rec_.from_date AND
          rpd_period_rec_.until_date = rec_.until_date) THEN
         IF (NOT insert_mode_) THEN
            error_found_ := FALSE;
         END IF;
         
      ELSIF (rpd_period_rec_.from_date = rpd_period_rec_.until_date) THEN
         IF (rpd_period_rec_.from_date = rec_.from_date  OR
             rpd_period_rec_.from_date = rec_.until_date) THEN
            error_found_ := FALSE;
         END IF;
      
      ELSIF (rec_.from_date = rec_.until_date) THEN
         IF (rpd_period_rec_.from_date  = rec_.from_date  OR
             rpd_period_rec_.until_date = rec_.from_date) THEN
            error_found_ := FALSE;
         END IF;

      END IF;
      
      IF (error_found_) THEN
         RAISE INVALID_DATES;
      END IF;
      
   END LOOP;
   IF (insert_mode_) THEN
      OPEN C2;
      FETCH C2 INTO dummy_;     
      IF (C2%FOUND) THEN
         CLOSE C2;     
         Error_SYS.Appl_General(lu_name_,
                             'INVDATE2: The from date cannot be earlier than the until date of the reporting period :P1.',
                             dummy_);        
      END IF;              
      CLOSE C2;
      OPEN C3;
      FETCH C3 INTO dummy_;     
      IF (C3%FOUND) THEN
         CLOSE C3;     
         Error_SYS.Appl_General(lu_name_,
                             'INVDATE3: The until date cannot be later than the from date of the reporting period :P1.',
                             dummy_);        
      END IF;              
      CLOSE C3;
      OPEN C4;
      FETCH C4 INTO dummy_, dummy1_;     
      IF (C4%FOUND) THEN
         CLOSE C4;     
         Error_SYS.Appl_General(lu_name_,
                             'INVDATE4: The from date cannot be earlier than the until date of the reporting year :P1 period :P2.',
                             p1_ => dummy_,
                             p2_ => dummy1_);        
      END IF;
      CLOSE C4;
      OPEN C5;
      FETCH C5 INTO dummy_, dummy1_;     
      IF (C5%FOUND) THEN
         CLOSE C5;     
         Error_SYS.Appl_General(lu_name_,
                             'INVDATE5: The until date cannot be later than the from date of the reporting year :P1 period :P2.',
                             p1_ => dummy_,
                             p2_ => dummy1_);        
      END IF;
      CLOSE C5;
   END IF;
EXCEPTION
   WHEN INVALID_DATES THEN
      Error_SYS.Appl_General(lu_name_,
                             'INVDATE6: The date range :P1 until :P2 overlaps with another reporting period :P3. Change the from date or the until date as relevant.',
                             Date_To_Out_Str___(rpd_period_rec_.from_date),
                             Date_To_Out_Str___(rpd_period_rec_.until_date),
                             rpd_period_rec_.rpd_id);
END Validate_Dates___;


FUNCTION Get_Period_For_Date___(
   rpd_id_          IN VARCHAR2,
   reporting_date_  IN DATE) RETURN Rpd_Year_Period_Rec
IS
   yp_rec_     Rpd_Year_Period_Rec;
   rec_        RPD_PERIOD_TAB%ROWTYPE;
   rep_date_   DATE := TRUNC(reporting_date_);

   CURSOR get_period IS
     SELECT *
      FROM RPD_PERIOD_TAB
      WHERE rpd_id      = rpd_id_
      AND   from_date  <= rep_date_
      AND   until_date >= rep_date_;
BEGIN
   OPEN get_period;
   FETCH get_period INTO rec_;
   CLOSE get_period;

   Clear_Year_Period_Rec___(yp_rec_);
   
   IF (rec_.rpd_id IS NOT NULL) THEN
      yp_rec_.rpd_id           := rec_.rpd_id;
      yp_rec_.rpd_year         := rec_.rpd_year;
      yp_rec_.rpd_period       := rec_.rpd_period;
      yp_rec_.year_period_num  := rec_.year_period_num;
   END IF;
   
   RETURN(yp_rec_);
END Get_Period_For_Date___;


PROCEDURE Clear_Year_Period_Rec___(
   year_period_rec_  IN OUT  Rpd_Year_Period_Rec)
IS
BEGIN
    year_period_rec_.rpd_id     := NULL;
    year_period_rec_.rpd_year   := NULL;
    year_period_rec_.rpd_period := NULL;
END Clear_Year_Period_Rec___;

PROCEDURE Generate_Rpd_Period_Details___(
   rpd_id_              IN VARCHAR2,
   rpd_year_            IN NUMBER,
   rpd_period_          IN NUMBER,
   interval_start_date_ IN DATE,
   interval_end_date_   IN DATE)
IS
   date_ DATE;
BEGIN
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_ID', rpd_id_);
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_YEAR', rpd_year_);
   Error_SYS.Check_Not_Null(lu_name_, 'RPD_PERIOD', rpd_period_);

   Rpd_Identity_API.Exist(rpd_id_);
   Exist(rpd_id_, rpd_year_, rpd_period_);
   date_ := interval_start_date_;
   WHILE (date_ <= interval_end_date_) LOOP
      Rpd_Period_Detail_API.New_Instance(rpd_id_,
                                         rpd_year_,
                                         rpd_period_,
                                         date_);      
      date_ := date_ + 1;
   END LOOP;   
END Generate_Rpd_Period_Details___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT RPD_PERIOD_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Generate_Rpd_Period_Details(newrec_.rpd_id, newrec_.rpd_year, newrec_.rpd_period, newrec_.from_date, newrec_.until_date);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT rpd_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   Set_Year_Period___(newrec_);
   super(newrec_, indrec_, attr_);
   Validate_Insert___(newrec_);
   Client_SYS.Add_To_Attr('YEAR_PERIOD_NUM', newrec_.year_period_num, attr_);
   Client_SYS.Add_To_Attr('YEAR_PERIOD_STR', newrec_.year_period_str, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     rpd_period_tab%ROWTYPE,
   newrec_ IN OUT rpd_period_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'FROM_DATE', newrec_.from_date);
   Error_SYS.Check_Not_Null(lu_name_, 'UNTIL_DATE', newrec_.until_date);

   Validate_Modify___(newrec_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   rpd_id_ IN VARCHAR2,
   rpd_year_ IN NUMBER,
   rpd_period_ IN NUMBER )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_,  
                                'PERIODNOTEXIST: Reporting period :P1 does not exist in reporting year '||
                                                ':P2 in reporting period definition :P3.',
                                 TO_CHAR(rpd_period_),
                                 TO_CHAR(rpd_year_),
                                 rpd_id_);
   super(rpd_id_, rpd_year_, rpd_period_);
END Raise_Record_Not_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Period_For_Date(
   rpd_id_          IN VARCHAR2,
   reporting_date_  IN DATE) RETURN Rpd_Year_Period_Rec
IS
BEGIN
   RETURN(Get_Period_For_Date___(rpd_id_, reporting_date_));
END Get_Period_For_Date;


PROCEDURE New_Instance(
   rpd_id_        IN VARCHAR2,
   rpd_year_      IN NUMBER,
   rpd_period_    IN NUMBER,
   from_date_     IN DATE,
   until_date_    IN DATE)
IS
   newrec_        rpd_period_tab%ROWTYPE;
BEGIN
   newrec_.rpd_id       := rpd_id_;
   newrec_.rpd_year     := rpd_year_;
   newrec_.rpd_period   := rpd_period_;
   newrec_.from_date    := from_date_;
   newrec_.until_date   := until_date_;
   
   New___(newrec_);
END New_Instance;


PROCEDURE Generate_Rpd_Period_Details(
   rpd_id_              IN VARCHAR2,
   rpd_year_            IN NUMBER,
   rpd_period_          IN NUMBER,
   interval_start_date_ IN DATE,
   interval_end_date_   IN DATE)
IS
BEGIN
   Generate_Rpd_Period_Details___(rpd_id_,
                                  rpd_year_,
                                  rpd_period_,
                                  interval_start_date_,
                                  interval_end_date_);
   
END Generate_Rpd_Period_Details;        




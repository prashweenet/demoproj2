-----------------------------------------------------------------------------
--
--  Logical unit: RpdCompanyPeriod
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


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Period_Usage___(
   rec_  IN RPD_COMPANY_PERIOD_TAB%ROWTYPE)
IS
   idum_     PLS_INTEGER;
   
   CURSOR locate_period IS
      SELECT 1
      FROM RPD_COMPANY_PERIOD_TAB
      WHERE  rpd_id                = rec_.rpd_id
      AND    company               = rec_.company
      AND    accounting_year       = rec_.accounting_year
      AND    accounting_period     = rec_.accounting_period;
BEGIN
   
   OPEN locate_period;
   FETCH locate_period INTO idum_;
   IF (locate_period%FOUND) THEN
      CLOSE locate_period;
      Error_SYS.Appl_General(lu_name_,
                             'PERIODDUPLICATE: The accounting year :P1 and period :P2 is already defined in another '||
                                             'reporting period definition :P3.',
                             rec_.accounting_year,
                             rec_.accounting_period,
                             rec_.rpd_id);
   END IF;
   CLOSE locate_period;
END Validate_Period_Usage___;


FUNCTION Yp_To_Out_Str___(
   year_      IN NUMBER,
   period_    IN NUMBER) RETURN VARCHAR2
IS
BEGIN
   RETURN(TO_CHAR(year_)||' '||TO_CHAR(period_));
END Yp_To_Out_Str___;


PROCEDURE Validate_Insert___(
   rec_    RPD_COMPANY_PERIOD_TAB%ROWTYPE)
IS
BEGIN
   Validate_Period_Usage___(rec_);
END Validate_Insert___;


PROCEDURE Delete_Details___(
   rec_   IN RPD_COMPANY_PERIOD_TAB%ROWTYPE)
IS
   acc_date_         DATE;
   dummy_            NUMBER;
   det_rec_          rpd_company_period_det_tab%ROWTYPE;
   
   CURSOR details_exist IS
      SELECT 1 
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id       = rec_.rpd_id
      AND    rpd_year     = rec_.rpd_year
      AND    rpd_period   = rec_.rpd_period
      AND    company      = rec_.company;
   
   CURSOR other_acc_info_exist IS
      SELECT 1 
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id          = rec_.rpd_id
      AND    rpd_year        = rec_.rpd_year
      AND    rpd_period      = rec_.rpd_period
      AND    company         = rec_.company
      AND    accounting_date != acc_date_
      AND    accounting_date IS NOT NULL;
   
   CURSOR update_row IS
      SELECT *
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id          = rec_.rpd_id
      AND    rpd_year        = rec_.rpd_year
      AND    rpd_period      = rec_.rpd_period
      AND    company         = rec_.company
      AND    accounting_date = acc_date_
      ORDER BY reporting_date;
BEGIN
   -- get date interval
   acc_date_   := Accounting_Period_API.Get_Date_From(rec_.company, rec_.accounting_year, rec_.accounting_period);
   
   OPEN details_exist;
   FETCH details_exist INTO dummy_;
   IF (details_exist%FOUND) THEN
      OPEN other_acc_info_exist;
      FETCH other_acc_info_exist INTO dummy_;
      IF (other_acc_info_exist%FOUND) THEN
         OPEN update_row;
         FETCH update_row INTO det_rec_;
         Rpd_Company_Period_Det_API.New_Instance(det_rec_.rpd_id,
                                                 det_rec_.company,
                                                 det_rec_.rpd_year,
                                                 det_rec_.rpd_period,
                                                 det_rec_.reporting_date,
                                                 NULL);
         CLOSE update_row;      
         CLOSE other_acc_info_exist;
         RETURN;
      ELSE
         DELETE 
         FROM   rpd_company_period_det_tab t
         WHERE  t.rpd_id = rec_.rpd_id
         AND    t.company= rec_.company
         AND    t.rpd_year=rec_.rpd_year
         AND    t.rpd_period = rec_.rpd_period;        
      END IF;
      CLOSE other_acc_info_exist;      
   END IF;
   CLOSE details_exist;
END Delete_Details___;


PROCEDURE Generate_Details___(
   rec_   IN RPD_COMPANY_PERIOD_TAB%ROWTYPE)
IS
   curr_date_        DATE;
   until_date_       DATE;
   acc_date_         DATE;
   dummy_            NUMBER;
   det_rec_          rpd_company_period_det_tab%ROWTYPE;
   
   CURSOR details_exist IS
      SELECT 1 
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id       = rec_.rpd_id
      AND    rpd_year     = rec_.rpd_year
      AND    rpd_period   = rec_.rpd_period
      AND    company      = rec_.company;
   
   CURSOR info_exist IS
      SELECT 1 
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id          = rec_.rpd_id
      AND    rpd_year        = rec_.rpd_year
      AND    rpd_period      = rec_.rpd_period
      AND    company         = rec_.company
      AND    accounting_date = acc_date_;
   
   CURSOR update_row IS
      SELECT *
      FROM   rpd_company_period_det_tab 
      WHERE  rpd_id       = rec_.rpd_id
      AND    rpd_year     = rec_.rpd_year
      AND    rpd_period   = rec_.rpd_period
      AND    company      = rec_.company
      AND    accounting_date IS NULL
      ORDER BY reporting_date;
BEGIN
   -- get date interval
   acc_date_   := Accounting_Period_API.Get_Date_From(rec_.company, rec_.accounting_year, rec_.accounting_period);
   
   OPEN info_exist;
   FETCH info_exist INTO dummy_;
   IF (info_exist%FOUND) THEN
      CLOSE info_exist;
      RETURN;
   END IF;
   CLOSE info_exist;
   
   OPEN details_exist;
   FETCH details_exist INTO dummy_;
   IF (details_exist%FOUND) THEN
      CLOSE details_exist;
      OPEN update_row;
      FETCH update_row INTO det_rec_;
      Rpd_Company_Period_Det_API.New_Instance(det_rec_.rpd_id,
                                              det_rec_.company,
                                              det_rec_.rpd_year,
                                              det_rec_.rpd_period,
                                              det_rec_.reporting_date,
                                              acc_date_);
      CLOSE update_row;
   ELSE
      CLOSE details_exist;      
      
      curr_date_  := Rpd_Period_API.Get_From_Date(rec_.rpd_id, rec_.rpd_year, rec_.rpd_period);
      until_date_ := Rpd_Period_API.Get_Until_Date(rec_.rpd_id, rec_.rpd_year, rec_.rpd_period);

      WHILE curr_date_ <= until_date_ LOOP

          Rpd_Company_Period_Det_API.New_Instance(rec_.rpd_id,
                                                  rec_.company,
                                                  rec_.rpd_year,
                                                  rec_.rpd_period,
                                                  curr_date_,
                                                  acc_date_);

          curr_date_ := curr_date_ + 1;
      END LOOP;
   END IF;
END Generate_Details___;


-- Check_Exist___
--   Check if a specific LU-instance already exist in the database.
FUNCTION Check_Exist___(
   company_              IN VARCHAR2,
   accounting_year_      IN NUMBER,
   accounting_period_    IN NUMBER) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist IS
      SELECT 1 
      FROM   RPD_COMPANY_PERIOD_TAB t
      WHERE  t.company            = company_
        AND  t.accounting_year    = accounting_year_
        AND  t.accounting_period  = accounting_period_;   
BEGIN
   OPEN  exist; 
   FETCH exist INTO dummy_;
   CLOSE exist;
   RETURN NVL(dummy_, 0) = 1; 
END Check_Exist___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT rpd_company_period_tab%ROWTYPE,
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
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT rpd_company_period_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   Gen_Rpd_Com_Period_Dets(newrec_.rpd_id, newrec_.company, newrec_.rpd_year, newrec_.rpd_period, newrec_.accounting_year, newrec_.accounting_period);
   Client_SYS.Add_To_Attr('SPLIT_ACCOUNTING_PERIOD', 
                           Get_Split_Accounting_Period(newrec_.rpd_id, 
                                                       newrec_.company, 
                                                       newrec_.rpd_year, 
                                                       newrec_.rpd_period, 
                                                       newrec_.accounting_year, 
                                                       newrec_.accounting_period), 
                             attr_);
END Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN rpd_company_period_tab%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Delete_Details___(remrec_);
END Delete___;


@Override
PROCEDURE Raise_Record_Not_Exist___ (
   rpd_id_ IN VARCHAR2,
   company_ IN VARCHAR2,
   rpd_year_ IN NUMBER,
   rpd_period_ IN NUMBER,
   accounting_year_ IN NUMBER,
   accounting_period_ IN NUMBER )
IS
BEGIN
   Error_SYS.Record_Not_Exist(lu_name_,  
                    'NOTEXIST: The accounting period :P1 which is associated with reporting period :P2 does not exist for '||
                              'the reporting period definition/company :P3.',
                     Yp_To_Out_Str___(accounting_year_, accounting_period_), 
                     Yp_To_Out_Str___(rpd_year_, rpd_period_), 
                     company_||'/'||rpd_id_);
   super(rpd_id_, company_, rpd_year_, rpd_period_, accounting_year_, accounting_period_);
END Raise_Record_Not_Exist___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Split_Accounting_Period (
   rpd_id_ IN VARCHAR2,
   company_ IN VARCHAR2,
   rpd_year_ IN NUMBER,
   rpd_period_ IN NUMBER,
   accounting_year_ IN NUMBER,
   accounting_period_ IN NUMBER ) RETURN NUMBER
IS
   acc_public_rec_   accounting_period_api.Public_Rec;
   rpd_public_rec_   rpd_period_api.Public_Rec;
   
   return_ NUMBER := 0;
BEGIN
   acc_public_rec_ := Accounting_Period_API.Get(company_, accounting_year_, accounting_period_);
   rpd_public_rec_ := Rpd_Period_API.Get(rpd_id_, rpd_year_, rpd_period_);
   IF ( NOT ( (acc_public_rec_.date_from >= rpd_public_rec_.from_date) AND (acc_public_rec_.date_until <= rpd_public_rec_.until_date) )  ) THEN
      return_ := 1;
   END IF;
   RETURN return_;   
END Get_Split_Accounting_Period;


@UncheckedAccess
FUNCTION Check_Exist(
   company_              IN VARCHAR2,
   accounting_year_      IN NUMBER,
   accounting_period_    IN NUMBER) RETURN BOOLEAN
IS
BEGIN
   RETURN Check_Exist___(company_, accounting_year_, accounting_period_);   
END Check_Exist;


PROCEDURE Gen_Rpd_Com_Period_Dets(
   rpd_id_               IN VARCHAR2,
   company_              IN VARCHAR2,
   rpd_year_             IN NUMBER,
   rpd_period_           IN NUMBER,
   accounting_year_      IN NUMBER,
   accounting_period_    IN NUMBER)
IS
BEGIN
      
   Generate_Details___(Get_Object_By_Keys___(rpd_id_,
                                             company_,
                                             rpd_year_,
                                             rpd_period_,
                                             accounting_year_,
                                             accounting_period_));
   
END Gen_Rpd_Com_Period_Dets;        


PROCEDURE New_Instance(
   rpd_id_               IN VARCHAR2,
   company_              IN VARCHAR2,
   rpd_year_             IN NUMBER,
   rpd_period_           IN NUMBER,
   accounting_year_      IN NUMBER,
   accounting_period_    IN NUMBER)
IS
   newrec_        rpd_company_period_tab%ROWTYPE;
BEGIN
   newrec_.rpd_id             := rpd_id_;
   newrec_.company            := company_;
   newrec_.rpd_year           := rpd_year_;
   newrec_.rpd_period         := rpd_period_;
   newrec_.accounting_year    := accounting_year_;
   newrec_.accounting_period  := accounting_period_;

   New___(newrec_);
END New_Instance;




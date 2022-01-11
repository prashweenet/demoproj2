-----------------------------------------------------------------------------
--
--  Logical unit: RpdPeriodDetail
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

PROCEDURE Validate_Date___(
   rpd_period_det_rec_  IN RPD_PERIOD_DETAIL_TAB%ROWTYPE)
IS
   dummy_ NUMBER;     
   CURSOR date_exist IS
      SELECT 1
      FROM   RPD_PERIOD_DETAIL_TAB
      WHERE  rpd_id         = rpd_period_det_rec_.rpd_id
      AND    reporting_date = rpd_period_det_rec_.reporting_date;
BEGIN
   OPEN date_exist;
   FETCH date_exist INTO dummy_;      
   IF (date_exist%FOUND) THEN
      CLOSE date_exist;     
      Error_SYS.Appl_General(lu_name_,
                             'INVDATE: Reporting date :P1 is already included in an existing reporting period interval '||
                                      'in reporting period definition :P2.',
                             Date_To_Out_Str___(rpd_period_det_rec_.reporting_date),
                             rpd_period_det_rec_.rpd_id);
   END IF;   
   CLOSE date_exist;
END Validate_Date___;


FUNCTION Date_To_Out_Str___(
   date_      IN DATE) RETURN VARCHAR2
IS
BEGIN
   RETURN(TO_CHAR(date_,'YYYY-MM-DD'));
END Date_To_Out_Str___;



@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     rpd_period_detail_tab%ROWTYPE,
   newrec_ IN OUT rpd_period_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Validate_Date___(newrec_);
END Check_Common___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE New_Instance(
   rpd_id_             IN VARCHAR2,
   rpd_year_           IN NUMBER,
   rpd_period_         IN NUMBER,
   reporting_date_     IN DATE)
IS
   newrec_        rpd_period_detail_tab%ROWTYPE;
BEGIN
   newrec_.rpd_id          := rpd_id_;
   newrec_.rpd_year        := rpd_year_;
   newrec_.rpd_period      := rpd_period_;
   newrec_.reporting_date  := reporting_date_;

   New___(newrec_);
END New_Instance;




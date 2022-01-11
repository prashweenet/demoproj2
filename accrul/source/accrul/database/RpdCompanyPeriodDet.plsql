-----------------------------------------------------------------------------
--
--  Logical unit: RpdCompanyPeriodDet
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131101  Lamalk  PBFI-2089, Refactored code according to new template standards
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Is_Acc_Date_Defined___(
   rpd_id_     IN VARCHAR2,
   company_    IN VARCHAR2,
   rpd_year_   IN NUMBER,
   rpd_period_ IN NUMBER,
   acc_date_   IN DATE) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   
   CURSOR acc_date_exist IS
      SELECT 1 
      FROM   RPD_COMPANY_PERIOD_DET_TAB t
      WHERE  rpd_id          = rpd_id_
      AND    rpd_year        = rpd_year_
      AND    rpd_period      = rpd_period_
      AND    company         = company_
      AND    accounting_date = acc_date_;
BEGIN   
   OPEN acc_date_exist;
   FETCH acc_date_exist INTO dummy_;
   IF (acc_date_exist%FOUND) THEN
      CLOSE acc_date_exist;
      RETURN TRUE;
   END IF;
   CLOSE acc_date_exist;
   RETURN FALSE;
END Is_Acc_Date_Defined___; 


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT rpd_company_period_det_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   IF (Is_Acc_Date_Defined___  (newrec_.rpd_id,
                                newrec_.company,
                                newrec_.rpd_year,
                                newrec_.rpd_period,
                                newrec_.accounting_date)) THEN
      newrec_.accounting_date := NULL;                             
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE New_Instance (
   rpd_id_               IN VARCHAR2,
   company_              IN VARCHAR2,
   rpd_year_             IN NUMBER,
   rpd_period_           IN NUMBER,
   reporting_date_       IN DATE,
   accounting_date_      IN DATE )
IS
   attr_             VARCHAR2(2000);
   info_             VARCHAR2(100);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
BEGIN

   Client_SYS.Clear_Attr(attr_);
   Get_Id_Version_By_Keys___(objid_, objversion_, rpd_id_, company_, rpd_year_, rpd_period_, reporting_date_);
   
   IF(objid_ IS NOT NULL) THEN
      Client_SYS.Add_To_Attr('ACCOUNTING_DATE',      accounting_date_,      attr_);
      Rpd_Company_Period_Det_API.Modify__(info_, objid_, objversion_, attr_, 'DO');
   ELSE
      Client_SYS.Add_To_Attr('RPD_ID',               rpd_id_,               attr_);
      Client_SYS.Add_To_Attr('COMPANY',              company_,              attr_);
      Client_SYS.Add_To_Attr('RPD_YEAR',             rpd_year_,             attr_);
      Client_SYS.Add_To_Attr('RPD_PERIOD',           rpd_period_,           attr_);
      Client_SYS.Add_To_Attr('REPORTING_DATE',       reporting_date_,       attr_);
      Client_SYS.Add_To_Attr('ACCOUNTING_DATE',      accounting_date_,      attr_);

      Rpd_Company_Period_Det_API.New__(info_, objid_, objversion_, attr_, 'DO');
   END IF;

END New_Instance;



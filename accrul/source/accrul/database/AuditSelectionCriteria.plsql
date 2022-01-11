-----------------------------------------------------------------------------
--
--  Logical unit: AuditSelectionCriteria
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
PROCEDURE Add_New_Log__ (
   rec_           IN OUT Audit_Selection_Criteria_Tab%ROWTYPE,
   company_       IN VARCHAR2,
   country_       IN VARCHAR2,
   report_type_   IN VARCHAR2,
   valid_from_    IN DATE,
   valid_to_      IN DATE)
IS
BEGIN
   Accounting_Period_API.Get_Accounting_Year(rec_.period_start_year, rec_.period_start, company_, valid_from_);
   Accounting_Period_API.Get_Accounting_Year(rec_.period_end_year, rec_.period_end, company_, valid_to_);
   rec_.company := company_;
   rec_.country := ISO_COUNTRY_API.Encode(country_);
   rec_.report_type := Audit_Report_Types_API.Encode(report_type_);
   rec_.report_id := AUDIT_REPORT_LOG_SEQ.NEXTVAL;
   rec_.tax_rep_jur := NULL;
   rec_.company_entity := company_;
   rec_.selection_start_date := valid_from_;
   rec_.selection_end_date := valid_to_;
   rec_.document_type := 'XML';
   rec_.other_criteria := NULL;
   rec_.status := 'Posted';
   rec_.audit_file_date_created := SYSDATE;
   rec_.User_id := Fnd_Session_API.Get_Fnd_User;
   New___(rec_);
END Add_New_Log__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


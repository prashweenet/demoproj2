-----------------------------------------------------------------------------
--
--  Logical unit: AuditFormat
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  1200709 SALIDE   EDEL-1191, Added default_format
--  131022  PRatlk   CAHOOK-2822, Refactoring according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT audit_format_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   IF Check_Default__(newrec_.company) THEN
      newrec_.default_format := 'TRUE';
   ELSE
      newrec_.default_format := 'FALSE';
   END IF;
   super(objid_, objversion_, newrec_, attr_);
   Client_SYS.Add_To_Attr('DEFAULT_FORMAT', newrec_.default_format, attr_);
END Insert___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'DECIMAL_POINT',      Audit_Decimal_API.Get_Client_Value(0), attr_);
   Client_SYS.Add_To_Attr( 'THOUSAND_SEPARATOR', Audit_Thousand_Fmt_API.Get_Client_Value(1), attr_);
   Client_SYS.Add_To_Attr( 'NEGATIVE_FORMAT',    Audit_Negative_Fmt_API.Get_Client_Value(0), attr_);
   Client_SYS.Add_To_Attr( 'LEADING_ZEROES',     Audit_Zero_Format_API.Get_Client_Value(1), attr_);
   Client_SYS.Add_To_Attr( 'TIME_FORMAT',        Audit_Time_Format_API.Get_Client_Value(0), attr_);
   Client_SYS.Add_To_Attr( 'DATE_FORMAT',        Audit_Date_Format_API.Get_Client_Value(0), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     audit_format_tab%ROWTYPE,
   newrec_ IN OUT audit_format_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_); 
   
   IF (Audit_Decimal_API.Get_Value(newrec_.decimal_point) = Audit_Decimal_API.Get_Value(newrec_.thousand_separator)) THEN
      Error_SYS.Record_General(lu_name_, 'INVSIGN: The Decimal Point must be different from the Thousand Seperator.');
   END IF;
END Check_Common___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

FUNCTION Check_Default__ (
   company_ IN audit_format_tab.company%type) RETURN BOOLEAN
IS
   CURSOR check_available IS
      SELECT COUNT(*) total_no
      FROM   audit_format_tab
      WHERE  company         = company_
      AND    default_format = 'TRUE';
   total_        check_available%ROWTYPE;
BEGIN 
   OPEN  check_available;
   FETCH check_available INTO total_;
   CLOSE check_available;
   IF ( total_.total_no = 0 ) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END Check_Default__;

PROCEDURE Only_One_Default_Format__ (
   company_       IN VARCHAR2 )
IS
   CURSOR check_available IS
      SELECT COUNT(*) total_no
      FROM   audit_format_tab
      WHERE  company         = company_
      AND    default_format = 'TRUE';
   CURSOR check_existance IS
      SELECT COUNT(*) total_no
      FROM   audit_format_tab
      WHERE  company        = company_;
   total_        check_available%ROWTYPE;
BEGIN
   OPEN  check_existance;
   FETCH check_existance INTO total_;
   CLOSE check_existance;
   IF ( total_.total_no = 0 ) THEN
      RETURN;
   END IF;
   OPEN  check_available;
   FETCH check_available INTO total_;
   CLOSE check_available;
   IF ( total_.total_no = 0 ) THEN
      Error_SYS.Record_General( lu_name_, 'ONEATLEASTAUDITFORM: There must be at least one default format' );
   ELSIF ( total_.total_no > 1 ) THEN
      Error_SYS.Record_General( lu_name_, 'EXACTLYONEAUDITFORM: There must be only one default format' );
   END IF;
END Only_One_Default_Format__;

PROCEDURE Get_External_File_Info__(
   file_type_        OUT VARCHAR2,
   file_template_id_ OUT VARCHAR2,
   company_       IN VARCHAR2,
   country_       IN VARCHAR2,
   report_type_   IN VARCHAR2 DEFAULT NULL)
IS
   rec_ Public_Rec;
BEGIN
   rec_ := Get(company_, Iso_Country_Api.Encode(country_) , Audit_Report_Types_Api.Encode(report_type_));
   file_type_ := rec_.file_type;
   file_template_id_ := rec_.file_template_id;
END Get_External_File_Info__;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Default_Country (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ VARCHAR2(200);
   CURSOR get_def IS
      SELECT country
        FROM audit_format
       WHERE company = company_
         AND default_format = 'TRUE';
BEGIN
   OPEN  get_def;
   FETCH get_def INTO temp_;
   CLOSE get_def;
   RETURN temp_;
END Get_Default_Country;




PROCEDURE Audit_Format_Exist (
   company_ IN VARCHAR2,
   country_ IN VARCHAR2,
   report_type_ IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   IF (NOT Check_Exist___(company_, Iso_Country_API.Encode(country_), Audit_Report_Types_API.Encode(report_type_))) THEN
      Error_SYS.Record_General(lu_name_, 'NOFORMAT: There is no Audit Format specified for country :P1 in company :P2', country_, company_);
   END IF;
END Audit_Format_Exist;

@UncheckedAccess
FUNCTION Get_Report_Type (
   company_ IN VARCHAR2,
   country_ IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ VARCHAR2(200);
   CURSOR get_def IS
      SELECT report_type
        FROM audit_format
       WHERE company = company_
       AND country = country_;
BEGIN
   OPEN  get_def;
   FETCH get_def INTO temp_;
   CLOSE get_def;
   RETURN temp_;
END Get_Report_Type;

@UncheckedAccess
FUNCTION Get_Def_Report_Type (
   company_ IN VARCHAR2,
   country_ IN VARCHAR2) RETURN VARCHAR2
IS
   temp_ VARCHAR2(200);
   CURSOR get_def IS
      SELECT report_type
        FROM audit_format
       WHERE company = company_
       AND country = country_
       AND default_format = 'TRUE';
BEGIN
   OPEN  get_def;
   FETCH get_def INTO temp_;
   CLOSE get_def;
   RETURN temp_;
END Get_Def_Report_Type;

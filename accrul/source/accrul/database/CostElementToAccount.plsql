-----------------------------------------------------------------------------
--
--  Logical unit: CostElementToAccount
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  070626  Bmekse   Created
--  070829  Thpelk   Call Id 147800 - added NOCHECK opition to view COST_ELEMENT_TO_ACCOUNT_ALL account column.
--  090605  THPELK   Bug 82609 - Added UNDEFINE section and the missing statements for VIEW2, VIEWPCT.
--  100120  Nuvelk  TWIN PEAKS Merge.
            --  090119  Ersruk   Validation added in Unpack_Check_Insert___ to check exclude_proj_followup.
            --  090217  Makrlk   Added new column code_part to the view COST_ELEMENT_TO_ACCOUNT_ALL.
            --  090217  Makrlk   Added the function Exist_Cost_Elements()
            --  090219  Makrlk   Added the column valid_from to the view COST_ELEMENT_TO_ACCOUNT_ALL.
            --  090306  Makrlk   modified the view COST_ELEMENT_TO_ACCOUNT_PCT
            --  090306  Makrlk   modified the methods Export___(), Import___() and Copy___()
            --  091005  Ersruk   Added function Get_Account_Cost_Element().
--  100907  Nsillk   EAPM-4072, fixed some issues in view COST_ELEMENT_TO_ACCOUNT_ALL and unpack_check_insert
--  111024  Saallk   SPJ-31, Secondary mapping improvements.  
--  120221  Sacalk   SFI-2425,   Modified the VIEW COST_ELEMENT_TO_ACCOUNT_ALL
--  120320  Sacalk   SFI-2396,   Modified in FUNCTION Get_Project_Follow_Up_Element
--  120330  Waudlk   EASTRTM-8102, Modified  COST_ELEMENT_TO_ACCOUNT_ALL view to add SORT
--  131030  Umdolk   PBFI-1885, Refactoring.
--  160510  CPriLK   Bug 129046, Added function Get_Account_Cost_Element() to return cost element per code part which valid for given date.
--  171030  CHRALK   STRPJ-25100, Modified method Get_Project_Follow_Up_Element(), by adding new parameter default_element_type_.
--  180509  Savmlk   Bug 141587, Added new condition to Check_Common___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ cost_element_to_account_tab%ROWTYPE )
IS  
BEGIN
   Error_SYS.Record_General(lu_name_, 'OBJECTEXIST: The Project Cost/Revenue Element per Code part value object already exists');
   super(rec_);
END Raise_Record_Exist___;


@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2,
   valid_from_ IN DATE )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'OBJECTNOTEXIST: The Project Cost/Revenue Element per Code part value object does not exist');
   super(company_, account_, valid_from_);
END Raise_Record_Not_Exist___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     cost_element_to_account_tab%ROWTYPE,
   newrec_ IN OUT cost_element_to_account_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   exclude_proj_followup_  VARCHAR2(5);
   base_for_followup_      VARCHAR2(1);
BEGIN
   indrec_.account := FALSE;
   super(oldrec_, newrec_, indrec_, attr_);  
   base_for_followup_ := Accounting_Code_Parts_API.Get_Base_For_Followup_Element(newrec_.company);
   
   IF (base_for_followup_ = 'A') THEN
      exclude_proj_followup_ := NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE');
      IF ( exclude_proj_followup_= 'TRUE') AND (newrec_.project_cost_element IS NOT NULL) THEN
         Error_SYS.Record_General(lu_name_, 'EXCLUDEPROJ: Account :P1 is setup to exclude project follow up.', newrec_.account);
      END IF;
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT cost_element_to_account_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN   
   super(newrec_, indrec_, attr_);     
   IF (Accounting_Code_Part_Value_API.Code_Part_Value_Exist(newrec_.company,newrec_.code_part,newrec_.account) = 'FALSE')THEN
      Error_SYS.Record_Not_Exist(lu_name_, 'CODEPVALNOTEXIST: Code Part Value ":P1" does not exist in company ":P2"',newrec_.account,newrec_.company);
   END IF;
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Reference_Pfe__ (
   attr_ IN VARCHAR2 )
IS
   count_ NUMBER;
   company_ COST_ELEMENT_TO_ACCOUNT_TAB.company%TYPE := substr(attr_,1,instr(attr_,'^')-1);
   project_cost_element_ COST_ELEMENT_TO_ACCOUNT_TAB.project_cost_element%TYPE := substr(attr_,instr(attr_,'^')+1,instr(attr_,'^',1,2) - (instr(attr_,'^')+1));
BEGIN
   count_:= Get_Followup_Element_Count(company_,project_cost_element_);
   IF count_>0  THEN
      Error_SYS.Record_General(lu_name_, 'PFECONNEXIST: The Project Follow up Element ":P1" cannot be deleted since it has connected to :P2 Code Part values .',project_cost_element_,count_);
   END IF;
END Check_Reference_Pfe__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@Override
@UncheckedAccess
FUNCTION Get_Project_Cost_Element (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2,
   valid_from_ IN DATE ) RETURN VARCHAR2
IS
   temp_ COST_ELEMENT_TO_ACCOUNT_TAB.project_cost_element%TYPE;
BEGIN
   temp_ := super(company_, account_, valid_from_);
   IF (temp_ IS NOT NULL) THEN
      RETURN temp_;
   ELSE
      RETURN Project_Cost_Element_API.Get_Default_For_Company(company_);
   END IF;   
END Get_Project_Cost_Element;




@UncheckedAccess
FUNCTION Is_Account_Connected (
   company_ IN VARCHAR2,
   project_cost_element_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR is_connected IS
      SELECT 1
      FROM COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE company = company_
      AND project_cost_element = project_cost_element_;
   dummy_ NUMBER;
BEGIN
   OPEN is_connected;
   FETCH is_connected INTO dummy_;
   IF is_connected%FOUND THEN
      CLOSE is_connected;
      RETURN TRUE;
   ELSE
      CLOSE is_connected;
      RETURN FALSE;
   END IF;
END Is_Account_Connected;




@UncheckedAccess
FUNCTION Exist_Cost_Elements(
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE  company = company_
      AND    code_part = code_part_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Exist_Cost_Elements;




@UncheckedAccess
FUNCTION Get_Followup_Element_Count(
   company_          IN VARCHAR2,
   followup_element_  IN VARCHAR2) RETURN NUMBER
IS
   count_ NUMBER;
   CURSOR get_element_count IS
      SELECT count(*)
      FROM   COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE  company = company_
      AND    project_cost_element = followup_element_;
BEGIN
   OPEN get_element_count;
   FETCH get_element_count INTO count_;
   IF (get_element_count%FOUND) THEN
      CLOSE get_element_count;
      RETURN count_;
   END IF;
   CLOSE get_element_count;
   RETURN count_;
END Get_Followup_Element_Count;




FUNCTION Get_Project_Follow_Up_Element(
   company_                       IN VARCHAR2,
   code_a_                        IN VARCHAR2 DEFAULT NULL,
   code_b_                        IN VARCHAR2 DEFAULT NULL,
   code_c_                        IN VARCHAR2 DEFAULT NULL,
   code_d_                        IN VARCHAR2 DEFAULT NULL,
   code_e_                        IN VARCHAR2 DEFAULT NULL,
   code_f_                        IN VARCHAR2 DEFAULT NULL,
   code_g_                        IN VARCHAR2 DEFAULT NULL,
   code_h_                        IN VARCHAR2 DEFAULT NULL,
   code_i_                        IN VARCHAR2 DEFAULT NULL,
   code_j_                        IN VARCHAR2 DEFAULT NULL,
   valid_from_                    IN DATE DEFAULT NULL,
   generate_errors_               IN VARCHAR2 DEFAULT 'FALSE',
   posting_type_                  IN VARCHAR2 DEFAULT NULL,
   default_element_type_          IN VARCHAR2 DEFAULT 'COST_ONLY' ) RETURN VARCHAR2
IS
   temp_                          COST_ELEMENT_TO_ACCOUNT_TAB.project_cost_element%TYPE;
   base_code_part_                VARCHAR2(2);
   new_valid_from_                DATE;
   code_part_value_               VARCHAR2(20);
   default_cost_element_          VARCHAR2(100);
   exclude_proj_followup_         VARCHAR2(5);   
   default_revenue_element_       VARCHAR2(100);
   account_type_                  VARCHAR2(2);
   

   base_null                      EXCEPTION;
   code_null                      EXCEPTION;
   cost_element_null              EXCEPTION;
   cost_revenue_element_null      EXCEPTION;

   CURSOR get_attr IS
      SELECT project_cost_element
      FROM   COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE  company     = company_
      AND    account     = code_part_value_
      AND    code_part   = base_code_part_
      AND    valid_from <= new_valid_from_
      ORDER BY valid_from DESC;

BEGIN
   
   base_code_part_ := Accounting_Code_Parts_API.Get_Base_For_Followup_Element(company_);
   
   IF base_code_part_ IS NULL THEN
      RAISE base_null;
   END IF;

   IF valid_from_ IS NULL THEN
      new_valid_from_ := sysdate;
   ELSE
      new_valid_from_ := valid_from_;
   END IF;

   IF base_code_part_ = 'A' THEN
      code_part_value_ := code_a_;
   ELSIF base_code_part_ = 'B' THEN
      code_part_value_ := code_b_;
   ELSIF base_code_part_ = 'C' THEN
      code_part_value_ := code_c_;
   ELSIF base_code_part_ = 'D' THEN
      code_part_value_ := code_d_;
   ELSIF base_code_part_ = 'E' THEN
      code_part_value_ := code_e_;
   ELSIF base_code_part_ = 'F' THEN
      code_part_value_ := code_f_;
   ELSIF base_code_part_ = 'G' THEN
      code_part_value_ := code_g_;
   ELSIF base_code_part_ = 'H' THEN
      code_part_value_ := code_h_;
   ELSIF base_code_part_ = 'I' THEN
      code_part_value_ := code_i_;
   ELSIF base_code_part_ = 'J' THEN
      code_part_value_ := code_j_;
   END IF;
   
   default_cost_element_ := Project_Cost_Element_API.Get_Default_No_Base(company_); 

   IF ( code_part_value_ IS NULL ) THEN
      IF ( default_cost_element_  IS NULL ) THEN
         RAISE code_null;
      ELSE
         RETURN default_cost_element_;
      END IF ;
   END IF;

   IF ((code_a_ IS NOT NULL) AND (generate_errors_ ='TRUE')) THEN
      exclude_proj_followup_ := nvl(Account_API.Get_Exclude_Proj_Followup(company_, code_a_), 'FALSE');
      IF (exclude_proj_followup_ = 'TRUE') THEN
         Error_SYS.Record_General(lu_name_,
                                  'ACCEXCLPRJFL: Account :P1 in Company :P2 is set to Exclude Project Follow-up. Project Connections cannot be created for this Account.', code_a_, company_);
      END IF;
   END IF;

   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   
   IF (temp_ IS NOT NULL) THEN
      RETURN temp_;
   ELSE
      default_cost_element_ := Project_Cost_Element_API.Get_Default_For_Company(company_);

      IF (default_element_type_ = 'BOTH') THEN --Only the revenue reporting objects (to projects) pass in the value 'BOTH' 
         account_type_ := Account_API.Get_Accnt_Type_Db (company_, code_a_);
         IF (account_type_ = 'R') THEN
            default_revenue_element_ := Project_Cost_Element_API.Get_Default_Rev_For_Company(company_);
            IF (default_revenue_element_ IS NOT NULL) THEN
               RETURN default_revenue_element_;
            ELSIF (default_cost_element_ IS NOT NULL) THEN
               RETURN default_cost_element_;
            ELSE
               RAISE cost_revenue_element_null;
            END IF;
         ELSE
            IF (default_cost_element_ IS NULL) THEN
               RAISE cost_element_null;
            ELSE
               RETURN default_cost_element_;              
            END IF;
         END IF;
      ELSE --COST_ONLY
         IF (default_cost_element_ IS NULL) THEN
            RAISE cost_element_null;
         ELSE
            RETURN default_cost_element_;
         END IF;         
      END IF;
   END IF;
   
EXCEPTION
   WHEN base_null THEN
      IF generate_errors_ ='TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'BASEISNULL: Base for project cost/revenue element in company :P1 is not specified',company_);
      ELSE
         RETURN NULL;
      END IF;
   WHEN code_null THEN
      IF generate_errors_ ='TRUE' THEN
         IF posting_type_ IS NOT NULL THEN
            Error_SYS.Record_General(lu_name_, 'CODENULLWITHPOSTING: The value for code part :P1 is missing in posting type :P2',Accounting_Code_Parts_API.Get_Description(company_, base_code_part_),posting_type_);
         ELSE
            Error_SYS.Record_General(lu_name_, 'CODEISNULL: Code part :P1 is used for project cost/revenue element and must be entered',Accounting_Code_Parts_API.Get_Description(company_, base_code_part_));
         END IF;
      ELSE
         RETURN NULL;
      END IF;
   WHEN cost_element_null THEN
      IF generate_errors_ ='TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'COSTELMISNULL: There is no project cost element connected to code part value :P1',code_part_value_);
      ELSE
         RETURN NULL;
      END IF;
   WHEN cost_revenue_element_null THEN
      IF (generate_errors_ ='TRUE') THEN
         Error_SYS.Record_General(lu_name_, 'COSTREVELMISNULL: There is no project cost/revenue element connected to code part value :P1', code_part_value_);
      ELSE
         RETURN NULL;
      END IF;
END Get_Project_Follow_Up_Element;


FUNCTION Get_Project_Follow_Up_Element(
   company_                       IN VARCHAR2,
   code_rec_                      IN Accounting_Codestr_Api.CodestrRec,
   valid_from_                    IN DATE DEFAULT NULL,
   generate_errors_               IN VARCHAR2 DEFAULT 'FALSE',
   posting_type_                  IN VARCHAR2 DEFAULT NULL,
   default_element_type_          IN VARCHAR2 DEFAULT 'COST_ONLY') RETURN VARCHAR2
IS

BEGIN
   RETURN Get_Project_Follow_Up_Element(company_, code_rec_.code_a, code_rec_.code_b, code_rec_.code_c,
                                    code_rec_.code_d, code_rec_.code_e, code_rec_.code_f, code_rec_.code_g,
                                    code_rec_.code_h, code_rec_.code_i, code_rec_.code_j, valid_from_,
                                    generate_errors_, posting_type_, default_element_type_);
END Get_Project_Follow_Up_Element;


@UncheckedAccess
FUNCTION Get_Account_Cost_Element (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ COST_ELEMENT_TO_ACCOUNT_TAB.project_cost_element%TYPE;
   CURSOR get_attr IS
      SELECT project_cost_element
      FROM COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE company = company_
      AND   account = account_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Account_Cost_Element;

@UncheckedAccess
FUNCTION Get_Account_Cost_Element (
   company_    IN VARCHAR2,
   account_    IN VARCHAR2,
   valid_from_ IN DATE) RETURN VARCHAR2
IS
   temp_ COST_ELEMENT_TO_ACCOUNT_TAB.project_cost_element%TYPE;
   
   CURSOR get_cost_element IS
      SELECT project_cost_element
      INTO   temp_
      FROM   COST_ELEMENT_TO_ACCOUNT_TAB
      WHERE  company     = company_
      AND    account     = account_
      AND    valid_from <= valid_from_
      ORDER BY valid_from DESC;
BEGIN
   OPEN  get_cost_element;
   FETCH get_cost_element INTO temp_;
   CLOSE get_cost_element;
   RETURN temp_;
END Get_Account_Cost_Element;

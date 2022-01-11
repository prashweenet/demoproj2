-----------------------------------------------------------------------------
--
--  Logical unit: CostEleToAccntSecmap
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131030  Umdolk  PBFI-1904, Refactoring.
--  120829  JuKoDE  EDEL-1532, Modified General_SYS.Init_Method in Copy_Elements_To_Sec_Map__()
--  120320  Mohrlk  EASTRTM-5397, Modified methods Insert___() and Update___().
--  111025  SaAlLK  SPJ-552, Added new method Copy_Elements_To_Sec_Map__.
--  111024  DeKoLK  SPJ-548, Create
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ cost_ele_to_accnt_secmap_tab%ROWTYPE )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'SECMAPDUPEXIST: Secondary project cost/revenue element per code part value object already exists.');
   super(rec_);
END Raise_Record_Exist___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'CODE_PART', 'A', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     cost_ele_to_accnt_secmap_tab%ROWTYPE,
   newrec_ IN OUT cost_ele_to_accnt_secmap_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   exclude_proj_followup_  VARCHAR2(5);
BEGIN
   indrec_.account := FALSE;
   super(oldrec_, newrec_, indrec_, attr_);
   
   exclude_proj_followup_ := NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE');
   IF ( exclude_proj_followup_= 'TRUE') AND (newrec_.project_cost_element IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_, 'SECMAPEXCLUDEPROJ: It is not possible to define a Project Cost/Revenue Element for Account :P1, as it is set up to Exclude Project Follow-Up.', newrec_.account);
   END IF;
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT cost_ele_to_accnt_secmap_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS      
BEGIN   
   super(newrec_, indrec_, attr_);    

   IF (Accounting_Code_Part_Value_API.Code_Part_Value_Exist(newrec_.company,newrec_.code_part,newrec_.account) = 'FALSE')THEN
      Error_SYS.Record_Not_Exist(lu_name_, 'SECMAPCODEPVALNOTEXIST: Code Part Value ":P1" does not exist in company ":P2"', newrec_.account, newrec_.company);
   END IF;
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Copy_Elements_To_Sec_Map__(
   company_ IN VARCHAR2)
IS
BEGIN

   -- Upsert all account code part mappings from cost_element_to_account_tab to cost_ele_to_accnt_secmap_tab
   MERGE INTO COST_ELE_TO_ACCNT_SECMAP_TAB secmap
   USING ( SELECT company, account, project_cost_element, code_part, valid_from, rowversion 
           FROM cost_element_to_account_tab
           WHERE code_part = 'A'
             AND company   = company_
             AND project_cost_element IS NOT NULL) ce
   ON (secmap.company      = ce.company AND
       secmap.account      = ce.account AND
       secmap.valid_from   = ce.valid_from)
   WHEN MATCHED THEN
      UPDATE SET secmap.project_cost_element = ce.project_cost_element,
                 secmap.rowversion           = SYSDATE 
   WHEN NOT MATCHED THEN
      INSERT (secmap.company,
              secmap.account,
              secmap.project_cost_element,
              secmap.code_part,
              secmap.valid_from,
              secmap.rowversion)
      VALUES (ce.company,
              ce.account,
              ce.project_cost_element,
              ce.code_part,
              ce.valid_from,
              SYSDATE);  

END Copy_Elements_To_Sec_Map__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Account_Element (
   company_ IN VARCHAR2,
   account_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ COST_ELE_TO_ACCNT_SECMAP_TAB.project_cost_element%TYPE;
   CURSOR get_attr IS
      SELECT project_cost_element
      FROM COST_ELE_TO_ACCNT_SECMAP_TAB
      WHERE company = company_
      AND   account = account_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Account_Element;




PROCEDURE Check_Project_Element_Used (
   company_          IN VARCHAR2,
   project_element_  IN VARCHAR2 )
IS
   dummy_   NUMBER;

   CURSOR exist_control IS
      SELECT 1
      FROM COST_ELE_TO_ACCNT_SECMAP_TAB
      WHERE company              = company_
        AND project_cost_element = project_element_;
BEGIN

   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      Error_SYS.Record_General(lu_name_, 'SECMAPPROJECTELEMENTUSED: It is not possible to delete Cost/Revenue Element :P1 as it has been used in the Secondary Cost/Revenue Element mapping.', project_element_);
   END IF;
   CLOSE exist_control;
END Check_Project_Element_Used;


FUNCTION Get_Secmap_Follow_Up_Element(
   company_           IN VARCHAR2,
   code_a_            IN VARCHAR2 DEFAULT NULL,
   valid_from_        IN DATE     DEFAULT NULL) RETURN VARCHAR2
IS
   temp_              COST_ELE_TO_ACCNT_SECMAP_TAB.project_cost_element%TYPE;
   base_code_part_    VARCHAR2(2);
   new_valid_from_    DATE;
   code_part_value_   VARCHAR2(20);

   code_null          EXCEPTION;
   cost_element_null  EXCEPTION;

   CURSOR get_secmap_attr IS
      SELECT project_cost_element
      FROM   COST_ELE_TO_ACCNT_SECMAP_TAB
      WHERE  company     = company_
      AND    account     = code_part_value_
      AND    code_part   = base_code_part_
      AND    valid_from <= new_valid_from_
      ORDER BY valid_from DESC;
BEGIN
   
   -- Always use account code part for secondary mapping
   base_code_part_  := 'A';
   code_part_value_ := code_a_;

   IF valid_from_ IS NULL THEN
      new_valid_from_ := sysdate;
   ELSE
      new_valid_from_ := valid_from_;
   END IF;      

   IF code_part_value_ IS NULL THEN
      RAISE code_null;
   END IF;

   OPEN get_secmap_attr;
   FETCH get_secmap_attr INTO temp_;
   CLOSE get_secmap_attr;

   IF (temp_ IS NOT NULL) THEN
      RETURN temp_;
   ELSE
      RAISE cost_element_null;
   END IF;
EXCEPTION
   WHEN code_null THEN
      Error_SYS.Record_General(lu_name_, 'SECMAPCODEISNULL: Code part :P1 is used for project cost/revenue element secondary mapping and must be entered.', Accounting_Code_Parts_API.Get_Description(company_, base_code_part_));
   WHEN cost_element_null THEN
      Error_SYS.Record_General(lu_name_, 'SECMAPCOSTELMISNULL: There is no project cost/revenue element connected to code part value :P1 in secondary mapping.', code_part_value_);
END Get_Secmap_Follow_Up_Element;



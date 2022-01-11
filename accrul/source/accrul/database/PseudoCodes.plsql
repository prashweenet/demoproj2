-----------------------------------------------------------------------------
--
--  Logical unit: PseudoCodes
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  980429  BREN    Created.
--  981217  BAMP    Add Public method "Validate_Account" to validate accounts
--  990729  HiMu    Modified withrespect to template changes
--  000914  HiMu    Added General_SYS.Init_Method
--  001005  prtilk  BUG # 15677  Checked General_SYS.Init_Method
--  021015  nikalk  Added new views PSEUDO_CODES_ECT and PSEUDO_CODES_PCT.
--  021015           Added procedures Make_Company, Copy___, Import___ and Export___.  
--  030905  Bmekse  DEFI160N Modified view PSEUDO_CODES
--  031217  Thsrlk  FIPR300A1: Add translation supprt functionality.
--  040618  Gepelk  IID FIPR307. Pseudo Code
--  040623  anpelk  FIPR338A2: Unicode Changes.
--  040906  AjPelk  Call 117440 , A default null parameter has been added into both Get_Complete_Pseudo
--  041020  AjPelk  Call B117825 , Modify Get_Complete_Pseudo
--  051024  ShSalk  Made pseudo_code_ownership as Not Null. 
--  051118  WAPELK  Merged the Bug 52783. Correct the user group variable's width.
--  060210  Gawilk  Modified method Get_Account.
--  060224  Jakalk  B135586 Set Pseudo Code Ownership as Public in Prepare_Insert.
--  060314  Gawilk  Used Get_Pseudo_Code_User to fetch client_user in Get_Complete_Pseudo
--  090605  THPELK  Bug 82609 - Added missing UNDEFINE statement for VIEW1
--  100224  Nalslk  RAVEN-39, Increased pseudo_code length to 20 characters
--  111108  PRatLK  Added project_activity_ID 
--  120403  PRatLK  Added project_activity_Id column to private_pseudo_codes view
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  130211  JuKoDE  EDEL-2033, Added Check_If_Ownership(), Get_Pseudo_Code_User_Ownership(
--  200623  SACNLK  GESPRING20-4642, Added accounting_xml_data functionality.
--  201112  SACNLK  GESPRING20-5995, Modified Check_Common___ to add accounting_xml_data functionality.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Convert_Attr_To_Newrec___ (
   newrec_ OUT PSEUDO_CODES%ROWTYPE,
   attr_   IN VARCHAR2 )
IS
   ptr_    NUMBER;
   name_   VARCHAR2(30);
   value_  VARCHAR2(2000);
BEGIN

   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         newrec_.company := value_;
      ELSIF (name_ = 'PSEUDO_CODE') THEN
         newrec_.pseudo_code := value_;
      ELSIF (name_ = 'DESCRIPTION') THEN
         newrec_.description := value_;
      ELSIF (name_ = 'USER_NAME') THEN
         newrec_.user_name := value_;
      ELSIF (name_ = 'ACCOUNT') THEN
         newrec_.account := value_;
      ELSIF (name_ = 'CODE_B') THEN
         newrec_.code_b := value_;
      ELSIF (name_ = 'CODE_C') THEN
         newrec_.code_c := value_;
      ELSIF (name_ = 'CODE_D') THEN
         newrec_.code_d := value_;
      ELSIF (name_ = 'CODE_E') THEN
         newrec_.code_e := value_;
      ELSIF (name_ = 'CODE_F') THEN
         newrec_.code_f := value_;
      ELSIF (name_ = 'CODE_G') THEN
         newrec_.code_g := value_;
      ELSIF (name_ = 'CODE_H') THEN
         newrec_.code_h := value_;
      ELSIF (name_ = 'CODE_I') THEN
         newrec_.code_i := value_;
      ELSIF (name_ = 'CODE_J') THEN
         newrec_.code_j := value_;
      ELSIF (name_ = 'TEXT') THEN
         newrec_.text := value_;
      ELSIF (name_ = 'PROCESS_CODE') THEN
         newrec_.process_code := value_;
      ELSIF (name_ = 'QUANTITY') THEN
         newrec_.quantity := Client_SYS.Attr_Value_To_Number(value_);
      ELSIF (name_ = 'PSEUDO_CODE_OWNERSHIP') THEN
              newrec_.pseudo_code_ownership := value_;
      ELSIF (name_ = 'PROJECT_ACTIVITY_ID') THEN
         newrec_.project_activity_id := Client_SYS.Attr_Value_To_Number(value_);
      END IF;
   END LOOP;
END Convert_Attr_To_Newrec___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   company_             pseudo_codes_tab.company%TYPE;
BEGIN
   company_ := Client_SYS.Get_Item_Value('COMPANY', attr_);
   super(attr_);
   Client_SYS.Add_To_Attr('USER_NAME', Fnd_Session_API.Get_Fnd_User, attr_);
   Client_SYS.Add_To_Attr('PSEUDO_CODE_OWNERSHIP', Fin_Ownership_API.Decode('PUBLIC'), attr_);
   -- gelr:accounting_xml_data, begin   
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(company_, 'ACCOUNTING_XML_DATA') = Fnd_Boolean_API.DB_TRUE) THEN
      Client_SYS.Add_To_Attr('SAT_ACCOUNT_TYPE', Sat_Account_Type_API.Decode('DEBIT'), attr_);
      Client_SYS.Add_To_Attr('SAT_LEVEL', Sat_Level_API.Decode('2') , attr_); 
   END IF;
   -- gelr:accounting_xml_data, end
   
END Prepare_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     pseudo_codes_tab%ROWTYPE,
   newrec_ IN OUT pseudo_codes_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Validate_Code_Part_Demands___(newrec_, attr_);   
   Validate_Activity_Seq___(newrec_);
   -- gelr:accounting_xml_data, begin
   IF (indrec_.sat_level OR indrec_.sat_parent_account) THEN
      IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'ACCOUNTING_XML_DATA') = Fnd_Boolean_API.DB_TRUE) THEN
         Account_API.Validate_Sat_Parent_Account(newrec_.sat_level, newrec_.sat_parent_account);
      END IF;
   END IF;
   -- gelr:accounting_xml_data, end
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT pseudo_codes_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_           VARCHAR2(30);
   value_          VARCHAR2(4000);
   fnd_user_       VARCHAR2(20);
   group_          VARCHAR2(20);
   codestring_rec_ Accounting_codestr_API.CodestrRec;
BEGIN
   attr_ := Client_SYS.Remove_Attr('CODE_PART',attr_);
   attr_ := Client_SYS.Remove_Attr('CODE_DEMAND',attr_); 
   super(newrec_, indrec_, attr_);
   
   IF (newrec_.company IS NOT NULL AND indrec_.company = FALSE) THEN
      Company_Finance_API.Exist(newrec_.company);
   END IF;
   
   IF (newrec_.code_b IS NOT NULL AND indrec_.code_b = FALSE) THEN
      Code_B_API.Exist(newrec_.company, newrec_.code_b);
   END IF;
   IF (newrec_.code_c IS NOT NULL AND indrec_.code_c = FALSE) THEN
      Code_C_API.Exist(newrec_.company, newrec_.code_c);
   END IF;
   IF (newrec_.code_d IS NOT NULL AND indrec_.code_d = FALSE) THEN
      Code_D_API.Exist(newrec_.company, newrec_.code_d);
   END IF;
   IF (newrec_.code_e IS NOT NULL AND indrec_.code_e = FALSE) THEN
      Code_E_API.Exist(newrec_.company, newrec_.code_e);
   END IF;
   IF (newrec_.code_f IS NOT NULL AND indrec_.code_f = FALSE) THEN
      Code_F_API.Exist(newrec_.company, newrec_.code_f);
   END IF;
   IF (newrec_.code_g IS NOT NULL AND indrec_.code_g = FALSE) THEN
      Code_G_API.Exist(newrec_.company, newrec_.code_g);
   END IF;
   IF (newrec_.code_h IS NOT NULL AND indrec_.code_h = FALSE) THEN
      Code_H_API.Exist(newrec_.company, newrec_.code_h);
   END IF;
   IF (newrec_.code_i IS NOT NULL AND indrec_.code_i = FALSE) THEN
      Code_I_API.Exist(newrec_.company, newrec_.code_i);
   END IF;
   IF (newrec_.code_j IS NOT NULL AND indrec_.code_j = FALSE) THEN
      Code_J_API.Exist(newrec_.company, newrec_.code_j);
   END IF;
   IF (newrec_.process_code IS NOT NULL AND indrec_.process_code = FALSE) THEN
      Account_Process_Code_API.Exist(newrec_.company, newrec_.process_code);
   END IF;
   IF (newrec_.account IS NOT NULL AND indrec_.account = FALSE) THEN
      Account_API.Exist(newrec_.company, newrec_.account);
   END IF;
   
   IF (newrec_.pseudo_code_ownership IS NOT NULL AND indrec_.pseudo_code_ownership = FALSE) THEN
      Fin_Ownership_API.Exist_Db(newrec_.pseudo_code_ownership);
   END IF;
   
   Pseudo_Codes_API.Pseudo_Code_Exist_(newrec_.company, newrec_.pseudo_code, newrec_.user_name);
   Pseudo_Codes_API.Check_If_Account_(newrec_.company, newrec_.pseudo_code);

--Codepart Validation...........................................
   codestring_rec_.code_a := newrec_.account;
   codestring_rec_.code_b := newrec_.code_b;
   codestring_rec_.code_c := newrec_.code_c;
   codestring_rec_.code_d := newrec_.code_d;
   codestring_rec_.code_e := newrec_.code_e;
   codestring_rec_.code_f := newrec_.code_f;
   codestring_rec_.code_g := newrec_.code_g;
   codestring_rec_.code_h := newrec_.code_h;
   codestring_rec_.code_i := newrec_.code_i;
   codestring_rec_.code_j := newrec_.code_j;
   codestring_rec_.process_code := newrec_.process_code;
   codestring_rec_.text := newrec_.text;

-- According to the specification Mandatory/Blocked/Can is not checked for Quantity. But if Quantity
-- is Mandatory then it does not allow to save as Validate_Codestring Checks for Quantity as well.
-- Therefore 1 is added to Quantity if Quantity is Mandatory...

   IF Accounting_Code_Part_A_API.Get_Quantity_Demand(newrec_.company, 'A',newrec_.account) = 'M' THEN
        codestring_rec_.quantity := 1;
   END IF;

   fnd_user_ := Fnd_Session_API.Get_Fnd_User;
   group_    := User_Group_Member_Finance_API.Get_Default_Group(newrec_.company,fnd_user_);
   Accounting_Codestr_API.Validate_Codestring(codestring_rec_, newrec_.company, TRUNC(SYSDATE),group_);
   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     pseudo_codes_tab%ROWTYPE,
   newrec_ IN OUT pseudo_codes_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_              VARCHAR2(30);
   value_             VARCHAR2(4000);
   fnd_user_          VARCHAR2(20);
   group_             user_group_member_finance_tab.user_group%type;
   code_part_         VARCHAR2(20);
   code_demand_       VARCHAR2(2000);
   codestring_rec_    Accounting_codestr_API.CodestrRec;  
BEGIN
   code_part_   := Client_SYS.Cut_Item_Value('CODE_PART',attr_);
   code_demand_ := Client_SYS.Cut_Item_Value('CODE_DEMAND',attr_);   
   IF ((indrec_.pseudo_code_ownership) AND (Fnd_Session_API.Get_Fnd_User != newrec_.user_name)) THEN
      Error_SYS.Record_General(lu_name_, 'PSEUDOCODEOTHERUSER: You are not allowed to change ownership of the pseudo code :P1.', newrec_.pseudo_code);          
   END IF;   
   IF Client_SYS.Item_Exist(attr_,'PSEUDO_CODE_VALUE') THEN
      Error_SYS.Item_Update(lu_name_, 'PSEUDO_CODE_VALUE');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);   
   IF (newrec_.process_code IS NOT NULL) THEN
      Account_Process_Code_API.Exist(newrec_.company, newrec_.process_code);
   END IF;
    
--Codepart Validation...........................................
   codestring_rec_.code_a := newrec_.account;
   codestring_rec_.code_b := newrec_.code_b;
   codestring_rec_.code_c := newrec_.code_c;
   codestring_rec_.code_d := newrec_.code_d;
   codestring_rec_.code_e := newrec_.code_e;
   codestring_rec_.code_f := newrec_.code_f;
   codestring_rec_.code_g := newrec_.code_g;
   codestring_rec_.code_h := newrec_.code_h;
   codestring_rec_.code_i := newrec_.code_i;
   codestring_rec_.code_j := newrec_.code_j;
   codestring_rec_.process_code := newrec_.process_code;
   codestring_rec_.text := newrec_.text;

-- According to the specification Mandatory/Blocked/Can is not checked for Quantity. But if Quantity
-- is Mandatory then it does not allow to save as Validate_Codestring Checks for Quantity as well.
-- Therefore 1 is added to Quantity if Quantity is Mandatory...

   IF Accounting_Code_Part_A_API.Get_Quantity_Demand(newrec_.company, 'A',newrec_.account) = 'M' THEN
        codestring_rec_.quantity := 1;
   END IF;

   fnd_user_ := Fnd_Session_API.Get_Fnd_User;
   group_    := User_Group_Member_Finance_API.Get_Default_Group(newrec_.company,fnd_user_);
   Accounting_Codestr_API.Validate_Codestring(codestring_rec_, newrec_.company, TRUNC(SYSDATE),group_);
   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Validate_Activity_Seq___ (
   newrec_ IN OUT pseudo_codes_tab%ROWTYPE ) 
IS
   project_id_             VARCHAR2(20); 
   project_origin_         VARCHAR2(30);
   project_code_part_      VARCHAR2(2);
   $IF Component_Proj_SYS.INSTALLED $THEN
   activity_rec_           Activity_API.Public_Rec;
   $END
BEGIN  
   project_code_part_ := Accounting_Code_parts_api.Get_Codepart_Function (newrec_.company, 'PRACC');
   
   IF project_code_part_ IS NOT NULL THEN 
      IF (project_code_part_ = 'B') THEN
         project_id_ := newrec_.code_b;
      ELSIF (project_code_part_ = 'C') THEN
         project_id_ := newrec_.code_c;
      ELSIF (project_code_part_ = 'D') THEN
         project_id_ := newrec_.code_d;
      ELSIF (project_code_part_ = 'E') THEN
         project_id_ := newrec_.code_e;
      ELSIF (project_code_part_ = 'F') THEN
         project_id_ := newrec_.code_f;
      ELSIF (project_code_part_ = 'G') THEN
         project_id_ := newrec_.code_g;
      ELSIF (project_code_part_ = 'H') THEN
         project_id_ := newrec_.code_h;
      ELSIF (project_code_part_ = 'I') THEN
         project_id_ := newrec_.code_i;
      ELSIF (project_code_part_ = 'J') THEN
         project_id_ := newrec_.code_j;
      END IF;   
      
      IF (Account_API.Exist(newrec_.company, newrec_.account)) THEN
         $IF Component_Genled_SYS.INSTALLED $THEN
            project_origin_:=  ACCOUNTING_PROJECT_API.Get_Project_Origin_Db( newrec_.company , project_id_);
         $ELSE
            project_origin_:= NULL;
         $END  
         
         IF ((project_origin_ NOT IN ('PROJECT', 'JOB')) OR (project_origin_ IS NULL)) THEN
            IF (newrec_.project_activity_id IS NOT NULL) THEN
               Error_SYS.Record_General(lu_name_, 'NOPROJECTACT: Activity Sequence No can be entered only for projects with project origin ''Project''.');
            END IF;
         END IF;
                  
         IF (project_origin_ = 'PROJECT') THEN 
            IF (newrec_.project_activity_id IS NOT NULL) THEN
                     
               IF  (newrec_.project_activity_id > 0) AND NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'TRUE' THEN
                  Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', newrec_.account);
               END IF; 
               
               $IF Component_Proj_SYS.INSTALLED $THEN      
                  Activity_API.Exist(newrec_.project_activity_id);
                  activity_rec_     := Activity_API.Get(newrec_.project_activity_id);
                  
                  IF(activity_rec_.project_id <> project_id_ OR activity_rec_.project_id IS NULL ) THEN
                     Error_SYS.Record_General(lu_name_, 'ACTIVITYIDNOTVALID: Invalid Activity Sequence No for Project :P1', project_id_ );
                  END IF;                  

                  IF(activity_rec_.rowstate IN ('Planned', 'Closed', 'Cancelled')) THEN
                     Error_SYS.Record_General(lu_name_,'ACTIDNOTPOSTABLE: In Project :P1 , Activity Sequence No :P2  is in status planned, closed or cancelled. This operation is not allowed on Planned, Closed or Cancelled activities.',project_id_,newrec_.project_activity_id);
                  END IF;

               $ELSE
                  NULL;
               $END                   
            ELSIF (NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'FALSE') THEN
               Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Activity Sequence No must have a value for Project :P1', project_id_ );
            END IF;                   
            
         ELSIF (project_origin_ = 'JOB') THEN
            newrec_.project_activity_id := 0;
         END IF;                 
      END IF;                  
   ELSIF (newrec_.project_activity_id IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_, 'NOPROJECTACT: Activity Sequence No can be entered only for projects with project origin ''Project''.');      
   END IF;       
END Validate_Activity_Seq___ ;

PROCEDURE Validate_Code_Part_Demands___(
   newrec_ IN pseudo_codes_tab%ROWTYPE,
   attr_   IN VARCHAR2)
IS
   required_string_         VARCHAR2(30);
   demand_string_           VARCHAR2(20);
   mandatory_position_      NUMBER;
   start_postion_           NUMBER := 1;
   code_part_value_         VARCHAR2(20) := NULL;
   code_part_name_          VARCHAR2(20);
   mandatory_code_part_null EXCEPTION;
BEGIN   
   required_string_ := Client_SYS.Get_Item_Value('REQUIRED_STRING', attr_);
   demand_string_   := SUBSTR(required_string_, 1, 20);
   WHILE (start_postion_ < 20) LOOP
      mandatory_position_ := INSTR(demand_string_, 'M', start_postion_);
      CASE 
         WHEN mandatory_position_ = 1 THEN
            code_part_value_ := newrec_.code_b;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'B');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 3 THEN
            code_part_value_ := newrec_.code_c;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'C');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 5 THEN
            code_part_value_ := newrec_.code_d;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'D');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 7 THEN
            code_part_value_ := newrec_.code_e;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'E');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 9 THEN
            code_part_value_ := newrec_.code_f;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'F');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 11 THEN
            code_part_value_ := newrec_.code_g;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'G');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 13 THEN
            code_part_value_ := newrec_.code_h;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'H');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 15 THEN
            code_part_value_ := newrec_.code_i;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'I');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 17 THEN
            code_part_value_ := newrec_.code_j;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ :=  Accounting_Code_Parts_API.Get_Name(newrec_.company, 'J');
               RAISE mandatory_code_part_null;
            END IF;
         WHEN mandatory_position_ = 19 THEN
            code_part_value_ := newrec_.process_code;
            IF (code_part_value_ IS NULL) THEN
               code_part_name_ := 'Process Code';
               RAISE mandatory_code_part_null;
            END IF;
         ELSE
           EXIT;
      END CASE;
      start_postion_ := mandatory_position_ + 1;
   END LOOP;   
EXCEPTION
   WHEN mandatory_code_part_null THEN
      Error_SYS.Record_General(lu_name_, 'MANCODEPARTNULL: The field [:P1] must have a value.', code_part_name_);
END Validate_Code_Part_Demands___;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Check_If_Account_ (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR Check_Pseudo_ IS
      SELECT 1
      FROM   ACCOUNTING_CODE_PART_VALUE_TAB
      WHERE  Company         = company_
      AND    Code_Part_Value = pseudo_code_
      AND    Code_Part       = 'A' ;
BEGIN

   OPEN Check_Pseudo_;
   FETCH Check_Pseudo_  INTO dummy_;
   IF (Check_Pseudo_%FOUND) THEN
      ERROR_SYS.Record_General(lu_name_, 'PSEUDOEXIST: Pseudo code exists as an account');
      CLOSE Check_Pseudo_;
   END IF;
   CLOSE Check_Pseudo_;
END Check_If_Account_;


PROCEDURE Pseudo_Code_Exist_ (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2,
   user_name_   IN VARCHAR2 )
IS
   dummy_ NUMBER;
   CURSOR Check_Pseudo_ IS
      SELECT 1
      FROM   PSEUDO_CODES_TAB
      WHERE  Company     = company_
      AND    Pseudo_Code = pseudo_code_
      AND    User_Name   = user_name_ ;
BEGIN

   OPEN Check_Pseudo_;
   FETCH Check_Pseudo_ INTO dummy_;
   IF Check_Pseudo_%FOUND THEN
      ERROR_SYS.Record_General(lu_name_, 'PSEUDOCODEEXIST: Pseudo code already exists');
      CLOSE Check_Pseudo_;
   END IF;
   CLOSE Check_Pseudo_;
END Pseudo_Code_Exist_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Get_Pseudo_Code_User (
   company_        IN     VARCHAR2,
   pseudo_code_    IN     VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_user_name IS
      SELECT user_name, pseudo_code_ownership
      FROM   PSEUDO_CODES_TAB
      WHERE  company     = company_
      AND    pseudo_code = pseudo_code_;

   fnd_user_   VARCHAR2(30);
   app_user_   VARCHAR2(30);
   pub_user_   VARCHAR2(30);

BEGIN
   FOR rec_ IN get_user_name LOOP
      IF (rec_.user_name = Fnd_Session_API.Get_Fnd_User) THEN
         fnd_user_ := rec_.user_name;
      ELSIF (rec_.user_name = Fnd_Session_API.Get_App_Owner AND rec_.pseudo_code_ownership = 'PUBLIC') THEN
         app_user_ := rec_.user_name;
      ELSIF (rec_.pseudo_code_ownership = 'PUBLIC') THEN
         pub_user_ := rec_.user_name;
      END IF;
   END LOOP;

   IF fnd_user_ IS NOT NULL THEN
      RETURN fnd_user_;
   ELSIF app_user_ IS NOT NULL THEN
      RETURN app_user_;
   ELSIF pub_user_ IS NOT NULL THEN
      RETURN pub_user_;
   ELSE
      RETURN NULL;
   END IF;
END Get_Pseudo_Code_User;


PROCEDURE Get_Complete_Pseudo (
   codestring_rec_ IN OUT VARCHAR2,
   company_        IN     VARCHAR2,
   pseudo_code_    IN     VARCHAR2,
   client_user_    IN     VARCHAR2 DEFAULT NULL )
IS
   newrec_        PSEUDO_CODES_TAB%ROWTYPE;
   account_desc_  VARCHAR2(100);
   code_b_desc_   VARCHAR2(100);
   code_c_desc_   VARCHAR2(100);
   code_d_desc_   VARCHAR2(100);
   code_e_desc_   VARCHAR2(100);
   code_f_desc_   VARCHAR2(100);
   code_g_desc_   VARCHAR2(100);
   code_h_desc_   VARCHAR2(100);
   code_i_desc_   VARCHAR2(100);
   code_j_desc_   VARCHAR2(100);
BEGIN
   IF (client_user_ IS NULL) THEN
      newrec_ := Get_Object_By_Keys___(company_, pseudo_code_, Get_Pseudo_Code_User(company_, pseudo_code_));
   ELSE
      newrec_ := Get_Object_By_Keys___(company_, pseudo_code_, client_user_);
   END IF;
   account_desc_ := newrec_.account;
   code_b_desc_  := newrec_.code_b;
   code_c_desc_  := newrec_.code_c;
   code_d_desc_  := newrec_.code_d;
   code_e_desc_  := newrec_.code_e;
   code_f_desc_  := newrec_.code_f;
   code_g_desc_  := newrec_.code_g;
   code_h_desc_  := newrec_.code_h;
   code_i_desc_  := newrec_.code_i;
   code_j_desc_  := newrec_.code_j;
   accounting_codestr_api.Complete_Codestring_Desc(account_desc_,
                                                   code_b_desc_,
                                                   code_c_desc_,
                                                   code_d_desc_,
                                                   code_e_desc_,
                                                   code_f_desc_,
                                                   code_g_desc_,
                                                   code_h_desc_,
                                                   code_i_desc_,
                                                   code_j_desc_,
                                                   company_);
   Client_SYS.Clear_Attr(codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT', newrec_.account, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B', newrec_.code_b, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C', newrec_.code_c, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D', newrec_.code_d, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E', newrec_.code_e, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F', newrec_.code_f, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G', newrec_.code_g, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H', newrec_.code_h, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I', newrec_.code_i, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J', newrec_.code_j, codestring_rec_);
   Client_SYS.Add_To_Attr('PROCESS_CODE', newrec_.process_code, codestring_rec_);
   Client_SYS.Add_To_Attr('TEXT', newrec_.text, codestring_rec_);
   Client_SYS.Add_To_Attr('QUANTITY', newrec_.quantity, codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT_DESC', account_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B_DESC', code_b_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C_DESC', code_c_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D_DESC', code_d_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E_DESC', code_e_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F_DESC', code_f_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G_DESC', code_g_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H_DESC', code_h_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I_DESC', code_i_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J_DESC', code_j_desc_, codestring_rec_);
   Client_SYS.Add_To_Attr('PROJECT_ACTIVITY_ID', newrec_.project_activity_id, codestring_rec_);
END Get_Complete_Pseudo;


PROCEDURE Get_Complete_Pseudo (
   codestring_rec_ IN OUT Accounting_Codestr_API.CodestrRec,
   company_        IN     VARCHAR2,
   pseudo_code_    IN     VARCHAR2,
   client_user_    IN     VARCHAR2 DEFAULT NULL)
IS
   newrec_      PSEUDO_CODES_TAB%ROWTYPE;
BEGIN
   IF (client_user_ IS NULL) THEN
      newrec_ := Get_Object_By_Keys___(company_, pseudo_code_, Get_Pseudo_Code_User(company_, pseudo_code_));
   ELSE
      newrec_ := Get_Object_By_Keys___(company_, pseudo_code_, client_user_);
   END IF;
   codestring_rec_.code_a  := newrec_.account;
   codestring_rec_.code_b  := newrec_.code_b;
   codestring_rec_.code_c  := newrec_.code_c;
   codestring_rec_.code_d  := newrec_.code_d;
   codestring_rec_.code_e  := newrec_.code_e;
   codestring_rec_.code_f  := newrec_.code_f;
   codestring_rec_.code_g  := newrec_.code_g;
   codestring_rec_.code_h  := newrec_.code_h;
   codestring_rec_.code_i  := newrec_.code_i;
   codestring_rec_.code_j  := newrec_.code_j;
END Get_Complete_Pseudo;


@UncheckedAccess
FUNCTION Exist_Pseudo (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   PSEUDO_CODES_TAB
      WHERE  company     = company_
      AND    pseudo_code = pseudo_code_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Exist_Pseudo;


PROCEDURE Get_Complete_Codestr (
   codestring_ IN OUT VARCHAR2,
   attr_       IN     VARCHAR2 )
IS
   codestr_rec_  Accounting_Codestr_API.CodestrRec;
   override_rec_ Accounting_Codestr_API.CodestrRec;
   company_      VARCHAR2(20);
   code_part_    VARCHAR2(20);
   newrec_       PSEUDO_CODES%ROWTYPE;
BEGIN

   Convert_Attr_To_Newrec___(newrec_, attr_);

   company_             := newrec_.company;

   codestr_rec_.code_a  := newrec_.account;
   codestr_rec_.code_b  := newrec_.code_b;
   codestr_rec_.code_c  := newrec_.code_c;
   codestr_rec_.code_d  := newrec_.code_d;
   codestr_rec_.code_e  := newrec_.code_e;
   codestr_rec_.code_f  := newrec_.code_f;
   codestr_rec_.code_g  := newrec_.code_g;
   codestr_rec_.code_h  := newrec_.code_h;
   codestr_rec_.code_i  := newrec_.code_i;
   codestr_rec_.code_j  := newrec_.code_j;

   code_part_ := 'A';

   Accounting_Codestr_Compl_API.Get_Codestring_Completetion (
      codestr_rec_,
      code_part_,
      company_,
      override_rec_ );


   -- building the attribute string
   Client_SYS.Clear_Attr(codestring_);
   Client_SYS.Add_To_Attr('ACCOUNT', codestr_rec_.code_a, codestring_);
   Client_SYS.Add_To_Attr('CODE_B', codestr_rec_.code_b, codestring_);
   Client_SYS.Add_To_Attr('CODE_C', codestr_rec_.code_c, codestring_);
   Client_SYS.Add_To_Attr('CODE_D', codestr_rec_.code_d, codestring_);
   Client_SYS.Add_To_Attr('CODE_E', codestr_rec_.code_e, codestring_);
   Client_SYS.Add_To_Attr('CODE_F', codestr_rec_.code_f, codestring_);
   Client_SYS.Add_To_Attr('CODE_G', codestr_rec_.code_g, codestring_);
   Client_SYS.Add_To_Attr('CODE_H', codestr_rec_.code_h, codestring_);
   Client_SYS.Add_To_Attr('CODE_I', codestr_rec_.code_i, codestring_);
   Client_SYS.Add_To_Attr('CODE_J', codestr_rec_.code_j, codestring_);
END Get_Complete_Codestr;


@UncheckedAccess
FUNCTION Exist_Pseudo_Code (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
  temp_ BOOLEAN;
BEGIN
   temp_ := Exist_Pseudo(company_, pseudo_code_);
   IF (temp_) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Exist_Pseudo_Code;

PROCEDURE Validate_Account (
   demand_string_ OUT VARCHAR2,
   company_       IN  VARCHAR2,
   account_       IN  VARCHAR2 )
IS
BEGIN

   IF (Account_API.Is_Budget_account(company_, account_)) THEN
      Error_SYS.Record_General(lu_name_, 'BUDACCONLY: Account :P1 is only allowed for budget', account_);
   ELSE
      Accounting_Code_Part_A_API.Validate_Account(demand_string_, company_, account_);
   END IF;
END Validate_Account;

PROCEDURE Get_Demand_String_Pseudo (
   demand_string_ OUT VARCHAR2,
   account_value_ OUT VARCHAR2,
   company_       IN  VARCHAR2,
   account_       IN  VARCHAR2,
   client_user_   IN  VARCHAR2 DEFAULT NULL )
IS
   accnt_      VARCHAR2(20);
BEGIN
   accnt_ := account_ ;
   IF Exist_Pseudo(company_, account_) = TRUE THEN
      accnt_ := Get_Account(company_, account_ , client_user_ );
   END IF;
   demand_string_ := Account_Api.Get_Demand_String(company_, accnt_);
   account_value_ := accnt_ ;
END Get_Demand_String_Pseudo;


PROCEDURE Check_If_Ownership (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2,
   user_name_   IN VARCHAR2 )
IS
   exist_user_ VARCHAR2(20);
   CURSOR exist_user IS
      SELECT user_name
      FROM   PSEUDO_CODES_TAB
      WHERE  company     = company_
      AND    pseudo_code = pseudo_code_
      AND    user_name   != user_name_
      AND    pseudo_code_ownership = 'PRIVATE';
BEGIN
   OPEN  exist_user;
   FETCH exist_user INTO exist_user_;
   IF (exist_user%FOUND) THEN
      CLOSE exist_user;
      Error_SYS.Record_General(lu_name_, 'PSEUDOCODEOWNERSHIP: The private pseudo code can only be entered by user :P1.', exist_user_);
   ELSE
      CLOSE exist_user;
   END IF;
END Check_If_Ownership;


@UncheckedAccess
FUNCTION Get_Pseudo_Code_User_Ownership (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_name_  VARCHAR2(20);
   CURSOR get_user_name IS
      SELECT user_name
      FROM PSEUDO_CODES_TAB
      WHERE company     = company_
      AND   pseudo_code = pseudo_code_;
BEGIN
   OPEN  get_user_name;
   FETCH get_user_name INTO user_name_;
   CLOSE get_user_name;
   RETURN user_name_;
END Get_Pseudo_Code_User_Ownership;

@UncheckedAccess
FUNCTION Get_Account (
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   account_   VARCHAR2(20);
   CURSOR get_account_ IS
      SELECT Account
      FROM   PSEUDO_CODES_TAB
      WHERE  company     = company_
      AND    pseudo_Code = pseudo_code_;
BEGIN
   OPEN get_account_;
   FETCH get_account_ INTO account_;
   CLOSE get_account_;
   RETURN account_;
END Get_Account;

PROCEDURE New (
   newrec_ IN OUT NOCOPY pseudo_codes_tab%ROWTYPE )
IS
   attr_             VARCHAR2(32000);
   objid_            VARCHAR2(4000);
   objversion_       VARCHAR2(4000);
   indrec_           Indicator_Rec;
BEGIN
   indrec_ := Get_Indicator_Rec___(newrec_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

FUNCTION Get_Project_Id(
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2,
   user_name_   IN VARCHAR2) RETURN VARCHAR2
IS
   proj_code_part_  VARCHAR2(1);
   column_name_     VARCHAR2(10);
   stmt_            VARCHAR2(2000);
   project_id_      VARCHAR2(20) := NULL;
   TYPE GetProjectId  IS REF CURSOR;
   get_project_id_  GetProjectId;      
BEGIN
   proj_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_, 'PRACC');
   IF (proj_code_part_ IS NOT NULL) THEN
      column_name_ := 'CODE_' || proj_code_part_;
      stmt_ := 'SELECT ' || column_name_  ||' FROM pseudo_codes ' ||
               'WHERE company = :company_ ' ||
               'AND pseudo_code = :pseudo_code_ ' ||
               'AND user_name = :user_name_';
      @ApproveDynamicStatement(2019-01-30, kumglk)
      OPEN get_project_id_ FOR stmt_ USING company_, pseudo_code_, user_name_;
      FETCH get_project_id_ INTO project_id_;
      CLOSE get_project_id_;
   END IF;
   RETURN project_id_;   
END Get_Project_Id;

FUNCTION Is_Proj_Activity_Id_Enable(
   company_     IN VARCHAR2,
   pseudo_code_ IN VARCHAR2 DEFAULT NULL,
   user_name_   IN VARCHAR2 DEFAULT NULL,
   proj_id_     IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
   is_enable_      VARCHAR2(5);
   project_id_     VARCHAR2(20);
   project_origin_ VARCHAR2(30);
BEGIN   
   IF (proj_id_ IS NULL) THEN
      project_id_ := Get_Project_Id(company_, pseudo_code_, user_name_);
   ELSE 
      project_id_ := proj_id_;
   END IF;
   IF (project_id_ IS NULL) THEN
      RETURN 'FALSE';
   END IF;
   $IF (Component_Genled_SYS.INSTALLED) $THEN
      project_origin_:= Accounting_Project_API.Get_Project_Origin_Db(company_, project_id_);
      IF (project_origin_ = 'JOB') THEN
         is_enable_ := 'FALSE';
      ELSIF (project_origin_ = 'FINPROJECT') THEN
         is_enable_ := 'FALSE';
      ELSE 
         is_enable_ := 'TRUE';
      END IF;
   $ELSE
      is_enable_ := 'TRUE';
   $END
   RETURN is_enable_;   
END Is_Proj_Activity_Id_Enable;
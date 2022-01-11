-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodestr
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  951107  ToRe   Created.
--  951208  ToRe   Changed Record_general to Application_General.
--  960306  ToRe   Added Codestring_Completion and added parameter codepart_
--                  to procedure Complete_Codestring.
--  960412  MiJo   Modifyed for new Accounting Rules
--  960607  ToRe   Procedure Get_Override_Rec in Codestring_Completion
--                  is only called if posting_type is not NULL.
--  970606  JoTh   Bug # 97-0022 fixed in Validate_Codestring.
--  970813  MiJo   Bug # 97-0045. Changed the fixed for bug 97-0022.
--  990317  Bren   Bug #: 5779. Added protected procedure validate_codestring_ to handle overloaded procedure.
--  991229  SaCh   Removed public procedure Validate_Codestring which had the argument
--                 Ac_Am_Br_API.CodestrRec.
--  991229  SaCh   Removed public procedure Complete_Codestring which had the argument
--                 Ac_Am_Br_API.CodestrRec.
--  000105  SaCh   Added public methods Validate_Codestring and Complete_Codestring.
--  000912  HiMu   Added General_SYS.Init_Method
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010409  JeGu   Bug #21018 Modified Validate_Codeparts
--  011120  LiSv   Bug #26322 Corrected. Recorrection of bug #21018.
--  020812  RoRa   Bug #20070 fixed.Change of length from 20 to 200.
--  030731  prdilk SP4 Merge.
--  030813  risrlk GEFI204N. changed Object_Acq_Rec_ type to fixass_connection_v890
--                  in Validate_Codestring_Mpccom method.
--  030827  Gawilk LCS:36986 Merged. Added Validation for project in Validate_Codestring_Mpccom.
--  030913  Chprlk Modified the method Check_Project_Mpccom___
--  030930  Risrlk Merged LCS Bug 39333. Modified Validate_Codestring_Mpccom
--  031017  LoKrLK Patch Merge (39432). Added Validate_Internal_Codestring
--  031020  Brwelk Init_Method Corrections
--  041206  ShSaLk Remove of Sync730.api/apy.
--  050805  Umdolk LCS Merge (52175).
--  051118  WAPELK Merged the Bug 52783. Correct the user group variable's width. 
--  051202  GADALK Changed: Validate_Codestring() Validate_Codeparts() Validate_Budget_Codestring()
--                 added boolean parameters to enable customized validations.
--  060106  VOHELK Changed: Validate_Codestring_() add text to attr list
--  060802  Kagalk LCS Merge - Bug 57046, Skipped some validation for function group 'P'.
--  060920  Vohelk FIPL616A, Added condition to filter out Planning objects
--  061002  Samwlk LCS Merge, Add a new method Check_Project_Acq_Acc___ .
--  071221  DIFELK Bug 70050, corrected. Removed code introduced by bug 58036.
--  080728  VADELK Bug 73028 Corrected. In Check_Project_Mpccom___() the validation is done whether the account
--  080728         is connected to a cost element.
--  080929  MAKRLK Bug 76726, corrected. Modified method Validate_Budget_Codestring()
--  081124  MAWELK Bug Id 78456 Corrected.
--  090125  MAKRLK Bug 76650, Added new method Validate_Budget_Codestr_Dates().
--  090224  Ersruk Added validation for exclude_proj_followup in Check_Project_Mpccom___.
--  090521  MAKRLK Modified the method Check_Project_Mpccom___. 
--  090717  ErFelk Bug 83174, Replaced constant INVCDPRT with CODEMISSING in Validate_Internal_Codestring and changed the message
--  090717         constant in all similar messages in Validate_Codeparts, Validate_Budget_Codestring, Validate_Budget_Codestr_Dates
--  100120  MAKRLK TWIN PEAKS Merge.
--  100206  RUFELK RAVEN-309 - Modified Complete_Codestring() and Complete_Codestring___().
--  110131  AsHelk RAVEN-1565, Added Method Get_Prj_And_Obj_Code_P_Values
--  110325  DIFELK RAVEN-1918 modified Complete_Codestring___ by adding the voucher date when fetching override.
--  110105  THPELK Bug 94830, Corrected in Validate_Codestring() and Validate_Codeparts() methods.
--  110528  THPELK EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110808  JuKoDE EDEL-69, Modified accounts_req EXCEPTION in Validate_Budget_Codestring to add required budget codepart demand info.
--  111017  SWRALK SFI-128, Added conditional compilation for the places that had called package FIXASS_CONNECTION_V871_API and FIXASS_CONNECTION_V890_API.
--  111018  Shdilk   SFI-135, Conditional compilation.
--  111020  OVJOSE Added Get_Rec_Value_For_Code_Part, Get_Value_For_Code_Part, Convert_To_Code_Str_Rec, Convert_Rec_To_Code_Part_Vals,
--                 Set_Code_Part_Val_In_Rec and Get_Code_Part_Val_Tab
--  111230  Ashelk SBI-305 Added Method Get_Code_P_Values_By_Function.
--  120730  Maaylk Bug 101320, Added implementation method Validate_Codeparts___() to reduce calls to General_SYS
--  120816  Umdolk EDEL-1178, Removed the validation in Validate_Codestring_Mpccom method to allow acquisitions when the object is active.
--  120829  JuKoDE EDEL-1532, Added General_SYS.Init_Method in Convert_Rec_To_Code_Part_Vals(), Get_Prj_And_Obj_Code_P_Values(), Set_Code_Part_Val_In_Rec()
--  120921  Clstlk Bug 105357, Added parameter to Validate_Budget_Codestr_Dates().
--  120926  chanlk Bug 105181, Modified Validate_Codestring_Mpccom.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121204  Maaylk PEPA-183, Removed global variables
--  121126  Machlk Bug 106991, Modified the error message.
--  121126  Mohrlk CUJO-238, Added parameter validate_account_ to methods Validate_Codestring() and Validate_Codeparts___().
--  130402  Kagalk Bug 105207, Modified error message
--  140228  Shedlk PBFI-5562, Merged LCS bug 115107
--  140721  Mawelk PRFI-995,  Merged LCS bug 112616
--  150611  Chwilk Bug 122655, Modified Validate_Codestring_Mpccom.
--  160216  Savmlk STRFI-1186, Merged LCS Bug 127280, Fixed.
--  161017  Chwtlk STRFI-3528, Merged LCS Bug 131415, Modified Complete_Codestring___.
--  170724  Savmlk STRFI-6769, Merged lcs Bug 136233, Fixed.
--  190802  Nudilk Bug 149273, Provided overloaded methods to handle security based on project acess.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE CodestrRec IS RECORD (
      code_a               VARCHAR2(20),
      code_a_desc          VARCHAR2(100),
      code_b               VARCHAR2(20),
      code_b_desc          VARCHAR2(100),
      code_c               VARCHAR2(20),
      code_c_desc          VARCHAR2(100),
      code_d               VARCHAR2(20),
      code_d_desc          VARCHAR2(100),
      code_e               VARCHAR2(20),
      code_e_desc          VARCHAR2(100),
      code_f               VARCHAR2(20),
      code_f_desc          VARCHAR2(100),
      code_g               VARCHAR2(20),
      code_g_desc          VARCHAR2(100),
      code_h               VARCHAR2(20),
      code_h_desc          VARCHAR2(100),
      code_i               VARCHAR2(20),
      code_i_desc          VARCHAR2(100),
      code_j               VARCHAR2(20),
      code_j_desc          VARCHAR2(100),
      quantity             NUMBER,
      process_code         VARCHAR2(10),
      text                 VARCHAR2(200),
      project_activity_id  NUMBER,
      function_group       VARCHAR2(10),
      posting_type         VARCHAR2(10));   
TYPE Code_part_value_tab         IS TABLE OF VARCHAR2(20)  INDEX BY VARCHAR2(1);
TYPE FuncMappedCodePrtsType      IS TABLE OF VARCHAR2(1)   INDEX BY VARCHAR2(100);
TYPE CodePrtValsByFunctionType   IS TABLE OF VARCHAR2(20)  INDEX BY VARCHAR2(100);

-- Record for handling generic codestring handling for the Aurena client
-- The codestring is sent in using this record and returned using this record
-- If the codestring completion has will change any of the input it is returned in the
-- attributes starting with "modified" and the attribute "modified_code_string" is set to TRUE. This
-- so that cilent can prompt the user with a question to either keep the input data or use the modified code string
-- generated by the codestring completetion.
TYPE Codestring_Handling_Rec IS RECORD (
   company                       VARCHAR2(20),
   code_a                        VARCHAR2(20),
   code_b                        VARCHAR2(20),
   code_c                        VARCHAR2(20),
   code_d                        VARCHAR2(20),
   code_e                        VARCHAR2(20),
   code_f                        VARCHAR2(20),
   code_g                        VARCHAR2(20),
   code_h                        VARCHAR2(20),
   code_i                        VARCHAR2(20),
   code_j                        VARCHAR2(20),
   process_code                  VARCHAR2(10),
   text                          VARCHAR2(200),
   quantity                      NUMBER,
   project_activity_id           NUMBER,
   project_id                    VARCHAR2(10),
   modified_code_a               VARCHAR2(20),
   modified_code_b               VARCHAR2(20),
   modified_code_c               VARCHAR2(20),
   modified_code_d               VARCHAR2(20),
   modified_code_e               VARCHAR2(20),
   modified_code_f               VARCHAR2(20),
   modified_code_g               VARCHAR2(20),
   modified_code_h               VARCHAR2(20),
   modified_code_i               VARCHAR2(20),
   modified_code_j               VARCHAR2(20),
   modified_process_code         VARCHAR2(10),
   modified_text                 VARCHAR2(100),
   modified_quantity             NUMBER,
   modified_project_activity_id  NUMBER,   
   modified_project_id           VARCHAR2(10),
   modified_required_string      VARCHAR2(2000),
   required_string               VARCHAR2(2000),
   modified_code_string          VARCHAR2(5));

-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE Codepart_Completion_Rec IS RECORD (
   required_string         VARCHAR2(2000),
   req_string_complete     VARCHAR2(2000),
   completion_attr         VARCHAR2(2000),
   is_pseudo_code          VARCHAR2(5),
   modified_code_string    BOOLEAN);

TYPE Project_Activity_Rec IS RECORD (
   project_activity_id_enable    VARCHAR2(1),
   project_activity_id           NUMBER);
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Complete_Codestring___ (
   codestring_rec_ IN OUT CodestrRec,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   voucher_date_   IN     DATE,
   code_part_      IN     VARCHAR2 DEFAULT NULL,
   include_desc_   IN     BOOLEAN DEFAULT FALSE )
IS
   --
   codep_        VARCHAR2(1);
   override_rec_ Accounting_Codestr_API.CodestrRec;
   --
BEGIN
   codep_ := code_part_;

   codestring_rec_.posting_type := posting_type_;

   Accounting_Codestr_Compl_API.Get_Codestring_Completetion( codestring_rec_,
                                                             codep_,
                                                             company_,
                                                             override_rec_,
                                                             voucher_date_);

   IF (include_desc_) THEN
      IF (codestring_rec_.code_a IS NOT NULL) THEN
         codestring_rec_.code_a_desc := ACCOUNT_API.Get_Description(company_, codestring_rec_.code_a);
      END IF;
      IF (codestring_rec_.code_b IS NOT NULL) THEN
         codestring_rec_.code_b_desc := CODE_B_API.Get_Description(company_, codestring_rec_.code_b);
      END IF;
      IF (codestring_rec_.code_c IS NOT NULL) THEN
         codestring_rec_.code_c_desc := CODE_C_API.Get_Description(company_, codestring_rec_.code_c);
      END IF;
      IF (codestring_rec_.code_d IS NOT NULL) THEN
         codestring_rec_.code_d_desc := CODE_D_API.Get_Description(company_, codestring_rec_.code_d);
      END IF;
      IF (codestring_rec_.code_e IS NOT NULL) THEN
         codestring_rec_.code_e_desc := CODE_E_API.Get_Description(company_, codestring_rec_.code_e);
      END IF;
      IF (codestring_rec_.code_f IS NOT NULL) THEN
         codestring_rec_.code_f_desc := CODE_F_API.Get_Description(company_, codestring_rec_.code_f);
      END IF;
      IF (codestring_rec_.code_g IS NOT NULL) THEN
         codestring_rec_.code_g_desc := CODE_G_API.Get_Description(company_, codestring_rec_.code_g);
      END IF;
      IF (codestring_rec_.code_h IS NOT NULL) THEN
         codestring_rec_.code_h_desc := CODE_H_API.Get_Description(company_, codestring_rec_.code_h);
      END IF;
      IF (codestring_rec_.code_i IS NOT NULL) THEN
         codestring_rec_.code_i_desc := CODE_I_API.Get_Description(company_, codestring_rec_.code_i);
      END IF;
      IF (codestring_rec_.code_j IS NOT NULL) THEN
         codestring_rec_.code_j_desc := CODE_J_API.Get_Description(company_, codestring_rec_.code_j);
      END IF;
   END IF;
END Complete_Codestring___;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
PROCEDURE Complete_Codestring_Proj___ (
   codestring_rec_ IN OUT CodestrRec,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   voucher_date_   IN     DATE,
   project_id_     IN     VARCHAR2)
IS
   --
   codep_        VARCHAR2(1);
   --
BEGIN
   
   codestring_rec_.posting_type := posting_type_;

   Accounting_Codestr_Compl_API.Get_Codestring_Completetion( codestring_rec_,
                                                             codep_,
                                                             company_,
                                                             voucher_date_,
                                                             project_id_);
END Complete_Codestring_Proj___;

PROCEDURE Check_Project_Mpccom___ (
   newrec_        IN CodestrRec,
   voucher_date_  IN DATE,
   company_       IN VARCHAR2 )
 IS
   project_id_             VARCHAR2(20);
   hold_project_id_        VARCHAR2(20);
   project_code_part_      VARCHAR2(1);
   project_origin_         VARCHAR2(30);
   state_                  VARCHAR2(20);
   project_activity_id_    NUMBER;
   need_to_validate_       BOOLEAN := FALSE;
   function_group_         VARCHAR2(10);
   project_cost_element_   VARCHAR2(100);
   exclude_proj_followup_  VARCHAR2(5);
   
   CURSOR proj_code_part IS
      SELECT code_part
      FROM   ACCOUNTING_CODE_PART_TAB
      WHERE  company           = company_
      AND    logical_code_part = 'Project';
BEGIN
   
   $IF Component_Genled_SYS.INSTALLED $THEN
      project_code_part_ := Accounting_Code_Parts_Api.Get_Codepart_Function(company_, 'PRACC');
   $ELSE
      OPEN  proj_code_part;
      FETCH proj_code_part INTO project_code_part_;
      CLOSE proj_code_part;
   $END

   project_activity_id_ := newrec_.project_activity_id;

   IF (project_code_part_ IS NOT NULL) THEN
      IF    (project_code_part_ = 'B') THEN
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

      IF (( project_id_ IS NOT NULL ) OR (project_activity_id_ IS NOT NULL )) THEN
         need_to_validate_ := TRUE;
      END IF;
   ELSE
      IF (( project_id_ IS NOT NULL ) OR (project_activity_id_ IS NOT NULL )) THEN
          Error_SYS.Appl_General(lu_name_, 'PROJCODEPTNOTDEF: Project Code Part is not defined for company :P1', company_);
      END IF;
   END IF;

   hold_project_id_ := project_id_;

   IF (need_to_validate_) THEN
      function_group_ := NVL(newrec_.function_group, CHR(0));
      IF (project_activity_id_ != -123456 ) THEN
         IF ((project_activity_id_ IS NOT NULL) AND (project_id_ IS NULL)) THEN
            Error_SYS.Appl_General(lu_name_, 'NOPROJSPECIFIED: A Project must be specified in order for Activity Sequence No to have a value');
         END IF;
      END IF;
      
      IF (project_id_ IS NOT NULL) THEN
         $IF Component_Genled_SYS.INSTALLED $THEN
            project_origin_:= Accounting_Project_API.Get_Project_Origin_Db( company_ , project_id_ );
         $ELSE
            project_origin_:=NULL;
         $END
      END IF;
      
      exclude_proj_followup_ := nvl(Account_API.Get_Exclude_Proj_Followup(company_, newrec_.code_a), 'FALSE');
      Trace_SYS.Message('TRACE=> exclude_proj_followup_: '||exclude_proj_followup_);      
      IF (project_origin_ = 'PROJECT') AND (project_activity_id_ IS NULL) THEN
         IF ( function_group_ != 'Z' ) THEN            
            IF (exclude_proj_followup_ = 'FALSE') THEN
               Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Activity Sequence No must have a value for Project :P1', project_id_);
            END IF;           
         END IF;
      ELSIF (project_origin_ = 'JOB') THEN
         IF (function_group_ NOT IN ('M', 'K', 'Q','A','P','R','Z','D')) THEN
            IF (project_activity_id_ <> 0) THEN
               Error_SYS.Record_General(lu_name_, 'ACTSEQNOMUSTBEZERO: Activity Sequence No must be zero for Project :P1', project_id_);
            END IF;
         ELSE
            project_activity_id_ := 0;
         END IF;
      ELSIF (project_activity_id_ = -123456) THEN
         project_activity_id_ := NULL;
      END IF;

      -- Validations required if Project origin is Project and if packages and methods are installed
      IF (project_origin_ = 'PROJECT') THEN
         $IF Component_Proj_SYS.INSTALLED $THEN            
            IF (exclude_proj_followup_ = 'FALSE') THEN               
               IF (Account_API .Get_Accnt_Type_Db(company_, newrec_.code_a) <> 'R') THEN
                  project_cost_element_ := Cost_Element_To_Account_API.Get_Project_Follow_Up_Element(company_, newrec_.code_a, newrec_.code_b, newrec_.code_c, newrec_.code_d,
                                                                                                     newrec_.code_e, newrec_.code_f, newrec_.code_g, newrec_.code_h, newrec_.code_i,
                                                                                                     newrec_.code_j, voucher_date_,'TRUE');
               END IF;               
            END IF;
            IF (function_group_ != 'P') THEN
               IF (project_activity_id_ IS NOT NULL) THEN

                  IF (Activity_API.Is_Activity_Postable(project_id_, project_activity_id_) = 0) THEN
                     Error_SYS.Record_General(lu_name_,'ACTIDNOTPOSTABLE: In Project :P1 , Activity Sequence No :P2 is Planned, Closed or Cancelled. This operation is not allowed on Planned, Closed or Cancelled activities.',project_id_,project_activity_id_);
                  END IF;
               END IF;
            ELSE
               -- function group = 'P'
               state_ := Project_API.Get_Objstate(project_id_);
               state_ := NVL(state_, CHR(0));
               IF (state_!= 'Completed') THEN
                  Error_SYS.Record_General(lu_name_, 'PROJNOTCOMPLETED: Project :P1 must be completed', hold_project_id_);
               END IF;
            END IF;
         $ELSE
            NULL;
         $END
      END IF;
   END IF;
END Check_Project_Mpccom___;


PROCEDURE Validate_Codeparts___ (
   codestring_rec_            IN CodestrRec,
   company_                   IN VARCHAR2,
   voucher_date_              IN DATE,
   check_codeparts_           BOOLEAN DEFAULT TRUE,
   check_demands_codeparts_   BOOLEAN DEFAULT TRUE,
   check_demands_quantity_    BOOLEAN DEFAULT TRUE,
   check_demands_process_     BOOLEAN DEFAULT TRUE,
   check_demands_text_        BOOLEAN DEFAULT TRUE,
   validate_gl_rows_          BOOLEAN DEFAULT FALSE,
   validate_account_          IN BOOLEAN DEFAULT TRUE)
IS
   accounts_req              EXCEPTION;
   curr_balance_             VARCHAR2(1);
   curr_balance_code_part_   VARCHAR2(1);
   temp_codestring_rec_      Accounting_Codestr_API.CodestrRec;
   val_result_               VARCHAR2(5);
   req_string_               VARCHAR2(20);
   is_text_req_              BOOLEAN := FALSE;
   internal_codepart_        VARCHAR2(200);
   code_part_value_          VARCHAR2(20);
   code_part_                VARCHAR2(1);
   code_part_not_found       EXCEPTION;
   val_account_rec_          Account_API.Val_Account_Rec;
BEGIN   
   IF (validate_account_) THEN
      val_account_rec_ := Account_API.Validate_Account_Rec(company_,
                                                           codestring_rec_.code_a,
                                                           voucher_date_);
      val_result_ := val_account_rec_.val_result;
      curr_balance_ := val_account_rec_.curr_balance;
      req_string_ := val_account_rec_.req_string;
      IF (val_result_ = 'FALSE' ) THEN
         code_part_ := 'A';
         code_part_value_ := codestring_rec_.code_a;
         RAISE code_part_not_found;
      END IF;
   END IF;
   
   -- 1. Check Existance and Expiry of Code Parts --
   -------------------------------------------------
   IF check_codeparts_ THEN
      FOR i_ IN 1..9 LOOP
         -- B = CHR(66)
         code_part_ := CHR(65+i_);
         code_part_value_ := Get_Rec_Value_For_Code_Part(codestring_rec_, code_part_);
         IF NOT Accounting_Code_Part_Value_API.Validate_Code_Part ( company_, 
                                                                    code_part_,
                                                                    code_part_value_,
                                                                    voucher_date_) THEN
            RAISE code_part_not_found;
         END IF;
      END LOOP;
   END IF;
   
   -- 2. Check Demands --
   ----------------------
   IF ((codestring_rec_.code_a IS NOT NULL) AND
       (check_demands_codeparts_ OR 
        check_demands_quantity_  OR
        check_demands_process_   OR
        check_demands_text_        )) THEN
       
      -- Since assignments cannot be made to a in parameter
      temp_codestring_rec_ := codestring_rec_;
      
      -- If this is a Currency Balance account, the USER is not allowed to enter a value
      -- for the code part defined for 'Currency Balance'. This value is assigned by the
      -- Updating Routine. The code part demand for the code part defined for 'Currency Balance'
      -- will probably be 'Blocked' for all 'Currency Balance' accounts. Therefore we have
      -- to make sure that when we fire Validate_Req_Account_, there will NEVER be a value
      -- for the code part defined for 'Currency Balance'.
      IF (curr_balance_ = 'Y') THEN
         curr_balance_code_part_ := substr(Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_,'CURR'),1,1);
         IF (curr_balance_code_part_ = 'B' AND codestring_rec_.code_b IS NOT NULL) THEN
            temp_codestring_rec_.code_b := NULL;
         ELSIF (curr_balance_code_part_ = 'C' AND codestring_rec_.code_c IS NOT NULL) THEN
            temp_codestring_rec_.code_c := NULL;
         ELSIF (curr_balance_code_part_ = 'D' AND codestring_rec_.code_d IS NOT NULL) THEN
            temp_codestring_rec_.code_d := NULL;
         ELSIF (curr_balance_code_part_ = 'E' AND codestring_rec_.code_e IS NOT NULL) THEN
            temp_codestring_rec_.code_e := NULL;
         ELSIF (curr_balance_code_part_ = 'F' AND codestring_rec_.code_f IS NOT NULL) THEN
            temp_codestring_rec_.code_f := NULL;
         ELSIF (curr_balance_code_part_ = 'G' AND codestring_rec_.code_g IS NOT NULL) THEN
            temp_codestring_rec_.code_g := NULL;
         ELSIF (curr_balance_code_part_ = 'H' AND codestring_rec_.code_h IS NOT NULL) THEN
            temp_codestring_rec_.code_h := NULL;
         ELSIF (curr_balance_code_part_ = 'I' AND codestring_rec_.code_i IS NOT NULL) THEN
            temp_codestring_rec_.code_i := NULL;
         ELSIF (curr_balance_code_part_ = 'J' AND codestring_rec_.code_j IS NOT NULL) THEN
            temp_codestring_rec_.code_j := NULL;
         END IF;
      END IF;
      IF check_demands_codeparts_ THEN
         internal_codepart_ := Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_, 'INTERN');
         -- if it comes only to validate GL rows since internal code part is not stored in GL we need to eliminate validation for that code part.
         -- If it comes to validate in GL update then we need to validate all the code parts.
         IF (validate_gl_rows_ AND internal_codepart_ IS NOT NULL) THEN
            IF (instr(internal_codepart_,'B')=0 AND Check_Req_Account (substr(req_string_,1,1),temp_codestring_rec_.code_b)) OR             
               (instr(internal_codepart_,'C')=0 AND Check_Req_Account (substr(req_string_,2,1),temp_codestring_rec_.code_c)) OR
               (instr(internal_codepart_,'D')=0 AND Check_Req_Account (substr(req_string_,3,1),temp_codestring_rec_.code_d)) OR
               (instr(internal_codepart_,'E')=0 AND Check_Req_Account (substr(req_string_,4,1),temp_codestring_rec_.code_e)) OR
               (instr(internal_codepart_,'F')=0 AND Check_Req_Account (substr(req_string_,5,1),temp_codestring_rec_.code_f)) OR
               (instr(internal_codepart_,'G')=0 AND Check_Req_Account (substr(req_string_,6,1),temp_codestring_rec_.code_g)) OR
               (instr(internal_codepart_,'H')=0 AND Check_Req_Account (substr(req_string_,7,1),temp_codestring_rec_.code_h)) OR
               (instr(internal_codepart_,'I')=0 AND Check_Req_Account (substr(req_string_,8,1),temp_codestring_rec_.code_i)) OR
               (instr(internal_codepart_,'J')=0 AND Check_Req_Account (substr(req_string_,9,1),temp_codestring_rec_.code_j)) THEN
            RAISE accounts_req;
            END IF;
         ELSIF Check_Req_Account (substr(req_string_,1,1),
                            temp_codestring_rec_.code_b) OR
               Check_Req_Account (substr(req_string_,2,1),
                               temp_codestring_rec_.code_c) OR
               Check_Req_Account (substr(req_string_,3,1),
                               temp_codestring_rec_.code_d) OR
               Check_Req_Account (substr(req_string_,4,1),
                               temp_codestring_rec_.code_e) OR
               Check_Req_Account (substr(req_string_,5,1),
                               temp_codestring_rec_.code_f) OR
               Check_Req_Account (substr(req_string_,6,1),
                               temp_codestring_rec_.code_g) OR
               Check_Req_Account (substr(req_string_,7,1),
                               temp_codestring_rec_.code_h) OR
               Check_Req_Account (substr(req_string_,8,1),
                               temp_codestring_rec_.code_i) OR
               Check_Req_Account (substr(req_string_,9,1),
                               temp_codestring_rec_.code_j) THEN
               RAISE accounts_req;
         END IF; 
      END IF;
      IF check_demands_quantity_ AND
         Check_Req_Account (substr(req_string_,10,1),
                            TO_CHAR(temp_codestring_rec_.quantity)) THEN
            RAISE accounts_req;
      END IF;
      IF check_demands_process_ AND
         Check_Req_Account (substr(req_string_,11,1),
                            temp_codestring_rec_.process_code)  THEN
            RAISE accounts_req;
      END IF;
      IF check_demands_text_ AND
         Check_Req_Account (substr(req_string_,12,1),
                            temp_codestring_rec_.text)  THEN
            is_text_req_ := TRUE;
            RAISE accounts_req;
      END IF;
   END IF;
EXCEPTION
   WHEN accounts_req THEN
      IF (is_text_req_) THEN
         Error_SYS.Appl_General(lu_name_,'WRONGTEXTREQ: Text value is mandatory for account :P1. Please check code part demands.',
                                codestring_rec_.code_a);
      ELSE
         IF (codestring_rec_.posting_type IS NOT NULL) THEN
            Error_SYS.Appl_General(lu_name_,'INVCODE: Invalid code part demand requirements for account :P1  connected to :P2 posting type.', codestring_rec_.code_a, codestring_rec_.posting_type );
         ELSE
            Error_SYS.Appl_General(lu_name_,'WRONGREQ: Wrong requirements for account :P1. Please check code part demands.',
                                   codestring_rec_.code_a);
         END IF;
      END IF;
   WHEN code_part_not_found THEN
      Raise_Code_Part_Not_Found___(company_,code_part_,code_part_value_, TRUE, posting_type_ => codestring_rec_.posting_type);      
END Validate_Codeparts___;

PROCEDURE Raise_Code_Part_Demands_Err___(
   company_          IN VARCHAR2,
   codepart_         IN VARCHAR2,
   req_type_         IN VARCHAR2,
   account_          IN VARCHAR2,
   validate_qty_     IN BOOLEAN )
IS   
BEGIN
   IF (codepart_ IS NOT NULL) THEN
      IF (req_type_ = 'M') THEN
         IF ( validate_qty_ AND codepart_ = 'Quantity') THEN
            Error_SYS.Appl_General(lu_name_, 'WRONGREQMANDATORY2: Account :P1 needs a value for Quantity according to budget code part demands.', account_);
         ELSE
            Error_SYS.Appl_General(lu_name_, 'WRONGREQMANDATORY: Account :P1 needs a value for code part :P2 :P3 according to budget code part demands.',
                                  account_, codepart_, Accounting_Code_Parts_API.Get_Name(company_,codepart_));         
         END IF;        
      ELSIF (req_type_ = 'S') THEN
         Error_SYS.Appl_General(lu_name_, 'WRONGREQBLOCKED: Account :P1 is blocked for code part :P2 :P3 according to budget code part demands.',
                                account_, codepart_, Accounting_Code_Parts_API.Get_Name(company_,codepart_));
      END IF;
   ELSE
      Error_SYS.Appl_General(lu_name_,'WRONGREQ1: Wrong requirements for account :P1', account_);
   END IF;
END Raise_Code_Part_Demands_Err___; 


PROCEDURE Raise_Code_Part_Not_Found___(
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2,
   validate_budget_  IN BOOLEAN,
   posting_type_     IN VARCHAR2 DEFAULT NULL )
IS   
BEGIN   
   IF (posting_type_ IS NOT NULL ) THEN
      IF (validate_budget_) THEN
         Error_SYS.Appl_General(lu_name_,'CODEMISSINGBUDPOSTING: The value :P2 used for the code part :P1 and posting type :P3 is either missing, is a budget/planning code part value or has invalid time interval.',
                                Accounting_Code_Parts_API.Get_Name(company_,code_part_), code_part_value_, posting_type_);
      ELSE      
         Error_SYS.Appl_General(lu_name_,'CODEMISSINGPOSTING: :P1 :P2 is missing or has invalid time interval for posting type :P3.', Accounting_Code_Parts_API.Get_Name(company_,code_part_), code_part_value_, posting_type_);
      END IF;
   END IF;
   IF (validate_budget_) THEN
      Error_SYS.Appl_General(lu_name_,'CODEMISSINGBUD: The value :P2 used for the code part :P1 is either missing, is a budget/planning code part value or has invalid time interval.',
                             Accounting_Code_Parts_API.Get_Name(company_,code_part_), code_part_value_);
   ELSE      
      Error_SYS.Appl_General(lu_name_,'CODEMISSING: :P1 :P2 is missing or has invalid time interval', Accounting_Code_Parts_API.Get_Name(company_,code_part_), code_part_value_);
   END IF;
END Raise_Code_Part_Not_Found___; 
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Validate_Codestring_ (
   codestring_rec_   IN OUT VARCHAR2,
   company_          IN     VARCHAR2,
   voucher_date_     IN     DATE,
   user_group_       IN     VARCHAR2)
IS
   codestr_rec_      Accounting_Codestr_API.CodestrRec;
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(200); -- max length of any attribute value
   code_part_a_      VARCHAR2(20);
   code_part_b_      VARCHAR2(20);
   code_part_c_      VARCHAR2(20);
   code_part_d_      VARCHAR2(20);
   code_part_e_      VARCHAR2(20);
   code_part_f_      VARCHAR2(20);
   code_part_g_      VARCHAR2(20);
   code_part_h_      VARCHAR2(20);
   code_part_i_      VARCHAR2(20);
   code_part_j_      VARCHAR2(20);
   quantity_         NUMBER;
   process_code_     VARCHAR2(10);
   text_             VARCHAR2(2000);
BEGIN
   ptr_ := NULL;
   WHILE Client_SYS.Get_Next_From_Attr(codestring_rec_, ptr_, name_, value_) LOOP
      IF (name_ = 'ACCOUNT') THEN
         code_part_a_ := value_;
      ELSIF (name_ = 'CODE_B') THEN
         code_part_b_ := value_;
      ELSIF (name_ = 'CODE_C') THEN
         code_part_c_ := value_;
      ELSIF (name_ = 'CODE_D') THEN
         code_part_d_ := value_;
      ELSIF (name_ = 'CODE_E') THEN
         code_part_e_ := value_;
      ELSIF (name_ = 'CODE_F') THEN
         code_part_f_ := value_;
      ELSIF (name_ = 'CODE_G') THEN
         code_part_g_ := value_;
      ELSIF (name_ = 'CODE_H') THEN
         code_part_h_ := value_;
      ELSIF (name_ = 'CODE_I') THEN
         code_part_i_ := value_;
      ELSIF (name_ = 'CODE_J') THEN
         code_part_j_ := value_;
      ELSIF (name_ = 'QUANTITY') THEN
         quantity_ := value_;
      ELSIF (name_ = 'PROCESS_CODE') THEN
         process_code_ := value_;
      ELSIF (name_ = 'TEXT') THEN
         text_  := value_;
      END IF;
   END LOOP;
   codestr_rec_.code_a := code_part_a_;
   codestr_rec_.code_b := code_part_b_;
   codestr_rec_.code_c := code_part_c_;
   codestr_rec_.code_d := code_part_d_;
   codestr_rec_.code_e := code_part_e_;
   codestr_rec_.code_f := code_part_f_;
   codestr_rec_.code_g := code_part_g_;
   codestr_rec_.code_h := code_part_h_;
   codestr_rec_.code_i := code_part_i_;
   codestr_rec_.code_j := code_part_j_;
   codestr_rec_.quantity := quantity_;
   codestr_rec_.process_code := process_code_;
   codestr_rec_.text   := text_;

   Validate_codestring( codestr_rec_,
                        company_,
                        voucher_date_,
                        user_group_);

   Client_SYS.Clear_Attr(codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT', codestr_rec_.code_a, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B', codestr_rec_.code_b, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C', codestr_rec_.code_c, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D', codestr_rec_.code_d, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E', codestr_rec_.code_e, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F', codestr_rec_.code_f, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G', codestr_rec_.code_g, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H', codestr_rec_.code_h, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I', codestr_rec_.code_i, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J', codestr_rec_.code_j, codestring_rec_);
   Client_SYS.Add_To_Attr('QUANTITY', codestr_rec_.quantity, codestring_rec_);
   Client_SYS.Add_To_Attr('PROCESS_CODE', codestr_rec_.process_code, codestring_rec_);
   Client_SYS.Add_To_Attr('TEXT', codestr_rec_.text, codestring_rec_);
END Validate_Codestring_;


PROCEDURE Complete_Codestring_ (
   codestring_rec_ IN OUT VARCHAR2,
   company_        IN     VARCHAR2,
   posting_type_   IN     VARCHAR2,
   voucher_date_   IN     DATE,
   code_part_      IN     VARCHAR2 DEFAULT NULL )
IS
   codestr_rec_    Accounting_Codestr_API.CodestrRec;
   ptr_            NUMBER;
   name_           VARCHAR2(30);
   value_          VARCHAR2(200);
   code_part_a_    VARCHAR2(20);
   code_part_b_    VARCHAR2(20);
   code_part_c_    VARCHAR2(20);
   code_part_d_    VARCHAR2(20);
   code_part_e_    VARCHAR2(20);
   code_part_f_    VARCHAR2(20);
   code_part_g_    VARCHAR2(20);
   code_part_h_    VARCHAR2(20);
   code_part_i_    VARCHAR2(20);
   code_part_j_    VARCHAR2(20);
   quantity_       NUMBER;
   process_code_   VARCHAR2(10);
   text_           VARCHAR2(200);
BEGIN
   ptr_ := NULL;
   WHILE Client_SYS.Get_Next_From_Attr(codestring_rec_, ptr_, name_, value_) LOOP
      IF (name_ = 'ACCOUNT') THEN
         code_part_a_ := value_;
      ELSIF (name_ = 'CODE_B') THEN
         code_part_b_ := value_;
      ELSIF (name_ = 'CODE_C') THEN
         code_part_c_ := value_;
      ELSIF (name_ = 'CODE_D') THEN
         code_part_d_ := value_;
      ELSIF (name_ = 'CODE_E') THEN
         code_part_e_ := value_;
      ELSIF (name_ = 'CODE_F') THEN
         code_part_f_ := value_;
      ELSIF (name_ = 'CODE_G') THEN
         code_part_g_ := value_;
      ELSIF (name_ = 'CODE_H') THEN
         code_part_h_ := value_;
      ELSIF (name_ = 'CODE_I') THEN
         code_part_i_ := value_;
      ELSIF (name_ = 'CODE_J') THEN
         code_part_j_ := value_;
      ELSIF (name_ = 'PROCESS_CODE') THEN
         process_code_ := value_;
      ELSIF (name_ = 'TEXT') THEN      
         text_ := value_;
      ELSIF (name_ = 'QUANTITY') THEN  
         quantity_ := value_;
      END IF;
   END LOOP;
   codestr_rec_.code_a := code_part_a_;
   codestr_rec_.code_b := code_part_b_;
   codestr_rec_.code_c := code_part_c_;
   codestr_rec_.code_d := code_part_d_;
   codestr_rec_.code_e := code_part_e_;
   codestr_rec_.code_f := code_part_f_;
   codestr_rec_.code_g := code_part_g_;
   codestr_rec_.code_h := code_part_h_;
   codestr_rec_.code_i := code_part_i_;
   codestr_rec_.code_j := code_part_j_;
   codestr_rec_.process_code := process_code_;
   codestr_rec_.text := text_;         
   codestr_rec_.quantity := quantity_; 

   Complete_Codestring___( codestr_rec_,
                           company_,
                           posting_type_,
                           voucher_date_,
                           code_part_,
                           TRUE);
   Client_SYS.Clear_Attr(codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT', codestr_rec_.code_a, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B', codestr_rec_.code_b, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C', codestr_rec_.code_c, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D', codestr_rec_.code_d, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E', codestr_rec_.code_e, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F', codestr_rec_.code_f, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G', codestr_rec_.code_g, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H', codestr_rec_.code_h, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I', codestr_rec_.code_i, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J', codestr_rec_.code_j, codestring_rec_);
   Client_SYS.Add_To_Attr('PROCESS_CODE', codestr_rec_.process_code, codestring_rec_);
   Client_SYS.Add_To_Attr('TEXT', codestr_rec_.text, codestring_rec_);
   Client_SYS.Add_To_Attr('QUANTITY', codestr_rec_.quantity, codestring_rec_);
   Client_SYS.Add_To_Attr('ACCOUNT_DESC', codestr_rec_.code_a_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_B_DESC', codestr_rec_.code_b_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_C_DESC', codestr_rec_.code_c_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_D_DESC', codestr_rec_.code_d_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_E_DESC', codestr_rec_.code_e_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_F_DESC', codestr_rec_.code_f_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_G_DESC', codestr_rec_.code_g_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_H_DESC', codestr_rec_.code_h_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_I_DESC', codestr_rec_.code_i_desc, codestring_rec_);
   Client_SYS.Add_To_Attr('CODE_J_DESC', codestr_rec_.code_j_desc, codestring_rec_);
END Complete_Codestring_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Complete_Codestring
--   This procedure makes codestring completion. It uses the record type
--   ac_am_br_api.CodestrRec is input and output values. If the parameter
--   codepart is NULL then codestring completion is performed on every codepart
PROCEDURE Complete_Codestring (
   codestring_rec_     IN OUT CodestrRec,
   company_            IN     VARCHAR2,
   posting_type_       IN     VARCHAR2,
   voucher_date_       IN     DATE,
   code_part_          IN     VARCHAR2 DEFAULT NULL,
   include_desc_       IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   Complete_Codestring___( codestring_rec_,
                           company_,
                           posting_type_,
                           voucher_date_,
                           code_part_,
                           include_desc_ );
END Complete_Codestring;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
PROCEDURE Complete_Codestring_Proj (
   codestring_rec_     IN OUT CodestrRec,
   company_            IN     VARCHAR2,
   posting_type_       IN     VARCHAR2,
   voucher_date_       IN     DATE,
   project_id_         IN     VARCHAR2)
IS
BEGIN
   Complete_Codestring_Proj___( codestring_rec_,
                                company_,
                                posting_type_,
                                voucher_date_,
                                project_id_);
END Complete_Codestring_Proj;

-- Complete_Codestring
--   This procedure makes codestring completion. It uses the record type
--   ac_am_br_api.CodestrRec is input and output values. If the parameter
--   codepart is NULL then codestring completion is performed on every codepart
PROCEDURE Complete_Codestring (
   codestring_rec_  IN OUT VARCHAR2,
   company_         IN     VARCHAR2,
   posting_type_    IN     VARCHAR2,
   voucher_date_    IN     DATE,
   code_part_       IN     VARCHAR2 DEFAULT NULL )
IS
BEGIN
   Complete_Codestring_( codestring_rec_,
                         company_,
                         posting_type_,
                         voucher_date_,
                         code_part_ );
END Complete_Codestring;


-- Complete_Codestring
--   This procedure makes codestring completion. It uses the record type
--   ac_am_br_api.CodestrRec is input and output values. If the parameter
--   codepart is NULL then codestring completion is performed on every codepart
PROCEDURE Complete_Codestring (
   codestring_rec_     IN OUT CodestrRec,
   company_            IN     VARCHAR2,
   posting_type_       IN     VARCHAR2,
   product_code_       IN     VARCHAR2,
   voucher_date_       IN     DATE )
IS
   codestr_rec_   Accounting_Codestr_API.CodestrRec;
   code_part_     VARCHAR2(1) := NULL;
BEGIN

   codestr_rec_.code_a := codestring_rec_.code_a;
   codestr_rec_.code_b := codestring_rec_.code_b;
   codestr_rec_.code_c := codestring_rec_.code_c;
   codestr_rec_.code_d := codestring_rec_.code_d;
   codestr_rec_.code_e := codestring_rec_.code_e;
   codestr_rec_.code_f := codestring_rec_.code_f;
   codestr_rec_.code_g := codestring_rec_.code_g;
   codestr_rec_.code_h := codestring_rec_.code_h;
   codestr_rec_.code_i := codestring_rec_.code_i;
   codestr_rec_.code_j := codestring_rec_.code_j;

   Complete_Codestring___( codestr_rec_,
                           company_,
                           posting_type_,
                           voucher_date_,
                           code_part_ );

   codestring_rec_.code_a := codestr_rec_.code_a;
   codestring_rec_.code_b := codestr_rec_.code_b;
   codestring_rec_.code_c := codestr_rec_.code_c;
   codestring_rec_.code_d := codestr_rec_.code_d;
   codestring_rec_.code_e := codestr_rec_.code_e;
   codestring_rec_.code_f := codestr_rec_.code_f;
   codestring_rec_.code_g := codestr_rec_.code_g;
   codestring_rec_.code_h := codestr_rec_.code_h;
   codestring_rec_.code_i := codestr_rec_.code_i;
   codestring_rec_.code_j := codestr_rec_.code_j;

END Complete_Codestring;


PROCEDURE Complete_Codestring_Desc (
   code_a_desc_     IN OUT VARCHAR2,
   code_b_desc_     IN OUT VARCHAR2,
   code_c_desc_     IN OUT VARCHAR2,
   code_d_desc_     IN OUT VARCHAR2,
   code_e_desc_     IN OUT VARCHAR2,
   code_f_desc_     IN OUT VARCHAR2,
   code_g_desc_     IN OUT VARCHAR2,
   code_h_desc_     IN OUT VARCHAR2,
   code_i_desc_     IN OUT VARCHAR2,
   code_j_desc_     IN OUT VARCHAR2,
   company_         IN     VARCHAR2 )
IS
BEGIN

   IF (code_a_desc_ IS NOT NULL) THEN
      code_a_desc_ := ACCOUNT_API.Get_Description(company_, code_a_desc_);
   END IF;
   IF (code_b_desc_ IS NOT NULL) THEN
      code_b_desc_ := CODE_B_API.Get_Description(company_, code_b_desc_);
   END IF;
   IF (code_c_desc_ IS NOT NULL) THEN
      code_c_desc_ := CODE_C_API.Get_Description(company_, code_c_desc_);
   END IF;
   IF (code_d_desc_ IS NOT NULL) THEN
      code_d_desc_ := CODE_D_API.Get_Description(company_, code_d_desc_);
   END IF;
   IF (code_e_desc_ IS NOT NULL) THEN
      code_e_desc_ := CODE_E_API.Get_Description(company_, code_e_desc_);
   END IF;
   IF (code_f_desc_ IS NOT NULL) THEN
      code_f_desc_ := CODE_F_API.Get_Description(company_, code_f_desc_);
   END IF;
   IF (code_g_desc_ IS NOT NULL) THEN
      code_g_desc_ := CODE_G_API.Get_Description(company_, code_g_desc_);
   END IF;
   IF (code_h_desc_ IS NOT NULL) THEN
      code_h_desc_ := CODE_H_API.Get_Description(company_, code_h_desc_);
   END IF;
   IF (code_i_desc_ IS NOT NULL) THEN
      code_i_desc_ := CODE_I_API.Get_Description(company_, code_i_desc_);
   END IF;
   IF (code_j_desc_ IS NOT NULL) THEN
      code_j_desc_ := CODE_J_API.Get_Description(company_, code_j_desc_);
   END IF;
END Complete_Codestring_Desc;


PROCEDURE Validate_Codestring (
   codestring_rec_            IN OUT CodestrRec,
   company_                   IN     VARCHAR2,
   voucher_date_              IN     DATE,
   user_group_                IN     VARCHAR2,
   check_codeparts_           IN     BOOLEAN DEFAULT TRUE,
   check_demands_codeparts_   IN     BOOLEAN DEFAULT TRUE,
   check_demands_quantity_    IN     BOOLEAN DEFAULT TRUE,
   check_demands_process_     IN     BOOLEAN DEFAULT TRUE,
   check_demands_text_        IN     BOOLEAN DEFAULT TRUE,
   validate_gl_rows_          IN     BOOLEAN DEFAULT FALSE,
   validate_account_          IN     BOOLEAN DEFAULT TRUE,
   gl_update_                 IN     VARCHAR2 DEFAULT 'FALSE')
 
IS
   user_group_def_     user_group_member_finance_tab.user_group%type;
   user_name_          VARCHAR2(100);
   check_process_code_ BOOLEAN;
   check_quantity_     BOOLEAN;
BEGIN
   
   check_process_code_ := check_demands_process_;
   check_quantity_ := check_demands_quantity_;
   
   IF (codestring_rec_.function_group IN ('P', 'V', 'TP', 'TE', 'TF')) THEN
      check_process_code_ := FALSE;
   END IF;   
   IF (codestring_rec_.quantity = 0 AND codestring_rec_.function_group = 'P') THEN
      check_quantity_ := FALSE;
   END IF;
   IF ((codestring_rec_.function_group IS NULL) OR (codestring_rec_.function_group != 'YE')) THEN
      Validate_codeparts___( codestring_rec_, company_, voucher_date_,
                          check_codeparts_,
                          check_demands_codeparts_,
                          check_quantity_,
                          check_process_code_,
                          check_demands_text_,
                          validate_gl_rows_,
                          validate_account_);
   END IF;
   
   user_name_ := User_Finance_API.User_Id;
   
   IF validate_account_ THEN
      IF (User_Finance_API.Check_User(company_, user_name_)) THEN
         Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                          company_,
                                                          user_group_,
                                                          gl_update_);
      ELSE
         user_group_def_ := User_Group_Member_Finance_API.Get_Default_Group(company_, user_name_);
         Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                          company_,
                                                          user_group_def_,
                                                          gl_update_);
      END IF;
   END IF;
END Validate_Codestring;


PROCEDURE Validate_Codestring (
   codestring_rec_   IN OUT VARCHAR2,
   company_          IN     VARCHAR2,
   voucher_date_     IN     DATE,
   user_group_       IN     VARCHAR2 )
IS
BEGIN
   Validate_Codestring_( codestring_rec_, company_, voucher_date_, user_group_);
END Validate_Codestring;


PROCEDURE Validate_Codeparts (
   codestring_rec_            IN CodestrRec,
   company_                   IN VARCHAR2,
   voucher_date_              IN DATE,
   check_codeparts_           BOOLEAN DEFAULT TRUE,
   check_demands_codeparts_   BOOLEAN DEFAULT TRUE,
   check_demands_quantity_    BOOLEAN DEFAULT TRUE,
   check_demands_process_     BOOLEAN DEFAULT TRUE,
   check_demands_text_        BOOLEAN DEFAULT TRUE,
   validate_gl_rows_          BOOLEAN DEFAULT FALSE)
IS
BEGIN
   
   Validate_codeparts___( codestring_rec_, company_, voucher_date_,
                          check_codeparts_,
                          check_demands_codeparts_,
                          check_demands_quantity_,
                          check_demands_process_,
                          check_demands_text_ );  
END Validate_Codeparts;


PROCEDURE Execute_Accounting (
  account_            OUT    NUMBER,
  code_b_             OUT    NUMBER,
  code_c_             OUT    NUMBER,
  code_d_             OUT    NUMBER,
  code_e_             OUT    NUMBER,
  code_f_             OUT    NUMBER,
  code_g_             OUT    NUMBER,
  code_h_             OUT    NUMBER,
  code_i_             OUT    NUMBER,
  code_j_             OUT    NUMBER,
  product_            IN     VARCHAR2,
  company_            IN     VARCHAR2,
  posting_type_       IN     VARCHAR2,
  control_type_       IN     VARCHAR2 )
IS
   --
   codestring_rec_   VARCHAR2(2000);
   ptr_              NUMBER;
   name_             VARCHAR2(30);
   value_            VARCHAR2(200); -- max length of any attribute value
   --
BEGIN

   Posting_Ctrl_API.Get_Code_Part ( codestring_rec_,
                                    company_,
                                    posting_type_,
                                    control_type_,
                                    module_ );
   ptr_ := NULL;
   WHILE Client_SYS.Get_Next_From_Attr(codestring_rec_, ptr_, name_, value_) LOOP
      IF (name_ = 'ACCOUNT') THEN
         account_ := value_;
      ELSIF (name_ = 'CODE_B') THEN
         code_b_ := value_;
      ELSIF (name_ = 'CODE_C') THEN
         code_c_ := value_;
      ELSIF (name_ = 'CODE_D') THEN
         code_d_ := value_;
      ELSIF (name_ = 'CODE_E') THEN
         code_e_ := value_;
      ELSIF (name_ = 'CODE_F') THEN
         code_f_ := value_;
      ELSIF (name_ = 'CODE_G') THEN
         code_g_ := value_;
      ELSIF (name_ = 'CODE_H') THEN
         code_h_ := value_;
      ELSIF (name_ = 'CODE_I') THEN
         code_i_ := value_;
      ELSIF (name_ = 'CODE_J') THEN
         code_j_ := value_;
      END IF;
   END LOOP;
END Execute_Accounting;


PROCEDURE Validate_Budget_Codestring (
   codestring_rec_   IN OUT CodestrRec,
   company_          IN     VARCHAR2,
   voucher_date_     IN     DATE,
   user_group_       IN     VARCHAR2,
   check_account_    IN     BOOLEAN DEFAULT TRUE,
   check_codeparts_  IN     BOOLEAN DEFAULT TRUE,
   check_demands_    IN     BOOLEAN DEFAULT TRUE,
   ledger_id_        IN     VARCHAR2 DEFAULT '00')
IS
   user_group_def_         user_group_member_finance_tab.user_group%type;
   user_name_              VARCHAR2(100);   
   curr_balance_           VARCHAR2(1);
   val_result_             VARCHAR2(5);
   req_string_             VARCHAR2(20);
   result_                 VARCHAR2(5);
   req_type_               VARCHAR2(1);
   codepart_               VARCHAR2(1);
   code_part_value_        VARCHAR2(20);
   code_part_              VARCHAR2(1);
   allowed_in_budget_      VARCHAR2(5):= 'TRUE';
   code_part_not_found     EXCEPTION;
   accounts_req            EXCEPTION;
BEGIN   
   /* validate accounting code part A */
   IF (check_account_ OR check_demands_) THEN
      Account_API.Validate_Account ( val_result_,
                                     curr_balance_,
                                     req_string_,
                                     company_,
                                     codestring_rec_.code_a,
                                     voucher_date_ );
      IF (val_result_ = 'FALSE' ) THEN
         code_part_ := 'A';
         code_part_value_ := codestring_rec_.code_a;
         RAISE code_part_not_found;
      END IF;
   END IF;
   
   /* validate code parts */
   IF check_codeparts_ THEN
      FOR i_ IN 1..9 LOOP
         -- B = CHR(66)
         code_part_ := CHR(65+i_);
         code_part_value_ := Get_Rec_Value_For_Code_Part(codestring_rec_, code_part_);
         IF NOT Accounting_Code_Part_Value_API.Validate_Code_Part ( company_, 
                                                                    code_part_,
                                                                    code_part_value_,
                                                                    voucher_date_,
                                                                    'TRUE') THEN
            RAISE code_part_not_found;
         END IF;
      END LOOP;
   END IF;
   
   IF (check_demands_ AND codestring_rec_.code_a IS NOT NULL) THEN
      IF (curr_balance_ = 'N') THEN
         Account_API.Validate_Budget_Req_Account_ ( result_,
                                                    req_type_,
                                                    codepart_,
                                                    codestring_rec_,
                                                    company_,
                                                    voucher_date_);
         IF ledger_id_ != '00' THEN                                           
            $IF Component_Intled_SYS.INSTALLED $THEN
               allowed_in_budget_ := Internal_Ledger_Util_Pub_API.Is_Codepart_Allowed_In_Budget(company_, ledger_id_, codepart_);
            $ELSE
               allowed_in_budget_ := 'FALSE';
            $END 
         END IF;
         IF (result_ = 'TRUE') AND (allowed_in_budget_ = 'TRUE') THEN
            RAISE accounts_req;
         END IF;                                           
      END IF;
   END IF;

   /*
   This is only to support an old interface for Validate_Codestring. The old interface
   hade user id as input parameter insted of user_group.
   */
   IF user_group_ IS NOT NULL THEN
      Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_);
   ELSE
      user_name_ := User_Finance_API.User_Id;
      user_group_def_ := User_Group_Member_Finance_API.Get_Default_Group (company_,
                                                                          user_name_);
      Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_def_);
   END IF;
EXCEPTION
   WHEN accounts_req THEN
      Raise_Code_Part_Demands_Err___( company_ ,codepart_,req_type_,codestring_rec_.code_a, FALSE);   
   WHEN code_part_not_found THEN
      Raise_Code_Part_Not_Found___(company_,code_part_,code_part_value_, FALSE );
END Validate_Budget_Codestring;

  
PROCEDURE Validate_Budget_Codestring (
   codestring_rec_   IN OUT CodestrRec,
   company_          IN     VARCHAR2,
   user_group_       IN     VARCHAR2,
   budget_year_      IN     NUMBER,
   period_           IN     NUMBER,
   period_from_      IN     NUMBER,
   period_to_        IN     NUMBER,
   ledger_id_        IN     VARCHAR2 DEFAULT '00')
IS
   user_group_def_         user_group_member_finance_tab.user_group%type;
   user_name_              VARCHAR2(100);
   accounts_req            EXCEPTION;
   curr_balance_           VARCHAR2(1);
   val_result_             VARCHAR2(5);
   req_string_             VARCHAR2(20);
   result_                 VARCHAR2(5);
   req_type_               VARCHAR2(1);
   codepart_               VARCHAR2(8);
   code_part_              VARCHAR2(1);
   code_part_value_        VARCHAR2(20);
   allowed_in_budget_      VARCHAR2(5):= 'TRUE';
   code_part_not_found     EXCEPTION;
BEGIN
   Account_API.Validate_Account ( val_result_,
                                  curr_balance_,
                                  req_string_,
                                  company_,
                                  codestring_rec_.code_a,
                                  budget_year_,
                                  period_,
                                  period_from_,
                                  period_to_);
   IF (val_result_ = 'FALSE' ) THEN
      code_part_ := 'A';
      code_part_value_ := codestring_rec_.code_a;
      RAISE code_part_not_found;
   END IF;
   FOR i_ IN 1..9 LOOP
      -- B = CHR(66)
      code_part_ := CHR(65+i_);
      code_part_value_ := Get_Rec_Value_For_Code_Part(codestring_rec_, code_part_);
      IF NOT Accounting_Code_Part_Value_API.Validate_Code_Part ( company_, code_part_,
                                                                 code_part_value_,
                                                                 budget_year_,
                                                                 period_,
                                                                 period_from_,
                                                                 period_to_,
                                                                 'TRUE') THEN
         RAISE code_part_not_found;
      END IF;
   END LOOP;

   IF (codestring_rec_.code_a IS NOT NULL) THEN
      --IF (curr_balance_ = 'N') THEN
         Account_API.Validate_Budget_Req_Account_ ( result_,
                                                    req_type_,
                                                    codepart_,
                                                    codestring_rec_,
                                                    company_,
                                                    budget_year_,
                                                    period_,
                                                    period_from_,
                                                    period_to_);
         IF ledger_id_ != '00' THEN                                           
            $IF Component_Intled_SYS.INSTALLED $THEN
               allowed_in_budget_ := Internal_Ledger_Util_Pub_API.Is_Codepart_Allowed_In_Budget(company_, ledger_id_, codepart_);
            $ELSE
               allowed_in_budget_ := 'FALSE';
            $END 
         END IF;
         IF (result_ = 'TRUE') AND (allowed_in_budget_ = 'TRUE') THEN
            RAISE accounts_req;
         END IF;
      --END IF;
   END IF;

--
-- This is only to support an old interface for Validate_Codestring. The old interface
-- hade user id as input parameter insted of user_group.
-- Start.
   user_name_ := User_Finance_API.User_Id;
   user_group_def_ := User_Group_Member_Finance_API.Get_Default_Group (company_,
                                                                       user_name_);
   IF NOT (User_Finance_API.Check_User(company_,
                                       user_name_)) THEN
      Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_);
   ELSE
      Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_def_);
   END IF;
EXCEPTION
   WHEN accounts_req THEN      
      Raise_Code_Part_Demands_Err___( company_ ,codepart_,req_type_,codestring_rec_.code_a, TRUE);
   WHEN code_part_not_found THEN
      Raise_Code_Part_Not_Found___(company_,code_part_,code_part_value_, FALSE);
END Validate_Budget_Codestring;


@UncheckedAccess
FUNCTION Check_Req_Account (
   req_code_  IN VARCHAR2,
   account_   IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   IF ((account_ IS NULL AND req_code_ = 'M') OR
       (account_ IS NOT NULL AND req_code_ = 'S')) THEN
      RETURN (TRUE);
   END IF;
   RETURN (FALSE);
END Check_Req_Account;



PROCEDURE Validate_Codestring_Mpccom(
   codestring_rec_   IN OUT CodestrRec,
   company_          IN     VARCHAR2,
   voucher_date_     IN     DATE,
   user_group_       IN     VARCHAR2 )
IS
   fa_code_part_     VARCHAR2(10);
   object_id_        VARCHAR2(10);
   acq_account_      VARCHAR2(20);
   object_state_     VARCHAR2(30);
   $IF Component_Fixass_SYS.INSTALLED $THEN
      object_acq_rec_   Fa_Object_API.Public_Object_Acq_Rec;
   $END
   fa_code_part_name_ VARCHAR2(100);

BEGIN

   Validate_Codestring( codestring_rec_ ,
                        company_ ,
                        voucher_date_ ,
                        user_group_,
                        check_demands_quantity_    => FALSE,
                        check_demands_process_     => FALSE,
                        check_demands_text_        => FALSE);

   -- Additional checks when Object is specified in Code String
   $IF Component_Fixass_SYS.INSTALLED $THEN
      IF (Acquisition_Account_API.Is_Acquisition_Account (company_,
                                                          codestring_rec_.code_a)) THEN

         fa_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(company_,'FAACC');
         fa_code_part_ := UPPER(fa_code_part_);

         IF (fa_code_part_ = 'B')    THEN
            object_id_ := codestring_rec_.code_b;
         ELSIF (fa_code_part_ = 'C') THEN
            object_id_ := codestring_rec_.code_c;
         ELSIF (fa_code_part_ = 'D') THEN
            object_id_ := codestring_rec_.code_d;
         ELSIF (fa_code_part_ = 'E') THEN
            object_id_ := codestring_rec_.code_e;
         ELSIF (fa_code_part_ = 'F') THEN
            object_id_ := codestring_rec_.code_f;
         ELSIF (fa_code_part_ = 'G') THEN
            object_id_ := codestring_rec_.code_g;
         ELSIF (fa_code_part_ = 'H') THEN
            object_id_ := codestring_rec_.code_h;
         ELSIF (fa_code_part_ = 'I') THEN
            object_id_ := codestring_rec_.code_i;
         ELSIF (fa_code_part_ = 'J') THEN
            object_id_ := codestring_rec_.code_j;
         END IF;

         IF (object_id_ IS NOT NULL) THEN
              -- Check whether the supplied Object Id is known in company
              IF NOT (FA_Object_API.Already_Exist(company_,object_id_)) THEN
                  Error_SYS.appl_general(lu_name_,'UNKNOBJ: Object identity :P1 is Unknown',object_id_);
              END IF;

              -- Check whether the supplied acquisition account matches the acquisition account of object
              acq_account_ := FA_Object_API.Get_Account(company_,object_id_);

              IF (codestring_rec_.code_a != acq_account_) THEN
                 Error_SYS.appl_general(lu_name_,'NOTAQACC: Account :P1 is not the Acquisition Account for object :P2 ',
                                                 codestring_rec_.code_a, object_id_);
              END IF;

              -- Check State of Object.
              object_state_ := FA_Object_API.Get_Objstate(company_ , object_id_);
              IF (object_state_ != 'Investment') THEN
                 Error_SYS.appl_general(lu_name_,
                                        'WRNGSTAT: You have specified an object with wrong status.');

              END IF;
              
              -- Check Whether the current codestring matches the acquisition code string
              object_acq_rec_.company         := company_;
              object_acq_rec_.object_id       := object_id_;
              object_acq_rec_.account         := codestring_rec_.code_a;
              object_acq_rec_.code_b          := codestring_rec_.code_b;
              object_acq_rec_.code_c          := codestring_rec_.code_c;
              object_acq_rec_.code_d          := codestring_rec_.code_d;
              object_acq_rec_.code_e          := codestring_rec_.code_e;
              object_acq_rec_.code_f          := codestring_rec_.code_f;
              object_acq_rec_.code_g          := codestring_rec_.code_g;
              object_acq_rec_.code_h          := codestring_rec_.code_h;
              object_acq_rec_.code_i          := codestring_rec_.code_i;
              object_acq_rec_.code_j          := codestring_rec_.code_j;
              object_acq_rec_.fa_code_part    := fa_code_part_;

              FA_Object_API.Check_Code_Parts_Invest(object_acq_rec_);

              -- Check Whether the Hold table vouchers have different code strings
              VOUCHER_ROW_API.Check_Code_Str_Fa (company_ ,
                                                 object_id_,
                                                 fa_code_part_,
                                                 codestring_rec_);
         ELSE
              -- Acquisition Account used but No Object ID Supplied , Give Error Message
              fa_code_part_name_ := Accounting_Code_Parts_API.Get_Name (company_,
                                                                        fa_code_part_);
              Error_SYS.appl_general (lu_name_,
                                      'OBJMISSING: FA acquisition account :P1 supplied but object identity missing in code part :P2',
                                      codestring_rec_.code_a,
                                      fa_code_part_name_ );

         END IF;
      END IF ;
   $ELSE
      NULL;
   $END
   -- Note:- This is to validate Project related data
   Check_Project_Mpccom___( codestring_rec_,
                            voucher_date_,
                            company_ );
END Validate_Codestring_Mpccom;


PROCEDURE Validate_Internal_Codestring (
   codestring_rec_ IN CodestrRec,
   company_        IN VARCHAR2,
   voucher_date_   IN DATE,
   user_group_     IN VARCHAR2 )
IS
   invalid_code_part  EXCEPTION;
   code_part_value_   VARCHAR2(20);
   code_part_         VARCHAR2(1);
BEGIN
     
   -- Validate the codeparts except account
   FOR i_ IN 1..9 LOOP
      -- B = CHR(66)
      code_part_ := CHR(65+i_);
      code_part_value_ := Get_Rec_Value_For_Code_Part(codestring_rec_, code_part_);
      IF NOT Accounting_Code_Part_Value_API.Validate_Code_Part ( company_, code_part_,
                                                                 code_part_value_,
                                                                 voucher_date_) THEN
         RAISE invalid_code_part;
      END IF;
   END LOOP; 
EXCEPTION
   WHEN invalid_code_part THEN
      Raise_Code_Part_Not_Found___(company_,code_part_,code_part_value_, TRUE);
END Validate_Internal_Codestring;


PROCEDURE Validate_Budget_Codestr_Dates (
   codestring_rec_   IN OUT CodestrRec,
   company_          IN     VARCHAR2,
   date_from_        IN     DATE,
   date_until_       IN     DATE,
   user_group_       IN     VARCHAR2,
   check_account_    IN     BOOLEAN DEFAULT TRUE,
   check_codeparts_  IN     BOOLEAN DEFAULT TRUE,
   check_demands_    IN     BOOLEAN DEFAULT TRUE,
   check_category_   IN     BOOLEAN DEFAULT TRUE)
IS
   user_group_def_         user_group_member_finance_tab.user_group%type;
   user_name_              VARCHAR2(100);   
   curr_balance_           VARCHAR2(1);
   val_result_             VARCHAR2(5);
   req_string_             VARCHAR2(20);
   code_part_              VARCHAR2(1);
   code_part_value_        VARCHAR2(20);
   code_part_not_found     EXCEPTION;
BEGIN
   
   /* validate accounting code part A */
   IF (check_account_ OR check_demands_) THEN
      Account_API.Validate_Account ( val_result_,
                                     curr_balance_,
                                     req_string_,
                                     company_,
                                     codestring_rec_.code_a,
                                     date_from_ );
      IF (val_result_ = 'FALSE' ) THEN
         code_part_ := 'A';
         code_part_value_ := codestring_rec_.code_a;
         RAISE code_part_not_found;
      END IF;
   END IF;

   /* validate code parts */
   IF check_codeparts_ THEN
      FOR i_ IN 1..9 LOOP
         -- B = CHR(66)
         code_part_ := CHR(65+i_);
         code_part_value_ := Get_Rec_Value_For_Code_Part(codestring_rec_, code_part_);
         IF NOT Accounting_Code_Part_Value_API.Validate_Code_Part ( company_, code_part_,
                                                                    code_part_value_,
                                                                    date_from_,
                                                                    date_until_,
                                                                    'TRUE') THEN
            RAISE code_part_not_found;
         END IF;
      END LOOP;
   END IF;
   
   /*
   This is only to support an old interface for Validate_Codestring. The old interface
   hade user id as input parameter insted of user_group.
   */
   IF check_category_ THEN
      IF user_group_ IS NOT NULL THEN
         Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_);
      ELSE
         user_name_ := User_Finance_API.User_Id;
         user_group_def_ := User_Group_Member_Finance_API.Get_Default_Group (company_,
                                                                          user_name_);
         Accounting_Codestr_Comb_API.Combination_Control( codestring_rec_,
                                                       company_,
                                                       user_group_def_);
      END IF;
   END IF;
EXCEPTION
   WHEN code_part_not_found THEN
      Raise_Code_Part_Not_Found___(company_,code_part_,code_part_value_, FALSE);
END Validate_Budget_Codestr_Dates;


PROCEDURE Get_Prj_And_Obj_Code_P_Values (
   project_id_          OUT  VARCHAR2,
   object_id_           OUT  VARCHAR2,
   codestring_rec_       IN  CodestrRec,
   project_code_part_    IN  VARCHAR2,
   object_code_part_     IN  VARCHAR2 )
IS
BEGIN
   project_id_ := Get_Rec_Value_For_Code_Part(codestring_rec_,
                                              project_code_part_);

   object_id_ := Get_Rec_Value_For_Code_Part(codestring_rec_,
                                             object_code_part_);
END Get_Prj_And_Obj_Code_P_Values;


@UncheckedAccess
FUNCTION Get_Code_P_Values_By_Function(
   function_mapped_code_prts_   IN  FuncMappedCodePrtsType,
   codestring_rec_              IN  CodestrRec ) RETURN CodePrtValsByFunctionType
IS
  key_value_ VARCHAR2(100);
  code_prt_vals_by_function_  Accounting_Codestr_API.CodePrtValsByFunctionType;
BEGIN
   -- get empty code part values table indexed by code_part_function name
   code_prt_vals_by_function_ := Accounting_Code_Part_Util_API.Get_Code_Prt_Vals_By_Func_Tab;
   
   IF (function_mapped_code_prts_.COUNT > 0) THEN
      key_value_ := function_mapped_code_prts_.FIRST;
      WHILE key_value_ IS NOT NULL LOOP
          code_prt_vals_by_function_(key_value_) := Get_Rec_Value_For_Code_Part(codestring_rec_,function_mapped_code_prts_(key_value_));
          key_value_ := function_mapped_code_prts_.NEXT(key_value_);
      END LOOP;  
   END IF;
   
   RETURN code_prt_vals_by_function_;     
END Get_Code_P_Values_By_Function;



-- Get_Rec_Value_For_Code_Part
--   Returns the value for a given code part in the codestring record
@UncheckedAccess
FUNCTION Get_Rec_Value_For_Code_Part (
   codestring_rec_      IN    CodestrRec,
   code_part_           IN    VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN   CASE WHEN code_part_ = 'A' THEN
               codestring_rec_.code_a
            WHEN code_part_ = 'B' THEN
               codestring_rec_.code_b
            WHEN code_part_ = 'C' THEN
               codestring_rec_.code_c
            WHEN code_part_ = 'D' THEN
               codestring_rec_.code_d
            WHEN code_part_ = 'E' THEN
               codestring_rec_.code_e
            WHEN code_part_ = 'F' THEN
               codestring_rec_.code_f
            WHEN code_part_ = 'G' THEN
               codestring_rec_.code_g
            WHEN code_part_ = 'H' THEN
               codestring_rec_.code_h
            WHEN code_part_ = 'I' THEN
               codestring_rec_.code_i
            WHEN code_part_ = 'J' THEN
               codestring_rec_.code_j
            ELSE
               NULL
            END;
END Get_Rec_Value_For_Code_Part;



-- Get_Value_For_Code_Part
--   Returns the value for a given code part from the supplied codestring values
@UncheckedAccess
FUNCTION Get_Value_For_Code_Part (
   code_a_value_              IN    VARCHAR2,
   code_b_value_              IN    VARCHAR2,
   code_c_value_              IN    VARCHAR2,
   code_d_value_              IN    VARCHAR2,
   code_e_value_              IN    VARCHAR2,
   code_f_value_              IN    VARCHAR2,
   code_g_value_              IN    VARCHAR2,
   code_h_value_              IN    VARCHAR2,
   code_i_value_              IN    VARCHAR2,
   code_j_value_              IN    VARCHAR2,
   code_part_                 IN    VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN   CASE WHEN code_part_ = 'A' THEN
               code_a_value_
            WHEN code_part_ = 'B' THEN
               code_b_value_
            WHEN code_part_ = 'C' THEN
               code_c_value_
            WHEN code_part_ = 'D' THEN
               code_d_value_
            WHEN code_part_ = 'E' THEN
               code_e_value_
            WHEN code_part_ = 'F' THEN
               code_f_value_
            WHEN code_part_ = 'G' THEN
               code_g_value_
            WHEN code_part_ = 'H' THEN
               code_h_value_
            WHEN code_part_ = 'I' THEN
               code_i_value_
            WHEN code_part_ = 'J' THEN
               code_j_value_
            ELSE
               NULL
            END;
END Get_Value_For_Code_Part;



-- Convert_To_Code_Str_Rec
--   Returns the codepart values as a record of type Accounting_Codestr_API.CodestrRec
@UncheckedAccess
FUNCTION Convert_To_Code_Str_Rec (
   code_a_value_              IN    VARCHAR2,
   code_b_value_              IN    VARCHAR2,
   code_c_value_              IN    VARCHAR2,
   code_d_value_              IN    VARCHAR2,
   code_e_value_              IN    VARCHAR2,
   code_f_value_              IN    VARCHAR2,
   code_g_value_              IN    VARCHAR2,
   code_h_value_              IN    VARCHAR2,
   code_i_value_              IN    VARCHAR2,
   code_j_value_              IN    VARCHAR2) RETURN CodestrRec
IS
   codestring_rec_     Accounting_Codestr_API.CodestrRec;
BEGIN
   codestring_rec_.code_a := code_a_value_;
   codestring_rec_.code_b := code_b_value_;
   codestring_rec_.code_c := code_c_value_;
   codestring_rec_.code_d := code_d_value_;
   codestring_rec_.code_e := code_e_value_;
   codestring_rec_.code_f := code_f_value_;
   codestring_rec_.code_g := code_g_value_;
   codestring_rec_.code_h := code_h_value_;
   codestring_rec_.code_i := code_i_value_;
   codestring_rec_.code_j := code_j_value_;
   RETURN codestring_rec_;
END Convert_To_Code_Str_Rec;



-- Convert_Rec_To_Code_Part_Vals
--   Returns the codestring record as separate codepart values
@UncheckedAccess
PROCEDURE Convert_Rec_To_Code_Part_Vals (
   code_a_value_              OUT    VARCHAR2,
   code_b_value_              OUT    VARCHAR2,
   code_c_value_              OUT    VARCHAR2,
   code_d_value_              OUT    VARCHAR2,
   code_e_value_              OUT    VARCHAR2,
   code_f_value_              OUT    VARCHAR2,
   code_g_value_              OUT    VARCHAR2,
   code_h_value_              OUT    VARCHAR2,
   code_i_value_              OUT    VARCHAR2,
   code_j_value_              OUT    VARCHAR2,
   codestring_rec_            IN     CodestrRec)
IS
BEGIN
   code_a_value_ := codestring_rec_.code_a;
   code_b_value_ := codestring_rec_.code_b;
   code_c_value_ := codestring_rec_.code_c;
   code_d_value_ := codestring_rec_.code_d;
   code_e_value_ := codestring_rec_.code_e;
   code_f_value_ := codestring_rec_.code_f;
   code_g_value_ := codestring_rec_.code_g;
   code_h_value_ := codestring_rec_.code_h;
   code_i_value_ := codestring_rec_.code_i;
   code_j_value_ := codestring_rec_.code_j;
END Convert_Rec_To_Code_Part_Vals;


-- Get_Code_Part_Val_Tab
--   Returns the code part values in a table that is indexed by the code part letters A-J
@UncheckedAccess
FUNCTION Get_Code_Part_Val_Tab  (
   codestring_rec_      IN CodestrRec) RETURN Code_part_value_tab
IS
   tab_  Accounting_Codestr_API.Code_part_value_tab;
BEGIN
   FOR i_ IN 1..10 LOOP
      -- A = CHR(65)
      tab_(CHR(64+i_)) := Get_Rec_Value_For_Code_Part(codestring_rec_, CHR(64+i_)) ;
   END LOOP;
   RETURN tab_;
END Get_Code_Part_Val_Tab;


-- Set_Code_Part_Val_Tab
--   Set the code part values (code part A-J) in Code_part_value_tab to the codestring_rec
@UncheckedAccess
PROCEDURE Set_Code_Part_Val_Tab  (
   codestring_rec_      IN OUT CodestrRec,
   code_part_value_tab_ IN Code_part_value_tab)
IS   
   code_part_  VARCHAR2(1);
BEGIN
   FOR i_ IN 1..10 LOOP
      -- A = CHR(65)
      code_part_ := CHR(64+i_);
      IF (code_part_value_tab_.exists(code_part_)) THEN
         Set_Code_Part_Val_In_Rec(codestring_rec_, code_part_, code_part_value_tab_(code_part_));      
      END IF;
   END LOOP;   
END Set_Code_Part_Val_Tab;



-- Set_Code_Part_Val_In_Rec
--   Set value_ to the code part in the codestring record based the parameter code_part_
--   E.g. passing <value_='TEST'> <code_part_='B'> will set codestring_rec_.code_b='TEST'
@UncheckedAccess
PROCEDURE Set_Code_Part_Val_In_Rec  (
   codestring_rec_      IN OUT CodestrRec,
   code_part_           IN VARCHAR2,
   value_               IN VARCHAR2)
IS
BEGIN
   IF code_part_ = 'A' THEN
      codestring_rec_.code_a := value_;
   ELSIF code_part_ = 'B' THEN
      codestring_rec_.code_b := value_;
   ELSIF code_part_ = 'C' THEN
      codestring_rec_.code_c := value_;
   ELSIF code_part_ = 'D' THEN
      codestring_rec_.code_d := value_;
   ELSIF code_part_ = 'E' THEN
      codestring_rec_.code_e := value_;
   ELSIF code_part_ = 'F' THEN
      codestring_rec_.code_f := value_;
   ELSIF code_part_ = 'G' THEN
      codestring_rec_.code_g := value_;
   ELSIF code_part_ = 'H' THEN
      codestring_rec_.code_h := value_;
   ELSIF code_part_ = 'I' THEN
      codestring_rec_.code_i := value_;
   ELSIF code_part_ = 'J' THEN
      codestring_rec_.code_j := value_;
   END IF;
END Set_Code_Part_Val_In_Rec;


-- Get_Rec_Value_For_Code_P_Func
--   Returns the value for a given code part function for a given company from the codestring record
@UncheckedAccess
FUNCTION Get_Rec_Value_For_Code_P_Func (
   codestring_rec_      IN    CodestrRec,
   company_             IN    VARCHAR2,
   code_part_func_      IN    VARCHAR2) RETURN VARCHAR2
IS
   function_mapped_code_prts_   Accounting_Codestr_API.FuncMappedCodePrtsType := Accounting_Code_Part_Util_API.Get_Functn_Mapped_Code_Parts(company_);
BEGIN
   IF (NOT function_mapped_code_prts_.EXISTS(code_part_func_)) THEN
      RETURN NULL;
   END IF;
   RETURN Get_Rec_Value_For_Code_Part(codestring_rec_,
                                      function_mapped_code_prts_(code_part_func_));
END Get_Rec_Value_For_Code_P_Func;



-- Get_Value_For_Code_Part_Func
--   Returns the value for a given code part function e.g. PRACC in a company from the supplied codestring values
@UncheckedAccess
FUNCTION Get_Value_For_Code_Part_Func (
   company_                   IN    VARCHAR2,
   code_a_value_              IN    VARCHAR2,
   code_b_value_              IN    VARCHAR2,
   code_c_value_              IN    VARCHAR2,
   code_d_value_              IN    VARCHAR2,
   code_e_value_              IN    VARCHAR2,
   code_f_value_              IN    VARCHAR2,
   code_g_value_              IN    VARCHAR2,
   code_h_value_              IN    VARCHAR2,
   code_i_value_              IN    VARCHAR2,
   code_j_value_              IN    VARCHAR2,
   code_part_func_            IN    VARCHAR2) RETURN VARCHAR2
IS
   function_mapped_code_prts_   Accounting_Codestr_API.FuncMappedCodePrtsType := Accounting_Code_Part_Util_API.Get_Functn_Mapped_Code_Parts(company_);
BEGIN
   IF (NOT function_mapped_code_prts_.EXISTS(code_part_func_)) THEN
      RETURN NULL;
   END IF;
   RETURN Get_Value_For_Code_Part(code_a_value_,
                                  code_b_value_,
                                  code_c_value_,
                                  code_d_value_,
                                  code_e_value_,
                                  code_f_value_,
                                  code_g_value_,
                                  code_h_value_,
                                  code_i_value_,
                                  code_j_value_,
                                  function_mapped_code_prts_(code_part_func_));
END Get_Value_For_Code_Part_Func;

PROCEDURE Validate_Codepart (
   company_        IN VARCHAR2,
   codevalue_      IN VARCHAR2,
   code_part_      IN VARCHAR2,
   from_date_      IN DATE,
   untill_date_    IN DATE)
IS
   no_code_part               EXCEPTION;
BEGIN
   IF (ASCII(code_part_) BETWEEN 65 AND 74) THEN
      IF (NOT Accounting_Code_Part_Value_API.Validate_Code_Part (company_,code_part_,codevalue_,from_date_,untill_date_,'FALSE')) THEN
         Raise_Code_Part_Not_Found___(company_ ,
                                      code_part_ ,
                                      codevalue_,
                                      TRUE);
      END IF;
   ELSE
      RAISE no_code_part;
   END IF;
EXCEPTION 
   WHEN no_code_part THEN
        Error_SYS.appl_general(lu_name_,'INVCODEPART: Invalid code part :P1 is given.', code_part_ );
END Validate_Codepart;

-- Codestring_Handling
--   Function for handling generic codestring handling for the Aurena client
--   The company, codepart and codestring is sent in to the function and the output is returned in Codestring_Handling_Rec
--   If the codestring completion has changed any of the input values of the codestring it is returned in the
--   attributes starting with "modified" and the attribute "modified_code_string" is set to TRUE. This
--   so that cilent can prompt the user with a question to either keep the input data or use the modified code string
--   generated by the codestring completetion.
--   If the codestring completion does not change (only add) any of the codestring values the "modified_code_string" is set
--   to FALSE and the values of the codestring is set in the ordinary attributes in the record (code_a, code_b etc.).
--   account_only_ parameter is to be used when the method should only consider codestring completion for accounts and not the combination
--   of pseudo codes and account in code_a_ parameter.
--   The attr_ parameter is to be able to pass more information without the need of changing the interface.
FUNCTION Codestring_Handling(
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_a_              IN VARCHAR2,
   code_b_              IN VARCHAR2,
   code_c_              IN VARCHAR2,
   code_d_              IN VARCHAR2,
   code_e_              IN VARCHAR2,
   code_f_              IN VARCHAR2,
   code_g_              IN VARCHAR2,
   code_h_              IN VARCHAR2,
   code_i_              IN VARCHAR2,
   code_j_              IN VARCHAR2,
   process_code_        IN VARCHAR2,
   quantity_            IN NUMBER,
   text_                IN VARCHAR2,
   project_activity_id_ IN NUMBER,
   required_string_     IN VARCHAR2,
   account_only_        IN VARCHAR2 DEFAULT 'FALSE',
   attr_                IN VARCHAR2 DEFAULT NULL) RETURN Codestring_Handling_Rec
IS    
   return_rec_                   Codestring_Handling_Rec;
   is_account_                   BOOLEAN := FALSE;
BEGIN
   IF (Nvl(account_only_, 'FALSE') = 'TRUE') THEN
      is_account_ := TRUE;
   END IF;
   return_rec_ := Codestring_Handling___(company_,
                                         code_part_,
                                         code_a_,
                                         code_b_,
                                         code_c_,
                                         code_d_,
                                         code_e_,
                                         code_f_,
                                         code_g_,
                                         code_h_,
                                         code_i_,
                                         code_j_,
                                         process_code_,
                                         quantity_,
                                         text_,
                                         project_activity_id_,
                                         required_string_,
                                         is_account_,
                                         FALSE);   
   
   RETURN return_rec_;
END Codestring_Handling;   

-- Codestring_Handling_Budget
--   Function for handling generic codestring handling pages using budget for the Aurena client 
--   See method documentation as for Codestring_Handling but with the difference that is used for pages working with budget (budget code part demands)
FUNCTION Codestring_Handling_Budget(
   company_             IN VARCHAR2,
   ledger_id_           IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_a_              IN VARCHAR2,
   code_b_              IN VARCHAR2,
   code_c_              IN VARCHAR2,
   code_d_              IN VARCHAR2,
   code_e_              IN VARCHAR2,
   code_f_              IN VARCHAR2,
   code_g_              IN VARCHAR2,
   code_h_              IN VARCHAR2,
   code_i_              IN VARCHAR2,
   code_j_              IN VARCHAR2,
   process_code_        IN VARCHAR2,
   quantity_            IN NUMBER,
   text_                IN VARCHAR2,
   project_activity_id_ IN NUMBER,
   required_string_     IN VARCHAR2,
   account_only_        IN VARCHAR2 DEFAULT 'FALSE',
   budget_source_       IN BOOLEAN  DEFAULT TRUE) RETURN Codestring_Handling_Rec
IS    
   return_rec_                   Codestring_Handling_Rec;
   is_account_                   BOOLEAN := FALSE;
BEGIN
   IF (Nvl(account_only_, 'FALSE') = 'TRUE') THEN
      is_account_ := TRUE;
   END IF;
   return_rec_ := Codestring_Handling___(company_,
                                         code_part_,
                                         code_a_,
                                         code_b_,
                                         code_c_,
                                         code_d_,
                                         code_e_,
                                         code_f_,
                                         code_g_,
                                         code_h_,
                                         code_i_,
                                         code_j_,
                                         process_code_,
                                         quantity_,
                                         text_,
                                         project_activity_id_,
                                         required_string_,
                                         is_account_,
                                         budget_source_,
                                         ledger_id_);      
                                         
   Remove_Unused_Il_Codeparts___(return_rec_, ledger_id_);
   RETURN return_rec_;
END Codestring_Handling_Budget;   



FUNCTION Codestring_Budget_Demand_Only(
   company_             IN VARCHAR2,
   ledger_id_           IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_a_              IN VARCHAR2,
   code_b_              IN VARCHAR2,
   code_c_              IN VARCHAR2,
   code_d_              IN VARCHAR2,
   code_e_              IN VARCHAR2,
   code_f_              IN VARCHAR2,
   code_g_              IN VARCHAR2,
   code_h_              IN VARCHAR2,
   code_i_              IN VARCHAR2,
   code_j_              IN VARCHAR2,
   required_string_     IN VARCHAR2) RETURN Codestring_Handling_Rec
IS    
   return_rec_          Codestring_Handling_Rec;   
BEGIN
   
   return_rec_.required_string := Account_API.Get_Req_Budget_Code_Part_List(company_, code_a_);
   
   return_rec_.company := company_;
   return_rec_.code_a := code_a_;
   return_rec_.code_b := code_b_;
   return_rec_.code_c := code_c_;
   return_rec_.code_d := code_d_;
   return_rec_.code_e := code_e_;
   return_rec_.code_f := code_f_;
   return_rec_.code_g := code_g_;
   return_rec_.code_h := code_h_;
   return_rec_.code_i := code_i_;
   return_rec_.code_j := code_j_;     

   IF (ledger_id_ IN ('00')) THEN
      Remove_Blocked_Codeparts___(return_rec_);
   ELSE
      Remove_Unused_Il_Codeparts___(return_rec_, ledger_id_);
   END IF;
   RETURN return_rec_;
END Codestring_Budget_Demand_Only;   

@UncheckedAccess
FUNCTION Get_Ledger_Code_Part_Used_List (
   company_       IN VARCHAR2,
   ledger_id_     IN VARCHAR2  ) RETURN VARCHAR2
IS
   CURSOR get_code_part_used IS
      SELECT code_part_used
      FROM accounting_code_part_tab 
      WHERE company = company_
      AND code_part BETWEEN 'B' AND 'J'
      ORDER BY code_part;
       
   blocked_code_parts_ VARCHAR2(20);
   temp_ledger_id_   VARCHAR2(20) := Nvl(ledger_id_, '00');
BEGIN
   IF temp_ledger_id_ IN ('*', '00') THEN
      FOR rec_ IN get_code_part_used LOOP
         blocked_code_parts_ := blocked_code_parts_ || rec_.code_part_used;      
      END LOOP;
   ELSE
      $IF (Component_Intled_SYS.INSTALLED) $THEN
         blocked_code_parts_ := Internal_Code_Parts_API.Get_Code_Part_Used_List(company_, temp_ledger_id_);
      $ELSE
         blocked_code_parts_ := NULL;
      $END        
   END IF;
  
   RETURN blocked_code_parts_;
END Get_Ledger_Code_Part_Used_List;

PROCEDURE Remove_Blocked_Codeparts___(
   return_rec_    IN OUT Codestring_Handling_Rec)
IS
   code_part_demand_       VARCHAR2(1);
   index_                  NUMBER := 1;
BEGIN    
   -- check if code part B-J is blocked and if so remove the code part value for those code parts.
   FOR i_ IN 1..9 LOOP
      code_part_demand_ := Substr(return_rec_.required_string, index_, 1);
      IF (code_part_demand_ = 'S') THEN
         IF (i_ = 1) THEN
            return_rec_.code_b := NULL;
         ELSIF (i_ = 2) THEN
            return_rec_.code_c := NULL;            
         ELSIF (i_ = 3) THEN
            return_rec_.code_d := NULL;            
         ELSIF (i_ = 4) THEN
            return_rec_.code_e := NULL;            
         ELSIF (i_ = 5) THEN
            return_rec_.code_f := NULL;            
         ELSIF (i_ = 6) THEN
            return_rec_.code_g := NULL;            
         ELSIF (i_ = 7) THEN
            return_rec_.code_h := NULL;            
         ELSIF (i_ = 8) THEN
            return_rec_.code_i := NULL;            
         ELSIF (i_ = 9) THEN
            return_rec_.code_j := NULL;                        
         END IF;
      END IF;      
      index_ := index_ + 2;
   END LOOP;
END Remove_Blocked_Codeparts___;   

FUNCTION Codestring_Handling___(
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_a_              IN VARCHAR2,
   code_b_              IN VARCHAR2,
   code_c_              IN VARCHAR2,
   code_d_              IN VARCHAR2,
   code_e_              IN VARCHAR2,
   code_f_              IN VARCHAR2,
   code_g_              IN VARCHAR2,
   code_h_              IN VARCHAR2,
   code_i_              IN VARCHAR2,
   code_j_              IN VARCHAR2,
   process_code_        IN VARCHAR2,
   quantity_            IN NUMBER,
   text_                IN VARCHAR2,
   project_activity_id_ IN NUMBER,
   required_string_     IN VARCHAR2,
   account_only_        IN BOOLEAN DEFAULT FALSE,
   budget_source_       IN BOOLEAN DEFAULT FALSE,
   ledger_id_           IN VARCHAR2 DEFAULT '00') RETURN Codestring_Handling_Rec
IS 
   temp_rec_                     Codepart_Completion_Rec;
   temp_rec2_                    Codepart_Completion_Rec;   
   return_rec_                   Codestring_Handling_Rec;
   code_part_val_rec_            CodestrRec;   
   modified_code_string_         VARCHAR2(5) := 'FALSE';   
   dummy_string_                 CONSTANT VARCHAR2(20) := '###$$$###';
   proj_id_                      VARCHAR2(20);
   input_proj_id_                VARCHAR2(20);
   proj_activity_rec_            Project_Activity_Rec;
   modified_proj_id_             VARCHAR2(100);
   modified_proj_activity_rec_   Project_Activity_Rec;
   account_                      VARCHAR2(20);
   is_account_                   BOOLEAN := Nvl(account_only_, FALSE);
   is_budget_source_             BOOLEAN := Nvl(budget_source_, FALSE);
   proj_code_part_               VARCHAR2(1) := Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_, 'PRACC');   
   code_part_char_               VARCHAR2(1) := code_part_;
   
   FUNCTION Get_Required_Code_Part_List___(
      company_       IN VARCHAR2,
      account_       IN VARCHAR2,
      budget_source_ IN BOOLEAN) RETURN VARCHAR2
   IS
      demand_type_      VARCHAR2(20);
      list_             VARCHAR2(2000) := 'K;K;K;K;K;K;K;K;K;K;K;K;';
   BEGIN      
      IF (budget_source_) THEN
         $IF Component_Intled_SYS.INSTALLED $THEN
            IF (ledger_id_ != '00') THEN 
               demand_type_ := Internal_Ledger_API.Get_Code_Part_Demands_Db(company_,ledger_id_);
               IF demand_type_ NOT IN ('BUDGET_ONLY','VOUCHER_AND_BUDGET') THEN
                  RETURN list_;
               END IF;
            END IF;
         $END         
         RETURN Account_API.Get_Req_Budget_Code_Part_List(company_, account_);
      ELSE
         RETURN Account_API.Get_Required_Code_Part_List(company_, account_);
      END IF;
   END Get_Required_Code_Part_List___;
   
   FUNCTION Validate_Project_Enabled___(
      company_            IN VARCHAR2,
      code_part_value_    IN VARCHAR2 ) RETURN Project_Activity_Rec
   IS   
      tmp_project_activity_id_enabled_ VARCHAR2(1);
      tmp_pca_ext_project_             VARCHAR2(2000);
      tmp_project_origin_              VARCHAR2(2000);
      tmp_project_activity_id_         NUMBER;
      project_activity_struct_rec_     Project_Activity_Rec;
      function_group_                  VARCHAR2(10); -- not implemented yet, will perhaps only be needed for Voucher Row Posting (Voucher Entry)
   BEGIN      
      $IF (Component_Genled_SYS.INSTALLED) $THEN
         tmp_project_activity_id_enabled_ := Accounting_Project_API.Get_Externally_Created(company_, code_part_value_);
        -- tmp_pca_ext_project_ := Voucher_Row_API.Get_Pca_Ext_Project(company_);
         tmp_project_origin_ := Accounting_Project_API.Get_Project_Origin_Db(company_, code_part_value_);
      $ELSE
         tmp_project_activity_id_enabled_ := 'Y';
      $END   
      IF (tmp_project_origin_ = 'FINPROJECT') THEN
         tmp_project_activity_id_enabled_ := 'N';
         tmp_project_activity_id_ := NULL;
      ELSIF (tmp_project_origin_ = 'JOB') THEN
         tmp_project_activity_id_enabled_ := 'N';
         tmp_project_activity_id_ := 0;
      ELSIF (function_group_ = 'Z') THEN
         IF (tmp_pca_ext_project_ = 'FALSE' AND code_part_value_ IS NOT NULL) THEN
            Error_SYS.Record_General(lu_name_, 'PCANOTALLOWED: PCA not allowed for External Projects in Company :P1', company_);
         END IF;
         tmp_project_activity_id_enabled_ := 'N';
         tmp_project_activity_id_ := NULL;
      ELSE
         tmp_project_activity_id_ := NULL;
      END IF;   
      project_activity_struct_rec_.project_activity_id_enable := tmp_project_activity_id_enabled_;
      project_activity_struct_rec_.project_activity_id := tmp_project_activity_id_;
      RETURN project_activity_struct_rec_;
   END Validate_Project_Enabled___;   

   PROCEDURE Remove_Blocked_Codeparts___(
      return_rec_    IN OUT Codestring_Handling_Rec,
      mode_          IN VARCHAR2)
   IS
      code_part_demand_       VARCHAR2(1);
      index_                  NUMBER := 1;
      temp_required_str_      VARCHAR2(4000);
      mod_codestring_rec_     BOOLEAN := FALSE;
      start_                  NUMBER := 1;
      end_                    NUMBER := 2;
   BEGIN    
      IF (mode_ = 'MODIFIED') THEN 
         start_ := 2;
         end_ := 2;
      ELSIF (mode_ = 'ORIGINAL') THEN 
         start_ := 1;
         end_ := 1;
      ELSE 
         start_ := 1;
         end_ := 2;
      END IF;         
      -- check if code part B-J is blocked and if so remove the code part value for those code parts.
      FOR a_ IN start_..end_ LOOP
         index_ := 1;         
         IF (a_ = 2) THEN
            mod_codestring_rec_ := TRUE;
            temp_required_str_ := return_rec_.modified_required_string;
         ELSE            
            temp_required_str_ := return_rec_.required_string;
         END IF;         
         FOR i_ IN 1..9 LOOP                        
            code_part_demand_ := Substr(temp_required_str_, index_, 1);
            IF (code_part_demand_ = 'S') THEN
               IF (mod_codestring_rec_) THEN               
                  IF (i_ = 1) THEN
                     return_rec_.modified_code_b := NULL;
                  ELSIF (i_ = 2) THEN
                     return_rec_.modified_code_c := NULL;            
                  ELSIF (i_ = 3) THEN
                     return_rec_.modified_code_d := NULL;            
                  ELSIF (i_ = 4) THEN
                     return_rec_.modified_code_e := NULL;            
                  ELSIF (i_ = 5) THEN
                     return_rec_.modified_code_f := NULL;         
                  ELSIF (i_ = 6) THEN
                     return_rec_.modified_code_g := NULL;         
                  ELSIF (i_ = 7) THEN
                     return_rec_.modified_code_h := NULL;         
                  ELSIF (i_ = 8) THEN
                     return_rec_.modified_code_i := NULL;            
                  ELSIF (i_ = 9) THEN
                     return_rec_.modified_code_j := NULL;         
                  END IF;
               ELSE
                  IF (i_ = 1) THEN
                     return_rec_.code_b := NULL;
                  ELSIF (i_ = 2) THEN
                     return_rec_.code_c := NULL;            
                  ELSIF (i_ = 3) THEN
                     return_rec_.code_d := NULL;            
                  ELSIF (i_ = 4) THEN
                     return_rec_.code_e := NULL;            
                  ELSIF (i_ = 5) THEN
                     return_rec_.code_f := NULL;         
                  ELSIF (i_ = 6) THEN
                     return_rec_.code_g := NULL;         
                  ELSIF (i_ = 7) THEN
                     return_rec_.code_h := NULL;         
                  ELSIF (i_ = 8) THEN
                     return_rec_.code_i := NULL;            
                  ELSIF (i_ = 9) THEN
                     return_rec_.code_j := NULL;         
                  END IF;               
               END IF;
            END IF;      
            index_ := index_ + 2;
         END LOOP;
      END LOOP;
   END Remove_Blocked_Codeparts___;
BEGIN   
   return_rec_.company := company_;
   return_rec_.code_a := code_a_;
   return_rec_.code_b := code_b_;
   return_rec_.code_c := code_c_;
   return_rec_.code_d := code_d_;
   return_rec_.code_e := code_e_;
   return_rec_.code_f := code_f_;
   return_rec_.code_g := code_g_;
   return_rec_.code_h := code_h_;
   return_rec_.code_i := code_i_;
   return_rec_.code_j := code_j_;   
   return_rec_.process_code := process_code_;
   return_rec_.quantity := quantity_;
   return_rec_.text := text_;
   return_rec_.project_activity_id := project_activity_id_;
   
   -- store input project id
   input_proj_id_ := Accounting_Codestr_API.Get_Value_For_Code_Part_Func(company_,
                                                                         return_rec_.code_a,
                                                                         return_rec_.code_b,
                                                                         return_rec_.code_c,
                                                                         return_rec_.code_d,
                                                                         return_rec_.code_e,
                                                                         return_rec_.code_f,
                                                                         return_rec_.code_g,
                                                                         return_rec_.code_h,
                                                                         return_rec_.code_i,
                                                                         return_rec_.code_j,
                                                                         'PRACC');      
   input_proj_id_ := Nvl(input_proj_id_, dummy_string_);
   
   temp_rec_ := Validate_Code_Part___(company_,
                                      code_part_,
                                      return_rec_.code_a,
                                      return_rec_.code_b,
                                      return_rec_.code_c,
                                      return_rec_.code_d,
                                      return_rec_.code_e,
                                      return_rec_.code_f,
                                      return_rec_.code_g,
                                      return_rec_.code_h,
                                      return_rec_.code_i,
                                      return_rec_.code_j,
                                      process_code_,
                                      quantity_,
                                      text_,
                                      required_string_,
                                      is_budget_source_,
                                      is_account_);      
   --Check if Codestring completion exists for the given code part and code part value   
   IF (temp_rec_.completion_attr IS NOT NULL) THEN
      -- fetch new code part demands
      account_ := Client_SYS.Get_Item_Value('ACCOUNT', temp_rec_.completion_attr);      
      IF (account_ IS NOT NULL) THEN         
         return_rec_.required_string := Get_Required_Code_Part_List___(company_, account_, is_budget_source_);
      ELSE         
         return_rec_.required_string := Get_Required_Code_Part_List___(company_, code_a_, is_budget_source_);
      END IF;     
      temp_rec_.required_string := return_rec_.required_string;
      -- Codestring completion exists for the given code part and code part value
      temp_rec2_ := Scan_Attribute_String___(company_, 
                                             temp_rec_.completion_attr, 
                                             temp_rec_.required_string, 
                                             temp_rec_.req_string_complete, 
                                             temp_rec_.is_pseudo_code);
      
      IF (temp_rec2_.modified_code_string) THEN               
         -- modifys the existing code string, user need to confirm changes.
         modified_code_string_ := 'TRUE';

         code_part_val_rec_ := Attr_To_Code_Part_Rec___(temp_rec2_.req_string_complete);
         
         return_rec_.modified_code_a := code_part_val_rec_.code_a;
         return_rec_.modified_code_b := code_part_val_rec_.code_b;
         return_rec_.modified_code_c := code_part_val_rec_.code_c;
         return_rec_.modified_code_d := code_part_val_rec_.code_d;
         return_rec_.modified_code_e := code_part_val_rec_.code_e;
         return_rec_.modified_code_f := code_part_val_rec_.code_f;
         return_rec_.modified_code_g := code_part_val_rec_.code_g;
         return_rec_.modified_code_h := code_part_val_rec_.code_h;
         return_rec_.modified_code_i := code_part_val_rec_.code_i;
         return_rec_.modified_code_j := code_part_val_rec_.code_j;
         return_rec_.modified_process_code := code_part_val_rec_.process_code;
         return_rec_.modified_quantity := code_part_val_rec_.quantity;
         return_rec_.modified_text := code_part_val_rec_.text;
         return_rec_.modified_project_activity_id := code_part_val_rec_.project_activity_id;             
         
         return_rec_.modified_required_string := Get_Required_Code_Part_List___(company_, return_rec_.modified_code_a, is_budget_source_);
         
         -- Remove blocked code_parts for modfied string
         Remove_Blocked_Codeparts___(return_rec_, 'MODIFIED');

         modified_proj_id_ := Accounting_Codestr_API.Get_Value_For_Code_Part_Func(company_,
                                                                                  return_rec_.modified_code_a,
                                                                                  return_rec_.modified_code_b,
                                                                                  return_rec_.modified_code_c,
                                                                                  return_rec_.modified_code_d,
                                                                                  return_rec_.modified_code_e,
                                                                                  return_rec_.modified_code_f,
                                                                                  return_rec_.modified_code_g,
                                                                                  return_rec_.modified_code_h,
                                                                                  return_rec_.modified_code_i,
                                                                                  return_rec_.modified_code_j,
                                                                                  'PRACC');   
         modified_proj_activity_rec_ := Validate_Project_Enabled___(company_, modified_proj_id_);  
         
         return_rec_.modified_project_id := modified_proj_id_;                  
         -- When code_part_char_ is the code part for project then always set project_activity_id_, if the project id is changed 
         -- then set project_activity_id, if it is a pseudo code use value fetch from the pseudo else keep the old value            
         IF (code_part_char_ = proj_code_part_) THEN
            return_rec_.modified_project_activity_id := modified_proj_activity_rec_.project_activity_id;              
         ELSIF (input_proj_id_ != NVL(modified_proj_id_, dummy_string_) ) THEN
            return_rec_.modified_project_activity_id := modified_proj_activity_rec_.project_activity_id;
         ELSE            
            modified_proj_activity_rec_ := Validate_Project_Enabled___(company_, input_proj_id_);
            return_rec_.modified_project_activity_id := project_activity_id_;                  
         END IF;
         return_rec_.modified_required_string := return_rec_.modified_required_string || modified_proj_activity_rec_.project_activity_id_enable || ';';                  
      ELSE
         -- codestring completion will not change any input value from the user or it is a pseudo code 
         -- that is allowed to change the input values without asking the user.
         temp_rec_.req_string_complete := temp_rec2_.req_string_complete;
      END IF;
      code_part_val_rec_ := Attr_To_Code_Part_Rec___(temp_rec_.req_string_complete);
      return_rec_.code_a := code_part_val_rec_.code_a;
      return_rec_.code_b := code_part_val_rec_.code_b;
      return_rec_.code_c := code_part_val_rec_.code_c;
      return_rec_.code_d := code_part_val_rec_.code_d;
      return_rec_.code_e := code_part_val_rec_.code_e;
      return_rec_.code_f := code_part_val_rec_.code_f;
      return_rec_.code_g := code_part_val_rec_.code_g;
      return_rec_.code_h := code_part_val_rec_.code_h;
      return_rec_.code_i := code_part_val_rec_.code_i;
      return_rec_.code_j := code_part_val_rec_.code_j;
      return_rec_.process_code := code_part_val_rec_.process_code;
      return_rec_.quantity := code_part_val_rec_.quantity;
      return_rec_.text := code_part_val_rec_.text;
      return_rec_.project_activity_id := code_part_val_rec_.project_activity_id;
   ELSE
      --return_rec_.required_string := Account_API.Get_Required_Code_Part_List(company_, return_rec_.code_a);
      return_rec_.required_string := Get_Required_Code_Part_List___(company_, return_rec_.code_a, is_budget_source_);
      -- No Codestring completion exists for the given code part and code part value
      return_rec_.code_a := code_a_;
      return_rec_.code_b := code_b_;
      return_rec_.code_c := code_c_;
      return_rec_.code_d := code_d_;
      return_rec_.code_e := code_e_;
      return_rec_.code_f := code_f_;
      return_rec_.code_g := code_g_;
      return_rec_.code_h := code_h_;
      return_rec_.code_i := code_i_;
      return_rec_.code_j := code_j_;   
      return_rec_.process_code := process_code_;
      return_rec_.quantity := quantity_;
      return_rec_.text := text_;      
      return_rec_.project_activity_id := project_activity_id_;
   END IF;
   -- Set the required string for the input account
   IF (return_rec_.code_a IS NOT NULL) THEN
      --return_rec_.required_string := Account_API.Get_Required_Code_Part_List(company_, return_rec_.code_a);
      return_rec_.required_string := Get_Required_Code_Part_List___(company_, return_rec_.code_a, is_budget_source_);
   END IF;   
   
   -- remove any values for code parts that are blocked in the ordinary codestring 
   -- attributes (return_rec_.code_b and not modified_code_b for example) codestring attributes
   Remove_Blocked_Codeparts___(return_rec_, 'ORIGINAL');         
   
   return_rec_.modified_code_string := modified_code_string_; 
   
   proj_id_ := Accounting_Codestr_API.Get_Value_For_Code_Part_Func(company_,
                                                                   return_rec_.code_a,
                                                                   return_rec_.code_b,
                                                                   return_rec_.code_c,
                                                                   return_rec_.code_d,
                                                                   return_rec_.code_e,
                                                                   return_rec_.code_f,
                                                                   return_rec_.code_g,
                                                                   return_rec_.code_h,
                                                                   return_rec_.code_i,
                                                                   return_rec_.code_j,
                                                                   'PRACC');
   proj_activity_rec_ := Validate_Project_Enabled___(company_, proj_id_);   
   return_rec_.project_id := proj_id_;   

   -- When code_part_char_ is the code part for project then always set project_activity_id_, if the project id is changed 
   -- then set project_activity_id, if it is a pseudo code use value fetch from the pseudo else keep the old value   
   IF (code_part_char_ = proj_code_part_) THEN
      return_rec_.project_activity_id := proj_activity_rec_.project_activity_id;       
   ELSIF (temp_rec_.is_pseudo_code = 'TRUE') THEN
      -- use the value from pseudo code setting
      NULL;
   ELSIF (input_proj_id_ != NVL(proj_id_, dummy_string_) ) THEN
      return_rec_.project_activity_id := proj_activity_rec_.project_activity_id;            
   ELSE      
      proj_activity_rec_ := Validate_Project_Enabled___(company_, input_proj_id_);
      return_rec_.project_activity_id := project_activity_id_;      
   END IF;   
   
   return_rec_.required_string := return_rec_.required_string || proj_activity_rec_.project_activity_id_enable || ';' ;   
   RETURN return_rec_;
END Codestring_Handling___;   


FUNCTION Validate_Code_Part___(
   company_            IN VARCHAR2,
   code_part_          IN VARCHAR2,
   code_a_value_       IN VARCHAR2,
   code_b_value_       IN VARCHAR2,
   code_c_value_       IN VARCHAR2,
   code_d_value_       IN VARCHAR2,
   code_e_value_       IN VARCHAR2,
   code_f_value_       IN VARCHAR2,
   code_g_value_       IN VARCHAR2,
   code_h_value_       IN VARCHAR2,
   code_i_value_       IN VARCHAR2,
   code_j_value_       IN VARCHAR2,
   process_code_value_ IN VARCHAR2,
   quantity_value_     IN NUMBER,
   text_value_         IN VARCHAR2,
   required_string_    IN VARCHAR2,
   is_budget_source_   IN BOOLEAN,
   is_account_         IN BOOLEAN) RETURN Codepart_Completion_Rec
IS
   this_code_part_value_         VARCHAR2(20);
   local_required_string_        VARCHAR2(2000) := required_string_;
   req_string_complete_          VARCHAR2(2000);
   completion_attr_              VARCHAR2(2000);
   is_pseudo_code_               VARCHAR2(5) := 'FALSE';
   c_p_completion_structure_rec_ Codepart_Completion_Rec;
   is_code_parts_null_           BOOLEAN;
BEGIN
   this_code_part_value_ := Get_Value_For_Code_Part(code_a_value_,
                                                    code_b_value_,
                                                    code_c_value_,
                                                    code_d_value_,
                                                    code_e_value_,
                                                    code_f_value_,
                                                    code_g_value_,
                                                    code_h_value_,
                                                    code_i_value_,
                                                    code_j_value_,
                                                    code_part_);
   -- IF wildcards are used in the this_code_part_value_ then do not do anything more.  
   IF (Instr(this_code_part_value_, '%') > 0 OR Instr(this_code_part_value_, '_') > 0 ) THEN
      NULL;
   ELSIF (this_code_part_value_ IS NOT NULL) THEN
      req_string_complete_ := Fetch_Code_Part_To_Attr___(code_a_value_,
                                                         code_b_value_,
                                                         code_c_value_,
                                                         code_d_value_,
                                                         code_e_value_,
                                                         code_f_value_,
                                                         code_g_value_,
                                                         code_h_value_,
                                                         code_i_value_,
                                                         code_j_value_,
                                                         process_code_value_,
                                                         quantity_value_,
                                                         text_value_);
                                                         
      is_code_parts_null_ := (code_a_value_ IS NULL AND 
                              code_b_value_ IS NULL AND 
                              code_c_value_ IS NULL AND 
                              code_d_value_ IS NULL AND 
                              code_e_value_ IS NULL AND 
                              code_f_value_ IS NULL AND 
                              code_g_value_ IS NULL AND 
                              code_h_value_ IS NULL AND 
                              code_i_value_ IS NULL AND 
                              code_j_value_ IS NULL AND 
                              process_code_value_ IS NULL AND 
                              quantity_value_ IS NULL AND 
                              text_value_ IS NULL);
                              
      Validate_Fetch_Completion___(completion_attr_,
                                   is_pseudo_code_,
                                   local_required_string_,
                                   req_string_complete_,                                   
                                   company_,
                                   code_part_,
                                   this_code_part_value_,
                                   is_code_parts_null_,
                                   is_budget_source_,
                                   is_account_);                                          
   END IF;
   c_p_completion_structure_rec_.completion_attr := completion_attr_;
   c_p_completion_structure_rec_.required_string := local_required_string_;
   c_p_completion_structure_rec_.req_string_complete := req_string_complete_;
   c_p_completion_structure_rec_.is_pseudo_code := is_pseudo_code_;
   RETURN c_p_completion_structure_rec_;
END Validate_Code_Part___;
   
FUNCTION Fetch_Code_Part_To_Attr___ (
   code_a_value_       IN VARCHAR2,
   code_b_value_       IN VARCHAR2,
   code_c_value_       IN VARCHAR2,
   code_d_value_       IN VARCHAR2,
   code_e_value_       IN VARCHAR2,
   code_f_value_       IN VARCHAR2,
   code_g_value_       IN VARCHAR2,
   code_h_value_       IN VARCHAR2,
   code_i_value_       IN VARCHAR2,
   code_j_value_       IN VARCHAR2,
   process_code_value_ IN VARCHAR2,
   quantity_value_     IN NUMBER,
   text_value_         IN VARCHAR2 ) RETURN VARCHAR2
IS
   attr_  VARCHAR2(2000);
BEGIN
   Client_SYS.Add_To_Attr('ACCOUNT', code_a_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_B', code_b_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_C', code_c_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_D', code_d_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_E', code_e_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_F', code_f_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_G', code_g_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_H', code_h_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_I', code_i_value_, attr_);
   Client_SYS.Add_To_Attr('CODE_J', code_j_value_, attr_);
   Client_SYS.Add_To_Attr('PROCESS_CODE', process_code_value_, attr_);
   Client_SYS.Add_To_Attr('QUANTITY', quantity_value_, attr_);
   Client_SYS.Add_To_Attr('TEXT', text_value_, attr_);      
   RETURN attr_;
END Fetch_Code_Part_To_Attr___;

PROCEDURE Validate_Fetch_Completion___(
   completion_attr_     OUT VARCHAR2,
   is_pseudo_code_      OUT VARCHAR2,
   required_string_     IN OUT VARCHAR2,
   req_string_complete_ IN OUT VARCHAR2,   
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2,
   is_code_parts_null_  IN BOOLEAN,
   is_budget_source_    IN BOOLEAN,
   is_account_          IN BOOLEAN)
IS   
   temp_attr_           VARCHAR2(2000);   
BEGIN
   IF (code_part_ = 'A') THEN   
      IF (is_budget_source_) THEN
         Account_API.Validate_Bud_Account_Pseudo__(required_string_,
                                                   req_string_complete_, 
                                                   company_,                                                                                                   
                                                   code_part_value_,
																	NULL );
      ELSE
         -- is_account_ is true when used by clients that only handles account and not account in combination with pseudo codes
         IF (is_account_) THEN            
            Account_API.Get_Required_Code_Part(required_string_, company_, code_part_value_);
            Accounting_Codestr_API.Complete_Codestring(req_string_complete_, company_, NULL, NULL, 'A');
         ELSE
            Account_API.Validate_Account_Pseudo__(company_,
                                                  code_part_value_, 
                                                  NULL, 
                                                  required_string_, 
                                                  req_string_complete_);
         END IF;
      END IF;
      
      IF NOT (is_code_parts_null_) THEN
         IF (is_account_) THEN
            is_pseudo_code_ := 'FALSE';
         ELSE
            is_pseudo_code_ := Pseudo_Codes_API.Exist_Pseudo_Code(company_, code_part_value_);
         END IF;
         IF (is_pseudo_code_ = 'FALSE') THEN            
            completion_attr_ := Accounting_Codestr_Compl_API.Get_Complete_CodeString(company_,
                                                                                     code_part_, 
									                                                          code_part_value_);                                                                                                    
         ELSE            
            temp_attr_ := NULL;
            Pseudo_Codes_API.Get_Complete_Pseudo(temp_attr_,
                                                 company_,
                                                 code_part_value_);   
            completion_attr_ := temp_attr_;
         END IF;
      ELSE
         completion_attr_ := req_string_complete_;
      END IF;
   ELSIF (ASCII(code_part_) BETWEEN 66 AND 74) THEN      
      Accounting_Code_Part_Value_API.Exist(company_,
                                           code_part_,
                                           code_part_value_);      
            
      completion_attr_ := Accounting_Codestr_Compl_API.Get_Complete_CodeString(company_,
                                                                               code_part_, 
                                                                               code_part_value_);
   END IF;   
END Validate_Fetch_Completion___;


-- Scan_Attribute_String___
--    function that go through the code string completion attr-string and compare with required string complete
--    when there are different values for the same code part the function will set a flag that the code string completion
--    has modified one or more of the values in the code string.
--    Pseudo codes will always rewrite the whole code string.
--    Blocked code parts will be removed before the code string is returned
FUNCTION Scan_Attribute_String___(
   company_             IN VARCHAR2,
   completion_attr_     IN VARCHAR2,
   required_string_     IN VARCHAR2,
   req_string_complete_ IN VARCHAR2,
   is_pseudo_code_      IN VARCHAR2) RETURN Codepart_Completion_Rec
IS
   temp_completion_attr_         VARCHAR2(2000);
   this_required_string_         VARCHAR2(2000);
   this_req_string_complete_     VARCHAR2(2000);   
   s_tmp_codepart_               VARCHAR2(200);
   s_tmp_value_                  VARCHAR2(200);
   value_in_req_string_          VARCHAR2(100);
   b_pseudo_code_                VARCHAR2(5) := is_pseudo_code_;
   ptr_                          NUMBER;   
   c_p_completion_structure_rec_ Codepart_Completion_Rec;
   modified_code_string_         BOOLEAN := FALSE;
BEGIN
   this_required_string_ := required_string_;
   this_req_string_complete_ := req_string_complete_;
   temp_completion_attr_ := completion_attr_;   
            
   WHILE (Client_SYS.Get_Next_From_Attr(temp_completion_attr_, ptr_, s_tmp_codepart_, s_tmp_value_)) LOOP      
      IF (s_tmp_value_ IS NOT NULL) THEN
         value_in_req_string_ := Client_SYS.Get_Item_Value(s_tmp_codepart_, this_req_string_complete_);                  
         IF (value_in_req_string_ IS NULL) THEN
            IF (s_tmp_codepart_ = 'ACCOUNT') THEN
               Account_API.Get_Required_Code_Part_Pseudo(this_required_string_,
                                                         company_,
                                                         s_tmp_value_);
            END IF;
            this_req_string_complete_ := Modify_Required_String___(s_tmp_codepart_, s_tmp_value_, this_req_string_complete_);
         ELSIF (s_tmp_codepart_ = 'ACCOUNT' AND b_pseudo_code_ = 'TRUE') THEN
            b_pseudo_code_:= 'FALSE';
            this_req_string_complete_ := Modify_Required_String___(s_tmp_codepart_, s_tmp_value_, this_req_string_complete_);
         ELSE
            IF (value_in_req_string_ != s_tmp_value_) THEN
               -- The input code string has been modified by the code string completion, user will be prompted what to do.
               modified_code_string_ := TRUE;               
            END IF;
            IF (s_tmp_codepart_ = 'ACCOUNT') THEN
               Account_API.Get_Required_Code_Part_Pseudo(this_required_string_,
                                                         company_,
                                                         s_tmp_value_);
            END IF;
            this_req_string_complete_ := Modify_Required_String___(s_tmp_codepart_, s_tmp_value_, this_req_string_complete_);
         END IF;
      END IF;
      s_tmp_value_ := Client_SYS.Cut_Item_Value(s_tmp_codepart_, temp_completion_attr_);
      ptr_ := NULL;
   END LOOP;   
   c_p_completion_structure_rec_.required_string := this_required_string_;
   c_p_completion_structure_rec_.req_string_complete := this_req_string_complete_;
   c_p_completion_structure_rec_.completion_attr := temp_completion_attr_;
   c_p_completion_structure_rec_.is_pseudo_code := b_pseudo_code_;   
   c_p_completion_structure_rec_.modified_code_string := modified_code_string_;   
   RETURN c_p_completion_structure_rec_;
END Scan_Attribute_String___;


FUNCTION Modify_Required_String___(
   code_part_                 IN VARCHAR2,
   code_part_value_           IN VARCHAR2,
   required_string_complete_  IN VARCHAR2) RETURN VARCHAR2 
IS
   local_required_string_complete_  VARCHAR2(2000);   
BEGIN
   local_required_string_complete_ := required_string_complete_;
   IF (Client_SYS.Item_Exist(code_part_, local_required_string_complete_)) THEN
      Client_SYS.Set_Item_Value(code_part_, code_part_value_, local_required_string_complete_);
   END IF;
   RETURN local_required_string_complete_;
END Modify_Required_String___;


FUNCTION Attr_To_Code_Part_Rec___(
   req_string_complete_ VARCHAR2) RETURN CodestrRec
IS
   code_part_val_structure_rec_ CodestrRec;
BEGIN
   code_part_val_structure_rec_.code_a := Client_SYS.Get_Item_Value('ACCOUNT', req_string_complete_);
   code_part_val_structure_rec_.code_b := Client_SYS.Get_Item_Value('CODE_B', req_string_complete_);
   code_part_val_structure_rec_.code_c := Client_SYS.Get_Item_Value('CODE_C', req_string_complete_);
   code_part_val_structure_rec_.code_d := Client_SYS.Get_Item_Value('CODE_D', req_string_complete_);
   code_part_val_structure_rec_.code_e := Client_SYS.Get_Item_Value('CODE_E', req_string_complete_);
   code_part_val_structure_rec_.code_f := Client_SYS.Get_Item_Value('CODE_F', req_string_complete_);
   code_part_val_structure_rec_.code_g := Client_SYS.Get_Item_Value('CODE_G', req_string_complete_);
   code_part_val_structure_rec_.code_h := Client_SYS.Get_Item_Value('CODE_H', req_string_complete_);
   code_part_val_structure_rec_.code_i := Client_SYS.Get_Item_Value('CODE_I', req_string_complete_);
   code_part_val_structure_rec_.code_j := Client_SYS.Get_Item_Value('CODE_J', req_string_complete_);
   code_part_val_structure_rec_.process_code := Client_SYS.Get_Item_Value('PROCESS_CODE', req_string_complete_);
   code_part_val_structure_rec_.quantity := Client_SYS.Get_Item_Value_To_Number('QUANTITY', req_string_complete_,lu_name_);
   code_part_val_structure_rec_.text := Client_SYS.Get_Item_Value('TEXT', req_string_complete_);
   code_part_val_structure_rec_.project_activity_id := Client_SYS.Get_Item_Value_To_Number('PROJECT_ACTIVITY_ID', req_string_complete_, lu_name_);
   RETURN code_part_val_structure_rec_;
END Attr_To_Code_Part_Rec___;

PROCEDURE Remove_Unused_Il_Codeparts___ (
   codestring_rec_   IN OUT Accounting_Codestr_API.Codestring_Handling_Rec,
   ledger_id_        IN VARCHAR2)
IS   
   code_b_           VARCHAR2(1);
   code_c_           VARCHAR2(1);
   code_d_           VARCHAR2(1);
   code_e_           VARCHAR2(1);
   code_f_           VARCHAR2(1);
   code_g_           VARCHAR2(1);
   code_h_           VARCHAR2(1);
   code_i_           VARCHAR2(1);
   code_j_           VARCHAR2(1);   
   temp_ledger_id_   VARCHAR2(20) := Nvl(ledger_id_, '00');
BEGIN    
   -- Only handle Internal Ledger, if GL then return
   IF (temp_ledger_id_ IN ('*', '00')) THEN
      RETURN;
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      Internal_Code_Parts_API.Get_Code_Part_Usage(code_b_,
                                                  code_c_,
                                                  code_d_,
                                                  code_e_,
                                                  code_f_,
                                                  code_g_,
                                                  code_h_,
                                                  code_i_,
                                                  code_j_,
                                                  codestring_rec_.company,
                                                  temp_ledger_id_);
   $ELSE
      NULL;
   $END   

   -- when value is N then code part is not used in the ledger so therefore remove the value
   IF (code_b_ = 'N') THEN
      codestring_rec_.code_b := NULL;
      codestring_rec_.modified_code_b := NULL;
   END IF;
   IF (code_c_ = 'N') THEN
      codestring_rec_.code_c := NULL;
      codestring_rec_.modified_code_c := NULL;
   END IF;
   IF (code_d_ = 'N') THEN
      codestring_rec_.code_d := NULL;
      codestring_rec_.modified_code_d := NULL;
   END IF;
   IF (code_e_ = 'N') THEN
      codestring_rec_.code_e := NULL;
      codestring_rec_.modified_code_e := NULL;
   END IF;
   IF (code_f_ = 'N') THEN
      codestring_rec_.code_f := NULL;
      codestring_rec_.modified_code_f := NULL;
   END IF;
   IF (code_g_ = 'N') THEN
      codestring_rec_.code_g := NULL;
      codestring_rec_.modified_code_g := NULL;
   END IF;
   IF (code_h_ = 'N') THEN
      codestring_rec_.code_h := NULL;
      codestring_rec_.modified_code_h := NULL;
   END IF;
   IF (code_i_ = 'N') THEN
      codestring_rec_.code_i := NULL;
      codestring_rec_.modified_code_i := NULL;
   END IF;
   IF (code_j_ = 'N') THEN
      codestring_rec_.code_j := NULL;
      codestring_rec_.modified_code_j := NULL;
   END IF;                                                  
END Remove_Unused_Il_Codeparts___;


FUNCTION Is_Project_Activity_Enabled___(
      company_            IN VARCHAR2,
      code_part_value_    IN VARCHAR2 ) RETURN VARCHAR2
   IS
      project_activity_id_enable_ VARCHAR2(1);
      
      tmp_project_origin_              VARCHAR2(2000);
      -- not implemented yet, will perhaps only be needed for Voucher Row Posting (Voucher Entry)
   BEGIN   
      IF (code_part_value_ IS NULL ) THEN
         project_activity_id_enable_ := 'N';
         RETURN project_activity_id_enable_;
      END IF;
      $IF (Component_Genled_SYS.INSTALLED) $THEN
         project_activity_id_enable_ := Accounting_Project_API.Get_Externally_Created(company_, code_part_value_);
        -- tmp_pca_ext_project_ := Voucher_Row_API.Get_Pca_Ext_Project(company_);
         tmp_project_origin_ := Accounting_Project_API.Get_Project_Origin_Db(company_, code_part_value_);
      $ELSE
         project_activity_id_enable_ := 'Y';
      $END
      IF (tmp_project_origin_ IS NULL ) THEN 
         project_activity_id_enable_ := 'N';
      ELSIF (tmp_project_origin_ = 'FINPROJECT') THEN
         project_activity_id_enable_ := 'N';         
      ELSIF (tmp_project_origin_ = 'JOB') THEN
         project_activity_id_enable_ := 'N';         
--      ELSIF (function_group_ IS NOT NULL AND function_group_ = 'Z') THEN         
--         project_activity_id_enable_ := 'N';      
      END IF;   
     
      RETURN project_activity_id_enable_;
END Is_Project_Activity_Enabled___;   
   
   
FUNCTION Get_Required_Code_Part_List (
  company_        IN VARCHAR2,
  account_        IN VARCHAR2,
  project_id_     IN VARCHAR2 ) RETURN VARCHAR2
 -- function_group_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   required_string_        VARCHAR2(2000);
   activity_seq_enabled_   VARCHAR2(1);
BEGIN
	required_string_ := Account_API.Get_Required_Code_Part_List(company_, account_);
   activity_seq_enabled_ := Is_Project_Activity_Enabled___(company_, project_id_);
   
   required_string_ := required_string_ || activity_seq_enabled_ || ';' ;   
   
	RETURN required_string_;
END Get_Required_Code_Part_List;


PROCEDURE Validate_Project_Code_Part  (
   project_code_part_          OUT VARCHAR2,
   project_activity_enable_    OUT BOOLEAN,
   project_code_part_value_    OUT VARCHAR2,
   project_externally_created_ OUT VARCHAR2,
   project_id_                 OUT VARCHAR2,
   proj_activity_seq_no_       IN OUT NUMBER,
   company_                    IN  VARCHAR2,
   code_b_                     IN  VARCHAR2,
   code_c_                     IN  VARCHAR2,
   code_d_                     IN  VARCHAR2,
   code_e_                     IN  VARCHAR2,
   code_f_                     IN  VARCHAR2,
   code_g_                     IN  VARCHAR2,
   code_h_                     IN  VARCHAR2,
   code_i_                     IN  VARCHAR2,
   code_j_                     IN  VARCHAR2)
IS
BEGIN   
   project_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(company_, 'PRACC');
   IF (project_code_part_ IS NULL) THEN
      project_activity_enable_ := FALSE;
   ELSE
      $IF Component_Proj_SYS.INSTALLED $THEN
         project_activity_enable_ := TRUE;
      $ELSE
         project_activity_enable_ := FALSE;
      $END
   END IF;
   IF (project_activity_enable_) THEN
      IF (project_code_part_ = 'B') THEN
         project_code_part_value_ := code_b_;
      ELSIF (project_code_part_ = 'C') THEN
         project_code_part_value_ := code_c_;
      ELSIF (project_code_part_ = 'D') THEN
         project_code_part_value_ := code_d_;
      ELSIF (project_code_part_ = 'E') THEN
         project_code_part_value_ := code_e_;
      ELSIF (project_code_part_ = 'F') THEN
         project_code_part_value_ := code_f_;
      ELSIF (project_code_part_ = 'G') THEN
         project_code_part_value_ := code_g_;
      ELSIF (project_code_part_ = 'H') THEN
         project_code_part_value_ := code_h_;
      ELSIF (project_code_part_ = 'I') THEN
         project_code_part_value_ := code_i_;
      ELSIF (project_code_part_ = 'J') THEN
         project_code_part_value_ := code_j_;
      ELSE
         project_code_part_value_ := NULL;
      END IF;   END IF;
   Code_Part_Changed(project_externally_created_, project_id_, proj_activity_seq_no_, company_, project_code_part_, project_code_part_value_, FALSE, project_activity_enable_);
   
END Validate_Project_Code_Part;


PROCEDURE Code_Part_Changed  (
   project_externally_created_ OUT    VARCHAR2,
   project_id_                 IN OUT VARCHAR2,
   proj_activity_seq_no_       IN OUT NUMBER,
   company_                    IN     VARCHAR2,
   code_part_                  IN     VARCHAR2,
   code_part_value_            IN     VARCHAR2,
   is_code_part_changed_       IN     BOOLEAN,
   project_activity_enable_    IN     BOOLEAN)
IS
   project_code_part_   VARCHAR2(10);
   buffer_              VARCHAR2(1000);
   exeception1_         EXCEPTION;
BEGIN   
   project_externally_created_ := 'N';
   project_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(company_, 'PRACC');
   IF (project_activity_enable_) THEN
      IF (code_part_ = project_code_part_) THEN
         IF (is_code_part_changed_) THEN
            proj_activity_seq_no_ := NULL;
         END IF;
      END IF;
      IF (code_part_value_ IS NULL) THEN
         project_id_ := NULL;
         project_externally_created_ := 'N';
      ELSE
         IF (code_part_ = project_code_part_) THEN
            project_id_ := code_part_value_;
            buffer_ := code_part_value_;
            $IF Component_Genled_SYS.INSTALLED $THEN
               buffer_ := Accounting_Project_API.Get_Externally_Created(company_, buffer_);
            $ELSE
               NULL;
            $END
            project_externally_created_ := buffer_;
         END IF;
      END IF;
   END IF;
EXCEPTION
   WHEN exeception1_ THEN
      Error_SYS.Record_General(lu_name_, 'ERRORFOUND: ERROR.', buffer_);
END Code_Part_Changed;

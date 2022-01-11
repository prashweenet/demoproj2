-----------------------------------------------------------------------------
--
--  Logical unit: AccountType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960327  MIJO     Created.
--  970402  AnDj     Added functionality to enable codepart update of accounts
--  970624  SLKO     Converted to Foundation1 1.2.2d
--  980126  SLKO     Converted to Foundation1 2.0.0
--  990706  UMAB     Modified with respect to new templates
--  991118  FAMESE   Changed "newrec_.account_type_description" to "description_" in
--                   "Unpack_Check_Insert___" . Changed description_ &VIEW..Description%TYPE
--                   to VARCHAR2(200).
--  000908  HiMu     Added General_SYS.Init_Method
--  001004  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001130  OVJOSE   For new Create Company concept added new view account_type_ect and account_type_pct.
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020206  MaNi     Text_Field_Translation changed to Company_Translation
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020709  Dagalk   Bug 31463 in Unpack_Check_Update call Account_API.Update_Code_Part_Demands_ conditionally
--  021001  Nimalk   Removed usage of the view Company_Finance_Auth in ACCOUNT_TYPE view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021031  ovjose   IID Glob06. Added column description to Table. Added function get_description
--
--  040617  sachlk   FIPR338A2: Unicode Changes.
--  070111  RUFELK   FIPL637A - Made it impossible to update the Logical Account Type when there are
--                   accounts connected to the User Defined Account Type.
--  070117  SHSALK   LCS Bug 62735  Corrected
--  131111  Umdolk   PBFI-1339, Refactoring.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Logical_Account_Exist_Db___ (
   company_ IN VARCHAR2,
   accnt_type_ IN VARCHAR2,
   logical_account_type_ IN VARCHAR2 )
IS
   dummy_   NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ACCOUNT_TYPE_TAB
      WHERE  company                   = company_
      AND    user_defined_account_type = accnt_type_
      AND    logical_account_type      = logical_account_type_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      Error_SYS.Appl_General(lu_name_,'NOLOGICALACCNT: The logical account type does not exist');
   END IF;
   CLOSE exist_control;
END Logical_Account_Exist_Db___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
 company_    ACCOUNT_TYPE_TAB.company%TYPE;
 can_        VARCHAR2(200);
 blocked_    VARCHAR2(200);

BEGIN
   can_     :=  Account_Request_API.Decode('K') ;
   blocked_ :=  Account_Request_API.Decode('S') ;
   company_ := Client_SYS.Get_Item_Value( 'COMPANY', attr_ );
   super(attr_);

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'B') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_B_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_B_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_B_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_B_DEFAULT', blocked_, attr_);
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'C') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_C_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_C_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_C_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_C_DEFAULT', blocked_, attr_);
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'D') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_D_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_D_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_D_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_D_DEFAULT', blocked_, attr_);
   END IF;

    IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'E') = 'TRUE')  THEN
      Client_SYS.Add_To_Attr('REQ_CODE_E_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_E_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_E_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_E_DEFAULT', blocked_, attr_);
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'F') = 'TRUE')  THEN
      Client_SYS.Add_To_Attr('REQ_CODE_F_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_F_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_F_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_F_DEFAULT', blocked_, attr_);
   END IF;

    IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'G') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_G_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_G_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_G_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_G_DEFAULT', blocked_, attr_);
   END IF;

    IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'H') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_H_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_H_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_H_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_H_DEFAULT', blocked_, attr_);
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'I') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_I_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_I_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_I_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_I_DEFAULT', blocked_, attr_);
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(company_, 'J') = 'TRUE') THEN
      Client_SYS.Add_To_Attr('REQ_CODE_J_DEFAULT', can_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_J_DEFAULT', can_, attr_);
   ELSE
      Client_SYS.Add_To_Attr('REQ_CODE_J_DEFAULT', blocked_, attr_);
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_J_DEFAULT', blocked_, attr_);
   END IF;

   Client_SYS.Add_To_Attr('REQ_QUANTITY_DEFAULT', can_, attr_);
   Client_SYS.Add_To_Attr('REQ_BUD_QUANTITY_DEFAULT', can_, attr_);
   Client_SYS.Add_To_Attr('TEXT_DEFAULT', can_, attr_);
   Client_SYS.Add_To_Attr('PROCESS_CODE_DEFAULT', can_, attr_);
END Prepare_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     account_type_tab%ROWTYPE,
   newrec_ IN OUT account_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Validate_Code_Part_Demands___(newrec_);
END Check_Common___;

PROCEDURE Validate_Code_Part_Demands___(
   newrec_ IN account_type_tab%ROWTYPE)
IS
   code_part_                 VARCHAR2(1);
   code_part_blocked          EXCEPTION;
   budget_code_part_          VARCHAR2(1);
   budget_code_part_blocked   EXCEPTION;
BEGIN   
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'B') = 'FALSE' AND newrec_.req_code_b_default != 'S') THEN
      code_part_ := 'B';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'C') = 'FALSE' AND newrec_.req_code_c_default != 'S') THEN
      code_part_ := 'C';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'D') = 'FALSE' AND newrec_.req_code_d_default != 'S') THEN
      code_part_ := 'D';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'E') = 'FALSE' AND newrec_.req_code_e_default != 'S') THEN
      code_part_ := 'E';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'F') = 'FALSE' AND newrec_.req_code_f_default != 'S') THEN
      code_part_ := 'F';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'G') = 'FALSE' AND newrec_.req_code_g_default != 'S') THEN
      code_part_ := 'G';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'H') = 'FALSE' AND newrec_.req_code_h_default != 'S') THEN
      code_part_ := 'H';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'I') = 'FALSE' AND newrec_.req_code_i_default != 'S') THEN
      code_part_ := 'I';
      RAISE code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'J') = 'FALSE' AND newrec_.req_code_j_default != 'S') THEN
      code_part_ := 'J';
      RAISE code_part_blocked;
   END IF;

   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'B') = 'FALSE' AND newrec_.req_bud_code_b_default != 'S') THEN
      budget_code_part_ := 'B';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'C') = 'FALSE' AND newrec_.req_bud_code_c_default != 'S') THEN
      budget_code_part_ := 'C';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'D') = 'FALSE' AND newrec_.req_bud_code_d_default != 'S') THEN
      budget_code_part_ := 'D';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'E') = 'FALSE' AND newrec_.req_bud_code_e_default != 'S') THEN
      budget_code_part_ := 'E';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'F') = 'FALSE' AND newrec_.req_bud_code_f_default != 'S') THEN
      budget_code_part_ := 'F';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'G') = 'FALSE' AND newrec_.req_bud_code_g_default != 'S') THEN
      budget_code_part_ := 'G';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'H') = 'FALSE' AND newrec_.req_bud_code_h_default != 'S') THEN
      budget_code_part_ := 'H';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'I') = 'FALSE' AND newrec_.req_bud_code_i_default != 'S') THEN
      budget_code_part_ := 'I';
      RAISE budget_code_part_blocked;
   END IF;
   IF (Accounting_Code_Parts_API.Is_Code_Used(newrec_.company, 'J') = 'FALSE' AND newrec_.req_bud_code_j_default != 'S') THEN
      budget_code_part_ := 'J';
      RAISE budget_code_part_blocked;
   END IF;   
EXCEPTION 
   WHEN code_part_blocked THEN
      Error_SYS.Record_General(lu_name_,
                               'CODEPARTNOTUSED: Code Part :P1 is set as not used in Defined Code String.',
                               Accounting_Code_Parts_API.Get_Name(newrec_.company, code_part_));
   WHEN budget_code_part_blocked THEN
      Error_SYS.Record_General(lu_name_,
                               'BUDCODEPARTNOTUSED: Budget Code Part :P1 is set as not used in Defined Code String.',
                               Accounting_Code_Parts_API.Get_Name(newrec_.company, budget_code_part_));
                               
END Validate_Code_Part_Demands___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT account_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.description IS NULL) THEN
      newrec_.description := newrec_.user_defined_account_type;
   END IF;
   super(newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     account_type_tab%ROWTYPE,
   newrec_ IN OUT account_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   desc_updated_        BOOLEAN  := FALSE;
   attr2_               VARCHAR2(2000);
   code_part_updated_   BOOLEAN := FALSE;
   budget_code_updated_ BOOLEAN := FALSE;
BEGIN   
   IF (indrec_.description) THEN
      desc_updated_ := TRUE;   
   END IF;
   IF (indrec_.req_code_b_default OR indrec_.req_code_c_default OR indrec_.req_code_d_default 
      OR indrec_.req_code_e_default OR indrec_.req_code_f_default OR indrec_.req_code_g_default 
      OR indrec_.req_code_h_default OR indrec_.req_code_i_default OR indrec_.req_code_j_default  
      OR indrec_.req_quantity_default OR indrec_.process_code_default OR indrec_.text_default) THEN
      code_part_updated_ := TRUE;
   END IF;
   
   IF (indrec_.req_bud_code_b_default OR indrec_.req_bud_code_c_default OR indrec_.req_bud_code_d_default 
      OR indrec_.req_bud_code_e_default OR indrec_.req_bud_code_f_default OR indrec_.req_bud_code_g_default 
      OR indrec_.req_bud_code_h_default OR indrec_.req_bud_code_i_default OR indrec_.req_bud_code_j_default  
      OR indrec_.req_bud_quantity_default) THEN
      budget_code_updated_ := TRUE;
   END IF;   
      
   super(oldrec_, newrec_, indrec_, attr_);   
   
   IF (indrec_.logical_account_type) THEN
      Account_API.Account_Exist(newrec_.company, newrec_.user_defined_account_type);
   END IF;
   IF (Client_SYS.Get_Item_Value('ACTION', attr_) = 'TRUE') THEN
      Client_SYS.Add_To_Attr('COMPANY', newrec_.company, attr2_ );
      Client_SYS.Add_To_Attr('ACCNT_TYPE', newrec_.user_defined_account_type, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_B', newrec_.req_code_b_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_C', newrec_.req_code_c_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_D', newrec_.req_code_d_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_E', newrec_.req_code_e_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_F', newrec_.req_code_f_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_G', newrec_.req_code_g_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_H', newrec_.req_code_h_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_I', newrec_.req_code_i_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_CODE_J', newrec_.req_code_j_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_QUANTITY', newrec_.req_quantity_default, attr2_ );
      Client_SYS.Add_To_Attr('PROCESS_CODE', newrec_.process_code_default, attr2_ );
      Client_SYS.Add_To_Attr('TEXT', newrec_.text_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_B', newrec_.req_bud_code_b_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_C', newrec_.req_bud_code_c_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_D', newrec_.req_bud_code_d_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_E', newrec_.req_bud_code_e_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_F', newrec_.req_bud_code_f_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_G', newrec_.req_bud_code_g_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_H', newrec_.req_bud_code_h_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_I', newrec_.req_bud_code_i_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_CODE_J', newrec_.req_bud_code_j_default, attr2_ );
      Client_SYS.Add_To_Attr('REQ_BUD_QUANTITY', newrec_.req_bud_quantity_default, attr2_ );
      IF (desc_updated_ = FALSE) THEN
         Account_API.Update_Code_Part_Demands_(attr2_);
      END IF;
      IF (desc_updated_ = TRUE AND code_part_updated_ = TRUE) THEN
         Account_API.Update_Code_Part_Demands_(attr2_);
      END IF;
      IF (desc_updated_ = TRUE AND budget_code_updated_ = TRUE) THEN
         Account_API.Update_Code_Part_Demands_(attr2_);
      END IF;
   END IF;
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Get_Default_Codepart_Demands_ (
   default_code_b_          OUT VARCHAR2,
   default_code_c_          OUT VARCHAR2,
   default_code_d_          OUT VARCHAR2,
   default_code_e_          OUT VARCHAR2,
   default_code_f_          OUT VARCHAR2,
   default_code_g_          OUT VARCHAR2,
   default_code_h_          OUT VARCHAR2,
   default_code_i_          OUT VARCHAR2,
   default_code_j_          OUT VARCHAR2,
   default_quantity_        OUT VARCHAR2,
   default_text_            OUT VARCHAR2,
   default_process_code_    OUT VARCHAR2,
   default_bud_code_b_      OUT VARCHAR2,
   default_bud_code_c_      OUT VARCHAR2,
   default_bud_code_d_      OUT VARCHAR2,
   default_bud_code_e_      OUT VARCHAR2,
   default_bud_code_f_      OUT VARCHAR2,
   default_bud_code_g_      OUT VARCHAR2,
   default_bud_code_h_      OUT VARCHAR2,
   default_bud_code_i_      OUT VARCHAR2,
   default_bud_code_j_      OUT VARCHAR2,
   default_bud_quantity_    OUT VARCHAR2,
   company_              IN     VARCHAR2,
   accnt_type_           IN     VARCHAR2 )
IS
   rec_        account_type_tab%ROWTYPE;     
BEGIN
   rec_ := Get_Object_By_Keys___(company_, accnt_type_);
   IF (rec_.company IS NULL) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
   default_code_b_ := rec_.req_code_b_default;
   default_code_c_ := rec_.req_code_c_default;
   default_code_d_ := rec_.req_code_d_default;
   default_code_e_ := rec_.req_code_e_default;
   default_code_f_ := rec_.req_code_f_default;
   default_code_g_ := rec_.req_code_g_default;
   default_code_h_ := rec_.req_code_h_default;
   default_code_i_ := rec_.req_code_i_default;
   default_code_j_ := rec_.req_code_j_default;
   default_quantity_ := rec_.req_quantity_default;
   default_text_     := rec_.text_default;
   default_process_code_ := rec_.process_code_default;   
   default_bud_code_b_ := rec_.req_bud_code_b_default;
   default_bud_code_c_ := rec_.req_bud_code_c_default;
   default_bud_code_d_ := rec_.req_bud_code_d_default;
   default_bud_code_e_ := rec_.req_bud_code_e_default;
   default_bud_code_f_ := rec_.req_bud_code_f_default;
   default_bud_code_g_ := rec_.req_bud_code_g_default;
   default_bud_code_h_ := rec_.req_bud_code_h_default;
   default_bud_code_i_ := rec_.req_bud_code_i_default;
   default_bud_code_j_ := rec_.req_bud_code_j_default;
   default_bud_quantity_ := rec_.req_bud_quantity_default;
END Get_Default_Codepart_Demands_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Logical_Account_Exist (
   company_               IN VARCHAR2,
   accnt_type_            IN VARCHAR2,
   logical_account_type_  IN VARCHAR2 )
IS
   logical_account_type_db_  VARCHAR2(20);
BEGIN
   logical_account_type_db_ := Account_Type_Value_API.Encode(logical_account_type_);
   Logical_Account_Exist_Db___(company_, accnt_type_, logical_account_type_db_);
END Logical_Account_Exist;


PROCEDURE Logical_Account_Exist_Db (
   company_ IN VARCHAR2,
   accnt_type_ IN VARCHAR2,
   logical_account_type_db_ IN VARCHAR2 )
IS
BEGIN
   Logical_Account_Exist_Db___(company_, accnt_type_, logical_account_type_db_);
END Logical_Account_Exist_Db;


-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodestrCompl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960329  xxxx  Base Table to Logical Unit Generator 1.0A
--  960607  ToRe  Override value in override_rec is default 'Y'.
--  970627  SLKO  Converted to Foundation 1.2.2d
--  980217  SLKO  Converted to Foundation1 2.0.0
--  980921  Bren  Master Slave Connection
--                Added Send_Code_Comp_Info___, Send_Code_Comp_Info_Delete___,
--                Send_Code_Comp_Info_Modify___, Receive_Code_Comp_Info___ .
--  990405  JPS   Corrected Bog 8446. Changed Get_Codestring_Completetion.
--  990420  JPS   Performed Template Changes (Foundation 2.2.1)
--  000908  HiMu  Added General_SYS.Init_Method 
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method 
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  020207  MaNi  IID21003, Company Translations
--  021001  Nimalk   Remove usage of the view Company_Finance_Auth in ACCOUNTING_CODESTR_COMPL view 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  030730  prdilk   SP4 Merge 
--  030903  Thsrlk LCS Merge - Bug 38836,Corrected. Added function Exist_Completion__.
--  040727  Umdolk Merged LCS Bug 43755.
--  061212  Kagalk LCS Merge 58758, Performance improvement.
--  090110  Maaylk Bug 79375, modified Connect_To_Account(). Should exist records with codefill_value NOT NULL to return true
--  090720  Marulk Bug 83876, added necessary view and methods to add the LU to the company template. 
--  100914  Jaralk Bug 92858 Added two method to update the ACCOUNTING_CODESTR_COMPL_TAB  
--                 to reflect the changes done in ACCOUNTING_CODE_PART tab
--  110818  Mohrlk FIDEAGLE-1337, Merged bug 98291, Changed the column width field of view comment of codefill value field of the accounting_codestr_compl view
--  131104  Umdolk PBFI-893, Refactoring.
--  150811  Thpelk Bug Id 123238, Fixed
--  151117  Bhhilk STRFI-12, Removed annotation from public get methords.
--  151229  Umdolk FINGP-20, Modified Get_Translated_Code_Fill_Name.
--  160216  Savmlk STRFI-1186, Merged LCS Bug 127280, Fixed.
--  161017  Chwtlk STRFI-3528, Merged LCS Bug 131415, Fixed. And rollbacked changes done by 123238.
--  161027  Kagalk STRFI-3862, Merged Bug 132223, Fixed numeric or value error when using Get_Complete_CodeString().
--  170910  Savmlk STRFI-10295, Merged LCS Bug 138088, Modified Insert_Code_Parts.
--  190802  Nudilk Bug 149273, Provided overloaded methods to handle security based on project acess.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     accounting_codestr_compl_tab%ROWTYPE,
   newrec_ IN OUT accounting_codestr_compl_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_      VARCHAR2(30);
   value_     VARCHAR2(4000);
   codefill_value_name_  VARCHAR2(100);
BEGIN
   codefill_value_name_:= Client_SYS.Cut_Item_Value('CODEFILL_VALUE_NAME',attr_);
   IF (codefill_value_name_ IS NOT NULL)THEN
      Error_SYS.Item_Update(lu_name_, 'CODEFILL_VALUE_NAME');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

PROCEDURE Get_Codestring_Completetion___ (
   codestring_rec_    IN OUT Accounting_Codestr_API.CodestrRec,
   code_part_         IN OUT VARCHAR2,
   company_           IN     VARCHAR2,
   voucher_date_      IN     DATE DEFAULT NULL)
IS
   --
   code_a_codefill_          VARCHAR2(20);
   code_b_codefill_          VARCHAR2(20);
   code_c_codefill_          VARCHAR2(20);
   code_d_codefill_          VARCHAR2(20);
   code_e_codefill_          VARCHAR2(20);
   code_f_codefill_          VARCHAR2(20);
   code_g_codefill_          VARCHAR2(20);
   code_h_codefill_          VARCHAR2(20);
   code_i_codefill_          VARCHAR2(20);
   code_j_codefill_          VARCHAR2(20);
   process_code_codefill_    VARCHAR2(20);
   code_part_value_          VARCHAR2(20);
   codep_                    VARCHAR2(1);
   no_codepart_val_rec_      Accounting_Codestr_API.CodestrRec;
   override_rec1_            Accounting_Codestr_API.CodestrRec;
   inner_codep_              VARCHAR2(1);
   inner_codep_val_          VARCHAR2(20);
   tmp_override_val_         VARCHAR2(20);
   tmp_no_code_part_val_     VARCHAR2(20);
BEGIN
   IF codestring_rec_.posting_type IS NOT NULL THEN
      Posting_Ctrl_API.Get_Override_Rec( override_rec1_,
                                         no_codepart_val_rec_,
                                         company_,
                                         codestring_rec_.posting_type,
                                         voucher_date_ );
   END IF;
   
   FOR i_ IN 1..10 LOOP
      codep_ := chr(64+i_);
      code_part_value_ := Accounting_Codestr_API.Get_Rec_Value_For_Code_Part(codestring_rec_, codep_);      
      
      IF (code_part_value_ IS NOT NULL AND code_part_ IS NULL
      OR code_part_value_ IS NOT NULL AND code_part_ = codep_) THEN
         Complete_Code_Part__(code_a_codefill_,
                              code_b_codefill_,
                              code_c_codefill_,
                              code_d_codefill_,
                              code_e_codefill_,
                              code_f_codefill_,
                              code_g_codefill_,
                              code_h_codefill_,
                              code_i_codefill_,
                              code_j_codefill_,
                              process_code_codefill_,
                              company_,
                              codep_,
                              code_part_value_);
         FOR k_ IN 1..10 LOOP
            inner_codep_ := chr(64+k_);            
            inner_codep_val_ := Accounting_Codestr_API.Get_Rec_Value_For_Code_Part(codestring_rec_, inner_codep_);
            tmp_override_val_ := Accounting_Codestr_API.Get_Rec_Value_For_Code_Part(override_rec1_, inner_codep_);
            tmp_no_code_part_val_ := Accounting_Codestr_API.Get_Rec_Value_For_Code_Part(no_codepart_val_rec_, inner_codep_);
            
            IF (inner_codep_val_ IS NULL AND NVL(tmp_no_code_part_val_, 'F') = 'F') OR (NVL(tmp_override_val_, 'N') = 'Y') THEN               
               Accounting_Codestr_API.Set_Code_Part_Val_In_Rec(codestring_rec_,
                                                               inner_codep_,
                                                               NVL(Accounting_Codestr_API.Get_Value_For_Code_Part(code_a_codefill_, 
                                                                                                                  code_b_codefill_,
                                                                                                                  code_c_codefill_,
                                                                                                                  code_d_codefill_,
                                                                                                                  code_e_codefill_,
                                                                                                                  code_f_codefill_,
                                                                                                                  code_g_codefill_,
                                                                                                                  code_h_codefill_,
                                                                                                                  code_i_codefill_,
                                                                                                                  code_j_codefill_,                                                                                                  
                                                                                                                  inner_codep_), 
                                                                  inner_codep_val_));               

            END IF;
         END LOOP;
         
         IF (codestring_rec_.process_code IS NULL OR override_rec1_.process_code = 'Y') THEN
            codestring_rec_.process_code := NVL(process_code_codefill_, codestring_rec_.process_code);
         END IF;
      END IF;
   END LOOP;   
END Get_Codestring_Completetion___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Complete_Code_Part__ (
   code_a_codefill_          OUT VARCHAR2,
   code_b_codefill_          OUT VARCHAR2,
   code_c_codefill_          OUT VARCHAR2,
   code_d_codefill_          OUT VARCHAR2,
   code_e_codefill_          OUT VARCHAR2,
   code_f_codefill_          OUT VARCHAR2,
   code_g_codefill_          OUT VARCHAR2,
   code_h_codefill_          OUT VARCHAR2,
   code_i_codefill_          OUT VARCHAR2,
   code_j_codefill_          OUT VARCHAR2,
   process_code_codefill_    OUT VARCHAR2,
   company_               IN     VARCHAR2,
   code_part_             IN     VARCHAR2,
   code_part_value_       IN     VARCHAR2 )
IS
   --
   codefill_code_part_    VARCHAR2(1);
   codefill_value_        VARCHAR2(20);
   --
   CURSOR complete_cursor IS
      SELECT  codefill_code_part, codefill_value
      FROM    ACCOUNTING_CODESTR_COMPL_TAB
      WHERE   company         = company_
      AND     code_part       = code_part_
      AND     code_part_value = code_part_value_
      AND     codefill_value  IS NOT NULL;
   --
BEGIN

   code_a_codefill_       := NULL;
   code_b_codefill_       := NULL;
   code_c_codefill_       := NULL;
   code_d_codefill_       := NULL;
   code_e_codefill_       := NULL;
   code_f_codefill_       := NULL;
   code_g_codefill_       := NULL;
   code_h_codefill_       := NULL;
   code_i_codefill_       := NULL;
   code_j_codefill_       := NULL;
   process_code_codefill_ := NULL;

   OPEN complete_cursor;
   WHILE (TRUE) LOOP
      FETCH complete_cursor INTO codefill_code_part_, codefill_value_;
      EXIT WHEN complete_cursor%NOTFOUND;
      IF codefill_code_part_ = 'A' THEN
         code_a_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'B' THEN
         code_b_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'C' THEN
         code_c_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'D' THEN
         code_d_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'E' THEN
         code_e_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'F' THEN
         code_f_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'G' THEN
         code_g_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'H' THEN
         code_h_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'I' THEN
         code_i_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'J' THEN
         code_j_codefill_ := codefill_value_;
      ELSIF codefill_code_part_ = 'P' THEN
         process_code_codefill_ := codefill_value_;
      END IF;
   END LOOP;
   CLOSE complete_cursor;
END Complete_Code_Part__;


FUNCTION Exist_Completion__(company_ IN VARCHAR2, account_ in VARCHAR2) RETURN VARCHAR2
IS 
 CURSOR check_completion IS
     SELECT 1
     FROM Accounting_Codestr_Compl
     WHERE company = company_
     AND code_part = 'A'
     AND code_part_value = account_;
     
  temp_   NUMBER;   
  result_ VARCHAR2(5);
  
BEGIN
   OPEN check_completion;
   FETCH check_completion INTO temp_;
   CLOSE check_completion;
  
   IF (temp_ > 0) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
   END IF;   
  
   RETURN result_;
END Exist_Completion__;

FUNCTION Exist_Any_For_Code_Part_Val__ (
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2) RETURN VARCHAR2
IS
   
      exists_  VARCHAR2(5)  := 'TRUE';
      idum_     PLS_INTEGER;
      CURSOR exist_control IS
         SELECT 1
         FROM  accounting_codestr_compl_tab
         WHERE company = company_
         AND   code_part = code_part_
         AND   code_part_value = code_part_value_;
   BEGIN
      OPEN exist_control;
      FETCH exist_control INTO idum_;
      IF (exist_control%NOTFOUND) THEN
         exists_ := 'FALSE';
      END IF;
      CLOSE exist_control;
      RETURN exists_;
   END Exist_Any_For_Code_Part_Val__;
   
PROCEDURE Create_Code_Str_Comp_Det__ (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2) 
IS
   newrec_ accounting_codestr_compl_tab%ROWTYPE;
   emptyrec_ accounting_codestr_compl_tab%ROWTYPE;
   
   CURSOR get_code_parts IS 
      SELECT code_part, code_name
      FROM   accounting_code_parts
      WHERE  company = company_
      AND    code_part_used_db = 'Y'
      AND    code_part BETWEEN 'A' AND 'J'
      UNION 
      SELECT 'P', Accounting_Codestr_Compl_API.Get_Translated_Code_Fill_Name(company_, 'ACCRUL', 'AccountingCodeParts', 'P') 
      FROM DUAL
      ORDER BY 1 ASC; 
BEGIN
   FOR rec_ IN get_code_parts LOOP
      newrec_ := emptyrec_;
      newrec_.company            := company_;
      newrec_.code_part          := code_part_;
      newrec_.code_part_value    := code_part_value_;
      newrec_.codefill_code_part := rec_.CODE_PART;
      newrec_.codefill_value     := NULL;
      New___(newrec_);
   END LOOP;   
END Create_Code_Str_Comp_Det__;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Delete_Code_Str_Comp_Det__(
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2) 
IS
   remrec_   accounting_codestr_compl_tab%ROWTYPE;
   CURSOR get_records IS 
      SELECT *
      FROM   accounting_codestr_compl_tab
      WHERE  company = company_
      AND    code_part = code_part_
      AND    code_part_value = code_part_value_;   
BEGIN
   FOR rec_ IN get_records LOOP
      remrec_.company            := rec_.company;
      remrec_.code_part          := rec_.code_part;
      remrec_.code_part_value    := rec_.code_part_value;
      remrec_.codefill_code_part := rec_.codefill_code_part;
      Delete___(remrec_);
   END LOOP;   
END Delete_Code_Str_Comp_Det__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

FUNCTION Check_Delete_Allowed_ (
   company_           IN VARCHAR2,
   code_part_value_   IN VARCHAR2,
   code_part_         IN VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN
IS   
   dummy_             VARCHAR2(1);
   --
   CURSOR exist_code_part IS
     SELECT 'X'
     FROM   ACCOUNTING_CODESTR_COMPL_TAB
     WHERE  company            = company_
     AND    codefill_code_part = code_part_
     AND    codefill_value     = code_part_value_;

   CURSOR exist_code_part_value IS
     SELECT 'X'
     FROM   ACCOUNTING_CODESTR_COMPL_TAB
     WHERE  company        = company_
     AND    codefill_value = code_part_value_;
BEGIN
   IF (code_part_ IS NULL) THEN
      OPEN  exist_code_part_value;
      FETCH exist_code_part_value INTO dummy_;
      IF (exist_code_part_value%NOTFOUND) THEN
         CLOSE  exist_code_part_value;
         RETURN TRUE;
      ELSE
         CLOSE  exist_code_part_value;
         RETURN FALSE;
      END IF;
   ELSE
      OPEN  exist_code_part;
      FETCH exist_code_part INTO dummy_;
      IF (exist_code_part%NOTFOUND) THEN
         CLOSE  exist_code_part;
         RETURN TRUE;
      ELSE
         CLOSE  exist_code_part;
         RETURN FALSE;
      END IF;
   END IF;
END Check_Delete_Allowed_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_Codestring_Completetion (
   codestring_rec_    IN OUT Accounting_Codestr_API.CodestrRec,
   code_part_         IN OUT VARCHAR2,
   company_           IN     VARCHAR2,
   override_rec_      IN     Accounting_Codestr_API.CodestrRec,
   voucher_date_      IN     DATE DEFAULT NULL)
IS
BEGIN
   Get_Codestring_Completetion___(codestring_rec_, code_part_, company_, voucher_date_);  
END Get_Codestring_Completetion;

-- Note: Please use this method only when project_id is not null and Project_Access_API.Has_User_Project_Access check is essential. 
--       Try to use overloaded method with company security check if possible. 
--       Calling this method can skip company security check in certain conditions.
@ServerOnlyAccess
PROCEDURE Get_Codestring_Completetion (
   codestring_rec_    IN OUT Accounting_Codestr_API.CodestrRec,
   code_part_         IN OUT VARCHAR2,
   company_           IN     VARCHAR2,
   voucher_date_      IN     DATE,
   project_id_        IN     VARCHAR2)
IS
   check_company_security_ BOOLEAN := FALSE;
BEGIN
   IF project_id_ IS NOT NULL THEN 
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF Project_Access_API.Has_User_Project_Access(project_id_) = 1 THEN
            -- Note: by pass the company security check in this senario.
            check_company_security_ := FALSE;
         ELSE
            check_company_security_ := TRUE;
         END IF;
      $ELSE
         check_company_security_ := TRUE;
      $END
   ELSE
      check_company_security_ := TRUE;
   END IF;
   
   IF check_company_security_ THEN
      Get_Codestring_Completetion(codestring_rec_, code_part_, company_, NULL, voucher_date_);
   ELSE
      Get_Codestring_Completetion___(codestring_rec_, code_part_, company_, voucher_date_);
   END IF;
END Get_Codestring_Completetion;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Connect_To_Account (
   company_         IN VARCHAR2,
   code_part_       IN VARCHAR2,
   code_part_value_ IN VARCHAR2  )     RETURN VARCHAR2
IS
   CURSOR code_str IS
      SELECT 'X'
      FROM   ACCOUNTING_CODESTR_COMPL_TAB
      WHERE  company         = company_
      AND    code_part       = code_part_
      AND    code_part_value = code_part_value_
      AND    codefill_value IS NOT NULL ;
   dummy_ VARCHAR2(1);
BEGIN
   OPEN  code_str;
   FETCH code_str INTO dummy_;
   CLOSE code_str;
   IF (dummy_ = 'X') THEN
      RETURN('T');
   ELSE
      RETURN('F');
   END IF;
END Connect_To_Account;


FUNCTION Get_Complete_CodeString(
   company_          IN VARCHAR2,
   code_part_        IN VARCHAR2,
   code_part_value_  IN VARCHAR2) RETURN VARCHAR2
IS
   code_a_codefill_          VARCHAR2(20);
   code_b_codefill_          VARCHAR2(20);
   code_c_codefill_          VARCHAR2(20);
   code_d_codefill_          VARCHAR2(20);
   code_e_codefill_          VARCHAR2(20);
   code_f_codefill_          VARCHAR2(20);
   code_g_codefill_          VARCHAR2(20);
   code_h_codefill_          VARCHAR2(20);
   code_i_codefill_          VARCHAR2(20);
   code_j_codefill_          VARCHAR2(20);
   process_code_codefill_    VARCHAR2(20);
   completion_attr_          VARCHAR2(2000);   
   codestring_rec_           Accounting_Codestr_API.CodestrRec;
   codep_                    VARCHAR2(1);
   codep_value_              VARCHAR2(20);
   code_part_tab_            Accounting_Codestr_API.Code_part_value_tab;
BEGIN
   Complete_Code_Part__ ( code_a_codefill_,
                          code_b_codefill_,
                          code_c_codefill_,
                          code_d_codefill_,
                          code_e_codefill_,
                          code_f_codefill_,
                          code_g_codefill_,
                          code_h_codefill_,
                          code_i_codefill_,
                          code_j_codefill_,
                          process_code_codefill_,
                          company_,
                          code_part_,
                          code_part_value_ );

   IF (code_a_codefill_ IS NULL) AND (code_b_codefill_ IS NULL)
                                 AND (code_c_codefill_ IS NULL) 
                                 AND (code_d_codefill_ IS NULL) 
                                 AND (code_e_codefill_ IS NULL) 
                                 AND (code_f_codefill_ IS NULL) 
                                 AND (code_g_codefill_ IS NULL) 
                                 AND (code_h_codefill_ IS NULL) 
                                 AND (code_i_codefill_ IS NULL) 
                                 AND (code_j_codefill_ IS NULL) 
                                 AND (process_code_codefill_ IS NULL) THEN
      RETURN NULL;
   ELSE
      codestring_rec_ := Accounting_Codestr_API.Convert_To_Code_Str_Rec(code_a_codefill_,
                                                                        code_b_codefill_,
                                                                        code_c_codefill_,
                                                                        code_d_codefill_,
                                                                        code_e_codefill_,
                                                                        code_f_codefill_,
                                                                        code_g_codefill_,
                                                                        code_h_codefill_,
                                                                        code_i_codefill_,
                                                                        code_j_codefill_);
      code_part_tab_ := Accounting_Codestr_API.Get_Code_Part_Val_Tab(codestring_rec_);
      -- Loop over code part A-J                                                                        
      FOR i_ IN 1..10 LOOP
         codep_ := chr(64+i_);
         codep_value_ := code_part_tab_(codep_);
         IF (codep_value_ IS NOT NULL) THEN
            IF (i_ = 1) THEN
               Client_SYS.Add_To_Attr('ACCOUNT', codep_value_, completion_attr_);
               Client_SYS.Add_To_Attr('ACCOUNT_DESC', Account_API.Get_Description(company_, codep_value_), completion_attr_);
            ELSE
               Client_SYS.Add_To_Attr('CODE_'|| codep_, codep_value_, completion_attr_);               
               Client_SYS.Add_To_Attr('CODE_'|| codep_ || '_DESC', Accounting_Code_Part_Value_API.Get_Description(company_, codep_, codep_value_), completion_attr_);               
            END IF;            
         END IF;
      END LOOP;

      IF (process_code_codefill_ IS NOT NULL) THEN
         Client_SYS.Add_To_Attr('PROCESS_CODE', process_code_codefill_, completion_attr_);   
      END IF;
   END IF;
   RETURN completion_attr_;
END Get_Complete_CodeString;   


@UncheckedAccess
FUNCTION Get_Translated_Code_Fill_Name (
   company_ IN VARCHAR2,
   module_ IN VARCHAR2,
   lu_ IN VARCHAR2,
   attribute_ IN VARCHAR2,
   lang_code_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   text_    VARCHAR2(2000);    
BEGIN
   IF (attribute_ BETWEEN 'A' AND 'J') THEN
      text_ := Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_, module_, lu_, attribute_,lang_code_, 'NO') ;
   ELSIF (attribute_ = 'P') THEN
      text_ := language_sys.Translate_Constant(lu_name_, 'PROCESS_CODE: Process Code');
   END IF;
   RETURN text_;
END Get_Translated_Code_Fill_Name;



PROCEDURE Insert_Code_Parts(
   newrec_ IN OUT ACCOUNTING_CODESTR_COMPL_TAB%ROWTYPE ) 
IS 
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   attr_       VARCHAR2(2000);
BEGIN
   IF NOT Check_Exist___ (newrec_.company ,newrec_.code_part, newrec_.code_part_value, newrec_.codefill_code_part) THEN
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   END IF;
END Insert_Code_Parts;


PROCEDURE Delete_Code_Parts(
   company_            IN VARCHAR2,
   code_part_          IN VARCHAR2,
   code_part_value_    IN VARCHAR2,
   codefill_code_part_ IN VARCHAR2) 
IS
   info_             VARCHAR2(2000);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);
   
BEGIN
   IF Check_Exist___ (company_, code_part_, code_part_value_, codefill_code_part_) THEN
      Get_Id_Version_By_Keys___ (objid_, objversion_, company_,code_part_,code_part_value_,codefill_code_part_);
      Remove__(info_,objid_,objversion_,'DO');
   END IF;
END Delete_Code_Parts;


FUNCTION Get_Code_Part_Block_Info(
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2,
   codefill_code_part_ IN VARCHAR2) RETURN VARCHAR2
IS 
   codepart_demand_  VARCHAR2(2000) := NULL;
   codefill_account_ VARCHAR2(20);
   CURSOR get_account IS
      SELECT a.codefill_value
        FROM Accounting_Codestr_Compl_Tab a
       WHERE a.company = company_
         AND a.code_part = code_part_
         AND a.code_part_value = code_part_value_
         AND a.codefill_code_part = 'A';
BEGIN
   IF (code_part_ = codefill_code_part_) THEN
      RETURN 'S';
   ELSIF (code_part_ = 'A') THEN
      Accounting_Code_Part_A_API.Get_Required_Code_Part(codepart_demand_,company_,code_part_value_);
   ELSE
      OPEN get_account;
      FETCH get_account INTO codefill_account_;
      IF get_account%FOUND THEN
         Accounting_Code_Part_A_API.Get_Required_Code_Part(codepart_demand_,company_,codefill_account_);
      END IF;
      CLOSE get_account;
   END IF;
   IF (INSTR('ABCDEFGHIJ',codefill_code_part_) != -1) THEN
      IF (SUBSTR(codepart_demand_,INSTR(codepart_demand_,'CODE_'|| codefill_code_part_) + 7, 1) != 'S') THEN
         RETURN 'O';
      END IF;
   ELSIF (SUBSTR(codepart_demand_,INSTR(codepart_demand_,'PROCESS_CODE') + 13, 1) != 'S') THEN
      RETURN 'O';
   END IF;
   RETURN 'S';

   
END Get_Code_Part_Block_Info;


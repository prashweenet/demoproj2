-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodestrComb
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960415  MIJO     Created.
--  960508  Narni    Modified.
--  970717  SLKO     Converted to Foundation 1.2.2d
--  971003  ANDJ     Modified view to enable update (wrong objversion).
--  980921  Bren     Master Slave Connection
--                   Added Send_Acc_Comb_Info___, Send_Acc_Comb_Info_Delete___,
--                   Send_Acc_Comb_Info_Modify___, Receive_Acc_Comb_Info___ .
--  000908  HiMu     Added General_SYS.Init_Method
--  001004  prtilk   BUG # 15677  Checked General_SYS.Init_Method 
--  001130  OVJOSE   For new Create Company concept added new view accounting_codestr_comb_ect and accounting_codestr_comb_pct. 
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010425  ANDJ     Bug #20361, cursor comb_control in procedure Check_Combination__.
--  010504  OVJOSE   Changed call in Copy___ method from POSTING_COMBINATION_API.Get_Combination to Codestring_Comb_API.Get_Combination.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  010816  OVJOSE   Changed select statement in copy___ procedure.
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020603  Hecolk   Bug 26124, Merged. Added the NULL Check to Cursor comb_control in Check_Combination__. 
--  021001  Nimalk   Removed usage of the view Company_Finance_Auth in ACCOUNTING_CODESTR_COMB view 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021223  ISJALK   SP3 merge, Bug 33368.
--  030730  prdilk   SP4 Merge.
--  030925  LoKrLK   B104046 - Undo SP4 Merge
--  040324  Gepelk   2004 SP1 Merge.
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  050322  Samwlk   LCS Bug 49756, Merged.
--  050304  Chablk   Merged bug 49051, corrected. Let the client to display empty Process Code while
--                   column on ACCOUNTING_CODESTR_COMB_TAB stores value '>NU#LL<'.
--  051116  WAPELK   Merged the Bug 52783. Correct the user group variable's width.
--  060227  GADALK   B135693 Error in Unpack_Check_Update___() fixed.
--  060227  GADALK   B135763 Errors in Insert___() fixed to return objvertion correctly. 
--  060802  Prdilk   B138987 Modify Unpack_Check_Insert___ and Unpack_Check_Update___ 
--  060920  SuSalk   LCS Merge 60284, Modified Check_Combination__ procedure to change the error message.                     
--  081103  Nirplk   Bug 77483, Added a new column called combination_rule_id
--  091207  HimRlk   Reverse engineering, Added REF to CompnayFinace in company column in main view and added REF to UserGroupFinance in user_group column.
--  100308  Sacalk   RAVEN-177, Added code part description columns in the VIEW ACCOUNTING_CODESTR_COMB
--  120730  Maaylk   Bug 101320, Added implementation method Check_Combination___ to reduce calls to General_SY
--  170724  Savmlk   STRFI-6769, Merged lcs Bug 136233, Fixed.
--  181823  Nudilk   Bug 143758, Corrected.
--  190410  Chwtlk   Bug 147828, Modified Insert___ and overrided Update___. Added posting_combination_id to the attr_.
--  190522  Dakplk  Bug 147872, Modified Copy_To_Companies__. 
--  200701  Tkavlk  Bug 154601, Added Remove_Company.
--  210202  Tkavlk  LCS 157098 Merge, Corrected in Copy_To_Companies_().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Check_Process_Code_Ref___ (
   newrec_ IN OUT accounting_codestr_comb_tab%ROWTYPE )
IS
BEGIN
   IF instr(newrec_.process_code,'%') = 0 AND instr(newrec_.process_code,'_') = 0 THEN
      Account_Process_Code_API.Exist(newrec_.company, newrec_.process_code);
   END IF;      
END Check_Process_Code_Ref___;


PROCEDURE Import___ (
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   attr_          VARCHAR2(32000);
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   newrec_        ACCOUNTING_CODESTR_COMB_TAB%ROWTYPE;
   
   msg_             VARCHAR2(2000);   
   i_               NUMBER := 0;
   indrec_          Indicator_Rec;
   codestring_rec_  Accounting_Codestr_API.CodestrRec;   
   
   CURSOR get_data IS
      SELECT C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13 
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1 
                      FROM accounting_codestr_comb_tab dest, codestring_comb_tab b
                      WHERE dest.posting_combination_id = b.posting_combination_id
                      AND dest.company = crecomp_rec_.company
                      AND dest.user_group = src.c1
                      AND b.account = src.c2
                      AND b.code_b = src.c3
                      AND b.code_c = src.c4
                      AND b.code_d = src.c5
                      AND b.code_e = src.c6
                      AND b.code_f = src.c7
                      AND b.code_g = src.c8
                      AND b.code_h = src.c9
                      AND b.code_i = src.c10
                      AND b.code_j = src.c11
                      AND decode(dest.process_code,'>NU#LL<','',dest.process_code) = src.c12);           
BEGIN
   IF (Insert_Company_Data___(crecomp_rec_)) THEN   
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-26,dipelk)
         SAVEPOINT make_company_insert;
         Client_SYS.Clear_Attr(attr_);         
         BEGIN
            newrec_.company         := crecomp_rec_.company;
            newrec_.user_group      := rec_.c1;
            codestring_rec_.code_a  := rec_.c2;
            codestring_rec_.code_b  := rec_.c3;
            codestring_rec_.code_c  := rec_.c4;
            codestring_rec_.code_d  := rec_.c5;
            codestring_rec_.code_e  := rec_.c6;
            codestring_rec_.code_f  := rec_.c7;
            codestring_rec_.code_g  := rec_.c8;
            codestring_rec_.code_h  := rec_.c9;
            codestring_rec_.code_i  := rec_.c10;
            codestring_rec_.code_j  := rec_.c11;
            Codestring_Comb_API.Get_Combination(newrec_.posting_combination_id, codestring_rec_);
            newrec_.process_code    := rec_.c12; 
            newrec_.allowed         := rec_.c13;
 
            Client_SYS.Add_To_Attr('ACCOUNT',rec_.c2, attr_);
            Client_SYS.Add_To_Attr('CODE_B',rec_.c3, attr_);
            Client_SYS.Add_To_Attr('CODE_C',rec_.c4, attr_);
            Client_SYS.Add_To_Attr('CODE_D',rec_.c5, attr_);
            Client_SYS.Add_To_Attr('CODE_E',rec_.c6, attr_);
            Client_SYS.Add_To_Attr('CODE_F',rec_.c7, attr_);
            Client_SYS.Add_To_Attr('CODE_G',rec_.c8, attr_);
            Client_SYS.Add_To_Attr('CODE_H',rec_.c9, attr_);
            Client_SYS.Add_To_Attr('CODE_I',rec_.c10, attr_);
            Client_SYS.Add_To_Attr('CODE_J',rec_.c11 ,attr_);
            
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-26,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'Error', msg_);                                                   
         END;
      END LOOP;      
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;      
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'Error', msg_);                                          
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedWithErrors');                           
END Import___;   


PROCEDURE Copy___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   msg_             VARCHAR2(2000);
   newrec_          ACCOUNTING_CODESTR_COMB_TAB%ROWTYPE;
   attr_            VARCHAR2(2000);
   i_               NUMBER := 0;
   objid_           VARCHAR2(2000);
   objversion_      VARCHAR2(2000);
   indrec_          Indicator_Rec;
   codestring_rec_  Accounting_Codestr_API.CodestrRec;     
   CURSOR get_data IS                                                            
      SELECT src.user_group, b.account, b.code_b, b.code_c, b.code_d, b.code_e, b.code_f, b.code_g, b.code_h, b.code_i, b.code_j, decode(process_code,'>NU#LL<','',process_code) process_code, allowed, b.posting_combination_id
       FROM  accounting_codestr_comb_tab src, codestring_comb_tab b
       WHERE  src.posting_combination_id = b.posting_combination_id
       AND    src.company = crecomp_rec_.old_company
       AND NOT EXISTS (SELECT 1 
                FROM accounting_codestr_comb_tab dest, codestring_comb_tab d
                WHERE dest.posting_combination_id = d.posting_combination_id
                AND b.posting_combination_id = d.posting_combination_id
                AND dest.company = crecomp_rec_.company
                AND dest.user_group = src.user_group
                AND decode(dest.process_code,'>NU#LL<','',dest.process_code) = src.process_code);
BEGIN
   IF (Insert_Company_Data___(crecomp_rec_)) THEN   
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-26,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            Client_SYS.Clear_Attr(attr_); 
            newrec_.company         := crecomp_rec_.company;
            newrec_.user_group      := rec_.user_group;
            codestring_rec_.code_a  := rec_.account;
            codestring_rec_.code_b  := rec_.code_b;
            codestring_rec_.code_c  := rec_.code_c;
            codestring_rec_.code_d  := rec_.code_d;
            codestring_rec_.code_e  := rec_.code_e;
            codestring_rec_.code_f  := rec_.code_f;
            codestring_rec_.code_g  := rec_.code_g;
            codestring_rec_.code_h  := rec_.code_h;
            codestring_rec_.code_i  := rec_.code_i;
            codestring_rec_.code_j  := rec_.code_j;
            Client_SYS.Add_To_Attr('ACCOUNT',rec_.account, attr_);
            Client_SYS.Add_To_Attr('CODE_B',rec_.code_b, attr_);
            Client_SYS.Add_To_Attr('CODE_C',rec_.code_c, attr_);
            Client_SYS.Add_To_Attr('CODE_D',rec_.code_d, attr_);
            Client_SYS.Add_To_Attr('CODE_E',rec_.code_e, attr_);
            Client_SYS.Add_To_Attr('CODE_F',rec_.code_f, attr_);
            Client_SYS.Add_To_Attr('CODE_G',rec_.code_g, attr_);
            Client_SYS.Add_To_Attr('CODE_H',rec_.code_h, attr_);
            Client_SYS.Add_To_Attr('CODE_I',rec_.code_i, attr_);
            Client_SYS.Add_To_Attr('CODE_J',rec_.code_j, attr_);            
            newrec_.posting_combination_id := rec_.posting_combination_id;
            newrec_.process_code    := rec_.process_code; 
            newrec_.allowed         := rec_.allowed;            
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-26,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedWithErrors');                     
         END IF;      
      END IF;      
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedSuccessfully');
   END IF;      
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'Error', msg_);                                                
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'ACCOUNTING_CODESTR_COMB_API', 'CreatedWithErrors');                           
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_             NUMBER := 1;

   CURSOR get_data IS
      SELECT user_group, b.account, b.code_b, b.code_c, b.code_d, b.code_e, b.code_f, b.code_g, b.code_h, b.code_i, b.code_j, process_code, allowed
      FROM   accounting_codestr_comb_tab src, codestring_comb_tab b
      WHERE  src.posting_combination_id = b.posting_combination_id
      AND    company = crecomp_rec_.company;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_name_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.user_group;
      pub_rec_.c2 := pctrec_.account;
      pub_rec_.c3 := pctrec_.code_b;
      pub_rec_.c4 := pctrec_.code_c;
      pub_rec_.c5 := pctrec_.code_d;
      pub_rec_.c6 := pctrec_.code_e;
      pub_rec_.c7 := pctrec_.code_f;
      pub_rec_.c8 := pctrec_.code_g;
      pub_rec_.c9 := pctrec_.code_h;
      pub_rec_.c10 := pctrec_.code_i;
      pub_rec_.c11 := pctrec_.code_j;
      pub_rec_.c12 := pctrec_.process_code;
      pub_rec_.c13 := pctrec_.allowed;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;


FUNCTION Exist_Any___(
   company_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN  := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
     SELECT 1
     FROM   ACCOUNTING_CODESTR_COMB_TAB
     WHERE  company = company_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO idum_;
   IF (exist_control%NOTFOUND) THEN
      b_exist_ := FALSE;
   END IF;
   CLOSE exist_control;
   RETURN b_exist_;
END Exist_Any___;


FUNCTION Insert_Company_Data___(
   crecomp_rec_    IN  ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) RETURN BOOLEAN
IS
   perform_insert_         BOOLEAN;
   update_by_key_          BOOLEAN;
BEGIN
   perform_insert_ := FALSE;
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);   
   IF ( update_by_key_ ) THEN
      perform_insert_ := TRUE;
   ELSE
      IF ( NOT Exist_Any___( crecomp_rec_.company ) ) THEN
         perform_insert_ := TRUE;
      END IF;
   END IF;
   RETURN perform_insert_;
END Insert_Company_Data___;


PROCEDURE Validate_Codepart___(
   company_       IN VARCHAR2,
   code_part_     IN VARCHAR2,
   value_         IN VARCHAR2)
IS
BEGIN
   IF value_ IS NOT NULL THEN
      IF instr(value_,'%') = 0 AND instr(value_,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(company_, code_part_, value_);
      END IF;
   END IF;
END Validate_Codepart___;


PROCEDURE Check_Combination___ (
   codestring_rec_    IN Accounting_Codestr_API.CodestrRec,
   company_           IN VARCHAR2,
   user_group_        IN VARCHAR2,
   gl_update_         IN VARCHAR2 DEFAULT 'FALSE')
IS
   combination_text_   VARCHAR2(300);
   param_com_usgr_     VARCHAR2(300);
   internal_code_part_ VARCHAR2(200) := Accounting_Code_Parts_API.Get_Codepart_Function_Db(company_, 'INTERN');

   CURSOR comb_control IS
      SELECT a.allowed, decode(a.allowed,'Y',1,0) sort_col, a.comb_rule_id
      FROM   accounting_codestr_comb_tab a,
             codestring_comb_tab b
      WHERE  a.posting_combination_id = b.posting_combination_id
      AND    a.company                = company_
      AND    a.user_group             = user_group_
      AND    codestring_rec_.code_a LIKE account
      AND    ((internal_code_part_ = 'B' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_b, chr(0)) LIKE NVL(decode(codestring_rec_.code_b,NULL,(REPLACE(b.code_b,'_%','-%')),b.code_b),chr(0))))
      AND    ((internal_code_part_ = 'C' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_c, chr(0)) LIKE NVL(decode(codestring_rec_.code_c,NULL,(REPLACE(b.code_c,'_%','-%')),b.code_c),chr(0))))
      AND    ((internal_code_part_ = 'D' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_d, chr(0)) LIKE NVL(decode(codestring_rec_.code_d,NULL,(REPLACE(b.code_d,'_%','-%')),b.code_d),chr(0))))
      AND    ((internal_code_part_ = 'E' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_e, chr(0)) LIKE NVL(decode(codestring_rec_.code_e,NULL,(REPLACE(b.code_e,'_%','-%')),b.code_e),chr(0))))
      AND    ((internal_code_part_ = 'F' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_f, chr(0)) LIKE NVL(decode(codestring_rec_.code_f,NULL,(REPLACE(b.code_f,'_%','-%')),b.code_f),chr(0))))
      AND    ((internal_code_part_ = 'G' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_g, chr(0)) LIKE NVL(decode(codestring_rec_.code_g,NULL,(REPLACE(b.code_g,'_%','-%')),b.code_g),chr(0))))
      AND    ((internal_code_part_ = 'H' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_h, chr(0)) LIKE NVL(decode(codestring_rec_.code_h,NULL,(REPLACE(b.code_h,'_%','-%')),b.code_h),chr(0))))
      AND    ((internal_code_part_ = 'I' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_i, chr(0)) LIKE NVL(decode(codestring_rec_.code_i,NULL,(REPLACE(b.code_i,'_%','-%')),b.code_i),chr(0))))
      AND    ((internal_code_part_ = 'J' AND gl_update_ = 'TRUE') OR (NVL(codestring_rec_.code_j, chr(0)) LIKE NVL(decode(codestring_rec_.code_j,NULL,(REPLACE(b.code_j,'_%','-%')),b.code_j),chr(0))))
      AND    NVL(codestring_rec_.process_code, CHR(0)) LIKE NVL(decode(codestring_rec_.process_code,
                                                                       NULL, (REPLACE(REPLACE(a.process_code,'>NU#LL<',''),'_%','-%')),
                                                                       REPLACE(a.process_code,'>NU#LL<','')),
                                                                CHR(0))
      ORDER BY 2; 

   rec_   comb_control%ROWTYPE;
BEGIN
   combination_text_ := codestring_rec_.code_a ||'/'||NVL(codestring_rec_.code_b,'-')||'/'||NVL(codestring_rec_.code_c,'-')||'/'||NVL(codestring_rec_.code_d,'-')
   ||'/'||NVL(codestring_rec_.code_e,'-')||'/'||NVL(codestring_rec_.code_f,'-')||'/'||NVL(codestring_rec_.code_g,'-')||'/'||NVL(codestring_rec_.code_h,'-')
   ||'/'||NVL(codestring_rec_.code_i,'-')||'/'||NVL(codestring_rec_.code_j,'-')||'/'||NVL(codestring_rec_.process_code,'-')||'/';

   param_com_usgr_   := Language_SYS.Translate_Constant(lu_name_,'COMUSRGRCOMB: for user group :P1 in company :P2.',
                          NULL,
                          user_group_,
                          company_);

   OPEN  comb_control;
   FETCH comb_control INTO rec_;
   IF (comb_control%NOTFOUND) THEN
      CLOSE comb_control;
      Error_SYS.Appl_General(lu_name_,'INVCOMB2: Code string combination ":P1" is not included in any one of the allowed combination rules :P2', 
                     combination_text_,
                     param_com_usgr_);
   END IF;
   CLOSE comb_control;

   IF (rec_.allowed = 'N' ) THEN
      Error_SYS.Appl_General(lu_name_,'INVCOMB3: Code string combination ":P1" is invalid according to Combination Rule ID ":P2" :P3', 
                     combination_text_,
                     TO_CHAR(rec_.comb_rule_id),
                     param_com_usgr_);
   END IF;
END Check_Combination___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   dummy_val_     VARCHAR2(50):= 1;
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('ALLOWED', SUBSTR(Fin_Allowed_API.Decode('N'),1,200), attr_);
   Client_SYS.Add_To_Attr('ACCOUNT', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_B', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_C', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_D', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_E', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_F', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_G', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_H', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_I', '%', attr_);
   Client_SYS.Add_To_Attr('CODE_J', '%', attr_);
   Client_SYS.Add_To_Attr('PROCESS_CODE', '%', attr_);
   Client_SYS.Add_To_Attr('POSTING_COMBINATION_ID', dummy_val_, attr_);   
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT ACCOUNTING_CODESTR_COMB_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   comb_rule_id_              NUMBER;
BEGIN 
   Comb_Rule_Id_API.Get_Next_Rule_Id(comb_rule_id_, newrec_.company);
   newrec_.comb_rule_id := comb_rule_id_;
   Error_SYS.Check_Not_Null(lu_name_, 'COMB_RULE_ID', newrec_.comb_rule_id);
   Client_SYS.Add_To_Attr('COMB_RULE_ID' , comb_rule_id_ , attr_);
   -- 147828, Begin.
   Client_SYS.Add_To_Attr('POSTING_COMBINATION_ID', newrec_.posting_combination_id, attr_);
   -- 147828, End.
   super(objid_, objversion_, newrec_, attr_);
END Insert___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     accounting_codestr_comb_tab%ROWTYPE,
   newrec_     IN OUT accounting_codestr_comb_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   -- 147828, Begin.
   Client_SYS.Add_To_Attr('POSTING_COMBINATION_ID', newrec_.posting_combination_id, attr_);
   -- 147828, End.
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
END Update___;

-- Check_Exist___
--   Check if a specific LU-instance already exist in the database.
FUNCTION Check_Exist___ (
   company_      IN VARCHAR2,
   user_group_   IN VARCHAR2,
   account_      IN VARCHAR2,
   code_b_       IN VARCHAR2,
   code_c_       IN VARCHAR2,
   code_d_       IN VARCHAR2,
   code_e_       IN VARCHAR2,
   code_f_       IN VARCHAR2,
   code_g_       IN VARCHAR2,
   code_h_       IN VARCHAR2,
   code_i_       IN VARCHAR2,
   code_j_       IN VARCHAR2,
   process_code_ IN VARCHAR2) RETURN BOOLEAN
IS
   codestring_rec_            Accounting_Codestr_API.CodestrRec;
   posting_combination_id_    NUMBER;   
BEGIN
   codestring_rec_.code_a := account_;
   codestring_rec_.code_b := code_b_;
   codestring_rec_.code_c := code_c_;
   codestring_rec_.code_d := code_d_;
   codestring_rec_.code_e := code_e_;
   codestring_rec_.code_f := code_f_;   
   codestring_rec_.code_g := code_g_;
   codestring_rec_.code_h := code_h_;
   codestring_rec_.code_i := code_i_;
   codestring_rec_.code_j := code_j_;
   
   Codestring_Comb_API.Get_Combination(posting_combination_id_, codestring_rec_);
   
   RETURN Check_Exist___(company_,
                         user_group_,
                         posting_combination_id_,
                         process_code_); 
END Check_Exist___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_codestr_comb_tab%ROWTYPE,
   newrec_ IN OUT accounting_codestr_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   -- this indicator rec is used to check whether the code string is changed.
   TYPE Codestr_Indicator_Rec IS RECORD (
      code_a               BOOLEAN := FALSE,
      code_b               BOOLEAN := FALSE,
      code_c               BOOLEAN := FALSE,
      code_d               BOOLEAN := FALSE,
      code_e               BOOLEAN := FALSE,
      code_f               BOOLEAN := FALSE,
      code_g               BOOLEAN := FALSE,
      code_h               BOOLEAN := FALSE,
      code_i               BOOLEAN := FALSE,
      code_j               BOOLEAN := FALSE);
      
   ptr_               NUMBER;
   name_              VARCHAR2(30);
   value_             VARCHAR2(2000);   
   codestrrec_        Accounting_Codestr_API.CodestrRec;
   codestr_ind_rec_   Codestr_Indicator_Rec;
BEGIN
   IF (App_Context_SYS.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(newrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;   
   ptr_    := NULL;
   -- get the codestring for update.
   IF (newrec_.posting_combination_id IS NOT NULL) THEN
      Codestring_Comb_API.Get_Posting_Combination(codestrrec_, newrec_.posting_combination_id);
   END IF;
   
   -- when calling from external files interface, there will be two entries for code string. 
   -- one from prepare_insert and one from the attribute string. so need to fetch the code string in a loop.
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'ACCOUNT') THEN
         codestrrec_.code_a := value_;
         codestr_ind_rec_.code_a := TRUE;
      ELSIF (name_ = 'CODE_B') THEN
         codestrrec_.code_b := value_;
         codestr_ind_rec_.code_b := TRUE;
      ELSIF (name_ = 'CODE_C') THEN
         codestrrec_.code_c := value_;
         codestr_ind_rec_.code_c := TRUE;
      ELSIF (name_ = 'CODE_D') THEN
         codestrrec_.code_d := value_;
         codestr_ind_rec_.code_d := TRUE;
      ELSIF (name_ = 'CODE_E') THEN
         codestrrec_.code_e := value_;
         codestr_ind_rec_.code_e := TRUE;
      ELSIF (name_ = 'CODE_F') THEN
         codestrrec_.code_f := value_;
         codestr_ind_rec_.code_f := TRUE;
      ELSIF (name_ = 'CODE_G') THEN
         codestrrec_.code_g := value_;
         codestr_ind_rec_.code_g := TRUE;
      ELSIF (name_ = 'CODE_H') THEN
         codestrrec_.code_h := value_;
         codestr_ind_rec_.code_h := TRUE;
      ELSIF (name_ = 'CODE_I') THEN
         codestrrec_.code_i := value_;
         codestr_ind_rec_.code_i := TRUE;
      ELSIF (name_ = 'CODE_J') THEN
         codestrrec_.code_j := value_;      
         codestr_ind_rec_.code_j := TRUE;
      END IF;
   END LOOP;
   
   IF (codestr_ind_rec_.code_a) THEN
      Validate_Codepart___(newrec_.company, 'A',codestrrec_.code_a);
   END IF;
   
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', codestrrec_.code_a);
   
   IF (codestr_ind_rec_.code_b) THEN
      Validate_Codepart___(newrec_.company, 'B',codestrrec_.code_b);
   END IF;
   IF (codestr_ind_rec_.code_c) THEN
      Validate_Codepart___(newrec_.company, 'C',codestrrec_.code_c);
   END IF;
   IF (codestr_ind_rec_.code_d) THEN
      Validate_Codepart___(newrec_.company, 'D',codestrrec_.code_d);
   END IF;
   IF (codestr_ind_rec_.code_e) THEN
      Validate_Codepart___(newrec_.company, 'E',codestrrec_.code_e);
   END IF;
   IF (codestr_ind_rec_.code_f) THEN
      Validate_Codepart___(newrec_.company, 'F',codestrrec_.code_f);
   END IF;
   IF (codestr_ind_rec_.code_g) THEN
      Validate_Codepart___(newrec_.company, 'G',codestrrec_.code_g);
   END IF;
   IF (codestr_ind_rec_.code_h) THEN
      Validate_Codepart___(newrec_.company, 'H',codestrrec_.code_h);
   END IF;
   IF (codestr_ind_rec_.code_i) THEN
      Validate_Codepart___(newrec_.company, 'I',codestrrec_.code_i);
   END IF;
   IF (codestr_ind_rec_.code_j) THEN
      Validate_Codepart___(newrec_.company, 'J',codestrrec_.code_j);
   END IF;
   
   Codestring_Comb_API.Get_Combination(newrec_.posting_combination_id, codestrrec_);
   
   IF (newrec_.process_code IS NULL) THEN
       newrec_.process_code := '>NU#LL<';
   END IF;    
   
   super(oldrec_, newrec_, indrec_, attr_);  
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_codestr_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS       
BEGIN   
   IF (Client_SYS.Item_Exist('CODE_PART', attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'CODE_PART');      
   END IF;
   super(newrec_, indrec_, attr_); 
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     accounting_codestr_comb_tab%ROWTYPE,
   newrec_ IN OUT accounting_codestr_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS    
BEGIN      
   IF (Client_SYS.Item_Exist('CODE_PART', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'CODE_PART');      
   END IF;      
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Update___;

-- Note: Use Copy_To_Company_Util_API.Get_Next_Record_Sep_Val method instead.
@Deprecated
FUNCTION Get_Next_Record_Sep_Val___ (
   value_ IN OUT VARCHAR2,
   ptr_   IN OUT NUMBER,  
   attr_  IN     VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_);
END Get_Next_Record_Sep_Val___; 

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN accounting_codestr_comb_tab%ROWTYPE )
IS
BEGIN
   IF (App_Context_Sys.Find_Value(lu_name_||'.copy_to_company_', 'FALSE') != 'TRUE') THEN
      IF (Company_Basic_Data_Window_API.Check_Copy_From_Company(remrec_.company, lu_name_)) THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

PROCEDURE Copy_To_Companies_For_Svc___ (
   source_company_      IN VARCHAR2,
   target_company_list_ IN VARCHAR2,
   user_group_list_     IN VARCHAR2,
   post_comb_id_list_   IN VARCHAR2,
   process_code_list_   IN VARCHAR2,
   update_method_list_  IN VARCHAR2,
   log_id_              IN NUMBER,
   attr_                IN VARCHAR2 DEFAULT NULL)
IS
   TYPE accounting_codestr_comb IS TABLE OF accounting_codestr_comb_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;   
   ptr_                      NUMBER;
   ptr1_                     NUMBER;
   ptr2_                     NUMBER;
   i_                        NUMBER;
   update_method_            VARCHAR2(20);
   value_                    VARCHAR2(2000);
   target_company_           accounting_codestr_comb_tab.company%TYPE;
   ref_acc_codestr_comb_     accounting_codestr_comb;
   ref_attr_                 attr;
   attr_value_               VARCHAR2(32000) := NULL;
BEGIN   
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, user_group_list_) LOOP
      ref_acc_codestr_comb_(i_).user_group := value_;
      i_ := i_ + 1;
   END LOOP;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, post_comb_id_list_) LOOP
      ref_acc_codestr_comb_(i_).posting_combination_id := value_;
      i_ := i_ + 1;
   END LOOP;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, process_code_list_) LOOP
      ref_acc_codestr_comb_(i_).process_code := value_;
      i_ := i_ + 1;
   END LOOP;

   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;

   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_acc_codestr_comb_.FIRST..ref_acc_codestr_comb_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_acc_codestr_comb_(j_).user_group,
                                 ref_acc_codestr_comb_(j_).posting_combination_id,
                                 ref_acc_codestr_comb_(j_).process_code,
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;     
END Copy_To_Companies_For_Svc___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Combination__ (
   codestring_rec_    IN Accounting_Codestr_API.CodestrRec,
   company_           IN VARCHAR2,
   user_group_        IN VARCHAR2 )
IS
BEGIN
   Check_Combination___(codestring_rec_,
                        company_,
                        user_group_);
END Check_Combination__;

PROCEDURE Create_Client_Mapping__ (
   client_window_ IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
 
   clmapprec_    Client_Mapping_API.Client_Mapping_Pub;
   clmappdetrec_ Client_Mapping_API.Client_Mapping_Detail_Pub;
BEGIN
   clmapprec_.module := module_;
   clmapprec_.lu := lu_name_;
   clmapprec_.mapping_id := 'CCD_ACCOUNTINGCODESTRCOMB';
   clmapprec_.client_window := client_window_;  
   clmapprec_.rowversion := sysdate;
   Client_Mapping_API.Insert_Mapping(clmapprec_);

   clmappdetrec_.module := module_;
   clmappdetrec_.lu := lu_name_;
   clmappdetrec_.mapping_id :=  'CCD_ACCOUNTINGCODESTRCOMB';
   clmappdetrec_.column_type := 'NORMAL';  
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := sysdate;  
   
   clmappdetrec_.column_id := 'C1' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.USER_GROUP';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C2' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.ACCOUNT';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C3' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_B';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C4' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_C';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C5' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_D';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C6' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_E';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C7' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_F';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C8' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_G';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C9' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_H';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C10' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_I';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C11' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.CODE_J';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C12' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.PROCESS_CODE';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C13' ;
   clmappdetrec_.translation_link := 'ACCOUNTING_CODESTR_COMB.ALLOWED_DB';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
 
END Create_Client_Mapping__;   

PROCEDURE Create_Company_Reg__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
   
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, 'ACCOUNTING_CODESTR_COMB_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'CCD_ACCOUNTINGCODESTRCOMB',NULL);
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
      module_,'ACCOUNTING_CODESTR_COMB_TAB',
      CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'ACCOUNTING_CODESTR_COMB_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;

PROCEDURE Copy_To_Companies__ (
   source_company_         IN VARCHAR2,
   target_company_         IN VARCHAR2,
   user_group_             IN VARCHAR2,
   posting_combination_id_ IN NUMBER,
   process_code_           IN VARCHAR2,   
   update_method_          IN VARCHAR2,
   log_id_                 IN NUMBER,
   attr_                   IN VARCHAR2 DEFAULT NULL)
IS
   source_rec_              accounting_codestr_comb_tab%ROWTYPE;
   target_rec_              accounting_codestr_comb_tab%ROWTYPE;
   old_target_rec_          accounting_codestr_comb_tab%ROWTYPE;
   log_key_                 VARCHAR2(2000);
   log_detail_status_       VARCHAR2(10);   
   codestr_rec_             Accounting_Codestr_API.CodestrRec;
BEGIN
   Codestring_Comb_API.Get_Posting_Combination(codestr_rec_, posting_combination_id_);   
   log_key_ := user_group_ ||'^'|| codestr_rec_.code_a ||'^'|| codestr_rec_.code_a ||'^'|| codestr_rec_.code_b ||'^'|| codestr_rec_.code_c ||'^'||
               codestr_rec_.code_d ||'^'|| codestr_rec_.code_e ||'^'|| codestr_rec_.code_f ||'^'|| codestr_rec_.code_g ||'^'|| 
               codestr_rec_.code_h ||'^'|| codestr_rec_.code_i ||'^'|| codestr_rec_.code_j ||'^'|| process_code_;
               
   source_rec_ := Get_Object_By_Keys___(source_company_, user_group_, posting_combination_id_, process_code_);
   target_rec_ := source_rec_;
   target_rec_.company := target_company_;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'TRUE');
   old_target_rec_ := Get_Object_By_Keys___(target_company_, user_group_, posting_combination_id_, process_code_);

   IF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source creates a new record which does not exist in the target company
      New___(target_rec_);
      log_detail_status_ := 'CREATED';
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'UPDATE_ALL') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user wants to update the entire record in the target
      target_rec_.rowkey := old_target_rec_.rowkey;
      Modify___(target_rec_);
      log_detail_status_ := 'MODIFIED';    
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NOT NULL) THEN
      -- Source removes a record, the same record is removed in the target company
      Remove___(old_target_rec_);      
      log_detail_status_ := 'REMOVED';      
   ELSIF (source_rec_.rowversion IS NULL AND old_target_rec_.rowversion IS NULL) THEN
      -- Source removes a record, the same record does not exist in the target company to be removed
      Raise_Record_Not_Exist___(target_company_, user_group_, posting_combination_id_, process_code_);
   ELSIF (source_rec_.rowversion IS NOT NULL AND old_target_rec_.rowversion IS NOT NULL AND update_method_ = 'NO_UPDATE') THEN
      -- Source company adds or modifies a record, the same exists in the target company and the user does not wan to update records in the target
      Raise_Record_Exist___(target_rec_);
   END IF;
   IF (Company_Basic_Data_Window_API.Check_Copy_From_Source_Company(target_company_,source_company_, lu_name_)) THEN
      IF log_detail_status_ IN ('CREATED','MODIFIED') THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTINSERT: A record cannot be entered/modified as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      ELSIF log_detail_status_ = 'REMOVED' THEN
         Error_SYS.Record_General(lu_name_, 'NODIRECTREMOVE: A record cannot be removed as :P1 window has been set up for copying data only from source company in Basic Data Synchronization window.', Basic_Data_Window_API.Get_Window(lu_name_));
      END IF;
   END IF;
   App_Context_SYS.Set_Value(lu_name_||'.copy_to_company_', 'FALSE');
   Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_);
EXCEPTION
   WHEN OTHERS THEN
      log_detail_status_ := 'ERROR';
      Copy_Basic_Data_Log_Detail_API.Create_New_Record(log_id_, target_company_, log_key_, log_detail_status_, SQLERRM);
END Copy_To_Companies__;
   
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Copy_To_Companies_ (
   attr_ IN  VARCHAR2 )
IS
   ptr_                         NUMBER;
   name_                        VARCHAR2(200);
   value_                       VARCHAR2(32000);
   company_                     VARCHAR2(100);
   user_group_list_             VARCHAR2(32000);
   posting_combination_id_list_ VARCHAR2(32000);
   process_code_list_           VARCHAR2(32000);
   target_company_list_         VARCHAR2(32000);
   update_method_list_          VARCHAR2(32000);
   copy_type_                   VARCHAR2(100);
   attr1_                       VARCHAR2(32000);
BEGIN
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'COMPANY') THEN
         company_ := value_;
      ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
         target_company_list_ := value_;
      ELSIF (name_ = 'USER_GROUP_LIST') THEN
         user_group_list_ := value_;
      ELSIF (name_ = 'POSTING_COMBINATION_ID_LIST') THEN
         posting_combination_id_list_ := value_;
      ELSIF (name_ = 'PROCESS_CODE_LIST') THEN
         process_code_list_ := value_;         
      ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
         update_method_list_ := value_;
      ELSIF (name_ = 'COPY_TYPE') THEN
         copy_type_ := value_;
      ELSIF (name_ = 'ATTR') THEN
         attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
      END IF;
   END LOOP;
   Copy_To_Companies_(company_,
                      target_company_list_,
                      user_group_list_,
                      posting_combination_id_list_,
                      process_code_list_,
                      update_method_list_,
                      copy_type_,
                      attr1_);
END Copy_To_Companies_;

PROCEDURE Copy_To_Companies_ (
   source_company_              IN VARCHAR2,
   target_company_list_         IN VARCHAR2,
   user_group_list_             IN VARCHAR2,
   posting_combination_id_list_ IN VARCHAR2,
   process_code_list_           IN VARCHAR2,
   update_method_list_          IN VARCHAR2,
   copy_type_                   IN VARCHAR2,
   attr_                        IN VARCHAR2 DEFAULT NULL)
IS
   TYPE accounting_codestr_comb IS TABLE OF accounting_codestr_comb_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE attr IS TABLE OF VARCHAR2 (32000) INDEX BY BINARY_INTEGER;                           
   ptr_                         NUMBER;
   ptr1_                        NUMBER;
   ptr2_                        NUMBER;
   i_                           NUMBER;
   update_method_               VARCHAR2(20);
   value_                       VARCHAR2(2000);
   target_company_              accounting_codestr_comb_tab.company%TYPE;
   ref_accounting_codestr_comb_ accounting_codestr_comb;
   ref_attr_                    attr;
   log_id_                      NUMBER;
   attr_value_                  VARCHAR2(32000) := NULL;
BEGIN
   ptr_  := NULL;
   ptr1_ := NULL;
   ptr2_ := NULL;

   i_    := 0;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, user_group_list_) LOOP
      ref_accounting_codestr_comb_(i_).user_group := value_;
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, posting_combination_id_list_) LOOP
      ref_accounting_codestr_comb_(i_).posting_combination_id := Client_SYS.Attr_Value_To_Number(value_);
      i_ := i_ + 1;
   END LOOP;
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, process_code_list_) LOOP
      ref_accounting_codestr_comb_(i_).process_code := value_;
      i_ := i_ + 1;
   END LOOP;   
   
   i_    := 0;
   ptr_  := NULL;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(value_, ptr_, attr_) LOOP
      ref_attr_(i_) := value_;
      i_ := i_ + 1;
   END LOOP;
   
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Create_New_Record(log_id_, source_company_, copy_type_,lu_name_);
   END IF;
   WHILE Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(target_company_, ptr1_, target_company_list_) LOOP      
      IF (Copy_To_Company_Util_API.Get_Next_Record_Sep_Val(update_method_, ptr2_, update_method_list_)) THEN
         FOR j_ IN ref_accounting_codestr_comb_.FIRST..ref_accounting_codestr_comb_.LAST LOOP
            IF (ref_attr_.FIRST IS NOT NULL) THEN
               attr_value_ := ref_attr_(j_);
            END IF;            
            Copy_To_Companies__ (source_company_,  
                                 target_company_,
                                 ref_accounting_codestr_comb_(j_).user_group,
                                 ref_accounting_codestr_comb_(j_).posting_combination_id,  
                                 ref_accounting_codestr_comb_(j_).process_code,  
                                 update_method_,
                                 log_id_,
                                 attr_value_);
         END LOOP;
      END IF;
   END LOOP;
   IF (target_company_list_ IS NOT NULL) THEN
      Copy_Basic_Data_Log_API.Update_Status(log_id_);
   END IF;
END Copy_To_Companies_;

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
@UncheckedAccess
PROCEDURE Exist (
   company_      IN VARCHAR2,
   user_group_   IN VARCHAR2,
   account_      IN VARCHAR2,
   code_b_       IN VARCHAR2,
   code_c_       IN VARCHAR2,
   code_d_       IN VARCHAR2,
   code_e_       IN VARCHAR2,
   code_f_       IN VARCHAR2,
   code_g_       IN VARCHAR2,
   code_h_       IN VARCHAR2,
   code_i_       IN VARCHAR2,
   code_j_       IN VARCHAR2,
   process_code_ IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   IF (NOT Check_Exist___(company_, user_group_, account_, code_b_, code_c_, code_d_, code_e_, code_f_, code_g_, code_h_, code_i_, code_j_, process_code_)) THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist;


PROCEDURE Combination_Control (
   codestring_rec_    IN Accounting_Codestr_API.CodestrRec,
   company_           IN VARCHAR2,
   user_group_        IN VARCHAR2,
   gl_update_         IN VARCHAR2 DEFAULT 'FALSE')
IS
BEGIN   
   IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
      Check_Combination___(codestring_rec_, company_, user_group_, gl_update_);
   ELSE
      Error_SYS.Appl_General(lu_name_, 'INVAUTH: You are NOT authorized to access this section');
   END IF;
END Combination_Control;


PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS    
   rec_        Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;      
BEGIN   
   rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec('ACCRUL', attr_);
   
   IF (rec_.make_company = 'EXPORT') THEN
      Export___(rec_);      
   ELSIF (rec_.make_company = 'IMPORT') THEN
      IF (rec_.action = 'NEW') THEN
         Import___(rec_);         
      ELSIF (rec_.action = 'DUPLICATE') THEN 
         Copy___(rec_);         
      END IF;      
   END IF;
END Make_Company;

FUNCTION Get_Posting_Combination_Id(
   obj_id_ IN VARCHAR2) RETURN NUMBER
IS
   posting_combination_id_  accounting_codestr_comb_tab.posting_combination_id%TYPE;

   CURSOR get_id is
      SELECT  posting_combination_id
      FROM    accounting_codestr_comb_tab 
      WHERE   rowid   = obj_id_ ;
BEGIN
   OPEN  get_id;
   FETCH get_id into posting_combination_id_;
   IF (get_id%NOTFOUND) THEN      
      posting_combination_id_ := null;
   END IF;
   CLOSE get_id;

   RETURN posting_combination_id_;
END Get_Posting_Combination_Id ;

PROCEDURE Copy_To_Companies_For_Svc (
   attr_              IN VARCHAR2,
   run_in_background_ IN BOOLEAN,
   log_id_            IN NUMBER DEFAULT NULL)
IS
   ptr_                    NUMBER;
   name_                   VARCHAR2(200);
   value_                  VARCHAR2(32000);
   source_company_         VARCHAR2(100);
   process_code_list_      VARCHAR2(2000);
   post_comb_id_list_      VARCHAR2(2000);
   user_group_list_        VARCHAR2(2000);
   target_company_list_    VARCHAR2(2000);
   update_method_list_     VARCHAR2(2000);
   attr1_                  VARCHAR2(32000);
   run_in_background_attr_ VARCHAR2(32000);
BEGIN   
   IF (run_in_background_) THEN
      run_in_background_attr_ := attr_;
      Transaction_SYS.Deferred_Call('Accounting_Codestr_Comb_API.Copy_To_Companies_', run_in_background_attr_, Language_SYS.Translate_Constant(lu_name_, 'COPYDATA: Copy Basic Data')); 
   ELSE
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'SOURCE_COMPANY') THEN
            source_company_ := value_;
         ELSIF (name_ = 'TARGET_COMPANY_LIST') THEN
            target_company_list_ := value_;
         ELSIF (name_ = 'USER_GROUP_LIST') THEN
            user_group_list_ := value_;
         ELSIF (name_ = 'POSTING_COMBINATION_ID_LIST') THEN
            post_comb_id_list_ := value_;
         ELSIF (name_ = 'PROCESS_CODE_LIST') THEN
            process_code_list_ := value_;
         ELSIF (name_ = 'UPDATE_METHOD_LIST') THEN
            update_method_list_ := value_;
         ELSIF (name_ = 'ATTR') THEN
            attr1_ := value_||chr(30)||substr(attr_, ptr_,length(attr_)-1);
         END IF;
      END LOOP;
      Copy_To_Companies_For_Svc___(source_company_,
                                   target_company_list_,
                                   user_group_list_,
                                   post_comb_id_list_,
                                   process_code_list_,
                                   update_method_list_,
                                   log_id_,
                                   attr1_);
   END IF;
END Copy_To_Companies_For_Svc;

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_    IN VARCHAR2)
IS
BEGIN  
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN
      DELETE 
         FROM COMB_RULE_ID_TAB
         WHERE company = company_; 
      DELETE
         FROM ACCOUNTING_CODESTR_COMB_TAB
         WHERE company = company_;
   END IF;
END Remove_Company;

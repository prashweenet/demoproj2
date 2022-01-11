-----------------------------------------------------------------------------
--
--  Logical unit: ApproverCombRuleDetail
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

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     approver_comb_rule_detail_tab%ROWTYPE,
   newrec_ IN OUT approver_comb_rule_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   codestring_             Accounting_Codestr_API.CodestrRec;
BEGIN
   codestring_.code_a := newrec_.account;
   codestring_.code_b := newrec_.code_b;
   codestring_.code_c := newrec_.code_c;
   codestring_.code_d := newrec_.code_d;
   codestring_.code_e := newrec_.code_e;
   codestring_.code_f := newrec_.code_f;
   codestring_.code_g := newrec_.code_g;
   codestring_.code_h := newrec_.code_h;
   codestring_.code_i := newrec_.code_i;
   codestring_.code_j := newrec_.code_j;
   Codestring_Comb_API.Get_Combination( newrec_.posting_combination_id, codestring_ );
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.account IS NOT NULL) THEN
      IF instr(newrec_.account,'%') = 0 AND instr(newrec_.account,'_') = 0 THEN
         Accounting_Code_Part_A_API.Exist(newrec_.company, 'A', newrec_.account);
      END IF;
   END IF;

   IF (newrec_.code_b IS NOT NULL) THEN
      IF instr(newrec_.code_b,'%') = 0 AND instr(newrec_.code_b,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'B', newrec_.code_b);
         
      END IF;
   END IF;
   IF (newrec_.code_c IS NOT NULL) THEN
      IF instr(newrec_.code_c,'%') = 0 AND instr(newrec_.code_c,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'C', newrec_.code_c);
         
      END IF;
   END IF;
   IF (newrec_.code_d IS NOT NULL) THEN
      IF instr(newrec_.code_d,'%') = 0 AND instr(newrec_.code_d,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'D', newrec_.code_d);
         
      END IF;
   END IF;
   IF (newrec_.code_e IS NOT NULL) THEN
      IF instr(newrec_.code_e,'%') = 0 AND instr(newrec_.code_e,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'E', newrec_.code_e);
         
      END IF;
   END IF;
   IF (newrec_.code_f IS NOT NULL) THEN
      IF instr(newrec_.code_f,'%') = 0 AND instr(newrec_.code_f,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'F', newrec_.code_f);
         
      END IF;
   END IF;
   IF (newrec_.code_g IS NOT NULL) THEN
      IF instr(newrec_.code_g,'%') = 0 AND instr(newrec_.code_g,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'G', newrec_.code_g);
         
      END IF;
   END IF;
   IF (newrec_.code_h IS NOT NULL) THEN
      IF instr(newrec_.code_h,'%') = 0 AND instr(newrec_.code_h,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'H', newrec_.code_h);
         
      END IF;
   END IF;
   IF (newrec_.code_i IS NOT NULL) THEN
      IF instr(newrec_.code_i,'%') = 0 AND instr(newrec_.code_i,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'I', newrec_.code_i);
         
      END IF;
   END IF;
   IF (newrec_.code_j IS NOT NULL) THEN
      IF instr(newrec_.code_j,'%') = 0 AND instr(newrec_.code_j,'_') = 0 THEN
         Accounting_Code_Part_Value_API.Exist(newrec_.company, 'J', newrec_.code_j);
         
      END IF;
   END IF;
--   User_Finance_API.Exist(newrec_.company, Fnd_Session_API.Get_Fnd_User);
END Check_Common___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('POSTING_COMBINATION_ID', 1, attr_);
   Client_SYS.Add_To_Attr('ACCOUNT','%',attr_);
   Client_SYS.Add_To_Attr('CODE_B','%',attr_);
   Client_SYS.Add_To_Attr('CODE_C','%',attr_);
   Client_SYS.Add_To_Attr('CODE_D','%',attr_);
   Client_SYS.Add_To_Attr('CODE_E','%',attr_);
   Client_SYS.Add_To_Attr('CODE_F','%',attr_);
   Client_SYS.Add_To_Attr('CODE_G','%',attr_);
   Client_SYS.Add_To_Attr('CODE_H','%',attr_);
   Client_SYS.Add_To_Attr('CODE_I','%',attr_);
   Client_SYS.Add_To_Attr('CODE_J','%',attr_);
END Prepare_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Is_Allowed (
   company_                IN VARCHAR2,
   combination_rule_id_    IN VARCHAR2,
   posting_combination_id_ IN NUMBER) RETURN VARCHAR2
IS 
   dummy_   NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Approver_Comb_Rule_Detail_tab a,
             codestring_combination b   
      WHERE  b.posting_combination_id = posting_combination_id_
      AND    a.company                = company_
      AND    b.account         LIKE a.account
      AND    NVL(b.code_b,' ') LIKE NVL(a.code_b, ' ')
      AND    NVL(b.code_c,' ') LIKE NVL(a.code_c, ' ')
      AND    NVL(b.code_d,' ') LIKE NVL(a.code_d, ' ')
      AND    NVL(b.code_e,' ') LIKE NVL(a.code_e, ' ')
      AND    NVL(b.code_f,' ') LIKE NVL(a.code_f, ' ')
      AND    NVL(b.code_g,' ') LIKE NVL(a.code_g, ' ')
      AND    NVL(b.code_h,' ') LIKE NVL(a.code_h, ' ')
      AND    NVL(b.code_i,' ') LIKE NVL(a.code_i, ' ')
      AND    NVL(b.code_j,' ') LIKE NVL(a.code_j, ' ')
      AND    a.allowed_comb    = 'Y'
      AND    a.combination_rule_id      = combination_rule_id_
      AND NOT EXISTS ( SELECT 1
                       FROM   Approver_Comb_Rule_Detail_tab a1,
                              codestring_combination b1     
                       WHERE  b1.account LIKE a1.account
                       AND    NVL(b1.code_b, ' ') LIKE NVL(a1.code_b, ' ')
                       AND    NVL(b1.code_c, ' ') LIKE NVL(a1.code_c, ' ')
                       AND    NVL(b1.code_d, ' ') LIKE NVL(a1.code_d, ' ')
                       AND    NVL(b1.code_e, ' ') LIKE NVL(a1.code_e, ' ')
                       AND    NVL(b1.code_f, ' ') LIKE NVL(a1.code_f, ' ')
                       AND    NVL(b1.code_g, ' ') LIKE NVL(a1.code_g, ' ')
                       AND    NVL(b1.code_h, ' ') LIKE NVL(a1.code_h, ' ')
                       AND    NVL(b1.code_i, ' ') LIKE NVL(a1.code_i, ' ')
                       AND    NVL(b1.code_j, ' ') LIKE NVL(a1.code_j, ' ')
                       AND    a1.allowed_comb     = 'N'
                       AND    a1.combination_rule_id    = a.combination_rule_id
                       AND    a1.company                = a.company
                       AND    b1.posting_combination_id = b.posting_combination_id );
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Is_Allowed;

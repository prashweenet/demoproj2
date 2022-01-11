-----------------------------------------------------------------------------
--
--  Logical unit: CodestringComb
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  XXXXXX  XXXX   Created.
--  970717  SLKO   Converted to Foundation 1.2.2d
--  990419  JPS    Performed Template Changes.(Foundation 2.2.1)
--  000908  HiMu   Added General_SYS.Init_Method
--  001004  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  010612  JeGu   Bug #22421 Changed procedure Get_Combination.
--                 Added column codestring to view and procedures/functions
--                 Copied some procedures/functions from posting_combination_api.
--                 New view CODESTRING_COMBINATION
--   120806  Maaylk  Bug 101320, Removed calls to Client_SYS.
--  130816  Clstlk  Bug 111221, Corrected functions without RETURN statement in all code paths.
--  131031  Umdolk  PBFI-1936, Refactoring
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     codestring_comb_tab%ROWTYPE,
   newrec_ IN OUT codestring_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   codestring_value_   VARCHAR2(200) := NULL;
BEGIN   
   super(oldrec_, newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('ACCOUNT', newrec_.account, codestring_value_);
   Client_SYS.Add_To_Attr('CODE_B',  newrec_.code_b,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_C',  newrec_.code_c,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_D',  newrec_.code_d,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_E',  newrec_.code_e,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_F',  newrec_.code_f,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_G',  newrec_.code_g,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_H',  newrec_.code_h,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_I',  newrec_.code_i,  codestring_value_);
   Client_SYS.Add_To_Attr('CODE_J',  newrec_.code_j,  codestring_value_);
   newrec_.codestring := codestring_value_;   
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Combination (
   posting_combination_id_ OUT NUMBER,
   codestring_             IN  Accounting_Codestr_API.CodestrRec )
IS
   posting_comb_       NUMBER;
   codestring_value_   VARCHAR2(200) := NULL;
   CURSOR get_next_id IS
      SELECT Codestring_comb_seq.NEXTVAL
      FROM   DUAL;
   CURSOR check_combination IS
      SELECT posting_combination_id
      FROM   codestring_comb_tab
      WHERE  codestring = codestring_value_;

   field_separator_    CONSTANT VARCHAR2(1)  := Client_SYS.field_separator_;
   record_separator_   CONSTANT VARCHAR2(1)  := Client_SYS.record_separator_;
BEGIN
   codestring_value_ := codestring_value_||'ACCOUNT'||field_separator_||codestring_.code_a||record_separator_;
   codestring_value_ := codestring_value_||'CODE_B'||field_separator_||codestring_.code_b||record_separator_;
   codestring_value_ := codestring_value_||'CODE_C'||field_separator_||codestring_.code_c||record_separator_;
   codestring_value_ := codestring_value_||'CODE_D'||field_separator_||codestring_.code_d||record_separator_;
   codestring_value_ := codestring_value_||'CODE_E'||field_separator_||codestring_.code_e||record_separator_;
   codestring_value_ := codestring_value_||'CODE_F'||field_separator_||codestring_.code_f||record_separator_;
   codestring_value_ := codestring_value_||'CODE_G'||field_separator_||codestring_.code_g||record_separator_;
   codestring_value_ := codestring_value_||'CODE_H'||field_separator_||codestring_.code_h||record_separator_;
   codestring_value_ := codestring_value_||'CODE_I'||field_separator_||codestring_.code_i||record_separator_;                        
   codestring_value_ := codestring_value_||'CODE_J'||field_separator_||codestring_.code_j||record_separator_;   

   OPEN check_combination;
   FETCH check_combination INTO posting_combination_id_;
   IF (check_combination%NOTFOUND) THEN
      OPEN  get_next_id;
      FETCH get_next_id INTO posting_comb_;
      CLOSE get_next_id;
      posting_combination_id_ := posting_comb_;
      INSERT
         INTO codestring_comb_tab (
            posting_combination_id,
            account,
            code_b,
            code_c,
            code_d,
            code_e,
            code_f,
            code_g,
            code_h,
            code_i,
            code_j,
            codestring,
            rowversion )
         VALUES (
            posting_combination_id_,
            codestring_.code_a,
            codestring_.code_b,
            codestring_.code_c,
            codestring_.code_d,
            codestring_.code_e,
            codestring_.code_f,
            codestring_.code_g,
            codestring_.code_h,
            codestring_.code_i,
            codestring_.code_j,
            codestring_value_,
            sysdate );
      CLOSE check_combination;
   ELSE
      CLOSE check_combination;
   END IF;
END Get_Combination;


@UncheckedAccess
FUNCTION Get_Codepart_Value (
   posting_combination_id_ IN NUMBER,
   codepart_               IN VARCHAR2 ) RETURN VARCHAR2
IS
   lu_rec_ CODESTRING_COMB_TAB%ROWTYPE;
   CURSOR getrec IS
      SELECT *
      FROM   CODESTRING_COMB_TAB
      WHERE  posting_combination_id = posting_combination_id_;
BEGIN
   OPEN getrec;
   FETCH getrec INTO lu_rec_;
   CLOSE getrec;
   IF (codepart_ = 'A') THEN
      RETURN(lu_rec_.account);
   ELSIF (codepart_ = 'B') THEN
      RETURN(lu_rec_.code_b);
   ELSIF (codepart_ = 'C') THEN
      RETURN(lu_rec_.code_c);
   ELSIF (codepart_ = 'D') THEN
      RETURN(lu_rec_.code_d);
   ELSIF (codepart_ = 'E') THEN
      RETURN(lu_rec_.code_e);
   ELSIF (codepart_ = 'F') THEN
      RETURN(lu_rec_.code_f);
   ELSIF (codepart_ = 'G') THEN
      RETURN(lu_rec_.code_g);
   ELSIF (codepart_ = 'H') THEN
      RETURN(lu_rec_.code_h);
   ELSIF (codepart_ = 'I') THEN
      RETURN(lu_rec_.code_i);
   ELSIF (codepart_ = 'J') THEN
      RETURN(lu_rec_.code_j);
   ELSE
      RETURN NULL;   
   END IF;
END Get_Codepart_Value;




PROCEDURE Get_Posting_Combination (
   codestring_             OUT VARCHAR2,
   posting_combination_id_ IN  NUMBER )
IS
   CURSOR Get_Comb IS
      SELECT codestring
      FROM   CODESTRING_COMB_TAB
      WHERE  posting_combination_id = posting_combination_id_;
BEGIN
   OPEN Get_Comb;
   FETCH Get_Comb INTO codestring_;
   IF (Get_Comb%NOTFOUND) THEN
      CLOSE Get_Comb;
      Error_SYS.Record_General(lu_name_,'NO_COMB: The ID has no codestring');
   ELSE
      CLOSE Get_Comb;
   END IF;
END Get_Posting_Combination;


PROCEDURE Get_Posting_Combination (
   codestring_rec_         OUT Accounting_Codestr_API.CodestrRec,
   posting_combination_id_ IN  NUMBER )
IS
   CURSOR Get_String_Combination IS
      SELECT account,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j
      FROM   CODESTRING_COMB_TAB
      WHERE posting_combination_id = posting_combination_id_;
BEGIN
   OPEN  Get_String_Combination;
   FETCH Get_String_Combination INTO codestring_rec_.code_a,
                                     codestring_rec_.code_b,
                                     codestring_rec_.code_c,
                                     codestring_rec_.code_d,
                                     codestring_rec_.code_e,
                                     codestring_rec_.code_f,
                                     codestring_rec_.code_g,
                                     codestring_rec_.code_h,
                                     codestring_rec_.code_i,
                                     codestring_rec_.code_j;
   IF (Get_String_Combination%NOTFOUND) THEN
      Error_SYS.Record_General(lu_name_,'NO_COMB: The ID has no codestring');
      CLOSE Get_String_Combination;
   ELSE
      CLOSE Get_String_Combination;
   END IF;
END Get_Posting_Combination;



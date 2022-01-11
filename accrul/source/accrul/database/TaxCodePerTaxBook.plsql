-----------------------------------------------------------------------------
--
--  Logical unit: TaxCodePerTaxBook
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021101  risrlk created IID - ITFI101E
--  021115  risrlk SALSA IID - ITFI101E. Enabled cascade delete.
--  021120  RAABLK SALSA IID - ITFI101E.Added Function Check_Tax_Code_Exist.
--  030121  RISRLK ITFI101E Statutory_Fee_API.Exist was replaced with Statutory_Fee_API.Exist_Deductible
--  030326  risrlk RDFI140NF - Changed Db values
--  030505  risrlk corrected db_value change errors.
--  040329  Gepelk 2004 SP1 Merge.
--  080421  NiFelk Bug 73180, Corrected in Validate_Insert()
--  151007  chiblk  STRFI-200, New__ changed to New___ in New_Rec
--  180510  Kgamlk Bug 140923, Merged App9 correction, Triggered an error message when only inserting a Withholding tax code to tax book of tax direction Received and Tax code All.
--  180725  Waudlk Bug 142410, Removed validations for WHT tax codes.
--  191030  Kagalk GESPRING20-1261, Added changes for tax_book_and_numbering.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_code_per_tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   tax_book_rec_  Tax_Book_API.Public_Rec;
BEGIN
   super(newrec_, indrec_, attr_);
   tax_book_rec_ := Tax_Book_API.Get(newrec_.company, newrec_.tax_book_id);
      
   IF Validate_Insert(newrec_.company, newrec_.fee_code, tax_book_rec_.tax_book_base_values, tax_book_rec_.tax_direction_sp) = 'FALSE' THEN
      Error_SYS.Appl_General(lu_name_, 'VIOLTAX: Tax Code can only be defined once for each tax direction');
   END IF;
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     tax_code_per_tax_book_tab%ROWTYPE,
   newrec_ IN OUT tax_code_per_tax_book_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   tax_code_rec_              Statutory_Fee_API.Public_Rec;
   tax_book_rec_              Tax_Book_API.Public_Rec;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   tax_code_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(newrec_.company, newrec_.fee_code, SYSDATE, 'TRUE', 'TRUE', 'FETCH_AND_VALIDATE');   
   tax_book_rec_ := Tax_Book_API.Get(newrec_.company, newrec_.tax_book_id);
   
   IF Validate_Insert(newrec_.company, newrec_.fee_code, tax_book_rec_.tax_book_base_values, tax_book_rec_.tax_direction_sp) = 'FALSE' THEN
      Error_SYS.Appl_General(lu_name_, 'VIOLTAX: Tax Code can only be defined once for each tax direction');
   END IF;
END Check_Update___;

-- Check_Delete_Tax_Book_Rec___
--   Check that raises an error if the fee code in the company is used in Tax Book and the tax code is RESTRICTED
PROCEDURE Check_Delete_Tax_Book_Rec___ (
   company_ IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
   CURSOR fee_code_exist IS
      SELECT count(*)
        FROM Tax_Code_Per_Tax_Book tc, Tax_Book_Tab tb
       WHERE tb.Company = company_
         AND tb.Company = tc.Company
         AND tb.Tax_Book_Id = tc.Tax_Book_Id
         AND tb.tax_book_base_values = 'RESTRICTED'
         AND tc.Fee_Code = fee_code_;
         
   no_of_rec_ NUMBER := 0;   
BEGIN
   OPEN  fee_code_exist;
   FETCH fee_code_exist INTO no_of_rec_;
   CLOSE fee_code_exist;
   IF (no_of_rec_ > 0) THEN
      Error_SYS.Appl_General(lu_name_, 'VIOLDEL: Cannot Delete Tax Code. It is being used by a Tax Book');
   END IF;
END Check_Delete_Tax_Book_Rec___;

PROCEDURE Do_Cascade_Fee_Code___(
   company_    IN VARCHAR2,
   fee_code_   IN VARCHAR2,
   action_     IN VARCHAR2)
IS
   info_    VARCHAR2(4000);
   CURSOR get_data IS
      SELECT  to_char(rowversion,'YYYYMMDDHH24MISS') objversion,
              rowid                          objid
     FROM tax_code_per_tax_book_tab
     WHERE company = company_
     AND fee_code = fee_code_;
BEGIN
   Check_Delete_Tax_Book_Rec___(company_, fee_code_);
   FOR rec_ IN get_data LOOP
      Remove__(info_, rec_.objid, rec_.objversion, action_);
   END LOOP;
   NULL;
END Do_Cascade_Fee_Code___;  

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Delete_Fee_Code__(
   key_list_    IN VARCHAR2)   
IS
   company_    VARCHAR2(20);
   fee_code_   VARCHAR2(20);   
BEGIN
   company_ := substr(key_list_, 1, instr(key_list_, '^') - 1);
   fee_code_ := substr(key_list_, instr(key_list_, '^') + 1, instr(key_list_, '^' , 1, 2) - (instr(key_list_, '^') + 1));      
   Do_Cascade_Fee_Code___(company_, fee_code_, 'CHECK');
END Check_Delete_Fee_Code__;  


PROCEDURE Delete_Fee_Code__(
   key_list_    IN VARCHAR2)
IS
   company_    VARCHAR2(20);
   fee_code_   VARCHAR2(20);
BEGIN
   company_ := substr(key_list_, 1, instr(key_list_, '^') - 1);
   fee_code_ := substr(key_list_, instr(key_list_, '^') + 1, instr(key_list_, '^' , 1, 2) - (instr(key_list_, '^') + 1));   
   Do_Cascade_Fee_Code___(company_, fee_code_, 'DO');
END Delete_Fee_Code__;  

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Validate_Insert (
   company_              IN VARCHAR2,   
   fee_code_             IN VARCHAR2,
   tax_book_base_values_ IN VARCHAR2,
   tax_direction_sp_     IN VARCHAR2 ) RETURN VARCHAR2
IS

   CURSOR cur_code_per_book IS
      SELECT *
        FROM tax_code_per_tax_book
       WHERE company = company_
         AND fee_code = fee_code_;        
        
   tax_direc_          VARCHAR2(20);
   false_              VARCHAR2(10):= 'FALSE';
   true_               VARCHAR2(10):= 'TRUE';
   exist_base_values_  VARCHAR2(20);   
BEGIN
   IF (tax_book_base_values_ = 'RESTRICTED') THEN
      FOR cur_rec IN cur_code_per_book LOOP
         IF (cur_code_per_book%ROWCOUNT != 0) THEN
            exist_base_values_ := Tax_Book_API.Get_Tax_Book_Base_Values_Db(company_, cur_rec.tax_book_id);                         
            IF (exist_base_values_ != 'ALL') THEN
               tax_direc_ := Tax_Book_API.Get_Tax_Direction_Sp_Db(company_, cur_rec.tax_book_id);               
               IF (tax_direction_sp_ = 'RECEIVED') THEN
                  IF (tax_direc_ IN ('RECEIVED' ,'DISBURSEDRECEIVED')) THEN
                     RETURN false_;
                  END IF;
               ELSIF (tax_direction_sp_ = 'DISBURSED') THEN
                  IF (tax_direc_ IN ('DISBURSED' ,'DISBURSEDRECEIVED')) THEN
                     RETURN false_;
                  END IF;
               ELSIF (tax_direction_sp_ = 'DISBURSEDRECEIVED') THEN
                  IF (tax_direc_ IN ('DISBURSED' ,'DISBURSEDRECEIVED', 'RECEIVED')) THEN
                     RETURN false_;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   END IF;  
   RETURN true_;
END Validate_Insert;


PROCEDURE Remove_Rec (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 )
IS

   CURSOR cur_del_rec IS
      SELECT objid, objversion
        FROM Tax_Code_Per_Tax_Book
       WHERE company = company_
         AND tax_book_id = tax_book_id_;

   info_    VARCHAR2(2000);
BEGIN
   FOR cur_rec IN cur_del_rec LOOP
      Remove__(info_, cur_rec.objid, cur_rec.objversion, 'DO');
      Client_SYS.Merge_Info(info_);
   END LOOP;
END Remove_Rec;


@UncheckedAccess
FUNCTION Check_Exists (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR cur_res_rec IS
      SELECT 1
        FROM Tax_Code_Per_Tax_Book_Tab
       WHERE company = company_
         AND tax_book_id = tax_book_id_;

   dummy_  NUMBER;
BEGIN
   OPEN cur_res_rec;
   FETCH cur_res_rec INTO dummy_;
   IF (cur_res_rec%FOUND)THEN
      CLOSE cur_res_rec;
      RETURN 'TRUE';
   END IF;      
   CLOSE cur_res_rec;
   RETURN 'FALSE';
END Check_Exists;


PROCEDURE Delete_Rec (
   company_ IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
   CURSOR del_fee_code IS
      SELECT Objid, Objversion
        FROM Tax_Code_Per_Tax_Book
       WHERE Company = company_
         AND Fee_Code = fee_code_;
   
   info_    VARCHAR2(2000);
BEGIN
   Check_Delete_Tax_Book_Rec___(company_, fee_code_);
   FOR del_rec IN del_fee_code LOOP
      Remove__(info_, del_rec.objid, del_rec.objversion, 'DO');
   END LOOP;   
END Delete_Rec;


PROCEDURE New_Rec (
   company_ IN VARCHAR2,
   tax_book_id_ IN VARCHAR2,
   fee_code_ IN VARCHAR2 )
IS
   newrec_     tax_code_per_tax_book_tab%ROWTYPE;
BEGIN
   newrec_.company      := company_;
   newrec_.tax_book_id  := tax_book_id_;
   newrec_.fee_code     := fee_code_;   
   New___(newrec_);
END New_Rec;


FUNCTION Check_Tax_Code_Exist (
   company_     IN VARCHAR2,
   tax_book_id_ IN VARCHAR2,
   tax_code_    IN VARCHAR2) RETURN BOOLEAN
IS
   CURSOR exist_control IS
      SELECT 1
        FROM Tax_Code_Per_Tax_Book_Tab
       WHERE company = company_
         AND tax_book_id = tax_book_id_
         AND fee_code = tax_code_;

   dummy_   NUMBER;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      RETURN(FALSE);
   END IF;
   CLOSE exist_control;
   RETURN(TRUE);
END Check_Tax_Code_Exist;


-- gelr:tax_book_and_numbering, begin
FUNCTION Get_Tax_Book_By_Direction (
   company_          IN VARCHAR2,        
   tax_code_         IN VARCHAR2,
   tax_direction_db_ IN VARCHAR2 ) RETURN VARCHAR2   
IS 
   tax_book_id_         VARCHAR2(20);

   CURSOR get_tax_book_id IS
      SELECT tctb.tax_book_id
      FROM   tax_code_per_tax_book_tab tctb,
             tax_book_tab tb
      WHERE  tctb.company        = tb.company
      AND    tctb.tax_book_id    = tb.tax_book_id
      AND    tctb.company        = company_
      AND    tctb.fee_code       = tax_code_
      AND   (tb.tax_direction_sp = tax_direction_db_ OR tb.tax_direction_sp = 'DISBURSEDRECEIVED');
BEGIN
   OPEN  get_tax_book_id;
   FETCH get_tax_book_id INTO tax_book_id_;
   CLOSE get_tax_book_id;
   RETURN tax_book_id_;
END Get_Tax_Book_By_Direction;
-- gelr:tax_book_and_numbering, end

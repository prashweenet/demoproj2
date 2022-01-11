-----------------------------------------------------------------------------
--
--  Logical unit: InternalPostingsAccrul
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  010219  ARMOLK   Bug # 15677 Add call to General_SYS.Init_Method
--  010329  AsRalk   Bug #21029 corrected
--  010329  AsRalk   Bug #21030 automatically corrected through the modifications done to Bug #21029
--  010612  ARMOLK   Bug # 15677 Add call to General_SYS.Init_Method
--  010613  JeGu     Bug #21705 New Dummyinterface
--  011108  Thsrlk   Bug # 24054 corrected add  FUNCTION Manual_Post_Exist & FUNCTION Get_Percentage.
--                   Add new coloumn percentage in to relavent places.
--  050308  NiFelk   B121223, Added methods New_Voucher_Row___ and Delete_Voucher_Row___.
--  050915  Chajlk   LCS Merge(33986).
--  051227  Vohelk   Bug #129769  corrected. Add Remove_Manual_Postings method.
--  100312  SACALK   RAVEN-197 - Added Code Part descriptions to the VIEW INTERNAL_POSTINGS_ACCRUL
--  111019  SWRALK   SFI-143, Added conditional compilation for the places that had called package INTLED_CONNECTION_V101_API and INTLED_CONNECTION_V130_API.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  131116  Umdolk  PBFI-2046, Refactoring
--  190219  UJPELK  FIUXX - Added procedure to calculate remaining balances
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE New_Voucher_Row___(newrec_ INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE)
IS
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      Voucher_Row_API.Create_Row(newrec_.company,
                                 newrec_.voucher_type,
                                 newrec_.voucher_no,
                                 newrec_.accounting_year,
                                 newrec_.ref_row_no);
   $ELSE
      NULL;                                          
   $END
END New_Voucher_Row___;


PROCEDURE Delete_Voucher_Row___(remrec_ INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE)
IS
   posting_combination_id_     NUMBER;
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      Posting_Combination_API.Get_Combination(posting_combination_id_,
                                              remrec_.account,
                                              remrec_.code_b,
                                              remrec_.code_c,
                                              remrec_.code_d,
                                              remrec_.code_e,
                                              remrec_.code_f,
                                              remrec_.code_g,
                                              remrec_.code_h,
                                              remrec_.code_i,
                                              remrec_.code_j);
   $ELSE
      NULL;                                          
   $END
   $IF Component_Intled_SYS.INSTALLED $THEN
      Internal_Hold_Voucher_Row_API.Delete_Row(remrec_.company,
                                               remrec_.voucher_type,
                                               remrec_.voucher_no,
                                               remrec_.accounting_year,
                                               remrec_.ledger_id,
                                               remrec_.ref_row_no,
                                               posting_combination_id_);
   $ELSE
      NULL;                                          
   $END
END Delete_Voucher_Row___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   row_no_     NUMBER; 
   amount_     NUMBER;
   
   CURSOR next_row IS
      SELECT NVL(MAX(row_no),0)+1
      FROM  internal_postings_accrul_tab
      WHERE company              = newrec_.company
      AND   ledger_id            = newrec_.ledger_id
      AND   internal_seq_number  = newrec_.internal_seq_number
      AND   account              = newrec_.account;
   
   CURSOR get_vou_ref_no IS
      SELECT row_no,
             NVL(debet_amount, credit_amount ) amount
      FROM   voucher_row_tab
      WHERE company              = newrec_.company
      AND   internal_seq_number  = newrec_.internal_seq_number
      AND   account              = newrec_.account;
BEGIN
   OPEN  next_row;
   FETCH next_row INTO row_no_;
   CLOSE next_row;
   
   newrec_.row_no := row_no_;
   
   IF newrec_.ref_row_no IS NULL THEN
      OPEN  get_vou_ref_no;
      FETCH get_vou_ref_no INTO newrec_.ref_row_no,amount_;
      CLOSE get_vou_ref_no;
      
      IF amount_ <> 0 THEN
         newrec_.percentage := abs(NVL(newrec_.debit_amount, newrec_.credit_amount)/amount_*100);
      END IF;
   END IF;
   super(objid_, objversion_, newrec_, attr_);
   IF (Client_SYS.Get_Item_Value('MODIFY',attr_) = 'TRUE') THEN
      New_Voucher_Row___(newrec_);
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Delete_Voucher_Row___(remrec_);
END Delete___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT internal_postings_accrul_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (Client_SYS.Item_Exist('AMOUNT', attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'AMOUNT');
   END IF;      
   newrec_.row_no := 0;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     internal_postings_accrul_tab%ROWTYPE,
   newrec_ IN OUT internal_postings_accrul_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (Client_SYS.Item_Exist('AMOUNT', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'AMOUNT');
   END IF;      
   
   super(oldrec_, newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     internal_postings_accrul_tab%ROWTYPE,
   newrec_ IN OUT internal_postings_accrul_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   new_attr_ VARCHAR2(32000);
BEGIN
   IF newrec_.currency_credit_amount IS NOT NULL THEN
      new_attr_ := Client_SYS.Remove_Attr('CURRENCY_DEBIT_AMOUNT', attr_);
   END IF;
   IF newrec_.currency_debit_amount IS NOT NULL THEN
      new_attr_ := Client_SYS.Remove_Attr('CURRENCY_CREDIT_AMOUNT', attr_);
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);   
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Manual_Post_Exist (
   company_         IN VARCHAR2,
   ledger_id_       IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   ref_row_no_      IN NUMBER )  RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE company        = company_
      AND   ledger_id      = ledger_id_
      AND   accounting_year = accounting_year_
      AND   voucher_type   = voucher_type_
      AND   voucher_no     = voucher_no_
      AND   row_no         = row_no_
      AND   ref_row_no     = ref_row_no_;
BEGIN
   
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
   
END Manual_Post_Exist;


@UncheckedAccess
FUNCTION Manual_Post_Exist (
   company_         IN VARCHAR2,
   ledger_id_       IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   ref_row_no_      IN NUMBER )  RETURN BOOLEAN
IS
   dummy_                  NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE company         = company_
      AND   ledger_id       = ledger_id_
      AND   accounting_year = accounting_year_
      AND   voucher_type    = voucher_type_
      AND   voucher_no      = voucher_no_
      AND   ref_row_no      = ref_row_no_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Manual_Post_Exist;


FUNCTION Get_Percentage (
   company_         IN VARCHAR2,
   ledger_id_       IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   ref_row_no_      IN NUMBER )  RETURN NUMBER
IS
   temp_ INTERNAL_POSTINGS_ACCRUL_TAB.Percentage%TYPE;
   CURSOR get_attr IS
      SELECT Percentage
      FROM INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE company        = company_
      AND   ledger_id      = ledger_id_
      AND   accounting_year = accounting_year_
      AND   voucher_type   = voucher_type_
      AND   voucher_no     = voucher_no_
      AND   row_no         = row_no_
      AND   ref_row_no     = ref_row_no_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Percentage;


PROCEDURE Insert_Manual_Postings (
   ledger_id_ IN VARCHAR2,
   row_rec_   IN VOUCHER_ROW_TAB%ROWTYPE )
IS
   objid_                  VARCHAR2(2000);
   objversion_             VARCHAR2(2000);
   newrec_                 INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE;
   attr_                   VARCHAR2(2000);
BEGIN
   newrec_.company                      := row_rec_.company;
   newrec_.ledger_id                    := ledger_id_;
   newrec_.internal_seq_number          := row_rec_.internal_seq_number;
   newrec_.account                      := row_rec_.account;
   newrec_.voucher_type                 := row_rec_.voucher_type;
   newrec_.accounting_year              := row_rec_.accounting_year;
   newrec_.voucher_no                   := row_rec_.voucher_no;
   newrec_.ref_row_no                   := row_rec_.reference_row_no;
   newrec_.code_b                       := row_rec_.code_b;
   newrec_.code_c                       := row_rec_.code_c;
   newrec_.code_d                       := row_rec_.code_d;
   newrec_.code_e                       := row_rec_.code_e;
   newrec_.code_f                       := row_rec_.code_f;
   newrec_.code_g                       := row_rec_.code_g;
   newrec_.code_h                       := row_rec_.code_h;
   newrec_.code_i                       := row_rec_.code_i;
   newrec_.code_j                       := row_rec_.code_j;
   newrec_.debit_amount                 := row_rec_.debet_amount;
   newrec_.credit_amount                := row_rec_.credit_amount;
   newrec_.currency_debit_amount        := row_rec_.currency_debet_amount;
   newrec_.currency_credit_amount       := row_rec_.currency_credit_amount;
   newrec_.third_currency_debit_amount  := row_rec_.third_currency_debit_amount;
   newrec_.third_currency_credit_amount := row_rec_.third_currency_credit_amount;
   newrec_.currency_rate                := row_rec_.currency_rate;
   newrec_.text                         := row_rec_.text;
   Insert___(objid_, objversion_, newrec_, attr_);
END Insert_Manual_Postings;


PROCEDURE Remove_Manual_Postings(
   company_             IN VARCHAR2,
   ledger_id_           IN VARCHAR2,
   account_             IN VARCHAR2,
   internal_seq_number_ IN NUMBER )
IS
   CURSOR Int_Post_Cur IS 
	   SELECT * 
		FROM INTERNAL_POSTINGS_ACCRUL_TAB  
		WHERE company = company_									
		      AND ledger_id = RTRIM(ledger_id_,'|')
		      AND account = account_
		      AND internal_seq_number = internal_seq_number_;
   
   objid_       INTERNAL_POSTINGS_ACCRUL.objid%TYPE;
   objversion_ INTERNAL_POSTINGS_ACCRUL.objversion%TYPE;
   rec_          INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE;
   
BEGIN 
   
   OPEN Int_Post_Cur;
LOOP 
   FETCH Int_Post_Cur INTO rec_;
   EXIT WHEN Int_Post_Cur%NOTFOUND;
   Get_Id_Version_By_Keys___( objid_,
                              objversion_, 
                              rec_.company , 			
                              rec_.ledger_id,
                              rec_.internal_seq_number,
                              rec_.account,
                              rec_.row_no);
   Delete___(objid_ , rec_);
END LOOP;
CLOSE Int_Post_Cur;
END Remove_Manual_Postings;


PROCEDURE Copy_Internal_Posting (
   new_internal_seq_number_ OUT NUMBER,
   company_                 IN  VARCHAR2,
   account_                 IN  VARCHAR2,
   internal_seq_number_     IN  NUMBER,
   status_                  IN  VARCHAR2,
   correction_status_       IN  VARCHAR2)
IS
   newrec_                      INTERNAL_POSTINGS_ACCRUL_TAB%ROWTYPE;
   amount_                      NUMBER;
   currency_amount_             NUMBER;
   objid_                       VARCHAR2(2000);
   objversion_                  VARCHAR2(2000);
   attr_                        VARCHAR2(2000);
   CURSOR fetch_records IS
      SELECT *
      FROM   internal_postings_accrul_tab
      WHERE  company             = company_
      AND    internal_seq_number = internal_seq_number_
      AND    account             = account_;
BEGIN
   IF (internal_seq_number_ IS NOT NULL) THEN
      $IF Component_Intled_SYS.INSTALLED $THEN
         new_internal_seq_number_ := Internal_Ledger_Util_Pub_API.Get_Next_Int_Manual_Post_Seq();
      $ELSE
         new_internal_seq_number_ := NULL;
      $END
   ELSE
      new_internal_seq_number_ := NULL;
   END IF;
   FOR row_rec_ IN fetch_records LOOP
      newrec_.company             := row_rec_.company;
      newrec_.ledger_id           := row_rec_.ledger_id;
      newrec_.internal_seq_number := new_internal_seq_number_;
      newrec_.account             := row_rec_.account;
      newrec_.voucher_type        := row_rec_.voucher_type;
      newrec_.accounting_year     := row_rec_.accounting_year;
      newrec_.voucher_no          := row_rec_.voucher_no;
      newrec_.ref_row_no          := row_rec_.ref_row_no;
      newrec_.code_b              := row_rec_.code_b;
      newrec_.code_c              := row_rec_.code_c;
      newrec_.code_d              := row_rec_.code_d;
      newrec_.code_e              := row_rec_.code_e;
      newrec_.code_f              := row_rec_.code_f;
      newrec_.code_g              := row_rec_.code_g;
      newrec_.code_h              := row_rec_.code_h;
      newrec_.code_i              := row_rec_.code_i;
      newrec_.code_j              := row_rec_.code_j;
      amount_                     := NVL(row_rec_.debit_amount, -(row_rec_.credit_amount));
      currency_amount_ := NVL(row_rec_.currency_debit_amount, row_rec_.currency_credit_amount);
      
      IF (status_ = 'CORRECTION') THEN
         newrec_.debit_amount                 := -(row_rec_.debit_amount);
         newrec_.credit_amount                := -(row_rec_.credit_amount);
         newrec_.currency_debit_amount        := -(row_rec_.currency_debit_amount);
         newrec_.currency_credit_amount       := -(row_rec_.currency_credit_amount);
         newrec_.third_currency_debit_amount  := -(row_rec_.third_currency_debit_amount);
         newrec_.third_currency_credit_amount := -(row_rec_.third_currency_credit_amount);
         newrec_.currency_rate                := row_rec_.currency_rate;
         newrec_.text                         := row_rec_.text;
      END IF;
      
      IF (status_ = 'REVERSE') THEN
         IF  (correction_status_ = 'Y') THEN
            IF (row_rec_.currency_debit_amount IS NULL) THEN
               newrec_.currency_debit_amount := -(row_rec_.currency_credit_amount);
            ELSE
               newrec_.currency_credit_amount := -(row_rec_.currency_debit_amount);
            END IF;
            IF (row_rec_.debit_amount IS NULL) THEN
               newrec_.debit_amount := -(row_rec_.credit_amount);
            ELSE
               newrec_.credit_amount := -(row_rec_.debit_amount);
            END IF;
            IF (row_rec_.third_currency_debit_amount IS NULL) THEN
               newrec_.third_currency_debit_amount := -(row_rec_.third_currency_credit_amount);
            ELSE
               newrec_.third_currency_credit_amount := -(row_rec_.third_currency_debit_amount);
            END IF;
            newrec_.currency_rate := row_rec_.currency_rate;
            newrec_.text := row_rec_.text;
         END IF;
         
         IF  (correction_status_ = 'N') THEN
            IF (row_rec_.currency_debit_amount IS NULL) THEN
               newrec_.currency_debit_amount := row_rec_.currency_credit_amount;
            ELSE
               newrec_.currency_credit_amount := row_rec_.currency_debit_amount;
            END IF;
            IF (row_rec_.debit_amount IS NULL) THEN
               newrec_.debit_amount := row_rec_.credit_amount;
            ELSE
               newrec_.credit_amount := row_rec_.debit_amount;
            END IF;
            IF (row_rec_.third_currency_debit_amount IS NULL) THEN
               newrec_.third_currency_debit_amount := row_rec_.third_currency_credit_amount;
            ELSE
               newrec_.third_currency_credit_amount := row_rec_.third_currency_debit_amount;
            END IF;
            newrec_.currency_rate := row_rec_.currency_rate;
            newrec_.text          := row_rec_.text;
         END IF;
      END IF;
      IF (status_ = 'NONE') THEN
         newrec_.debit_amount                 := row_rec_.debit_amount;
         newrec_.credit_amount                := row_rec_.credit_amount;
         newrec_.currency_debit_amount        := row_rec_.currency_debit_amount;
         newrec_.currency_credit_amount       := row_rec_.currency_credit_amount;
         newrec_.third_currency_debit_amount  := row_rec_.third_currency_debit_amount;
         newrec_.third_currency_credit_amount := row_rec_.third_currency_credit_amount;
         newrec_.currency_rate                := row_rec_.currency_rate;
         newrec_.text                         := row_rec_.text;
      END IF;
      Client_SYS.Clear_Attr(attr_);
      Insert___(objid_, objversion_, newrec_, attr_);
   END LOOP;
END Copy_Internal_Posting;

-- Created for Aurena
PROCEDURE Calculate_Remaining_Balances(
   company_                    IN  VARCHAR2,
   ledger_id_                  IN  VARCHAR2,
   account_                    IN  VARCHAR2,
   internal_seq_no_            IN  NUMBER,
   currency_remaining_balance_ OUT NUMBER,
   remaining_balance_          OUT NUMBER)
IS
   CURSOR get_postings IS
      SELECT currency_debit_amount, currency_credit_amount,
      currency_amount, debit_amount, credit_amount, amount
      FROM Internal_Postings_Accrul
      WHERE company = company_ AND ledger_id = ledger_id_
      AND account = account_ AND internal_seq_number = internal_seq_no_;
   
   currency_balance_ NUMBER := 0;
   balance_          NUMBER := 0;
   curr_temp_        NUMBER := 0;
   acc_temp_         NUMBER := 0;
   
BEGIN
   FOR rec_ IN get_postings LOOP
      currency_balance_ := rec_.currency_debit_amount - rec_.currency_credit_amount;
      balance_ := rec_.debit_amount - rec_.credit_amount;
      IF rec_.currency_amount != currency_balance_ THEN
         NULL;
         --         fire currency balance IS NOT tally error
      END IF;
      IF rec_.amount != balance_ THEN
         NULL;
         --         amount IS NOT tally WITH the client VALUE error
      END IF;
      
      curr_temp_ := curr_temp_ + rec_.currency_amount;
      acc_temp_  := acc_temp_ + rec_.amount;
   END LOOP;  
   currency_remaining_balance_ := curr_temp_;
   remaining_balance_ := acc_temp_;
END Calculate_Remaining_Balances;

-- Created for Aurena
FUNCTION Calculate_Percentage (
   total_  IN NUMBER,
   amount_ IN NUMBER) RETURN NUMBER
IS
   percentage_ NUMBER;
BEGIN
   IF (total_ != 0 OR total_ IS NOT NULL) THEN
      percentage_ := amount_ / total_ * 100 ;
      percentage_ := abs(percentage_);  
   ELSE 
      percentage_ := 0;
   END IF;
   
	RETURN percentage_;
END Calculate_Percentage;

-- Created for Aurena
PROCEDURE Validate_Percentage (
   currency_amount_        IN  NUMBER,
   amount_                 IN  NUMBER,
   percentage_             IN  NUMBER,
   correction_             IN  BOOLEAN,
   currency_debit_amount_  OUT NUMBER,
   currency_credit_amount_ OUT NUMBER,
   row_currency_amount_    OUT NUMBER,
   debit_amount_           OUT NUMBER,
   credit_amount_          OUT NUMBER,
   row_amount_             OUT NUMBER)
IS
BEGIN
   IF (currency_amount_ != 0 OR currency_amount_ IS NOT NULL) THEN
      IF correction_ THEN
         IF (currency_amount_ > 0) THEN
            currency_credit_amount_ := -1 * percentage_ * currency_amount_ / 100;
         ELSE
            currency_debit_amount_ := percentage_ * currency_amount_ / 100;
         END IF;
      ELSE
         IF (currency_amount_ > 0) THEN
            currency_debit_amount_ := percentage_ * currency_amount_ / 100;
         ELSE 
            currency_credit_amount_ := -1 * percentage_ * currency_amount_ / 100;
         END IF;
      END IF;    
      row_currency_amount_ := NVL(currency_debit_amount_, 0) - NVL(currency_credit_amount_, 0);
   ELSIF (amount_ != 0 OR amount_ IS NOT NULL) THEN
      IF correction_ THEN
         IF (amount_ > 0) THEN
            credit_amount_ := -1 * percentage_ * amount_ / 100;
         ELSE
            debit_amount_ := percentage_ * amount_ / 100;
         END IF;
      ELSE
         IF (amount_ > 0) THEN
            debit_amount_ := percentage_ * amount_ / 100;
         ELSE 
            credit_amount_ := -1 * percentage_ * amount_ / 100;
         END IF;
      END IF; 
   row_amount_ := NVL(debit_amount_, 0) - NVL(credit_amount_, 0);
   END IF;
END Validate_Percentage;

PROCEDURE Get_Amounts (
   currency_balance_           OUT NUMBER,
   balance_                    OUT NUMBER,
   company_                    IN  VARCHAR2,
   ledger_id_                  IN  VARCHAR2,
   internal_seq_no_            IN  NUMBER,
   account_                    IN  VARCHAR2)
IS
   CURSOR get_posting_balance_ IS
      SELECT SUM(NVL(currency_debit_amount,-currency_credit_amount)),
             SUM(NVL(debit_amount,-credit_amount))
      FROM internal_postings_accrul_tab
      WHERE company = company_ 
      AND ledger_id = ledger_id_
      AND internal_seq_number = internal_seq_no_
      AND account = account_ ;
BEGIN
   OPEN get_posting_balance_;
   FETCH get_posting_balance_ INTO currency_balance_, balance_;
   CLOSE get_posting_balance_;
END Get_Amounts;

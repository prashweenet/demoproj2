-----------------------------------------------------------------------------
--
--  Logical unit: PeriodAllocationRule
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  071205  Jeguse  Bug 69803 Created
--  080826  VADELK  Bug 76042, Corrected. Added new parameter for Create_New_Allocation_Lines() and Distribute_Allocation_Lines___()
--  080826          to check the transaction currency code. The Percentage is rounded to two digits and the amount is
--  080826          rounded according to the transaction currency code.                                          
--  090212  Jeguse  Bug 80401, Modified in Create_New_All_From_Parent
--  090219  Jeguse  Bug 80680, Corrected
--  090224  Maaylk  Bug 80804, Removed unnecessary Order By clause
--  090323  Jeguse  Bug 80510, Corrected in Create_Period_Allocations
--  090525  AsHelk  Bug 80221, Adding Transaction Statement Approved Annotation.
--  090717  ErFelk  Bug 83174, Replaced constant NOENDPER with NOACCPER in Distribute_Allocation_Lines___ and replaced CREDESCSC with CREDESCMV
--  090717          in Get_Creator_Desc. 
--  091118  Nsillk  EAFH-202 Removed method Rollback_Per_Alloc_Client
--  100118  ShFrlk  Bug 87904, Corrected. Calculated allocation amounts using raw percentage instead of rounded percentage.
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  120105  Lamalk  SFI-1345, Merged Bug 100289; Corrected in Distribute_Allocation_Lines___
--    121204   Maaylk  PEPA-183, Removed global variables
--  131107  PRatlk  PBFI-2062, Refactored according to the new template
--  151204  chiblk  STRFI-682,removing sub methods and rewriting them as implementation methods
--                            code inside the sub procedure was put into the places where the sub procedure was used
--  170309  Dakplk  STRFI-3113, Added new methods Any_Allocation(), Do_Period_Allocation() and Do_Multi_Period_Alloc_From_Msg()  
--  170321  Dkanlk  STRFI-5116, Added code to delete records from 'int_period_allocation_tab'.
--  190215  Kgamlk  Bug 146944, Modified method Create_Period_Allocations.
--  201125  Kumglk  Bug 156562, Modified Create_New_All_From_Parent and introduced Reverse_Period_Alloc_Lines__, to correctly reverse period allocation amounts of cancelled vouchers
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE Public_Allocation_Rec IS RECORD
(company           period_allocation_tab.company%TYPE,
 accounting_year   period_allocation_tab.alloc_year%TYPE,
 accounting_period period_allocation_tab.alloc_period %TYPE,
 amount            NUMBER,
 percentage        NUMBER);

TYPE Public_Allocation_Tab IS TABLE OF Public_Allocation_Rec INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Distribute_Allocation_Lines___ (
   allocation_id_ IN NUMBER,
   company_       IN VARCHAR2,
   from_date_     IN DATE,
   until_date_    IN DATE,
   total_amount_  IN NUMBER,
   distr_type_    IN VARCHAR2 DEFAULT 'E',
   currency_code_ IN VARCHAR2 DEFAULT NULL)
IS
   newrec_       period_alloc_rule_line_tab%ROWTYPE;  
   alloc_tab_    Public_Allocation_Tab;   
BEGIN
   DELETE 
   FROM   period_alloc_rule_line_tab
   WHERE  allocation_id = allocation_id_;
   
   alloc_tab_ := Distribute_Allocations(company_,
                                        from_date_,
                                        until_date_,
                                        total_amount_,
                                        distr_type_,
                                        currency_code_);
   IF (alloc_tab_.COUNT>0) THEN
      FOR i_ IN alloc_tab_.FIRST.. alloc_tab_.LAST LOOP        
         newrec_.allocation_id     := allocation_id_;
         newrec_.alloc_line_id     := Get_Next_Alloc_Line_Seq;
         newrec_.accounting_year   := alloc_tab_(i_).accounting_year;
         newrec_.accounting_period := alloc_tab_(i_).accounting_period;
         newrec_.percentage        := alloc_tab_(i_).percentage;
         newrec_.amount            := alloc_tab_(i_).amount;
         newrec_.allocation_diff   := 'FALSE';
         Period_Alloc_Rule_Line_API.New(newrec_);         
      END LOOP;
   END IF;
END Distribute_Allocation_Lines___;

PROCEDURE Raise_Acc_Per_Not_Found___(
   date_ IN DATE)
IS
BEGIN   
   Error_SYS.Record_General(lu_name_, 'NOACCPER: Accounting Period for :P1 not found', date_);   
END Raise_Acc_Per_Not_Found___;

PROCEDURE Distribute_Old_Lines___ (
   allocation_id_     IN NUMBER,
   old_allocation_id_ IN NUMBER,
   total_amount_      IN NUMBER )
IS
   company_ VARCHAR2(20) := NULL;
BEGIN
   Distribute_Old_Lines___(company_, allocation_id_, old_allocation_id_, total_amount_);
END Distribute_Old_Lines___; 

PROCEDURE Distribute_Old_Lines___ (
   company_           IN VARCHAR2,
   allocation_id_     IN NUMBER,
   old_allocation_id_ IN NUMBER,
   total_amount_      IN NUMBER )
IS
   newrec_               period_alloc_rule_line_tab%ROWTYPE;
   until_year_period_    NUMBER;
   sum_amount_           NUMBER  := 0;
   amount_               NUMBER;
   dummy_                NUMBER  := 1;
   acc_currency_        VARCHAR2(3);
   rounding_            NUMBER;
   --
   CURSOR get_until_year_period IS
      SELECT MAX((accounting_year * 100) + accounting_period) until_year_period
      FROM   period_alloc_rule_line_tab a
      WHERE  allocation_id = old_allocation_id_;
   --
   CURSOR get_old_alloc IS
      SELECT alloc_line_id                                 alloc_line_id,
             accounting_year                               accounting_year,
             accounting_period                             accounting_period,
             ((accounting_year * 100) + accounting_period) year_period,
             percentage                                    percentage
      FROM   period_alloc_rule_line_tab a
      WHERE  allocation_id = old_allocation_id_
      ORDER BY ((accounting_year * 100) + accounting_period);
   
BEGIN
   
   IF (company_ IS NOT NULL)THEN
      acc_currency_ := Company_Finance_API.Get_Currency_Code (company_);
      rounding_     := Currency_Code_API.Get_Currency_Rounding (company_, acc_currency_);
   ELSE
      rounding_ := 2;
   END IF; 
   --
   IF (old_allocation_id_ != allocation_id_) THEN
      DELETE 
      FROM   period_alloc_rule_line_tab
      WHERE  allocation_id = allocation_id_;
   END IF;
   --
   OPEN  get_until_year_period;
   FETCH get_until_year_period INTO until_year_period_;
   CLOSE get_until_year_period;
   --
   FOR rec_ IN get_old_alloc LOOP      
      IF (NOT Period_Alloc_Rule_Line_API.Exists(allocation_id_, rec_.alloc_line_id)) THEN      
         dummy_ := 0;
      END IF;
      
      IF (dummy_ = 0) THEN
         newrec_.allocation_id     := allocation_id_;
         newrec_.alloc_line_id     := Get_Next_Alloc_Line_Seq;
         newrec_.accounting_year   := rec_.accounting_year;
         newrec_.accounting_period := rec_.accounting_period;
         newrec_.percentage        := rec_.percentage;
      END IF;
      IF (rec_.year_period = until_year_period_) THEN
         amount_                   := total_amount_ - sum_amount_;
      ELSE
         amount_                   := ROUND(total_amount_ * (rec_.percentage / 100), rounding_);
         sum_amount_               := sum_amount_ + amount_;
      END IF;
      IF (dummy_ = 0) THEN
         newrec_.amount            := amount_;
         Period_Alloc_Rule_Line_API.New(newrec_);
      ELSE
         UPDATE period_alloc_rule_line_tab
            SET amount            = amount_,
                percentage        = rec_.percentage,
                accounting_year   = rec_.accounting_year,
                accounting_period = rec_.accounting_period
         WHERE  allocation_id     = allocation_id_
         AND    alloc_line_id     = rec_.alloc_line_id;
      END IF;
   END LOOP;
   
END Distribute_Old_Lines___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT period_allocation_rule_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.status     := 'New';
   super(objid_, objversion_, newrec_, attr_);
END Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN period_allocation_rule_tab%ROWTYPE )
IS
   alloc_exist_ VARCHAR2(5)     := 'FALSE';
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      alloc_exist_ := Gen_Led_Voucher_Row_API.Check_Exist_Alloc_Id(remrec_.allocation_id);
   $END
   IF (alloc_exist_ = 'FALSE') THEN
      alloc_exist_ := Voucher_Row_API.Check_Exist_Alloc_Id (remrec_.allocation_id);
   ELSE 
      RETURN;
   END IF;
   super(objid_, remrec_);
END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT period_allocation_rule_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.from_date  := TRUNC(newrec_.from_date);
   newrec_.until_date := TRUNC(newrec_.until_date);
   super(newrec_, indrec_, attr_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     period_allocation_rule_tab%ROWTYPE,
   newrec_ IN OUT period_allocation_rule_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.from_date  := TRUNC(newrec_.from_date);
   newrec_.until_date := TRUNC(newrec_.until_date);
   -- When updating in unpack_check_insert___ the old implimenation value for creator was never updated. This new assignment ensures that same functionality in
   -- App 9 generated code also. 
   newrec_.creator    := oldrec_.creator;
   super(oldrec_, newrec_, indrec_, attr_);   
END Check_Update___;

PROCEDURE Reverse_Period_Alloc_Lines___ (
   allocation_id_     IN NUMBER,
   old_allocation_id_ IN NUMBER)
IS
   newrec_               period_alloc_rule_line_tab%ROWTYPE;
 
   CURSOR get_old_alloc IS
      SELECT alloc_line_id                                 alloc_line_id,
             accounting_year                               accounting_year,
             accounting_period                             accounting_period,
             ((accounting_year * 100) + accounting_period) year_period,
             percentage                                    percentage,
             amount
      FROM   period_alloc_rule_line_tab a
      WHERE  allocation_id = old_allocation_id_
      ORDER BY ((accounting_year * 100) + accounting_period);
      
BEGIN   
   FOR rec_ IN get_old_alloc LOOP      
      newrec_.allocation_id     := allocation_id_;
      newrec_.alloc_line_id     := Period_Allocation_Rule_API.Get_Next_Alloc_Line_Seq;
      newrec_.accounting_year   := rec_.accounting_year;
      newrec_.accounting_period := rec_.accounting_period;
      newrec_.percentage        := rec_.percentage;
      -- need to reverse since this is rollback
      newrec_.amount            := rec_.amount*-1;
      Period_Alloc_Rule_Line_API.New(newrec_);
   END LOOP;
END Reverse_Period_Alloc_Lines___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Common method to distribute the allocations
FUNCTION Distribute_Allocations(   
   company_       IN VARCHAR2,
   from_date_     IN DATE,
   until_date_    IN DATE,
   total_amount_  IN NUMBER,
   distr_type_    IN VARCHAR2 DEFAULT 'E',
   currency_code_ IN VARCHAR2 DEFAULT NULL) RETURN Public_Allocation_Tab
IS 
   from_year_             NUMBER;
   from_period_           NUMBER;
   from_year_period_      NUMBER;
   from_per_from_date_    DATE;
   from_per_until_date_   DATE;
   until_year_            NUMBER;
   until_period_          NUMBER;
   until_year_period_     NUMBER;
   until_per_from_date_   DATE;
   until_per_until_date_  DATE;
   no_of_periods_         NUMBER;
   no_of_periods_even_    NUMBER;
   percentage_            NUMBER;
   sum_amount_            NUMBER;
   sum_percentage_        NUMBER;
   even_percentage_       NUMBER;
   even_last_percentage_  NUMBER;
   prop_percentage_       NUMBER;
   prop_first_percentage_ NUMBER;
   prop_last_percentage_  NUMBER;
   even_amount_           NUMBER;
   even_last_amount_      NUMBER;
   prop_amount_           NUMBER;
   prop_first_amount_     NUMBER;
   prop_last_amount_      NUMBER;
   days_per_period_       NUMBER;
   days_per_total_        NUMBER;
   acc_currency_          VARCHAR2(3);
   rounding_              NUMBER;
   one_100_created_       VARCHAR2(5) := 'FALSE';
   alloc_tab_             Public_Allocation_Tab;
   i_                     NUMBER:=0;
   trans_currency_code_   VARCHAR2(10);
   
   CURSOR get_accperiod IS
      SELECT accounting_year, 
             accounting_period, 
             date_from, 
             date_until
      FROM   accounting_period_tab
      WHERE  company             = company_
      AND    ((accounting_year * 100) + accounting_period) BETWEEN from_year_period_ AND until_year_period_
      AND    year_end_period     = 'ORDINARY'
      ORDER BY ((accounting_year * 100) + accounting_period);     
BEGIN
   IF (until_date_ IS NULL) THEN
      Error_SYS.Record_General(lu_name_, 'NOUNTDATE: Until Date is not specified');
   END IF;
   
   IF (until_date_ < from_date_) THEN
      Error_SYS.Record_General(lu_name_, 'WRONGUNTDATE: Until Date :P1 is less than From Date :P2', until_date_, from_date_);
   END IF;
   
   --Fetch Period information for from_date   
   Accounting_Period_API.Get_Period_Info(from_year_, from_period_, from_per_from_date_, from_per_until_date_, company_, from_date_);   
   IF (from_per_from_date_ IS NULL ) THEN
      Raise_Acc_Per_Not_Found___(from_date_);      
   END IF;
   
   --Fetch Period information for until_date  
   Accounting_Period_API.Get_Period_Info(until_year_, until_period_, until_per_from_date_, until_per_until_date_, company_, until_date_);
   IF (until_per_from_date_ IS NULL) THEN
      Raise_Acc_Per_Not_Found___(until_date_);      
   END IF;
   
   from_year_period_   := (from_year_ * 100) + from_period_;
   until_year_period_  := (until_year_ * 100) + until_period_;
   
   no_of_periods_      := Accounting_Period_API.Get_Period_Count(company_, from_year_period_, until_year_period_);
   no_of_periods_even_ := no_of_periods_;
   
   -- Fetch Currency Information   
   acc_currency_ := Company_Finance_API.Get_Currency_Code(company_);
   
   IF(nvl(currency_code_,'N/A')!='N/A') THEN
     trans_currency_code_ := currency_code_;
   ELSE
     trans_currency_code_ := acc_currency_;
   END IF;
   
   rounding_    := Currency_Code_API.Get_Currency_Rounding(company_, trans_currency_code_);
   sum_amount_  := total_amount_;

   IF (from_year_period_ = until_year_period_) THEN      
      one_100_created_ := 'TRUE';         
   ELSIF (distr_type_ = 'M') THEN
      -- Period distribution = Mixed
      days_per_total_           := until_date_ - from_date_ + 1;
      IF (from_per_from_date_ = from_date_) THEN
         prop_first_percentage_ := 0;
      ELSE
         no_of_periods_even_    := no_of_periods_even_ - 1;
         days_per_period_       := from_per_until_date_ - from_date_ + 1;
         prop_first_percentage_ := (days_per_period_ / days_per_total_) * 100;
         IF (total_amount_ IS NOT NULL) THEN
            prop_first_amount_  := ROUND(total_amount_ * (prop_first_percentage_ / 100), rounding_);
         END IF;
      END IF;
      IF (until_per_until_date_ = until_date_) THEN
         prop_last_percentage_  := 0;
      ELSE
         no_of_periods_even_    := no_of_periods_even_ - 1;
         days_per_period_       := until_date_ - until_per_from_date_ + 1;
         prop_last_percentage_  := (days_per_period_ / days_per_total_) * 100;
         IF (total_amount_ IS NOT NULL) THEN
            prop_last_amount_   := ROUND(total_amount_ * (prop_last_percentage_ / 100), rounding_);
         END IF;
      END IF;
      sum_amount_               := 0;
      sum_percentage_           := 0;
      IF (no_of_periods_even_ > 0) THEN
         -- At least one full period found
         prop_percentage_          := (100 - prop_first_percentage_ - prop_last_percentage_) / no_of_periods_even_;
         sum_percentage_           := sum_percentage_ + (no_of_periods_even_ * prop_percentage_);
         IF (total_amount_ IS NOT NULL) THEN
            prop_amount_           := ROUND(total_amount_ * (prop_percentage_ / 100),rounding_);
            sum_amount_            := sum_amount_ + (prop_amount_ * no_of_periods_even_);
         END IF;
         IF (prop_first_percentage_ = 0) THEN
            prop_first_percentage_ := prop_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               prop_first_amount_  := prop_amount_;
            END IF;
         ELSE
            sum_percentage_        := sum_percentage_ + prop_first_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               sum_amount_         := sum_amount_ + prop_first_amount_;
            END IF;
         END IF;
         IF (prop_last_percentage_ = 0) THEN
            prop_last_percentage_  := prop_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               prop_last_amount_   := prop_amount_;
            END IF;
         ELSE
            sum_percentage_        := sum_percentage_ + prop_last_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               sum_amount_         := sum_amount_ + prop_last_amount_;
            END IF;
         END IF;
      ELSE
         -- No full period found
         prop_percentage_          := 0;
         prop_amount_              := 0;
         sum_amount_               := 0;
         IF (prop_first_percentage_ = 0) THEN
            prop_first_percentage_ := 100 - prop_last_percentage_;
            sum_percentage_        := prop_last_percentage_ + prop_first_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               prop_first_amount_  := total_amount_ - prop_last_amount_;
            END IF;
         END IF;
         IF (total_amount_ IS NOT NULL) THEN
            sum_amount_            := sum_amount_ + prop_first_amount_;
         END IF;
         IF (prop_last_percentage_ = 0) THEN
            prop_last_percentage_  := 100 - prop_first_percentage_;
            sum_percentage_        := prop_first_percentage_ + prop_last_percentage_;
            IF (total_amount_ IS NOT NULL) THEN
               prop_last_amount_   := total_amount_ - prop_first_amount_;
            END IF;
         END IF;
         IF (total_amount_ IS NOT NULL) THEN
            sum_amount_            := sum_amount_ + prop_last_amount_;
         END IF;
      END IF;
      IF (total_amount_ IS NOT NULL) THEN
         prop_last_amount_         := prop_last_amount_ + (total_amount_ - sum_amount_);
      END IF;
      prop_first_percentage_ := ROUND(prop_first_percentage_, 2);
      prop_percentage_       := ROUND(prop_percentage_, 2);         
      prop_last_percentage_  := ROUND(prop_last_percentage_, 2);
   ELSIF (distr_type_ = 'E') THEN
      -- Period distribution = Even
      even_percentage_             := 0;
      IF (total_amount_ IS NOT NULL) THEN
         even_amount_              := total_amount_ / no_of_periods_;
         prop_amount_              := ROUND(total_amount_ / no_of_periods_,rounding_);
         IF (even_amount_ = prop_amount_) THEN
            even_percentage_       := ROUND(100 / no_of_periods_,2);
            sum_percentage_        := even_percentage_ * no_of_periods_;
            sum_amount_            := even_amount_ * no_of_periods_;
            even_last_percentage_  := even_percentage_;
            even_last_amount_      := even_amount_;
         END IF;
      END IF;
      IF (even_percentage_ = 0) THEN
         even_percentage_          := ROUND(100 / no_of_periods_,rounding_);
         sum_percentage_           := even_percentage_ * no_of_periods_;
         even_last_percentage_     := even_percentage_ + (100 - sum_percentage_);
         IF (total_amount_ IS NOT NULL) THEN
            even_amount_           := ROUND(total_amount_ * ((100 / no_of_periods_) / 100),rounding_);
            sum_amount_            := even_amount_ * no_of_periods_;
            even_last_amount_      := even_amount_ + (total_amount_ - sum_amount_);
         END IF;
      END IF;
   ELSE
      -- Period distribution = Proportional
      days_per_total_              := until_date_ - from_date_ + 1;
      sum_percentage_              := 0;
      sum_amount_                  := 0;
   END IF;
   
   -- Set Allocation values for relavent periods according to Distributoin type
   IF (from_year_period_ = until_year_period_) THEN
      alloc_tab_(i_).accounting_year   := from_year_;
      alloc_tab_(i_).accounting_period := from_period_;
      alloc_tab_(i_).percentage        := 100;
      alloc_tab_(i_).amount            := total_amount_;
      i_ := i_ + 1;
   ELSIF (one_100_created_ = 'FALSE') THEN
      FOR rec_ IN get_accperiod LOOP            
         IF (distr_type_ = 'P') THEN
            -- Period distribution = Proportional
            IF (rec_.accounting_year = until_year_ AND rec_.accounting_period = until_period_) THEN
               percentage_         := 100 - sum_percentage_;
               IF (total_amount_ IS NOT NULL) THEN
                  prop_amount_     := total_amount_ - sum_amount_;
               END IF;
            ELSE
               IF (rec_.accounting_year = from_year_ AND rec_.accounting_period = from_period_) THEN
                  days_per_period_ := rec_.date_until - from_date_ + 1;
               ELSE
                  days_per_period_ := rec_.date_until - rec_.date_from + 1;
               END IF;
               percentage_         := ROUND((days_per_period_ / days_per_total_) * 100,2);
               sum_percentage_     := sum_percentage_ + percentage_;
               IF (total_amount_ IS NOT NULL) THEN
                  prop_amount_     := ROUND(total_amount_ * (days_per_period_ / days_per_total_) ,rounding_);
                  sum_amount_      := sum_amount_ + prop_amount_;
               END IF;
            END IF;
         ELSIF (distr_type_ = 'E') THEN
            -- Period distribution = Even
            IF (rec_.accounting_year = until_year_ AND rec_.accounting_period = until_period_) THEN
               percentage_         := even_last_percentage_;
            ELSE
               percentage_         := even_percentage_;
            END IF;
         ELSE
            -- Period distribution = Mixed
            IF (rec_.accounting_year = from_year_ AND rec_.accounting_period = from_period_) THEN
               percentage_         := prop_first_percentage_;
            ELSIF (rec_.accounting_year = until_year_ AND rec_.accounting_period = until_period_) THEN
               percentage_         := prop_last_percentage_;
            ELSE
               percentage_         := prop_percentage_;
            END IF;
         END IF;
         alloc_tab_(i_).accounting_year   := rec_.accounting_year;
         alloc_tab_(i_).accounting_period := rec_.accounting_period;
         alloc_tab_(i_).percentage        := percentage_;
      
         IF (total_amount_ IS NULL) THEN
            alloc_tab_(i_).amount         := NULL;
         ELSE
            IF (distr_type_ = 'E') THEN
               -- Period distribution = Even
               IF (rec_.accounting_year = until_year_ AND rec_.accounting_period = until_period_) THEN
                  alloc_tab_(i_).amount   := even_last_amount_;
               ELSE
                  alloc_tab_(i_).amount   := even_amount_;
               END IF;
            ELSIF (distr_type_ = 'M') THEN
               -- Period distribution = Mixed
               IF (rec_.accounting_year = from_year_ AND rec_.accounting_period = from_period_) THEN
                  alloc_tab_(i_).amount   := prop_first_amount_;
               ELSIF (rec_.accounting_year = until_year_ AND rec_.accounting_period = until_period_) THEN
                  alloc_tab_(i_).amount   := prop_last_amount_;
               ELSE
                  alloc_tab_(i_).amount   := prop_amount_;
               END IF;
            ELSE
               -- Period distribution = Proportional
               alloc_tab_(i_).amount      := prop_amount_;
            END IF;
         END IF;
         i_ := i_ + 1;       
      END LOOP;
   END IF;
   RETURN alloc_tab_;
END Distribute_Allocations;

@UncheckedAccess
FUNCTION Get_Open_Status (
   allocation_id_ IN NUMBER,
   creator_       IN VARCHAR2) RETURN VARCHAR2
IS
   temp_             period_allocation_rule_tab.status%TYPE;
   org_creator_      VARCHAR2(30);
BEGIN
   temp_ := Get_Status(allocation_id_);
   IF (temp_ = 'New') THEN
      org_creator_ := Get_Creator(allocation_id_);
      IF (org_creator_ = creator_) THEN
         RETURN 'M';
      ELSE
         RETURN 'Q';
      END IF;
   ELSE
      RETURN 'Q';
   END IF;
END Get_Open_Status;


@UncheckedAccess
FUNCTION Get_Creator_Desc (
   creator_ IN VARCHAR2) RETURN VARCHAR2
IS
   creator_desc_ VARCHAR2(200);
BEGIN
   IF (creator_ = 'InstantInvoice') THEN
      creator_desc_ := Language_Sys.Translate_Constant(lu_name_, 'CREDESCII: Instant Invoice');
   ELSIF (creator_ = 'ServiceContract') THEN
      creator_desc_ := Language_Sys.Translate_Constant(lu_name_, 'CREDESCSC: Service Contract');
   ELSIF (creator_ = 'SupplierInvoice') THEN
      creator_desc_ := Language_Sys.Translate_Constant(lu_name_, 'CREDESCSI: Supplier Invoice');
   ELSIF (creator_ = 'ManualVoucher') THEN
      creator_desc_ := Language_Sys.Translate_Constant(lu_name_, 'CREDESCMV: Manual Voucher');
   ELSIF (creator_ = 'MixedPayment') THEN
      creator_desc_ := Language_Sys.Translate_Constant(lu_name_, 'CREDESCMP: Mixed Payment');
   ELSE
      creator_desc_ := creator_;
   END IF;
   RETURN creator_desc_;
END Get_Creator_Desc;


@UncheckedAccess
FUNCTION Get_Creator_Desc (
   allocation_id_ IN NUMBER) RETURN VARCHAR2
IS
   creator_ period_allocation_rule_tab.creator%TYPE;
   
BEGIN
   IF (allocation_id_ = -1) THEN
      creator_ := 'SupplierInvoice';
   ELSIF (allocation_id_ IS NULL) THEN
      creator_ := 'ManualVoucher';
   ELSE
      creator_ := Get_Creator(allocation_id_);
   END IF;
   RETURN Get_Creator_Desc (creator_);
END Get_Creator_Desc;

PROCEDURE New (
   newrec_     IN OUT period_allocation_rule_tab%ROWTYPE )
IS
   attr_       VARCHAR2(2000);
   objid_      period_allocation_rule.objid%TYPE;
   objversion_ period_allocation_rule.objversion%TYPE;
BEGIN
   Insert___(objid_, objversion_, newrec_, attr_);
END New;

FUNCTION Get_Next_Allocation_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT Period_Allocation_Seq.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN (seq_no_);
END Get_Next_Allocation_Seq;


FUNCTION Get_Next_Alloc_Line_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT Period_Alloc_Line_Seq.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN (seq_no_);
END Get_Next_Alloc_Line_Seq;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Create_New_Allocation_Head (
   allocation_id_        IN OUT NUMBER,
   company_              IN OUT VARCHAR2,
   site_                 IN     VARCHAR2,
   creator_              IN     VARCHAR2,
   from_date_            IN     DATE,
   until_date_           IN     VARCHAR2,
   total_amount_         IN     NUMBER,
   currency_code_        IN     VARCHAR2,
   distr_type_           IN     VARCHAR2 DEFAULT 'E',
   parent_allocation_id_ IN     NUMBER   DEFAULT NULL)
IS
   newrec_               period_allocation_rule_tab%ROWTYPE;
BEGIN
   allocation_id_               := Get_Next_Allocation_Seq;
   newrec_.allocation_id        := allocation_id_;
   newrec_.parent_allocation_id := parent_allocation_id_;
   IF (company_ IS NULL) THEN
      $IF Component_Mpccom_SYS.INSTALLED $THEN
         company_ := Site_API.Get_Company(site_);
      $ELSE
         NULL;
      $END
   END IF;
   newrec_.company              := company_;
   newrec_.from_date            := from_date_;
   newrec_.until_date           := until_date_;
   newrec_.total_amount         := total_amount_;
   newrec_.distr_type           := distr_type_;
   newrec_.currency_code        := currency_code_;
   newrec_.creator              := creator_;
   New (newrec_);
END Create_New_Allocation_Head;


PROCEDURE Create_New_Allocation_Lines (
   allocation_id_   IN NUMBER,
   distr_type_      IN VARCHAR2 DEFAULT 'E',
   from_date_in_    IN DATE     DEFAULT NULL,
   until_date_in_   IN DATE     DEFAULT NULL,
   total_amount_in_ IN NUMBER   DEFAULT NULL,
   currency_code_   IN VARCHAR2 DEFAULT NULL )
IS
   company_             VARCHAR2(20);
   trans_currency_code_ VARCHAR2(10);   
   from_date_           DATE;
   until_date_          DATE;
   total_amount_        NUMBER;
   rule_rec_            period_allocation_rule_tab%ROWTYPE;
  
   CURSOR get_attr IS
      SELECT from_date,
             until_date,
             total_amount
      FROM   period_allocation_rule_tab
      WHERE  allocation_id = allocation_id_;
BEGIN
   IF (from_date_in_ IS NOT NULL) THEN
      from_date_    := from_date_in_;
      until_date_   := until_date_in_;
      total_amount_ := total_amount_in_;
   ELSE
      OPEN  get_attr;
      FETCH get_attr INTO from_date_,
                          until_date_,
                          total_amount_;
      CLOSE get_attr;
   END IF;
   
   rule_rec_ := Get_Object_By_Keys___(allocation_id_);
                          
   company_                      := rule_rec_.company; 
   rule_rec_.from_date           := from_date_;
   rule_rec_.until_date          := until_date_;
   rule_rec_.total_amount        := total_amount_;
   rule_rec_.distr_type          := distr_type_; 
   Modify___(rule_rec_);
   
   IF(nvl(currency_code_,'N/A') != 'N/A') THEN
      trans_currency_code_ := currency_code_;
   END IF;

   Distribute_Allocation_Lines___ (allocation_id_,
                                   company_,
                                   from_date_,
                                   until_date_,
                                   total_amount_,
                                   distr_type_,
                                   trans_currency_code_);
END Create_New_Allocation_Lines;


PROCEDURE Recalculate_Allocation_Lines (
   allocation_id_ IN NUMBER,
   total_amount_  IN NUMBER )
IS
   company_ VARCHAR2(20) := NULL;
BEGIN
   Distribute_Old_Lines___ (company_,
                            allocation_id_,
                            allocation_id_,
                            total_amount_);
END Recalculate_Allocation_Lines;


PROCEDURE Create_New_Alloc_Rule (
   allocation_id_ IN OUT NUMBER,
   company_       IN     VARCHAR2,
   site_          IN     VARCHAR2,
   creator_       IN     VARCHAR2,
   from_date_     IN     DATE,
   until_date_    IN     DATE,
   total_amount_  IN     NUMBER,
   currency_code_ IN     VARCHAR2,
   distr_type_    IN     VARCHAR2 DEFAULT 'E' )
IS
   act_company_          VARCHAR2(20);
BEGIN
   act_company_ := company_;
   IF (allocation_id_ IS NULL) THEN
      Create_New_Allocation_Head (allocation_id_,
                                  act_company_,
                                  site_,
                                  creator_,
                                  from_date_,
                                  until_date_,
                                  total_amount_,
                                  currency_code_,
                                  distr_type_);
   END IF;
   Distribute_Allocation_Lines___ (allocation_id_,
                                   act_company_,
                                   from_date_,
                                   until_date_,
                                   total_amount_,
                                   distr_type_);
END Create_New_Alloc_Rule;


PROCEDURE Create_Alloc_Rule_Company (
   allocation_id_ IN OUT NUMBER,
   company_       IN     VARCHAR2,
   creator_       IN     VARCHAR2,
   from_date_     IN     DATE,
   until_date_    IN     DATE,
   total_amount_  IN     NUMBER,
   currency_code_ IN     VARCHAR2,
   distr_type_    IN     VARCHAR2 DEFAULT 'E' )
IS
BEGIN
   Create_New_Alloc_Rule (allocation_id_,
                          company_,
                          NULL,
                          creator_,
                          from_date_,
                          until_date_,
                          total_amount_,
                          currency_code_,
                          distr_type_);
END Create_Alloc_Rule_Company;


PROCEDURE Create_Alloc_Rule_Site (
   allocation_id_ IN OUT NUMBER,
   site_          IN     VARCHAR2,
   creator_       IN     VARCHAR2,
   from_date_     IN     DATE,
   until_date_    IN     DATE,
   total_amount_  IN     NUMBER,
   currency_code_ IN     VARCHAR2,
   distr_type_    IN     VARCHAR2 DEFAULT 'E' )
IS
   act_company_          VARCHAR2(20);
BEGIN
   Create_New_Alloc_Rule (allocation_id_,
                          act_company_,
                          site_,
                          creator_,
                          from_date_,
                          until_date_,
                          total_amount_,
                          currency_code_,
                          distr_type_);
END Create_Alloc_Rule_Site;


PROCEDURE Create_New_All_From_Parent (
   allocation_id_        IN OUT NUMBER,
   parent_allocation_id_ IN     NUMBER,
   total_amount_         IN     NUMBER,
   reverse_alloc_lines_  IN     VARCHAR2 DEFAULT 'FALSE')
IS
   company_                     VARCHAR2(20);
   creator_                     VARCHAR2(30);
   distr_type_                  VARCHAR2(1);
   currency_code_               VARCHAR2(3);
   from_date_                   DATE;
   until_date_                  DATE;
   alloc_amount_                NUMBER;
   CURSOR get_attr IS
      SELECT company,
             from_date,
             until_date,
             creator,
             distr_type,
             currency_code, 
             total_amount
      FROM   period_allocation_rule_tab
      WHERE  allocation_id = parent_allocation_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO company_,
                       from_date_,
                       until_date_,
                       creator_,
                       distr_type_,
                       currency_code_,
                       alloc_amount_;
   CLOSE get_attr;
   IF (total_amount_ = alloc_amount_) THEN
      RETURN;
   END IF;
   IF (allocation_id_ IS NULL) THEN
      Create_New_Allocation_Head (allocation_id_,
                                  company_,
                                  NULL,
                                  creator_,
                                  from_date_,
                                  until_date_,
                                  total_amount_,
                                  currency_code_,
                                  distr_type_);
   END IF;
   IF (allocation_id_ = parent_allocation_id_) THEN
      Distribute_Allocation_Lines___ (allocation_id_,
                                      company_,
                                      from_date_,
                                      until_date_,
                                      total_amount_,
                                      distr_type_,
                                      currency_code_);
   ELSIF (reverse_alloc_lines_ = 'TRUE') THEN 
      Reverse_Period_Alloc_Lines___ (allocation_id_,
                                     parent_allocation_id_);
   ELSE
      Distribute_Old_Lines___ (company_,
                               allocation_id_,
                               parent_allocation_id_,
                               total_amount_);
   END IF;
   IF (total_amount_ != alloc_amount_) THEN
      Update_Per_Alloc_Info (allocation_id_,
                             from_date_,
                             until_date_,
                             total_amount_,
                             distr_type_);   
   END IF;
END Create_New_All_From_Parent;


PROCEDURE Create_Period_Allocations (
   allocation_error_     IN OUT VARCHAR2,
   company_              IN     VARCHAR2,
   voucher_type_         IN     VARCHAR2,
   voucher_no_           IN     NUMBER,
   row_no_               IN     NUMBER,
   account_              IN     VARCHAR2,
   accounting_year_      IN     NUMBER,
   accounting_period_    IN     NUMBER,
   allocation_id_        IN OUT NUMBER,
   parent_allocation_id_ IN OUT NUMBER,
   vou_amount_           IN     NUMBER )
IS
   total_amount_                NUMBER;
   act_allocation_id_           NUMBER;
   user_group_                  VARCHAR2(30);
   until_year_                  NUMBER;
   until_period_                NUMBER;
   newrec_                      period_allocation_tab%ROWTYPE;
   ok_to_create_                VARCHAR2(5) := 'FALSE';
   not_open_percentage_         NUMBER := 0;
   not_open_amount_             NUMBER := 0;
   not_open_line_id_            NUMBER := 0;
   dummy_                       NUMBER;
   allocation_diff_             VARCHAR2(5);
   act_date_                    DATE;
   accounting_year_period_      NUMBER;
   act_year_period_             NUMBER;
   alloc_vou_type_              VARCHAR2(3);
   period_alloc_line_rec_       Period_Allocation_Rule_API.Public_Rec;
   
   CURSOR get_act_per_info IS
      SELECT  ((accounting_year * 100) + accounting_period)
      FROM    accounting_period_tab
      WHERE   company      = company_
      AND     date_from   <= act_date_
      AND     date_until  >= act_date_
      ORDER BY accounting_period ASC;
   --
   CURSOR get_until_year_period IS
      SELECT accounting_year,
             accounting_period
      FROM   period_alloc_rule_line_tab a
      WHERE  allocation_id = act_allocation_id_
      ORDER BY ((accounting_year * 100) + accounting_period) DESC;
   --
   CURSOR get_alloc_Lines IS
      SELECT alloc_line_id                                 alloc_line_id,
             accounting_year                               accounting_year,
             accounting_period                             accounting_period,
             ((accounting_year * 100) + accounting_period) year_period,
             percentage                                    percentage,
             amount                                        amount,
             ROWID                                         objid
      FROM   period_alloc_rule_line_tab a
      WHERE  allocation_id = act_allocation_id_
      ORDER BY ((accounting_year * 100) + accounting_period);
   --
   CURSOR exist_allocation IS
      SELECT 1
      FROM   period_allocation_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_
      AND    accounting_year = accounting_year_
      AND    alloc_period    = accounting_period_
      AND    alloc_year      = accounting_year_;
   --
BEGIN
   IF (Account_API.Get_Logical_Account_Type_Db (company_, account_) IN ('C','R','S')) THEN
      ok_to_create_ := 'TRUE';
   END IF;
   IF (ok_to_create_ = 'TRUE') THEN
      IF (Account_API.Is_Ledger_Account (company_, account_) OR
          Account_API.Is_Tax_Account (company_, account_)) THEN
         ok_to_create_ := 'FALSE';
      END IF;
   END IF;
   IF (ok_to_create_ = 'TRUE') THEN
      accounting_year_period_ := ((accounting_year_ * 100) + accounting_period_);
      act_date_               := TRUNC(SYSDATE);
      OPEN  get_act_per_info;
      FETCH get_act_per_info INTO act_year_period_;
      CLOSE get_act_per_info;
      act_allocation_id_ := allocation_id_;
      period_alloc_line_rec_   := Period_Allocation_Rule_API.Get(allocation_id_);
      total_amount_      := Get_Total_Amount (act_allocation_id_);
      IF (ABS(total_amount_) != ABS(vou_amount_)) THEN
         -- Does the amount differ when comparing the amount from Period Allocation Rule with Voucher Row Amount?
         parent_allocation_id_ := act_allocation_id_;
         act_allocation_id_    := NULL;
         Create_New_All_From_Parent (act_allocation_id_,
                                     parent_allocation_id_,
                                     vou_amount_);
      END IF;
      
      OPEN  get_until_year_period;
      FETCH get_until_year_period INTO until_year_, until_period_;
      CLOSE get_until_year_period;
      
     
      user_group_ := Voucher_API.Get_User_Group (company_,
                                                 voucher_type_,
                                                 accounting_year_,
                                                 voucher_no_);      
      IF alloc_vou_type_ IS NULL THEN                                           
         Voucher_Type_User_Group_API.Get_Default_Voucher_Type (alloc_vou_type_,
                                                               company_,
                                                               user_group_,
                                                               accounting_year_,
                                                               'X');  --function_group_
      END IF;                                                         
         
      IF (alloc_vou_type_ IS NULL) THEN
         Error_SYS.Record_General(lu_name_, 'WRONGUSRGRP: User group :P1 is not connected to a voucher type with function group X for accounting year :P2 in Company :P3.', user_group_, accounting_year_, company_);
      END IF;

      allocation_error_ := NULL;    
                
      FOR rec_ IN get_alloc_lines LOOP
         allocation_diff_            := 'FALSE';
         IF (rec_.year_period <= accounting_year_period_ AND
             User_Group_Period_API.Is_Period_Open (company_, rec_.accounting_year, rec_.accounting_period, user_group_) = 'FALSE') THEN
            not_open_percentage_     := not_open_percentage_ + rec_.percentage;
            IF (ABS(total_amount_) = ABS(vou_amount_) AND
                total_amount_ != vou_amount_) THEN             
                  not_open_amount_   := not_open_amount_     + (rec_.amount * -1);             
            ELSE
               not_open_amount_      := not_open_amount_     + rec_.amount;
            END IF;
            not_open_line_id_        := rec_.alloc_line_id;
            allocation_diff_         := 'TRUE';
         ELSE
            IF (User_Group_Period_API.Is_Period_Open (company_, rec_.accounting_year, rec_.accounting_period, user_group_) = 'FALSE' ) THEN
               Error_SYS.Record_General( lu_name_, 
                                         'NOTOPALLPER: Period :P1 is closed for user group :P2 in company :P3 when creating Period Allocation', 
                                         rec_.accounting_year || CHR(32) || rec_.accounting_period, 
                                         user_group_, 
                                         company_);
            END IF;
            newrec_.company          := company_;
            newrec_.accounting_year  := accounting_year_;
            newrec_.voucher_type     := voucher_type_;
            newrec_.voucher_no       := voucher_no_;
            newrec_.row_no           := row_no_;
            newrec_.creator          := period_alloc_line_rec_.creator;
            newrec_.distr_type       := period_alloc_line_rec_.distr_type;
            newrec_.from_date        := period_alloc_line_rec_.from_date;
            newrec_.until_date       := period_alloc_line_rec_.until_date;
            newrec_.alloc_period     := rec_.accounting_period;
            newrec_.alloc_year       := rec_.accounting_year;
            newrec_.alloc_percent    := rec_.percentage;
            newrec_.until_year       := until_year_;
            newrec_.until_period     := until_period_;
            
            
            IF (ABS(total_amount_) = ABS(vou_amount_) AND
                total_amount_ != vou_amount_) THEN
                  newrec_.alloc_amount:= rec_.amount * -1;
            ELSE
               newrec_.alloc_amount  := rec_.amount;
            END IF;
            
            IF (not_open_percentage_ != 0 OR
                not_open_amount_     != 0) THEN
               newrec_.alloc_percent := newrec_.alloc_percent + not_open_percentage_;
               newrec_.alloc_amount  := newrec_.alloc_amount  + not_open_amount_;
               not_open_percentage_  := 0;
               not_open_amount_      := 0;
            END IF;
            newrec_.user_group       := user_group_;
            newrec_.alloc_vou_type   := alloc_vou_type_;
            newrec_.alloc_line_id    := rec_.alloc_line_id;
            newrec_.creator          := period_alloc_line_rec_.creator;
            newrec_.distr_type       := period_alloc_line_rec_.distr_type;
            newrec_.from_date        := period_alloc_line_rec_.from_date;
            newrec_.until_date       := period_alloc_line_rec_.until_date;
            Period_Allocation_API.New_Record (newrec_);
         END IF;
         IF (allocation_diff_ = 'TRUE') THEN
            UPDATE period_alloc_rule_line_tab
               SET allocation_diff  = allocation_diff_
            WHERE  ROWID = rec_.objid;
            allocation_diff_         := 'FALSE';
         END IF;
      END LOOP;
      IF (not_open_percentage_ != 100) THEN
         IF (not_open_percentage_ != 0 OR
             not_open_amount_     != 0) THEN
            OPEN  exist_allocation;
            FETCH exist_allocation INTO dummy_;
            IF (exist_allocation%FOUND) THEN
               UPDATE Period_Allocation_Tab
                  SET alloc_percent = alloc_percent + not_open_percentage_,
                      alloc_amount  = alloc_amount + not_open_amount_
               WHERE  company         = company_
               AND    voucher_type    = voucher_type_
               AND    voucher_no      = voucher_no_
               AND    row_no          = row_no_
               AND    accounting_year = accounting_year_
               AND    alloc_period    = accounting_period_
               AND    alloc_year      = accounting_year_;
            ELSE
               newrec_.company          := company_;
               newrec_.accounting_year  := accounting_year_;
               newrec_.voucher_type     := voucher_type_;
               newrec_.voucher_no       := voucher_no_;
               newrec_.row_no           := row_no_;
               newrec_.accounting_year  := accounting_year_;
               newrec_.alloc_period     := accounting_period_;
               newrec_.alloc_year       := accounting_year_;
               newrec_.alloc_percent    := not_open_percentage_;
               newrec_.until_year       := until_year_;
               newrec_.until_period     := until_period_;
               newrec_.alloc_amount     := not_open_amount_;
               newrec_.user_group       := user_group_;
               newrec_.alloc_vou_type   := alloc_vou_type_;
               newrec_.alloc_line_id    := not_open_line_id_;
               newrec_.creator          := period_alloc_line_rec_.creator;
               newrec_.distr_type       := period_alloc_line_rec_.distr_type;
               Period_Allocation_API.New_Record (newrec_);
            END IF;
            CLOSE exist_allocation;
            newrec_.alloc_percent    := newrec_.alloc_percent + not_open_percentage_;
            newrec_.alloc_amount     := newrec_.alloc_amount  + not_open_amount_;
            not_open_percentage_     := 0;
            not_open_amount_         := 0;
         END IF;
      END IF;
      
      allocation_id_ := act_allocation_id_;
      
   END IF;
END Create_Period_Allocations;


PROCEDURE Exist_Accounting_Period (
   accounting_year_   IN NUMBER,
   accounting_period_ IN NUMBER,
   allocation_id_     IN NUMBER )
IS
   company_          VARCHAR2(20);
BEGIN
   company_ := Get_Company (allocation_id_);
   Accounting_Period_API.Exist (company_,
                                accounting_year_,
                                accounting_period_);
END Exist_Accounting_Period;


PROCEDURE Update_Per_Alloc_Info (
   allocation_id_ IN NUMBER,
   from_date_     IN DATE,
   until_date_    IN DATE,
   total_amount_  IN NUMBER,
   distr_type_    IN VARCHAR2 )
IS
BEGIN
   UPDATE period_allocation_rule_tab 
      SET from_date    = from_date_,
          until_date   = until_date_,
          total_amount = total_amount_,
          distr_type   = distr_type_,
          rowversion   = SYSDATE
   WHERE  allocation_id = allocation_id_;
END Update_Per_Alloc_Info;


PROCEDURE Update_Per_Alloc_Status (
   allocation_id_ IN NUMBER,
   status_        IN VARCHAR2 )
IS
BEGIN
   UPDATE period_allocation_rule_tab 
      SET status       = status_,
          rowversion   = SYSDATE
   WHERE allocation_id = allocation_id_;
END Update_Per_Alloc_Status;


PROCEDURE Calc_Percent_From_Amount(
   line_percent_ IN OUT NUMBER,
   company_      IN     VARCHAR2,
   total_amount_ IN     NUMBER,
   line_amount_  IN     NUMBER)
IS
   acc_currency_    VARCHAR2(3);
   rounding_        NUMBER;
   calc_percent_    NUMBER;
BEGIN
   acc_currency_ := Company_Finance_API.Get_Currency_Code (company_);
   rounding_     := Currency_Code_API.Get_Currency_Rounding (company_, acc_currency_);
   calc_percent_ := ROUND((line_amount_ / total_amount_) * 100,rounding_);
   line_percent_ := calc_percent_ / 100;   
END Calc_Percent_From_Amount;


PROCEDURE Calc_Amount_From_Percent (
   line_amount_  IN OUT NUMBER,
   company_      IN     VARCHAR2,
   total_amount_ IN     NUMBER,
   line_percent_ IN     NUMBER )
IS
   acc_currency_        VARCHAR2(3);
   rounding_            NUMBER;
   calc_amount_         NUMBER;
BEGIN
   acc_currency_ := Company_Finance_API.Get_Currency_Code (company_);
   rounding_     := Currency_Code_API.Get_Currency_Rounding (company_, acc_currency_);
   calc_amount_  := ROUND(total_amount_ * (line_percent_ / 100),rounding_);
   line_amount_  := calc_amount_;
END Calc_Amount_From_Percent;


PROCEDURE Compare_Distribution (
   total_amount_  IN NUMBER,
   allocation_id_ IN NUMBER )
IS
   sum_percentage_   NUMBER;
   sum_amount_       NUMBER;
   CURSOR sum_lines IS
      SELECT SUM(NVL(percentage,0)),
             SUM(NVL(amount,0))
      FROM   period_alloc_rule_line_tab
      WHERE  allocation_id = allocation_id_;
BEGIN
   OPEN  sum_lines;
   FETCH sum_lines INTO sum_percentage_, sum_amount_;
   CLOSE sum_lines;
   IF (total_amount_ IS NOT NULL) THEN
      IF (sum_amount_ != total_amount_) THEN
         Error_SYS.Record_General( lu_name_, 'DAMTERR: Distributed Amount :P1 is not equal to Total Amount',sum_amount_);
      END IF;
   ELSE
      IF (sum_percentage_ != 100) THEN
         Error_SYS.Record_General( lu_name_, 'DPRCERR: Distributed Percentage :P1 is not equal to 100',sum_percentage_);
      END IF;
   END IF;
END Compare_Distribution;


PROCEDURE Remove_Allocation (
   allocation_id_ IN NUMBER )
IS
   company_     VARCHAR2(20);
   alloc_exist_ VARCHAR2(5) := 'FALSE';
   CURSOR get_child IS
      SELECT allocation_id
      FROM   period_allocation_rule_tab
      WHERE  parent_allocation_id = allocation_id_;
BEGIN
   company_ := Period_Allocation_Rule_API.Get_Company(allocation_id_); 
   User_Finance_Api.Exist_Current_User(company_ );
   $IF Component_Genled_SYS.INSTALLED $THEN
      alloc_exist_ := Gen_Led_Voucher_Row_API.Check_Exist_Alloc_Id(allocation_id_);
   $END
   IF (alloc_exist_ = 'FALSE') THEN
      alloc_exist_ := Voucher_Row_API.Check_Exist_Alloc_Id (allocation_id_);
   END IF;
   IF (alloc_exist_ = 'FALSE') THEN
      FOR rec_ IN get_child LOOP
         Remove_Allocation (rec_.allocation_id);
      END LOOP;
      DELETE
      FROM  period_allocation_rule_tab
      WHERE allocation_id = allocation_id_;
      DELETE
      FROM  period_alloc_rule_line_tab
      WHERE allocation_id = allocation_id_;
   END IF;
END Remove_Allocation;


PROCEDURE Refresh_Per_Alloc_From_Vou (
   allocation_id_     IN NUMBER )
IS
   amount_to_allocate_   NUMBER;
   new_allocation_id_    NUMBER;
   parent_allocation_id_ NUMBER;
   allocation_error_     VARCHAR2(2000);
 
   CURSOR get_voucher_row IS
      SELECT company,
             voucher_type,
             voucher_no,
             row_no,
             account,
             accounting_year,
             accounting_period,
             currency_amount,
             parent_allocation_id,
             objid
      FROM   voucher_row t
      WHERE  allocation_id = allocation_id_;
BEGIN
    
   FOR rec_ IN get_voucher_row LOOP
      new_allocation_id_    := allocation_id_;
      parent_allocation_id_ := rec_.parent_allocation_id;     
      amount_to_allocate_   := rec_.currency_amount;
      
      DELETE
      FROM   period_allocation_tab
      WHERE  company         = rec_.company
      AND    voucher_type    = rec_.voucher_type
      AND    accounting_year = rec_.accounting_year
      AND    voucher_no      = rec_.voucher_no
      AND    row_no          = rec_.row_no;
      
      $IF Component_Intled_SYS.INSTALLED $THEN
         DELETE
         FROM   int_period_allocation_tab
         WHERE  company         = rec_.company
         AND    voucher_type    = rec_.voucher_type
         AND    accounting_year = rec_.accounting_year
         AND    voucher_no      = rec_.voucher_no;
      $END   
      
      Create_Period_Allocations (allocation_error_,
                                 rec_.company,
                                 rec_.voucher_type,
                                 rec_.voucher_no,
                                 rec_.row_no,
                                 rec_.account,
                                 rec_.accounting_year,
                                 rec_.accounting_period,
                                 new_allocation_id_,
                                 parent_allocation_id_,
                                 amount_to_allocate_);
      UPDATE voucher_row_tab
         SET allocation_id        = new_allocation_id_,
             parent_allocation_id = parent_allocation_id_,
             update_error         = allocation_error_
      WHERE  rowid = rec_.objid;
   END LOOP;
END Refresh_Per_Alloc_From_Vou;


PROCEDURE Exist_Any_Line (
   allocation_id_ IN OUT NUMBER )
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   period_alloc_rule_line_tab
      WHERE  allocation_id = allocation_id_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      dummy_ := 0;
   END IF;
   CLOSE exist_control;
   IF (dummy_ = 0) THEN
      Period_Allocation_Rule_API.Remove_Allocation (allocation_id_);
      allocation_id_ := NULL;
   END IF;
END Exist_Any_Line;


@UncheckedAccess
FUNCTION Validate_Per_All_Amt (
   allocation_id_ IN NUMBER,
   total_amount_  IN NUMBER) RETURN VARCHAR2
IS
   rule_amount_   NUMBER;
BEGIN
   rule_amount_ := Get_Total_Amount (allocation_id_);
   IF (rule_amount_ != total_amount_) THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
END Validate_Per_All_Amt;


PROCEDURE Remove_Invalid_Allocation (
   allocation_id_ IN OUT NUMBER )
IS
BEGIN
   Period_Allocation_Rule_API.Remove_Allocation (allocation_id_);
   allocation_id_ := NULL;
END Remove_Invalid_Allocation;


PROCEDURE Modify_Allocation_Head (
   allocation_id_   IN NUMBER,
   distr_type_      IN VARCHAR2 DEFAULT 'E',
   from_date_in_    IN DATE     DEFAULT NULL,
   until_date_in_   IN DATE     DEFAULT NULL,
   total_amount_in_ IN NUMBER   DEFAULT NULL)
IS
   company_             VARCHAR2(20); 
   from_date_           DATE;
   until_date_          DATE;
   total_amount_        NUMBER;
   rule_rec_            period_allocation_rule_tab%ROWTYPE;
     
   CURSOR get_attr IS
      SELECT from_date,
             until_date,
             total_amount
      FROM   period_allocation_rule_tab
      WHERE  allocation_id = allocation_id_;
BEGIN
   IF (from_date_in_ IS NOT NULL) THEN
      from_date_    := from_date_in_;
      until_date_   := until_date_in_;
      total_amount_ := total_amount_in_;
   ELSE
      OPEN  get_attr;
      FETCH get_attr INTO from_date_, until_date_, total_amount_;
      CLOSE get_attr;
   END IF;
   rule_rec_ := Get_Object_By_Keys___(allocation_id_);
   company_                      := rule_rec_.company; 
   rule_rec_.from_date           := from_date_;
   rule_rec_.until_date          := until_date_;
   rule_rec_.total_amount        := total_amount_;
   rule_rec_.distr_type          := distr_type_; 
   Modify___(rule_rec_);   
END Modify_Allocation_Head;


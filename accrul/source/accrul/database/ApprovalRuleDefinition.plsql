-----------------------------------------------------------------------------
--
--  Logical unit: ApprovalRuleDefinition
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

PROCEDURE Insert_Approvers_To_Voucher__(
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER )
IS
   approval_rule_id_    VARCHAR2(50);
   rec_                 Public_Rec;
BEGIN
   approval_rule_id_ := Get_Relevant_Rule_For_Vou__(company_, accounting_year_, voucher_type_, voucher_no_);
   IF (approval_rule_id_ IS NOT NULL) THEN
      Approval_Rule_Approver_API.Copy_Into_Voucher__(company_, accounting_year_, voucher_type_, voucher_no_, approval_rule_id_);
      rec_     := Approval_Rule_Definition_API.Get(company_, approval_rule_id_);      
      Voucher_API.Insert_Approve_Details__(company_, accounting_year_, voucher_type_, voucher_no_, rec_.two_approver_required, rec_.sequential_approval, approval_rule_id_);
   END IF;
END Insert_Approvers_To_Voucher__;

FUNCTION Get_Relevant_Rule_For_Vou__(
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER ) RETURN VARCHAR2
IS
   voucher_debit_sum_     NUMBER := 0;
   approval_rule_id_      VARCHAR2(50);
   voucher_type_priority_ NUMBER;
   amount_priority_       NUMBER;
   
   CURSOR get_approval_rule_definition IS
      SELECT a.approval_rule_id, decode(a.voucher_types, voucher_type_, 0, 1) voucher_type_priority,
             DECODE(a.minimum_amount, NULL, DECODE(a.maximum_amount, NULL, 4, 2), DECODE(a.maximum_amount, NULL, 3, 1)) amount_priority
      FROM   approval_rule_definition_tab a
      WHERE  a.company = company_
      AND    ((a.minimum_amount IS NOT NULL AND a.maximum_amount IS NOT NULL AND voucher_debit_sum_ BETWEEN a.minimum_amount AND a.maximum_amount) OR
              (a.minimum_amount IS NULL AND a.maximum_amount IS NOT NULL AND voucher_debit_sum_ <= a.maximum_amount) OR
              (a.minimum_amount IS NOT NULL AND a.maximum_amount IS NULL AND voucher_debit_sum_ >= a.minimum_amount) OR
              (a.minimum_amount IS NULL AND a.maximum_amount IS NULL))
      AND    ((voucher_type_ LIKE a.voucher_types) OR INSTR(';'||voucher_types||';',';'||voucher_type_||';')> 0 )
      AND    a.rowstate = 'Active'
      ORDER BY voucher_type_priority, amount_priority;
BEGIN
   IF (Voucher_Type_API.Get_Use_Approval_Workflow(company_,voucher_type_) = 'TRUE') THEN
      voucher_debit_sum_ := ABS(Voucher_API.Get_Sum(company_, accounting_year_, voucher_type_, voucher_no_, 'debit'));
      OPEN get_approval_rule_definition;
      FETCH get_approval_rule_definition INTO approval_rule_id_, voucher_type_priority_, amount_priority_;
      IF get_approval_rule_definition%FOUND THEN
         CLOSE get_approval_rule_definition;
         RETURN approval_rule_id_;
      END IF;
      CLOSE get_approval_rule_definition;
   END IF;
   RETURN NULL;
END Get_Relevant_Rule_For_Vou__;

PROCEDURE Check_If_Rule_Overlaps__(
   param_rec_ IN approval_rule_definition_tab%ROWTYPE)
IS
   current_rule_ approval_rule_definition_tab%ROWTYPE;
   voucher_type_ VARCHAR2(3);
   
   CURSOR get_intersecting_rules(current_voucher_types_ VARCHAR2, new_voucher_types_ VARCHAR2) IS
      SELECT v.voucher_type
        FROM voucher_type_tab v
       WHERE v.company = current_rule_.company
         AND ((v.voucher_type LIKE current_voucher_types_) OR INSTR(';'||current_voucher_types_||';',';'||v.voucher_type||';')> 0 )
      INTERSECT
       SELECT v.voucher_type
         FROM voucher_type_tab v
        WHERE v.company = current_rule_.company
          AND ((v.voucher_type LIKE new_voucher_types_) OR INSTR(';'||new_voucher_types_||';',';'||v.voucher_type||';')> 0 );
         
   CURSOR get_all_active_rules IS
     SELECT *
        FROM approval_rule_definition_tab a
       WHERE a.company = current_rule_.company
         AND a.rowstate = 'Active';
BEGIN
   current_rule_ := param_rec_;
   
   FOR rec_ IN get_all_active_rules LOOP
      OPEN get_intersecting_rules(rec_.voucher_types, current_rule_.voucher_types);
      FETCH get_intersecting_rules INTO voucher_type_;
      IF get_intersecting_rules%NOTFOUND THEN
         voucher_type_ := NULL;
      END IF;
      CLOSE get_intersecting_rules;
      IF voucher_type_ IS NOT NULL THEN
         rec_.minimum_amount           := NVL(rec_.minimum_amount,0);
         current_rule_.minimum_amount  := NVL(current_rule_.minimum_amount,0);
         IF (rec_.maximum_amount IS NULL AND current_rule_.maximum_amount IS NULL) THEN
            IF (rec_.minimum_amount < current_rule_.minimum_amount) THEN
               rec_.maximum_amount          := current_rule_.minimum_amount;
               current_rule_.maximum_amount := current_rule_.minimum_amount;
            ELSE
               rec_.maximum_amount          := rec_.minimum_amount;
               current_rule_.maximum_amount := rec_.minimum_amount;
            END IF;
         ELSIF  (rec_.maximum_amount IS NULL AND current_rule_.maximum_amount IS NOT NULL) THEN
            IF (rec_.minimum_amount < current_rule_.maximum_amount) THEN
               rec_.maximum_amount          := current_rule_.maximum_amount;
            ELSE
               rec_.maximum_amount          := rec_.minimum_amount;
            END IF;
         ELSIF  (rec_.maximum_amount IS NOT NULL AND current_rule_.maximum_amount IS NULL) THEN
            IF (current_rule_.minimum_amount < rec_.maximum_amount) THEN
               current_rule_.maximum_amount          := rec_.maximum_amount;
            ELSE
               current_rule_.maximum_amount          := current_rule_.minimum_amount;
            END IF;
         END IF;
         
         IF (rec_.minimum_amount <= current_rule_.maximum_amount AND  current_rule_.minimum_amount <= rec_.maximum_amount) THEN
            Error_SYS.Record_General(lu_name_, 'AMOUNTSOVERLAP: You cannot activate rule id :P1 because the defined amount range overlaps with rule id :P2 based on voucher type :P3.', current_rule_.approval_rule_id, rec_.approval_rule_id, voucher_type_);
         END IF;
      END IF;
   END LOOP;
END Check_If_Rule_Overlaps__;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     approval_rule_definition_tab%ROWTYPE,
   newrec_ IN OUT approval_rule_definition_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.rowstate = 'Active') THEN
      Error_SYS.Record_General(lu_name_,'CANNOTUPDATEWHENACTIVE: Update is not allowed when the approver assigning rule is in status Active.');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Update___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     approval_rule_definition_tab%ROWTYPE,
   newrec_ IN OUT approval_rule_definition_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.two_approver_required = 'FALSE' AND newrec_.sequential_approval = 'TRUE') THEN
      newrec_.sequential_approval := 'FALSE';
   END IF;   
   IF nvl(newrec_.minimum_amount,0) < 0 OR  nvl(newrec_.maximum_amount,0) < 0 THEN
      Error_SYS.Record_General(lu_name_, 'AMOUNTPOSITIVE: Amounts must be positive.');
   END IF;
   IF (newrec_.minimum_amount IS NOT NULL AND newrec_.maximum_amount IS NOT NULL AND
      newrec_.minimum_amount > newrec_.maximum_amount) THEN
      Error_SYS.Record_General(lu_name_, 'MINBIGGERTHANMAX: Maximum Amount in Accounting Currency should be greater than the Minimum Amount in Accounting Currency.');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

PROCEDURE Do_Activate___ (
   rec_  IN OUT NOCOPY approval_rule_definition_tab%ROWTYPE,
   attr_ IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   Check_If_Rule_Overlaps__(rec_);
END Do_Activate___;

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     approval_rule_definition_tab%ROWTYPE,
   newrec_     IN OUT approval_rule_definition_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);   
   IF (newrec_.sequential_approval != oldrec_.sequential_approval) THEN
      Approval_Rule_Approver_API.Reorder_Sequence_Number__(newrec_.company,newrec_.approval_rule_id,newrec_.sequential_approval);
   END IF;   
END Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU  NEW METHODS -------------------------------------

-----------------------------------------------------------------------------
--
--  Logical unit: ApprovalRuleApprover
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
   oldrec_ IN     approval_rule_approver_tab%ROWTYPE,
   newrec_ IN OUT approval_rule_approver_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   approval_rule_status_  VARCHAR2(20);
   approval_rule_definition_rec_ approval_rule_definition_API.Public_Rec;
BEGIN
   approval_rule_definition_rec_ := approval_rule_definition_API.Get(newrec_.company,newrec_.approval_rule_id);
   approval_rule_status_ := approval_rule_definition_rec_.rowstate;
   IF (approval_rule_status_ = 'Active') THEN
      Error_SYS.Record_General(lu_name_,'CANNOTUPDATEWHENACTIVE: Update is not allowed when the approver assigning rule is in status Active.');
   END IF;
   IF (newrec_.approver_id IS NOT NULL AND newrec_.approver_group_id IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_,'ONLYAPPROVERORGROUP: Either one Approver ID or one Approver Group can be specified. not both.');
   ELSIF (newrec_.approver_id IS NULL AND newrec_.approver_group_id IS NULL) THEN
      Error_SYS.Record_General(lu_name_,'MUSTAPPROVERORGROUP: An Approver ID or an Approver Group must be specified.');
   END IF;
   
   IF (approval_rule_definition_rec_.Sequential_Approval = 'TRUE' AND newrec_.sequence IS NULL) THEN
      Error_SYS.Record_General(lu_name_,'SEQUENCEREQUIRED: Sequence number should be specified when Sequential Approval is enabled in the Approval Rule.');
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Common___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   new_attr_          VARCHAR2(4000);
   company_           VARCHAR2(20);
   approval_rule_id_  VARCHAR2(50);
   sequence_          NUMBER;
BEGIN
   new_attr_ := attr_;
   super(attr_);
   company_          := Client_SYS.Get_Item_Value('COMPANY', new_attr_);
   approval_rule_id_ := Client_SYS.Get_Item_Value('APPROVAL_RULE_ID', new_attr_);
   sequence_ := Get_Next_Sequence__(company_,approval_rule_id_);
   Client_SYS.Add_To_Attr('SEQUENCE', sequence_, attr_);
END Prepare_Insert___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT approval_rule_approver_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.Approval_Rule_Row_Id := Get_Next_Approval_Row_Id___(newrec_.company);
   super(newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Insert___;

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN approval_rule_approver_tab%ROWTYPE )
IS
BEGIN
   Error_SYS.Record_General(lu_name_,'APPROVALRULEAPPROVEREXISTS: Approver/Approver Group already exists in Approval Rule :P1', rec_.approval_rule_id);
   super(rec_);
END Raise_Record_Exist___;

FUNCTION Get_Next_Approval_Row_Id___ (
   company_ IN VARCHAR2) RETURN NUMBER
IS
   next_id_ NUMBER;
BEGIN
   SELECT MAX(Approval_Rule_Row_Id) INTO next_id_
     FROM approval_rule_approver_tab
    WHERE company = company_;
   RETURN NVL(next_id_,0)+1;
END Get_Next_Approval_Row_Id___;

PROCEDURE Check_Approver_Detail_Ref___ (
   newrec_ IN OUT NOCOPY approval_rule_approver_tab%ROWTYPE )
IS
BEGIN
   IF (newrec_.approver_id IS NOT NULL) THEN
      User_Finance_API.Exist(newrec_.company, newrec_.approver_id);
   END IF;
   IF (newrec_.approver_group_id IS NOT NULL) THEN
      Approver_Group_API.Exist(newrec_.company, newrec_.approver_group_id);
   END IF;
   Approver_Detail_API.Check_Exist_For_Date(newrec_.company, newrec_.approver_id, newrec_.approver_group_id, sysdate);
END Check_Approver_Detail_Ref___;


PROCEDURE Check_Approver_Id_Ref___ (
   newrec_ IN OUT NOCOPY approval_rule_approver_tab%ROWTYPE )
IS
   
BEGIN
   Check_Approver_Detail_Ref___(newrec_);
END Check_Approver_Id_Ref___;


PROCEDURE Check_Approver_Group_Ref___ (
   newrec_ IN OUT NOCOPY approval_rule_approver_tab%ROWTYPE )
IS
   
BEGIN
   Check_Approver_Detail_Ref___(newrec_);
END Check_Approver_Group_Ref___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Approver_Reference__ (
   company_            IN VARCHAR2,
   approver_detail_id_ IN VARCHAR2,
   valid_from_         IN VARCHAR2)
IS
   count_ NUMBER;
   dummy_ NUMBER;
   prefix_ VARCHAR2(2);
   approver_group_     VARCHAR2(30);
   approver_ VARCHAR2(30);
   CURSOR check_exists IS
      SELECT 1
        FROM approval_rule_approver_tab v
       WHERE company = company_
         AND NVL(v.approver_id, ' ') = NVL(approver_, ' ')
         AND NVL(v.approver_group_id, ' ') = NVL(approver_group_,' ');
BEGIN
   count_ := Approver_Detail_API.Get_Rowcount_For_Given_Id__(company_,approver_detail_id_);
   IF count_ = 1  THEN
      prefix_ := SUBSTR(approver_detail_id_,1,2);
      IF (prefix_ = '1_') THEN
         approver_ := SUBSTR(approver_detail_id_,3);
      ELSE
         approver_group_ := SUBSTR(approver_detail_id_,3);
      END IF;
      OPEN check_exists;
      FETCH check_exists INTO dummy_;
      IF check_exists%FOUND THEN
         CLOSE check_exists;
         Error_SYS.Record_General(lu_name_, 'APPROVERUSED: Cannot delete Approver/Approver Group as it is used in Approver Assigning Rule.');
      END IF;
      CLOSE check_exists;
   END IF;
END Check_Approver_Reference__;

PROCEDURE Reorder_Sequence_Number__ (
   company_             IN VARCHAR2,
   approval_rule_id_    IN VARCHAR2,
   sequencial_approval_ IN VARCHAR2 )
IS
   newrec_        approval_rule_approver_tab%ROWTYPE;
   sequence_      NUMBER;
   CURSOR reoder_sequence_number_ IS
      SELECT *
        FROM approval_rule_approver_tab v
       WHERE company = company_
         AND approval_rule_id = approval_rule_id_
    ORDER BY sequence;
BEGIN
   sequence_ := 1;
   FOR rec_ IN reoder_sequence_number_ LOOP
      newrec_ := rec_;
      IF (sequencial_approval_ != 'TRUE')THEN
         newrec_.sequence := NULL;
         Modify___(newrec_);
      ELSE
         IF (nvl(newrec_.sequence,0) != sequence_) THEN
            newrec_.sequence := sequence_;
            Modify___(newrec_);
         END IF;
         sequence_ := sequence_ + 1;
      END IF;
   END LOOP;
END Reorder_Sequence_Number__;

FUNCTION Get_Next_Sequence__ (
   company_             IN VARCHAR2,
   approval_rule_id_    IN VARCHAR2) RETURN NUMBER
IS
   next_sequence_ NUMBER;
BEGIN
   SELECT MAX(sequence) INTO next_sequence_
     FROM approval_rule_approver_tab
    WHERE company = company_
      AND approval_rule_id = approval_rule_id_;
   RETURN NVL(next_sequence_,0)+1;
END Get_Next_Sequence__;

PROCEDURE Validate_Sequence__(
   company_             IN VARCHAR2,
   approval_rule_id_    IN VARCHAR2)
IS
   prev_sequence_    NUMBER := 0;
   CURSOR check_sequence_ IS
      SELECT sequence
        FROM approval_rule_approver_tab v
       WHERE company = company_
         AND approval_rule_id = approval_rule_id_
       ORDER BY sequence;
BEGIN
   IF Approval_Rule_Definition_API.Get_Sequential_Approval_Db(company_, approval_rule_id_) = 'TRUE' THEN
      FOR rec_ IN check_sequence_ LOOP
         IF (NVL(rec_.sequence,0) != prev_sequence_+1) THEN
            Error_SYS.Record_General(lu_name_,'NOTINSEQUENCE: Sequence should be defined in a consecutive order starting from 1.');
         END IF;
         prev_sequence_ := prev_sequence_+1;
      END LOOP;
   END IF;
END Validate_Sequence__;

PROCEDURE Exist_Approver_Connection__ (
   company_            IN VARCHAR2,
   approval_rule_id_   IN VARCHAR2,
   approver_           IN VARCHAR2,
   approver_group_     IN VARCHAR2)
IS
   dummy_ NUMBER;
   CURSOR check_exists IS
      SELECT 1
        FROM approval_rule_approver_tab
       WHERE company = company_
         AND approval_rule_id = approval_rule_id_
         AND (approver_id = approver_
         OR   approver_group_id = approver_group_);
BEGIN
   OPEN check_exists;
   FETCH check_exists INTO dummy_;
   IF check_exists%NOTFOUND THEN
      CLOSE check_exists;
      Error_SYS.Record_General(lu_name_, 'APPROVERNOTEXISTS: Cannot insert Approver/Approver Group as it is not used in Approver Assigning Rule.');
   END IF;
   CLOSE check_exists;
END Exist_Approver_Connection__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Copy_Into_Voucher__(
   company_          VARCHAR2,
   accounting_year_  NUMBER,
   voucher_type_     VARCHAR2,
   voucher_no_       NUMBER,
   approval_rule_id_ VARCHAR2 )
IS
   newrec_ voucher_candidate_approver_tab%ROWTYPE;
   emptyrec_ voucher_candidate_approver_tab%ROWTYPE;
   dummy_ NUMBER;
   
   CURSOR is_voucher_approvers_exist IS
      SELECT 1
        FROM Voucher_Candidate_Approver_Tab v
       WHERE v.company = company_
         AND v.accounting_year = accounting_year_
         AND v.voucher_type = voucher_type_
         AND v.voucher_no = voucher_no_;
   
   CURSOR get_approvers IS
      SELECT *
        FROM approval_rule_approver_tab a
       WHERE a.company = company_
         AND a.approval_rule_id = approval_rule_id_;
BEGIN
   OPEN is_voucher_approvers_exist;
   FETCH is_voucher_approvers_exist INTO dummy_;
   IF is_voucher_approvers_exist%NOTFOUND THEN
      FOR rec_ IN get_approvers LOOP
         newrec_ := emptyrec_;
         newrec_.company := company_;
         newrec_.accounting_year := accounting_year_;
         newrec_.voucher_type := voucher_type_;
         newrec_.voucher_no := voucher_no_;
         newrec_.sequence := rec_.sequence;
         newrec_.approver_id := rec_.approver_id;
         newrec_.approver_group_id := rec_.approver_group_id;
         Voucher_Candidate_Approver_API.New__(newrec_);
      END LOOP;
   END IF;
   CLOSE is_voucher_approvers_exist;
END Copy_Into_Voucher__;

-------------------- LU  NEW METHODS -------------------------------------

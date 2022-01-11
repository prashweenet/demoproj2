-----------------------------------------------------------------------------
--
--  Logical unit: VoucherCandidateApprover
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

PROCEDURE Check_Approver_Detail_Ref___ (
   newrec_ IN OUT NOCOPY voucher_candidate_approver_tab%ROWTYPE )
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

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_candidate_approver_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.voucher_approver_row_id := Get_Next_Approver_Row_Id___(newrec_.company,newrec_.accounting_year,newrec_.voucher_type,newrec_.voucher_no);
   Validate_New_Approver___(newrec_);
   super(newrec_, indrec_, attr_);
END Check_Insert___;

PROCEDURE Update_Error_Text___ (
   company_                 IN VARCHAR2,
   accounting_year_         IN NUMBER,
   voucher_type_            IN VARCHAR2,
   voucher_no_              IN NUMBER,
   voucher_approver_row_id_ IN VARCHAR2,
   error_text_              IN VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   UPDATE voucher_candidate_approver_tab v
      SET v.error_text = SUBSTR(error_text_, INSTR(error_text_,':', 1, 2) + 1, 200)
    WHERE v.company                 = company_
      AND v.accounting_year         = accounting_year_
      AND v.voucher_type            = voucher_type_
      AND v.voucher_no              = voucher_no_
      AND v.voucher_approver_row_id = voucher_approver_row_id_;
   @ApproveTransactionStatement(2016-12-08,maaylk)
   COMMIT;
END Update_Error_Text___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_candidate_approver_tab%ROWTYPE,
   newrec_ IN OUT voucher_candidate_approver_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.authorization_status = 'APPROVED') THEN
      Error_SYS.Record_General(lu_name_, 'CANNOTMODIFYWHENAPPROVED: It is not possible to modify a line which has Approved status. Cancel the approval and continue.');
   END IF;
   Validate_New_Approver___(newrec_);
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Update___;




@Override
PROCEDURE Check_Delete___ (
   remrec_ IN voucher_candidate_approver_tab%ROWTYPE )
IS
BEGIN
   IF (remrec_.authorization_status = 'APPROVED') THEN
      Error_SYS.Record_General(lu_name_, 'CANNOTDELETEWHENAPPROVED: It is not possible to delete a line which has Approved status. Cancel the approval and continue.');
   END IF;
   super(remrec_);
END Check_Delete___;


FUNCTION Get_Next_Approver_Row_Id___ (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER) RETURN NUMBER
IS
   next_id_ NUMBER;
BEGIN
   SELECT MAX(voucher_approver_row_id) INTO next_id_
     FROM voucher_candidate_approver_tab
    WHERE company          = company_
      AND accounting_year  = accounting_year_
      AND voucher_type     = voucher_type_
      AND voucher_no       = voucher_no_;
      
   RETURN NVL(next_id_,0)+1;
END Get_Next_Approver_Row_Id___;

PROCEDURE Validate_New_Approver___ (
   rec_ IN voucher_candidate_approver_tab%ROWTYPE)
IS
   approval_rule_id_ VARCHAR2(20) := Voucher_API.Get_Approval_Rule_Id(rec_.company, rec_.accounting_year, rec_.voucher_type, rec_.voucher_no);
BEGIN
   IF (approval_rule_id_ IS NOT NULL) THEN
      Approval_Rule_Approver_API.Exist_Approver_Connection__(rec_.company, approval_rule_id_, rec_.approver_id, rec_.approver_group_id);
   END IF;
END Validate_New_Approver___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE New__ (
   newrec_ IN OUT NOCOPY voucher_candidate_approver_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END New__;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Approve__ (
   company_                 IN VARCHAR2,
   accounting_year_         IN NUMBER,
   voucher_type_            IN VARCHAR2,
   voucher_no_              IN NUMBER,
   voucher_approver_row_id_ IN VARCHAR2,
   user_group_              IN VARCHAR2 DEFAULT NULL)
IS
   oldrec_                  voucher_candidate_approver_tab%ROWTYPE;
   newrec_                  voucher_candidate_approver_tab%ROWTYPE;
   objid_                   VARCHAR2(2000);
   objversion_              VARCHAR2(2000);
   attr_                    VARCHAR2(2000);
   info_                    VARCHAR2(2000);
   current_userid_          VARCHAR2(30);
   current_approver_        VARCHAR2(30);
   current_approver_group_  VARCHAR2(30);
   current_sequence_        NUMBER;
   old_sequence_exists_     NUMBER;
   voucher_date_            DATE;
   approver_detail_rec_     Approver_Detail_API.Public_Rec;
   approver_grp_detail_rec_ Approver_Detail_API.Public_Rec;
   voucher_debit_sum_       NUMBER;
   timestamp_               DATE;
   new_vourec_              voucher_tab%ROWTYPE;
   seperate_approval_db_    VARCHAR2(20);
   voucher_status_          VARCHAR2(20);
   
   CURSOR get_approver_detail IS
     SELECT v.approver_id, v.approver_group_id
       FROM voucher_candidate_approver_tab v
      WHERE v.company                 = company_
        AND v.accounting_year         = accounting_year_
        AND v.voucher_type            = voucher_type_
        AND v.voucher_no              = voucher_no_
        AND v.voucher_approver_row_id = voucher_approver_row_id_;
        
   CURSOR get_voucher IS
     SELECT v.*
       FROM voucher_tab v
      WHERE v.company                 = company_
        AND v.accounting_year         = accounting_year_
        AND v.voucher_type            = voucher_type_
        AND v.voucher_no              = voucher_no_;
        
   CURSOR get_vou_row IS
     SELECT r.row_no, r.posting_combination_id
       FROM voucher_row_tab r
      WHERE r.company         = company_
        AND r.accounting_year = accounting_year_
        AND r.voucher_type    = voucher_type_
        AND r.voucher_no      = voucher_no_;

   CURSOR check_prior_sequence_exist IS
     SELECT 1
       FROM voucher_candidate_approver_tab v
      WHERE v.company                        = company_
        AND v.accounting_year                = accounting_year_
        AND v.voucher_type                   = voucher_type_
        AND v.voucher_no                     = voucher_no_
        AND v.sequence                       < current_sequence_
        AND NVL(v.authorization_status,' ') != 'APPROVED';

   CURSOR check_user_already_approved IS
     SELECT 1
       FROM voucher_candidate_approver_tab v
      WHERE v.company         = company_
        AND v.accounting_year = accounting_year_
        AND v.voucher_type    = voucher_type_
        AND v.voucher_no      = voucher_no_
        AND v.approved_by     = current_userid_;
BEGIN
   voucher_status_ := Voucher_API.Get_Objstate(company_, accounting_year_, voucher_type_, voucher_no_);
   IF (voucher_status_ = 'Error') THEN
      BEGIN
         Error_SYS.Record_General(lu_name_, 'CANNOTAPPROVEWHENERROR: Cannot Approve when voucher is in Error status.');
      EXCEPTION
      WHEN OTHERS THEN
         Update_Error_Text___(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_, sqlerrm);
         RAISE;
      END;
   ELSIF  (voucher_status_ = 'Confirmed') THEN
      Error_SYS.Record_General(lu_name_, 'VOUCHERALREADYAPPROVED: This voucher is already approved.');
   END IF;
   OPEN get_voucher;
   FETCH get_voucher INTO new_vourec_;
   CLOSE get_voucher;
      
   IF user_group_ IS NOT NULL THEN
      new_vourec_.user_group := user_group_;
      Voucher_API.Modify__(new_vourec_, FALSE);
   END IF;
   
   BEGIN
      IF (new_vourec_.sequential_approval = 'TRUE') THEN
         current_sequence_ := Get_Sequence(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_);
      END IF;
      IF (current_sequence_ IS NOT NULL) THEN
         OPEN  check_prior_sequence_exist;
         FETCH check_prior_sequence_exist INTO old_sequence_exists_;
         IF (check_prior_sequence_exist%FOUND) THEN
            CLOSE check_prior_sequence_exist;
            Error_SYS.Record_General(lu_name_, 'NOTINSEQUENCE: Voucher should be approved in the sequential order.');
         END IF;
         CLOSE check_prior_sequence_exist;
      END IF;

      current_userid_ := Fnd_Session_API.Get_Fnd_User;

      seperate_approval_db_ :=  Voucher_Type_API.Get_Separate_User_Approval_Db(company_, 
                                                                               voucher_type_);

      IF (seperate_approval_db_ = 'TRUE' AND (new_vourec_.userid = current_userid_ OR new_vourec_.userid IS NULL)) THEN
         Error_SYS.Appl_General(lu_name_, 'SEPUSERAPP: The voucher cannot be approved by :P1 user as :P2 voucher type is defined with the option Separate User Approval.',current_userid_,voucher_type_);
      END IF;
      
      OPEN get_approver_detail;
      FETCH get_approver_detail INTO current_approver_, current_approver_group_;
      CLOSE get_approver_detail;

      voucher_date_      := Voucher_API.Get_Voucher_Date(company_, accounting_year_, voucher_type_, voucher_no_);
      voucher_debit_sum_ := Voucher_API.Get_Sum(company_, accounting_year_, voucher_type_, voucher_no_, 'debit');

      IF (current_approver_ IS NOT NULL) THEN
         IF (current_userid_ != current_approver_) THEN
            Error_SYS.Record_General(lu_name_, 'USERNOTALLOWED: User :P1 is not allowed to approve for Approver :P2.', current_userid_, current_approver_);
         END IF;
      END IF;
   
      --Voucher_Type_User_Group_API.Check_User_Have_Approvability(company_, voucher_type_, accounting_year_, current_userid_);
      
      OPEN check_user_already_approved;
      FETCH check_user_already_approved INTO old_sequence_exists_;
      IF (check_user_already_approved%FOUND) THEN
         CLOSE check_user_already_approved;
         Error_SYS.Record_General(lu_name_, 'USERLREADYAPPROVED: This voucher is already approved by user :P1.',current_userid_);
      END IF;
      CLOSE check_user_already_approved;
   
      IF current_approver_group_ IS NOT NULL THEN
         IF NOT Approver_Group_Detail_API.Exists(company_,current_approver_group_,current_userid_) THEN
            Error_SYS.Record_General(lu_name_, 'USERNOTMEMBEROFGRP: User :P1 is not a member of Approver Group :P2.', current_userid_, current_approver_group_);
         END IF;

         approver_grp_detail_rec_ := Approver_Detail_API.Get_Rec(company_,NULL,current_approver_group_,voucher_date_);
         IF (approver_grp_detail_rec_.valid_from IS NULL) THEN
            Error_SYS.Record_General(lu_name_, 'APPROVERGRPVALIDFROM: Valid From date of the Approver Group should be earlier than the Voucher Date.');
         END IF;
         IF voucher_debit_sum_ > approver_grp_detail_rec_.amount THEN
            Error_SYS.Record_General(lu_name_, 'GRPAMOUNTCRITERIAFAIL: Amount :P1 in the voucher exceeds the maximum allowed amount of the Approver Group :P2.', voucher_debit_sum_, current_approver_group_);
         END IF;
      END IF;

      approver_detail_rec_ := Approver_Detail_API.Get_Rec(company_,current_userid_,NULL,voucher_date_);
      IF (approver_detail_rec_.valid_from IS NULL) THEN
         Error_SYS.Record_General(lu_name_, 'APPROVERVALIDFROM: Valid From date of the Approver should be earlier than the Voucher Date.');
      END IF;
      IF approver_detail_rec_.amount IS NOT NULL THEN
         IF voucher_debit_sum_ > approver_detail_rec_.amount THEN
            Error_SYS.Record_General(lu_name_, 'AMOUNTCRITERIAFAIL: Amount :P1 in the voucher exceeds the maximum allowed amount of user :P2.', voucher_debit_sum_, current_approver_);
         END IF;
      END IF;

      FOR rec_ IN get_vou_row LOOP
         IF (approver_grp_detail_rec_.combination_rule_id IS NOT NULL) THEN
            IF (Approver_Comb_Rule_Detail_API.Is_Allowed(company_, approver_grp_detail_rec_.combination_rule_id , rec_.posting_combination_id) != 'TRUE') THEN
               Error_SYS.Record_General(lu_name_, 'APPROVERGRPNOTALLOWED: Approver Group :P1 is not allowed to approve the code string combination in voucher row number :P2.', current_approver_group_, rec_.row_no);
            END IF;
         END IF;
         IF (approver_detail_rec_.combination_rule_id IS NOT NULL) THEN
            IF (Approver_Comb_Rule_Detail_API.Is_Allowed(company_, approver_detail_rec_.combination_rule_id , rec_.posting_combination_id) != 'TRUE') THEN
               Error_SYS.Record_General(lu_name_, 'APPROVERNOTALLOWED: Approver :P1 is not allowed to approve the code string combination in voucher row number :P2.', current_userid_, rec_.row_no);
            END IF;
         END IF;
      END LOOP;

      timestamp_  := sysdate;
      attr_       := NULL;
      Client_SYS.Add_To_Attr('APPROVED_BY', current_userid_, attr_);
      Client_SYS.Add_To_Attr('TIMESTAMP', timestamp_, attr_);
      Client_SYS.Add_To_Attr('APPROVED_BY_USER_GROUP', new_vourec_.user_group, attr_);
      Voucher_API.Ready_To_Update__(info_, company_, accounting_year_, voucher_type_, voucher_no_, attr_, 'DO');

      attr_       := NULL;
      oldrec_     := Lock_By_Keys___(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_);
      newrec_     := oldrec_;
      newrec_.authorization_status := 'APPROVED';
      newrec_.approved_by          := current_userid_;
      newrec_.timestamp            := timestamp_;
      newrec_.error_text           := NULL;
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   EXCEPTION
      WHEN OTHERS THEN
         Update_Error_Text___(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_, sqlerrm);
         RAISE;
   END;
END Approve__;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Remove_Approve__ (
   company_                 IN VARCHAR2,
   accounting_year_         IN NUMBER,
   voucher_type_            IN VARCHAR2,
   voucher_no_              IN NUMBER,
   voucher_approver_row_id_ IN VARCHAR2 )
IS
   oldrec_                 voucher_candidate_approver_tab%ROWTYPE;
   newrec_                 voucher_candidate_approver_tab%ROWTYPE;
   objid_                  VARCHAR2(2000);
   objversion_             VARCHAR2(2000);
   attr_                   VARCHAR2(2000);
   info_                   VARCHAR2(2000);
   current_userid_         VARCHAR2(30);
   current_approver_       VARCHAR2(30);
   current_approver_group_ VARCHAR2(30);
   current_sequence_       NUMBER;
   next_sequence_exists_   NUMBER;
   vou_rec_                Voucher_API.Public_Rec;
   
   CURSOR get_approver_detail IS
     SELECT v.approver_id, v.approver_group_id
       FROM voucher_candidate_approver_tab v
      WHERE v.company                 = company_
        AND v.accounting_year         = accounting_year_
        AND v.voucher_type            = voucher_type_
        AND v.voucher_no              = voucher_no_
        AND v.voucher_approver_row_id = voucher_approver_row_id_;
        
   CURSOR check_next_sequence_exist IS
     SELECT 1
       FROM voucher_candidate_approver_tab v
      WHERE v.company                 = company_
        AND v.accounting_year         = accounting_year_
        AND v.voucher_type            = voucher_type_
        AND v.voucher_no              = voucher_no_
        AND v.sequence                > current_sequence_
        AND NVL(v.authorization_status,' ')  = 'APPROVED';
BEGIN
   BEGIN
      IF (Voucher_API.Get_Objstate(company_, accounting_year_, voucher_type_, voucher_no_) IN ('Error')) THEN
         Error_SYS.Record_General(lu_name_, 'CANNOTREMOVEAPPROVE: Cannot Cancel Approval when voucher is in Error status.');
      END IF;
   
   EXCEPTION
      WHEN OTHERS THEN
         Update_Error_Text___(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_, sqlerrm);
         RAISE;
   END;
   current_userid_ := Fnd_Session_API.Get_Fnd_User;
   OPEN get_approver_detail;
   FETCH get_approver_detail INTO current_approver_, current_approver_group_;
   CLOSE get_approver_detail;
   
   IF (current_approver_ IS NOT NULL) THEN
      IF (current_userid_ != current_approver_) THEN
         Error_SYS.Record_General(lu_name_, 'USERNOTALLOWEDREMOVE: User :P1 is not allowed to remove approval of Approver :P2.',current_userid_,current_approver_);
      END IF;
   END IF;

   IF (current_approver_group_ IS NOT NULL) THEN
      IF NOT Approver_Group_Detail_API.Exists(company_,current_approver_group_,current_userid_) THEN
         Error_SYS.Record_General(lu_name_, 'USERNOTMEMBEROFGRP: User :P1 is not a member of Approver Group :P2.', current_userid_, current_approver_group_);
      END IF;
   END IF;
   
   vou_rec_ := Voucher_API.Get(company_, accounting_year_, voucher_type_, voucher_no_);
   IF (vou_rec_.sequential_approval = 'TRUE') THEN
      current_sequence_ := Get_Sequence(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_);
      IF (current_sequence_ IS NOT NULL) THEN
         OPEN  check_next_sequence_exist;
         FETCH check_next_sequence_exist INTO next_sequence_exists_;
         IF (check_next_sequence_exist%FOUND) THEN
            CLOSE check_next_sequence_exist;
            Error_SYS.Record_General(lu_name_, 'CANCELNOTINSEQUENCE: Cancel Approval should be performed in sequential order.');
         END IF;
         CLOSE check_next_sequence_exist;
      END IF;
   END IF;
      
   attr_       := NULL;
   Client_SYS.Add_To_Attr('APPROVED_BY', current_userid_, attr_);
   Voucher_API.Cancel_Approve__(info_, company_, accounting_year_, voucher_type_, voucher_no_, attr_, 'DO');

   attr_       := NULL;
   oldrec_ := Lock_By_Keys___(company_, accounting_year_, voucher_type_, voucher_no_, voucher_approver_row_id_);
   newrec_ := oldrec_;
   newrec_.authorization_status := '';
   newrec_.approved_by          := NULL;
   newrec_.timestamp            := NULL;
   newrec_.error_text           := NULL;
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Remove_Approve__;

PROCEDURE Remove_All_Approvals__(
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN VARCHAR2 )
IS
BEGIN
   UPDATE Voucher_Candidate_Approver_Tab v
      SET v.approved_by          = NULL,
          v.timestamp            = NULL,
          v.authorization_status = NULL
    WHERE v.company              = company_
      AND v.accounting_year      = accounting_year_
      AND v.voucher_type         = voucher_type_
      AND v.voucher_no           = voucher_no_
      AND v.authorization_status = 'APPROVED';
END Remove_All_Approvals__;

FUNCTION Get_Approver_Count__(
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER) RETURN NUMBER
IS 
   count_ NUMBER;
   CURSOR get_count IS
     SELECT count(*)
       FROM voucher_candidate_approver_tab v
      WHERE v.company = company_
        AND v.accounting_year = accounting_year_
        AND v.voucher_type = voucher_type_
        AND v.voucher_no = voucher_no_
        AND v.authorization_status = 'APPROVED';
BEGIN
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
   RETURN NVL(count_,0);
END Get_Approver_Count__;

PROCEDURE Check_Approver_Reference__ (
   company_            IN VARCHAR2,
   approver_detail_id_ IN VARCHAR2,
   valid_from_         IN DATE)
IS
   count_              NUMBER;
   dummy_              NUMBER;
   prefix_             VARCHAR2(2);
   approver_group_     VARCHAR2(30);
   approver_           VARCHAR2(30);
   
   CURSOR check_exists IS
      SELECT 1
        FROM voucher_candidate_approver_tab v
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
         Error_SYS.Record_General(lu_name_, 'APPROVERUSED: Cannot delete Approver/Approver Group as it is connected to Voucher in the hold table.');
      END IF;
      CLOSE check_exists;
   END IF;
END Check_Approver_Reference__;

FUNCTION Get_Relavent_Rule_Per_User__ (
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   user_id_         IN VARCHAR2 ) RETURN NUMBER
IS
   voucher_approver_row_id_ NUMBER := NULL;
   
   CURSOR get_indivigual_approver_row_id IS
      SELECT v.voucher_approver_row_id
        FROM voucher_candidate_approver_tab v
       WHERE company           = company_
         AND v.accounting_year = accounting_year_
         AND v.voucher_type    = voucher_type_
         AND v.voucher_no      = voucher_no_
         AND NVL(v.authorization_status, ' ') != 'APPROVED'
         AND NVL(v.approver_id, ' ')           = user_id_;

   CURSOR get_group_approver_row_id IS
      SELECT v.voucher_approver_row_id
        FROM voucher_candidate_approver_tab v, 
             approver_group_detail_tab g
       WHERE g.company           = v.company
         AND g.approver_group_id = v.approver_group_id
         AND v.company           = company_
         AND v.accounting_year   = accounting_year_
         AND v.voucher_type      = voucher_type_
         AND v.voucher_no        = voucher_no_
         AND NVL(v.authorization_status, ' ') != 'APPROVED'
         AND v.approver_group_id IS NOT NULL
         AND g.user_id           = user_id_;

BEGIN
   OPEN get_indivigual_approver_row_id;
   FETCH get_indivigual_approver_row_id INTO voucher_approver_row_id_;
   CLOSE get_indivigual_approver_row_id;
   
   IF (voucher_approver_row_id_ IS NULL) THEN
      OPEN get_group_approver_row_id;
      FETCH get_group_approver_row_id INTO voucher_approver_row_id_;
      CLOSE get_group_approver_row_id;
   END IF;
   
   RETURN voucher_approver_row_id_;
END Get_Relavent_Rule_Per_User__;

PROCEDURE Validate_Sequence__(
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER)
IS
   prev_sequence_    NUMBER := 0;
   CURSOR check_sequence IS
      SELECT sequence
        FROM voucher_candidate_approver_tab
       WHERE company          = company_
         AND accounting_year  = accounting_year_
         AND voucher_type     = voucher_type_
         AND voucher_no       = voucher_no_
       ORDER BY sequence;
BEGIN
   IF (Voucher_API.Get_Sequential_Approval_Db(company_, accounting_year_, voucher_type_, voucher_no_) = 'TRUE') THEN 
      FOR rec_ IN check_sequence LOOP
         IF (NVL(rec_.sequence,0) != prev_sequence_+1) THEN
            Error_SYS.Record_General(lu_name_,'SEQUENCEERROR: Sequence should be defined in a consecutive order starting from 1.');
         END IF;
         prev_sequence_ := prev_sequence_+1;
      END LOOP;
   END IF;
END Validate_Sequence__;

PROCEDURE Reorder_Sequence_Number__(
   company_             IN VARCHAR2,
   accounting_year_     IN NUMBER,
   voucher_type_        IN VARCHAR2,
   voucher_no_          IN NUMBER,
   sequencial_approval_ IN VARCHAR2)
IS
   newrec_        voucher_candidate_approver_tab%ROWTYPE;
   sequence_      NUMBER;
   
   CURSOR reoder_sequence_number_ IS
      SELECT *
        FROM voucher_candidate_approver_tab
         WHERE company        = company_
         AND accounting_year  = accounting_year_
         AND voucher_type     = voucher_type_
         AND voucher_no       = voucher_no_
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


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Is_User_Have_Approval_Rights (
   company_           IN VARCHAR2,
   approver_id_       IN VARCHAR2,
   approver_group_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   current_userid_       VARCHAR2(30);
BEGIN
   current_userid_ := Fnd_Session_API.Get_Fnd_User;

   IF (approver_id_ IS NOT NULL AND approver_group_id_ IS NULL) THEN
      IF (current_userid_ = approver_id_) THEN
         RETURN 'TRUE';
      END IF;
   END IF;
   IF (approver_group_id_ IS NOT NULL AND approver_id_ IS NULL) THEN
      IF (Approver_Group_Detail_API.Exists(company_,approver_group_id_,current_userid_)) THEN
         RETURN 'TRUE';
      END IF;
   END IF;
   RETURN 'FALSE';
END Is_User_Have_Approval_Rights;

-- Note: This method is used to control the handling of two check boxes. 
--       (Two Approvers Required and Sequential Approval) in Voucher Entry - Voucher Approval tab.
PROCEDURE Grant_Voucher_Approval_Change
IS
BEGIN
   RETURN;
END Grant_Voucher_Approval_Change;

-- Note: Remove all voucher_candidate_approver_tab rows for a given voucher.
PROCEDURE Remove_All_Voucher_Approvers(
   company_         IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER)
IS
BEGIN
   DELETE
   FROM Voucher_Candidate_Approver_Tab
   WHERE company        = company_
   AND accounting_year  = accounting_year_
   AND voucher_type     = voucher_type_
   AND voucher_no       = voucher_no_; 
END Remove_All_Voucher_Approvers;

-------------------- LU  NEW METHODS -------------------------------------

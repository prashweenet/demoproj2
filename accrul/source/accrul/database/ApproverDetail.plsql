-----------------------------------------------------------------------------
--
--  Logical unit: ApproverDetail
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
   oldrec_ IN     approver_detail_tab%ROWTYPE,
   newrec_ IN OUT approver_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.approver_id IS NOT NULL AND newrec_.approver_group_id IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_,'ONLYAPPROVERORGROUP: Either one Approver ID or one Approver Group can be specified. not both.');
   ELSIF (newrec_.approver_id IS NULL AND newrec_.approver_group_id IS NULL) THEN
      Error_SYS.Record_General(lu_name_,'MUSTAPPROVERORGROUP: An Approver ID or an Approver Group must be specified.');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT approver_detail_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   newrec_.approver_detail_id := Get_Id_From_Approver_Or_Grp___(newrec_.approver_id,newrec_.approver_group_id);
   super(newrec_, indrec_, attr_);
END Check_Insert___;

FUNCTION Get_Id_From_Approver_Or_Grp___ (
   approver_id_       IN VARCHAR2,
   approver_group_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   approver_detail_id_ VARCHAR2(32);
BEGIN
   IF (approver_id_ IS NOT NULL AND approver_group_id_ IS NULL) THEN
      approver_detail_id_ := '1_'||approver_id_;
   ELSIF (approver_id_ IS NULL AND approver_group_id_ IS NOT NULL) THEN
      approver_detail_id_ := '2_'||approver_group_id_;
   END IF;
   RETURN approver_detail_id_;
END Get_Id_From_Approver_Or_Grp___;

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN approver_detail_tab%ROWTYPE )
IS
BEGIN
   Error_SYS.Record_General(lu_name_,'APPROVERDETAILEXISTS: The Voucher Candidate Approver already exist.');
   super(rec_);
END Raise_Record_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

FUNCTION Get_Rowcount_For_Given_id__ (
   company_           IN VARCHAR2,
   approver_detail_id_ IN VARCHAR2) RETURN NUMBER
IS
   count_ NUMBER;
BEGIN
   SELECT Count(*) INTO count_
     FROM Approver_Detail_Tab a
    WHERE a.company            = company_
      AND a.approver_detail_id = approver_detail_id_;
   RETURN NVL(count_,0);
END Get_Rowcount_For_Given_id__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Check_Exist_For_Date (
   company_ IN VARCHAR2,
   approver_id_ IN VARCHAR2,
   approver_group_id_ IN VARCHAR2,
   date_ IN DATE )
IS
   dummy_ NUMBER;
   
   CURSOR check_exists IS
   SELECT 1
     FROM approver_detail_tab a
    WHERE a.company = company_
      AND NVL(a.approver_id,' ') = NVL(approver_id_,' ')
      AND NVL(a.approver_group_id,' ') = NVL(approver_group_id_,' ')
      AND a.valid_from <= date_;
 
BEGIN
   OPEN check_exists;
   FETCH check_exists INTO dummy_;
   IF check_exists%NOTFOUND THEN
      CLOSE check_exists;
      Error_SYS.Record_General(lu_name_, 'RECNOTEXISTSFORDATE: Approver/Approver Group details are not defined for the date :P1',date_);
   END IF;
   CLOSE check_exists;
END Check_Exist_For_Date;


FUNCTION Get_Amount (
   company_            IN VARCHAR2,
   approver_id_        IN VARCHAR2,
   approver_group_id_  IN VARCHAR2,
   valid_from_         IN DATE ) RETURN NUMBER
IS
   valid_from_date_    DATE;
   approver_detail_id_ VARCHAR2(32);
   
   CURSOR get_max_valid_date IS
      SELECT MAX(valid_from)
        FROM approver_detail_tab a
       WHERE a.company = company_
         AND a.approver_detail_id = approver_detail_id_
         AND a.valid_from <= valid_from_;
BEGIN
   approver_detail_id_ := Get_Id_From_Approver_Or_Grp___(approver_id_,approver_group_id_);

   OPEN get_max_valid_date;
   FETCH get_max_valid_date INTO valid_from_date_;
   CLOSE get_max_valid_date;
      
   RETURN Get_Amount(company_, approver_detail_id_, valid_from_date_);
END Get_Amount;


FUNCTION Get_Rec (
   company_           IN VARCHAR2,
   approver_id_       IN VARCHAR2,
   approver_group_id_ IN VARCHAR2,
   current_date_      IN DATE) RETURN public_rec
IS
   valid_from_date_ DATE;
   approver_detail_id_ VARCHAR2(32);
   
   CURSOR get_max_valid_date IS
      SELECT MAX(valid_from)
        FROM approver_detail_tab a
       WHERE a.company = company_
         AND a.approver_detail_id = approver_detail_id_
         AND a.valid_from <= current_date_;
BEGIN
   approver_detail_id_ := Get_Id_From_Approver_Or_Grp___(approver_id_,approver_group_id_);
   
   OPEN get_max_valid_date;
   FETCH get_max_valid_date INTO valid_from_date_;
   CLOSE get_max_valid_date;
   
   RETURN Get(company_, approver_detail_id_, valid_from_date_);
END Get_Rec;


-------------------- LU  NEW METHODS -------------------------------------

-----------------------------------------------------------------------------
--
--  Logical unit: UuidInformation
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200708  Smallk  gelr: Added to support Global Extension Functionalities.
--  200807  Smallk  GESPRING20-5304, Added Remove_Uuid_Info().
--  200811  Smallk  GESPRING20-5324, Added Is_Invalid_Uuid().
--  200821  Sacnlk  GESPRING20-5337, Added Validate_Cancelled_Uuids().
--  201112  Tkavlk  Fixed unchecked annotation error.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-- gelr:mx_xml_doc_reporting, begin
TYPE related_uuid_rec_type_ IS RECORD (
   uuid_number         VARCHAR2(36));

TYPE rec_related_uuid_type IS TABLE OF related_uuid_rec_type_ INDEX BY BINARY_INTEGER;
-- gelr:mx_xml_doc_reporting, end

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-- gelr:accounting_xml_data, begin
@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     uuid_information_tab%ROWTYPE,
   newrec_ IN OUT uuid_information_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (Validate_SYS.Is_Changed(UPPER(oldrec_.uuid_number), UPPER(newrec_.uuid_number))) THEN
      -- Check for invalid UUIDs
      IF (Is_Invalid_Uuid(newrec_.uuid_number)) THEN
         Error_SYS.Record_General(lu_name_, 'MXXMLINUIDF: UUID Number ":P1" is invalid.', newrec_.uuid_number);
      END IF;
      -- Check for duplicate UUIDs within the company
      IF (Is_Uuid_Duplicate___(newrec_.company, newrec_.uuid_number)) THEN
         Error_SYS.Record_General(lu_name_, 'MXDUPLUUID: The UUID Number already exists in Company :P1.', newrec_.company);
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


FUNCTION Is_Uuid_Duplicate___ (
   company_     IN VARCHAR2,
   uuid_number_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR get_count (company_       IN VARCHAR2,
                     uuid_number_   IN VARCHAR2) IS
      SELECT count(*)
      FROM Uuid_Information_Tab
      WHERE company = company_
      AND UPPER(uuid_number) = UPPER(uuid_number_);
   count_ NUMBER;
BEGIN
   OPEN get_count (company_, uuid_number_);
   FETCH get_count INTO count_;
   CLOSE get_count;
	RETURN (count_ > 0);
END Is_Uuid_Duplicate___;
-- gelr:accounting_xml_data, end


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- gelr:accounting_xml_data, begin
PROCEDURE New_Modify (
   new_rec_ IN OUT uuid_information_tab%ROWTYPE )
IS
   old_rec_ uuid_information_tab%ROWTYPE;
BEGIN
   IF (NOT Check_Exist___(new_rec_.company, new_rec_.source_ref1, new_rec_.source_ref2, new_rec_.source_ref3, new_rec_.source_ref_type)) THEN
      New___(new_rec_);
   ELSE
      old_rec_             := Get_Object_By_Keys___(new_rec_.company, new_rec_.source_ref1, new_rec_.source_ref2, new_rec_.source_ref3, new_rec_.source_ref_type);
      old_rec_.uuid_number := new_rec_.uuid_number;
      old_rec_.uuid_date   := new_rec_.uuid_date;
      new_rec_             := old_rec_;
      Modify___(new_rec_);
   END IF;
END New_Modify;


PROCEDURE Remove_Uuid_Info (
   rec_ IN uuid_information_tab%ROWTYPE )
IS
   remrec_   uuid_information_tab%ROWTYPE;
BEGIN
   remrec_ := rec_;
   IF (Check_Exist___(remrec_.company, remrec_.source_ref1, remrec_.source_ref2, remrec_.source_ref3, remrec_.source_ref_type)) THEN
      Delete___(remrec_);
   END IF;
END Remove_Uuid_Info;


FUNCTION Is_Invalid_Uuid (
   uuid_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
	IF (REGEXP_LIKE(uuid_, '^[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}$', 'i')) THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END Is_Invalid_Uuid;
-- gelr:accounting_xml_data, end

-- gelr:epayment_receipt, begin
PROCEDURE Validate_Cancelled_Uuids (
   company_                 IN VARCHAR2,
   related_pay_uuid_number_ IN VARCHAR2 ) 
IS    
   $IF Component_Payled_SYS.INSTALLED $THEN
      CURSOR get_count (company_       IN VARCHAR2,
                        uuid_number_   IN VARCHAR2) IS
      SELECT count(*)
      FROM   Uuid_Information
      WHERE  company = company_
      AND    source_ref_type_db  = Uuid_Source_Ref_Type_API.DB_PAYMENT_RECEIPT
      AND    source_ref1 IN (SELECT TO_CHAR(r.pay_receipt_id)
                              FROM payment_receipt r, payment p
                              WHERE r.company = company_
                              AND r.company = p.company
                              AND r.series_id = p.series_id
                              AND r.payment_id = p.payment_id
                              AND p.payment_rollback_status_db NOT IN ('NOTCANCELLED','NOTROLLEDBACK')
                              AND r.way_id IS NOT NULL)
      AND    UPPER(uuid_number) = UPPER(uuid_number_);
   $END
   count_ NUMBER;
BEGIN 
   $IF Component_Payled_SYS.INSTALLED $THEN
      IF (Finance_Lib_API.Fin_Length(related_pay_uuid_number_) IS NOT NULL) THEN
         FOR i IN
              (SELECT trim(regexp_substr(related_pay_uuid_number_, '[^;]+', 1, LEVEL)) l
              FROM dual
              CONNECT BY LEVEL <= regexp_count(related_pay_uuid_number_, ';') +1 )
         LOOP
            IF (Is_Invalid_Uuid(i.l)) THEN
               Error_SYS.Record_General(lu_name_, 'MXUUIDINVALID: Invalid Related Payment UUID Number :P1.', i.l);
            END IF;
            OPEN get_count (company_, i.l);
            FETCH get_count INTO count_;
            CLOSE get_count;
            IF (count_ = 0) THEN
               Error_SYS.Record_General(lu_name_, 'MXUUIDNOTEXIST: UUID Number ":P1" does not exist for any cancelled payment in company :P2.', i.l, company_);
            END IF;         
         END LOOP;     
      END IF;
   $ELSE
      NULL;
   $END
END Validate_Cancelled_Uuids;
-- gelr:epayment_receipt, end

-- gelr:mx_xml_doc_reporting, begin
@UncheckedAccess
PROCEDURE Get_Related_Uuid_Number (
   related_uuid_no_     OUT rec_related_uuid_type,
   uuid_count_          OUT NUMBER,
   company_             IN  VARCHAR2,
   invoice_id_          IN  NUMBER,
   series_reference_    IN  VARCHAR2,
   number_reference_    IN  VARCHAR2,   
   inv_creator_         IN  VARCHAR2,
   creators_reference_  IN  VARCHAR2 ) 
IS   
   debit_invoice_id_ NUMBER;    
   index_            NUMBER := 0;
   $IF Component_Invoic_SYS.INSTALLED $THEN
      CURSOR get_inst_adv_uuid IS 
      SELECT u.uuid_number
      FROM  advance_inv_reference_tab a, invoice_tab i, uuid_information_tab u
      WHERE a.company         = i.company
      AND   a.adv_inv_id      = i.invoice_id
      AND   i.company         = u.company
      AND   i.invoice_id      = u.source_ref1
      AND   u.source_ref2     = '*'
      AND   u.source_ref3     = '*'
      AND   u.source_ref_type = 'INVOICE'
      AND   a.company         = company_
      AND   a.invoice_id      = invoice_id_;
      
      CURSOR get_co_adv_uuid IS 
      SELECT u.uuid_number
      FROM  invoice_tab i, uuid_information_tab u
      WHERE i.company          = u.company
      AND   i.invoice_id       = u.source_ref1
      AND   u.source_ref2      = '*'
      AND   u.source_ref3      = '*'
      AND   u.source_ref_type  = 'INVOICE'
      AND   adv_inv            = 'TRUE'
      AND   creators_reference = creators_reference_
      AND   creators_reference IS NOT NULL
      AND   creator            IN ('CUSTOMER_ORDER_INV_HEAD_API')
      AND   rowstate           != 'Cancelled';
   $END
BEGIN
	$IF Component_Invoic_SYS.INSTALLED $THEN
      debit_invoice_id_ := Invoice_API.Get_Ref_Inv_Id(company_, series_reference_, number_reference_);
      IF (debit_invoice_id_ IS NOT NULL) THEN
         related_uuid_no_(index_).uuid_number := Get_Uuid_Number(company_, TO_CHAR(debit_invoice_id_), '*', '*', Uuid_Source_Ref_Type_API.Get_Client_Value(0));
         index_ := index_ + 1;
      END IF;
      IF (inv_creator_ = 'INSTANT_INVOICE_API') THEN 
         FOR uuid_rec_ IN get_inst_adv_uuid LOOP 
            related_uuid_no_(index_).uuid_number := uuid_rec_.uuid_number;
            index_ := index_ + 1;
         END LOOP;
      ELSIF (inv_creator_ = 'CUSTOMER_ORDER_INV_HEAD_API' AND Invoice_API.Get_Adv_Inv(company_, invoice_id_) = 'FALSE') THEN
         FOR uuid_rec_ IN get_co_adv_uuid LOOP 
            related_uuid_no_(index_).uuid_number := uuid_rec_.uuid_number;
            index_ := index_ + 1;
         END LOOP;
      END IF;      
      uuid_count_ := index_;
   $ELSE
      NULL;
   $END   
END Get_Related_Uuid_Number;

FUNCTION Get_Related_Uuid_Number (
   company_             IN  VARCHAR2,
   invoice_id_          IN  NUMBER,
   series_reference_    IN  VARCHAR2,
   number_reference_    IN  VARCHAR2,   
   inv_creator_         IN  VARCHAR2,
   creators_reference_  IN  VARCHAR2 ) RETURN VARCHAR2     
IS
   related_uuid_no_rec_  rec_related_uuid_type;
   related_uuid_no_      VARCHAR2(32000);
   uuid_count_           NUMBER := 0;   
BEGIN
   Get_Related_Uuid_Number(related_uuid_no_rec_, 
                           uuid_count_, 
                           company_,
                           invoice_id_, 
                           series_reference_, 
                           number_reference_ , 
                           inv_creator_, 
                           creators_reference_);                        
   FOR index_ IN 0..uuid_count_-1 LOOP
      IF related_uuid_no_ IS NOT NULL THEN 
         related_uuid_no_ := related_uuid_no_ ||';'|| related_uuid_no_rec_(index_).uuid_number;
      ELSE 
         related_uuid_no_ := related_uuid_no_rec_(index_).uuid_number;
      END IF;
   END LOOP;
   RETURN related_uuid_no_;
END Get_Related_Uuid_Number;
-- gelr:mx_xml_doc_reporting, end
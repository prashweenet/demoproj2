-----------------------------------------------------------------------------
--
--  Logical unit: FinanceDocReg
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  040602  PPerse  Created
--  131101  PRatlk  PBFI-2034 , Refactored according to the new template
--  160505  PKurlk  STRFI-1407, Logic to update key references for LUs in Finance_Doc_Reg_Tab.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Basic_Data (
   lu_  IN VARCHAR2,
	key_ IN VARCHAR2 DEFAULT NULL)
IS
   key_ref_   VARCHAR2(2000);
BEGIN
	IF (key_ IS NULL) THEN
		Client_SYS.Get_Key_Reference(key_ref_ ,lu_ );
		IF (NOT Check_Exist___(lu_)) THEN
			INSERT INTO FINANCE_DOC_REG_TAB (
				lu,
				key_ref,
				rowversion)
			VALUES (
				lu_,
				key_ref_,
				SYSDATE);
		ELSE
			UPDATE FINANCE_DOC_REG_TAB
				SET key_ref = key_ref_
			WHERE  lu = lu_;
		END IF;
	ELSE
		IF (NOT Check_Exist___(lu_)) THEN
			INSERT INTO FINANCE_DOC_REG_TAB (
				lu,
				key_ref,
				rowversion)
			VALUES (
				lu_,
				key_,
				SYSDATE);
		ELSE
			UPDATE FINANCE_DOC_REG_TAB
				SET key_ref = key_
			WHERE  lu = lu_;
		END IF;
	END IF;
END Insert_Basic_Data;

PROCEDURE Refresh_Key_Ref_Data (
   lu_   IN VARCHAR2 DEFAULT NULL)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   ori_key_ref_     VARCHAR2(2000);
   
   CURSOR get_doc_reg IS
      SELECT lu, key_ref
      FROM   FINANCE_DOC_REG_TAB;
      
   CURSOR get_key_ref (lu_ IN VARCHAR2) IS
      SELECT key_ref
      FROM   FINANCE_DOC_REG_TAB
      WHERE  lu = lu_;
BEGIN
   IF (lu_ IS NULL) THEN
      FOR rec_ IN get_doc_reg LOOP
         Update_Key_Ref_Data(rec_.lu, rec_.key_ref);
      END LOOP;
   ELSE
      OPEN  get_key_ref (lu_);
      FETCH get_key_ref INTO ori_key_ref_; 
      CLOSE get_key_ref;
      
      Update_Key_Ref_Data(lu_, ori_key_ref_);
   END IF;
   @ApproveTransactionStatement(2016-05-05,pkurlk)
   COMMIT;
END Refresh_Key_Ref_Data;

PROCEDURE Update_Key_Ref_Data (
   lu_            IN VARCHAR2,
   ori_key_ref_   IN VARCHAR2)
IS
   key_ref_     VARCHAR2(2000);
BEGIN
   Client_SYS.Get_Key_Reference(key_ref_, lu_);
   
   IF (key_ref_ IS NOT NULL AND key_ref_ != ori_key_ref_) THEN
      UPDATE FINANCE_DOC_REG_TAB
         SET key_ref = key_ref_
       WHERE lu = lu_;
   END IF;
END Update_Key_Ref_Data;

PROCEDURE Post_Installation_Data
IS
BEGIN
   -- Refresh key references for LUs in Finance_Doc_Reg_Tab.
   IF (Module_API.Is_Included_In_Delivery('ACCRUL')) THEN
      Refresh_Key_Ref_Data();
   END IF;
END Post_Installation_Data;
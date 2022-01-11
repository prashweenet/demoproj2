-----------------------------------------------------------------------------
--
--  Logical unit: TransferredVoucherRow
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  050915  Chajlk LCS Merge(33986).
--  090922  Mawelk Bug 84647 Fixed
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT transferred_voucher_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_              VARCHAR2(30);
   value_             VARCHAR2(4000);
  
BEGIN
  
   super(newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_B', newrec_.code_b);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_C', newrec_.code_c);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_D', newrec_.code_c);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_E', newrec_.code_e);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_F', newrec_.code_f);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_G', newrec_.code_g);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_H', newrec_.code_h);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_I', newrec_.code_i);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_J', newrec_.code_j);
   
   IF (newrec_.voucher_date IS NULL) THEN
      newrec_.voucher_date := Transferred_Voucher_Api.Get_Voucher_Date(newrec_.company,
                                               newrec_.accounting_year,
                                               newrec_.voucher_type,
                                               newrec_.voucher_no);
     
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     transferred_voucher_row_tab%ROWTYPE,
   newrec_ IN OUT transferred_voucher_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_B', newrec_.code_b);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_C', newrec_.code_c);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_D', newrec_.code_d);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_E', newrec_.code_e);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_F', newrec_.code_f);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_G', newrec_.code_g);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_H', newrec_.code_h);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_I', newrec_.code_i);
   Error_SYS.Check_Not_Null(lu_name_, 'CODE_J', newrec_.code_j);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


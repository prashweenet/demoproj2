-----------------------------------------------------------------------------
--
--  Logical unit: AuditBasicDataMaster
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  180830  NWeelk  Bug 143129, Removed default value for TAX_ACCOUNTING_BASIS  
--  200617  Chwtlk  Bug 154389, Corrected.  
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('AUDIT_FILE_VERSION' , value_ => '1.0', attr_ => attr_);
   Client_SYS.Add_To_Attr('SOFTWARE_VERSION' , value_ => 'IFS Cloud', attr_ => attr_);
   Client_SYS.Add_To_Attr('SOFTWARE_COMPANY_NAME' , value_ => 'Industrial and Financial Systems', attr_ => attr_);
   Client_SYS.Add_To_Attr('SOFTWARE_I_D' , value_ => 'IFS Cloud', attr_ => attr_);
   Client_SYS.Add_To_Attr('REPORTING_CURRENCY' , Audit_Reporting_Currency_API.Decode('ACCOUNTINGCURRENCY'), attr_ => attr_);   
END Prepare_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     audit_basic_data_master_tab%ROWTYPE,
   newrec_ IN OUT audit_basic_data_master_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (LENGTH(newrec_.software_version) > 18 AND indrec_.software_version) THEN
      Error_SYS.Record_General(lu_name_, 'SOFTWAREVERSINLENGTH: The field Software Version should not exceed the maximum character count of 18.');
   END IF;
END Check_Common___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


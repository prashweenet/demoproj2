-----------------------------------------------------------------------------
--
--  Logical unit: AdcomInstallation
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------
identity_                   CONSTANT VARCHAR2(30) := 'MAINTENIX';
description_                CONSTANT VARCHAR2(50) := 'Maintenix Service User';
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Post_Installation_Data 
IS
   info_  VARCHAR2(2000);
   objid_ VARCHAR2(2000);
   objv_  VARCHAR2(2000);
   attr_  VARCHAR2(2000);
BEGIN   
     IF NOT Fnd_User_API.Exists(identity_) THEN
      Client_SYS.Add_To_Attr('IDENTITY', identity_, attr_);
      Client_SYS.Add_To_Attr('DESCRIPTION', description_ , attr_);
      Client_SYS.Add_To_Attr('USER_TYPE_DB', Fnd_User_Type_API.DB_SERVICE_USER, attr_);
      Client_SYS.Add_To_Attr('ORACLE_USER', identity_, attr_);
      Client_SYS.Add_To_Attr('WEB_USER', identity_, attr_);
      Client_SYS.Add_To_Attr('EXPIRE_PASSWORD', 'FALSE', attr_);
      Client_SYS.Add_To_Attr('ACTIVE', 'TRUE', attr_);
      Fnd_User_API.New__(info_, objid_, objv_, attr_, 'DO');
   END IF;
END Post_Installation_Data;
-------------------- LU  NEW METHODS -------------------------------------

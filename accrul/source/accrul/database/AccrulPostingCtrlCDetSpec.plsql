-----------------------------------------------------------------------------
--
--  Logical unit: AccrulPostingCtrlCDetSpec
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  050816  reanpl   Created
--  090605  THPELK   Bug 82609 - Removed the aditional UNDEFINE statement for VIEW
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS 
BEGIN
   Posting_Ctrl_Crecomp_API.Make_Company_Comb_Det_Spec_Gen( 'ACCRUL', lu_name_, 'ACCRUL_POST_CTRL_CDET_SPEC_API', attr_ );
END Make_Company;   



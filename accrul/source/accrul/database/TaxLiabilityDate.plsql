-----------------------------------------------------------------------------
--
--  Logical unit: TaxLiabilityDate
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  141128  TAORSE  Added Enumerate1_Db, Enumerate2_Db, Enumerate3_Db and Enumerate4_Db
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-------------------- PACKAGES FOR METHOD
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
PROCEDURE Enumerate1 (
   client_values_ OUT VARCHAR2 )
IS
   translated_value_list_ VARCHAR2(1000);
BEGIN
   translated_value_list_  := Get_Client_Value (0)||'^'||
                              Get_Client_Value (1)||'^'||
                              Get_Client_Value (2)||'^';
   client_values_          := Domain_SYS.Enumerate_(translated_value_list_);
END Enumerate1;

PROCEDURE Enumerate1_Db (
   db_values_ OUT VARCHAR2 )
IS
   db_value_list_ VARCHAR2(1000);
BEGIN
   db_value_list_ := Get_Db_Value (0)||'^'||
                     Get_Db_Value (1)||'^'||   
                     Get_Db_Value (2)||'^';
   db_values_     := Domain_SYS.Enumerate_(db_value_list_);
END Enumerate1_Db;
                     
@UncheckedAccess
PROCEDURE Enumerate2 (
   client_values_ OUT VARCHAR2 )
IS
   translated_value_list_ VARCHAR2(1000);
BEGIN
   translated_value_list_  := Get_Client_Value (0)||'^'||
                              Get_Client_Value (4)||'^';
   client_values_          := Domain_SYS.Enumerate_(translated_value_list_);
END Enumerate2;

PROCEDURE Enumerate2_Db (
   db_values_ OUT VARCHAR2 )
IS
   db_value_list_ VARCHAR2(1000);
BEGIN
   db_value_list_  := Get_Db_Value (0)||'^'||
                      Get_Db_Value (4)||'^';
   db_values_      := Domain_SYS.Enumerate_(db_value_list_);
END Enumerate2_Db;

@UncheckedAccess
PROCEDURE Enumerate3 (
   client_values_ OUT VARCHAR2 )
IS
   translated_value_list_ VARCHAR2(1000);
BEGIN
   translated_value_list_  := Get_Client_Value (0)||'^'||
                              Get_Client_Value (1)||'^'||
                              Get_Client_Value (2)||'^'||
                              Get_Client_Value (3)||'^'||
                              Get_Client_Value (7)||'^';
   client_values_ := Domain_SYS.Enumerate_(translated_value_list_);
END Enumerate3;

PROCEDURE Enumerate3_Db (
   db_values_ OUT VARCHAR2)
IS
   db_value_list_ VARCHAR2(1000);
BEGIN
   db_value_list_          := Get_Db_Value (0)||'^'||
                              Get_Db_Value (1)||'^'||
                              Get_Db_Value (2)||'^'||
                              Get_Db_Value (3)||'^'||
                              Get_Db_Value (7)||'^';
   db_values_              := Domain_SYS.Enumerate_(db_value_list_);
END Enumerate3_Db;                           

@UncheckedAccess
PROCEDURE Enumerate4 (
   client_values_ OUT VARCHAR2 )
IS
   translated_value_list_ VARCHAR2(1000);
BEGIN
   translated_value_list_ := Get_Client_Value (0)||'^'||
                             Get_Client_Value (1)||'^'||
                             Get_Client_Value (2)||'^'||
                             Get_Client_Value (5)||'^'||
                             Get_Client_Value (6)||'^';
   client_values_ := Domain_SYS.Enumerate_(translated_value_list_);
END Enumerate4;

PROCEDURE Enumerate4_Db (
   db_values_ OUT VARCHAR2)
IS
   db_value_list_ VARCHAR2(1000);
BEGIN
   db_value_list_         := Get_Db_Value (0)||'^'||
                             Get_Db_Value (1)||'^'||
                             Get_Db_Value (2)||'^'||
                             Get_Db_Value (5)||'^'||
                             Get_Db_Value (6)||'^';
   db_values_             := Domain_SYS.Enumerate_(db_value_list_);
END Enumerate4_Db;
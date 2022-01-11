-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileFunction
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  080925  Jeguse Bug 77126 Corrected
--  131107  PRatlk PBFI-897, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Check_Exist (
   function_id_ IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN (Check_Exist___(function_id_));
END Check_Exist;


@UncheckedAccess
FUNCTION Check_Valid (
   function_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(function_id_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Valid;


@UncheckedAccess
FUNCTION Get_Min_Num_Of_Args (
   function_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_           NUMBER;
   CURSOR get_attr IS
      SELECT min_num_of_args
      FROM   EXT_FILE_FUNCTION_TAB
      WHERE  function_id = function_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   IF (get_attr%NOTFOUND) THEN
      temp_ := 0;
   END IF;
   CLOSE get_attr;
   RETURN temp_;
END Get_Min_Num_Of_Args;


@UncheckedAccess
FUNCTION Get_Max_Num_Of_Args (
   function_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   temp_           NUMBER;
   CURSOR get_attr IS
      SELECT max_num_of_args
      FROM   EXT_FILE_FUNCTION_TAB
      WHERE  function_id = function_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   IF (get_attr%NOTFOUND) THEN
      temp_ := 0;
   END IF;
   CLOSE get_attr;
   RETURN temp_;
END Get_Max_Num_Of_Args;




-----------------------------------------------------------------------------
--
--  Logical unit: AuditStorage
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  120829  JuKoDE  EDEL-1532, Added General_SYS.Init_Method in Insert_Data(
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Data (
   objid_      OUT VARCHAR2,
   view_       IN VARCHAR2,
   xml_data_   IN CLOB,
   data_       IN CLOB )
IS
   id_         NUMBER;
BEGIN
   SELECT Audit_Storage_Seq.NEXTVAL INTO id_ FROM DUAL;
   INSERT
      INTO audit_storage_tab (
         storage_id,
         audit_source,
         creation_date,
         creator,
         xml_data,
         data,
         rowversion)
      VALUES (
         id_,
         view_,
         SYSDATE,
         Fnd_Session_API.Get_Fnd_User(),
         xml_data_,
         data_,
         SYSDATE)
      RETURNING ROWID INTO objid_;
END Insert_Data;

PROCEDURE Cleanup_Audit_Storage(
   message_    IN VARCHAR2 ) 
IS
   name_arr_            Message_SYS.name_table;
   value_arr_           Message_SYS.line_table;
   days_checked_        VARCHAR2(5);
   count_               NUMBER;
   number_of_days_      NUMBER;
   before_date_         DATE;
   
BEGIN
   Message_SYS.Get_Attributes(message_, count_, name_arr_, value_arr_);
   
   FOR n_ IN 1..count_ LOOP
      IF (name_arr_(n_) = 'DAYS_CHECKED') THEN
         days_checked_ := value_arr_(n_);
      ELSIF (name_arr_(n_) = 'NUMBER_OF_DAYS') THEN
         number_of_days_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
      ELSIF (name_arr_(n_) = 'BEFORE_DATE') THEN
         before_date_ := Client_SYS.Attr_Value_To_Date(value_arr_(n_));
      ELSE
         Error_SYS.Record_General(lu_name_, 'INCORRECT_MESSAGE: Item :P1 can not be used in this method.', name_arr_(n_));
      END IF;
   END LOOP;
   
   IF (number_of_days_ IS NOT NULL AND number_of_days_ > 0) THEN
      before_date_ := TRUNC(SYSDATE) - number_of_days_;
   END IF;
   
   IF before_date_ IS NOT NULL THEN
      DELETE
      FROM  Audit_Storage_Tab
      WHERE creation_date < before_date_;
   END IF;
END Cleanup_Audit_Storage;

PROCEDURE Validate_Cleanup_Params (
   message_ IN VARCHAR2 )
IS 
   name_arr_               Message_SYS.name_table;
   value_arr_              Message_SYS.line_table;
   days_checked_           VARCHAR2(5);
   number_of_days_         NUMBER;
   count_                  NUMBER;
   before_date_            DATE;
BEGIN
   
   Message_SYS.Get_Attributes(message_, count_, name_arr_, value_arr_);
   FOR n_ IN 1..count_ LOOP
      IF (name_arr_(n_) = 'DAYS_CHECKED') THEN
         days_checked_ := UPPER(value_arr_(n_));
      ELSIF (name_arr_(n_) = 'NUMBER_OF_DAYS') THEN
         number_of_days_ := Client_SYS.Attr_Value_To_Number(value_arr_(n_));
         IF (days_checked_ = 'TRUE') THEN
            IF (number_of_days_ IS NULL) THEN
               Error_SYS.Item_General(lu_name_, 'NUMBER_OF_DAYS', 'NUMBEROFDAYSNULLVALUE: Field [Days Before Current Date] is mandatory and requires a value.');
            END IF;
            IF (number_of_days_ <= 0) THEN
               Error_SYS.Item_General(lu_name_, 'NUMBER_OF_DAYS', 'NODAYSNEGORZERO: Days Before Current Date must be bigger than zero.');
            END IF;
         END IF;
      ELSIF (name_arr_(n_) = 'BEFORE_DATE') THEN
         before_date_ := Client_SYS.Attr_Value_To_Date(value_arr_(n_));
         IF (days_checked_ = 'FALSE') THEN
            IF (before_date_ IS NULL) THEN
               Error_SYS.Item_General(lu_name_, 'BEFORE_DATE', 'BEFOREDATENULLVALUE: Field [Created Before] is mandatory and requires a value.');
            END IF;
            IF (before_date_ > TRUNC(SYSDATE)) THEN
               Error_SYS.Item_General(lu_name_, 'BEFORE_DATE', 'DATEBEFOREFUTURE: Created Before date must not be in the future.');
            END IF;
         END IF;
      ELSE
         Error_SYS.Record_General(lu_name_, 'INCORRECT_MESSAGE: Item :P1 can not be used in this method.');
      END IF;
   END LOOP;
END Validate_Cleanup_Params;
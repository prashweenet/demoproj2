-----------------------------------------------------------------------------
--
--  Logical unit: AccrulAttribute
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  030929 rakolk Added new method Set_Attribute_Value.
--  131022 Pratlk CAHOOK-2820, Refactering using new template
--  140724  THPELK PRFI-264 - LCS Merge(Bug 105417).
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@UncheckedAccess
FUNCTION Check_Temp_Table___ RETURN BOOLEAN
IS
   dummy_ NUMBER;
   -- should not have records in temp table.
   -- asume no reocrds means no update routine is running at this point. truncate is done at the end of Do_Update__
   -- if there is a forecast run and records are commited there will be a issue
   $IF ( Component_Genled_SYS.INSTALLED) $THEN
      CURSOR exists_records IS
         SELECT 1
         FROM   VOUCHER_UPDATE_TMP t;
   $END      
BEGIN
   $IF (Component_Genled_SYS.INSTALLED) $THEN
      OPEN exists_records;
      FETCH exists_records INTO dummy_;
      IF (exists_records%FOUND) THEN
         CLOSE exists_records;
         RETURN(TRUE);
      END IF;
      CLOSE exists_records;
      RETURN(FALSE);
   $ELSE
      RETURN(TRUE);
   $END   
END Check_Temp_Table___;

@UncheckedAccess
FUNCTION Check_Exist_Jobs___ (
   queue_id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exists_jobs IS
      SELECT 1
      FROM   transaction_sys_local_tab t
      WHERE  state IN ('Posted', 'Executing')
      AND    UPPER(procedure_name) IN ( 'GEN_LED_VOUCHER_UPDATE_API.START_UPDATE__', 'GEN_LED_VOUCHER_UPDATE_API.START_UPDATE_BATCH__', 'STEP_API.UPDATE_GL')
      AND    queue_id = queue_id_;
     
BEGIN
   OPEN exists_jobs;
   FETCH exists_jobs INTO dummy_;
   IF (exists_jobs%FOUND) THEN
      CLOSE exists_jobs;
      RETURN(TRUE);
   END IF;
   CLOSE exists_jobs;
   RETURN(FALSE);
END Check_Exist_Jobs___;
   

@Override
PROCEDURE Check_Update___ (
oldrec_ IN     accrul_attribute_tab%ROWTYPE,
newrec_ IN OUT accrul_attribute_tab%ROWTYPE,
indrec_ IN OUT Indicator_Rec,
attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   IF  ( indrec_.attribute_value AND newrec_.attribute_name = 'GL_UPDATE_BATCH_QUEUE_ID') THEN
      Error_SYS.Item_Update(lu_name_, 'ATTRIBUTE_VALUE');
   ELSIF  ( indrec_.attribute_value AND newrec_.attribute_name = 'GL_UPDATE_BATCH_QUEUE') THEN
      newrec_.attribute_value := UPPER(newrec_.attribute_value);
   END IF;
   
   IF  ( newrec_.attribute_name = 'GL_UPDATE_BATCH_QUEUE') THEN
      IF ( Check_Temp_Table___) THEN
         Error_SYS.Appl_General(lu_name_, 'PROCALREADYRNUNNING: Cannot change the parameter value while General Ledger update process is executed.');
      END IF;
      
      IF ( Check_Exist_Jobs___( TO_NUMBER(Get_Attribute_Value('GL_UPDATE_BATCH_QUEUE_ID')) )) THEN
         Error_SYS.Appl_General(lu_name_, 'PROCALREADYRNUNNING2: Cannot change the parameter value as General Ledger update procedure(s) are queued in the specified General Ledger update queue.');   
      END IF;

      IF (newrec_.attribute_value NOT IN ('TRUE', 'FALSE'))  THEN
         Error_SYS.Appl_General(lu_name_, 'ATTRVALERR: Parameter Value for the GL_UPDATE_BATCH_QUEUE can be either ''TRUE'' or ''FALSE''.');   
      END IF;
   END IF;
   
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Update___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Exist (
   attribute_name_ IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   RETURN Check_Exist___ (attribute_name_);
END Check_Exist;


PROCEDURE Set_Attribute_Value (
   attribute_name_ IN VARCHAR2,
   attribute_value_ IN VARCHAR2 )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   attr_       VARCHAR2(2000);
   oldrec_     ACCRUL_ATTRIBUTE_TAB%ROWTYPE;
   newrec_     ACCRUL_ATTRIBUTE_TAB%ROWTYPE;
BEGIN
   IF Check_Exist___(attribute_name_) THEN
      oldrec_ := Lock_By_Keys___(attribute_name_);
      newrec_ := oldrec_;
      newrec_.attribute_value := attribute_value_;
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   ELSE
      newrec_.attribute_name  := attribute_name_;
      newrec_.attribute_value := attribute_value_;
      Insert___(objid_, objversion_, newrec_, attr_);
   END IF;
END Set_Attribute_Value;




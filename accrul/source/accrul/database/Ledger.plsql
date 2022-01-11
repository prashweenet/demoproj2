-----------------------------------------------------------------------------
--
--  Logical unit: Ledger
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  111124  Umdolk  SFI-910, Added pragma to Get_Ledger_Snapshot method.
--  130708  Umdolk  DANU-1602, Added Enumerate_Ledgers method to get General ledger and Internal ledger in the list.
--  141125  TAORSE  Added Enumerate_Ledger_Db and Enumerate_Snapshot_Db
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
FUNCTION Get_Ledger (
   ledger_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   ledger_      VARCHAR2(2);
BEGIN
   IF NOT ledger_id_ IN (DB_GL_AFFECT_IL, DB_GENERAL_LEDGER, DB_CONS_SNAPSHOT) THEN
      ledger_ := DB_INTERNAL_LEDGER;
   ELSE
      ledger_ := ledger_id_;
   END IF;
   RETURN Ledger_API.Decode(ledger_);
END Get_Ledger;

@UncheckedAccess
FUNCTION Get_Ledger_Db (
   ledger_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   ledger_      VARCHAR2(2);
BEGIN
   IF NOT ledger_id_ IN (DB_GL_AFFECT_IL, DB_GENERAL_LEDGER, DB_CONS_SNAPSHOT) THEN
      ledger_ := DB_INTERNAL_LEDGER;
   ELSE
      ledger_ := ledger_id_;
   END IF;
   RETURN ledger_;
END Get_Ledger_Db;


@UncheckedAccess
FUNCTION Get_Ledger_Snapshot (
   ledger_id_snapshot_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   ledger_snapshot_      VARCHAR2(2);
BEGIN
   IF NOT ledger_id_snapshot_ IN (DB_GL_AFFECT_IL, DB_GENERAL_LEDGER, DB_CONS_SNAPSHOT, DB_IL_CONS_SNAPSHOT) THEN
      ledger_snapshot_ := DB_INTERNAL_LEDGER;
   ELSE
      ledger_snapshot_ := ledger_id_snapshot_;
   END IF;
      RETURN Ledger_API.Decode(ledger_snapshot_);
END Get_Ledger_Snapshot;



@UncheckedAccess
PROCEDURE Enumerate_Snapshot (
   client_values_snapshot_ OUT VARCHAR2 )
IS
BEGIN
   client_values_snapshot_ :=
   Domain_SYS.Enumerate_(Decode(DB_GL_AFFECT_IL)  ||'^' ||
                         Decode(DB_GENERAL_LEDGER) ||'^' ||
                         Decode(DB_INTERNAL_LEDGER) ||'^' ||
                         Decode(DB_CONS_SNAPSHOT) ||'^' ||
                         Decode(DB_IL_CONS_SNAPSHOT));
END Enumerate_Snapshot;

PROCEDURE Enumerate_Snapshot_Db (
   db_values_snapshot_ OUT VARCHAR2 )
IS
BEGIN
   db_values_snapshot_ := Domain_SYS.Enumerate_('DB_GL_AFFECT_IL^DB_GENERAL_LEDGER^DB_INTERNAL_LEDGER^
   DB_CONS_SNAPSHOT^DB_IL_CONS_SNAPSHOT^');
END Enumerate_Snapshot_Db;


PROCEDURE Enumerate_Ledger (
   client_values_ledgers_ OUT VARCHAR2 )
IS
BEGIN
   client_values_ledgers_ := Domain_SYS.Enumerate_(Decode(DB_GENERAL_LEDGER) ||'^' ||
                                                   Decode(DB_INTERNAL_LEDGER));
END Enumerate_Ledger;

PROCEDURE Enumerate_Ledger_Db (
   db_values_ledgers_ OUT VARCHAR2 )
IS
BEGIN
   db_values_ledgers_ := Domain_SYS.Enumerate_('DB_GENERAL_LEDGER^DB_INTERNAL_LEDGER^');
END Enumerate_Ledger_Db;


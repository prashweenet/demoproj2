-----------------------------------------------------------------------------
--
--  Logical unit: AvDocAttachMapper
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200930  chdslk  DISO2020R1-395, Added wrapper method to New___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New(
   newrec_ IN OUT NOCOPY av_doc_attach_mapper_tab%ROWTYPE)
IS
BEGIN
   New___(newrec_);
END New;

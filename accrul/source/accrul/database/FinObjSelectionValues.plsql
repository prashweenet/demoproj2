-----------------------------------------------------------------------------
--
--  Logical unit: FinObjSelectionValues
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  101027  SALIDE  RAVEN-1085, Created.
--  110729  Sacalk  FIDEAGLE-198, Fixed errors in Dictionary Tes
--  151007  chiblk  STRFI-200, New__ changed to New___ in Insert_Values
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     fin_obj_selection_values_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY fin_obj_selection_values_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
   selection_object_id_    VARCHAR2(100);
   CURSOR get_selection_object_id IS
      SELECT selection_object_id 
      FROM   fin_object_selection_tab
      WHERE  company         = newrec_.company
      AND    object_group_id = newrec_.object_group_id
      AND    object_id       = newrec_.object_id
      AND    selection_id    = newrec_.selection_id
      AND    item_id         = newrec_.item_id;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   OPEN  get_selection_object_id;
   FETCH get_selection_object_id INTO selection_object_id_;
   CLOSE get_selection_object_id;
   IF (selection_object_id_ = 'REMINDER_LEVEL') THEN
      Validate_Number___(newrec_.value);
   END IF;   
END Check_Common___;

PROCEDURE Validate_Number___(
   value_   IN VARCHAR2)
IS
   number_  NUMBER;
BEGIN
   number_ := TO_NUMBER(value_);
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDNO: Invalid Number.');
END Validate_Number___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Is_Value_Exist (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_      IN NUMBER,
   item_id_          IN NUMBER,
   value_            IN VARCHAR2 ) RETURN NUMBER
IS
   dummy_   NUMBER;
   CURSOR exist IS
      SELECT 1
        FROM FIN_OBJ_SELECTION_VALUES_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_
         AND item_id = item_id_
         AND value = value_;
BEGIN
   OPEN  exist;
   FETCH exist INTO dummy_;
   IF exist%NOTFOUND THEN
      CLOSE exist;
      RETURN 0;
   END IF;
   CLOSE exist;
   RETURN 1;
END Is_Value_Exist;


@UncheckedAccess
FUNCTION Is_Value_Exist (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_      IN NUMBER,
   item_id_          IN NUMBER ) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   CURSOR exist IS
      SELECT 1
        FROM FIN_OBJ_SELECTION_VALUES_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND object_id = object_id_
         AND selection_id = selection_id_
         AND item_id = item_id_;
BEGIN
   OPEN  exist;
   FETCH exist INTO dummy_;
   IF exist%NOTFOUND THEN
      CLOSE exist;
      RETURN 'FALSE';
   END IF;
   CLOSE exist;
   RETURN 'TRUE';
END Is_Value_Exist;


PROCEDURE Insert_Values (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_      IN NUMBER,
   item_id_          IN NUMBER,
   value_str_        IN VARCHAR2 )
IS
   rec_           fin_obj_selection_values_tab%ROWTYPE;
   value_         VARCHAR2(50);
   action_        NUMBER;
   n_             NUMBER;
   pos_           NUMBER;
BEGIN

   n_ := 1;
   pos_ := INSTR(value_str_, '^', n_);
   WHILE (pos_ > 0) LOOP
      value_  := substr(value_str_, n_, pos_ - n_);
      action_ := substr(value_, -1);
      value_  := substr(value_, 1, length(value_) - 1 );
      n_ := pos_ + 1;
      pos_ := INSTR(value_str_, '^', n_);
      IF ( action_ = 1 AND Is_Value_Exist( company_, object_group_id_, object_id_, selection_id_, item_id_, value_ ) != 1 ) THEN
         rec_.company         := company_;
         rec_.object_group_id := object_group_id_;
         rec_.object_id       := object_id_;
         rec_.selection_id    := selection_id_;
         rec_.item_id         :=  item_id_;
         rec_.value           := value_;
         
         New___(rec_);
      ELSIF (action_=0) THEN
         rec_ := Lock_By_Keys___ (company_, object_group_id_, object_id_, selection_id_, item_id_, value_);
         DELETE FROM fin_obj_selection_values_tab
         WHERE  company = company_
         AND    object_group_id = object_group_id_
         AND    object_id = object_id_
         AND    selection_id = selection_id_
         AND    item_id = item_id_
         AND    value = value_;
      END IF;
   END LOOP;
END Insert_Values;


PROCEDURE Copy_Selection_Templ_Values (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   object_id_        IN VARCHAR2,
   selection_id_     IN NUMBER,
   template_id_      IN VARCHAR2 )
IS
BEGIN
   INSERT 
      INTO fin_obj_selection_values_tab (
         company,
         object_group_id,
         object_id,
         selection_id,
         item_id,
         value,
         rowversion)
      SELECT 
         company,
         object_group_id,
         object_id_,
         selection_id_,
         item_id,
         value,
         SYSDATE
      FROM fin_sel_templ_values_tab
      WHERE company = company_
        AND object_group_id = object_group_id_
        AND template_id = template_id_;
END Copy_Selection_Templ_Values;



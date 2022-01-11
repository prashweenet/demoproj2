/*
 *  Template:     3.0
 *  Built by:     IFS Developer Studio
 *
 *
 *
 * ---------------------------------------------------------------------------
 *
 *  Logical unit: ExternalFileHandling
 *  Type:         Projection
 *  Component:    ACCRUL
 *
 * ---------------------------------------------------------------------------
 */

package com.ifsworld.projection;

import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Map;

/*
 * Implementation class for all global actions defined in the ExternalFileHandling projection model.
 */

@Stateless(name="ExternalFileHandlingActions")
@TransactionAttribute(value = TransactionAttributeType.REQUIRED)
public class ExternalFileHandlingActionsImpl implements ExternalFileHandlingActions {

   @Override
   public Map<String, Object> dummyAction(final Map<String, Object> parameters, final Connection connection) {
      throw new UnsupportedOperationException("Not supported yet.");
   }
}
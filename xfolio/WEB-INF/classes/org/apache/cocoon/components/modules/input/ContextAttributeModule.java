
package org.apache.cocoon.components.modules.input;

import java.util.Iterator;
import java.util.Map;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.thread.ThreadSafe;
import org.apache.cocoon.environment.ObjectModelHelper;

/**
 * RequestParameterModule accesses request parameters. If the
 * parameter name contains an askerisk "*" this is considered a
 * wildcard and all parameters that would match this wildcard are
 * considered to be part of an array of that name for
 * getAttributeValues. Only one "*" is allowed. Wildcard matches take
 * precedence over real arrays. In that case only the first value of
 * such array is returned.
 *
 * @author <a href="mailto:haul@apache.org">Christian Haul</a>
 * @version CVS $Id: ContextAttributeModule.java,v 1.2 2004/06/09 08:49:52 frederic Exp $
 */
public class ContextAttributeModule extends AbstractInputModule implements ThreadSafe {

    public Object getAttribute( String name, Configuration modeConf, Map objectModel ) throws ConfigurationException {

        String pname = (String) this.settings.get("parameter", name);
        if ( modeConf != null ) {
            pname = modeConf.getAttribute( "parameter", pname );
            // preferred
            pname = modeConf.getChild("parameter").getValue(pname);
        }
        return ObjectModelHelper.getContext(objectModel).getAttribute( pname );
    }


    public Iterator getAttributeNames( Configuration modeConf, Map objectModel ) throws ConfigurationException {

        return new IteratorHelper(ObjectModelHelper.getContext(objectModel).getAttributeNames());
    }

    


    public Object[] getAttributeValues( String name, Configuration modeConf, Map objectModel )
        throws ConfigurationException {


        String wildcard = (String) this.settings.get("parameter", name);
        if ( modeConf != null ) {
            wildcard = modeConf.getAttribute( "parameter", wildcard );
            // preferred
            wildcard = modeConf.getChild("parameter").getValue(wildcard);
        }

        	Object[] out=new String[1];
        	out[0]=ObjectModelHelper.getContext(objectModel).getAttribute( wildcard );
            return out;
            
    }


}

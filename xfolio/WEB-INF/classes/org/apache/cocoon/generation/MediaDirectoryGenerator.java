/*
 * Created on 5 mars 2004
 * (c) strabon.org
 * GPL
 * frederic.glorieux@ajlsm.com
 */
package org.apache.cocoon.generation;

import java.io.File;

import java.util.Iterator;


import org.xml.sax.SAXException;

import com.drew.metadata.*;
import com.drew.imaging.jpeg.*;

/**
 * An extension of DirectoryGenerators that adds extra attributes for image
 * files.
 *
 * @author <a href="mailto:frederic.glorieux@ajlsm.com">Glorieux, Fr?d?ric</a>
 * @version CVS $Id: MediaDirectoryGenerator.java,v 1.1 2004/04/30 16:49:48 frederic Exp $
 */
final public class MediaDirectoryGenerator extends DirectoryGenerator {

	protected static String IMAGE_WIDTH_ATTR_NAME = "width";
	protected static String IMAGE_HEIGHT_ATTR_NAME = "height";
	protected static String IMAGE_COMMENT_ATTR_NAME = "comment";

	/**
	 * Extends the <code>setNodeAttributes</code> method from the
	 * <code>DirectoryGenerator</code> 
	 * by adding metadata properties from 
	 * <a href="http://www.drewnoakes.com/code/exif/sampleUsage.html">drewnoakes.com</a>
	 */
	protected void setNodeAttributes(File path) throws SAXException {
		super.setNodeAttributes(path);
		if (path.isDirectory()) {
			return;
		}
		try {
			Metadata metadata = JpegMetadataReader.readMetadata(path);
			// iterate through metadata directories
		 	Iterator directories = metadata.getDirectoryIterator();
			while (directories.hasNext()) {
				Directory directory = (Directory)directories.next();
				// iterate through tags and print to System.out
				Iterator tags = directory.getTagIterator();
				while (tags.hasNext()) {
					Tag tag = (Tag)tags.next();
					String name=tag.getTagName().replace(' ', '.').replace('/', '-').replace('(', '-').replace(')', '-');
					String value=tag.getDescription();
					// use Tag.toString()
					if (name != null && value != null) attributes.addAttribute("", name, name, "CDATA", value);
				}
			}
		}
		catch (JpegProcessingException e) {
			// try MP3 here, it's not a Jpeg File
			// getLogger().info("JpegProcessingException for " + path, e);
		}
		catch (MetadataException e) {
			getLogger().info("MetadataException for " + path, e);
		}
		catch (Exception e) {
			// probably not a JPEG file
			getLogger().info("Exception for " + path, e);
		}
	}

}

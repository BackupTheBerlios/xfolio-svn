package org.apache.cocoon.generation;
import java.io.IOException;
import java.io.InputStream;
import java.io.InvalidObjectException;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.util.Map;
import java.util.Vector;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.service.ServiceException;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.components.source.SourceUtil;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.excalibur.source.Source;
import org.apache.excalibur.source.SourceException;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.xml.sax.SAXParser;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
/**
 * 
 * The <code>FileGenerator</code> is a class that reads XML from a source and
 * generates SAX Events. The FileGenerator implements the
 * <code>CacheableProcessingComponent</code> interface.
 * 
 * @author <a href="mailto:pier@apache.org">Pierpaolo Fumagalli </a> (Apache
 *         Software Foundation)
 * @author <a href="mailto:cziegeler@apache.org">Carsten Ziegeler </a>
 * @version CVS $Id: XMPjpgGenerator.java,v 1.1 2004/06/22 23:30:01 frederic Exp $
 */
public class XMPjpgGenerator extends ServiceableGenerator
		implements
			CacheableProcessingComponent {
	/** Jpeg markers */
	/* Start Of Frame N */
	public static final int M_SOF0 = 0xC0;
	/* N indicates which compression process */
	public static final int M_SOF1 = 0xC1;
	/* Only SOF0-SOF2 are now in common use */
	public static final int M_SOF2 = 0xC2;
	public static final int M_SOF3 = 0xC3;
	/* NB: codes C4 and CC are NOT SOF markers */
	public static final int M_SOF5 = 0xC5;
	public static final int M_SOF6 = 0xC6;
	public static final int M_SOF7 = 0xC7;
	public static final int M_SOF9 = 0xC9;
	public static final int M_SOF10 = 0xCA;
	public static final int M_SOF11 = 0xCB;
	public static final int M_SOF13 = 0xCD;
	public static final int M_SOF14 = 0xCE;
	public static final int M_SOF15 = 0xCF;
	/* Start Of Image (beginning of datastream) */
	public static final int M_SOI = 0xD8;
	/* End Of Image (end of datastream) */
	public static final int M_EOI = 0xD9;
	/* Start Of Scan (begins compressed data) */
	public static final int M_SOS = 0xDA;
	/* Application-specific marker, type N */
	public static final int M_APP0 = 0xE0;
	public static final int M_APP1 = 0xE1;
	public static final int M_APP2 = 0xE2;
	public static final int M_APP3 = 0xE3;
	public static final int M_APP4 = 0xE4;
	public static final int M_APP5 = 0xE5;
	public static final int M_APP6 = 0xE6;
	public static final int M_APP7 = 0xE7;
	public static final int M_APP8 = 0xE8;
	public static final int M_APP9 = 0xE9;
	public static final int M_APP10 = 0xEA;
	public static final int M_APP11 = 0xEB;
	public static final int M_APP12 = 0xEC;
	public static final int M_APP13 = 0xED;
	public static final int M_APP14 = 0xEE;
	public static final int M_APP15 = 0xEF;
	public static final int M_COM = 0xFE;
	/* fields */
    protected int compression = -1;
    protected int bitsPerPixel = -1;
    protected int height = -1;
    protected int width = -1;
    protected int numComponents = -1;

	/* The maximal comment length */
	public static final int M_MAX_COM_LENGTH = 65500;
	protected Vector vacom[] = new Vector[16];
	protected Vector vcom = null;
	protected String comments[] = null;
	protected byte appcomments[][] = null;
	/** The input source */
	protected Source inputSource;
	protected InputStream in;
	/**
	 * Convenience object, so we don't need to create an AttributesImpl for
	 * every element.
	 */
	protected AttributesImpl attributes = new AttributesImpl();
	/**
	 * Recycle this component. All instance variables are set to
	 * <code>null</code>.
	 */
	public void recycle() {
		if (null != this.inputSource) {
			super.resolver.release(this.inputSource);
			this.inputSource = null;
		}
		super.recycle();
	}
	/**
	 * Setup the file generator. Try to get the last modification date of the
	 * source for caching.
	 */
	public void setup(SourceResolver resolver, Map objectModel, String src,
			Parameters par) throws ProcessingException, SAXException,
			IOException {
		super.setup(resolver, objectModel, src, par);
		try {
			this.inputSource = super.resolver.resolveURI(src);
		} catch (SourceException se) {
			throw SourceUtil.handle("Error during resolving of '" + src + "'.",
					se);
		}
	}
	/**
	 * Generate the unique key. This key must be unique inside the space of this
	 * component.
	 * 
	 * @return The generated key hashes the src
	 */
	public java.io.Serializable getKey() {
		return this.inputSource.getURI();
	}
	/**
	 * Generate the validity object.
	 * 
	 * @return The generated validity object or <code>null</code> if the
	 *         component is currently not cacheable.
	 */
	public SourceValidity getValidity() {
		return this.inputSource.getValidity();
	}
	/**
	 * Generate XML data.
	 */
	public void generate() throws IOException, SAXException,
			ProcessingException {
		try {
			if (getLogger().isDebugEnabled()) {
				getLogger().debug(
						"Source " + super.source + " resolved to "
								+ this.inputSource.getURI());
			}
			/*
			 * from default file generator SourceUtil.parse(this.manager,
			 * this.inputSource, super.xmlConsumer);
			 */
			in=null;
			in = inputSource.getInputStream();
			scanHeaders();
			//SourceUtil.parse(this.manager, this.inputSource, super.xmlConsumer);
            // from org.apache.cocoon.components.source.SourceUtil;
			SAXParser parser = null;
            parser = (SAXParser) manager.lookup( SAXParser.ROLE);
            parser.parse( new InputSource ( new StringReader(this.getXMP())), this.contentHandler );

		}
		catch (ServiceException e) {
			throw new ProcessingException(e);
		}
		catch (SAXException e) {
			final Exception cause = e.getException();
			if (cause != null) {
				if (cause instanceof ProcessingException) {
					throw (ProcessingException) cause;
				}
				if (cause instanceof IOException) {
					throw (IOException) cause;
				}
				if (cause instanceof SAXException) {
					throw (SAXException) cause;
				}
				throw new ProcessingException("Could not read resource "
						+ this.inputSource.getURI(), cause);
			}
			throw e;
		} 
		finally {
			if (in != null) in.close();
			in=null;
		}
	}
	/**
	 * A get XMP in APP1
	 * 
	 * from
	 * http://dev.w3.org/cvsweb/~checkout~/java/classes/org/w3c/tools/jpeg/JpegHeaders.java?rev=1.16&content-type=text/plain
	 */
	public String getXMP() throws IOException, ProcessingException {
		String magicstr = "W5M0MpCehiHzreSzNTczkc9d";
		char magic[] = magicstr.toCharArray();
		String magicendstr = "<?xpacket";
		char magicend[] = magicendstr.toCharArray();
		char c;
		int length;
		int h = 0, i = 0, j = 0, k;
		char buf[] = new char[256];
		/* get the APP1 marker */
		String app1markers[] = getStringAPPComments(M_APP1);
		String app1marker = new String();
		boolean found = false;
		for (h = 0; h < app1markers.length; h++) {
			if (found == false && app1markers[h].indexOf(magicstr) != -1) {
				found = true;
				//		System.out.println("magic found");
				app1marker = app1marker.concat(app1markers[h]);
			} else if (found == true) {
				app1marker = app1marker.concat(app1markers[h]);
			}
		}
		StringReader app1reader = new StringReader(app1marker);
		StringBuffer sbuf = new StringBuffer();
		/* Get the marker parameter length count */
		length = read2bytes(app1reader);
		/* Length includes itself, so must be at least 2 */
		if (length < 2)
			throw new ProcessingException("Erroneous JPEG marker length");
		length -= 2;
		/* initialize a new reader to start from the beginning */
		app1reader = new StringReader(app1marker);
		/* Read until end of block or until magic string found */
		while (length > 0 && j < magic.length) {
			buf[i] = (char) (app1reader.read());
			if (buf[i] == -1)
				throw new ProcessingException("Premature EOF in JPEG file");
			if (buf[i] == magic[j]) {
				j++;
			} else {
				j = 0;
			}
			i = (i + 1) % 100;
			length--;
		}
		if (j == magic.length) {
			/* Copy from buffer everything since beginning of the PI */
			k = i;
			do {
				i = (i + 100 - 1) % 100;
			} while (buf[i] != '<' || buf[(i + 1) % 100] != '?'
					|| buf[(i + 2) % 100] != 'x' || buf[(i + 3) % 100] != 'p');
			for (; i != k; i = (i + 1) % 100)
				sbuf.append(buf[i]);
			/* Continue copying until end of XMP packet */
			j = 0;
			while (length > 0 && j < magicend.length) {
				c = (char) (app1reader.read());
				if (c == -1)
					throw new ProcessingException("Premature EOF in JPEG file");
				if (c == magicend[j])
					j++;
				else
					j = 0;
				sbuf.append(c);
				length--;
			}
			/* Copy until end of PI */
			while (length > 0) {
				c = (char) (app1reader.read());
				if (c == -1)
					throw new ProcessingException("Premature EOF in JPEG file");
				sbuf.append(c);
				length--;
				if (c == '>')
					break;
			}
		}
		/* Skip rest, if any */
		while (length > 0) {
			app1reader.read();
			length--;
		}
		return (sbuf.toString());
	}
	protected int read2bytes(StringReader sr) throws IOException,
			ProcessingException {
		int c1, c2;
		c1 = sr.read();
		if (c1 == -1)
			throw new ProcessingException("Premature EOF in JPEG file");
		c2 = sr.read();
		if (c2 == -1)
			throw new ProcessingException("Premature EOF in JPEG file");
		return (((int) c1) << 8) + ((int) c2);
	}
	/**
	 * This method scan
	 * 
	 * @return @throws
	 *         IOException
	 * @throws JpegException
	 */
	protected int scanHeaders() throws IOException, InvalidObjectException {
		int marker;
		vcom = new Vector(1);
		vacom = new Vector[16];
		for (int i = 0; i < 16; i++) {
			vacom[i] = new Vector(1);
		}
		if (firstMarker() != M_SOI)
			throw new InvalidObjectException("Expected SOI marker first");
		int i=0;
		while (true) {
		    // track infinite loop
			marker = nextMarker();
			switch (marker) {
				case M_SOF0 :
				/* Baseline */
				case M_SOF1 :
				/* Extended sequential, Huffman */
				case M_SOF2 :
				/* Progressive, Huffman */
				case M_SOF3 :
				/* Lossless, Huffman */
				case M_SOF5 :
				/* Differential sequential, Huffman */
				case M_SOF6 :
				/* Differential progressive, Huffman */
				case M_SOF7 :
				/* Differential lossless, Huffman */
				case M_SOF9 :
				/* Extended sequential, arithmetic */
				case M_SOF10 :
				/* Progressive, arithmetic */
				case M_SOF11 :
				/* Lossless, arithmetic */
				case M_SOF13 :
				/* Differential sequential, arithmetic */
				case M_SOF14 :
				/* Differential progressive, arithmetic */
				case M_SOF15 :
					/* Differential lossless, arithmetic */
					// Remember the kind of compression we saw
					compression = marker;
					// Get the intrinsic properties fo the image
					readImageInfo();
					break;
				case M_SOS: // stop before hitting compressed data
				skipVariable(); 
				 // Update the EXIF updateExif(); 
					return marker; 
				case M_EOI: // in case it's a tables-only JPEG stream //
				// Update the EXIF updateExif(); 
					return marker;
				case M_COM :
					// Always ISO-8859-1? Is this a bug or is there something
					// about
					// the comment field that I don't understand...
					vcom.addElement(new String(processComment(), "UTF-8"));
					break;
				case M_APP0 :
				case M_APP1 :
				case M_APP2 :
				case M_APP3 :
				case M_APP4 :
				case M_APP5 :
				case M_APP6 :
				case M_APP7 :
				case M_APP8 :
				case M_APP9 :
				case M_APP10 :
				case M_APP11 :
				case M_APP12 :
				case M_APP13 :
				case M_APP14 :
				case M_APP15 :
					// Some digital camera makers put useful textual
					// information into APP1 andAPP12 markers, so we print
					// those out too when in -verbose mode.
					byte data[] = processComment();
					vacom[marker - M_APP0].addElement(data);
					// This is where the EXIF data is stored, grab it and parse
					// it!
					/*
					 * Thnks Norm if (marker == M_APP1) { // APP1 == EXIF if
					 * (exif != null) { exif.parseExif(data); } }
					 */
					break;
				default :
					// Anything else just gets skipped
					skipVariable(); // we assume it has a parameter count...
					break;
			}
		}
	}
	
    /**
     * read the image info then the section
     */
    protected void readImageInfo() 
	throws IOException, InvalidObjectException
    {
	long len = (long)read2bytes() - 2;

	if (len < 0 )
	    throw new InvalidObjectException("Erroneous JPEG marker length");

	bitsPerPixel = in.read(); len--;
	height = read2bytes(); len -= 2;
	width = read2bytes(); len -= 2;
	numComponents = in.read(); len--;

	while (len > 0) {
	    long saved = in.skip(len);
	    if (saved < 0)
		throw new IOException("Error while reading jpeg stream");
	    len -= saved;
	}
    }

	
	protected int firstMarker() throws IOException, InvalidObjectException {
		int c1, c2;
		c1 = in.read();
		c2 = in.read();
		if (c1 != 0xFF || c2 != M_SOI)
			throw new InvalidObjectException("Not a JPEG file");
		return c2;
	}
	protected int nextMarker() throws IOException {
		int discarded_bytes = 0;
		int c;
		/* Find 0xFF byte; count and skip any non-FFs. */
		c = in.read();
		while (c != 0xFF)
			c = in.read();
		/*
		 * Get marker code byte, swallowing any duplicate FF bytes. Extra FFs
		 * are legal as pad bytes, so don't count them in discarded_bytes.
		 */
		do {
			c = in.read();
		} while (c == 0xFF);
		return c;
	}
	/**
	 * skip the body after a marker
	 */
	protected void skipVariable() throws IOException, InvalidObjectException {
		long len = (long) read2bytes() - 2;
		if (len < 0)
			throw new InvalidObjectException("Erroneous JPEG marker length");
		while (len > 0) {
			long saved = in.skip(len);
			if (saved < 0)
				throw new IOException("Error while reading jpeg stream");
			len -= saved;
		}
	}
	protected int read2bytes() throws IOException, InvalidObjectException {
		int c1, c2;
		c1 = in.read();
		if (c1 == -1)
			throw new InvalidObjectException("Premature EOF in JPEG file");
		c2 = in.read();
		if (c2 == -1)
			throw new InvalidObjectException("Premature EOF in JPEG file");
		return (((int) c1) << 8) + ((int) c2);
	}
	protected byte[] processComment() throws IOException, InvalidObjectException {
		int length;
		/* Get the marker parameter length count */
		length = read2bytes();
		/* Length includes itself, so must be at least 2 */
		if (length < 2)
			throw new InvalidObjectException("Erroneous JPEG marker length");
		length -= 2;
		StringBuffer buffer = new StringBuffer(length);
		byte comment[] = new byte[length];
		int got, pos;
		pos = 0;
		while (length > 0) {
			got = in.read(comment, pos, length);
			if (got < 0)
				throw new InvalidObjectException("EOF while reading jpeg comment");
			pos += got;
			length -= got;
		}
		return comment;
	}
	public String[] getStringAPPComments(int marker) throws UnsupportedEncodingException {
		// out of bound, no comment
		if ((marker < M_APP0) || (marker > M_APP15)) {
			return null;
		}
		int idx = marker - M_APP0;
		int asize = vacom[idx].size();
		appcomments = new byte[asize][];
		vacom[idx].copyInto(appcomments);
		String strappcomments[] = new String[asize];
		for (int i = 0; i < asize; i++) {
			strappcomments[i] = new String(appcomments[i], "UTF-8");
		}
		return strappcomments;
	}
}
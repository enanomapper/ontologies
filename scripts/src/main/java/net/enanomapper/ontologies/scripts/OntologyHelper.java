package net.enanomapper.ontologies.scripts;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.obolibrary.macro.ManchesterSyntaxTool;
import org.semanticweb.owlapi.expression.ParserException;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLObject;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyID;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.util.ShortFormProvider;
import org.semanticweb.owlapi.util.SimpleShortFormProvider;

import owltools.graph.OWLGraphWrapper;
import owltools.io.ParserWrapper;
import uk.ac.manchester.cs.owl.owlapi.mansyntaxrenderer.ManchesterOWLSyntaxObjectRenderer;

public class OntologyHelper {


	public static OWLOntology openOntologyFromURL(String url) {
		ParserWrapper pw = new ParserWrapper();
		try {
			URL website = new URL(url);
			HttpURLConnection connection = (HttpURLConnection)website.openConnection();

			InputStream is = openConnectionCheckRedirects(connection);

			BufferedReader in = new BufferedReader(
					new InputStreamReader(
							is));

			StringBuilder response = new StringBuilder();
			String inputLine;

			while ((inputLine = in.readLine()) != null) 
				response.append(inputLine);

			in.close();

			//create a temp file to store the content
			
			File temp = File.createTempFile("tempfile", 
					url.lastIndexOf(".")>0?url.substring(url.lastIndexOf(".")):".owl"); 

			//write it
			BufferedWriter bw = new BufferedWriter(new FileWriter(temp));
			bw.write(response.toString());
			bw.close();

			OWLOntology o = pw.parse(temp.toString());

			return o;


		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}

	}

	/**
	 * Creates a merged ontology with all the axioms from the imports closure of the source ontology. 
	 * @param source
	 * @return
	 */
	public static OWLOntology loadAllImportedAxioms(OWLOntology source, String mergedOntologyIRI) {

		OWLOntologyManager man = source.getOWLOntologyManager();
		OWLOntology mergedOntology = null;
		try {
			OWLGraphWrapper graph = new OWLGraphWrapper(source);

			mergedOntology = man.createOntology(new OWLOntologyID(IRI.create(mergedOntologyIRI)));
			
			for (OWLOntology ont : graph.getAllOntologies()) {
				man.addAxioms(mergedOntology, ont.getAxioms());
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null; 
		}
		return mergedOntology;
	}

	private static InputStream openConnectionCheckRedirects(URLConnection c) throws IOException
	{
		boolean redir;
		int redirects = 0;
		InputStream in = null;
		do {
			if (c instanceof HttpURLConnection) {
				((HttpURLConnection) c).setInstanceFollowRedirects(false);
			}
			// We want to open the input stream before getting headers
			// because getHeaderField() et al swallow IOExceptions.
			in = c.getInputStream();
			redir = false;
			if (c instanceof HttpURLConnection)
			{
				HttpURLConnection http = (HttpURLConnection) c;
				int stat = http.getResponseCode();
				if (stat >= 300 && stat <= 307 && stat != 306 &&
						stat != HttpURLConnection.HTTP_NOT_MODIFIED)
				{
					URL base = http.getURL();
					String loc = http.getHeaderField("Location");
					URL target = null;
					if (loc != null)
					{
						target = new URL(base, loc);
					}
					http.disconnect();
					// Redirection should be allowed only for HTTP and HTTPS (ADDED FTP)
					// and should be limited to 5 redirections at most.
					if (target == null || !(target.getProtocol().equals("http")
							|| target.getProtocol().equals("https")
							|| target.getProtocol().equals("ftp"))
							|| redirects >= 5)
					{
						throw new SecurityException("illegal URL redirect");
					}
					redir = true;
					c = target.openConnection();
					redirects++;
				}
			}
		}
		while (redir);
		return in;
	}
	
		/**
		 * 
		 * @param description
		 * @return
		 */
		 public static String toManchesterOWLSyntax(OWLClassExpression description) {
			StringWriter sw = new StringWriter();
	        ShortFormProvider sfp = new SimpleShortFormProvider();
	        ManchesterOWLSyntaxObjectRenderer renderer = new ManchesterOWLSyntaxObjectRenderer(sw, sfp);
	        description.accept(renderer);
	        return sw.toString();
		 } 
		 

		 public static String toManchesterOWLSyntax(OWLAxiom description) {
			StringWriter sw = new StringWriter();
	        ShortFormProvider sfp = new SimpleShortFormProvider();
	        ManchesterOWLSyntaxObjectRenderer renderer = new ManchesterOWLSyntaxObjectRenderer(sw, sfp);
	        description.accept(renderer);
	        return sw.toString();
	    } 
	    
		 
		 /**
		  * 
		  * @param label
		  * @param gr
		  * @return
		  */
		public static OWLObject getOWLObjectByLabel(String label, OWLGraphWrapper gr){
			OWLObject obj = gr.getOWLObjectByLabel(label);
			if (obj == null && gr.getIRIByLabel(label) != null)
				// getOWLObjectByLabel doesn't treat Data Properties!!!!
				obj = gr.getDataFactory().getOWLDataProperty((gr.getIRIByLabel(label)));
			return obj;
		}
		/**
		 * 
		 * @param id
		 * @param gr
		 * @return
		 */
		public static OWLObject getOWLObjectByIdentifier(String id, OWLGraphWrapper gr){
			OWLObject obj = gr.getOWLObjectByIdentifier(id);
			if (obj == null)
				// getOWLObjectByLabel doesn't treat Data Properties!!!!
				obj = gr.getDataFactory().getOWLDataProperty((gr.getIRIByIdentifier(id)));
			return obj;
		}
		
		/**
		 * 
		 * @param queryWithLabels
		 * @param graph
		 * @return a String representing queryWithLabels where labels are replaced with IDs
		 * @throws Exception
		 */
				
		public static String translateToIDs(String nlDLQuery, OWLGraphWrapper graph) throws Exception{
			String[] splitted = nlDLQuery.split("[\\s�]+");
			String res = "";
			for (String tok: splitted){
//				System.out.println("tok: " + tok);
				// try getting it by label, maybe it is a relation
				if (graph.getOWLObjectByIdentifier(tok) != null){
					res += tok + " ";
				}
				else {
					tok = tok.replaceAll("_", " ");
					if (OntologyHelper.getOWLObjectByLabel(tok, graph) != null){
						res += graph.getIdentifier( OntologyHelper.getOWLObjectByLabel(tok, graph)) + " ";
					}
					else if (isReservedWord(tok))
						res += tok + " ";
					else if (isDatatypeValue(tok)){
						res += parseDatatypeValue(tok) + " ";
					}
					else {
						Exception e = new Exception("Token <b>" + tok + "</b> could not be matched to an entry in our ontology. Please check the spelling.");
						throw e;
					}
				}
			}
			res = res.replaceAll("CHEMINF:", "CHEMINF_");
//			System.out.println("Query was translated to : " + res.trim());
			return res.trim();
		}
		
		/**
		 *  Checking reserved words is not exhaustive. Might need to add patterns.
		 * @param tok 
		 * @return true/false
		 */
		protected static boolean isReservedWord(String tok){
			if (tok.toLowerCase().matches("some|only|value|or|and|exactly|not|inverse|min|max|self|\\(|\\)|\\d+|int|long|\\[|\\]|\\>|\\<|\\>\\=|\\<\\="))
				return true;
			else return false;
		}
		
		public static boolean isDatatypeValue(String tok){
			if (tok.startsWith("int[") || tok.endsWith("^^int"))
				return true;
			return false;
		}
		
		/**
		 * 
		 * @param tok String representing the datatype value without spaces, in protege-like Manchester syntax, e.g. int[>=1]
		 * @return
		 */
		public static String parseDatatypeValue(String tok){
			String res = "";
			Pattern p = Pattern.compile("int\\[(\\>|\\<|\\>\\=|\\<\\=)(\\d+)\\]");
			Matcher m = p.matcher(tok);
			if (m.matches()){
				res= "xsd:integer [ " + m.group(1) + " " + m.group(2) + " ]";
			}
			else {
				tok.endsWith("^^int");
				res = tok.replace("^^int", "^^xsd:integer");
			}
			return res;
		}
		
		/**
		 * parseQuery
		 * @param query as string, in OWL Manchester Syntax and using IDs not labels!!
		 * @return the query param as OWLClassExpression 
		 */
		public static OWLClassExpression parseQuery(String query, OWLGraphWrapper graph, OWLOntology o) throws Exception{
			
			ManchesterSyntaxTool parser = null;		
			OWLClassExpression ce = null;
			try {
				parser = new ManchesterSyntaxTool(o);
				System.out.println("--before: " + query);
				ce = parser.parseManchesterExpression(query);
				System.out.println("--after: " + ce);
			} catch(ParserException e){
				String errMessage = "There was a problem parsing token ";
				String tok = "";
				if (OntologyHelper.getOWLObjectByIdentifier(e.getCurrentToken().replaceAll("CHEBI_", "CHEBI:"), graph) != null)
					tok = graph.getLabel(OntologyHelper.getOWLObjectByIdentifier(e.getCurrentToken().replaceAll("CHEBI_", "CHEBI:"), graph));
				else 
					tok = e.getCurrentToken();
				errMessage += "<b>" + tok + "</b> or the query is not compete. <br/>";
				errMessage += "The parser expected one of : "+ (e.getMessage().split("Expected one of:")[1]) + "." ;
				System.out.println(e.getMessage());
				throw new Exception(errMessage);
			} finally {
				// always dispose parser to avoid a memory leak
				if (parser != null) {
					parser.dispose();
				}
			}
			return ce;
		}
		/**
		 * Translates a query obtained with from OWLClassExpression to usual Manchester syntax using labels.
		 * @param idDLQuery
		 * @param graph
		 * @return
		 */
		public static String translateToLabels(String idDLQuery, OWLGraphWrapper graph){
			String q = idDLQuery.replace("(", "( ");
			q = q.replace(")", " )");
			String[] splitted;
			if (q.split(" SubClassOf | EquivalentClass ").length > 1){
				splitted = q.split(" SubClassOf ")[1].split("[\\s�]+");
			}
			else 
				splitted = q.split("[\\s�]+");
			String res = "";
			for (String tok: splitted){
				tok = tok.replace("CHEBI_", "CHEBI:");
				System.out.println("tok: " + tok);
				if (graph.getOWLObjectByIdentifier(tok) != null){
					res += graph.getLabel(graph.getOWLObjectByIdentifier(tok)).replaceAll(" ", "_") + " ";
				}
				else if (isReservedWord	(tok)){
					res += tok + " ";
				}
				else {
					res += tok + " ";
					Exception e = new Exception("Token <b>" + tok + "</b> could not be matched to an entry in our ontology. Please check the spelling.");
					System.out.println(e);
				}
			}
			res = res.replace("integer[> ", "int[>");
			res = res.replace("integer[< ", "int[<");
			res = res.replace("integer[>= ", "int[>=");
			res = res.replace("integer[<= ", "int[<=");
			System.out.println("Query was translated to : " + res.trim());
			return res.trim();
		}
		
		/**
		 * Both my check and the Machester syntax parser.
		 */
		protected static boolean checkSyntax(String query, OWLGraphWrapper graph, OWLOntology ont) throws Exception{
			String idQuery = "";
			String exceptionMessage = " ";
			try {
				if (query.equalsIgnoreCase(""))
					return true; //correct
				else {
					idQuery = translateToIDs(query, graph);
					if( OntologyHelper.parseQuery(idQuery, graph, ont) != null )
						return true;				
				}
			}catch (Exception e){
				exceptionMessage += e.getMessage();
				exceptionMessage = exceptionMessage.replaceAll("\n", "<br/>");
				throw new Exception (exceptionMessage);
			}
			return false;		
		}		
}

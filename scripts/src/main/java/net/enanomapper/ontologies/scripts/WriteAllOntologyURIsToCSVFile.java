package net.enanomapper.ontologies.scripts;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;

import com.opencsv.CSVWriter;

import owltools.io.ParserWrapper;

public class WriteAllOntologyURIsToCSVFile {
	
	ParserWrapper pw = new ParserWrapper();
	OWLDataFactory fac = pw.getManager().getOWLDataFactory();

	private OWLOntology loadOntology (String ontologyName) throws OWLOntologyCreationException {

		OWLOntology owlOntology = pw.parseOWL(ontologyName);
		
		String iri = owlOntology.getOntologyID().getOntologyIRI().toString();
		
		String iriChanged = iri+"_merged.owl";
		
		owlOntology = OntologyHelper.loadAllImportedAxioms(owlOntology, iriChanged);
		
		return owlOntology;
	}
	
	public File saveOntologyContentAsCSV (OWLOntology owlOntology, String fileNameToSave) throws IOException {
				
		HashMap<String,String> result = new HashMap<String,String>();
		
		File fileToSave = new File(fileNameToSave);
		
		for (OWLClass clz : owlOntology.getClassesInSignature()) {
			Set<OWLAnnotation> annos = clz.getAnnotations(owlOntology, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
				String classIRI = clz.toStringID();
				if (annoVal != null && !annoVal.isEmpty()) {
					result.put(classIRI, annoVal);	
				}
				
			}
			if (!result.containsKey(clz.toStringID())) {
				result.put(clz.toStringID(), "no RDFS label found!");
			}
		}
		
		
		CSVWriter writer = new CSVWriter(new FileWriter(fileToSave), '\t');
	     // feed in your array (or convert your data to an array)

		for (String key : result.keySet()) {
			writer.writeNext(new String[] {key , result.get(key)});
		}
		writer.flush();
		
		writer.close();
		
		return fileToSave;
	}
	
	public static final void main(String[] args) throws Exception {
		if (args.length < 2) {
			System.out.println("Need two arguments: \n"
					+ "1: to specify which ontology to load (URI), and \n"
					+ "2: the name of the file to save the output to.");
			System.exit(1);
		}
		
		String ontologyIRI = args[0];
		String fileNameToSave = args[1];
		
		WriteAllOntologyURIsToCSVFile me = new WriteAllOntologyURIsToCSVFile();
		
		OWLOntology ontology = me.loadOntology (ontologyIRI);
		
		File file = me.saveOntologyContentAsCSV (ontology, fileNameToSave);
		
		System.out.println("Done");
	}

	
}

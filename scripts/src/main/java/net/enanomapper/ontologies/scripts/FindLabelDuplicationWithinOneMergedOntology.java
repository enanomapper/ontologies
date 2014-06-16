package net.enanomapper.ontologies.scripts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;

import owltools.io.ParserWrapper;

public class FindLabelDuplicationWithinOneMergedOntology {


	public OverlapResult testOverlap (String ontologyName) throws Exception {
		ParserWrapper pw = new ParserWrapper();
		
		OWLOntology owlOntology = pw.parseOWL(ontologyName);
		
		String iri = owlOntology.getOntologyID().getOntologyIRI().toString();
		
		String iriChanged = iri+"_merged.owl";
	
		System.out.println("IRI: "+iriChanged);
		
		owlOntology = OntologyHelper.loadAllImportedAxioms(owlOntology, iriChanged);
		
		OWLDataFactory fac = pw.getManager().getOWLDataFactory();
		
		OverlapResult result = new OverlapResult();
		
		for (OWLClass c : owlOntology.getClassesInSignature()) {
			Set<OWLAnnotation> annos = c.getAnnotations(owlOntology, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
				String classIRI = c.toStringID();
				if (annoVal != null && !annoVal.isEmpty()) {
					result.allLabels.add(annoVal);
					if (!result.labelsToURIs.containsKey(annoVal)) {
						List<String> newList = new ArrayList<String>();
						newList.add(classIRI);
						result.labelsToURIs.put(annoVal, newList);
					} else {
						result.labelsToURIs.get(annoVal).add(classIRI);
					}
						
				}
			}
		}
		
		//start analytics
		for (String label : result.allLabels) {
			List<String> uris = result.labelsToURIs.get(label); 
			if (uris.size() > 1) {
				//There is a duplicate
				result.labelsDuplicated.add(label);
			}
		}
		
		return result;
	}
	
	public static final void main(String[] args) throws Exception {
		FindLabelDuplicationWithinOneMergedOntology to = new FindLabelDuplicationWithinOneMergedOntology();
		String ontology = "https://raw.githubusercontent.com/enanomapper/ontologies/master/enanomapper.owl";
		
		String ontologyName = ontology.substring(ontology.lastIndexOf("/"));
		
		OverlapResult res = to.testOverlap(ontology);
		System.out.println("# labels in "+ontologyName+": "+res.allLabels.size());
	
		System.out.println("# duplicated labels: "+res.labelsDuplicated.size()+", printed out below: ");
		
		for (String label : res.labelsDuplicated) {
			System.out.print(label);
			for (String uri : res.labelsToURIs.get(label)) { System.out.print(" "+uri); }
			System.out.println();
		}
	}
	
	
	
	class OverlapResult {
		List<String> allLabels;
		Map<String,List<String>> labelsToURIs;
		List<String> labelsDuplicated;
		
		public OverlapResult() {
			allLabels = new ArrayList<String>();
			labelsToURIs = new HashMap<String,List<String>>();
			labelsDuplicated = new ArrayList<String>();
		}
		
	}
	
}


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

public class FindLabelOverlapBetweenOntologies {


	public OverlapResult testOverlap (String ontologyOne, String ontologyTwo, boolean getImportsClosure) throws Exception {
		ParserWrapper pw = new ParserWrapper();
		
		OWLOntology owlOntoOne = pw.parseOWL(ontologyOne);
		OWLOntology owlOntoTwo = pw.parseOWL(ontologyTwo);
		
		if (getImportsClosure) {
			String iriOne = owlOntoOne.getOntologyID().getOntologyIRI().toString();
			String iriTwo = owlOntoTwo.getOntologyID().getOntologyIRI().toString();
			
			String iriOneChanged = iriOne+"_merged.owl";
			String iriTwoChanged = iriTwo+"_merged.owl";
		
			System.out.println("ONE: "+iriOneChanged);
			System.out.println("TWO: "+iriTwoChanged);
			
			owlOntoOne = OntologyHelper.loadAllImportedAxioms(owlOntoOne, iriOneChanged);
			owlOntoTwo = OntologyHelper.loadAllImportedAxioms(owlOntoTwo, iriTwoChanged);
			
		}
		
		OWLDataFactory fac = pw.getManager().getOWLDataFactory();
		
		OverlapResult result = new OverlapResult();
		
		for (OWLClass c : owlOntoOne.getClassesInSignature()) {
			Set<OWLAnnotation> annos = c.getAnnotations(owlOntoOne, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
				String classIRI = c.toStringID();
				if (annoVal != null && !annoVal.isEmpty()) {
					result.allLabelsOne.add(annoVal);
					result.labelsToURIsOne.put(annoVal, classIRI);
				}
			}
		}
		
		for (OWLClass c : owlOntoTwo.getClassesInSignature()) {
			Set<OWLAnnotation> annos = c.getAnnotations(owlOntoTwo, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
				String classIRI = c.toStringID();
				if (annoVal != null && !annoVal.isEmpty()) {
					result.allLabelsTwo.add(annoVal);
					result.labelsToURIsTwo.put(annoVal, classIRI);
				}
			}
		}		
		
	
		//start analytics
		for (String labelInOne : result.allLabelsOne) {
			if (result.allLabelsTwo.contains(labelInOne)) {
				if (result.labelsToURIsOne.get(labelInOne).equals(result.labelsToURIsTwo.get(labelInOne))) {
					result.labelsAndIdsShared.add(labelInOne);
				} else {
					result.labelsShared.add(labelInOne);
				}
			} else {
				result.labelsInOneNotTwo.add(labelInOne);
			}
			
		}
		
		for (String labelInTwo : result.allLabelsTwo) {
			if (!result.allLabelsOne.contains(labelInTwo)) {
				result.labelsInTwoNotOne.add(labelInTwo);
			}
		}
		return result;
	}
	
	public static final void main(String[] args) throws Exception {
		FindLabelOverlapBetweenOntologies to = new FindLabelOverlapBetweenOntologies();
		
//		OverlapResult res = to.testOverlapNonOBOOntology("http://www.ebi.ac.uk/~hastings/downloads/ontologies/CogPO12142010_v1.0.owl", 
//				"http://www.ebi.ac.uk/~hastings/downloads/ontologies/cogat_v0.3.owl");
//		System.out.println("# labels in CogAtlas: "+res.allLabelsOne.size());
//		System.out.println("# labels in CogPO: "+res.allLabelsTwo.size());
//	
//		System.out.println("# shared labels: "+res.labelsShared.size()+", printed out below: ");
//		
//		for (String label : res.labelsShared) {
//			System.out.println(label);
//		}
		
//		OverlapResult res = to.testOverlapNonOBOOntology("http://emotion-ontology.googlecode.com/svn/trunk/ontology/MFOEM.owl", 
//				"http://www.ebi.ac.uk/~hastings/downloads/ontologies/cogat_v0.3.owl");
//		System.out.println("# labels in MFOEM: "+res.allLabelsOne.size());
//		System.out.println("# labels in CogPO: "+res.allLabelsTwo.size());
//	
//		System.out.println("# shared labels: "+res.labelsShared.size()+", printed out below: ");
//		
//		for (String label : res.labelsShared) {
//			System.out.println(label);
//		}

//		String ontologyOne = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/chebi.owl";
//		String ontologyTwo = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/BAO-merged-full.owl";
		String ontologyTwo = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/npo-2011-12-08_inferred.owl";
//		String ontologyOne = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/CHEMINF-merged-full.owl";
		String ontologyOne = "http://semanticchemistry.googlecode.com/svn/trunk/ontology/cheminf.owl";
//		String ontologyTwo = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/BAO-merged-full.owl";
		
		String ontologyOneName = ontologyOne.substring(ontologyOne.lastIndexOf("/"));
		String ontologyTwoName = ontologyTwo.substring(ontologyTwo.lastIndexOf("/"));
		
		OverlapResult res = to.testOverlap(ontologyOne, ontologyTwo, true);
		System.out.println("# labels in "+ontologyOneName+": "+res.allLabelsOne.size());
		System.out.println("# labels in "+ontologyTwoName+": "+res.allLabelsTwo.size());
	
		System.out.println("# shared labels and IDs: "+res.labelsAndIdsShared.size()+", printed out below: ");
		
		for (String label : res.labelsAndIdsShared) {
			System.out.println(label);
		}
		
		System.out.println("# shared labels but not shared IDs: "+res.labelsShared.size()+", printed out below: ");
		
		for (String label : res.labelsShared) {
			System.out.println(label);
		}		
	}
	
	
	
	class OverlapResult {
		List<String> allLabelsOne;
		List<String> allLabelsTwo;
		Map<String,String> labelsToURIsOne;
		Map<String,String> labelsToURIsTwo;
		List<String> labelsShared;
		List<String> labelsAndIdsShared;
		List<String> labelsInOneNotTwo;
		List<String> labelsInTwoNotOne;
		
		public OverlapResult() {
			allLabelsOne = new ArrayList<String>();
			allLabelsTwo = new ArrayList<String>();
			labelsToURIsOne = new HashMap<String,String>();
			labelsToURIsTwo = new HashMap<String,String>();
			labelsShared = new ArrayList<String>();
			labelsAndIdsShared = new ArrayList<String>();
			labelsInOneNotTwo = new ArrayList<String>();
			labelsInTwoNotOne = new ArrayList<String>();
			
		}
		
	}
	
}


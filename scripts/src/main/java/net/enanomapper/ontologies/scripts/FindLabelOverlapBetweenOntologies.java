package net.enanomapper.ontologies.scripts;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;

import owltools.io.ParserWrapper;

public class FindLabelOverlapBetweenOntologies {


	public OverlapResult testOverlap (String ontologyOne, String ontologyTwo) throws Exception {
		ParserWrapper pw = new ParserWrapper();
		
		OWLOntology owlOntoOne = pw.parseOWL(ontologyOne);
		OWLOntology owlOntoTwo = pw.parseOWL(ontologyTwo);
		
		OWLDataFactory fac = pw.getManager().getOWLDataFactory();
		
		OverlapResult result = new OverlapResult();
		
		for (OWLClass c : owlOntoOne.getClassesInSignature()) {
			Set<OWLAnnotation> annos = c.getAnnotations(owlOntoOne, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
				
				if (annoVal != null && !annoVal.isEmpty()) {
					result.allLabelsOne.add(annoVal);
				}
			}
		}
		
		for (OWLClass c : owlOntoTwo.getClassesInSignature()) {
			Set<OWLAnnotation> annos = c.getAnnotations(owlOntoTwo, fac.getRDFSLabel());
			for (OWLAnnotation anno : annos) {
				String annoVal = anno.getValue().toString().replaceAll("\"", "").replaceAll("@", "");
			
				if (annoVal != null && !annoVal.isEmpty()) {
					result.allLabelsTwo.add(annoVal);
				}
			}
		}		
		
	
		//start analytics
		for (String labelInOne : result.allLabelsOne) {
			if (result.allLabelsTwo.contains(labelInOne)) {
				result.labelsShared.add(labelInOne);
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
		String ontologyOne = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/CHEMINF-merged-full.owl";
//		String ontologyTwo = "http://www.ebi.ac.uk/~hastings/downloads/ontologies/BAO-merged-full.owl";
		
		String ontologyOneName = ontologyOne.substring(ontologyOne.lastIndexOf("/"));
		String ontologyTwoName = ontologyTwo.substring(ontologyTwo.lastIndexOf("/"));
		
		OverlapResult res = to.testOverlap(ontologyOne, ontologyTwo);
		System.out.println("# labels in "+ontologyOneName+": "+res.allLabelsOne.size());
		System.out.println("# labels in "+ontologyTwoName+": "+res.allLabelsTwo.size());
	
		System.out.println("# shared labels: "+res.labelsShared.size()+", printed out below: ");
		
		for (String label : res.labelsShared) {
			System.out.println(label);
		}
	}
	
	
	
	class OverlapResult {
		List<String> allLabelsOne;
		List<String> allLabelsTwo;
		List<String> labelsShared;
		List<String> labelsInOneNotTwo;
		List<String> labelsInTwoNotOne;
		
		public OverlapResult() {
			allLabelsOne = new ArrayList<String>();
			allLabelsTwo = new ArrayList<String>();
			labelsShared = new ArrayList<String>();
			labelsInOneNotTwo = new ArrayList<String>();
			labelsInTwoNotOne = new ArrayList<String>();
			
		}
		
	}
	
}


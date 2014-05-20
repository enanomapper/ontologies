package net.enanomapper.ontologies.scripts;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import uk.ac.manchester.cs.owl.owlapi.OWLObjectSomeValuesFromImpl;


public class ExtractModuleFromOWLOntology {

	public List<RelationshipInfo> parseFile(String fileName) throws Exception {
		File file = new File(fileName); 
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
		OWLOntology ontology = manager.loadOntologyFromOntologyDocument(file);
		OWLDataFactory dataFactory = OWLManager.getOWLDataFactory();
		
		List<RelationshipInfo> infos = new ArrayList<RelationshipInfo>();
		
		
		for (OWLClass clazz : ontology.getClassesInSignature()) {

			String label = "";
			for (OWLAnnotation a : clazz.getAnnotations(ontology, dataFactory.getRDFSLabel() ) ) {
				label = a.getValue().toString();
			}

			Set<OWLClassExpression> set = clazz.getSuperClasses(ontology);

			for (OWLClassExpression clsEx : set) {

				OWLClass other = null;

				if (clsEx instanceof OWLObjectSomeValuesFromImpl) {
					OWLObjectSomeValuesFromImpl restric = (OWLObjectSomeValuesFromImpl) clsEx;


					for (OWLClass c : restric.getClassesInSignature() ) {
						other = c;
					}

					if (other != null ) {
						String otherLabel = "";
						for (OWLAnnotation a : other.getAnnotations(ontology, dataFactory.getRDFSLabel() ) ) {
							otherLabel = a.getValue().toString();
						}

						RelationshipInfo info = new RelationshipInfo();
						info.source = clazz.getIRI().toString().substring(clazz.getIRI().toString().indexOf("#")+1);
						info.sourceLabel = label;
						info.target = other.getIRI().toString().substring(other.getIRI().toString().indexOf("#")+1);
						info.targetLabel = otherLabel;
						info.relationshipType = restric.getProperty().toString().substring(restric.getProperty().toString().indexOf("#")+1, restric.getProperty().toString().lastIndexOf(">"));
						infos.add(info);
					}
				}
			}
		}
			
		return infos;
	}
	
	class RelationshipInfo {
		String source;
		String sourceLabel;
		String target;
		String targetLabel;
		String relationshipType;
	}
	
	
	public static String fileToLoad = "data/chebi.obo";
	public static String fileToLoadTwo = "data/gene_ontology_ext.obo";
	public static String fileToLoadThree = "data/biological_process_xp_chebi.obo";

	
	public static final void main(String[] args) throws Exception {
		ExtractModuleFromOWLOntology extractor = new ExtractModuleFromOWLOntology();
		List<RelationshipInfo> finalResults = new ArrayList<RelationshipInfo>();		

		//Parse ChEBI
		List<RelationshipInfo> list = extractor.parseFile(extractor.fileToLoad);
		Map<String, List<RelationshipInfo>> sortedByType = sortRelationshipTypes(list);
		System.out.println("Got "+list.size()+" relationships in ChEBI, sorted into "+sortedByType.keySet().size()+" relationship types.");	
		extractSubset(sortedByType, finalResults);

		//Parse Gene Ontology
		List<RelationshipInfo> list2 = extractor.parseFile(extractor.fileToLoadTwo);
		sortedByType = sortRelationshipTypes(list2);
		System.out.println("Got "+list2.size()+" relationships in GO, sorted into "+sortedByType.keySet().size()+" relationship types.");
		extractSubset(sortedByType, finalResults);

		
		//Parse cross-products
//		List<RelationshipInfo> list3 = extractor.parseFile(extractor.fileToLoadThree);
//		sortedByType = sortRelationshipTypes(list3);
//		System.out.println("Got "+list3.size()+" relationships in GO XP, sorted into "+sortedByType.keySet().size()+" relationship types.");
//		extractSubset(sortedByType, finalResults);

		
		
		System.out.println("Got "+finalResults.size()+" final results");
		for (RelationshipInfo info : finalResults) {
			System.out.println(info.source + "\t" + info.sourceLabel + "\t" + info.relationshipType + "\t" + info.target + "\t" + info.targetLabel);
		}		

	}


	private static void extractSubset(
			Map<String, List<RelationshipInfo>> sortedByType,
			List<RelationshipInfo> finalResults) {
		//now we have them sorted by relationship type, need to extract only a random 20 for each
		for (String relationshipType : sortedByType.keySet()) {
			
			int numOfThisType = sortedByType.get(relationshipType).size(); 
			int howManyIter = numOfThisType / 20;
			if (howManyIter < 1) howManyIter = 1;
			
			for (int i=howManyIter-1; i<numOfThisType; i+=howManyIter) {
				RelationshipInfo inf = sortedByType.get(relationshipType).get(i);
				finalResults.add(inf);
			}
			
		}
	}


	private static Map<String, List<RelationshipInfo>> sortRelationshipTypes(
			List<RelationshipInfo> list) {
		Map<String, List<RelationshipInfo>> sortedByType = new HashMap<String, List<RelationshipInfo>>();
		for (RelationshipInfo info : list) {
			if (sortedByType.containsKey(info.relationshipType)) {
				sortedByType.get(info.relationshipType).add(info);
			} else {
				List<RelationshipInfo> list2 = new ArrayList<RelationshipInfo>();
				sortedByType.put(info.relationshipType, list2);
				list2.add(info);
			}
		}
		return sortedByType;
	}
}



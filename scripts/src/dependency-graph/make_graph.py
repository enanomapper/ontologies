#!/usr/bin/env python3

import rdflib
import re
import yaml


def get_prefix(g, iri):
    for prefix, namespace in g.namespaces():
        pattern = re.compile(namespace)
        if bool(re.search(pattern, iri)):
            if prefix == 'aop-ontology':
                prefix = 'aopo'
            if prefix=='Thesaurus':
                prefix = 'ncit'
            prefix = re.sub(r'\d', '', prefix)
            prefix = re.sub(r'\bonto\b', 'enm', prefix)
            prefix = re.sub(r'\bowl\b', 'enm', prefix)
            return prefix

def load_configuration(config_file = 'config.yaml'):
    """Load the configuration from the YAML file and return it as adictionary."""
    
    with open(config_file, 'r') as config_file:
        config = yaml.safe_load(config_file)
    return config

def main():
    # slims
    slims = load_configuration()['slims']
    print(slims)
    # change this to the path of your OWL file
    owl_file = "enanomapper-full.owl"
    print(owl_file)
    g = rdflib.Graph()
    g.parse(owl_file, format='xml')
    edges = []
    with open("assets/dependency_graph.md", "w+") as f:
        f.write("```mermaid\n")
        f.write("graph LR\n")
    with open("assets/dependency_graph.tsv", 'w') as f:
        f.write("source\ttarget")
    with open("assets/slims_graph.md", "w+") as f:
        f.write("```mermaid\n")
        f.write("graph LR\n")
    with open("assets/slims_graph.tsv", 'w') as f:
        f.write("source\ttarget")
    for s, p, o in g:
        # is s a subClassOf o?
#        subclass_p = re.compile("http://www.w3.org/2000/01/rdf-schema#subClassOf")
#        if subclass_p.match(str(p)):
            # does s have a different namespace than o?
            namespace_s = get_prefix(g, s)
            namespace_o = get_prefix(g, o)
            if namespace_s != namespace_o and type(namespace_o) == str and type(namespace_s) == str and namespace_s != 'resource' and namespace_o != 'resource':
                if namespace_s == "obo":
                    match = re.search(r"obo/([A-Za-z]{3,7})", s)
                    if match:
                        namespace_s = match.group(1).casefold()
                if type(namespace_o) == str and "obo" in namespace_o:
                    match = re.search(r"obo/([A-Za-z]{3,7})", o)
                    if match:
                        namespace_o = match.group(1).casefold()
                
                new_edge = f"{namespace_s} --> {namespace_o}"
                if new_edge not in edges:
                    
                    edges.append(new_edge)
                    print("found subClassOf edge:", new_edge)
                    with open("assets/dependency_graph.md", "a") as f:
                        f.write(f"\t{new_edge}\n")
                    with open("assets/dependency_graph.tsv", "a") as f:
                        f.write(f"\n{namespace_s}\t{namespace_o}")
                    if namespace_o and namespace_s in [slim.casefold() for slim in slims]:
                        print('SLIM REUSE:')
                        with open('assets/slims_graph.md', 'a') as f:
                            f.write(f"\t{new_edge}\n")
                        with open('assets/slims_graph.tsv', 'a') as f:
                            f.write(f"\n{namespace_s}\t{namespace_o}")
    with open("assets/dependency_graph.md", "a") as f:
        f.write("```")
    with open("assets/slims_graph.md", "a") as f:
        f.write("```")

if __name__ == "__main__":
    main()

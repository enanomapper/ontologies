#!/usr/bin/env python3

"""
make-mmd
Makes a mermaid graph .md from an xml file showing the edges:
 - imports
 - subClassOf

Usage:
    tbd

"""

import re
import rdflib



def get_prefix(g, iri):
    for prefix, namespace in g.namespaces():
        pattern = re.compile(namespace)
        if bool(re.search(pattern, iri)):
            return prefix

def namespace_peek(g):
    for prefix, namespace in g.namespaces():
        print(prefix, " ---------------", namespace)

def main():
    # change this to the path of your OWL file
    owl_file = "enanomapper-full.owl"
    print(owl_file)
    g = rdflib.Graph()
    g.parse(owl_file, format='xml')
    edges = []
    with open("subclass.md", "w+") as f:
        f.write("""```mermaid
flowchart TD\n""")
    for s, p, o in g:
        # is s a subClassOf o?
        subclass_p = re.compile("http://www.w3.org/2000/01/rdf-schema#subClassOf")
        if subclass_p.match(str(p)):
            # does s have a different namespace than o?
            namespace_s = get_prefix(g, s)
            namespace_o = get_prefix(g, o)
            if namespace_s != namespace_o:
                new_edge = f"{namespace_s} --> {namespace_o}"
                if new_edge not in edges:
                    edges.append(new_edge)
                    print("found subClassOf edge:", new_edge)
                    with open("subclass.md", "a") as f:
                        f.write(f"\t{new_edge}\n")
    with open("subclass.md", "a") as f:
        f.write("```")   
if __name__ == "__main__":
    main()
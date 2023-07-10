#!/usr/bin/env python3

import rdflib
import re


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
    with open("assets/dependency_graph.md", "w+") as f:
        f.write("```mermaid\n")
        f.write("graph LR\n")
    with open("assets/dependency_graph.tsv", 'w') as f:
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
                    match = re.search(r"obo/([A-Za-z]{3,5})", s)
                    if match:
                        namespace_s = f"obo:{match.group(1)}"
                if type(namespace_o) == str and "obo" in namespace_o:
                    match = re.search(r"obo/([A-Za-z]{3,5})", o)
                    if match:
                        namespace_o = f"obo:{match.group(1)}"
                namespace_o = re.sub(r'\d', '', namespace_o)
                namespace_s = re.sub(r'\d', '', namespace_s)
                namespace_o = re.sub(r'\bonto\b', 'enm', namespace_o)
                namespace_s = re.sub(r'\bonto\b', 'enm', namespace_s)
                namespace_o = re.sub(r'\bowl\b', 'enm', namespace_o)
                namespace_s = re.sub(r'\bowl\b', 'enm', namespace_s)
                new_edge = f"{namespace_s} --> {namespace_o}"
                if new_edge not in edges:
                    edges.append(new_edge)
                    print("found subClassOf edge:", new_edge)
                    with open("assets/dependency_graph.md", "a") as f:
                        f.write(f"\t{new_edge}\n")
                    with open("assets/dependency_graph.tsv", "a") as f:
                        f.write(f"\n{namespace_s}\t{namespace_o}")
    with open("assets/dependency_graph.md", "a") as f:
        f.write("```")

if __name__ == "__main__":
    main()

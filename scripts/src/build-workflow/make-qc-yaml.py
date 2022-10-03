#!/usr/local/bin/python
import yaml
with open("enanomapper.yaml", "r") as stream:
    try:
        config = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

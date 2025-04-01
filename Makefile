# Makefile for ontology processing and term extraction
# This makefile handles extraction of terms from various ontologies,
# processing them according to the .iris configuration files, and
# generating slimmed ontologies using ROBOT.
# Tries to follow OBO's ROBOT/ODK conventions.

# List of ontologies to process
ONTOLOGIES = fabio aopo obi bfo ccont pato cheminf sio chmo npo \
             uo bao ncit uberon chebi oae envo go efo obcs bto \
             cito clo iao ro msio

# Commands and tools
ROBOT = bash robot
ROBOT_VERSION = v1.9.6
ROBOT_JAR = robot.jar
WGET = wget -nc
ROBOT_OPTS = --prefixes "external-dev/prefixes.json"

# Directories
TERM_FILES_DIR = external-dev/term-files
TEMPLATES_DIR = external-dev/templates
TMP_DIR = external-dev/tmp
#TMP_DIR = $(TMP_DIR)/source
CONFIG_DIR = config

# Output directory
OUTPUT_DIR = external-dev

# Main target to process all ontologies
.PHONY: all
all: setup download-robot process-config-files process-ontologies merge-templates cleanup

# Setup directories
.PHONY: setup
setup:
	@echo "Setting up directories..."
	@mkdir -p $(TERM_FILES_DIR)/add
	@mkdir -p $(TERM_FILES_DIR)/remove
	@mkdir -p $(TEMPLATES_DIR)
	@mkdir -p $(TMP_DIR)
	@mkdir -p $(TMP_DIR)

# Download ROBOT tool
.PHONY: download-robot
download-robot: robot $(ROBOT_JAR)

robot:
	$(WGET) https://github.com/ontodev/robot/raw/master/bin/robot
	@chmod +x robot

$(ROBOT_JAR):
	$(WGET) https://github.com/ontodev/robot/releases/download/$(ROBOT_VERSION)/robot.jar

# Process config files and generate term files
.PHONY: process-config-files
process-config-files: download-robot setup
	@echo "Removing previous files..."
	@rm -f $(TERM_FILES_DIR)/add/* 
	@rm -f $(TERM_FILES_DIR)/remove/*
	@echo "Processing config files..."
	@for onto in $(ONTOLOGIES); do \
		echo "Processing config file for $$onto"; \
		$(MAKE) process-onto-config ONTO=$$onto; \
	done

# Process a single ontology's config file
.PHONY: process-onto-config
process-onto-config:
	@echo "Processing $(ONTO).iris..."
	@touch $(TERM_FILES_DIR)/add/$(ONTO)_add_D.txt.tmp
	@touch $(TERM_FILES_DIR)/add/$(ONTO)_add.txt.tmp
	@touch $(TERM_FILES_DIR)/remove/$(ONTO)_remove_D.txt.tmp
	@touch $(TERM_FILES_DIR)/remove/$(ONTO)_remove.txt.tmp
	@touch $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv.tmp
	@SC=False; \
	while IFS= read -r line || [[ -n "$$line" ]]; do \
		add_sc=$$(echo "$$line" | grep -Po "(?<=:)\s*http[^\s]+"); \
		add_spc=$$(echo "$$line" | grep -Po "http:.+(?=\):)"); \
		add_comment=$$(echo "$$line" | grep -Po "(?<=\s).+"); \
		add_opt=$$(echo "$$line" | grep -Po "^[+,-]"); \
		add_d=$$(echo "$$line" | grep -Po "D"); \
		if [[ -z "$$add_d" ]]; then add_d="no"; else add_d="D"; fi; \
		if [[ "$$add_opt" == *"+"* ]]; then \
			if [[ "$$add_d" == "D" && -n "$$add_sc" ]]; then \
				echo "$${add_sc} # $${add_comment}" >> $(TERM_FILES_DIR)/add/$(ONTO)_add_D.txt.tmp; \
			elif [[ "$$add_d" != "D" && -n "$$add_sc" ]]; then \
				echo "$${add_sc} # $${add_comment}" >> $(TERM_FILES_DIR)/add/$(ONTO)_add.txt.tmp; \
			fi; \
			if [[ -n "$$add_spc" && -n "$$add_sc" ]]; then \
				SC=True; \
				echo "$${add_sc},$${add_spc}" >> $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv.tmp; \
			fi; \
		fi; \
		if [[ "$$add_opt" == *"-"* ]]; then \
			if [[ "$$add_d" == "D" && -n "$$add_sc" ]]; then \
				echo "$${add_sc} # $${add_comment}" >> $(TERM_FILES_DIR)/remove/$(ONTO)_remove_D.txt.tmp; \
			elif [[ "$$add_d" != "D" && -n "$$add_sc" ]]; then \
				echo "$${add_sc} # $${add_comment}" >> $(TERM_FILES_DIR)/remove/$(ONTO)_remove.txt.tmp; \
			fi; \
		fi; \
	done < $(CONFIG_DIR)/$(ONTO).iris; \
	for file in "$(TERM_FILES_DIR)/add/$(ONTO)_add_D.txt.tmp" "$(TERM_FILES_DIR)/add/$(ONTO)_add.txt.tmp" \
                "$(TERM_FILES_DIR)/remove/$(ONTO)_remove_D.txt.tmp" "$(TERM_FILES_DIR)/remove/$(ONTO)_remove.txt.tmp" \
                "$(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv.tmp"; do \
		if [[ -s "$$file" ]]; then \
			$(MAKE) replace-namespaces FILE=$$file; \
			mv "$$file" $${file%.tmp}; \
		else \
			rm "$$file"; \
		fi; \
	done; \
	if [[ "$$SC" == "False" ]]; then \
		rm -f $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv; \
	else \
		sort -r $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv | uniq > tmp_sc; \
		echo "ID,SC %" | cat - tmp_sc > $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv; \
		echo "IRI,subClassOf" | cat - $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv > tmp_sc; \
		mv tmp_sc $(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv; \
	fi

# Replace namespaces with CURIEs in a file
.PHONY: replace-namespaces
replace-namespaces:
	@sed -i \
		-e 's|http://www.bioassayontology.org/bao#|bao:|g' \
		-e 's|http://purl.bioontology.org/ontology/npo#|npo:|g' \
		-e 's|http://semanticscience.org/resource/|sio:|g' \
		-e 's|http://purl.org/spar/fabio/|fabio:|g' \
		-e 's|http://semanticscience.org/resource/|cheminf:|g' \
		-e 's|http://livercancer.imbi.uni-heidelberg.de/ccont#|ccont:|g' \
		-e 's|http://purl.enanomapper.org/onto/|enm:|g' \
		-e 's|http://purl.obolibrary.org/obo/|obo:|g' \
		-e 's|http://aopkb.org/aop_ontology#|aopo:|g' \
		-e 's|http://www.ebi.ac.uk/efo/|efo:|g' \
		$(FILE)

# Process ontologies with ROBOT
.PHONY: process-ontologies
process-ontologies: download-robot setup process-config-files
	@echo "Processing ontologies with ROBOT..."
	@for onto in $(ONTOLOGIES); do \
		echo "____________________________________________[$$onto]____________________________________________"; \
		$(MAKE) process-single-ontology ONTO=$$onto; \
	done

# Process a single ontology
.PHONY: process-single-ontology
process-single-ontology:
	@echo "Downloading $(ONTO) ontology..."
	@$(WGET) -O $(TMP_DIR)/$(ONTO).owl $$(grep "owl=" $(CONFIG_DIR)/$(ONTO).props | cut -d'=' -f2)
	@head $(TMP_DIR)/$(ONTO).owl
	@# Special case for NPO
	@if [[ "$(ONTO)" == "npo" ]]; then \
		echo "Reasoning NPO (ELK)"; \
		$(ROBOT) $(ROBOT_OPTS) reason --reasoner ELK --annotate-inferred-axioms true \
			--input $(TMP_DIR)/$(ONTO).owl --output $(TMP_DIR)/$(ONTO).owl; \
	fi
	
	@# Determine which files exist (case patterns determine processing steps)
	@add_D=$(TERM_FILES_DIR)/add/$(ONTO)_add_D.txt; \
	add=$(TERM_FILES_DIR)/add/$(ONTO)_add.txt; \
	remove=$(TERM_FILES_DIR)/remove/$(ONTO)_remove.txt; \
	remove_D=$(TERM_FILES_DIR)/remove/$(ONTO)_remove_D.txt; \
	file_status="$$([ -f $$add ] && echo 1 || echo 0)$$([ -f $$add_D ] && echo 1 || echo 0)$$([ -f $$remove ] && echo 1 || echo 0)$$([ -f $$remove_D ] && echo 1 || echo 0)"; \
	echo "[$(ONTO)] Settings code: $$file_status"; \
	
	@# Process based on which files exist - We'll implement the case patterns
	@add_D=$(TERM_FILES_DIR)/add/$(ONTO)_add_D.txt; \
	add=$(TERM_FILES_DIR)/add/$(ONTO)_add.txt; \
	remove=$(TERM_FILES_DIR)/remove/$(ONTO)_remove.txt; \
	remove_D=$(TERM_FILES_DIR)/remove/$(ONTO)_remove_D.txt; \
	file_status="$$([ -f $$add ] && echo 1 || echo 0)$$([ -f $$add_D ] && echo 1 || echo 0)$$([ -f $$remove ] && echo 1 || echo 0)$$([ -f $$remove_D ] && echo 1 || echo 0)"; \
	case $$file_status in \
		1111) \
			echo "[$(ONTO)] Settings: add, add_D, remove, and remove_D all existing"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add_D.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO)_add_D.owl --input $(TMP_DIR)/$(ONTO)_add.owl \
				--include-annotations true remove --term-file $$remove_D --select "self descendants" \
				remove --term-file $$remove --select "self" --output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1110) \
			echo "[$(ONTO)] Settings: add, add_D, and remove existing but no remove_D"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add_D.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO)_add_D.owl --input $(TMP_DIR)/$(ONTO)_add.owl \
				--include-annotations true remove --term-file $$remove --select "self" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1101) \
			echo "[$(ONTO)] Settings: add, add_D, and remove_D existing but no remove"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add_D.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO)_add_D.owl --input $(TMP_DIR)/$(ONTO)_add.owl \
				remove --term-file $$remove_D --select "self descendants" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1100) \
			echo "[$(ONTO)] Settings: add and add_D existing but no remove or remove_D"; \
			$(ROBOT) $(ROBOT_OPTS) filter --trim false --axioms all --input $(TMP_DIR)/$(ONTO).owl \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add_D.owl; \
			$(ROBOT) $(ROBOT_OPTS) filter --trim false --axioms all --input $(TMP_DIR)/$(ONTO).owl \
				--term-file $$add --select "annotations self" --signature false \
				merge --input $(TMP_DIR)/$(ONTO)_add_D.owl --output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1011) \
			echo "[$(ONTO)] Settings: add, remove, and remove_D existing but no add_D"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO)_add.owl \
				remove --term-file $$remove_D --select "self descendants" \
				remove --term-file $$remove --select "self" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1010) \
			echo "[$(ONTO)] Settings: add and remove existing but no add_D or remove_D"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) remove --input $(TMP_DIR)/$(ONTO)_add.owl \
				--term-file $$remove --select "self" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1001) \
			echo "[$(ONTO)] Settings: add and remove_D existing but no add_D or remove"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add.owl; \
			$(ROBOT) $(ROBOT_OPTS) remove --input $(TMP_DIR)/$(ONTO)_add.owl \
				--term-file $$remove_D --select "self descendants" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		1000) \
			echo "[$(ONTO)] Settings: only add existing"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add --select "annotations self" --signature false \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		0111) \
			echo "[$(ONTO)] Settings: add_D, remove, and remove_D existing but no add"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				remove --term-file $$remove_D --select "self descendants" \
				remove --term-file $$remove --select "self" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		0110) \
			echo "[$(ONTO)] Settings: add_D and remove existing but no add or remove_D"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				remove --term-file $$remove --select "self" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		0101) \
			echo "[$(ONTO)] Settings: add_D and remove_D existing but no add or remove"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_add_D.owl \
				remove --term-file $$remove_D --select "self descendants" \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
		0100) \
			echo "[$(ONTO)] Settings: only add_D existing"; \
			$(ROBOT) $(ROBOT_OPTS) merge --input $(TMP_DIR)/$(ONTO).owl filter --trim false --axioms all \
				--term-file $$add_D --select "annotations self descendants parents" --signature false \
				--output $(TMP_DIR)/$(ONTO)_no_spcs.owl; \
			;; \
	esac; \
	echo "...Done filtering source ontology $(ONTO)"; \
	timestamp=$$(date -I); \
	if [[ -f "$(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv" ]]; then \
		echo "Injecting SC via template."; \
		$(ROBOT) $(ROBOT_OPTS) template --template "$(TEMPLATES_DIR)/$(ONTO)_subclass_assertion.csv" \
			--output $(TMP_DIR)/$(ONTO)_spcs.owl; \
		$(ROBOT) $(ROBOT_OPTS) merge --include-annotations true \
			--input $(TMP_DIR)/$(ONTO)_no_spcs.owl --input $(TMP_DIR)/$(ONTO)_spcs.owl \
			--output $(OUTPUT_DIR)/$(ONTO)-slim.owl \
			annotate --ontology-iri "http://purl.enanomapper.net/onto/external/$(ONTO)-slim.owl" \
			--version-iri "https://purl.enanomapper.org/onto/external-dev/$(ONTO)-slim-prop.owl/" \
			--annotation http://www.w3.org/2002/07/owl#versionInfo "This ontology subset was generated automatically with ROBOT (http://robot.obolibrary.org)" \
			--annotation http://www.geneontology.org/formats/oboInOwl#date "$$timestamp (yyy-mm-dd)"; \
	else \
		cp $(TMP_DIR)/$(ONTO)_no_spcs.owl $(OUTPUT_DIR)/$(ONTO)-slim.owl; \
	fi; \
	if [[ -f "$(CONFIG_DIR)/$(ONTO)-term-file.txt" ]]; then \
		echo "Extracting object and data properties"; \
		$(ROBOT) $(ROBOT_OPTS) extract --method subset --input $(TMP_DIR)/$(ONTO).owl \
			--term-file $(CONFIG_DIR)/$(ONTO)-term-file.txt \
			annotate --version-iri "https://purl.enanomapper.org/onto/external-dev/$(ONTO)-slim-prop.owl/" \
			--ontology-iri "https://purl.enanomapper.org/onto/external-dev/$(ONTO)-slim.owl/" \
			--output $(OUTPUT_DIR)/$(ONTO)-slim-prop.owl; \
	fi

# Merge templates for predicates
.PHONY: merge-templates
merge-templates: download-robot process-ontologies
	@echo "Merging templates..."
	@$(ROBOT) merge --input enanomapper-dev.owl template \
		--template external-dev/templates/predicates/chemical_compositions.tsv \
		--ontology-iri "https://purl.enanomapper.org/onto/chemical_compositions.owl" \
		--output $(OUTPUT_DIR)/chemical_compositions.owl

# Clean up temporary files and downloaded .iris files
.PHONY: cleanup
cleanup:
	@echo "Cleaning up..."
	@rm -f *.iris

# Clean all generated files
.PHONY: clean
clean:
	@echo "Cleaning all generated files..."
	@rm -rf $(TMP_DIR)
	@rm -f robot robot.jar
	@rm -f *.iris

# Display help information
.PHONY: help
help:
	@echo "Ontology Processing Makefile"
	@echo "-------------------------------------------------------------------------"
	@echo "This makefile processes ontology term files based on configuration files"
	@echo "and creates slimmed versions using ROBOT."
	@echo
	@echo "Available targets:"
	@echo "  all               - Run the complete workflow"
	@echo "  setup             - Create necessary directories"
	@echo "  download-robot    - Download ROBOT tool"
	@echo "  process-config-files - Process configuration files to generate term files"
	@echo "  process-ontologies - Process all ontologies with ROBOT"
	@echo "  process-single-ontology ONTO=<ontology> - Process a specific ontology"
	@echo "  merge-templates   - Merge templates for predicates"
	@echo "  cleanup           - Remove temporary .iris files"
	@echo "  clean             - Remove all generated files and directories"
	@echo
	@echo "Example usage:"
	@echo "  make all          - Run the complete workflow"
	@echo "  make clean        - Clean all generated files"
	@echo "  make process-single-ontology ONTO=chebi - Process only the ChEBI ontology"
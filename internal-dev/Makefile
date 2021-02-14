OWLS := ${shell ls -1 *.owl }

check:
	@for owl in $(OWLS) ; do \
		echo "Checking $$owl" ; \
		xmllint --noout $$owl ; \
	done

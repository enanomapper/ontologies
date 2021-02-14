OWLS := ${shell ls -1 *.owl }

check:
	@for owl in $(OWLS) ; do \
		xmllint --noout $$owl ; \
	done

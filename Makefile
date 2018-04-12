PORTAINER_TEMPLATES_YAML = $(shell find -name 'portainer-template.yaml' | sort)

portainer/templates.json: $(PORTAINER_TEMPLATES_YAML)
# Will wait forever miserably if the requisites are empty
	$(shell cat $^ | egrep -v '^---$$' | ./utilities/yaml2json > $@)

all: portainer/templates.json

clean:
	-rm -f portainer/templates.json

.PHONY: all clean

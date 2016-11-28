{% set image_name = 'elasticsearch:1.5' %}
{% set cluster_name = salt['pillar.get']('elasticsearch:cluster_name', 'elasticsearch_root') %}
{% set memory_footprint = salt['pillar.get']("elasticsearch:memory_footprint", '1g') %}
{% set container_name = 'elasticsearch' %}
{% set host_port = salt['pillar.get']('elasticsearch:port') %}


/tmp/elasticsearch.yml:
  file.managed:
    - source: salt://docker-elasticsearch/files/elasticsearch.yml
    - template: jinja
    - context:
      cluster_name: {{ cluster_name }}

{{ image_name }}:
  dockerng.image_present

{{ container_name }}:
  require:
     - dockerng: {{ image_name }}
     - file: /tmp/elasticsearch.yml
  dockerng.running:
    - name: {{ container_name }}
    - image: {{ image_name }}
    - restart_policy: always
    - environment:
      - ES_HEAP_SIZE: "{{ memory_footprint }}"
    - binds:
      - "/tmp/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"
    - port_bindings:
      - {{ salt['grains.get']('ip4_interfaces:eth0:0') }}:{{ host_port }}:9200/tcp

{% set image_name = 'elasticsearch:1.5' %}
{% set cluster_name = salt['pillar.get']('elasticsearch:cluster_name', 'elasticsearch_root') %}
{% set memory_footprint = salt['pillar.get']("elasticsearch:memory_footprint", '1g') %}
{% set container_name = 'elasticsearch' %}
{% set host = salt['grains.get']('elasticsearch:host') %}
{% set host_port = salt['pillar.get']('elasticsearch:port') %}


/tmp/elasticsearch.yml:
  file.managed:
    - source: salt://docker-elasticsearch/files/elasticsearch.yml
    - template: jinja
    - context:
      cluster_name: {{ cluster_name }}

{{ image_name }}:
  docker.pulled:
    - name: elasticsearch

{{ image_name }}-container:
  require:
     - docker: elasticsearch
     - file: /tmp/elasticsearch.yml
  docker.installed:
    - name: {{ container_name }}
    - image: elasticsearch
    - environment:
      - ES_HEAP_SIZE: {{ memory_footprint }}

{{ image_name }}-running:
  require:
    - docker: {{ image_name }}-container
  docker.running:
    - container: {{ container_name }}
    - image: elasticsearch
    - restart_policy: always
    - volumes:
      - /tmp/elasticsearch.yml: /usr/share/elasticsearch/config/elasticsearch.yml
    - ports:
        "9200/tcp":
            HostIp: {{ host }}
            HostPort: {{ host_port }}

{% set es_cluster_name = salt['pillar.get']('elasticsearch:es_cluster_name', 'elasticsearch_root') %}
{% set memory_footprint = salt['pillar.get']("elasticsearch:memory_footprint", '1g') %}
{% set container_name = salt['pillar.get']("elasticsearch:container_name", 'elasticsearch') %}
{% set host_ip = salt['grains.get']('ip4_interfaces:eth0:0') %}
{% set host_port = salt['pillar.get']('elasticsearch:port') %}


/tmp/elasticsearch.yml:
  file.managed:
    - source: salt://docker-elasticsearch/files/elasticsearch.yml
    - template: jinja
    - context:
      es_cluster_name: {{ es_cluster_name }}

elasticsearch:
  docker.pulled:
    - name: elasticsearch

elasticsearch-container:
  require:
     - docker: elasticsearch
     - file: /tmp/elasticsearch.yml
  docker.installed:
    - name: {{ container_name }}
    - image: elasticsearch
    - environment:
      - ES_HEAP_SIZE: {{ memory_footprint }}

elasticsearch-running:
  require:
    - docker: elasticsearch-container
  docker.running:
    - container: {{ container_name }}
    - image: elasticsearch
    - restart_policy: always
    - volumes:
      - /tmp/elasticsearch.yml: /usr/local/etc/elasticsearch/elasticsearch.yml
    - ports:
        "9200/tcp":
            HostIp: {{ host_ip }}
            HostPort: {{ host_port }}

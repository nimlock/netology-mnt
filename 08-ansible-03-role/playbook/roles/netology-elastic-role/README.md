Elasticsearch
=========

Simple download binaries from official website and install elasticsearch.

Role Variables
--------------
There are only three variables that you can redefine in your playbook.
```yaml
elastic_version: "7.11.0" # Use for download only this version of elastic
elastic_home: "/opt/elastic/{{ elastic_version }}" # Use for unpackage distro and create ES_HOME variable
elastic_bind_address: "0.0.0.0" # Use for templating config for Elastic
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
      - netology-elastic-role
```

License
-------

BSD

Author Information
------------------

Netology Students

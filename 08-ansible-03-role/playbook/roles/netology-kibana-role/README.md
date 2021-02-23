Kibana
=========

Simple download binaries from official website and install kibana.

Role Variables
--------------
There are five variables that you can redefine in your playbook.
```yaml
kibana_version: "7.11.0" # Use for download only this version
kibana_home: "/opt/kibana/{{ kibana_version }}" # Use for unpackage distro and create KBN_HOME variable
kibana_port: "5601" # Use for config file templating
kibana_bind_address: "0.0.0.0" # Use for config file templating
elastic_url_in_kibana: "http://localhost:{{ elastic_port | default('9200') }}" # Use for config file templating
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
      - netology-kibana-role
```

License
-------

BSD

Author Information
------------------

Netology Students
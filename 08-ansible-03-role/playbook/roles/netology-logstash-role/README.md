Logstash
=========

Simple download binaries from official website and install logstash.

Role Variables
--------------
There are three variables that you can redefine in your playbook.
```yaml
logstash_version: "7.11.0" # Use for download only this version
logstash_home: "/opt/logstash/{{ logstash_version }}" # Use for unpackage distro and create LS_HOME variable
elastic_host_in_logstash: "localhost" # Use for config file templating
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
      - netology-logstash-role
```

License
-------

BSD

Author Information
------------------

Netology Students
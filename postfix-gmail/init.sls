{% from "postfix-gmail/map.jinja" import postfix with context %}

postfix:
  pkg.installed:
    - names: {{postfix.packages}}
  service.running:
    - name: postfix
    - require:
        - pkg: postfix
    - watch:
        - file: /etc/postfix/main.cf
        
# manage /etc/aliases if data found in pillar
{% if 'aliases' in pillar.get('postfix-gmail', '') %}
{{ postfix.aliases_file }}:
  file.managed:
    - source: salt://postfix-gmail/aliases
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: postfix

run-newaliases:
  cmd.wait:
    - name: newaliases
    - cwd: /
    - watch:
      - file: {{ postfix.aliases_file }}
{% endif %}

# copy the cert
main.cf-cacert:
  file.copy:
    - source: {{postfix.cacert}}
    - name: /etc/postfix/cacert.pem
    - require:
        - pkg: postfix

# configure sasl host
main.cf-sasl:
  file.append:
    - name: /etc/postfix/main.cf
    - text: |
        smtp_sasl_auth_enable = yes
        smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
        smtp_sasl_security_options = noanonymous
        smtp_tls_CAfile = /etc/postfix/cacert.pem
        smtp_use_tls = yes
        compatibility_level=2
    - require:
        - pkg: postfix
        - file: main.cf-cacert

# update the relayhost
main.cf-relayhost:
  file.replace:
    - name: /etc/postfix/main.cf
    - pattern: '^relayhost .*'
    - repl: 'relayhost = {{postfix.relayhost}}'
    - require:
        - pkg: postfix

# configure password file
/etc/postfix/sasl_passwd:
  file.managed:
    - mode: 0400
    - user: root
    - group: root
    - contents: "{{postfix.relayhost}} {{salt['pillar.get']('postfix-gmail:email')}}:{{salt['pillar.get']('postfix-gmail:password')}}"
  cmd.wait:
    - name: postmap /etc/postfix/sasl_passwd
    - watch:
        - file: /etc/postfix/sasl_passwd

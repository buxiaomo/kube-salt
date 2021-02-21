/etc/ssl/kubernetes/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - makedirs: True

/etc/ssl/kubernetes/ca.crt:
  x509.certificate_managed:
    - signing_private_key: /etc/ssl/kubernetes/ca.key
    - CN: "kubernetes-ca"
    - C: "BeiJing"
    - ST: "BeiJing"
    - L: "BeiJing"
    - O: "Ops"
    - OU: "DevOps"
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - require:
      - x509: /etc/ssl/kubernetes/ca.key
    - makedirs: True
    - backup: True

/etc/kubernetes/pki/ca.crt:
  file.managed:
    - source: salt://kubernetes/ca.crt
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/kubernetes/pki/ca.key:
  file.managed:
    - source: salt://kubernetes/ca.key
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/kubernetes/pki/openssl.cnf:
  file.managed:
    - source: salt://kube-apiserver/files/openssl.cnf.j2
    - user: root
    - group: root
    - template: jinja
    - makedirs: True
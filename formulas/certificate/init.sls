/etc/ssl/kubernetes:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/etc/ssl/kubernetes/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - require:
      - file: /etc/ssl/kubernetes

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
    - backup: True
    - require:
      - file: /etc/ssl/kubernetes
      - x509: /etc/ssl/kubernetes/ca.key
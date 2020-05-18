---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
spec:
  routes:
    - match: Host(`traefik.${domain}`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
  tls:
    secretName: traefik-tls
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: traefik-tls
spec:
  secretName: traefik-tls
  dnsNames:
    - traefik.${domain}
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: letsencrypt-cloudflare

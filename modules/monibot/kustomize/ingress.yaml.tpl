---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: monibot
spec:
  routes:
    - match: Host(`metrics.${domain}`) && Path(`/discord`)
      kind: Rule
      services:
        - name: monibot
          port: 9100
          kind: Service
      middlewares:
        - name: discord-metrics
  tls:
    secretName: monibot-tls
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: monibot-tls
spec:
  secretName: monibot-tls
  dnsNames:
    - metrics.${domain}
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: letsencrypt-cloudflare
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: discord-metrics
spec:
  replacePath:
    path: /649165975647682560/metrics

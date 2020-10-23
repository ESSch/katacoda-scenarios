apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "reviews"
  namespace: "default"
spec:
  peers:
  - mtls:
      mode: STRICT
---
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "ratings"
  namespace: "default"
spec:
  peers:
  - mtls:
      mode: STRICT
---
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "details"
  namespace: "default"
spec:
  peers:
  - mtls:
      mode: STRICT
---
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "productpage"
  namespace: "default"
spec:
  peers:
  - mtls:
      mode: STRICT
---
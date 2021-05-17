# Scanning

Trivy
Clair

# Diagnostic

Sonobuoy

output=$(sonobuoy retrieve)
sonobuoy results $output --plugin e2e --mode report
sonobuoy results $output --plugin e2e --mode detailed
sonobuoy results $output --plugin e2e --mode dump


https://github.com/vmware-tanzu/sonobuoy
https://sonobuoy.io/docs/master/results/
https://github.com/vmware-tanzu/sonobuoy
https://sonobuoy.io/docs/v0.50.0/results/
https://sonobuoy.io/docs/v0.50.0/snapshot/
https://sonobuoy.io/docs/v0.50.0/e2eplugin/
# ocp_cis_manual_checks

** Background **

In OpenShift you can install compliance operator to run compliance checks for your cluster. It has several profiles based on the compliance checks required at your site. For CIS benchmarks there are two profiles: ocp4-cis and ocp4-cis-node

For CIS profiles, there are around 23 `compliancecheckresult` which are `MANUAL` (Listed below)

```
$ oc get compliancecheckresult | grep MANUAL
ocp4-cis-accounts-restrict-service-account-tokens                     MANUAL   medium
ocp4-cis-accounts-unique-service-account                              MANUAL   medium
ocp4-cis-file-groupowner-proxy-kubeconfig                             MANUAL   medium
ocp4-cis-file-owner-proxy-kubeconfig                                  MANUAL   medium
ocp4-cis-general-apply-scc                                            MANUAL   medium
ocp4-cis-general-default-namespace-use                                MANUAL   medium
ocp4-cis-general-default-seccomp-profile                              MANUAL   medium
ocp4-cis-general-namespaces-in-use                                    MANUAL   medium
ocp4-cis-rbac-least-privilege                                         MANUAL   high
ocp4-cis-rbac-limit-cluster-admin                                     MANUAL   medium
ocp4-cis-rbac-limit-secrets-access                                    MANUAL   medium
ocp4-cis-rbac-pod-creation-access                                     MANUAL   medium
ocp4-cis-rbac-wildcard-use                                            MANUAL   medium
ocp4-cis-scc-drop-container-capabilities                              MANUAL   medium
ocp4-cis-scc-limit-ipc-namespace                                      MANUAL   medium
ocp4-cis-scc-limit-net-raw-capability                                 MANUAL   medium
ocp4-cis-scc-limit-network-namespace                                  MANUAL   medium
ocp4-cis-scc-limit-privilege-escalation                               MANUAL   medium
ocp4-cis-scc-limit-privileged-containers                              MANUAL   medium
ocp4-cis-scc-limit-process-id-namespace                               MANUAL   medium
ocp4-cis-scc-limit-root-containers                                    MANUAL   medium
ocp4-cis-secrets-consider-external-storage                            MANUAL   medium
ocp4-cis-secrets-no-environment-variables                             MANUAL   medium

```

Instead of executing each check one by one you can run this script to generate the output as per the instructions defined in the compliance rule. 
It generates the `Name`, `Description`, `Instructions` and `Output of the command that checks the rule for you to verify`

NOTE

```
Currently the script doesn't support following MANUAL rules:

- ocp4-cis-rbac-wildcard-use

```

** Pre-requirements **

1) Running OCP cluster with compliance operator installed
2) CIS scan has been performed on the cluster
3) Cluster-admin access to the OCP cluster

** Steps **

Clone the script to your helper node where you have the `oc` command line utility installed.

```wget https://raw.githubusercontent.com/avyas26/ocp_cis_manual_checks/main/manual_checks.sh```

Make it executable

```chmod +x manual_checks.sh```

Run the script

```./manual_checks.sh```

Sample output

``` 
NAME:
ocp4-cis-accounts-restrict-service-account-tokens

Description:
Restrict Automounting of Service Account Tokens Mounting 
service account tokens inside pods can provide an avenue 
for privilege escalation attacks where an attacker is able 
to compromise a single pod in the cluster.


Instructions:
For each pod in the cluster, review the pod specification 
and ensure that pods that do not need to explicitly communicate 
with the API server have automountServiceAccountToken configured to false.


OUTPUT: Pods that have automount service account token set to false
cluster-version-operator-6d8755cdbb-rvdpp                         openshift-cluster-version                          false
revision-pruner-9-master01                                        openshift-etcd                                     false
revision-pruner-9-master02                                        openshift-etcd                                     false
revision-pruner-9-master03                                        openshift-etcd                                     false
kube-apiserver-operator-6dbdbdc565-tnbps                          openshift-kube-apiserver-operator                  false
installer-10-master01                                             openshift-kube-apiserver                           false
installer-10-master02                                             openshift-kube-apiserver                           false
installer-10-master03                                             openshift-kube-apiserver                           false
installer-8-master02                                              openshift-kube-apiserver                           false
installer-8-master03                                              openshift-kube-apiserver                           false

<Truncated-Output>

```

Verify the output of each rule and make changes as necessary to make he result compliant.





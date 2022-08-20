#!/bin/bash

new_line(){ echo -e "\n"; }
print_message() { echo $1; }

clusterrole(){

	print_message "Cluster Role Bindings with service accounts having $1 access"

	for clusterrole in $(for scc in $(oc get scc -o custom-columns=NAME:.metadata.name,Priv:.$1 | grep true | awk '{print $1}'); do oc get clusterrole -A -o custom-columns=NAME:.metadata.name,Resource:.rules[*].resourceNames | grep "\[$scc\]" | awk '{print $1}'; done) ; do oc get clusterrolebindings $clusterrole -oyaml -o custom-columns=NAME:.metadata.name,Account:.subjects[*].name 2>/dev/null; done |column -t

}

localrole(){

	print_message "Local Role Bindings with service accounts having $1 access"

        for role in $(for scc in $(oc get scc -o custom-columns=NAME:.metadata.name,Priv:.$1 | grep true | awk '{print $1}'); do oc get role -A -o custom-columns=NAME:.metadata.name,Resource:.rules[*].resourceNames | grep "\[$scc\]" | awk '{print $1}'; done) ; do oc get rolebindings $role -oyaml -o custom-columns=NAME:.metadata.name,Account:.subjects[*].name 2>/dev/null; done |column -t

}

ocp4-cis-scc-limit-root-containers(){

	clusterrole allowPrivilegedContainer
	new_line
	localrole allowPrivilegedContainer

}

ocp4-cis-scc-limit-process-id-namespace(){

        clusterrole allowHostPID
        new_line
        localrole allowHostPID

}

ocp4-cis-scc-limit-privileged-containers(){

        clusterrole allowPrivilegedContainer
        new_line
        localrole allowPrivilegedContainer

}

ocp4-cis-scc-limit-privilege-escalation(){

        clusterrole allowPrivilegeEscalation
        new_line
        localrole allowPrivilegeEscalation

}

ocp4-cis-scc-limit-network-namespace(){

        clusterrole allowHostNetwork
        new_line
        localrole allowHostNetwork

}

ocp4-cis-scc-limit-ipc-namespace(){

        clusterrole allowHostIPC
        new_line
        localrole allowHostIPC

}

ocp4-cis-scc-limit-ipc-namespace(){

        clusterrole allowHostIPC
        new_line
        localrole allowHostIPC

}

ocp4-cis-accounts-restrict-service-account-tokens(){

	print_message "Pods that have automount service account token set to false"
	oc get pods -A  -oyaml -o custom-columns=NAME:.metadata.name,Project:.metadata.namespace,SAToken:.spec.automountServiceAccountToken | grep false

}

ocp4-cis-accounts-unique-service-account(){

	print_message "Cluster Role Bindings with default service accounts"
	for clusterrolebinding in $(oc get clusterrolebindings --no-headers | awk '{print $1}'); do oc get clusterrolebindings $clusterrolebinding -oyaml -o custom-columns=Name:.metadata.name,Account:.subjects[*].name; done |grep default |column -t

	print_message "Local Role Bindings with default service accounts"
        for rolebinding in $(oc get rolebindings --no-headers | awk '{print $1}'); do oc get rolebindings $rolebinding -oyaml -o custom-columns=Name:.metadata.name,Account:.subjects[*].name; done |grep default |column -t

}

ocp4-cis-api-server-oauth-https-serving-cert(){

	print_message "Type and cert data in current oauth api serving cert secret"
	oc describe secrets serving-cert -n openshift-oauth-apiserver | grep -A3 -E "Type|Data" | column -t

}

ocp4-cis-api-server-openshift-https-serving-cert(){

	print_message "Type and cert data in current api serving cert secret"
        oc describe secrets serving-cert -n openshift-apiserver | grep -A3 -E "Type|Data" | column -t

}

ocp4-cis-file-groupowner-proxy-kubeconfig(){

	print_message "File and Group ownership of /config/kube-proxy-config.yaml file"
	for i in $(oc get pods -n openshift-sdn -l app=sdn -oname);do echo $i $(oc exec -n openshift-sdn $i -c sdn -- stat -Lc %U:%G /config/kube-proxy-config.yaml); done

}

ocp4-cis-file-owner-proxy-kubeconfig(){

	print_message "File and Group ownership of /config/kube-proxy-config.yaml file"
        for i in $(oc get pods -n openshift-sdn -l app=sdn -oname);do echo $i $(oc exec -n openshift-sdn $i -c sdn -- stat -Lc %U:%G /config/kube-proxy-config.yaml); done

}

#ocp4-cis-general-apply-scc(){}

ocp4-cis-general-configure-imagepolicywebhook(){

	oc get image.config.openshift.io/cluster -o yaml
	print_message "Check for allowed and blocked registry sources in the above output"
	print_message "Reference: https://docs.openshift.com/container-platform/4.10/openshift_images/image-configuration.html"


}


ocp4-cis-general-default-namespace-use(){

	print_message "Check that only openshift and default service is created in default ns"
	oc get all -n default

}

ocp4-cis-general-default-seccomp-profile(){


	print_message "By default,seccomp profile is set to unconfined which means that no seccomp profiles are enabled."
	new_line
	print_message "To enable the default seccomp profile, use the reserved value /runtime/default that will make sure that the pod uses the default policy available on the host. If the default seccomp profile is too restrictive for you, you will need to create and manage your own seccomp profiles."

}



ocp4-cis-general-namespaces-in-use(){
	
	print_message "Check the namespaces created are the ones you need and are adequately administered"
	oc get ns | grep -v -E "openshift|kube|default"

}

ocp4-cis-rbac-limit-cluster-admin(){

	print_message "Check the below users with cluster-admin role. Do not modify clusterrolebindings that include system: prefix"
	oc get clusterrolebindings -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECT:.subjects[*].kind | grep -v system: | grep cluster-admin | column -t

}

ocp4-cis-rbac-limit-secrets-access(){

	print_message "Cluster roles that have access to secrets"
	for clusterrole in $(oc get clusterrole --no-headers -o NAME | grep -v system:); do echo $clusterrole $(oc describe  $clusterrole | grep secrets | grep -v /secrets) | grep secrets ; done

	print_message "Local roles that have access to secrets"
	for ns in $(oc get ns --no-headers -o NAME | awk -F/ '{print $2}'); do for role in $(oc get role -n $ns --no-headers -o NAME); do echo $ns $role $(oc describe  $role -n $ns | grep secrets | grep -v /secrets) | grep secrets; done;done

}

ocp4-cis-rbac-pod-creation-access(){

	print_message "Cluster roles that have access to create pods"
	for clusterrole in $(oc get clusterrole --no-headers -o NAME | grep -v system:); do echo $clusterrole $(oc describe  $clusterrole | grep "pods " | grep create) | grep pods ; done

	print_message "Local roles that have access to create pods"
	for ns in $(oc get ns --no-headers -o NAME | awk -F/ '{print $2}'); do for role in $(oc get role -n $ns --no-headers -o NAME); do echo $role $(oc describe  $role -n $ns | grep "pods " | grep create) | grep pods; done;done
}

#ocp4-cis-rbac-wildcard-use(){}

#ocp4-cis-scc-drop-container-capabilities(){}

#ocp4-cis-scc-limit-net-raw-capability(){}

ocp4-cis-secrets-consider-external-storage(){

	print_message "Check with customer if they use any third party systems to store secrets"

}

ocp4-cis-secrets-no-environment-variables(){

	print_message "Secrets mounted as environment variables"
	oc get all -o jsonpath='{range .items[?(@..secretKeyRef)]} {.kind} {.metadata.namespace} {.metadata.name} {"\n"}{end}' -A |column -t

}

for manual_check in $(oc -n openshift-compliance get compliancecheckresult | grep MANUAL | awk '{print $1}')

do
	new_line
	echo "NAME:"
	oc -n openshift-compliance get compliancecheckresult $manual_check -o jsonpath='{.metadata.name}'

	new_line
	echo "Description:"
	oc -n openshift-compliance get compliancecheckresult $manual_check -o jsonpath='{.description}' | xargs -d'\n'

	new_line
	echo "Instructions:"
	oc -n openshift-compliance get compliancecheckresult $manual_check -o jsonpath='{.instructions}' | xargs -d'\n'

	new_line
	$manual_check
done

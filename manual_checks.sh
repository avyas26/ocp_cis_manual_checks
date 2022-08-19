#!/bin/bash

new_line(){

	echo -e "\n"
}

clusterrole(){

	echo "Cluster Role Bindings with service accounts having $1 access"

	for clusterrole in $(for scc in $(oc get scc -o custom-columns=NAME:.metadata.name,Priv:.$1 | grep true | awk '{print $1}'); do oc get clusterrole -A -o custom-columns=NAME:.metadata.name,Resource:.rules[*].resourceNames | grep "\[$scc\]" | awk '{print $1}'; done) ; do oc get clusterrolebindings $clusterrole -oyaml -o custom-columns=NAME:.metadata.name,Account:.subjects[*].name 2>/dev/null; done

}

localrole(){

	echo "Local Role Bindings with service accounts having $1 access"

        for role in $(for scc in $(oc get scc -o custom-columns=NAME:.metadata.name,Priv:.$1 | grep true | awk '{print $1}'); do oc get role -A -o custom-columns=NAME:.metadata.name,Resource:.rules[*].resourceNames | grep "\[$scc\]" | awk '{print $1}'; done) ; do oc get rolebindings $role -oyaml -o custom-columns=NAME:.metadata.name,Account:.subjects[*].name 2>/dev/null; done

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

for manual_check in $(oc get compliancecheckresult | grep MANUAL | grep scc | awk '{print $1}')

do
	echo "NAME:"
	oc get compliancecheckresult $manual_check -o jsonpath='{.metadata.name}'

	new_line
	echo "Description:"
	oc get compliancecheckresult $manual_check -o jsonpath='{.description}' | xargs echo

	new_line
	echo "Instructions:"
	oc get compliancecheckresult $manual_check -o jsonpath='{.instructions}' | xargs echo
	
	new_line
	$manual_check
done

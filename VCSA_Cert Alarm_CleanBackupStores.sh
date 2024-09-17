#!/bin/bash
echo "https://knowledge.broadcom.com/external/article?legacyId=82560"
echo
echo "These are the current Certificate Stores:";
    for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list);
    do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After";
    done 
    echo "   *   ";
echo
echo "If there are any expired or expiring Certificates within the BACKUP_STORES please continue to run this script";
echo 
	read -p "Have you taken powered off snapshots of all PSC's and VCSA's within the SSO domain(Y|y|N|n)" -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then 
		exit 1
	fi
echo
	for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli entry list --store BACKUP_STORE |grep -i "alias" | cut -d ":" -f2);
	do echo BACKUP_STORE $i; 
	/usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store BACKUP_STORE --alias $i -y; 
	done 
	
	for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list); 
	do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After";
	done | grep -i 'BACKUP_STORE_H5C'&> /dev/null

	if [ $? == 0 ]; then 
		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli entry list --store BACKUP_STORE_H5C |grep -i "alias" | cut -d ":" -f2); 
        do echo BACKUP_STORE_H5C $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store BACKUP_STORE_H5C --alias $i -y; 
        done
		echo 
		echo "   **   ";
	fi
echo "The resulting BACKUP_STORES after the cleanups are: ";
echo
		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list); 
        do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After"; 
        done
	    echo "   ***   ";
echo
echo "Results: ";
echo "The Certificate BACKUP_STORES were successfully cleaned";
echo
echo "Please acknowlege and reset any certificate related alarm."
echo "Restart services on all PSC's and VCSA's in the SSO Domain:";
echo " service-control --stop --all && service-control --start --all(optional) "
echo
echo "https://knowledge.broadcom.com/external/article/344633/stopping-starting-or-restarting-vmware-v.html"
echo "--------------------------------------------------------";
echo
echo "Monitor the VCSA for 24 hours and alarms should clear after acknowlegement."
echo
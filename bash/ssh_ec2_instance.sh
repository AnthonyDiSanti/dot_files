#!/usr/bin/env bash

ssh_ec2_instance() {

  printUsage() {
    echo " "
    echo "Example: ssh_ec2_instance -i i-4334234 -u 'evans'"
    echo "Options:"
    echo " -i, ec2 instance id"
    echo " -u, instance login user"
    echo " -h, this help screen"
  }

  if (( $# < 1 )); then
    printUsage >&2
    return 0
  fi

  # Set default ec2 login user
  ec2_user='ubuntu'

  #  grab the options and their arguments
  while getopts "i:u:h" option; do
          case $option in
                  u)    ec2_user=$OPTARG;;
                  i)    ec2_instance_id=$OPTARG;;
                  h)    
                        printUsage
                        return 0
                        ;;
                  [?])  
                        printUsage >&2
                        return 1
                        ;;
          esac
  done

  ec2_instance_url=$(ec2-describe-instances ${ec2_instance_id} | grep INSTANCE | cut -f 4)

  echo "ssh ${ec2_user}@$ec2_instance_url"
  ssh ${ec2_user}@$ec2_instance_url

}

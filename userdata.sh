#!/bin/bash
# informing this as shell-script

# directly connecting shell - rabbitmq and connect by above code
labauto ansible
ansible-pull -i localhost, -U https://github.com/prabalark/roboshop-ansible-72.git roboshop-ani.yml -e role_name=${name} -e env=${env} &>>/opt/ansible.log


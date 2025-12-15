INVENTORY ?= ansible/inventory.ini

deploy:
	ansible-playbook -i $(INVENTORY) ansible/site.yml

ping:
	ansible -i $(INVENTORY) pi -m ping

ssh:
	@echo "Use: ssh <user>@<pi_ip>"
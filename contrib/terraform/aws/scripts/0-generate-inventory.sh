terraform output -json > output.json
jinja2 templates/inventory.tpl output.json > inventory.ini
# ansible-playbook -i inventory.ini cluster.yml -b -u ubuntu

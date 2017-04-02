#!/usr/bin/env node

if (process.argv.length < 3) {
    console.error('Usage: terraform2ansible.js <stateFile> [outputFile]');
    process.exit(1);
}

let input = process.argv[2];
let output = null;
if (process.argv.length == 4) {
    output = process.argv[3];
}

let fs = require('fs');
let config = JSON.parse(fs.readFileSync(input, 'utf8'));
let resources = config.modules[0].resources;
let ansible = {};
const attributes = ['public_ip', 'private_ip', 'type', 'instance_type'];

for (let key in resources) {
    let resource = resources[key];
    if (resource.type == 'aws_instance') {

        let host = resource.primary ? resource.primary.attributes : resource.tainted.attributes;
        let myRegexp = /aws_instance\.([^.]*)/g;
        let match = myRegexp.exec(key);
        let type = match[1];
        if (match) {
            host.type = type;
            if (ansible[type] == null) {
                ansible[type] = [];
            }
            ansible[type].push(host);
        }
    }
}

function hostname(type,index){
    return `${type.replace('_','-')}${index+1}.private`;
}

let inventory = "";
ssh_config = '';
for (let key in ansible) {
    inventory += "\n[" + key + "]\n";
    ansible[key].forEach(function (host, index) {
        inventory += `${hostname(key,index)}`;
        inventory += ` fqdn="${hostname(key,index)}" `;
        for (let attr_key in host) {
            if (attributes.indexOf(attr_key) != -1) {
                inventory += " " + attr_key + "=\"" + host[attr_key] + "\"";
            }
        }
        inventory += "\n";

        if (host.public_ip != '') {

            if (host.type == 'bastion') {
                ssh_config += `
Host ${hostname(key,index)}
  Hostname ${host.public_ip}
  User ubuntu
  IdentityFile mesos-starter
  ForwardAgent yes
`;
            } else {
                ssh_config += `
Host ${hostname(key,index)}
  Hostname ${host.public_ip}
  User ubuntu
  IdentityFile mesos-starter
`;
            }

        } else {
            ssh_config += `
Host ${hostname(key,index)}
  Hostname ${host.private_ip}
  User ubuntu
  IdentityFile mesos-starter
  ProxyCommand ssh bastion.1 -W %h:%p
`;
        }

    });
}

if (output) {
    fs.writeFile(output, inventory, function (err) {
        if (err) {
            console.log(err);
        } else {
            console.log(output + " was saved!");
        }
    });

    fs.writeFile('./ssh/ssh_config', ssh_config, function (err) {
        if (err) {
            console.log(err);
        } else {
            console.log('./ssh/ssh_config' + " was saved!");
        }
    });
} else {
    console.log(inventory)
}

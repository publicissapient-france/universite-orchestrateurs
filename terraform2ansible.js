#!/usr/bin/env node

if (process.argv.length < 3) {
    console.error('Usage: terraform2ansible.js <stateFile> [outputFile]');
    process.exit(1);
}

var input = process.argv[2];
var output = null;
if (process.argv.length == 4) {
    output = process.argv[3];
}

var fs = require('fs');
var config = JSON.parse(fs.readFileSync(input, 'utf8'));
var resources = config.modules[0].resources;
var ansible = {};
var attributes = ['public_ip', 'private_ip', 'type', 'instance_type'];

for (var key in resources) {
    var resource = resources[key];
    if (resource.type == 'aws_instance') {

        var host = resource.primary ? resource.primary.attributes : resource.tainted.attributes;
        var myRegexp = /aws_instance\.([^.]*)/g;
        var match = myRegexp.exec(key);
        var type = match[1];
        if (match) {
            host.type = type;
            if (ansible[type] == null) {
                ansible[type] = [];
            }
            ansible[type].push(host);
        }
    }
}

var inventory = "";
ssh_config = '';

for (var key in ansible) {
    inventory += "[" + key + "]\n";
    ansible[key].forEach(function (host, index) {
        inventory += `${key}.${index+1}`;
        // inventory += host.public_ip != '' ? host.public_ip : host.private_ip;
        for (var attr_key in host) {
            if (attributes.indexOf(attr_key) != -1) {
                inventory += " " + attr_key + "=\"" + host[attr_key] + "\"";
            }
        }
        inventory += "\n";

        if (host.public_ip != '') {

            if (host.type == 'bastion') {
                ssh_config += `
Host ${key}.${index+1}
  Hostname ${host.public_ip}
  User ubuntu
  IdentityFile mesos-starter
  ForwardAgent yes
`;
            } else {
                ssh_config += `
Host ${key}.${index+1}
  Hostname ${host.public_ip}
  User ubuntu
  IdentityFile mesos-starter
`;
            }

        } else {
            ssh_config += `
Host ${key}.${index+1}
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

    fs.writeFile('ssh_config', ssh_config, function (err) {
        if (err) {
            console.log(err);
        } else {
            console.log('ssh_config' + " was saved!");
        }
    });
} else {
    console.log(inventory)
}

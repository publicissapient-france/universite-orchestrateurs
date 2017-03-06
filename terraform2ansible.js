#!/usr/bin/env node

if (process.argv.length < 3) {
    console.error('Usage: terraform2ansible.js <stateFile> [outputFile]');
    process.exit(1);
}

var input = process.argv[2];
var output = null;
if(process.argv.length == 4){
    output = process.argv[3];
}

var fs = require('fs');
var config = JSON.parse(fs.readFileSync(input, 'utf8'));
var resources = config.modules[0].resources;
var ansible = {};
var attributes = ['public_ip', 'private_ip','type','instance_type'];

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
for (var key in ansible) {
    inventory += "[" + key + "]\n";
    ansible[key].forEach(function (host) {
        inventory += host.public_ip != '' ? host.public_ip : host.private_ip;
        for (var key in host) {
            if (attributes.indexOf(key) != -1) {
                inventory += " " + key + "=\"" + host[key] + "\"";
            }
        }
        inventory += "\n";
    });
}

if(output){
    fs.writeFile(output,inventory, function(err) {
        if(err) {
            console.log(err);
        } else {
            console.log(output + " was saved!");
        }
    });
}else{
    console.log(inventory)
}

#!/usr/bin/env node
let fs = require('fs');

let input ="applications/services.json";

if (process.argv.length < 3) {
    console.error('Usage: uopen.js <service>');
    process.exit(1);
}

let service = process.argv[2];


let services = JSON.parse(fs.readFileSync(input, 'utf8'));

let service_url = services[service];
if(service_url !== undefined) {
    let exec = require('child_process').exec;
    let cmd = `/usr/bin/open ${service_url}`;

    exec(cmd, function (error, stdout, stderr) {
        console.log(error);
        // command output is in stdout
    });
}else{
    console.error(`Unkown service ${service}`)
}
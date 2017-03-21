#! /bin/bash
set -e

echo "--- Bootstrap script ---"

if [ -z "$MARATHON_APP_ID" ]; then
	echo "No Marathon App ID"
else
	echo "Marathon App ID: $MARATHON_APP_ID"

	# Configure LibProcess advertise IP and Port
	export LIBPROCESS_ADVERTISE_IP="$HOST"
	export LIBPROCESS_ADVERTISE_PORT="$PORT_45000"

	echo "LIBPROCESS_ADVERTISE_IP=$HOST"
	echo "LIBPROCESS_ADVERTISE_PORT=$PORT_45000"

	# Configure Jenkins URL for Mesos plugin
	config_file="/var/jenkins_home/config.xml"
	jenkins_url="$HOST:$PORT"

	if [ -f $config_file ]; then
		count=$(find $config_file -exec grep "<jenkinsURL>.*</jenkinsURL>" {} \; | wc -l)

		if [ $count -eq 1 ]; then
			sed -i "s#<jenkinsURL>.*</jenkinsURL>#<jenkinsURL>http://$jenkins_url</jenkinsURL>#" \
				$config_file

			echo "Jenkins URL: $jenkins_url"

			configured=1
		fi
	fi

	if [ -z $configured ]; then
		printf '\n%s\n\n%s\n\n' "WARNING: Mesos Cloud is not configured yet." \
								"Please add a new Mesos Cloud with Jenkins URL set to $jenkins_url"
	fi
fi

echo "------------------------"

exec /bin/tini -- /usr/local/bin/jenkins.sh

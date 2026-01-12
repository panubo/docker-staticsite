load functions.bash
load setup.bash

setup_file() {
	# Disable parallel execution in this file
	export BATS_NO_PARALLELIZE_WITHIN_FILE=true

	docker_volume="$(docker volume create)"

	export docker_volume
}

teardown_file() {
	docker volume rm -f "${docker_volume}" || true
}

@test "k8s-init check copy and render" {
	# Fix volume permissions to match K8s behaviour
	docker run --rm -v "${docker_volume}:/volume" busybox install -d -o root -g 2000 -m 2775 /volume

	# Run k8s-init - content and config should be copied to the volume
	docker run --rm -v "${docker_volume}:/volume" --group-add 2000 panubo/staticsite-testsite:1 k8s-init

	# Print the content of the volume
	run docker run --rm -v "${docker_volume}:/volume" busybox sh -c 'find /volume | sort'

	# diag "${output}"
	assert_line '/volume/config/http.d/default.conf'
	assert_line '/volume/content/html/env-config.js'
	assert_line '/volume/content/html/env-config2.js'
}

@test "k8s-init check nginx default.conf" {
	# Don't need to redo the permissions and k8s-init since no parallelize is set in this file

	# Print the content of nginx default.conf
	run docker run --rm -v "${docker_volume}:/volume" busybox cat /volume/config/http.d/default.conf

	# diag "${output}"
	assert_line -p 'root  /var/www/html;'
}

@test "k8s-nginx" {
	# This test isn't possible with docker since your cannot mount a subPath
	# from a docker volume. eg `-v "$
	# {docker_volume}/config/http.d:/etc/nginx/http.d:ro` (or whatever the
	# syntax will be if implemented in docker).
	skip "Unable to implement with docker, missing subPath support"

	container="$(docker run -d -v "${docker_volume}:/volume:ro" --group-add 2000 -p 8080 panubo/staticsite-testsite:1 k8s-nginx)"
	container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container})"
	container_http_port="$(docker inspect --format '{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' ${container} || { docker logs ${container} >&3 2>&3; return 1; })"
	( wait_http "http://127.0.0.1:${container_http_port}"; )

	run curl -sSf http://127.0.0.1:${container_http_port}

	docker rm -f "${container}" || true

	assert_success
}

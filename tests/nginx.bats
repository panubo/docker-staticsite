load functions.bash
load setup.bash

setup_file() {
	container="$(docker run -d -p 8080 panubo/staticsite-testsite:1 nginx)"
	container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container})"
	container_http_port="$(docker inspect --format '{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' ${container} || { docker logs ${container} >&3 2>&3; return 1; })"
	( wait_http "http://127.0.0.1:${container_http_port}"; )
	export container container_ip container_http_port
}

teardown_file() {
	docker rm -f "${container}" || true
}

@test "nginx smoke test" {
	# echo "# curl -sSf http://127.0.0.1:${container_http_port}" >&3
	run curl -sSf http://127.0.0.1:${container_http_port}
	# diag "${output}"
	assert_success
	assert_line "<h1>Hello World!</h1>"
}

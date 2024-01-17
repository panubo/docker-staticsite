load functions.bash
# load setup.bash

setup_file() {

	# Start a minio server to emulate s3
	minio_container="$(docker run -d \
		-e MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE \
		-e MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-p 9000 \
		-p 9001 \
		minio/minio:latest server /mnt)"
	minio_container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${minio_container})"
	minio_container_http_port="$(docker inspect --format '{{(index (index .NetworkSettings.Ports "9000/tcp") 0).HostPort}}' ${minio_container})"

	# container="$(docker run -d -p 80 panubo/staticsite-testsite:1 nginx)"
	# container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container})"
	# container_http_port="$(docker inspect --format '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' ${container})"
	( wait_http "http://127.0.0.1:${minio_container_http_port}/minio/health/live"; )
	export minio_container minio_container_ip minio_container_http_port

	# Create a bucket and make it public
	docker run --rm --entrypoint sh minio/mc:latest -c "\
		mc alias set myminio http://${minio_container_ip}:9000 AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY; \
		mc mb myminio/test-bucket; \
		mc anonymous set public myminio/test-bucket; \
		" # >&3 2>&3

	# Upload a test site
	docker run --rm \
		-e AWS_ENDPOINT_OVERRIDE=http://${minio_container_ip}:9000 \
		-e AWS_REGION=us-east-1 \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-e AWS_BUCKET_NAME=test-bucket \
		panubo/staticsite-testsite:1 s3sync # >&3 2>&3

}

# setup() {
	
# }

teardown_file() {
	docker rm -f "${minio_container}" || true
}

@test "s3-basic check cache control override index.html" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/index.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=60, s-maxage=60" <<<"${output}"
}

@test "s3-basic check cache control override 404.html" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/404.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=60, s-maxage=60" <<<"${output}"
}

@test "s3-basic check cache control default" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/content.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=3600" <<<"${output}"
}

@test "s3-basic check content-type on index.html" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/index.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Content-Type: text/html" <<<"${output}"
}

@test "s3-basic check content-type on json.json" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/json.json
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Content-Type: application/json" <<<"${output}"
}

@test "s3-basic check content-type on apple-app-site-association (content-type override)" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/.well-known/apple-app-site-association
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Content-Type: application/json" <<<"${output}"
}

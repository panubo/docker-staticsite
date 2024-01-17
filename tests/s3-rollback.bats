load functions.bash
# load setup.bash

setup_file() {
	# Disable parallel execution in this file
	export BATS_NO_PARALLELIZE_WITHIN_FILE=true

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
}

# setup() {
	
# }

teardown_file() {
	docker rm -f "${minio_container}" || true
}

@test "s3-rollback upload v1" {
	docker ps -a >&3 2>&3

	# Upload v1
	docker run --rm \
		-e AWS_ENDPOINT_OVERRIDE=http://${minio_container_ip}:9000 \
		-e AWS_REGION=us-east-1 \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-e AWS_BUCKET_NAME=test-bucket \
		panubo/staticsite-testsite:1 s3sync >&3 2>&3

	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/index.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "<p>v1</p>" <<<"${output}"
}

@test "s3-rollback upload v2" {
	skip
	# Upload v1
	docker run --rm \
		-e AWS_ENDPOINT_OVERRIDE=http://${minio_container_ip}:9000 \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-e AWS_BUCKET_NAME=test-bucket \
		panubo/staticsite-testsite:2 s3sync # >&3 2>&3

	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/index.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "<p>v2</p>" <<<"${output}"
}

@test "s3-rollback rollback to v1" {
	skip
	# Upload v1
	docker run --rm \
		-e AWS_ENDPOINT_OVERRIDE=http://${minio_container_ip}:9000 \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-e AWS_BUCKET_NAME=test-bucket \
		panubo/staticsite-testsite:1 s3sync # >&3 2>&3

	run curl -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/index.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "<p>v1</p>" <<<"${output}"
}

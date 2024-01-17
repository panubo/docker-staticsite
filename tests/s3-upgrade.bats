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

	# Upload v1
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

# `special-cache.html` is the same file between versions but with different cache-control overrides
# This test along with the v2 counterpart below check that the cache-control actually gets updated during upgrade.
@test "s3-upgrade check file specific cache" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/special-cache.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=600" <<<"${output}"
}

# `no-mime-json` is the same file between versions, it does not have a standard extension so automatic mime type detection doesn't work
# v1 does not set content-type override, v2 sets content-type override.
# This test and its counterpart below check that the header actually get updated during upgrade.
@test "s3-upgrade check no-mime-json content-type" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/no-mime-json
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Content-Type: binary/octet-stream" <<<"${output}"
}

# `cached-json` is the same file between versions, it does not have a standard extension so automatic mime type detection doesn't work
# v1 does not set any content-type or cache-control override, v2 sets both overrides. This test and its counterpart below check
# that the two headers actually get updated during upgrade.
@test "s3-upgrade check cached-json content-type and cache-control" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/cached-json
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=3600" <<<"${output}"
	grep "Content-Type: binary/octet-stream" <<<"${output}"
}

@test "s3-upgrade upload v2" {
	run docker run --rm \
		-e AWS_ENDPOINT_OVERRIDE=http://${minio_container_ip}:9000 \
		-e AWS_REGION=us-east-1 \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-e AWS_BUCKET_NAME=test-bucket \
		panubo/staticsite-testsite:2 s3sync
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
}

@test "s3-upgrade check file specific cache after upgrade" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/special-cache.html
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=1200" <<<"${output}"
}

@test "s3-upgrade check no-mime-json content-type after upgrade" {
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/no-mime-json
	# diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Content-Type: application/json" <<<"${output}"
}

@test "s3-upgrade check cached-json content-type and cache-control after upgrade" {
	skip "This test is for a known issue, both content-type and cache-control can not currently be overridden for the same file."
	run curl -i -sSf http://127.0.0.1:${minio_container_http_port}/test-bucket/cached-json
	diag "${output}"

	[[ "${status}" -eq 0 ]]
	grep "Cache-Control: public, max-age=1200" <<<"${output}"
	grep "Content-Type: application/json" <<<"${output}"
}

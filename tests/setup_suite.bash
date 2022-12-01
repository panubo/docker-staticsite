setup_suite() {
	( cd html/v1; DOCKER_BUILDKIT=0 docker build -t panubo/staticsite-testsite:1 .; ) > /dev/null 2>&1
	( cd html/v2; DOCKER_BUILDKIT=0 docker build -t panubo/staticsite-testsite:2 .; ) > /dev/null 2>&1
}

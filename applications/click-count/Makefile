all: compile build-image

compile:
	docker run --rm -v $(PWD):/usr/src/workspace -w /usr/src/workspace \
	                -v $(PWD)/.m2:/root/.m2 \
	                maven:3 mvn clean package

build-image:
	docker build -t xebiafrance/uo-click-count .

push-image:
	docker push xebiafrance/uo-click-count
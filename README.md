LSM-Compactron3000
=======================


## Development

### Create Docker Image

```bash
docker build -t scala:v1 .
docker run -v <absolute-path>/LSM-Compactron3000:/design -it scala:v1 bash
```

### Run

You can run the included test with:
```sh
sbt test
```

To run the main program, you can use:
```sh
sbt run
```

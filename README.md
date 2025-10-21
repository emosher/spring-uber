# Spring Uber

An example Spring project visualizing Uber data from NYC.  Full data set is [here](https://www.kaggle.com/datasets/fivethirtyeight/uber-pickups-in-new-york-city/data).  It uses Java 21 and Gradle 9.  

### Quickstart 

To run the app and Postgres locally, you can do something like this.

```bash
docker run --name spring-uber-postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres:16
```

Copy the example application properties via the command below and edit for your Postgres config.  Then run the app.

```bash
# Change any config via the file as needed
cp application.properties.example src/main/resources/application.properties
# Make sure you have gradle installed with this or similar
brew install gradle
# You might need to generate a gradle wrapper
gradle wrapper
# Run the app
./gradlew bootRun
```

### Running the Bitnami Secure Images Demo

To run the BSI version of this app, you first need a BSI account and a registry set up.  Mine is in the `Dockerfile.bsi` and `docker-compose.bsi.yml`.  You will want to change those values and ensure you have authenticated access to your registry in the `FROM` statment in the Dockerfile and the `image` tag in the Docker Compose.  This app uses the Java 21, Java Minimal 21, and Postgres 16 containers.  Make sure you have those 3 images before running the BSI version of the app.

The demo script also requires the following tools, and will alert you if they are not installed:
 - Vendir
 - Grype
 - Docker
 - Docker Compose
 - jq

```bash
# Edit any env varables as necessary
cp env.example .env
# Change any application config as necessary
cp application.properties.example src/main/resources/application.properties
# Run the demo 
./demo.sh
```

### Deploying to Cloud Foundry

Create your service for Postgres with something like
```bash
cf create-service postgresql [plan-name] spring-uber-db
```
Build the jar
```bash
./gradlew bootJar
```
Push the app to the platform with
```bash
cf push -f manifest.yml
```

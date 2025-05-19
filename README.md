# Spring Uber

An example Spring project visualizing Uber data from NYC.  Full data set is [here](https://www.kaggle.com/datasets/fivethirtyeight/uber-pickups-in-new-york-city/data).  

### Quickstart

To run Postgres locally, you can do something like this.

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

package fr.xebia.clickcount;

import javax.inject.Singleton;

@Singleton
public class Configuration {

    public final String redisHost;
    public final int redisPort;
    public final int redisConnectionTimeout;  //milliseconds

    public Configuration() {

        String envHost = System.getenv("REDIS_HOST");
        redisHost = (envHost != null && !envHost.isEmpty())  ? envHost : "redis";

        String envPort = System.getenv("REDIS_PORT");
        redisPort = (envPort != null && !envPort.isEmpty())  ? Integer.valueOf(envPort) : 6379;

        redisConnectionTimeout = 2000;
    }
}

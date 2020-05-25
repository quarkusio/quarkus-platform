package io.quarkus.platform.camel.timer.test.devmode;

import org.apache.camel.builder.RouteBuilder;
import org.jboss.logging.Logger;

public class TimerRoute extends RouteBuilder {

    private static final Logger LOG = Logger.getLogger(TimerRoute.class);

    @Override
    public void configure() throws Exception {
        from("timer:foo?period=100")
                .process(exchange -> LOG.info("Hello foo"));
    }
}

Wear Connect is a C2C (Customer-to-Customer) e-commerce website that allows users to act as both renters and rental providers.

Rental providers can upload images of their clothing items along with relevant information such as size and hourly rental price. Renters can search for clothing by category or style and then proceed to book the items for their desired rental period.

The system supports core rental-related functions, including rental order management, deposit handling, online payment processing, rental status tracking (ongoing, returned, completed), and refund processing when necessary. In addition, WearConnect provides a rating and review feature that allows users to evaluate each other after completing a transaction, thereby enhancing trust and transparency within the platform.

WearConnect aims to optimize clothing utilization, reduce unnecessary purchases, help users save costs, and promote sustainable consumption through a sharing economy model.

## Run In NetBeans

This project is now a Spring Boot Maven project.

1. Open the project in NetBeans by selecting the folder that contains [pom.xml](pom.xml).
2. Make sure the project JDK is set to Java 17 or newer.
3. Use NetBeans `Run Project` to start the application.

NetBeans is configured with [nbactions.xml](nbactions.xml) so the `Run` action executes `spring-boot:run` instead of the old Ant flow.

Useful actions:

- `Run Project`: starts the Spring Boot app with embedded Tomcat.
- `Debug Project`: starts the Spring Boot app in debug mode.
- `Clean and Build`: creates the WAR package.

If port `8080` is busy, change the port in [src/main/resources/application.properties](src/main/resources/application.properties) before running.

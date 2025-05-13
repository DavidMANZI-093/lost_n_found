import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Main application entry point for Lost and Found application
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@SpringBootApplication
@ComponentScan(basePackages = {
    "controllers",
    "controllers.v1", 
    "services", 
    "repositories", 
    "config",
    "utils",
    "entities",
    "payloads",
    "exceptions"
})
@EntityScan("entities")
@EnableJpaRepositories("repositories")
class Main {
    public static void main(String[] args) {
        SpringApplication.run(Main.class, args);
    }
}

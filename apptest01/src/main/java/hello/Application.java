package hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@SpringBootApplication
@RestController
public class Application {

			@RequestMapping("/")
	        public String home() {
			        return "Hello here is 2nd container for apptest_blue ( nginx -> 1st container )";
				    }

	        public static void main(String[] args) {
			
			        SpringApplication.run(Application.class, args);
				    }

}


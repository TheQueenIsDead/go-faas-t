package main

import (
	"context"
	"fmt"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	amqp "github.com/rabbitmq/amqp091-go"
	"log"
	"net/http"
	"net/url"
	"os"
	"time"
)

const randomImageHost = "https://source.unsplash.com"
const randomImageURL = randomImageHost + "/random"
const staticImageHost = "https://images.unsplash.com"

func defaultHandler(c echo.Context) error {
	return c.HTML(http.StatusOK, "Hello from the producer!")
}

func imageHandler(c echo.Context) error {

	// Send an HTTP GET request for the image
	resp, err := http.Get(randomImageURL)
	failOnError(err, fmt.Sprintf("Could not retrieve image from %s", randomImageURL))
	if err != nil {
		panic(err)
	}

	// Parse the resultant HTTP location after a 302 redirect to a random image
	imageURI := fmt.Sprintf("%s%s", staticImageHost, resp.Request.URL.RequestURI())
	parsedImageUri, err := url.PathUnescape(imageURI)
	failOnError(err, "Could not parse random image URI")

	// Read RabbitMQ credentials from ENV.
	// Named ✨ vaguely ✨ as we are just mounting the default credentials in kubernetes with envFrom.
	amqpHost := os.Getenv("host")
	amqpPort := os.Getenv("port")
	amqpUser := os.Getenv("username")
	amqpPass := os.Getenv("password")
	amqpConnectionString := fmt.Sprintf("amqp://%s:%s@%s:%s/", amqpUser, amqpPass, amqpHost, amqpPort)

	// Connect to AMQP and publish a message with the parsed image URI
	conn, err := amqp.Dial(amqpConnectionString)
	failOnError(err, "Failed to connect to RabbitMQ")
	defer conn.Close()

	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"media", // name
		false,   // durable
		false,   // delete when unused
		false,   // exclusive
		false,   // no-wait
		nil,     // arguments
	)
	failOnError(err, "Failed to declare a queue")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	body := parsedImageUri
	err = ch.PublishWithContext(ctx,
		"",     // exchange
		q.Name, // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "text/plain",
			Body:        []byte(body),
		})
	failOnError(err, "Failed to publish a message")
	log.Printf(" [x] Sent %s\n", body)

	return c.HTML(http.StatusOK, parsedImageUri)
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}

func main() {

	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", defaultHandler)
	e.GET("/store-image", imageHandler)

	httpPort := os.Getenv("HTTP_PORT")
	if httpPort == "" {
		httpPort = "8080"
	}

	e.Logger.Fatal(e.Start(":" + httpPort))
}

package main

import (
	"fmt"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"io"
	"net/http"
	"net/url"
	"os"
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
	if err != nil {
		panic(err)
	}

	// Open a file to save the image
	file, err := os.Create("image.jpeg")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	// Copy the image data from the response to the file
	_, err = io.Copy(file, resp.Body)
	if err != nil {
		panic(err)
	}

	imageURI := fmt.Sprintf("%s%s", staticImageHost, resp.Request.URL.RequestURI())
	parsedImageUri, err := url.PathUnescape(imageURI)
	if err != nil {
		panic(err)
	}

	return c.HTML(http.StatusOK, parsedImageUri)
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

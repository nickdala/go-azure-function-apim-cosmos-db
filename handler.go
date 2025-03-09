package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

// TODO item represents an item in the MongoDB
type TodoItem struct {
	ID    string `json:"id" bson:"_id"`
	Title string `json:"title" bson:"title"`
	Done  bool   `json:"done" bson:"done"`
}

// TODO handler handles the HTTP requests for TODO items
type TodoHandler struct {
	todoItems []TodoItem
}

// NewTodoHandler creates a new TODO handler
func NewTodoHandler() *TodoHandler {
	return &TodoHandler{
		todoItems: []TodoItem{
			{ID: "1", Title: "Learn Go", Done: false},
		},
	}
}

// SayHello handles GET requests to say hello
func (h *TodoHandler) SayHello(c *gin.Context) {
	log.Println("Saying hello")
	c.JSON(http.StatusOK, gin.H{"message": "Hello, World!"})
}

// GetTodoItems handles GET requests to retrieve all TODO items
func (h *TodoHandler) GetTodoItems(c *gin.Context) {
	log.Println("Fetching all TODO items")
	c.JSON(http.StatusOK, h.todoItems)
}

// CreateTodoItem handles POST requests to create a new TODO item
func (h *TodoHandler) CreateOrUpdateTodoItem(c *gin.Context) {
	var todoItem TodoItem
	if err := c.ShouldBindJSON(&todoItem); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}
	h.todoItems = append(h.todoItems, todoItem)
	c.JSON(http.StatusCreated, todoItem)
}

// GetTodoItem handles GET requests to retrieve a specific TODO item by ID
func (h *TodoHandler) GetTodoItem(c *gin.Context) {
	id := c.Param("id")
	for _, item := range h.todoItems {
		if item.ID == id {
			c.JSON(http.StatusOK, item)
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
}

// SetupRouter sets up the HTTP routes and handlers
func SetupRouter() *gin.Engine {
	router := gin.Default()
	todoHandler := NewTodoHandler()

	router.GET("/api/hello", todoHandler.SayHello)

	router.GET("/api/todos", todoHandler.GetTodoItems)
	router.POST("/api/todos", todoHandler.CreateOrUpdateTodoItem)
	router.GET("/api/todos/:id", todoHandler.GetTodoItem)

	return router
}

// main function initializes the router and starts the server

func main() {

	router := SetupRouter()

	listenerPort := ":8080"
	if val, ok := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT"); ok {
		listenerPort = ":" + val
	}

	log.Printf("Starting server on port %s", listenerPort)

	router.Run(listenerPort)

}

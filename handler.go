package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"

	"github.com/nickdala/go-azure-function-apim-cosmos-db/repositories"
)

// TODO handler handles the HTTP requests for TODO items
type TodoHandler struct {
	todoItemRopository *repositories.TodoItemRepository
}

// NewTodoHandler creates a new TODO handler
func NewTodoHandler() *TodoHandler {
	return &TodoHandler{
		todoItemRopository: repositories.NewTodoItemRepository(),
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
	// Get the MongoDB collection from the client
	todos := h.todoItemRopository.GetAllTodos()
	c.JSON(http.StatusOK, todos)
}

// CreateTodoItem handles POST requests to create a new TODO item
func (h *TodoHandler) CreateOrUpdateTodoItem(c *gin.Context) {
	var todoItem repositories.TodoItem
	if err := c.ShouldBindJSON(&todoItem); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	insertedTodo := h.todoItemRopository.CreateOrUpdateTodoItem(&todoItem)
	c.JSON(http.StatusCreated, insertedTodo)
}

// GetTodoItem handles GET requests to retrieve a specific TODO item by ID
func (h *TodoHandler) GetTodoItem(c *gin.Context) {
	id := c.Param("id")
	log.Printf("Fetching TODO item with ID: %s", id)

	todoItem, err := h.todoItemRopository.GetTodoItemByID(id)
	if err != nil {
		log.Printf("Error fetching TODO item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch TODO item"})
		return
	}
	if todoItem != nil {
		c.JSON(http.StatusOK, todoItem)
		return
	}
	log.Printf("TODO item with ID %s not found", id)
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

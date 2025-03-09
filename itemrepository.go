package main

import (
	"context"
	"log"
	"os"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

// TODO item represents an item in the MongoDB
type TodoItem struct {
	ID    string `json:"id" bson:"_id"`
	Title string `json:"title" bson:"title"`
	Done  bool   `json:"done" bson:"done"`
}

type TodoItemRepository struct {
	// MongoDB client
	mongodbClient *mongo.Client

	// MongoDB database
	databaseName string

	// Collection name
	collectionName string
}

// NewTodoItemRepository creates a new TODO item repository
func NewTodoItemRepository() *TodoItemRepository {
	uri := os.Getenv("MONGODB_URI")
	if uri == "" {
		uri = "mongodb://localhost:27017"
	}

	// Set the client options
	clientOptions := options.Client().ApplyURI(uri)

	client, err := mongo.Connect(clientOptions)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	// Check the connection
	err = client.Ping(context.TODO(), nil)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Connected to Cosmos DB MongoDB instance!")
	return &TodoItemRepository{
		mongodbClient:  client,
		databaseName:   "todosdb",
		collectionName: "todos",
	}
}

func (repo *TodoItemRepository) GetAllTodos() []*TodoItem {
	collection := repo.mongodbClient.Database(repo.databaseName).Collection(repo.collectionName)

	// Find all TODO items
	cursor, err := collection.Find(context.TODO(), nil)
	if err != nil {
		log.Fatalf("Failed to fetch TODO items: %v", err)
	}
	defer cursor.Close(context.TODO())

	var todoItems []*TodoItem
	for cursor.Next(context.TODO()) {
		var todoItem TodoItem
		if err := cursor.Decode(&todoItem); err != nil {
			log.Fatalf("Failed to decode TODO item: %v", err)
		}
		todoItems = append(todoItems, &todoItem)
	}

	return todoItems
}

func (repo *TodoItemRepository) CreateOrUpdateTodoItem(todoItem *TodoItem) *TodoItem {
	collection := repo.mongodbClient.Database(repo.databaseName).Collection(repo.collectionName)

	// Check if the ID is empty, if so, generate a new ID
	if todoItem.ID == "" {
		// Set the ID field to a new unique ID
		todoItem.ID = primitive.NewObjectID()
	}

	// Insert or update the TODO item
	filter := bson.M{"_id": todoItem.ID}
	update := bson.M{"$set": todoItem}
	opts := options.UpdateOne().SetUpsert(true)
	result, err := collection.UpdateOne(context.TODO(), filter, update, opts)
	if err != nil {
		log.Fatalf("Failed to create or update TODO item: %v", err)
	}
}

package repositories

import (
	"context"
	"log"
	"os"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/v2/bson"
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
		mongodbClient: client,
	}
}

// Return the todos collection
func (repo *TodoItemRepository) getCollection() *mongo.Collection {
	collection := repo.mongodbClient.Database("todosdb").Collection("todos")
	return collection
}

func (repo *TodoItemRepository) GetAllTodos() []*TodoItem {
	collection := repo.getCollection()

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

func (repo *TodoItemRepository) CreateTodoItem(todoItem *TodoItem) *TodoItem {
	collection := repo.getCollection()

	// Insert the TODO item into the collection
	result, err := collection.InsertOne(context.TODO(), todoItem)
	if err != nil {
		log.Fatalf("Failed to insert TODO item: %v", err)
	}
	todoItem.ID = result.InsertedID.(primitive.ObjectID).Hex()
	return todoItem
}

func (repo *TodoItemRepository) UpdateTodoItem(todoItem *TodoItem) *TodoItem {
	collection := repo.getCollection()

	// Update the TODO item in the collection
	filter := bson.M{"_id": todoItem.ID}
	update := bson.M{"$set": todoItem}
	_, err := collection.UpdateOne(context.TODO(), filter, update)
	if err != nil {
		log.Fatalf("Failed to update TODO item: %v", err)
	}

	return todoItem
}

func (repo *TodoItemRepository) CreateOrUpdateTodoItem(todoItem *TodoItem) *TodoItem {

	// Check if the ID is empty, if so, generate a new ID
	if todoItem.ID == "" {
		return repo.CreateTodoItem(todoItem)
	}

	return repo.UpdateTodoItem(todoItem)
}

func (repo *TodoItemRepository) GetTodoItemByID(id string) (*TodoItem, error) {
	collection := repo.getCollection()

	// Convert the ID string to an ObjectID
	objectID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}

	var todoItem TodoItem
	err = collection.FindOne(context.TODO(), bson.M{"_id": objectID}).Decode(&todoItem)
	if err != nil {
		return nil, err
	}

	return &todoItem, nil
}

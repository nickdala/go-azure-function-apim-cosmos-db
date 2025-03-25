package repositories

import (
	"context"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// TODO item represents an item in the MongoDB
type TodoItem struct {
	ID    primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Title string             `json:"title" bson:"title"`
	Done  bool               `json:"done" bson:"done"`
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

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
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

func (repo *TodoItemRepository) GetAllTodos() []TodoItem {
	collection := repo.getCollection()

	// Find all TODO items
	condition := bson.M{}
	cursor, err := collection.Find(context.Background(), condition)
	if err != nil {
		log.Fatalf("Failed to fetch TODO items: %v", err)
	}
	defer cursor.Close(context.TODO())

	var todoItems []TodoItem
	if err := cursor.All(context.Background(), &todoItems); err != nil {
		log.Fatal(err)
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
	todoItem.ID = result.InsertedID.(primitive.ObjectID)
	return todoItem
}

func (repo *TodoItemRepository) UpdateTodoItem(todoItem *TodoItem) *TodoItem {
	log.Println("Updating TODO item:", todoItem)
	collection := repo.getCollection()

	// Update the TODO item in the collection
	filter := bson.M{"_id": todoItem.ID}
	update := bson.M{"$set": todoItem}

	opts := options.FindOneAndUpdate().SetReturnDocument(options.After)
	res := collection.FindOneAndUpdate(context.TODO(), filter, update, opts)
	if res.Err() != nil {
		log.Fatalf("Failed to update TODO item: %v", res.Err())
	}
	// Decode the updated TODO item
	var updatedData TodoItem
	if err := res.Decode(&updatedData); err != nil {
		log.Fatalf("Failed to decode updated TODO item: %v", err)
	}
	return &updatedData
}

func (repo *TodoItemRepository) CreateOrUpdateTodoItem(todoItem *TodoItem) *TodoItem {

	// Check if the ID is empty, if so, generate a new ID
	if todoItem.ID == primitive.NilObjectID {
		log.Panicln("The ID is empty, creating a new TODO item")
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

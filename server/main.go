package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"tailscale.com/tsnet"
)

type DashboardResponse struct {
	Family   []FamilyMember `json:"family"`
	Events   []Event        `json:"events"`
	Shopping []ShoppingItem `json:"shopping"`
	Note     Note           `json:"note"`
	Pi       PiStatus       `json:"pi"`
}

type FamilyMember struct {
	ID            string  `json:"id"`
	Name          string  `json:"name"`
	AvatarURL     *string `json:"avatarURL"`
	Status        string  `json:"status"`
	IsCurrentUser bool    `json:"isCurrentUser"`
}

type Event struct {
	ID       string    `json:"id"`
	Title    string    `json:"title"`
	Date     time.Time `json:"date"`
	PersonID string    `json:"personId"`
}

type ShoppingItem struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	Completed bool   `json:"completed"`
}

type Note struct {
	ID      string `json:"id"`
	Content string `json:"content"`
}

type PiStatus struct {
	ID                 string  `json:"id"`
	TailscaleConnected bool    `json:"tailscaleConnected"`
	CPUUsage           float64 `json:"cpuUsage"`
	StorageUsage       float64 `json:"storageUsage"`
}

func main() {
	// 1. Initialize tsnet server
	s := &tsnet.Server{
		Hostname: "amaka-hub",
	}
	defer s.Close()

	ln, err := s.Listen("tcp", ":80")
	if err != nil {
		log.Fatal(err)
	}
	defer ln.Close()

	fmt.Printf("Amaka Hub is now live on your Tailscale network at http://amaka-hub/\n")

	// 2. Setup handlers
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "./templates/index.html")
	})

	http.HandleFunc("/api/dashboard", func(w http.ResponseWriter, r *http.Request) {
		data := DashboardResponse{
			Family: []FamilyMember{
				{ID: "1", Name: "Noah", Status: "At Home", IsCurrentUser: true},
				{ID: "2", Name: "Sarah", Status: "At Work"},
				{ID: "3", Name: "Emma", Status: "School"},
			},
			Events: []Event{
				{ID: "e1", Title: "Dinner with Gran", Date: time.Now().Add(24 * time.Hour), PersonID: "1"},
				{ID: "e2", Title: "Piano Lesson", Date: time.Now().Add(5 * time.Hour), PersonID: "3"},
			},
			Shopping: []ShoppingItem{
				{ID: "s1", Title: "Milk", Completed: false},
				{ID: "s2", Title: "Eggs", Completed: true},
				{ID: "s3", Title: "Bread", Completed: false},
			},
			Note: Note{ID: "n1", Content: "Welcome to Amaka! This is your secure family note area via tsnet."},
			Pi: PiStatus{
				ID:                 "p1",
				TailscaleConnected: true,
				CPUUsage:           0.12,
				StorageUsage:       0.45,
			},
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(data)
	})

	// 3. Start server
	log.Fatal(http.Serve(ln, nil))
}

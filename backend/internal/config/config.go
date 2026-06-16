package config

import (
	"os"
)

type Config struct {
	Port           string
	DBPath         string
	AllowedOrigins []string
}

func Load() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "propostas.db" // Fallback SQLite file
	}

	return &Config{
		Port:           port,
		DBPath:         dbPath,
		AllowedOrigins: []string{"http://localhost:4200"},
	}
}

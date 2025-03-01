import json
import yaml
import os
import datetime

# Load dbt manifest.json
with open("target/manifest.json", "r") as f:
    manifest = json.load(f)

# Create data structure to hold all documentation
all_documentation = {
    "models": {},
    "sources": {}
}

# Extract documentation for all models
models_processed = 0
print("Extracting documentation for all models...")

for node_id, node_data in manifest["nodes"].items():
    # Only process models (not sources, tests, etc.)
    if node_id.startswith("model."):
        model_data = node_data
        
        # Format the extracted data
        model_doc = {
            "model_name": model_data["name"],
            "full_model_name": node_id,
            "description": model_data.get("description", "No description available"),
            "columns": {
                col_name: {
                    "description": col_data.get("description", "No description"),
                    "data_type": col_data.get("data_type", "Unknown")
                }
                for col_name, col_data in model_data.get("columns", {}).items()
            },
            "tags": model_data.get("tags", []),
            "database": model_data.get("database", ""),
            "schema": model_data.get("schema", ""),
            "depends_on": model_data.get("depends_on", {}).get("nodes", []),
            "created_at": model_data.get("created_at", "Unknown"),
        }
        
        # Add to the combined documentation
        all_documentation["models"][model_data["name"]] = model_doc
        models_processed += 1
        print(f"Processed model: {model_data['name']}")

# Extract sources
sources_processed = 0
print("\nExtracting documentation for all sources...")

for source_id, source_data in manifest["sources"].items():
    source_doc = {
        "source_name": source_data["name"],
        "full_source_name": source_id,
        "description": source_data.get("description", "No description available"),
        "columns": {
            col_name: {
                "description": col_data.get("description", "No description"),
                "data_type": col_data.get("data_type", "Unknown")
            }
            for col_name, col_data in source_data.get("columns", {}).items()
        },
        "database": source_data.get("database", ""),
        "schema": source_data.get("schema", ""),
    }
    
    # Add to the combined documentation
    all_documentation["sources"][source_data["name"]] = source_doc
    sources_processed += 1
    print(f"Processed source: {source_data['name']}")

# Add summary counts
all_documentation["summary"] = {
    "total_models": models_processed,
    "total_sources": sources_processed,
    "generated_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
}

# Save as a single JSON file
with open("dbt_documentation.json", "w") as json_file:
    json.dump(all_documentation, json_file, indent=2)

# Save as a single YAML file
with open("dbt_documentation.yaml", "w") as yaml_file:
    yaml.dump(all_documentation, yaml_file, default_flow_style=False)

print(f"\nSuccessfully generated documentation for {models_processed} models and {sources_processed} sources.")
print("Files created:")
print("- dbt_documentation.json")
print("- dbt_documentation.yaml")
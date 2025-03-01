#!/usr/bin/env python3
"""
Extract schema information from dbt-generated documentation files.
Usage: python extract_schemas_from_dbt.py

This script reads from manifest.json and catalog.json in the target/ directory
and extracts schema information for all models and sources, creating a single consolidated
JSON file containing all schema information with BigQuery full table names.
"""

import json
import os
import sys

# Output file
OUTPUT_DIR = "schemas"
os.makedirs(OUTPUT_DIR, exist_ok=True)
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "all_schemas.json")

def main():
    # Check for required files
    manifest_path = "target/manifest.json"
    catalog_path = "target/catalog.json"
    
    if not os.path.exists(manifest_path):
        print(f"Error: {manifest_path} not found.")
        print("Please run 'dbt docs generate' first.")
        sys.exit(1)
    
    if not os.path.exists(catalog_path):
        print(f"Error: {catalog_path} not found.")
        print("Please run 'dbt docs generate' first.")
        sys.exit(1)
    
    # Load the files
    print("Loading manifest and catalog files...")
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)
    
    with open(catalog_path, 'r') as f:
        catalog = json.load(f)
    
    # Initialize the consolidated schema dictionary
    all_schemas = {
        "models": {},
        "sources": {}
    }
    
    # Process all models
    print("Extracting schema information...")
    model_count = 0
    source_count = 0
    
    # Process nodes (models)
    for node_id, node_info in manifest.get("nodes", {}).items():
        if node_id.startswith("model."):
            model_name = node_info.get("name")
            schema_name = node_info.get("schema")
            database_name = node_info.get("database")
            project_id = node_info.get("config", {}).get("project", database_name)
            
            # Construct full BigQuery table name
            full_table_name = f"{project_id}.{schema_name}.{model_name}"
            
            print(f"Processing model: {full_table_name}")
            
            # Get column information from both files
            model_columns = {}
            
            # Get descriptions from manifest
            manifest_columns = node_info.get("columns", {})
            for col_name, col_info in manifest_columns.items():
                model_columns[col_name] = {
                    "name": col_name,
                    "description": col_info.get("description", ""),
                    "type": "unknown"  # Will be updated from catalog
                }
            
            # Get data types from catalog
            catalog_node_id = f"model.{node_info.get('package_name')}.{model_name}"
            if catalog_node_id in catalog.get("nodes", {}):
                catalog_columns = catalog["nodes"][catalog_node_id].get("columns", {})
                for col_name, col_info in catalog_columns.items():
                    if col_name in model_columns:
                        model_columns[col_name]["type"] = col_info.get("type")
                    else:
                        model_columns[col_name] = {
                            "name": col_name,
                            "description": "",
                            "type": col_info.get("type")
                        }
            
            # Create output schema
            model_schema = {
                "name": model_name,
                "schema": schema_name,
                "database": database_name,
                "project": project_id,
                "full_table_name": full_table_name,
                "description": node_info.get("description", ""),
                "columns": model_columns,
                "meta": node_info.get("meta", {})
            }
            
            # Add to consolidated schema
            all_schemas["models"][full_table_name] = model_schema
            model_count += 1
    
    # Process sources
    for source_id, source_info in manifest.get("sources", {}).items():
        source_name = source_info.get("name")
        schema_name = source_info.get("schema")
        database_name = source_info.get("database")
        project_id = source_info.get("config", {}).get("project", database_name)
        
        # Construct full BigQuery table name
        full_table_name = f"{project_id}.{schema_name}.{source_name}"
        
        print(f"Processing source: {full_table_name}")
        
        # Get column information from both files
        source_columns = {}
        
        # Get descriptions from manifest
        manifest_columns = source_info.get("columns", {})
        for col_name, col_info in manifest_columns.items():
            source_columns[col_name] = {
                "name": col_name,
                "description": col_info.get("description", ""),
                "type": "unknown"  # Will be updated from catalog
            }
        
        # Get data types from catalog
        catalog_source_id = f"source.{source_info.get('package_name')}.{source_info.get('source_name')}.{source_name}"
        if catalog_source_id in catalog.get("sources", {}):
            catalog_columns = catalog["sources"][catalog_source_id].get("columns", {})
            for col_name, col_info in catalog_columns.items():
                if col_name in source_columns:
                    source_columns[col_name]["type"] = col_info.get("type")
                else:
                    source_columns[col_name] = {
                        "name": col_name,
                        "description": "",
                        "type": col_info.get("type")
                    }
        
        # Create output schema
        source_schema = {
            "name": source_name,
            "schema": schema_name,
            "database": database_name,
            "project": project_id,
            "full_table_name": full_table_name,
            "description": source_info.get("description", ""),
            "columns": source_columns,
            "meta": source_info.get("meta", {})
        }
        
        # Add to consolidated schema
        all_schemas["sources"][full_table_name] = source_schema
        source_count += 1
    
    # Write all schemas to a single file
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(all_schemas, f, indent=2)
    
    print(f"Successfully extracted schemas for {model_count} models and {source_count} sources.")
    print(f"All schemas are saved in {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
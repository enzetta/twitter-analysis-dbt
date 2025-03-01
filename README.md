# Twitter Political Discourse Analysis (dbt)

## Overview

This project is part of a **Bachelor's Thesis** analyzing **political discourse on Twitter** in Germany between **2020 and 2021**. The analysis focuses on:

- The role of politicians and politically engaged users in shaping discourse.
- The interaction dynamics between different political factions.
- The categorization of hashtags into political topics.
- The spread of political messaging across different user groups.

The project uses **dbt (Data Build Tool)** for **data modeling and transformation** to clean, structure, and analyze Twitter data.

---

## **Project Structure**

This dbt project is structured as follows:

```
├── models/
│   ├── source/           # Raw Twitter and politician data sources
│   ├── staging/          # Intermediate transformations
│   ├── curated/          # Final curated models for analysis
│   ├── analyses/         # Aggregated analysis models
│   ├── tests/            # Data quality tests
│   ├── macros/           # Custom dbt macros
│── seeds/                # Pre-loaded reference data
│── snapshots/            # Historical snapshots (if used)
│── dbt_project.yml       # dbt configuration
│── profiles.yml          # Database connection settings
│── requirements.txt      # Python dependencies
│── Makefile              # Helper commands for running dbt
└── README.md             # This file
```

---

## **Key dbt Models & Transformations**

### **1. Data Sources (`models/source/`)**
- `interactions.sql`: Raw tweets from Zenodo dataset.
- `users.sql`: Twitter user metadata.
- `ext_epi_netz_de.sql`: List of verified German politicians.

### **2. Data Staging (`models/staging/`)**
- `00_interactions_with_referrers.sql`: Extracts tweet metadata, hashtags, and references.
- `01_political_users.sql`: Identifies verified politicians from the dataset.
- `02_politically_engaged_users.sql`: Expands the set to include users engaged in political discussions.
- `02_political_hashtags_count.sql`: Counts hashtag occurrences among politicians.

### **3. Curated Analysis (`models/curated/`)**
- `political_hashtags_by_user.sql`: Tracks which users are using which political hashtags.
- `hashtags_categories_exploded.sql`: Breaks down hashtags into individual categories. Each hashtag and category combination is here in a seperate row.
- `hashtag_categories_aggregated.sql`: Breaks down hashtags into individual categories. Categories are grouped together in a list so each hashtag only occurs once.
- `relevant_tweets.sql`: Extracts tweets from users engaged in political discourse.

### **4. Aggregated Analyses (`models/analyses/`)**
- `category_stats_overall.sql`: Aggregates tweets and engagement per hashtag category.
- `category_stats_weekly.sql`: Weekly trends in hashtag usage.
- `hashtags_monthly.sql`: Monthly evolution of hashtag engagement.
- `politician_hashtags_monthly.sql`: Monthly hashtag usage trends among politicians.
- `relative_ratio_by_party.sql`: Computes relative engagement ratios for each political party.

---

## **Installation & Setup**

### **1. Install Required Dependencies**
Ensure you have Python 3.8+ and [dbt](https://docs.getdbt.com/docs/installation) installed:

```sh
pip install -r requirements.txt
```

### **2. Set Up dbt**
Configure your database connection by editing **`profiles.yml`**:

```yaml
ba_twitter_analysis:
  outputs:
    dev:
      type: bigquery
      project: your-google-cloud-project
      dataset: twitter_analysis
      keyfile: .secrets/service-account.json
      location: EU
      threads: 4
      priority: interactive
  target: dev
```

### **3. Initialize dbt**
Run the following commands to prepare the environment:

```sh
# Install dbt dependencies
dbt deps

# Load seed data (if applicable)
dbt seed
```

---

## **Usage & Running dbt Models**

### **1. Run All Models**
```sh
dbt build
```

### **2. Run Specific Models**
```sh
dbt run --models staging.political_users+
```

### **3. Full Refresh**
```sh
dbt build --full-refresh
```

### **4. Generate Documentation**
```sh
dbt docs generate
dbt docs serve
```

---

## **Expected Output & Insights**

### **1. Political User Categorization**
- Identifies **politicians**, **politically engaged users**, and **politically connected users**.

### **2. Hashtag Trends**
- Tracks the most used hashtags by different political factions.
- Aggregates hashtag usage by **week**, **month**, and **political category**.

### **3. Political Engagement Ratios**
- Computes the ratio of tweets per political party to assess their relative engagement.
- Measures the spread of hashtags across different user types.

---

## **Pre-commit Hooks & Code Quality**
This project uses **SQLFluff**, **Black**, and **isort** for code quality:

```sh
# Run linters
make lint

# Fix lint issues
make lint-fix
```

---

## **License & Acknowledgements**
This project is part of a **Bachelor's Thesis** analyzing social media polarization. Data sources include **Zenodo's Twitter dataset** and **publicly available information on German politicians**.

export GOOGLE_APPLICATION_CREDENTIALS=/Users/calvindudek/projects/sophie/twitter-analysis-dbt/.secrets/service-account.json

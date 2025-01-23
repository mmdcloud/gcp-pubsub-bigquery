module "im-workspace" {
 source = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
 version = "~> 7.0"

 project_id = nodal-talon-445602-m1
 deployment_id = projects/nodal-talon-445602-m1/locations/us-central1/deployments/pubsub-bq
 im_deployment_repo_uri = https://github.com/mmdcloud/gcp-pubsub-bigquery
 im_deployment_ref = master

 github_app_installation_id = 58404554
 github_personal_access_token = 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
}

data "google_project" "project" {}

resource "google_pubsub_schema" "topic_schema" {
  name       = "pubsubbq-topic-schema"
  type       = "AVRO"
  definition = "{\n  \"type\" : \"record\",\n  \"name\" : \"Avro\",\n  \"fields\" : [\n    {\n      \"name\" : \"name\",\n      \"type\" : \"string\"\n    },\n    {\n      \"name\" : \"city\",\n      \"type\" : \"string\"\n    }\n  ]\n}\n"
}

resource "google_pubsub_topic" "topic" {
  name = "pubsubbq-topic"

  labels = {
    foo = "bar"
  }
  schema_settings {
    encoding = "JSON"
    schema = google_pubsub_schema.topic_schema.id
  }
  message_retention_duration = "86600s"
}


resource "google_pubsub_subscription" "topic_subscription" {
  name  = "pubsubbq-topic-subscription"
  topic = google_pubsub_topic.topic.id

  bigquery_config {
    use_topic_schema = true
    table            = "${google_bigquery_table.table.project}.${google_bigquery_table.table.dataset_id}.${google_bigquery_table.table.table_id}"
  }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "pubsubbqdataset"
}


resource "google_bigquery_table" "table" {
  table_id   = "pubsubbq-table"
  dataset_id = google_bigquery_dataset.dataset.dataset_id

  schema = <<EOF
[
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  }
]
EOF

  deletion_protection = false
}

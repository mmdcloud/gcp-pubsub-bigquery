module "bigquery" {
  source     = "./modules/bigquery"
  dataset_id = "pubsubbqdataset"
  tables = [{
    table_id            = "pubsubbq-table"
    deletion_protection = false
    schema              = <<EOF
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
  }]
}

module "pubsub" {
  source                     = "./modules/pubsub"
  topic_name                 = "pubsubbq-topic"
  schema_name                = "pubsubbq-topic-schema"
  schema_type                = "AVRO"
  schema_encoding            = "JSON"
  message_retention_duration = "86600s"
  schema_definition          = "{\n  \"type\" : \"record\",\n  \"name\" : \"Avro\",\n  \"fields\" : [\n    {\n      \"name\" : \"name\",\n      \"type\" : \"string\"\n    },\n    {\n      \"name\" : \"city\",\n      \"type\" : \"string\"\n    }\n  ]\n}\n"
  subscriptions = [
    {
      subscription_name   = "pubsubbq-topic-subscription"
      bq_use_topic_schema = true
      bq_table            = "${module.bigquery.tables[0].project}.${module.bigquery.tables[0].dataset_id}.${module.bigquery.tables[0].table_id}"
    }
  ]
}

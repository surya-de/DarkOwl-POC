resource "aws_dynamodb_table" "StoreApiValue" {
  name = "StoreApiValue"
  billing_mode = "PROVISIONED"
  hash_key = "timestamp"
  read_capacity = 10
  write_capacity = 10
  attribute {
    name = "timestamp"
    type = "S"
  }
}
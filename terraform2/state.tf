terraform {
  backend "s3" {
    bucket = "columnstore-tf-state"
    key    = "drone2"
  }
}

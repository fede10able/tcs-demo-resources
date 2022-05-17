locals {
    db_name = "db${random_string.lab_id.result}"

}

resource "aws_db_subnet_group" "sg" {
    name       = lower("sng-${random_string.lab_id.result}")
    subnet_ids = module.vpc.private_subnets
    tags = {
        Name = "sng-${random_string.lab_id.result}"
        "Lab-ID" = random_string.lab_id.result
    } 

}

resource "aws_db_instance" "db" {
    max_allocated_storage = 0 # Disable storage grow 
    
    allocated_storage = 10 # In gigabytes
    storage_type = "gp2"
    
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    
    name = local.db_name
    username = "admin"
    password = random_string.lab_id.result
    
    multi_az = true ## HA Deploiment in multi subnet
    db_subnet_group_name = aws_db_subnet_group.sg.name

    publicly_accessible = false
    skip_final_snapshot = true

    identifier = lower(local.db_name)
    vpc_security_group_ids = [ aws_security_group.db.id ]


    tags = {
        Name = local.db_name
        "Lab-ID" = random_string.lab_id.result
    } 
}

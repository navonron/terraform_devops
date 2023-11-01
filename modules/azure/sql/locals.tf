locals {
  dbs = flatten([
    for server_key, server in var.sql : [
      for db_key, db in server.dbs : {
        server_key               = server_key
        db_key                   = db_key
        workload                 = db.workload
        create_mode              = db.create_mode
        sku                      = db.sku
        max_size_gb              = db.max_size_gb
        min_capacity             = db.min_capacity
        sa_type                  = db.sa_type
        license                  = db.license
        short_term_backup_config = db.short_term_backup_config
        long_term_backup_config  = db.long_term_backup_config
      }
    ]
  ])
}

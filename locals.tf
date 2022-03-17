locals {
  system_name = "${var.project.name}-${var.stage.short_name}"
  tags = {
      Env = var.stage.name
      Project = var.project.name
  }
}


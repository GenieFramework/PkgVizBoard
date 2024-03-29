using Genie, Logging

Genie.Configuration.config!(
  server_port                     = 8000,
  server_host                     = "127.0.0.1",
  log_level                       = Logging.Info,
  log_to_file                     = false,
  server_handle_static_files      = true,
  path_build                      = "build",
  format_julia_builds             = false,
  format_html_output              = true,
  cors_allowed_origins            = ["*"],
  base_path                       = "",
)

ENV["JULIA_REVISE"] = "auto"
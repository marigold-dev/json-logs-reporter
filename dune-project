(lang dune 2.9)
(name json-logs-reporter)
(version 0.1.0)

(generate_opam_files true)

(source (github marigold-dev/json-logs-reporter))
(license MIT)
(authors "Ulrik Strid")
(maintainers "ulrik@marigold.dev")

(package
 (name json-logs-reporter)
 (synopsis "JSON reporter for Logs")
 (description "A Logs reporter that prints in JSON format that is easy to parse with fluentd")
 (depends
  logs
  fmt
  ptime
  yojson
  (ppx_here (and :dev (>= 0.14.0)))))